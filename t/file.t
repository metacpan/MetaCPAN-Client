#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 8;
use Test::Fatal;
use t::lib::Functions;

my $mcpan = mcpan();

isa_ok( $mcpan, 'MetaCPAN::API' );
can_ok( $mcpan, 'file'          );
my $errmsg = qr/^Either provide a module name, 'id', or 'author and 'release' and an optional 'path'/;

# missing input
like(
    exception { $mcpan->file },
    $errmsg,
    'Missing any information',
);

# incorrect input
like(
    exception { $mcpan->file( ding => 'dong' ) },
    $errmsg,
    'Incorrect input',
);

my $result = $mcpan->file(
    author => 'DOY', release => 'Moose-2.0201', path => 'lib/Moose.pm',
);
ok( $result, 'Got result' );

$result = $mcpan->file(
    author => 'DOY', release => 'Moose-2.0201',
);
ok( $result, 'Got result' );

$result = $mcpan->file(
    id => 'ZdlTjiaxpvo9yRWUIB_V06SvRl4'
);
ok( $result, 'Got result' );

$result = $mcpan->file('MetaCPAN::API');
ok( $result, 'Got result' );
