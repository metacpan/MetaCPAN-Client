#!perl

use strict;
use warnings;

use Test::More;
use JSON::MaybeXS qw< encode_json JSON >;
use MetaCPAN::Client::Request qw<>;

# _build_query_element should accept JSON booleans for term queries,
# not just plain strings. Boolean fields like 'authorized' and 'indexed'
# require JSON true/false values in modern Elasticsearch.

my $result = MetaCPAN::Client::Request::_build_query_element(
    { authorized => JSON->true }
);

is_deeply(
    $result,
    { term => { authorized => JSON->true } },
    'JSON boolean true accepted in query element',
);

my $json = encode_json($result);
like(
    $json,
    qr/"authorized":true\b/,
    'serializes as JSON boolean true, not integer',
);

# JSON false should also work
my $result_false = MetaCPAN::Client::Request::_build_query_element(
    { indexed => JSON->false }
);

is_deeply(
    $result_false,
    { term => { indexed => JSON->false } },
    'JSON boolean false accepted in query element',
);

# Regular string values should still work
my $result_str = MetaCPAN::Client::Request::_build_query_element(
    { status => 'latest' }
);

is_deeply(
    $result_str,
    { term => { status => 'latest' } },
    'plain string values still work',
);

# Wildcard values should still work
my $result_wc = MetaCPAN::Client::Request::_build_query_element(
    { name => 'Moose*' }
);

is_deeply(
    $result_wc,
    { wildcard => { name => 'Moose*' } },
    'wildcard values still produce wildcard queries',
);

done_testing;
