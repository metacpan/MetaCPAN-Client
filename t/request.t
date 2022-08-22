#!perl

use strict;
use warnings;

use Test::More tests => 7;
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
is_deeply(
    $req->ua_args,
    [ agent => "MetaCPAN::Client/$ver",
      verify_SSL => 1 ],
    'Correct UA args',
);

my $client = MetaCPAN::Client->new( domain => 'foo' );
is ( $client->request->domain, 'foo', 'domain set in request' );
