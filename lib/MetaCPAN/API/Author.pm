use strict;
use warnings;
package MetaCPAN::API::Author;
# ABSTRACT: Author information for MetaCPAN::API

use Carp;
use Any::Moose 'Role';

# /author/{author}
sub author {
    my $self    = shift;
    my $pauseid = shift;

    $pauseid or croak 'Please provide an author PAUSEID';

    return $self->fetch("author/$pauseid");
}

1;

__END__

=head1 DESCRIPTION

This role provides MetaCPAN::API with fetching information about authors.

=head1 METHODS

=head2 author

    my $result = $mcpan->author('XSAWYERX');

Searches MetaCPAN for a specific author.

