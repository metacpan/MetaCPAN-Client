#!perl

use strict;
use warnings;
use Test::More tests => 7;
use Test::Fatal;

use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'rating' );

my $rs = $mc->rating( { distribution => 'Moose' } );
isa_ok( $rs, 'MetaCPAN::Client::ResultSet' );
can_ok( $rs, 'next' );

my $rating = $rs->next;
isa_ok( $rating, 'MetaCPAN::Client::Rating' );
can_ok( $rating, 'distribution' );
is( $rating->distribution, 'Moose', 'Correct distribution' );

__END__
can_ok( $rs, 'name' );
is( $rating->name, 'MetaCPAN-Client', 'Correct distribution' );

