#!perl

use strict;
use warnings;

use Test::More tests => 3;
use Test::TinyMocker;
use MetaCPAN::API;

my $mcpan = MetaCPAN::API->new;
isa_ok( $mcpan, 'MetaCPAN::API' );

mock 'HTTP::Tiny'
    => methods 'get'
    => should {
        my $self = shift;
        isa_ok( $self, 'HTTP::Tiny' );
        is( $_[0], '/release/distribution/hello', 'Correct URL' );
        return '{"content":"test"}';
    };

my $result = $mcpan->fetch('/release/distribution/hello');
is( $result, 'test', 'Correct result' );

