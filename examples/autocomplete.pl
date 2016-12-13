
# examples/autocomplete.pl

use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $mcpan = MetaCPAN::Client->new();

my $ac = $mcpan->autocomplete("Danc");

p $ac;
