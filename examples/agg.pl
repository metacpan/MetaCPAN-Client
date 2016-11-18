
# examples/agg.pl

use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $author =
    MetaCPAN::Client->new( version => 'v1' )->all(
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
