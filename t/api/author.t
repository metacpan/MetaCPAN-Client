#!perl

use strict;
use warnings;
use Test::More;
use Test::Fatal;

use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'author' );

my $author = $mc->author('XSAWYERX');
isa_ok( $author, 'MetaCPAN::Client::Author' );
can_ok( $author, 'pauseid' );
is( $author->pauseid, 'XSAWYERX', 'Correct author' );

my $most_daves;
{
    my $daves = $mc->author( {
        either => [
            { name => 'Dave *'  },
            { name => 'David *' },
        ]
    } );

    isa_ok( $daves, 'MetaCPAN::Client::ResultSet' );
    can_ok( $daves, 'total' );
    ok( $daves->total > 200, 'Lots of Daves' );

    $most_daves = $daves->total;
}

{
    my $daves = $mc->author( {
        either => [
            {
                all => [
                    { name  => 'Dave *'     },
                    { email => '*gmail.com' },
                ],
            },

            {
                all => [
                    { name  => 'David *'    },
                    { email => '*gmail.com' },
                ],
            },
        ]
    } );

    isa_ok( $daves, 'MetaCPAN::Client::ResultSet' );
    can_ok( $daves, 'total' );
    ok( $daves->total <= $most_daves, 'Definitely not more Daves' );

    while ( my $dave = $daves->next ) {
        ok(
            grep( +( $_ =~ /gmail\.com$/ ), @{ $dave->email } ),
            'This Dave has a Gmail account',
        );
    }
}

my $johns = $mc->author( {
    all => [
        { name  => 'John *'     },
        { email => '*gmail.com' },
    ]
} );

isa_ok( $johns, 'MetaCPAN::Client::ResultSet' );
can_ok( $johns, 'total' );
ok( $johns->total > 0, 'Got some Johns' );

while ( my $john = $johns->next ) {
    ok(
        grep( +( $_ =~ /gmail\.com$/ ), @{ $john->email } ),
        'This John has a Gmail account',
    );
}

done_testing;

