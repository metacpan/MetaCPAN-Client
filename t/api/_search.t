#!perl

use strict;
use warnings;
use Test::More tests => 19;
use Test::Fatal;

use lib '.';
use t::lib::Functions;

{
    no warnings qw<redefine once>;

    my $count = 0;
    *MetaCPAN::Client::ssearch = sub {
        my ( $self, $index, $args, $params ) = @_;
        ::isa_ok( $self, 'MetaCPAN::Client' );
        ::is( $index, 'author', 'Correct index' );
        ::is_deeply( $args, { hello => 'world' }, 'Correct args' );

        if ( $count++ == 0 ) {
            ::is_deeply( $params, {}, 'Correct empty params' );
        } else {
            ::is_deeply( $params, { a => 'b' }, 'Correct params' );
        }

        return { a => 'ok' };
    };

    *MetaCPAN::Client::ResultSet::new = sub {
        my ( $self, %args ) = @_;
        ::isa_ok( $self, 'MetaCPAN::Client::ResultSet' );
        ::is_deeply(
            \%args,
            {
                scroller => { a => 'ok' },
                index    => 'author',
            },
            'Correct args to ::ResultSet',
        );

        return 'yoyo';
    };
}

my $mc = mcpan();
can_ok( $mc, '_search' );

like(
    exception { $mc->_search('author') },
    qr/^_search takes a hash ref as query/,
    'Failed with no query',
);

like(
    exception { $mc->_search( 'author', { hello => 'world' }, 'fail' ) },
    qr/^_search takes a hash ref as query parameters/,
    'Failed with no query parameters',
);

like(
    exception { $mc->_search( 'authorz', { hello => 'world' }, { a => 'b' } ) },
    qr/^search index is not supported/,
    'Unsupported search index',
);

is(
    $mc->_search( 'author', { hello => 'world' } ),
    'yoyo',
    'Works with no query parameters',
);

is(
    $mc->_search( 'author', { hello => 'world' }, { a => 'b' } ),
    'yoyo',
    'Correct _search call',
);
