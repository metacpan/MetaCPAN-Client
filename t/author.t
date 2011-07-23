#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 4;
use Test::Fatal;
use MetaCPAN::API;

my $mcpan = MetaCPAN::API->new;

isa_ok( $mcpan, 'MetaCPAN::API' );
can_ok( $mcpan, 'author'        );
my $errmsg = qr/^Please provide author PAUSEID/;

# missing input
like(
    exception { $mcpan->author },
    $errmsg,
    'Missing any information',
);

my $result = $mcpan->author('DOY');
ok( $result, 'Got result' );

