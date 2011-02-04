use strict;
use warnings;
package MetaCPAN::API;
# ABSTRACT: A comprehensive, DWIM-featured API to MetaCPAN

use Any::Moose;
use JSON;
use Carp;
use Try::Tiny;
use HTTP::Tiny;

with qw/
    MetaCPAN::API::Author
    MetaCPAN::API::CPANRatings
    MetaCPAN::API::Module
    MetaCPAN::API::POD
/;

has base_url => (
    is      => 'ro',
    isa     => 'Str',
    default => 'http://api.metacpan.org',
);

has ua => (
    is         => 'ro',
    isa        => 'HTTP::Tiny',
    lazy_build => 1,
);

sub _build_ua {
    return HTTP::Tiny->new;
}

sub _get_hits {
    my $self     = shift;
    my $response = shift;
    my @hits     = ();

    try {
        # a single search might return partial JSON data, but no hits,
        # search dist for "Moose", or author for "Dave", it will come up
        # in that case, we need to check for a _source key

        my $content = decode_json $response->{'content'};

        if ( exists $content->{'hits'}{'hits'} ) {
            @hits = @{ $content->{'hits'}{'hits'} };
        } elsif ( exists $content->{'_source'} ) {
            @hits = $content;
        }
    } catch {
        croak 'There was an error decoding response from MetaCPAN.';
    };

    return @hits;
}

sub render_result {
1;
}

1;
