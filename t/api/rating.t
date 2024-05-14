#!perl

use strict;
use warnings;
use Test::More tests => 4;
use Test::Fatal;

use lib '.';
use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'rating' );

my $rs = $mc->rating( { distribution => 'Moose' } );
isa_ok( $rs, 'MetaCPAN::Client::ResultSet' );
can_ok( $rs, 'next' );
