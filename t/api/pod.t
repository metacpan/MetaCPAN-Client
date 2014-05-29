#!perl

use strict;
use warnings;
use Test::More tests => 5;

use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, 'pod' );

my $pod = $mc->pod('MetaCPAN::API');
isa_ok( $pod, 'MetaCPAN::Client::Pod' );
can_ok( $pod, qw<html x_pod x_markdown plain name> );
like( $pod->x_pod, qr/=head1/, 'got pod' );

