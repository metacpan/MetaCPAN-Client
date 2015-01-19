use strict;
use warnings;

use MetaCPAN::Client;

# use raw ES filter on a { match_all => {} } query

# find 'latest' status releases with at least 700 failing tests
# which consist at least 50% of their overall number of tests.

my $release = MetaCPAN::Client->new->all(
    'releases',
    {
        es_filter => {
            and => [
                { range => { 'tests.fail' => { gte => 700 } } },
                { term  => { 'status' => 'latest' } }
            ]
        },

        fields => [qw/ name tests /],
    }
);

while ( my $r = $release->next ) {
    my $fail = $r->tests->{fail};
    my $all  = 0; $all += $_ for @{ $r->tests }{qw/pass fail na unknown/};
    ($fail / $all) >= 0.5 and printf "%4d/%4d: %s\n", $fail, $all, $r->name;
}
