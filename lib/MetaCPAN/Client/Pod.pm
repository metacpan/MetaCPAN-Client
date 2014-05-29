use strict;
use warnings;
package MetaCPAN::Client::Pod;
# ABSTRACT: A Pod object

use Moo;

has name => ( is => 'ro', required => 1 );

my @known_formats = qw<
    html plain x_pod x_markdown
>;

foreach my $format (@known_formats) {
    has $format => (
        is      => 'ro',
        lazy    => 1,
        default => sub {
            my $self = shift;
            return $self->_request( $format );
        },
    );
}

sub _request {
    my $self   = shift;
    my $ctype  = shift || "plain";

    $ctype =~ s/_/-/;

    my $name = $self->name;

    require MetaCPAN::Client::Request;

    return
        MetaCPAN::Client::Request->new->fetch(
            "pod/${name}?content-type=text/${ctype}"
        );
}


1;

__END__

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 status

=head2 date

=head2 author

=head2 maturity

=head2 directory

=head2 indexed

=head2 documentation

=head2 id

=head2 module

=head2 authorized

=head2 pod_lines

=head2 version

=head2 binary

=head2 name

=head2 version_numified

=head2 release

=head2 path

=head2 description

=head2 stat

=head2 distribution

=head2 level

=head2 sloc

=head2 abstract

=head2 slop

=head2 mime

=head1 METHODS

=head2 pod

    my $pod = $module->pod(); # default = plain
    my $pod = $module->pod($type);

Returns the POD content for the module/file.

Takes a type as argument.

Supported types: B<plain>, B<html>, B<x-pod>, B<x-markdown>.
