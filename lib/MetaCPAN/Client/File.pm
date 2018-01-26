use strict;
use warnings;
package MetaCPAN::Client::File;
# ABSTRACT: A File data object

use Moo;
use Carp;

with 'MetaCPAN::Client::Role::Entity';

my %known_fields = (
    scalar => [qw<
        abstract
        author
        authorized
        binary
        date
        deprecated
        description
        directory
        distribution
        documentation
        download_url
        id
        indexed
        level
        maturity
        mime
        name
        path
        release
        sloc
        slop
        status
        version
        version_numified
    >],

    arrayref => [qw< module pod_lines >],

    hashref  => [qw< stat >],
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

sub pod {
    my $self   = shift;
    my $ctype  = shift || "plain";
    $ctype = lc($ctype);

    grep { $ctype eq $_ } qw<html plain x-pod x-markdown>
        or croak "wrong content-type for POD requested";

    my $name = $self->module->[0]{name};
    return unless $name;

    require MetaCPAN::Client::Request;

    return
        MetaCPAN::Client::Request->new->fetch(
            "pod/${name}?content-type=text/${ctype}"
        );
}

sub source {
    my $self = shift;

    my $author  = $self->author;
    my $release = $self->release;
    my $path    = $self->path;

    require MetaCPAN::Client::Request;

    return
        MetaCPAN::Client::Request->new->fetch(
            "source/${author}/${release}/${path}"
        );
}

sub metacpan_url {
    my $self = shift;
    sprintf("https://metacpan.org/source/%s/%s/%s",
            $self->author, $self->release, $self->path );
}

1;

__END__

=head1 DESCRIPTION

A MetaCPAN file entity object.

=head1 ATTRIBUTES

=head2 status

Returns a release status like C<backpan>, C<cpan>, or C<latest>.

=head2 date

An ISO8601 datetime string like C<2016-11-19T12:41:46> indicating when the
file was uploaded.

=head2 author

The author's PAUSE id.

=head2 maturity

This will be either C<release> or C<developer>.

=head2 directory

A boolean indicating whether or not the path represents a directory.

=head2 indexed

A boolean indicating whether or not the content is indexed.

=head2 documentation

The name of the module for which this file contains docs. This may be C<undef>

=head2 id

The file's internal MetaCPAN id.

=head2 authorized

A boolean indicating whether or not this file was part of an authorized
upload.

=head2 version

The distribution version that contains this file.

=head2 version_numified

The numified version of the distribution that contains the file.

=head2 release

The release that contains this file, which will be something like
C<Moose-2.2004>.

=head2 binary

A boolean indicating whether or not this file contains binary content.

=head2 name

The File's name, without any directory path included.

=head2 path

The file's path I<within the distribution archive>, relative to the root of
the archive.

=head2 abstract

If the file contains POD with a C<NAME> section, then this attribute will
include the abstract portion of the name.

=head2 deprecated

The deprecated field value for this file.

=head2 description

If the file contains POD with a C<DESCRIPTION> section, then this attribute
will contain that description.

=head2 distribution

The name of the distribution that contains the file.

=head2 level

A 0-indexed indication of how many directories deep this file is, relative to
the archive root.

=head2 sloc

If the file contains code, this will contain the number of lines of code in
the file.

=head2 slop

If the file contains POD, this will contain the number of lines of POD in
the file.

=head2 mime

The file's mime type.

=head2 module

If the file contains module indexed by PAUSE, then this attribute contains an
arrayref of hashrefs, one for each module. The hashrefs have the following
keys:

=over 4

=item * name

The module name.

=item * indexed

Whether or not the file is indexed by MetaCPAN.

=item * authorized

Whether or not the module is part of an authorized upload.

=item * version

The version of the module that this file contains.

=item * version_numified

The numified version of the module that this file contains.

=item * associated_pod

A path you can use with the C<< MetaCPAN::Client->file >> method to get the
file that contains POD for this module. In most cases, that will be the same
file as that one that contains this C<module> data.

=back

=head2 pod_lines

An arrayref.

=head2 stat

A hashref containing C<stat()> all information about the file. The keys are:

=over 4

=item * mtime

The Unix epoch of the file's last modified time.

=item * mode

The file's mode (as an integer, not an octal representation).

=item * size

The file's size in bytes.

=back

=head2 download_url

A URL for the distribution archive that contains this file.

=head1 METHODS

=head2 pod

    my $pod = $module->pod(); # default = plain
    my $pod = $module->pod($type);

Returns the POD content for the module/file.

Takes a type as argument.

Supported types: B<plain>, B<html>, B<x-pod>, B<x-markdown>.

=head2 source

    my $source = $module->source();

Returns the source code for the file.

=head2 metacpan_url

Returns a link to the file source page on MetaCPAN.
