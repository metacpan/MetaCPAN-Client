use strict;
use warnings;
package MetaCPAN::Client::Permission;
# ABSTRACT: A Permission data object

use Moo;

with 'MetaCPAN::Client::Role::Entity';

my %known_fields = (
    scalar   => [qw< module_name owner >],
    arrayref => [qw< co_maintainers >],
    hashref  => [],
);

my @known_fields =
    map { @{ $known_fields{$_} } } qw< scalar arrayref hashref >;

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

sub _known_fields { return \%known_fields }

1;

__END__

=head1 SYNOPSIS

    my $permission = $mcpan->permission('MooseX::Types');

=head1 DESCRIPTION

A MetaCPAN permission entity object.

=head1 ATTRIBUTES

=head2 module_name

Returns the name of the module.

=head2 owner

The module owner (first-come permissions).

=head2 co_maintainers

Other maintainers with permissions to this module.
