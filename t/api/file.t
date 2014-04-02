#!perl

use strict;
use warnings;
use Test::More tests => 10;
use Test::Fatal;

use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'file' );

my $file = $mc->file('DOY/Moose-2.0001/lib/Moose.pm');
isa_ok( $file, 'MetaCPAN::Client::File' );
can_ok( $file, qw<author distribution name path release version> );
is( $file->author, 'DOY', 'Correct author' );
is( $file->distribution, 'Moose', 'Correct distribution' );
is( $file->name, 'Moose.pm', 'Correct name' );
is( $file->path, 'lib/Moose.pm', 'Correct path' );
is( $file->release, 'Moose-2.0001', 'Correct release' );
is( $file->version, '2.0001', 'Correct version' );

