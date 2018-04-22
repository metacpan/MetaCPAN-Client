#!perl

use strict;
use warnings;
use Test::More tests => 8;
use Ref::Util qw< is_hashref is_ref >;

use lib '.';
use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'cover' );

my $cover = $mc->cover('Moose-2.2007');
isa_ok( $cover, 'MetaCPAN::Client::Cover' );
can_ok( $cover, qw< distribution release version criteria > );
ok( !is_ref($cover->distribution), "distribution is not a ref");
ok( !is_ref($cover->release), "release is not a ref");
ok( !is_ref($cover->version), "version is not a ref");
ok( is_hashref($cover->criteria), "criteria is a hashref");
