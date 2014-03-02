#!perl

use strict;
use warnings;
use Test::More tests => 5;
use Test::Fatal;

use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'author' );

my $author = $mc->author('XSAWYERX');
isa_ok( $author, 'MetaCPAN::Client::Author' );
can_ok( $author, 'pauseid' );
is( $author->pauseid, 'XSAWYERX', 'Correct author' );

