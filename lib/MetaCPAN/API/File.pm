package MetaCPAN::API::File;
# ABSTRACT: A File data object

use Moo;

my @known_fields = qw<
    pod status date author maturity directory indexed documentation id
    module authorized pod_lines version binary name version_numified release
    path description stat distribution level sloc abstract slop mime
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

