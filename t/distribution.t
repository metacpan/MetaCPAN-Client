#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 7;
use Test::Fatal;
use t::lib::Functions;

my $mcpan = mcpan();

isa_ok( $mcpan, 'MetaCPAN::API' );
can_ok( $mcpan, 'distribution'  );
my $errmsg = qr/^Either provide a distribution or 'search'/;

# missing input
like(
    exception { $mcpan->distribution },
    $errmsg,
    'Missing any information',
);

# incorrect input
like(
    exception { $mcpan->distribution( ding => 'dong' ) },
    $errmsg,
    'Incorrect input',
);

my $result = $mcpan->distribution('DBIx-Class');
ok( $result, 'Got result' );

$result = $mcpan->distribution( distribution => 'DBIx-Class' );
ok( $result, 'Got result' );

$result = $mcpan->distribution(
    search => {
        filter => { exists => { field => 'bugs.source' } },
        fields => ['name', 'bugs.source'],
        size   => 5,
    },
);
ok( $result, 'Got result' );
