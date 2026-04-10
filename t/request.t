#!perl

use strict;
use warnings;

use Test::More tests => 12;
use MetaCPAN::Client;
use MetaCPAN::Client::Request;

my $req = MetaCPAN::Client::Request->new( domain => 'https://mydomain' );
isa_ok( $req, 'MetaCPAN::Client::Request' );
can_ok(
    $req,
    qw<domain base_url ua ua_args
    fetch ssearch _decode_result
    _build_query_rec _build_query_element>,
);

is( $req->domain, 'https://mydomain', 'Correct domain' );
is( $req->base_url, 'https://mydomain', 'Correct base_url' );
isa_ok( $req->ua, 'HTTP::Tiny' );

my $ver = $MetaCPAN::Client::VERSION || 'xx';
is_deeply( $req->ua_args, [], 'ua_args defaults empty' );
is( $req->ua->{agent}, "MetaCPAN::Client/$ver", 'default user_agent comes from builder' );

my $client = MetaCPAN::Client->new( domain => 'foo' );
is ( $client->request->domain, 'foo', 'domain set in request' );

my $tagged_req = MetaCPAN::Client::Request->new(
    domain     => 'https://mydomain',
    user_agent => ' partner-app/1.2 ',
);
like( $tagged_req->ua->{agent}, qr/^\spartner-app\/1\.2\s+HTTP-Tiny\/[\d._]+$/, 'user_agent sets the HTTP::Tiny agent string' );

my $tagged_client = MetaCPAN::Client->new( domain => 'foo', user_agent => 'partner-app/1.2' );
is( $tagged_client->request->ua->{agent}, 'partner-app/1.2', 'client forwards user_agent to request construction' );

my $explicit_req = MetaCPAN::Client::Request->new(
    domain     => 'https://mydomain',
    user_agent => 'partner-app/1.2',
    ua_args    => [ agent => 'Explicit/9.9', verify_SSL => 1 ],
);
is_deeply( $explicit_req->ua_args, [ agent => 'Explicit/9.9', verify_SSL => 1 ], 'explicit ua_args are preserved' );
is( $explicit_req->ua->{agent}, 'Explicit/9.9', 'explicit ua_args still take precedence over user_agent' );
