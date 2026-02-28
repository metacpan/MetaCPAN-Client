# examples/cve.pl

use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $cve =
    MetaCPAN::Client->new()->cve('CPANSA-DBD-SQLite-2019-5018');

my %output = (
    DISTRIBUTION => $cve->distribution,
    RELEASES     => $cve->releases,
    REFERENCES   => $cve->references,
    SEVERITY     => $cve->severity,
    REPORTED     => $cve->reported,
    VERSIONS     => $cve->versions,
);

p %output;
