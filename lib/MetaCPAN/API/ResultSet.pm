package MetaCPAN::API::ResultSet;
# ABSTRACT: A Result Set

use Moo;
use Carp;

has scroller => (
    is       => 'ro',
    isa      => sub {
        ref($_[0]) eq 'Elasticsearch::Scroll'
            or croak "scroller must be an Elasticsearch::Scroll object";
    },
    required => 1,
    handles  => [qw/ total /],
);

has type => (
    is       => 'ro',
    isa      => sub {
        croak "invalid type" unless
            grep { $_ eq $_[0] } qw/ author distribution favorite file module release /;
    },
    required => 1,
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


sub next {
    my $self = shift;

    my $result = $self->scroller->next;
    defined($result) or return undef;

    my $class  = 'MetaCPAN::API::' . ucfirst $self->type;
    return $class->new_from_request( $result->{'_source'} );
}


1;

__END__

=head1 DESCRIPTION


=head1 ATTRIBUTES

