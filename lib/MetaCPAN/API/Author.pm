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
    my $url     = '';

    $pauseid or croak 'Please provide an author PAUSEID';

    return $self->fetch("author/$pauseid");
}

1;

__END__

=head1 DESCRIPTION

This role provides MetaCPAN::API with fetching information about distribution
and releases.

=head1 METHODS

=head2 release

    my $result = $mcpan->release( distribution => 'Moose' );

    # or
    my $result = $mcpan->release( author => 'DOY', release => 'Moose-2.0001' );

Searches MetaCPAN for a dist.

