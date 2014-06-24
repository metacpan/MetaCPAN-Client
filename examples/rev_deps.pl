
# examples/rev_deps.pl

use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $module = shift || 'Hijk';

my $deps =
    MetaCPAN::Client->new->rev_deps($module);

my @output;

while ( my $rel = $deps->next ) {
    push @output => {
        name   => $rel->name,
        author => $rel->author,
    };
}

print "\n";
my $title = "Reverse dependencies for 'Hijk':";
p $title;
p @output;
