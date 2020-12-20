#!perl

use strict;
use warnings;
use Test::More tests => 7;
use Test::Fatal;

use lib '.';
use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'release' );

my $release = $mc->release('MetaCPAN-API');
isa_ok( $release, 'MetaCPAN::Client::Release' );
can_ok( $release, qw<distribution> );
is( $release->distribution, 'MetaCPAN-API', 'Correct distribution' );
like($release->checksum_sha256, qr/^[a-f0-9]{64}$/, 'Has a sha256 hexdigest');
like($release->checksum_md5, qr/^[a-f0-9]{32}$/, 'Has a md5 hexdigest');
