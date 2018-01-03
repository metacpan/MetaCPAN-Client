#!perl

use strict;
use warnings;

use Test::More tests => 5;
use Test::Fatal qw( exception );
use MetaCPAN::Client;
use MetaCPAN::Client::ResultSet;

{

    package Test::Result;
    use Moo;
    with 'MetaCPAN::Client::Role::Entity';

    sub new_from_request {
        my ( $class, $request, $client ) = @_;
        return $class->new( ( defined $client ? ( client => $client ) : () ),
            data => $request, );
    }

    sub _known_fields { +{} }
}

my $client = MetaCPAN::Client->new();
my $scroll = $client->ssearch( 'author', { pauseid => 'KENTNL' } );

my $rs = MetaCPAN::Client::ResultSet->new(
    class    => 'Test::Result',
    scroller => $scroll,
);

isa_ok( $rs, 'MetaCPAN::Client::ResultSet' );
can_ok( $rs, qw<next aggregations total type scroller> );
my $item;
is( exception { $item = $rs->next; 1 }, undef, "no fail on next" );
isa_ok( $item, 'Test::Result' );

my $ex;
isnt( $ex = exception { MetaCPAN::Client::ResultSet->new( scroller => $scroll ) },
      undef, 'Must fail is neither class or type are passed' );
