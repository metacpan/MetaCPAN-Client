use strict;
use warnings;
package MetaCPAN::Client::DownloadURL;
# ABSTRACT: A Download URL data object

use Moo;

with 'MetaCPAN::Client::Role::Entity';

my %known_fields = (
    scalar   => [qw< date download_url status version >],
    arrayref => [],
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

    my $download_url = $mcpan->download_url('Moose');

=head1 DESCRIPTION

A MetaCPAN download_url entity object.

=head1 ATTRIBUTES

=head2 date

Returns the date of the release that this URL refers to.

=head2 download_url

The actual download URL.

=head2 status

The release status, which is something like C<latest> or C<cpan>

=head2 version

The version number for the distribution.
