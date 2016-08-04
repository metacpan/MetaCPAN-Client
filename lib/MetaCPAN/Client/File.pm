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

1;

__END__

=head1 DESCRIPTION

A MetaCPAN file entity object.

=head1 ATTRIBUTES

=head2 status

=head2 date

=head2 author

=head2 maturity

=head2 directory

=head2 indexed

=head2 documentation

=head2 id

=head2 authorized

=head2 version

=head2 binary

=head2 name

=head2 version_numified

=head2 release

=head2 path

=head2 description

=head2 distribution

=head2 level

=head2 sloc

=head2 abstract

=head2 slop

=head2 mime

=head2 module

Array-Ref.

=head2 pod_lines

Array-Ref.

=head2 stat

Hash-Ref.

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
