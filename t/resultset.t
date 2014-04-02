#!perl

use strict;
use warnings;

use Test::More tests => 3;
use Test::Fatal;
use MetaCPAN::Client::ResultSet;

like(
    exception {
        MetaCPAN::Client::ResultSet->new(
            type     => 'failZZ',
            scroller => bless {}, 'Elasticsearch::Scroll',
        )
    },
    qr/Invalid type/,
    'Invalid type fail',
);

my $rs = MetaCPAN::Client::ResultSet->new(
    type     => 'author',
    scroller => bless {}, 'Elasticsearch::Scroll',
);

isa_ok( $rs, 'MetaCPAN::Client::ResultSet' );
can_ok( $rs, qw<next facets total type scroller> );

