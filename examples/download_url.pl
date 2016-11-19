
# examples/download_url.pl

use strict;
use warnings;
use DDP;

use MetaCPAN::Client;

my $mcpan = MetaCPAN::Client->new();

my $download_url = $mcpan->download_url('Moose');

my %output = (
    VERSION      => $download_url->version,
    STATUS       => $download_url->status,
    DATE         => $download_url->date,
    DOWNLOAD_URL => $download_url->download_url,
);

p %output;
