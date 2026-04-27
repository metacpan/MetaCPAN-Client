# examples/count.pl

use strict;
use warnings;
use MetaCPAN::Client;

my $author_count =
    MetaCPAN::Client->new()->count('author');

printf "Number of author records: %d\n", $author_count;
