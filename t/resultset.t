#!perl

use strict;
use warnings;

use Test::More tests => 3;
use Test::Fatal;
use MetaCPAN::API::ResultSet;

like(
    exception {
        MetaCPAN::API::ResultSet->new(
            type     => 'failZZ',
            scroller => bless {}, 'Elasticsearch::Scroll',
        )
    },
    qr/Invalid type/,
    'Invalid type fail',
);

my $rs = MetaCPAN::API::ResultSet->new(
    type     => 'author',
    scroller => bless {}, 'Elasticsearch::Scroll',
);

isa_ok( $rs, 'MetaCPAN::API::ResultSet' );
can_ok( $rs, qw<next facets total type scroller> );

