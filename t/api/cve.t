#!perl

use strict;
use warnings;
use Test::More tests => 14;
use Ref::Util qw< is_arrayref is_ref >;

use lib '.';
use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'cve' );

my $cve = $mc->cve('CPANSA-DBD-SQLite-2019-5018');
isa_ok( $cve, 'MetaCPAN::Client::CVE' );
can_ok( $cve, qw< cpansa_id description distribution reported severity affected_versions cves references releases versions > );
ok( !is_ref($cve->cpansa_id), "cpansa_id is not a ref");
ok( !is_ref($cve->description), "description is not a ref");
ok( !is_ref($cve->distribution), "distribution is not a ref");
ok( !is_ref($cve->reported), "reported is not a ref");
ok( !is_ref($cve->severity), "severity is not a ref");
ok( is_arrayref($cve->affected_versions), "affected_versions is an arrayref");
ok( is_arrayref($cve->cves), "cves is an arrayref");
ok( is_arrayref($cve->references), "references is an arrayref");
ok( is_arrayref($cve->releases), "releases is an arrayref");
ok( is_arrayref($cve->versions), "versions is an arrayref");
