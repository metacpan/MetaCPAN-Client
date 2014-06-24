

# examples/author.pl

use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $author =
    MetaCPAN::Client->new->author('XSAWYERX');

my %output = (
    NAME    => $author->name,
    EMAILS  => $author->email,
    COUNTRY => $author->country,
    CITY    => $author->city,
    PROFILE => $author->profile,
);

p %output;

