#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 6;
use Test::Fatal;
use MetaCPAN::API;

my $mcpan = MetaCPAN::API->new;

TODO: {
    local $TODO = 'Awaiting implementation';

    can_ok( $mcpan, 'release' );
    my $errmsg = qr/^Either provide 'distribution' or 'author and 'release'/;

    # missing input
    like(
        exception { $mcpan->release },
        $errmsg,
        'Missing any information',
    );

    # incorrect input
    like(
        exception { $mcpan->release( ding => 'dong' ) },
        $errmsg,
        'Incorrect input',
    );

    # coupled input
    like(
        exception { $mcpan->release( distribution => 'it', author => 'at' ) },
        $errmsg,
        'Coupled input',
    );

    my $result = $mcpan->release( distribution => 'Moose' );
    ok( $result, 'Got result' );

    $result = $mcpan->release(
        author => 'DOY', release => 'Moose-2.0001'
    );

    ok( $result, 'Got result' );
};

