use strict;
use warnings;
package MetaCPAN::Client::Author;
# ABSTRACT: An Author data object

use Moo;

with 'MetaCPAN::Client::Role::Entity';

my @known_fields = qw<
    blog city country dir email gravatar_url links name
    pauseid profile release_count updated user website
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

Author's Email.

=head2 blog

Array of author's blog addresses.

Example:

    [
        {
            url  => "http://blogs.perl.org/users/brian_d_foy/"
            feed => "http://blogs.perl.org/users/brian_d_foy/atom.xml",
        }
    ]

=head2 city

Author's city.

=head2 country

Author's country.

=head2 dir

Author's directory of distribution and files.

Example: C<< id/P/PE/PERLER >>

=head2 gravatar_url

Author's Gravatar.com user picture URL. This URL is generated using
PAUSEID@cpan.org.

=head2 profile

Array of author's user profiles.

Example:

    [
        { name => "amazon",        id => "B002MRC39U"  },
        { name => "stackoverflow", id => "brian-d-foy" },
    ]

=head2 website

Array of Author's websites.

=head2 updated

=head2 user

=head1 METHODS

=head2 releases

    my $releases = $author->releases();

Search all releases of current author's object.
will return a ResultSet of MetaCPAN::Client::Release objects.
