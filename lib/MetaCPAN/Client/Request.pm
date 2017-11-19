use strict;
use warnings;
package MetaCPAN::Client::Request;
# ABSTRACT: Object used for making requests to MetaCPAN

use Moo;
use Carp;
use JSON::MaybeXS qw<decode_json encode_json>;
use Ref::Util qw< is_arrayref is_hashref is_ref >;

use MetaCPAN::Client::Scroll;
use MetaCPAN::Client::Types qw< HashRef Int >;

with 'MetaCPAN::Client::Role::HasUA';

has _clientinfo => (
    is      => 'ro',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_clientinfo',
);

has domain => (
    is      => 'ro',
    default => sub {
        $ENV{METACPAN_DOMAIN} and return $ENV{METACPAN_DOMAIN};
        $_[0]->_clientinfo->{production}{domain};
    },
);

has base_url => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        $ENV{METACPAN_DOMAIN} and return $ENV{METACPAN_DOMAIN};
        $_[0]->_clientinfo->{production}{url};
    },
);

has _is_agg => (
    is      => 'ro',
    default => 0,
    writer  => '_set_is_agg'
);

has debug => (
    is      => 'ro',
    isa     => Int,
    default => 0,
);

sub BUILDARGS {
    my ( $self, %args ) = @_;
    $args{domain} and $args{base_url} = $args{domain};
    return \%args;
}

sub _build_clientinfo {
    my $self = shift;

    my $info;
    eval {
        $info = $self->ua->get( 'https://clientinfo.metacpan.org' );
        $info = decode_json( $info->{content} );
        is_hashref($info) and exists $info->{production} or die;
        1;
    }
    or $info = +{
        production => {
            url    => 'https://fastapi.metacpan.org', # last known production url
            domain => 'https://fastapi.metacpan.org', # last known production domain
        }
    };

    return $info;
}

sub fetch {
    my $self    = shift;
    my $url     = shift or croak 'fetch must be called with a URL parameter';
    my $params  = shift || {};
    $url =~ s{^/}{};
    my $req_url = sprintf '%s/%s', $self->base_url, $url;
    my $ua      = $self->ua;

    my $result  = keys %{$params}
        ? $ua->post( $req_url, { content => encode_json $params } )
        : $ua->get($req_url);

    return $self->_decode_result( $result, $req_url );
}

sub ssearch {
    my $self   = shift;
    my $type   = shift;
    my $args   = shift;
    my $params = shift;

    my $time = delete $params->{'scroller_time'} || '5m';
    my $size = delete $params->{'scroller_size'} || 1000;

    my $scroller = MetaCPAN::Client::Scroll->new(
        ua       => $self->ua,
        size     => $size,
        time     => $time,
        base_url => $self->base_url,
        type     => $type,
        body     => $self->_build_body($args, $params),
        debug    => $self->debug,
    );

    return $scroller;
}

sub _decode_result {
    my $self   = shift;
    my $result = shift;
    my $url    = shift or croak 'Second argument of a URL must be provided';

    is_hashref($result)
        or croak 'First argument must be hashref';

    my $success = $result->{'success'};

    defined $success
        or croak 'Missing success in return value';

    $success
        or croak "Failed to fetch '$url': " . $result->{'reason'};

    my $content = $result->{'content'}
        or croak 'Missing content in return value';

    $url =~ m|/pod/|    and return $content;
    $url =~ m|/source/| and return $content;

    my $decoded_result;
    eval {
        $decoded_result = decode_json $content;
        1;
    } or do {
        croak "Couldn't decode '$content': $@";
    };

    return $decoded_result;
}

sub _build_body {
    my $self   = shift;
    my $args   = shift;
    my $params = shift;

    my $query = $args->{__MATCH_ALL__}
        ? { match_all => {} }
        : _build_query_rec($args);

    return +{
        query => $query,
        $self->_read_filters($params),
        $self->_read_fields($params),
        $self->_read_aggregations($params),
        $self->_read_sort($params)
    };
}

my %key2es = (
    all    => 'must',
    either => 'should',
    not    => 'must_not',
);

sub _read_fields {
    my $self   = shift;
    my $params = shift;

    my $fields  = delete $params->{fields};
    my $_source = delete $params->{_source};

    my @ret;

    if ( $fields ) {
        is_arrayref($fields) or
            croak "fields must be an arrayref";
        push @ret => ( fields => $fields );
    }

    if ( $_source ) {
        is_arrayref($_source) or !is_ref($_source) or
            croak "_source must be an arrayref or a string";
        push @ret => ( _source => $_source );
    }

    return @ret;
}

sub _read_aggregations {
    my $self   = shift;
    my $params = shift;

    my $aggregations = delete $params->{aggregations};
    is_ref($aggregations) or return ();

    $self->_set_is_agg(1);
    return ( aggregations => $aggregations );
}

sub _read_filters {
    my $self   = shift;
    my $params = shift;

    my $filter = delete $params->{es_filter};
    is_ref($filter) or return ();

    return ( filter => $filter );
}

sub _read_sort {
    my $self   = shift;
    my $params = shift;

    my $sort = delete $params->{sort};
    is_ref($sort) or return ();

    return ( sort => $sort );
}

sub _build_query_rec {
    my $args  = shift;
    is_hashref($args) or croak 'query args must be a hash';

    my %query = ();
    my $basic_element = 1;

  KEY: for my $k ( qw/ all either not / ) {
        my $v = delete $args->{$k} || next KEY;
        is_hashref($v)  and $v = [ $v ];
        is_arrayref($v) or croak "invalid value for key $k";

        undef $basic_element;

        $query{'bool'}{ $key2es{$k} } =
            [ map +( _build_query_rec($_) ), @$v ];

        $k eq 'either' and $query{'bool'}{'minimum_should_match'} = 1;
    }

    $basic_element and %query = %{ _build_query_element($args) };

    return \%query;
}

sub _build_query_element {
    my $args = shift;

    scalar keys %{$args} == 1
        or croak 'Wrong number of keys in query element';

    my ($key) = keys %{$args};
    my $val = $args->{$key};

    !is_ref($val) and $val =~ /[\w\*]/
        or croak 'Wrong type of query arguments';

    my $wildcard = $val =~ /[*?]/;
    my $qtype    = $wildcard ? 'wildcard' : 'term';

    return +{ $qtype => $args };
}


1;

__END__

=head1 ATTRIBUTES

=head2 domain

    $mcpan = MetaCPAN::Client->new( domain => 'localhost' );

What domain to use for all requests.

Default: B<https://fastapi.metacpan.org>.

=head2 base_url

    my $mcpan = MetaCPAN::Client->new(
        base_url => 'https://localhost:9999/v2',
    );

Instead of overriding the C<base_url>, you should override the C<domain>.
The C<base_url> will be set appropriately automatically.

Default: I<https://$domain>.

=head2 debug

debug-mode for more detailed error messages.

=head1 METHODS

=head2 BUILDARGS

=head2 fetch

    my $result = $mcpan->fetch('/release/Moose');

    # with parameters
    my $more = $mcpan->fetch(
        '/release/Moose',
        { param => 'value' },
    );

Fetches a path from MetaCPAN (post or get), and returns the decoded result.

=head2 ssearch

Calls an Elasticsearch query and returns an L<MetaCPAN::Client::Scroll>
scroller object.
