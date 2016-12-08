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

my %__known_fields_ex = (
    map { my $k = $_; $k => +{ map { $_ => 1 } @{ $known_fields{$k} } } }
    keys %known_fields
);

my @known_fields = map { @{ $known_fields{$_} } } keys %known_fields;

foreach my $field ( @known_fields ) {
    has $field => (
        is      => 'ro',
        lazy    => 1,
        default => sub {
            my $self = shift;
            return (
                exists $self->data->{$field}                ? $self->data->{$field} :
                exists $__known_fields_ex{hashref}{$field}  ? {} :
                exists $__known_fields_ex{arrayref}{$field} ? [] :
                exists $__known_fields_ex{scalar}{$field}   ? '' :
                undef
            );
        },
    );
}

sub _known_fields { return \%known_fields }

sub rt     { $_[0]->bugs->{rt}     || {} }
sub github { $_[0]->bugs->{github} || {} }

1;

__END__

=head1 SYNOPSIS

my $dist = $mcpan->distribution('MetaCPAN-Client');

=head1 DESCRIPTION

A MetaCPAN distribution entity object.

=head1 ATTRIBUTES

=head2 name

=head2 bugs

Hash-Ref.

=head2 river

Hash-Ref.

=head1 METHODS

=head2 rt

Returns 'bugs.rt' hash ref (defaults to {}).

=head2 github

Returns 'bugs.github' hash ref (defaults to {}).
