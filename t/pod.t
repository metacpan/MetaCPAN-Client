#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 6;
use Test::Fatal;
use MetaCPAN::API;

my $mcpan = MetaCPAN::API->new;

isa_ok( $mcpan, 'MetaCPAN::API' );
can_ok( $mcpan, 'pod'           );
my $errmsg = qr/^Either provide 'module' or 'author and 'release' and 'path'/;

# missing input
like(
    exception { $mcpan->pod },
    $errmsg,
    'Missing any information',
);

# incorrect input
like(
    exception { $mcpan->pod( ding => 'dong' ) },
    $errmsg,
    'Incorrect input',
);

my $result = $mcpan->pod( module => 'Moose' );
ok( $result, 'Got result' );

$result = $mcpan->pod(
    author => 'DOY', release => 'Moose-2.0201', path => 'lib/Moose.pm',
);

ok( $result, 'Got result' );

