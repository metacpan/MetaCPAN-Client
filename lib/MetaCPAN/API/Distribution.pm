package MetaCPAN::API::Distribution;
# ABSTRACT: A Distribution data object

use Moo;

my @known_fields = qw<name bugs>;

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

