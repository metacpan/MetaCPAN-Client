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
                                   file module rating release>;
    },
    required => 1,
);

# in case we're returning from a scrolled search
has scroller => (
    is       => 'ro',
    isa      => sub {
        ref $_[0] eq 'Search::Elasticsearch::Scroll'
            or croak 'scroller must be an Search::Elasticsearch::Scroll object';
    },
    required => 0,
);

# in case we're returning from a fetch
has list => (
    is       => 'ro',
    isa      => sub {
        ref $_[0] eq 'ARRAY'
            or croak 'list must be an array ref';
    },
    required => 0,
);

has total => (
    is      => 'ro',
    default => 0,
);

has facets => (
    is      => 'ro',
    lazy    => 1,
    builder => '_get_facets',
);

sub _get_facets {
    my $self = shift;

    return $self->scroller->facets || {};
}

sub BUILDARGS {
    my ( $class, %args ) = @_;

    exists $args{scroller} or exists $args{list}
        or croak "wrong args to ResultSet";

    $args{total} = exists $args{scroller}
        ? $args{scroller}->total
        : scalar(@{ $args{list} });

    return \%args;
}


sub _total {
    my $self = shift;

    ref $self->scroller and return $self->scroller->total;

    return scalar(@{ $self->list });
}

sub next {
    my $self = shift;
    my $result;

    # list:
    if ( ref $self->list ) {
        scalar @{ $self->list } > 0
            or return;

        $result = shift @{ $self->list };

    } else {
        $result = $self->scroller->next;
    }

    defined $result
        or return;

    my $class = 'MetaCPAN::Client::' . ucfirst $self->type;

    return $class->new_from_request( $result->{'_source'} || $result->{'fields'} );
}


1;

__END__

=head1 DESCRIPTION

Object representing a result from Elastic Search. This is used for the complex
(as in non-simple) queries to MetaCPAN. It provides easy access to the scroller
and facets.

=head1 ATTRIBUTES

=head2 scroller

An L<Search::Elasticsearch::Scroll> object

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

