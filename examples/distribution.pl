use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $dist =
    MetaCPAN::Client->new->distribution('Moose');

my %output = (
    NAME => $dist->name,
    BUGS => $dist->bugs,
);

p %output;
