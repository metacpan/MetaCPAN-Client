use strict;
use warnings;
package MetaCPAN::Client::Role::Entity;
# ABSTRACT: A role for MetaCPAN entities

use Moo::Role;

has data => (
    is       => 'ro',
    required => 1,
);

has client => (
    is         => 'ro',
    lazy       => 1,
    builder    => '_build_client',
);

sub _build_client {
    require MetaCPAN::Client;
    return MetaCPAN::Client->new();
}

sub new_from_request {
    my ( $class, $request, $client ) = @_;

    return $class->new(
        ( defined $client ? ( client => $client ) : () ),
        data => {
            map +( defined $request->{$_} ? ( $_ => $request->{$_} ) : () ),
            @{ $class->_known_fields }
        }
    );
}

1;

__END__

=head1 DESCRIPTION

This is a role to be consumed by all L<MetaCPAN::Client> entities. It provides
common attributes and methods.

=head1 ATTRIBUTES

=head2 data

Hash reference containing all the entity data.

Entities are usually generated using C<new_from_request> which sets the C<data>
attribute appropriately by picking the relevant information.

Required.

=head1 METHODS

=head2 new_from_request

Create a new entity object using a request hash. The hash represents the
information returned from a MetaCPAN request. This also sets the data attribute.

