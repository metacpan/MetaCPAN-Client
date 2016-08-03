
# examples/distribution.pl

use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $mcpan = MetaCPAN::Client->new( version => 'v1' );
my $dist  = $mcpan->distribution('Moose');

my %output = (
    NAME  => $dist->name,
    BUGS  => $dist->bugs,
    RIVER => $dist->river,
);

p %output;
