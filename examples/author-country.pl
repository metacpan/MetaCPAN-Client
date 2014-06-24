
# examples/author-country.pl

use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my @countries = qw<AT AU BE CA CH DE ES FR GB
                   IL IR IS NL PL RO RU UK US>;

my %cc2authors;

for my $cc ( @countries ) {
    my $authors =
        MetaCPAN::Client->new->author({ country => $cc });

    $cc2authors{$cc} = $authors->total;
}

p %cc2authors;
