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
        pauseid
        region
        updated
        user
    >],

    arrayref => [qw<
        donation
        email
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

=head1 DESCRIPTION

    my $author = $mcpan->author('MICKEY');

This represents a MetaCPAN author entity.

=head1 ATTRIBUTES

=head2 name

Author name.

=head2 pauseid

Author PAUSE ID.

=head2 email

Author's Emails (array-ref)

=head2 blog

Author's blog info (hash-ref)

Example:

    {
        url  => "http://blogs.perl.org/users/brian_d_foy/"
        feed => "http://blogs.perl.org/users/brian_d_foy/atom.xml",
    }

=head2 city

Author's city.

=head2 country

Author's country.

=head2 region

Author's region.

=head2 dir

Author's directory of distribution and files.

Example: C<< id/P/PE/PERLER >>

=head2 gravatar_url

Author's Gravatar.com user picture URL. This URL is generated using
PAUSEID@cpan.org.

=head2 profile

Author's user profiles (array-ref).

Example:

    [
        { name => "amazon",        id => "B002MRC39U"  },
        { name => "stackoverflow", id => "brian-d-foy" },
    ]

=head2 website

Author's websites (array-ref).

=head2 release_count

Author's release counts (hash-ref).

Example:
   {
      latest       => 118,
      backpan-only => 558,
      cpan         => 18,
   }

=head2 updated

timestamp.

=head2 links

hash-ref.

=head2 extra

hahs-ref.

=head2 donation

array-ref.

=head2 user

identification code.

=head1 METHODS

=head2 releases

    my $releases = $author->releases();

Search all releases of current author's object.
will return a ResultSet of MetaCPAN::Client::Release objects.
