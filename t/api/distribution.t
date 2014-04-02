#!perl

use strict;
use warnings;
use Test::More tests => 5;
use Test::Fatal;

use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'distribution' );

my $dist = $mc->distribution('MetaCPAN-API');
isa_ok( $dist, 'MetaCPAN::Client::Distribution' );
can_ok( $dist, 'name' );
is( $dist->name, 'MetaCPAN-API', 'Correct distribution' );

