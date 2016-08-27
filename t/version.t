#!perl

use strict;
use warnings;

use Test::More tests => 6;
use MetaCPAN::Client;

subtest 'default is v0' => sub {
    my $mcpan= MetaCPAN::Client->new();
    isa_ok( $mcpan, 'MetaCPAN::Client' );
    is( $mcpan->request->version, 'v0', 'default version is v0' );
};

subtest 'explicit v0' => sub {
    my $mcpan= MetaCPAN::Client->new( version => 'v0' );
    isa_ok( $mcpan, 'MetaCPAN::Client' );
    is( $mcpan->request->version, 'v0', 'given version is v0' );
};

subtest 'implicit v0' => sub {
    my $mcpan= MetaCPAN::Client->new( version => '0' );
    isa_ok( $mcpan, 'MetaCPAN::Client' );
    is( $mcpan->request->version, 'v0', 'given version is 0 -> v0' );
};

subtest 'explicit v1' => sub {
    my $mcpan= MetaCPAN::Client->new( version => 'v1' );
    isa_ok( $mcpan, 'MetaCPAN::Client' );
    is( $mcpan->request->version, 'v1', 'given version is v1' );
};

subtest 'implicit v1' => sub {
    my $mcpan= MetaCPAN::Client->new( version => '1' );
    isa_ok( $mcpan, 'MetaCPAN::Client' );
    is( $mcpan->request->version, 'v1', 'given version is 1 -> v1' );
};

subtest 'invalid version' => sub {

    my $mcpan;
    eval {
        $mcpan= MetaCPAN::Client->new( version => 'foo' );
        1;
    } or do {
        my $err = $@;
        like( $err, qr/invalid version/, 'checked invalid version' );
    };

    isnt( ref $mcpan, 'MetaCPAN::Client',  'object was not created with invalid version' );

};

done_testing;
