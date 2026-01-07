

# examples/mirror.pl

use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $mirrors =
    MetaCPAN::Client->new->mirror('www.cpan.org');

p $mirrors;
