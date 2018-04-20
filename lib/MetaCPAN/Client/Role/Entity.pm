use strict;
use warnings;
package MetaCPAN::Client::Role::Entity;
# ABSTRACT: A role for MetaCPAN entities

use Moo::Role;

use JSON::PP;
use Ref::Util qw< is_ref is_arrayref is_hashref >;

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

sub BUILDARGS {
    my ( $class, %args ) = @_;

    my $known_fields = $class->_known_fields;

    for my $k ( @{ $known_fields->{scalar} } ) {
        $args{data}{$k} = $args{data}{$k}->[0]
            if is_arrayref( $args{data}{$k} ) and @{$args{data}{$k}} == 1;

        if ( JSON::PP::is_bool($args{data}{$k}) ) {
            $args{data}{$k} = !!$args{data}{$k};
        }
        elsif ( is_ref( $args{data}{$k} ) ) {
            delete $args{data}{$k};
        }
    }

    for my $k ( @{ $known_fields->{arrayref} } ) {
        # fix the case when we expect an array ref but get a scalar because
        # the result array had one element and we received a scalar
        if ( defined($args{data}{$k}) and !is_ref($args{data}{$k}) ) {
            $args{data}{$k} = [ $args{data}{$k} ]
        }

        delete $args{data}{$k}
            unless is_arrayref( $args{data}{$k} ); # warn?
    }

    for my $k ( @{ $known_fields->{hashref} } ) {
        delete $args{data}{$k}
            unless is_hashref( $args{data}{$k} ); # warn?
    }

    return \%args;
}

sub new_from_request {
    my ( $class, $request, $client ) = @_;

    my $known_fields = $class->_known_fields;

    return $class->new(
        ( defined $client ? ( client => $client ) : () ),
        data => {
            map +( defined $request->{$_} ? ( $_ => $request->{$_} ) : () ),
            map +( @{ $known_fields->{$_} } ),
            qw< scalar arrayref hashref >
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

=head2 BUILDARGS

Perform type checks & conversion for the incoming data.
