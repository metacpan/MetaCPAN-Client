#!perl

use strict;
use warnings;
use Test::More tests => 2 + 4 * 2;
use Test::Fatal;

use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'favorite' );

foreach my $option ( { author => 'XSAWYERX' }, { dist => 'MetaCPAN-Client' } ) {
    my $rs = $mc->favorite($option);
    isa_ok( $rs, 'MetaCPAN::Client::ResultSet' );
    can_ok( $rs, qw<type scroller> );
    is( $rs->type, 'favorite', 'Correct resultset type' );
    isa_ok( $rs->scroller, 'Elasticsearch::Scroll' );
}

