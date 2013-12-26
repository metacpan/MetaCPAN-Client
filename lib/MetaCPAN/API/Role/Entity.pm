package MetaCPAN::API::Role::Entity;
# ABSTRACT: A role for MetaCPAN entities

use Moo::Role;

sub new_from_request {
    my ( $class, $request ) = @_;

    return $class->new(
        data => {
            map +( $_ => $request->{$_} ),
            @{ $class->_known_fields }
        }
    );
}

1;

