package MetaCPAN::API::Author;
# ABSTRACT: An Author data object

use Moo;

my @known_fields = qw<
    profile country website gravatar_url name blog
    dir email city user updated pauseid
>;

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

