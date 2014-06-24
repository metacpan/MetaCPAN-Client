
# examples/recent.pl

use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $recent =
    MetaCPAN::Client->new->recent(3);

while ( my $rel = $recent->next ) {
    my %output = (
        NAME    => $rel->name,
        AUTHOR  => $rel->author,
        DATE    => $rel->date,
        VERSION => $rel->version,
    );

    p %output;
}

