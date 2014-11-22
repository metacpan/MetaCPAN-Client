use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $mcpan = MetaCPAN::Client->new;

my $all_authors  = $mcpan->all('authors');
my $all_dists    = $mcpan->all('distributions');
my $all_modules  = $mcpan->all('modules');
my $all_releases = $mcpan->all('releases');

print "totals:\n";
printf "authors       : %d\n", $all_authors->total;
printf "distributions : %d\n", $all_dists->total;
printf "modules       : %d\n", $all_modules->total;
printf "releases      : %d\n", $all_releases->total;
