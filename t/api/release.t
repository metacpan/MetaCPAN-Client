#!perl

use strict;
use warnings;
use Test::More tests => 5;
use Test::Fatal;

use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'release' );

my $release = $mc->release('MetaCPAN-API');
isa_ok( $release, 'MetaCPAN::Client::Release' );
can_ok( $release, qw<distribution> );
is( $release->distribution, 'MetaCPAN-API', 'Correct distribution' );

