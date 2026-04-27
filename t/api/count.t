#!perl

use strict;
use warnings;
use Test::More tests => 3;

use lib '.';
use t::lib::Functions;

my $mc = mcpan(); # test 1

my $count_rel = $mc->count( 'release' );
cmp_ok( $count_rel, '>=', 0, 'count of releases > 0' );

my $count_auth = $mc->count( 'author' );
cmp_ok( $count_auth, '>=', 0, 'count of authors > 0' );

done_testing;
