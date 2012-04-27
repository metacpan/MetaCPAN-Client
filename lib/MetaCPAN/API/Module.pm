use strict;
use warnings;
package MetaCPAN::API::Module;
# ABSTRACT: Module information for MetaCPAN::API

use Carp;
use Any::Moose 'Role';

# /module/{module}
sub module {
    my $self = shift;
    my $name = shift;

    $name or croak 'Please provide a module name';

    return $self->fetch("module/$name");
}

1;

__END__

=head1 DESCRIPTION

This role provides MetaCPAN::API with fetching information about modules.

More specifically, this returns the C<.pm> file of that module.

=head1 METHODS

=head2 module

    my $result = $mcpan->module('MetaCPAN::API');

Searches MetaCPAN and returns a module's C<.pm> file.

=head2 file

This used to be a synonym of C<module>, but the functionality has now
moved to L<MetaCPAN::API::File>.

