use strict;
use warnings;
use MetaCPAN::Client;

my $mcpan = MetaCPAN::Client->new();

my $auth = $mcpan->author('HAARG');
my $mod  = $mcpan->module('Moo');
my $file = $mcpan->file('HAARG/Moo-2.003001/lib/Moo.pm');
my $dist = $mcpan->distribution('Moo');
my $rel  = $mcpan->release({
    all => [
        { distribution => 'Moo' },
        { version => '2.002005' },
    ]
});

printf "AUTHOR       : %s\n", $auth->metacpan_url;
printf "RELEASE      : %s\n", $rel->next->metacpan_url;
printf "MODULE       : %s\n", $mod->metacpan_url;
printf "FILE         : %s\n", $file->metacpan_url;
printf "DISTRIBUTION : %s\n", $dist->metacpan_url;

1;
