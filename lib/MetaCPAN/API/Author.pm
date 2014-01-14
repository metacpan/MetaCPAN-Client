package MetaCPAN::API::Author;
# ABSTRACT: An Author data object

use Moo;

with 'MetaCPAN::API::Role::Entity';

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

sub _known_fields { return \@known_fields }

1;

__END__

=head1 DESCRIPTION


=head1 ATTRIBUTES

