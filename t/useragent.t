#!perl

use strict;
use warnings;

use LWP::UserAgent;
use Test::More;
use Test::Fatal;

use t::lib::Functions;

my $mc = mcpan();

my $mcpan = MetaCPAN::Client->new( ua => LWP::UserAgent->new );

is( exception { $mcpan->author( 'XSAWYERX' ); },
    undef, 'LWP::UserAgent response parsed',
);

done_testing();
