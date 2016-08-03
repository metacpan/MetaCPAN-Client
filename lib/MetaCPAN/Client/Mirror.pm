use strict;
use warnings;
package MetaCPAN::Client::Mirror;
# ABSTRACT: A Mirror data object

use Moo;
use Carp;

with 'MetaCPAN::Client::Role::Entity';

my %known_fields = (
    scalar => [qw<
        aka_name
        A_or_CNAME
        ccode
        city
        continent
        country
        dnsrr
        freq
        ftp
        http
        inceptdate
        name
        note
        org
        region
        reitredate
        rsync
        src
        tz
    >],

    arrayref => [qw< contact location >],

    hashref  => [qw<>],
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

=head1
DESCRIPTION

=head1
ATTRIBUTES

=head2 name

=head2 org

=head2 ftp

=head2 contact

=head2 city

=head2 rsync

=head2 src

=head2 ccode

=head2 aka_name

=head2 tz

=head2 note

=head2 dnsrr

=head2 region

=head2 inceptdate

=head2 country

=head2 location

=head2 freq

=head2 continent

=head2 http

=head2 reitredate

=head2 A_or_CNAME

=head1 METHODS
