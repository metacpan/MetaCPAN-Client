# examples/cve_list.pl

use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $all_cves =
    MetaCPAN::Client->new()->all('cve');

my @output = map {
    $all_cves->next->cpansa_id
} 1 .. 20;

p @output;
