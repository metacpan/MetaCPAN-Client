use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $author =
    MetaCPAN::Client->new(raw_output=>1)->author('XSAWYERX');

p $author;
