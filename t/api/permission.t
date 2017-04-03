#!perl

use strict;
use warnings;
use Test::More tests => 7;
use Ref::Util qw< is_arrayref is_ref >;

use lib '.';
use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'permission' );

my $perm = $mc->permission('MooseX::Types');
isa_ok( $perm, 'MetaCPAN::Client::Permission' );
can_ok( $perm, qw< module_name owner co_maintainers > );
ok( !is_ref($perm->module_name), "module_name is not a ref");
ok( !is_ref($perm->owner), "owner is not a ref");
ok( is_arrayref($perm->co_maintainers), "co_maintainers is an arrayref");
