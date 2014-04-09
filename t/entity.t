#!perl

use strict;
use warnings;

use Test::More tests => 6;
use Test::Fatal;

{
    package MetaCPAN::Client::FakeEntityEmpty;
    use Moo;
    with 'MetaCPAN::Client::Role::Entity';
}

{
    package MetaCPAN::Client::FakeEntityFull;
    use Moo;
    with 'MetaCPAN::Client::Role::Entity';

    sub _known_fields { ['this'] }
}

ok(
    exception { MetaCPAN::Client::FakeEntityEmpty->new },
    'data is missing, causing exception',
);

is(
    exception { MetaCPAN::Client::FakeEntityEmpty->new( data => {} ) },
    undef,
    'data available, not causing exception',
);

like(
    exception { MetaCPAN::Client::FakeEntityEmpty->new_from_request( {} ) },
    qr/.*Can't locate.*_known_fields/,
    'Subroutine _known_fields missing',
);

is(
    exception { MetaCPAN::Client::FakeEntityFull->new( data => {} ) },
    undef,
    'data available, not causing exception',
);

my $fe = MetaCPAN::Client::FakeEntityFull->new_from_request(
    { that => 'this', this => 'that' }
);

isa_ok( $fe, 'MetaCPAN::Client::FakeEntityFull' );
is_deeply( $fe->{'data'}, { this => 'that' }, 'Correct data' );

