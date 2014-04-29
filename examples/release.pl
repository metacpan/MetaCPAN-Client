use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $release =
    MetaCPAN::Client->new->release('Moo');

my %output = (
    AUTHOR  => $release->author,
    DATE    => $release->date,
    STATUS  => $release->status,
    VERSION => $release->version,
    TESTS   => $release->tests,
);

p %output;
