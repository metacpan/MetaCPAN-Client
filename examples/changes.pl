use strict;
use warnings;
use MetaCPAN::Client;

my $dist = shift || 'Moose';

my $mcpan = MetaCPAN::Client->new();
my $rel   = $mcpan->release($dist);
print $rel->changes;
