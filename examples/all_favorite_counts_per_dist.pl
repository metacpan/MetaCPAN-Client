use strict;
use warnings;
use Data::Printer;

use MetaCPAN::Client;

# All 1+ favorite counts per distributions
# -- done inefficiently :)

my $mcpan = MetaCPAN::Client->new();
my $size  = $mcpan->all('favorites')->total;
my $favs  = $mcpan->all('favorites', {
    facets => {
        distribution => {
            terms => {
                field => "distribution",
                size  => $size,
                order => "reverse_count",
#                all_terms => "true",
            }
        },
    }
});

p $favs->facets->{distribution}{terms};
