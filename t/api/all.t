#!perl

use strict;
use warnings;
use Test::More tests => 10;
use Test::Fatal;

use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'all' );

my $module = $mc->all('modules', 'MetaCPAN::API', {});
isa_ok( $module, 'MetaCPAN::Client::Module' );
can_ok( $module, qw<distribution name path> );
is( $module->distribution, 'MetaCPAN-API', 'Correct distribution' );
is( $module->name, 'API.pm', 'Correct name' );
is( $module->path, 'lib/MetaCPAN/API.pm', 'Correct path' );

my $rs = $mc->all('modules', { path => 'lib/MetaCPAN' }, { fields => [qw/name distribution/] } );
isa_ok( $rs, 'MetaCPAN::Client::ResultSet' );
can_ok( $rs, 'total' );
ok( $rs->total > 0, 'More than a single result in result set' );

