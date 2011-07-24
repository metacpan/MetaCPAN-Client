#!perl

use strict;
use warnings;

use Test::More tests => 3;
use MetaCPAN::API;

{
    my $mcpan = MetaCPAN::API->new;
    isa_ok( $mcpan->ua, 'HTTP::Tiny' );
}

{
    my $mcpan = MetaCPAN::API->new(
        ua_args => [ agent => 'MyAgentMon' ],
    );

    my $ua = $mcpan->ua;
    isa_ok( $ua, 'HTTP::Tiny' );
    is( $ua->agent, 'MyAgentMon', 'Correct user agent arguments' );
}

