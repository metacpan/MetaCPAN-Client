package MetaCPAN::Client::Rating;
# ABSTRACT: A Rating data object

use Moo;

with 'MetaCPAN::Client::Role::Entity';

my @known_fields = qw<
    date release author details
    rating distribution helpful user
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

=head2 date

=head2 release

=head2 author

=head2 details

=head2 rating

=head2 distribution

=head2 helpful

=head2 user

