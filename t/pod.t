#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 11;
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

# failing content types
like(
    exception {
        $mcpan->pod( module => 'Moose', 'content-type' => 'text/text' )
    },
    qr/^Incorrect content-type provided/,
    'Incorrect content-type',
);

# successful content types
my @types = qw( text/html text/plain text/x-pod text/x-markdown );
foreach my $type (@types) {
    is(
        exception { $mcpan->pod( module => 'Moose', 'content-type' => $type ) },
        undef, # no exception
        'Correct content-type',
    );
}

