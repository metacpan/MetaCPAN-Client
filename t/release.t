#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 3;
use MetaCPAN::API;

my $mcpan = MetaCPAN::API->new;

TODO: {
    local $TODO = 'Awaiting implementation';

    can_ok( $mcpan, 'release' );
    my $result = $mcpan->release( distribution => 'Moose' );
    ok( $result, 'Got result' );

    $result = $mcpan->release(
        author => 'DOY', release => 'Moose-2.0001'
    );

    ok( $result, 'Got result' );
};

