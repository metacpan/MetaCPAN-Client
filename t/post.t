#!perl

use strict;
use warnings;

use Test::More tests => 13;
use Test::Fatal;
use Test::TinyMocker;
use MetaCPAN::API;

my $mcpan = MetaCPAN::API->new;
isa_ok( $mcpan, 'MetaCPAN::API' );

like(
    exception { $mcpan->post() },
    qr/^First argument of URL must be provided/,
    'Missing arguments',
);

like(
    exception { $mcpan->post( 'release' ) },
    qr/^Second argument of query hashref must be provided/,
    'Missing second argument',
);

like(
    exception { $mcpan->post( 'release', 'bad query' ) },
    qr/^Second argument of query hashref must be provided/,
    'Incorrect second argument',
);

my $url  = 'release/dist';
my $flag = 0;

mock 'HTTP::Tiny'
    => method 'request'
    => should {
        my $self = shift;
        my @args = @_;

        isa_ok( $self, 'HTTP::Tiny' );
        is( $args[0], 'POST', 'Correct request type' );
        is(
            $args[1],
            $mcpan->base_url . "/$url",
            'Correct URL',
        );

        if ( $flag++ == 0 ) {
            is_deeply(
                $args[2],
                {
                    headers => { 'Content-Type' => 'application/json' },
                    content => '{}',
                },
                'Correct request hash without content',
            );
        }

        if ( $flag++ == 2 ) {
            is_deeply(
                $args[2],
                {
                    headers => { 'Content-Type' => 'application/json' },
                    content => '{"useful":"query"}',
                },
                'Correct request hash with content',
            );
        }

        return { success => 1, content => '{}' };
    };

is(
    exception { $mcpan->post( $url, {} ) },
    undef,
    'Correct arguments are successful',
);

is(
    exception { $mcpan->post( $url, { useful => 'query' } ) },
    undef,
    'Correct and useful arguments are successful',
);

