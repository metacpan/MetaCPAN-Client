
# examples/agg.pl

use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $author =
    MetaCPAN::Client->new()->all(
        'authors',
        {
            aggregations => {
                aggs => {
                    terms => {
                        field => "country"
                    }
                }
            }
        }
    );

p $author->aggregations;
