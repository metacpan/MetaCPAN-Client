#!perl

use strict;
use warnings;
use Test::More tests => 15;
use Test::Fatal;

use lib '.';
use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'rating' );

{
    my $rs = $mc->download_url( 'Moose' );
    isa_ok( $rs, 'MetaCPAN::Client::DownloadURL' );
    can_ok( $rs, 'date' );
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