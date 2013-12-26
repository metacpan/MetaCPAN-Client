package MetaCPAN::API::Author;
# ABSTRACT: An Author data object

use Moo;

my @known_fields = qw<
    blog city country dir email gravatar_url name
    pauseid profile updated user website
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

has data => (
    is       => 'ro',
    required => 1,
);

sub known_fields { return \@known_fields }

1;

__END__

=head1 DESCRIPTION


=head1 ATTRIBUTES

