use strict;
use warnings;
package MetaCPAN::API::Autocomplete;
# ABSTRACT: Autocompletion info for MetaCPAN::API

use Carp;
use Any::Moose 'Role';

# /search/autocomplete?q={search}
sub autocomplete {
    my $self  = shift;
    my %opts  = @_ ? @_ : ();
    my $url   = '';

    my $error      = "You have to provide a search term";
    my $size_error = "The size has to be between 0 and 100";

    %opts or croak $error;
    $opts{search} && ref $opts{search} eq 'HASH' or croak $error;

    my %extra_opts;

    if ( defined ( my $term = $opts{search}->{query} ) ) {
        $url           = 'search/autocomplete';
        $extra_opts{q} = $term;

        my $size = $opts{search}->{size};
        if ( defined $size && $size >= 0 && $size <= 100 ) {
            $extra_opts{size} = $size;
        } else {
            croak $size_error;
        }
    } else {
        croak $error;
    }

    return $self->fetch( $url, %extra_opts );
}

1;

__END__

=head1 DESCRIPTION

This role provides MetaCPAN::API with fetching autocomplete information 

=head1 METHODS

=head2 autocomplete

    my $result = $mcpan->autocomplete( 
        search => {
            query => 'Moose',
        },
    );

By default, you get 20 results (at maximum). If you need more, you
can also pass C<size>:

    my $result = $mcpan->autocomplete( 
        search => {
            query => 'Moose',
            size  => 30,
        },
    );

There is a hardcoded limit of 100 results (hardcoded in MetaCPAN).

Searches MetaCPAN for autocompletion info.

