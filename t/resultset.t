#!perl

use strict;
use warnings;

use Test::More tests => 3;
use Test::Fatal;
use MetaCPAN::Client::ResultSet;

{
    package MetaCPAN::Client::Test::ScrollerZ;
    use base 'MetaCPAN::Client::Scroll'; # < 5.10 FTW (except, no)
    sub total {0}
}

like(
    exception {
        MetaCPAN::Client::ResultSet->new(
            index    => 'failZZ',
            scroller => bless {}, 'MetaCPAN::Client::Test::ScrollerZ',
        )
    },
    qr/Invalid index/,
    'Invalid index fail',
);

my $rs = MetaCPAN::Client::ResultSet->new(
    index    => 'author',
    scroller => bless {}, 'MetaCPAN::Client::Scroll',
);

isa_ok( $rs, 'MetaCPAN::Client::ResultSet' );
can_ok( $rs, qw<next aggregations total index scroller> );
