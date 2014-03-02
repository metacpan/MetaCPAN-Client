#!perl

use strict;
use warnings;

use Test::More tests => 7;
use MetaCPAN::API::Request;

my $req = MetaCPAN::API::Request->new( domain => 'mydomain', version => 'z' );
isa_ok( $req, 'MetaCPAN::API::Request' );
can_ok(
    $req,
    qw<domain version base_url ua ua_args
    fetch ssearch _decode_result
    _build_body _read_query_key _build_query_element>,
);

is( $req->domain, 'mydomain', 'Correct domain' );
is( $req->version, 'z', 'Correct version' );
is( $req->base_url, 'http://mydomain/z', 'Correct base_url' );
isa_ok( $req->ua, 'HTTP::Tiny' );

my $ver = $MetaCPAN::API::VERSION || 'xx';
is_deeply(
    $req->ua_args,
    [ agent => "MetaCPAN::API/$ver" ],
    'Correct UA args',
);

