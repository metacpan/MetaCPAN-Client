
# examples/rating.pl

use strict;
use warnings;
use Data::Printer;

use MetaCPAN::Client;

my $rating =
    MetaCPAN::Client->new->rating({ distribution => "Moose" });

p $rating->next;
