use strict;
use warnings;
package MetaCPAN::Client::Release;
# ABSTRACT: A Release data object

use Moo;

with 'MetaCPAN::Client::Role::Entity';

my %known_fields = (
    scalar => [qw<
        abstract
        archive
        author
        authorized
        date
        distribution
        download_url
        first
        id
        maturity
        name
        status
        version
        version_numified
    >],

    arrayref => [qw<
        dependency
        license
        provides
    >],

    hashref => [qw<
        metadata
        resources
        stat
        tests
    >],
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

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 resources

=head2 status

=head2 date

=head2 author

=head2 maturity

=head2 dependency

=head2 id

=head2 authorized

=head2 download_url

=head2 first

=head2 archive

=head2 version

=head2 name

=head2 version_numified

=head2 license

=head2 distribution

=head2 stat

=head2 provides

=head2 tests

=head2 abstract

=head2 metadata
