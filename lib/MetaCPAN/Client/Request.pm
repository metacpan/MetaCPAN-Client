use strict;
use warnings;
package MetaCPAN::Client::Request;
# ABSTRACT: Object used for making requests to MetaCPAN

use Moo;
use Carp;
use JSON::MaybeXS qw<decode_json encode_json>;
use Search::Elasticsearch;
use Try::Tiny;
use HTTP::Tiny;

has domain => (
    is      => 'ro',
    default => sub {
        return ( $ENV{METACPAN_DOMAIN} ? $ENV{METACPAN_DOMAIN} : 'api.metacpan.org' );
    },
);

has version => (
    is      => 'ro',
    default => sub { 'v0' },
);

has base_url => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return sprintf('http://%s/%s', $self->domain, $self->version);
    },
);

has _user_ua => (
    init_arg  => 'ua',
    is        => 'ro',
    predicate => '_has_user_ua',
);

has ua => (
    init_arg => undef,
    is       => 'ro',
    lazy     => 1,
    builder  => '_build_ua',
);

has ua_args => (
    is      => 'ro',
    default => sub {
        [ agent => 'MetaCPAN::Client/'.($MetaCPAN::Client::VERSION||'xx') ]
    },
);

sub _build_ua {
    my $self = shift;
    # This level of indirection is so that if a user has not specified a custom UA
    # MetaCPAN::Client and ElasticSearch will have their own UA's
    #
    # But if the user **has** specified a custom UA, that UA is used for both.
    if ( $self->_has_user_ua ) {
      return $self->_user_ua;
    }
    return HTTP::Tiny->new( @{ $self->ua_args } );
}

sub fetch {
    my $self    = shift;
    my $url     = shift or croak 'fetch must be called with a URL parameter';
    my $params  = shift || {};
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

    my $es = Search::Elasticsearch->new(
        nodes            => $self->domain,
        cxn_pool         => 'Static::NoPing',
        send_get_body_as => 'POST',
        ( $self->_has_user_ua ? ( handle => $self->_user_ua ) : () )
    );

    my $body = $self->_build_body($args, $params);

    my $scroller = $es->scroll_helper(
        search_type => 'scan',
        scroll      => '5m',
        index       => $self->version,
        type        => $type,
        size        => 1000,
        body        => $body,
        %{ $params },
    );

    return $scroller;
}

sub _decode_result {
    my $self   = shift;
    my $result = shift;
    my $url    = shift or croak 'Second argument of a URL must be provided';

    ref $result eq 'HASH'
        or croak 'First argument must be hashref';

    my $success = $result->{'success'};

    defined $success
        or croak 'Missing success in return value';

    $success
        or croak "Failed to fetch '$url': " . $result->{'reason'};

    my $content = $result->{'content'}
        or croak 'Missing content in return value';

    $url =~ m|/pod/| and return $content;

    my $decoded_result;
    try   { $decoded_result = decode_json $content }
    catch { croak "Couldn't decode '$content': $_" };

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
        _read_filters($params),
        _read_facets($params)
    };
}

my %key2es = (
    all    => 'must',
    either => 'should',
    not    => 'must_not',
);

sub _read_facets {
    my $params = shift;

    my $facets = delete $params->{facets};
    ref($facets) or return ();

    return ( facets => $facets );
}

sub _read_filters {
    my $params = shift;

    my $filter = delete $params->{es_filter};
    ref($filter) or return ();

    return ( filter => $filter );
}

sub _build_query_rec {
    my $args  = shift;
    ref $args eq 'HASH' or croak 'query args must be a hash';

    my %query = ();
    my $basic_element = 1;

  KEY: for my $k ( qw/ all either not / ) {
        my $v = delete $args->{$k} || next KEY;
        ref $v eq 'HASH'  and $v = [ $v ];
        ref $v eq 'ARRAY' or croak "invalid value for key $k";

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

    !ref($val) and $val =~ /[\w\*]/
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

Default: B<api.metacpan.org>.

=head2 version

    $mcpan = MetaCPAN::Client->new( version => 'v0' );

What version of MetaCPAN should be used?

Default: B<v0>.

=head2 base_url

    my $mcpan = MetaCPAN::Client->new(
        base_url => 'http://localhost:9999/v2',
    );

Instead of overriding the C<base_url>, you should override the C<domain> and
C<version>. The C<base_url> will be set appropriately automatically.

Default: I<http://$domain/$version>.

=head2 ua

    my $mcpan = MetaCPAN::Client->new( ua => HTTP::Tiny->new(...) );

The user agent object for running requests.

It must provide an interface that matches L<HTTP::Tiny>. Explicitly:

=over 4

=item * Implement post()

Method C<post> must be available that accepts a request URL and a hashref of
options.

=item * Implement get()

Method C<get> must be available that accepts a request URL.

=item * Return result hashref

Must return a result hashref which has key C<success> and key C<content>.

=back

Default: L<HTTP::Tiny>,

=head2 ua_args

    my $mcpan = MetaCPAN::Client->new(
        ua_args => [ agent => 'MyAgent' ],
    );

Arguments sent to the user agent.

Default: user agent string: B<MetaCPAN::Client/$version>.

=head1 METHODS

=head2 fetch

    my $result = $mcpan->fetch('/release/Moose');

    # with parameters
    my $more = $mcpan->fetch(
        '/release/Moose',
        { param => 'value' },
    );

Fetches a path from MetaCPAN (post or get), and returns the decoded result.

=head2 ssearch

Calls an Elastic Search query (using L<Search::Elasticsearch> and returns an
L<Search::Elasticsearch::Scroll> scroller object.
