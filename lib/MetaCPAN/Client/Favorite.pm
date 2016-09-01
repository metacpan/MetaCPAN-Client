use strict;
use warnings;
package MetaCPAN::Client::Favorite;
# ABSTRACT: A Favorite data object

use Moo;

with 'MetaCPAN::Client::Role::Entity';

my %known_fields = (
    scalar   => [qw< date user release id author distribution >],
    arrayref => [],
    hashref  => []
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

my $favorite = $mcpan->favorite( {
    distribution => 'Moose'
} );

=head1 DESCRIPTION

A MetaCPAN favorite entity object.

=head1 ATTRIBUTES

=head2 date

Date of the favorite.

=head2 user

The user ID (B<not> PAUSE ID) of who favorited.

=head2 release

The release that was favorited.

=head2 id

The favorite ID.

=head2 author

The PAUSE ID of the author whose release was favorited.

=head2 distribution

The distribution that was favorited.
