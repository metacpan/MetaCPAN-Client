#!perl

use strict;
use warnings;

use Test::More tests => 7;
use Test::Fatal;
use Test::TinyMocker;
use t::lib::Functions;

my $mcpan = mcpan();
isa_ok( $mcpan, 'MetaCPAN::API' );

my $url  = 'release/distribution/hello';
my $flag = 0;

mock 'HTTP::Tiny'
    => method 'get'
    => should {
        my $self = shift;
        isa_ok( $self, 'HTTP::Tiny' );
        is( $_[0], $mcpan->base_url . "/$url", 'Correct URL' );

        $flag++ == 0 and return {
            success => 1,
            content => '{"test":"test"}',
        };

        $flag++ == 2 and return {
            success => 1,
        };

        return {
            success => 1,
            content => 'string',
        };
    };

my $result = $mcpan->fetch($url);
is_deeply( $result, { test => 'test' }, 'Correct result' );

mock 'HTTP::Tiny'
    => method 'get'
    => should {
        my $self = shift;
        isa_ok( $self, 'HTTP::Tiny' );
        is( $_[0], $mcpan->base_url . '/?test=it', 'Correct URL' );

        return {
            success => 1,
            content => '{"content":"ok"}',
        };
    };

is_deeply(
    $mcpan->fetch( '', test => 'it' ),
    { content => 'ok' },
    'Sending params work right',
);

