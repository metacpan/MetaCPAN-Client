#!perl

use strict;
use warnings;

use Test::More tests => 7;
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

{
    package MetaCPAN::Client::Test::FilledScroller;
    use base 'MetaCPAN::Client::Scroll';
    my @_data = (
        { _source => { pauseid => 'OALDERS' } },
        { _source => { pauseid => 'BFOY'   } },
        { _source => { pauseid => 'RJBS'   } },
    );
    sub total { 3 }
    sub next  { return shift @_data }
}

my $scroller_rs = MetaCPAN::Client::ResultSet->new(
    index    => 'author',
    scroller => bless {}, 'MetaCPAN::Client::Test::FilledScroller',
);

my $items = $scroller_rs->items;
ok( defined $items,      'items is defined for scroller-based ResultSet' );
isa_ok( $items, 'ARRAY', 'items is an arrayref' );
is( scalar @$items, 3,   'items contains all scroller results' );
is_deeply(
    [ map { $_->{_source}{pauseid} } @$items ],
    [qw< OALDERS BFOY RJBS >],
    'items contains correct data from scroller',
);
