use strict;
use warnings;
package MetaCPAN::Client::File;
# ABSTRACT: A File data object

use Moo;

with 'MetaCPAN::Client::Role::Entity';

my @known_fields = qw<
    pod status date author maturity directory indexed documentation id
    module authorized pod_lines version binary name version_numified release
    path description stat distribution level sloc abstract slop mime
>;

foreach my $field (@known_fields) {
    has $field => (
        is      => 'ro',
        lazy    => 1,
        default => sub {
            my $self = shift;
            return $self->data->{$field};
        },
    );
}

sub _known_fields { return \@known_fields }


1;

__END__

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 pod

=head2 status

=head2 date

=head2 author

=head2 maturity

=head2 directory

=head2 indexed

=head2 documentation

=head2 id

=head2 module

=head2 authorized

=head2 pod_lines

=head2 version

=head2 binary

=head2 name

=head2 version_numified

=head2 release

=head2 path

=head2 description

=head2 stat

=head2 distribution

=head2 level

=head2 sloc

=head2 abstract

=head2 slop

=head2 mime

