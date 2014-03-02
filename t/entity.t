#!perl

use strict;
use warnings;

use Test::More tests => 6;
use Test::Fatal;

package MetaCPAN::API::FakeEntityEmpty {
    use Moo;
    with 'MetaCPAN::API::Role::Entity';
}

package MetaCPAN::API::FakeEntityFull {
    use Moo;
    with 'MetaCPAN::API::Role::Entity';

    sub _known_fields { ['this'] }
}

ok(
    exception { MetaCPAN::API::FakeEntityEmpty->new },
    'data is missing, causing exception',
);

is(
    exception { MetaCPAN::API::FakeEntityEmpty->new( data => {} ) },
    undef,
    'data available, not causing exception',
);

like(
    exception { MetaCPAN::API::FakeEntityEmpty->new_from_request( {} ) },
    qr/.*Can't locate.*_known_fields/,
    'Subroutine _known_fields missing',
);

is(
    exception { MetaCPAN::API::FakeEntityFull->new( data => {} ) },
    undef,
    'data available, not causing exception',
);

my $fe = MetaCPAN::API::FakeEntityFull->new_from_request(
    { that => 'this', this => 'that' }
);

isa_ok( $fe, 'MetaCPAN::API::FakeEntityFull' );
is_deeply( $fe->{'data'}, { this => 'that' }, 'Correct data' );

