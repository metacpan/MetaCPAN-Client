#!perl

use strict;
use warnings;

use Test::More tests => 2;
use MetaCPAN::API;

my $mcpan = MetaCPAN::API->new;
isa_ok( $mcpan, 'MetaCPAN::API' );

TODO: {
    local $TODO = 'Awaiting implementation';

    can_ok( $mcpan, qw/release author module pod/ );
};

