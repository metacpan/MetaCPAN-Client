#!perl

use strict;
use warnings;
use Test::More tests => 9;
use Test::Fatal;
use Ref::Util qw< is_hashref >;

use lib '.';
use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'distribution' );

my $dist = $mc->distribution('Business-ISBN');
isa_ok( $dist, 'MetaCPAN::Client::Distribution' );
can_ok( $dist, 'name' );
is( $dist->name, 'Business-ISBN', 'Correct distribution' );

can_ok( $dist, 'rt' );
ok( is_hashref( $dist->rt ), 'rt returns a hashref' );

can_ok( $dist, 'github' );
ok( is_hashref( $dist->github ), 'github returns a hashref' );
