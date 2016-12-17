use strict;
use warnings;
package MetaCPAN::Client::Scroll;
# ABSTRACT: A MetaCPAN::Client scroller

use Moo;
use Carp;
use Ref::Util qw< is_arrayref is_hashref is_ref >;
use JSON::MaybeXS qw< decode_json encode_json >;

has ua => (
    is       => 'ro',
    required => 1,
);

has size => (
    is  => 'ro',
    isa => sub {
        is_ref($_[0]) and croak 'size must be a scalar';
    },
);

has time => (
    is  => 'ro',
    isa => sub {
        is_ref($_[0]) and croak 'time must be a scalar';
    },
);

has base_url => (
    is  => 'ro',
    isa => sub {
        is_ref($_[0]) and croak 'base_url must be a scalar';
    },
    required => 1,
);

has type => (
    is  => 'ro',
    isa => sub {
        is_ref($_[0]) and croak 'type must be a scalar';
    },
    required => 1,
);

has body => (
    is  => 'ro',
    isa => sub {
        is_hashref($_[0]) or croak 'body must be a hashref';
    },
    required => 1,
);

has _id => (
    is  => 'ro',
    isa => sub {
        is_ref($_[0]) and croak 'id must be a scalar';
    },
    required => 1,
);

has total => (
    is  => 'ro',
    isa => sub {
        is_ref($_[0]) or $_[0] =~ /[^0-9]/
            and croak 'total must be a number';
    },
    required => 1,
);

has _read => (
    is  => 'ro',
    isa => sub {
        is_ref($_[0]) or $_[0] =~ /[^0-9]/
            and croak 'total must be a number';
    },
    default => sub { 0 },
    writer  => '_set_read',
);

has _buffer => (
    is  => 'ro',
    isa => sub {
        is_arrayref($_[0]) or croak 'buffer must be an array ref';
    },
    default => sub { [] },
);

has aggregations => (
    is  => 'ro',
    isa => sub {
        is_hashref($_[0]) or croak 'aggregations must be an hash ref';
    },
    default => sub { +{} },
);

sub BUILDARGS {
    my ( $class, %args ) = @_;
    $args{time} //= '5m';
    $args{size} //= '100';

    my ( $ua, $base_url, $type, $body, $time, $size ) =
        @args{qw< ua base_url type body time size >};

    # fetch scroller from server

    my $res = $ua->post(
        sprintf( '%s/%s/_search?scroll=%s&size=%s', $base_url, $type, $time, $size ),
        { content => encode_json $body }
    );

    croak "failed to create a scrolled search"
        unless $res->{status} == 200;

    my $content = decode_json $res->{content};

    # read response content --> object params

    $args{_id}   = $content->{_scroll_id};
    $args{total} = $content->{hits}{total};

    push @{ $args{_buffer} } => @{ $content->{hits}{hits} };

    $args{aggregations} = $content->{aggregations}
        if $content->{aggregations} and is_hashref( $content->{aggregations} );

    return \%args;
}

sub next {
    my $self = shift;
    return if $self->_read >= $self->total;

    $self->_fetch_next unless @{ $self->_buffer };

    $self->_set_read( $self->_read + 1 );
    return shift @{ $self->_buffer };
}

sub _fetch_next {
    my $self = shift;

    my $res = $self->ua->post(
        sprintf( '%s/_search/scroll?scroll=%s&size=%s', $self->base_url, $self->time, $self->size ),
        { content => $self->_id }
    );

    croak "failed to fetch next scolled batch"
        unless $res->{status} == 200;

    my $content = decode_json $res->{content};

    push @{ $self->_buffer } => @{ $content->{hits}{hits} };
}

sub DEMOLISH {
    my $self = shift;

    my $res = $self->ua->delete(
        sprintf( '%s/_search/scroll?scroll=%s', $self->base_url, $self->time ),
        { content => $self->_id }
    );

    warn "failed to delete scroller"
        unless $res->{status} == 200;
}

1;
__END__

=head1 METHODS

=head2 next

get next matched document.

=head2 BUILDARGS

=head2 DEMOLISH

=head1 ATTRIBUTES

=head2 aggregations

The returned aggregations structure from agg
requests.

=head2 base_url

The base URL for sending server requests.

=head2 body

The request body.

=head2 size

The numebr of docs to pull from each shard per request.

=head2 time

The lifetime of the scroller on the server.

=head2 total

The total number of matches.

=head2 type

The ElasticSearch type to query.

=head2 ua

The user agent object for running requests.
