#!perl

use strict;
use warnings;
use Test::More tests => 10;
use Test::Fatal;

use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'module' );

my $module = $mc->module('MetaCPAN::API');
isa_ok( $module, 'MetaCPAN::Client::Module' );
can_ok( $module, qw<distribution name path> );
is( $module->distribution, 'MetaCPAN-API', 'Correct distribution' );
is( $module->name, 'API.pm', 'Correct name' );
is( $module->path, 'lib/MetaCPAN/API.pm', 'Correct path' );

my $rs = $mc->module( { path => 'lib/MetaCPAN' } );
isa_ok( $rs, 'MetaCPAN::Client::ResultSet' );
can_ok( $rs, 'total' );
ok( $rs->total > 0, 'More than a single result in result set' );

