#!perl

use strict;
use warnings;

use Test::More tests => 6;
use Ref::Util qw< is_hashref >;
use HTTP::Tiny;
use MetaCPAN::Client::Scroll;
use MetaCPAN::Client::Release;

my $scroller = MetaCPAN::Client::Scroll->new(
   ua       => HTTP::Tiny->new,
   base_url => 'https://fastapi.metacpan.org/v1/',
   type     => 'release',
   body     => { query => { term => { distribution => 'MetaCPAN-Client' } } },
   size     => 50,
);
isa_ok( $scroller, 'MetaCPAN::Client::Scroll' );

can_ok(
    $scroller,
    qw< aggregations base_url body _buffer
        BUILDARGS DEMOLISH _fetch_next _id
        next size time total type ua >
);

my $next = $scroller->next;
ok( is_hashref($next), 'next doc returns a hashref' );

my $rel = MetaCPAN::Client::Release->new_from_request( $next->{'_source'} );
isa_ok( $rel, 'MetaCPAN::Client::Release' );
is( $rel->distribution, 'MetaCPAN-Client', 'release object can be created from next doc' );

my $got = 1;  # we call ->next once above
while ( my $n = $scroller->next ) { $got++ }
is( $got, $scroller->total, 'can read all matching docs' );

1;
