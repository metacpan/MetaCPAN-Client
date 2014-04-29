use strict;
use warnings;
use DDP;

use MetaCPAN::Client;

my $dist =
    MetaCPAN::Client->new->distribution('CPAN-Releases-Latest');

my %output = (
    NAME => $dist->name,
    BUGS => $dist->bugs,
);

p %output;
