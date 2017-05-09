use strict;
use warnings;
package MetaCPAN::Client::Module;
# ABSTRACT: A Module data object

use Moo;
extends 'MetaCPAN::Client::File';

sub metacpan_url {
    my $self = shift;
    sprintf("https://metacpan.org/pod/release/%s/%s/%s",
            $self->author, $self->release, $self->path );
}

sub package {
    my $self = shift;
    return $self->client->package( $self->documentation );
}

sub permission {
    my $self = shift;
    return $self->client->permission( $self->documentation );
}

1;

__END__

=head1 SYNOPSIS

    my $module = MetaCPAN::Client->new->module('Moo');

=head1 DESCRIPTION

A MetaCPAN module entity object.

This is currently the exact same as L<MetaCPAN::Client::File>.

=head1 ATTRIBUTES

Whatever L<MetaCPAN::Client::File> has.

=head1 METHODS

=head2 metacpan_url

Returns a link to the module page on MetaCPAN.

=head2 package

Returns an L<MetaCPAN::Client::Package> object for the module.

=head2 permission

Returns an L<MetaCPAN::Client::Permission> object for the module.
