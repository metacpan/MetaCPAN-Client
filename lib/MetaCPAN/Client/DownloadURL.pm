use strict;
use warnings;
package MetaCPAN::Client::DownloadURL;
# ABSTRACT: A Rating data object

use Moo;

with 'MetaCPAN::Client::Role::Entity';

my @known_fields = qw<
    date download_url status version
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

=head2 date

=head2 download_url

=head2 status

=head2 version
