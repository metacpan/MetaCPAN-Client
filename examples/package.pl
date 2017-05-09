# examples/package.pl

use strict;
use warnings;
use Data::Printer;
use MetaCPAN::Client;

my $mcpan = MetaCPAN::Client->new();
my $pack  = $mcpan->package('MooseX::Types');
p $pack;

1;
__END__

Alternatively:

my $module = $mcpan->module('MooseX::Types');
my $pack   = $module->package;
