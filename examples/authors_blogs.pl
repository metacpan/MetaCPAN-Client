use strict;
use warnings;

use MetaCPAN::Client;

my $mcpan = MetaCPAN::Client->new;

my $all_authors = $mcpan->all('authors');

AUTHOR: while ( my $author = $all_authors->next ) {

  BLOG: for my $blog ( @{ $author->blog || [] } ) {
        $blog and exists $blog->{url} or next BLOG;
        my $url = $blog->{url};

        my $blogs_csv = ref $url eq 'ARRAY'
            ? join q{,} => @$url
            : $url;

        printf "%-10s: %s\n", $author->pauseid, $blogs_csv;
    }
}
