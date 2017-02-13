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

=head1 SYNOPSIS

    my $mirror = $mcpan->mirror('eutelia.it');

=head1 DESCRIPTION

A MetaCPAN mirror entity object.

=head1 ATTRIBUTES

=head2 name

The name of the mirror, which is what you passed

=head2 org

The organization that maintains the mirror.

=head2 ftp

An FTP url for the mirror.

=head2 rsync

An rsync url for the mirror.

=head2 src

=head2 city

The city where the mirror is located.

=head2 country

The name of the country where the mirror is located.

=head2 ccode

The ISO country code for the mirror's country.

=head2 aka_name

=head2 tz

=head2 note

=head2 dnsrr

=head2 region

=head2 inceptdate

=head2 freq

=head2 continent

=head2 http

=head2 reitredate

=head2 A_or_CNAME

=head2 contact

Array-Ref.

=head2 location

Array-Ref.
