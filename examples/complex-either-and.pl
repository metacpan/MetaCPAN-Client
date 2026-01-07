
# examples/complex-either-and.pl

use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $authors =
    MetaCPAN::Client->new->author({
        either => [
            { name => 'Dave *'  },
            { name => 'David *' },
        ],
        all => { email => '*cpan.org' },
    });

my %output = (
    TOTAL => $authors->total,
    NAMES => [ map { $authors->next->name } 0 .. 9 ],
);

p %output;
