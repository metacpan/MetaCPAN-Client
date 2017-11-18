#!perl

use strict;
use warnings;
use Test::More tests => 45;
use Test::Fatal;
use Ref::Util qw< is_hashref >;

use lib '.';
use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'reverse_dependencies' );
can_ok( $mc, 'rev_deps' );

# isa_ok( $dist, 'MetaCPAN::Client::Distribution' );

my $module = 'MetaCPAN::Client';

my $rs = $mc->reverse_dependencies($module);

isa_ok $rs, 'MetaCPAN::Client::ResultSet';

my @revdeps;

while (my $release = $rs->next){
    is 
        ref $release, 
        'MetaCPAN::Client::Release', 
        "ResultSet->next with " . $release->distribution . " is ok";

    push @revdeps, $release->distribution;
}

is @revdeps > 2, 1, "revdep count for MetaCPAN::Client seems ok";

for (@revdeps){
    s/-/::/g;

    my $ok = eval {
        $mc->module($_)->name;
        1;
    };

    is $ok, 1, "$_ is a valid reverse dependency";
}
