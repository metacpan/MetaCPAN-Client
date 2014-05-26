#!perl

use strict;
use warnings;

use Test::More tests => 3;
use Test::Fatal;
use MetaCPAN::Client::ResultSet;

{
    package MetaCPAN::Client::Test::ScrollerZ;
    use base 'Search::Elasticsearch::Scroll'; # < 5.10 FTW (except, no)
    sub total {0}
}

like(
    exception {
        MetaCPAN::Client::ResultSet->new(
            type     => 'failZZ',
            scroller => bless {}, 'MetaCPAN::Client::Test::ScrollerZ',
        )
    },
    qr/Invalid type/,
    'Invalid type fail',
);

my $rs = MetaCPAN::Client::ResultSet->new(
    type     => 'author',
    scroller => bless {}, 'Search::Elasticsearch::Scroll',
);

isa_ok( $rs, 'MetaCPAN::Client::ResultSet' );
can_ok( $rs, qw<next facets total type scroller> );

