#!perl

use strict;
use warnings;
use Test::More tests => 10;
use Test::Fatal;

use lib '.';
use t::lib::Functions;

{
    no warnings qw<redefine once>;

    *MetaCPAN::Client::_search = sub {
        my ( $self, $index, $arg, $params ) = @_;
        ::isa_ok( $self, 'MetaCPAN::Client' );
        ::is( $index, 'index', 'Correct index' );
        ::is_deeply( $arg, { hello => 'world' }, 'Correct arg' );
        ::is_deeply( $params, { this => 'that' }, 'Correct params' );
    };

    *MetaCPAN::Client::_get = sub {
        my ( $self, $index, $arg ) = @_;
        ::isa_ok( $self, 'MetaCPAN::Client' );
        ::is( $index, 'indexB', 'Correct index in _get' );
        ::is( $arg, 'argb', 'Correct arg in _get' );
    };
}

my $mc = mcpan();
can_ok( $mc, '_get_or_search' );

# if arg is hash, it should call _search with it
$mc->_get_or_search( 'index', { hello => 'world' }, { this => 'that' } );

# if not, check for arg and call _get
$mc->_get_or_search( 'indexB', 'argb' );

# make arg fail check
like(
    exception { $mc->_get_or_search( 'index', sub {1} ) },
    qr/^index: invalid args/,
    'Failed execution',
);
