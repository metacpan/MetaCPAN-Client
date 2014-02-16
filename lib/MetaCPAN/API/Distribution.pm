package MetaCPAN::API::Distribution;
# ABSTRACT: A Distribution data object

use Moo;

with 'MetaCPAN::API::Role::Entity';

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

sub _known_fields { return \@known_fields }


1;

__END__

=head1 DESCRIPTION

    my $dist = $mcpan->distribution('MetaCPAN-API');

This represents a MetaCPAN distribution entity.

=head1 ATTRIBUTES

=head2 name

Distribution's name.

=head2 bugs

Distribution's bug information.

