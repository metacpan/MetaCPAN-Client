package MetaCPAN::API::ResultSet;
# ABSTRACT: A Result Set

use Moo;

has hits => (
    is       => 'ro',
    required => 1,
);

has facets => (
    is   => 'ro',
    lazy => 1,
);

sub first {}
sub next {}
sub all {}

1;

__END__

=head1 DESCRIPTION


=head1 ATTRIBUTES

