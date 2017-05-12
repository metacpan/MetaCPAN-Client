use strict;
use warnings;
use MetaCPAN::Client;
use Data::Printer;

my $mcpan = MetaCPAN::Client->new();

my $release = $mcpan->release({
    all => [
        { distribution => 'Moose' },
        { version => '2.2005' },
    ]
})->next;

my $contributors = $release->contributors;

p $contributors;

1;
