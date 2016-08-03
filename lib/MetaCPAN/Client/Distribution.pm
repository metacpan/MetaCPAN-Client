use strict;
use warnings;
package MetaCPAN::Client::Distribution;
# ABSTRACT: A Distribution data object

use Moo;

with 'MetaCPAN::Client::Role::Entity';

my %known_fields = (
    scalar   => [qw< name >],
    arrayref => [],
    hashref  => [qw< bugs river >]
);

my @known_fields =
    map { @{ $known_fields{$_} } } qw< scalar arrayref hashref >;

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

sub _known_fields { return \%known_fields }

1;

__END__

=head1 DESCRIPTION

    my $dist = $mcpan->distribution('MetaCPAN-Client');

This represents a MetaCPAN distribution entity.

=head1 ATTRIBUTES

=head2 name

Distribution's name.

=head2 bugs

Distribution's bug information.

=head2 river

Distribution's river information.
