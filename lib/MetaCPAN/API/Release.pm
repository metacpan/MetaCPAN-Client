package MetaCPAN::API::Release;
# ABSTRACT: A Release data object

use Moo;

my @known_fields = qw<
    resources status date author maturity dependency id authorized
    download_url first archive version name version_numified license
    distribution stat provides tests abstract
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

