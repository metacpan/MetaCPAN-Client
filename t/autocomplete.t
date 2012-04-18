#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 6;
use Test::Fatal;
use t::lib::Functions;

my $mcpan = mcpan();

isa_ok( $mcpan, 'MetaCPAN::API' );
can_ok( $mcpan, 'autocomplete'  );

my $errmsg   = qr/^You have to provide a search term/;
my $size_err = qr/^The size has to be between 0 and 100/;

# missing input
like(
    exception { $mcpan->autocomplete },
    $errmsg,
    'Missing any information',
);

# incorrect input
like(
    exception { $mcpan->autocomplete( ding => 'dong' ) },
    $errmsg,
    'Incorrect input',
);

my $result = $mcpan->autocomplete( search => { query => 'Moose', size => 10 } );
ok( $result, 'Got result' );

like (
    exception { $mcpan->autocomplete( search => { query => 'Moose', size => 109 } ) },
    $size_err,
    'Size too big',
);

