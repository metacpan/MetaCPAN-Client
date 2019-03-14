
# examples/top20_favorites

use strict;
use warnings;
use MetaCPAN::Client;

my $top20_fav =
    MetaCPAN::Client->new()->all(
        'favorites',
        {
            aggregations => {
                aggs => {
                    terms => {
                        field => "distribution"
                    }
                }
            }
        }
    );

for my $bucket ( @{ $top20_fav->aggregations->{aggs}{buckets} } ) {
    printf "%s : %s\n", $bucket->{doc_count}, $bucket->{key}
}
