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

