use strict;
use warnings;
package MetaCPAN::API::Rating;
# ABSTRACT: Rating information for MetaCPAN::API

use Carp;
use Any::Moose 'Role';

# /rating/{id}
# /rating/_search
sub rating {
    my $self  = shift;
    my $url   = '';
    my $error = "Either provide 'id' or 'search'";

    my %extra_opts = ();

    if ( @_ == 1 ) {
        $url = 'rating/' . shift;
    } elsif ( @_ ) {
        my %opts = @_;

        if ( defined ( my $id = $opts{'id'} ) ) {
            $url = "rating/$id";
        } elsif ( defined ( my $search_opts = $opts{'search'} ) ) {
            ref $search_opts && ref $search_opts eq 'HASH'
                or croak $error;

            %extra_opts = %{$search_opts};
            $url        = 'rating/_search';
        } else {
            croak $error;
        }
    } else {
        croak $error;
    }

    return $self->fetch( $url, %extra_opts );
}

1;

__END__

=head1 DESCRIPTION

This role provides MetaCPAN::API with fetching information about CPAN
ratings.

=head1 METHODS

=head2 rating

    my $result = $mcpan->rating( id => 'UC6tqabqR-y3xxZk0tgVXQ' );

Searches MetaCPAN for CPAN ratings.  

You can do complex searches using 'search' parameter:
    
    my $result = $mcpan->rating(
        search => {
            filter => "distribution:Moose",
            fields => [ "date", "rating" ],
        },
    );

These searches will give you the right _id to use for more detailed
information.