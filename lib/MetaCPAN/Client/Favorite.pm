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

    # Query favorites for a given distribution:

    my $favorites = $mcpan->favorite( {
        distribution => 'Moose'
    } );


    # Total number of matches ("how many favorites does the dist have?"):

    print $favorites->total;


    # Iterate over the favorite matches

    while ( my $fav = $favorites->next ) { ... }


=head1 DESCRIPTION

A MetaCPAN favorite entity object.

=head1 ATTRIBUTES

=head2 date

An ISO8601 datetime string like C<2016-11-19T12:41:46> indicating when the
favorite was created.

=head2 user

The user ID (B<not> PAUSE ID) of the person who favorited the thing in
question.

=head2 release

The release that was favorited.

=head2 id

The favorite ID.

=head2 author

The PAUSE ID of the author whose release was favorited.

=head2 distribution

The distribution that was favorited.
