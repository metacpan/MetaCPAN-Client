use strict;
use warnings;
package MetaCPAN::Client::Cover;
# ABSTRACT: A Cover data object

use Moo;

with 'MetaCPAN::Client::Role::Entity';

my %known_fields = (
    scalar   => [qw< distribution release version >],
    arrayref => [],
    hashref  => [qw< criteria >],
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

    my $cover = $mcpan->cover('Moose-2.2007');

=head1 DESCRIPTION

A MetaCPAN cover entity object.

=head1 ATTRIBUTES

=head2 distribution

Returns the name of the distribution.

=head2 release

Returns the name of the release.

=head2 version

Returns the version of the release.

=head2 criteria

Returns a hashref with the coverage stats for the release.
Will contain one or more of the following keys:
'branch', 'condition', 'statement', 'subroutine', 'total'
