use strict;
use warnings;
package MetaCPAN::Client::Package;
# ABSTRACT: A package data object (02packages.details entry)

use Moo;

with 'MetaCPAN::Client::Role::Entity';

my %known_fields = (
    scalar   => [qw< author distribution dist_version file module_name version >],
    arrayref => [qw<>],
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

    my $package = $mcpan->package('MooseX::Types');

=head1 DESCRIPTION

A MetaCPAN package (02packages.details) entity object.

=head1 ATTRIBUTES

=head2 module_name

Returns the name of the module.

=head2 file

The file path in CPAN for the module (latest release)

=head2 distribution

The distribution in which the module exist

=head2 version

The (latest) version of the module

=head2 dist_version

The (latest) version of the distribution

=head2 author

The pauseid of the release author
