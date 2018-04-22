# examples/cover.pl

use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $mcpan = MetaCPAN::Client->new();
my $coverage = $mcpan->cover('Moose-2.2007');
p $coverage;

1;
