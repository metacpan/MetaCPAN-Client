#!perl

use strict;
use warnings;
use Test::More tests => 13;
use Test::Fatal;

use t::lib::Functions;

{
    no warnings qw<redefine once>;

    *MetaCPAN::Client::Author::new_from_request = sub {
        my ( $self, $res ) = @_;
        ::isa_ok( $self, 'MetaCPAN::Client::Author' );
        ::is_deeply( $res, { hello => 'world' }, 'Correct response' );

        return 'ok';
    };

    my $count = 0;
    *MetaCPAN::Client::fetch = sub {
        my ( $self, $path ) = @_;
        ::isa_ok( $self, 'MetaCPAN::Client' );
        ::is( $path, 'author/myarg', 'Correct path' );

        $count++ == 0
            and return;

        return { hello => 'world' };
    };
}

my $mc = mcpan();
can_ok( $mc, '_get' );

like(
    exception { $mc->_get() },
    qr/^_get takes type and search string as parameters/,
    'Failed with no params',
);

like(
    exception { $mc->_get('wah') },
    qr/^_get takes type and search string as parameters/,
    'Failed with one param',
);

like(
    exception { $mc->_get('wah', 'wah', 'wah') },
    qr/^_get takes type and search string as parameters/,
    'Failed with more than two params',
);

# call fetch and fail
like(
    exception { $mc->_get( 'author', 'myarg' ) },
    qr/^Failed to fetch Author \(myarg\)/,
    'Correct failure',
);

# call fetch and succeed
my $res = $mc->_get( 'author', 'myarg' );
is( $res, 'ok', 'Correct result' );

