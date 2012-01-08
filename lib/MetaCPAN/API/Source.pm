use strict;
use warnings;
package MetaCPAN::API::Source;
# ABSTRACT: Source information for MetaCPAN::API

use Carp;
use Any::Moose 'Role';

# /source/{author}/{release}/{path}
sub source {
    my $self  = shift;
    my %opts  = @_ ? @_ : ();
    my $url   = '';
    my $error = "Provide 'author' and 'release' and 'path'";

    %opts or croak $error;

    if (
        defined ( my $author  = $opts{'author'}  ) &&
        defined ( my $release = $opts{'release'} ) &&
        defined ( my $path    = $opts{'path'}    )
      ) {
        $url = "source/$author/$release/$path";
    } else {
        croak $error;
    }

    $url = $self->base_url . "/$url";

    my $result = $self->ua->get($url);
    $result->{'success'}
        or croak "Failed to fetch '$url': " . $result->{'reason'};

    return $result->{'content'};
}

1;

__END__

=head1 DESCRIPTION

This role provides MetaCPAN::API with fetching of source files.

=head1 METHODS

=head2 source

    my $source = $mcpan->source(
        author  => 'DOY',
        release => 'Moose-2.0201',
        path    => 'lib/Moose.pm',
    );

Searches MetaCPAN for a module or a specific release and returns the plain
source.

=head1 AUTHOR

  Renee Baecker <module@renee-baecker.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Renee Baecker.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

