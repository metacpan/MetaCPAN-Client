#!perl

use strict;
use warnings;
use Test::More tests => 9;
use Ref::Util qw< is_arrayref is_ref >;

use lib '.';
use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'package' );

my $pack = $mc->package('MooseX::Types');
isa_ok( $pack, 'MetaCPAN::Client::Package' );
can_ok( $pack, qw< module_name file distribution version author > );
ok( !is_ref($pack->module_name),  "module_name is not a ref");
ok( !is_ref($pack->file),         "file is not a ref");
ok( !is_ref($pack->distribution), "distribution is not a ref");
ok( !is_ref($pack->version),      "version is not a ref");
ok( !is_ref($pack->author),       "author is not a ref");
