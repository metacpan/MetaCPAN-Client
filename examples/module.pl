
# examples/module.pl

use strict;
use warnings;
use DDP;

use MetaCPAN::Client;

my $module =
    MetaCPAN::Client->new->module('Moo');

my %output = (
    NAME        => $module->name,
    ABSTRACT    => $module->abstract,
    DESCRIPTION => $module->description,
    RELEASE     => $module->release,
    AUTHOR      => $module->author,
    VERSION     => $module->version,
);

p %output;

