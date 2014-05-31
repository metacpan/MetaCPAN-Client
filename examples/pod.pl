use strict;
use warnings;
use MetaCPAN::Client;

my $pod =
    MetaCPAN::Client->new->pod('Moo');

print $pod->html;
