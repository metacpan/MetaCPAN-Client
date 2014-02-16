package MetaCPAN::API::Request;

use Moo;
use Carp;
use JSON;
use Elasticsearch;
use Elasticsearch::Scroll;
use Try::Tiny;
use HTTP::Tiny;
use URI::Escape 'uri_escape';
use List::Util 'first';


has base_url => (
    is      => 'ro',
    default => sub { 'http://api.metacpan.org/v0' },
);

has ua => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_ua',
);

has ua_args => (
    is      => 'ro',
    default => sub {
        return [ agent => 'MetaCPAN::API/'.($MetaCPAN::API::VERSION||'xx') ];
    },
);


sub _build_ua {
    my $self = shift;
    return HTTP::Tiny->new( @{ $self->ua_args } );
}

sub fetch {
    my $self    = shift;
    my $url     = shift or croak "fetch must be called with a URL param";
    my $params  = shift || {};
    my $req_url = sprintf '%s/%s', $self->base_url, $url;
    my $ua      = $self->ua;

    my $result;
    if ( %{$params} ) {
        $result = $ua->post( $req_url, {
            content => to_json $params
        } );
    } else {
        $result = $ua->get($req_url);
    }

    return $self->_decode_result( $result, $req_url );
}

sub ssearch {
    my $self   = shift;
    my $type   = shift;
    my $args   = shift;
    my $params = shift;

    my $es = Elasticsearch->new(
        nodes    => 'api.metacpan.org',
        cxn_pool => 'Static::NoPing',
    );

    my $scroller = Elasticsearch::Scroll->new(
        body        => $params,
        es          => $es,
        type        => $type,
        size        => 1000,
        index       => 'v0',
        scroll      => '5m',
        search_type => 'scan',
    );

    return $scroller;
}

sub post {
    my $self  = shift;
    my $url   = shift or croak 'First argument of URL must be provided';
    my $query = shift;

    ref $query eq 'HASH'
        or croak 'Second argument of query hashref must be provided';

    my $query_json = to_json( $query, { canonical => 1 } );

    my $result = $self->ua->request(
        'POST',
        sprintf( '%s/%s', $self->base_url, $url ),
        {
            headers => { 'Content-Type' => 'application/json' },
            content => $query_json,
        }
    );

    return $self->_decode_result( $result, $url, $query_json );
}

sub _decode_result {
    my $self     = shift;
    my $result   = shift;
    my $url      = shift or croak 'Second argument of a URL must be provided';

    ref $result eq 'HASH'
        or croak 'First argument must be hashref';

    my $success = $result->{'success'};
    defined $success or croak 'Missing success in return value';
    $success or croak "Failed to fetch '$url': " . $result->{'reason'};

    my $content = $result->{'content'} or
        croak 'Missing content in return value';

    my $decoded_result;
    try   { $decoded_result = decode_json $content }
    catch { croak "Couldn't decode '$content': $_" };

    return $decoded_result;
}

sub _build_query {
    my $self = shift;
    my $args = shift;

    my $key = _read_query_key($args);

    my %query;

    if ( $key eq 'all' or $key eq 'either' ) {
        my @elements = map { _build_query_element($_) } @{ $args->{$key} };
        $query{bool} = $key eq 'all'
            ? { must => \@elements }
            : { should => \@elements, "minimum_should_match" => 1 };

    } else {
        %query = %{ _build_query_element( $args ) };
    }

    return \%query;
}

sub _read_query_key {
    my $args = shift;

    # search queries take a 1 key/value element hash
    scalar keys %{$args} == 1
        or croak 'Wrong number of query arguments';

    my ($key) = keys %{$args};

    # all/either queries take an array as params
    if ( $key eq 'all' or $key eq 'either' ) {
        ref($args->{$key}) eq 'ARRAY'
            or croak 'Wrong type of query arguments for all/either';
    }

    return $key;
}

sub _build_query_element {
    my $args = shift;

    scalar keys %{$args} == 1
        or croak 'Wrong number of keys in query element';

    my ($key) = keys %{$args};

    !ref($args->{$key}) and $args->{$key} =~ /\w/
        or croak 'Wrong type of query arguments';

    my $wildcard = $args->{$key} =~ /[*?]/;
    my $qtype    = $wildcard ? 'wildcard' : 'term';

    return +{ $qtype => $args };
}


1;

__END__

=head1 ATTRIBUTES

=head2 base_url

    my $mcpan = MetaCPAN::API->new(
        base_url => 'http://localhost:9999',
    );

This attribute is used for REST requests. You should set it to where the
MetaCPAN is accessible. By default it's already set correctly, but if you're
running a local instance of MetaCPAN, or use a local mirror, or tunnel it
through a local port, or any of those stuff, you would want to change this.

Default: I<http://api.metacpan.org/v0>.

This attribute is read-only (immutable), meaning that once it's set on
initialize (via C<new()>), you cannot change it. If you need to, create a
new instance of MetaCPAN::API. Why is it immutable? Because it's better.

=head2 ua

This attribute is used to contain the user agent used for running the REST
request to the server. It is specifically set to L<HTTP::Tiny>, so if you
want to set it manually, make sure it's of HTTP::Tiny.

HTTP::Tiny is used as part of the philosophy of keeping it tiny.

This attribute is read-only (immutable), meaning that once it's set on
initialize (via C<new()>), you cannot change it. If you need to, create a
new instance of MetaCPAN::API. Why is it immutable? Because it's better.

=head2 ua_args

    my $mcpan = MetaCPAN::API->new(
        ua_args => [ agent => 'MyAgent' ],
    );

The arguments that will be given to the L<HTTP::Tiny> user agent.

This attribute is read-only (immutable), meaning that once it's set on
initialize (via C<new()>), you cannot change it. If you need to, create a
new instance of MetaCPAN::API. Why is it immutable? Because it's better.

The default is a user agent string: B<MetaCPAN::API/$version>.

=head1 METHODS

=head2 fetch

    my $result = $mcpan->fetch('/release/distribution/Moose');

    # with parameters
    my $more = $mcpan->fetch(
        '/release/distribution/Moose',
        param => 'value',
    );

This is a helper method for API implementations. It fetches a path from
MetaCPAN, decodes the JSON from the content variable and returns it.

You don't really need to use it, but you can in case you want to write your
own extension implementation to MetaCPAN::API.

It accepts an additional hash as C<GET> parameters.

=head2 post

    # /release&content={"query":{"match_all":{}},"filter":{"prefix":{"archive":"Cache-Cache-1.06"}}}
    my $result = $mcpan->post(
        'release',
        {
            query  => { match_all => {} },
            filter => { prefix => { archive => 'Cache-Cache-1.06' } },
        },
    );

The POST equivalent of the C<fetch()> method. It gets the path and JSON request.
