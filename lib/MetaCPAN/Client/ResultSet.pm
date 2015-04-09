use strict;
use warnings;
package MetaCPAN::Client::ResultSet;
# ABSTRACT: A Result Set

use Moo;
use Carp;

has type => (
    is       => 'ro',
    isa      => sub {
        croak 'Invalid type' unless
            grep { $_ eq $_[0] } qw<author distribution favorite
                                   file module rating release mirror>;
    },
    required => 1,
);

# in case we're returning from a scrolled search
has scroller => (
    is        => 'ro',
    isa       => sub {
        use Safe::Isa;
        $_[0]->$_isa('Search::Elasticsearch::Scroll')
            or croak 'scroller must be an Search::Elasticsearch::Scroll object';
    },
    predicate => 'has_scroller',
);

# in case we're returning from a fetch
has items => (
    is  => 'ro',
    isa => sub {
        ref $_[0] eq 'ARRAY'
            or croak 'items must be an array ref';
    },
);

has total => (
    is      => 'ro',
    default => sub {
        my $self = shift;

        return $self->has_scroller ? $self->scroller->total
                                   : scalar @{ $self->items };
    },
);

sub BUILDARGS {
    my ( $class, %args ) = @_;

    exists $args{scroller} or exists $args{items}
        or croak 'ResultSet must get either scroller or items';

    exists $args{scroller} and exists $args{items}
        and croak 'ResultSet must get either scroller or items, not both';

    return \%args;
}

sub next {
    my $self   = shift;
    my $result = $self->has_scroller ? $self->scroller->next
                                     : shift @{ $self->items };

    defined $result or return;

    my $class = 'MetaCPAN::Client::' . ucfirst $self->type;
    return $class->new_from_request( $result->{'_source'} || $result->{'fields'} );
}

sub facets {
    my $self = shift;

    return $self->has_scroller ? $self->scroller->facets : {};
}

1;

__END__

=head1 DESCRIPTION

Object representing a result from Elastic Search. This is used for the complex
(as in L<non-simple/MetaCPAN::Client/"SEARCH SPEC">) queries to MetaCPAN. It
provides easy access to the scroller and facets.

=head1 ATTRIBUTES

=head2 scroller

An L<Search::Elasticsearch::Scroll> object.

=head2 items

An arrayref of items to manually scroll over, instead of a scroller object.

=head2 type

The entity of the result set. Available types:

=over 4

=item * author

=item * distribution

=item * module

=item * release

=item * favorite

=item * file

=back

=head2 facets

The facets available in the Elastic Search response.

=head1 METHODS

=head2 next

Iterator call to fetch the next result set object.

=head2 total

Iterator call to fetch the total amount of objects available in result set.

=head2 has_scroller

Predicate for ES scroller presence.

=head2 BUILDARGS

Double checks construction of objects. You should never run this yourself.
