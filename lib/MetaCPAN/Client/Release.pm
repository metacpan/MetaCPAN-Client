use strict;
use warnings;
package MetaCPAN::Client::Release;
# ABSTRACT: A Release data object

use Moo;
use Ref::Util qw< is_hashref >;
use JSON::MaybeXS qw< decode_json >;

with 'MetaCPAN::Client::Role::Entity',
     'MetaCPAN::Client::Role::HasUA';

my %known_fields = (
    scalar => [qw<
        abstract
        archive
        author
        authorized
        date
        deprecated
        distribution
        download_url
        first
        id
        maturity
        main_module
        name
        status
        version
        version_numified
    >],

    arrayref => [qw<
        dependency
        license
        provides
    >],

    hashref => [qw<
        metadata
        resources
        stat
        tests
    >],
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

sub changes {
    my $self = shift;
    my $url  = sprintf "https://fastapi.metacpan.org/changes/%s/%s", $self->author, $self->name;
    my $res = $self->ua->get($url);
    return unless is_hashref($res);
    my $content = decode_json $res->{'content'};
    return $content->{'content'};
}

sub metacpan_url {
    my $self = shift;
    sprintf( "https://metacpan.org/release/%s/%s", $self->author, $self->name )
}

sub contributors {
    my $self = shift;
    my $url = sprintf( "https://fastapi.metacpan.org/release/contributors/%s/%s", $self->author, $self->name );
    my $res = $self->ua->get($url);
    return unless is_hashref($res);
    my $content = decode_json $res->{'content'};
    return $content->{'contributors'};
}

1;

__END__

=head1 SYNOPSIS

my $release = $mcpan->release('Moose');

=head1 DESCRIPTION

A MetaCPAN release entity object.

=head1 ATTRIBUTES

=head2 status

The release's status, C<latest>, C<cpan>, or C<backpan>.

=head2 name

The release's name, something like C<Moose-1.23>.

=head2 date

An ISO8601 datetime string like C<2016-11-19T12:41:46> indicating when the
release was uploaded.

=head2 author

The PAUSE ID of the author who uploaded the release.

=head2 maturity

This will be either C<released> or C<developer>.

=head2 main_module

The release's main module name.

=head2 id

The release's internal MetaCPAN id.

=head2 authorized

A boolean indicating whether or not this was an authorized release.

=head2 download_url

A URL for this release's distribution archive file.

=head2 first

A boolean indicating whether or not this is the first release of this
distribution.

=head2 archive

The filename of the archive file for this release.

=head2 version

The release's version.

=head2 version_numified

The numified form of the release's version.

=head2 deprecated

The deprecated field value for this release.

=head2 distribution

The name of the distribution to which this release belongs. Something like C<Moose>

=head2 abstract

The abstract from this release's metadata.

=head2 dependency

This is an arrayref of hashrefs. Each hashref contains the following keys:

=over 4

=item * phase

The phase to which this dependency belongs. This will be one of C<configure>,
C<build>, C<runtime>, C<test>, or C<develop>.

=item * relationship

This will be one of C<requires>, C<recommends>, or C<suggests>.

=item * module

The name of the module which is depended on.

=item * version

The required version of the dependency. This may be C<0>, indicating that any
version is acceptable.

=back

=head2 license

An arrayref containing the license(s) under which this release has been made
available. These licenses are represented by strings like C<perl_5> or
C<gpl2>.

=head2 provides

This an arrayref containing a list of all the modules provided by this distribution.

=head2 metadata

This is a hashref containing metadata provided by the distribution. The exact
contents of this hashref will vary across CPAN, but should largely conform to
the spec defined by L<CPAN::Meta::Spec>.

=head2 resources

The resources portion of the release's metadata, returned as a hashref.

=head2 stat

A hashref containing C<stat()> all information about the release's archive
file. The keys are:

=over 4

=item * mtime

The Unix epoch of the file's last modified time.

=item * mode

The file's mode (as an integer, not an octal representation).

=item * size

The file's size in bytes.

=back

=head2 tests

Returns a hashref of information about CPAN testers results for this
release. The keys are C<pass>, C<fail>, C<unknown>, and C<na>. The values are
the count of that particular result on CPAN Testers for this release.

=head1 METHODS

=head2 changes

Returns the Changes text for the release.

=head2 metacpan_url

Returns a link to the release page on MetaCPAN.

=head2 contributors

Returns a structure with release contributors info.
