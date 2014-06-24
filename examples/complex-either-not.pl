
# examples/complex-either-not.pl

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
        not => [
            { name => 'Dave C*'  },
            { name => 'David M*' },
        ]
    });

print "\n";
my %out = ( TOTAL => $authors->total );
p %out;
