#!perl

use strict;
use warnings;

use Test::More tests => 9;
use MetaCPAN::Client;
use MetaCPAN::Client::Request;

my $req = MetaCPAN::Client::Request->new( domain => 'mydomain', version => 'v1' );
isa_ok( $req, 'MetaCPAN::Client::Request' );
can_ok(
    $req,
    qw<domain version base_url ua ua_args
    fetch ssearch _decode_result
    _build_query_rec _build_query_element>,
);

is( $req->domain, 'mydomain', 'Correct domain' );
is( $req->version, 'v1', 'Correct version' );
is( $req->base_url, 'https://mydomain/v1', 'Correct base_url' );
isa_ok( $req->ua, 'HTTP::Tiny' );

my $ver = $MetaCPAN::Client::VERSION || 'xx';
is_deeply(
    $req->ua_args,
    [ agent => "MetaCPAN::Client/$ver" ],
    'Correct UA args',
);

my $client = MetaCPAN::Client->new( domain => 'foo', version => 'v1' );
is ( $client->request->domain, 'foo', 'domain set in request' );
is ( $client->request->version, 'v1', 'version set in request' );
