use strict;
use warnings;
package MetaCPAN::Client::CVE;
# ABSTRACT: A Permission data object

use Moo;

with 'MetaCPAN::Client::Role::Entity';

my %known_fields = (
    scalar   => [qw< cpansa_id description distribution reported severity >],
    arrayref => [qw< affected_versions cves references releases versions >],
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

    my $cve = $mcpan->cve('MooseX::Types');

=head1 DESCRIPTION

A MetaCPAN CVE entity object.

=head1 ATTRIBUTES

=head2 cpansa_id

Returns the CPAN Security Advisory Database id

=head2 description

The CVE description

=head2 distribution

The CPAN distribution

=head2 reported

The reporting date of the CVE

=head2 severity

The severity of the CVE

=head2 affected_versions

Ranges of CPAN affected versions

=head2 cves

List of CVEs

=head2 references

List of references (URLs)

=head2 releases

List of CPAN releases

=head2 versions

Extracted list of existing CPAN releases
