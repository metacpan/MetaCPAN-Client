# examples/permission.pl

use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $mcpan = MetaCPAN::Client->new();
my $perm  = $mcpan->permission('MooseX::Types');
p $perm;
