use strict;
use warnings;
package MetaCPAN::Client::Author;
# ABSTRACT: An Author data object

use Moo;
use Ref::Util qw< is_arrayref >;

with 'MetaCPAN::Client::Role::Entity';

my %known_fields = (
    scalar => [qw<
        city
        country
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

sub BUILDARGS {
    my ( $class, %args ) = @_;

    my $email = $args{'email'} || [];
    $args{'email'} = [ $email ]
        unless is_arrayref($email);

    return \%args;
}

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

sub dir { $_[0]->links->{cpan_directory} }

sub metacpan_url { "https://metacpan.org/author/" . $_[0]->pauseid }

1;

__END__

=head1 SYNOPSIS

    my $author = $mcpan->author('MICKEY');

=head1 DESCRIPTION

a MetaCPAN author entity object.

=head1 ATTRIBUTES

=head2 pauseid

The author's pause id, which is a string like C<MICKEY> or C<XSAWYERX>.

=head2 name

The author's full name, if they've provided this in their MetaCPAN
profile. This may contain Unicode characters.

=head2 ascii_name

An ASCII-only version of the author's full name, if they've provided this in
their MetaCPAN profile.

=head2 city

The author's city, if they've provided this in their MetaCPAN profile.

=head2 region

The author's region, if they've provided this in their MetaCPAN profile.

=head2 country

The author's country, if they've provided this in their MetaCPAN profile.

=head2 updated

An ISO8601 datetime string like C<2016-11-19T12:41:46> indicating when the
author last updated their MetaCPAN profile. This is always provided in UTC.

=head2 dir

The author's CPAN directory, which is something like C<id/P/PE/PERLER>.

=head2 gravatar_url

The author's gravatar.com user URL, if they have one. This URL is generated
using PAUSEID@cpan.org.

=head2 user

The user's internal MetaCPAN id.

=head2 donation

This is an arrayref containing zero or more hashrefs. Each hashref contains
two keys, C<name> and C<id>. The known names are currently C<paypal>,
C<wishlist>, and C<flattr>. The id will be an appropriate id or URL for the
thing in question.

This may be empty if the author has not provided this information in their
MetaCPAN profile.

For example:

    [
        { "name" => "paypal",   "id" => "brian.d.foy@gmail.com" },
        { "name" => "wishlist", "id" => "http://amzn.com/w/4O7IX9ZNQJR" },
    ],

=head2 email

This is an arrayref containing zero or more email addresses that the author
has added to their MetaCPAN profile. Note that this does I<not> include the
C<AUTHOR@cpan.org> email address that all CPAN authors have.

=head2 website

This is an arrayref of website URLs provided by the author in their MetaCPAN
profile.

=head2 profile

This is an arrayref containing zero or more hashrefs. Each hashref contains
two keys, C<name> and C<id>. The names are things like C<github> or
C<stackoverflow>. The id will be an appropriate id for the site in question.

For example:

    [
        { name => "amazon",        id => "B002MRC39U"  },
        { name => "stackoverflow", id => "brian-d-foy" },
    ]

This may be empty if the author has not provided this information in their
MetaCPAN profile.

=head2 perlmongers

This is an arrayref containing zero or more hashrefs. Each hashref contains
two keys, C<name> and C<url>. The names are things like C<Minneapolis.pm>.

This may be empty if the author has not provided this information in their
MetaCPAN profile.

=head2 links

This is a hashref where the keys are a link type, and the values are URLs. The
currently known keys are:

=over 4

=item * cpan_directory

The author's CPAN directory.

=item * backpan_directory

The author's BackCPAN directory.

=item * cpantesters_reports

The author's CPAN Testers Reports page.

=item * cpantesters_matrix

The author's CPAN Testers matrix page.

=item * cpants

The author's CPANTS page.

=item * metacpan_explorer

A link to the MetaCPAN explorer site pre-populated with a request for the
author's profile.

=back

=head2 blog

This is an arrayref containing zer or more hashrefs. Each hashref contains two
keys, C<url> and C<feed>. For example:

    {
        url  => "http://blogs.perl.org/users/brian_d_foy/",
        feed => "http://blogs.perl.org/users/brian_d_foy/atom.xml",
    }

=head2 release_count

This is a hashref containing counts for various types of releases. The known
keys are:

=over 4

=item * cpan

The total number of distribution uplaods the author currently has on CPAN.

=item * latest

The total number of unique distributions the author currently has on CPAN.

=item * backpan-only

The number of distribution uploads currently only available via BackPAN.

=back

=head2 extra

Returns a hashref. The contents of this are entirely arbitrary and will vary
by author.

=head1 METHODS

=head2 BUILDARGS

Ensures format of the input.

=head2 releases

    my $releases = $author->releases();

This method returns a L<MetaCPAN::Client::ResultSet> of
L<MetaCPAN::Client::Release> objects. It includes all of the author's releases
with the C<latest> status.

=head2 metacpan_url

Returns a link to the author's page on MetaCPAN.
