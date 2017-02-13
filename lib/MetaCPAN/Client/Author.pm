use strict;
use warnings;
package MetaCPAN::Client::Author;
# ABSTRACT: An Author data object

use Moo;

with 'MetaCPAN::Client::Role::Entity';

my %known_fields = (
    scalar => [qw<
        city
        country
        dir
        gravatar_url
        name
        ascii_name
        pauseid
        region
        updated
        user
    >],

    arrayref => [qw<
        donation
        email
        perlmongers
        profile
        website
    >],

    hashref => [qw<
        blog
        extra
        links
        release_count
    >],
);

my @known_fields =
    map { @{ $known_fields{$_} } } qw< scalar arrayref hashref >;

foreach my $field ( @known_fields ) {
    has $field => (
        is      => 'ro',
        lazy    => 1,
        default => sub {
            my $self = shift;
            return $self->data->{$field};
        },
    );
}

sub _known_fields { \%known_fields }

sub releases {
    my $self = shift;
    my $id   = $self->pauseid;

    return $self->client->release({
            all => [
                { author => $id      },
                { status => 'latest' },
            ]
        });
}

1;

__END__

=head1 SYNOPSIS

my $author = $mcpan->author('MICKEY');

=head1 DESCRIPTION

a MetaCPAN author entity object.

=head1 ATTRIBUTES

=head2 pauseid

=head2 name

=head2 ascii_name

=head2 city

=head2 country

=head2 region

=head2 updated

=head2 dir

Directory of distribution and files.

e.g. C<< id/P/PE/PERLER >>

=head2 gravatar_url

Gravatar.com user picture URL.

This URL is generated using PAUSEID@cpan.org.

=head2 user

Identification code.

=head2 donation

Array-Ref.

=head2 email

Array-Ref.

=head2 website

Array-Ref.

=head2 profile

Array-Ref.

e.g.
    [
        { name => "amazon",        id => "B002MRC39U"  },
        { name => "stackoverflow", id => "brian-d-foy" },
    ]

=head2 perlmongers

Array-Ref.

=head2 links

Hash-Ref.

=head2 extra

Hash-Ref.

=head2 blog

Hash-Ref.

  {
    url  => "http://blogs.perl.org/users/brian_d_foy/"
    feed => "http://blogs.perl.org/users/brian_d_foy/atom.xml",
  }

=head2 release_count

Hash-Ref.

e.g.
   {
      latest       => 118,
      backpan-only => 558,
      cpan         => 18,
   }

=head1 METHODS

=head2 releases

    my $releases = $author->releases();

Search all releases of current author's object.
will return a ResultSet of MetaCPAN::Client::Release objects.
