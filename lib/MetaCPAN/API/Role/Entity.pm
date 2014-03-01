package MetaCPAN::API::Role::Entity;
# ABSTRACT: A role for MetaCPAN entities

use Moo::Role;

has data => (
    is       => 'ro',
    required => 1,
);

sub new_from_request {
    my ( $class, $request ) = @_;

    return $class->new(
        data => {
            map +( defined $request->{$_} ? ( $_ => $request->{$_} ) : () ),
            @{ $class->_known_fields }
        }
    );
}

1;

__END__

=head1 DESCRIPTION

This is a role to be consumed by all L<MetaCPAN::API> entities. It provides
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

