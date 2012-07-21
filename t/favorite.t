#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 5;
use Test::Fatal;
use t::lib::Functions;

my $mcpan = mcpan();

isa_ok( $mcpan, 'MetaCPAN::API' );
can_ok( $mcpan, 'favorite'      );
my $errmsg = qr/^Only 'search' can be used here/;

# missing input
like(
    exception { $mcpan->favorite },
    $errmsg,
    'Missing any information',
);

# incorrect input
like(
    exception { $mcpan->favorite( ding => 'dong' ) },
    $errmsg,
    'Incorrect input',
);

my $result = $mcpan->favorite(
    search => {
        user   => "SZABGAB",
        fields => "distribution",
        size   => 100,
    },
);
ok( $result, 'Got result' );
