use strict;
use warnings;
package MetaCPAN::Client::Module;
# ABSTRACT: A Module data object

use Moo;
extends 'MetaCPAN::Client::File';

1;

__END__

=head1 SYNOPSIS

    my $module = MetaCPAN::Client->new->module('Moo');

=head1 DESCRIPTION

A MetaCPAN module entity object.

This is currently the exact same as L<MetaCPAN::Client::File>.

=head1 ATTRIBUTES

Whatever L<MetaCPAN::Client::File> has.
