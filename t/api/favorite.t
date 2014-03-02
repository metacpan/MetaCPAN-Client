#!perl

use strict;
use warnings;
use Test::More tests => 2 + 4 * 2;
use Test::Fatal;

use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'favorite' );

foreach my $option ( { author => 'XSAWYERX' }, { dist => 'MetaCPAN-API' } ) {
    my $rs = $mc->favorite($option);
    isa_ok( $rs, 'MetaCPAN::API::ResultSet' );
    can_ok( $rs, qw<type scroller> );
    is( $rs->type, 'favorite', 'Correct resultset type' );
    isa_ok( $rs->scroller, 'Elasticsearch::Scroll' );
}

