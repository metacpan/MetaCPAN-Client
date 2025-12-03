#!perl

use strict;
use warnings;
use Test::More tests => 18;
use Test::Fatal;

use lib '.';
use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'rating' );

{
    my $rs = $mc->download_url( 'Moose' );
    isa_ok( $rs, 'MetaCPAN::Client::DownloadURL' );
    can_ok( $rs, 'date' );
    can_ok( $rs, 'distribution' );
    can_ok( $rs, 'download_url' );
    can_ok( $rs, 'status' );
    can_ok( $rs, 'version' );
}

{
    note "request an older version";
    # URL for 1.01 should not change over time, let's check it
    my $rs = $mc->download_url( 'Moose', 1.01 );
    isa_ok( $rs, 'MetaCPAN::Client::DownloadURL' );
    is $rs->version(), '1.01';
    is $rs->download_url(),
        q[https://cpan.metacpan.org/authors/id/F/FL/FLORA/Moose-1.01.tar.gz],
        'download_url for Moose-1.01';
    is $rs->checksum_sha256(),
        q[f4424f4d709907dea8bc9de2a37b9d3fef4f87775a8c102f432c48a1fdf8067b],
        'sha256 for Moose-1.0.1.tar.gz';
    is $rs->checksum_md5(),
        q[f13f9c203d099f5dc6117f59bda96340],
        'md5 for Moose-1.0.1.tar.gz';
}

{
    note "request a range";
    my $rs = $mc->download_url( 'Moose', '>1.01,<=2.00' );
    isa_ok( $rs, 'MetaCPAN::Client::DownloadURL' );
    is $rs->version(), '1.07';
    is $rs->download_url(),
        q[https://cpan.metacpan.org/authors/id/F/FL/FLORA/Moose-1.07.tar.gz],
        'download_url for Moose-1.07';
}

{
    note "request a devel version with range";
    my $rs = $mc->download_url(  'Try::Tiny', '>0.21,<0.27', 1 );
    isa_ok( $rs, 'MetaCPAN::Client::DownloadURL' );
    is $rs->version(), q[0.22], 'Try::Tiny >0.21,<0.27 dev=1';
}
