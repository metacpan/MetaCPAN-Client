#!perl

use strict;
use warnings;
use Test::More tests => 7;
use Test::Fatal;

use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'rating' );

my $rs = $mc->download_url( 'Moose' );
isa_ok( $rs, 'MetaCPAN::Client::DownloadURL' );
can_ok( $rs, 'date' );
can_ok( $rs, 'download_url' );
can_ok( $rs, 'status' );
can_ok( $rs, 'version' );
