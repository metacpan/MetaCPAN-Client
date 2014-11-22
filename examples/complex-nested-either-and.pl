
# examples/complex-nested-either-and.pl

use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $authors =
    MetaCPAN::Client->new->author({
        either => [
            { all => [ { name => 'Dave *'  },
                       { email => '*gmail.com' } ]
            },
            { all => [ { name => 'Sam *' },
                       { email => '*cpan.org' } ]
            },
        ],
    });

my %output = (
    TOTAL => $authors->total,
    NAMES => [ map { $authors->next->name } 0 .. 9 ],
);

p %output;
