package MetaCPAN::API::Favorite;
# ABSTRACT: A Favorite data object

use Moo;

my @known_fields = qw<date user release id author distribution>;

foreach my $field (@known_fields) {
    has $field => (
        is      => 'ro',        
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

1;

__END__

=head1 DESCRIPTION


=head1 ATTRIBUTES

