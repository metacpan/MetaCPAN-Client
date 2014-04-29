use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $mcpan    = MetaCPAN::Client->new;
my $author   = $mcpan->author('XSAWYERX');
my $releases = $author->releases;

p $releases->total;

while ( my $rel = $releases->next ) {
    p $rel->name;
}
