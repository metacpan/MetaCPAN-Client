use strict;
use warnings;
package MetaCPAN::Client::Scroll;
# ABSTRACT: A MetaCPAN::Client scroller

use Moo;
use Carp;
use Ref::Util qw< is_hashref >;
use JSON::MaybeXS qw< decode_json encode_json >;

use MetaCPAN::Client::Types qw< Str Int Time ArrayRef HashRef Bool >;

has ua => (
    is       => 'ro',
    required => 1,
);

has size => (
    is  => 'ro',
    isa => Str,
);

has time => (
    is  => 'ro',
    isa => Time,
);

has base_url => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has type => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has body => (
    is       => 'ro',
    isa      => HashRef,
    required => 1,
);

has _id => (
    is       => 'ro',
    isa      => Str,
);

has _buffer => (
    is       => 'ro',
    isa      => ArrayRef,
    default  => sub { [] },
);

has _remaining => (
    is       => 'rw',
    isa      => Int,
    default  => sub { 0 },
);

has total => (
    is       => 'ro',
    isa      => Int,
);

has aggregations => (
    is       => 'ro',
    isa      => HashRef,
    default  => sub { +{} },
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

    if ( $res->{status} != 200 ) {
        my $msg = "failed to create a scrolled search";
        $args{debug} and $msg .= "\n(" . $res->{content} . ")";
        croak $msg;
    }

    my $content = decode_json $res->{content};

    # read response content --> object params

    my $total = is_hashref($content->{hits}{total})
        ? $content->{hits}{total}{value}
        : $content->{hits}{total};

    $args{_remaining} = $total;
    $args{total}      = $total;

    $args{_id}        = $content->{_scroll_id};
    $args{_buffer}    = $content->{hits}{hits};

    $args{aggregations} = $content->{aggregations}
        if $content->{aggregations} and is_hashref( $content->{aggregations} );

    return \%args;
}

sub next {
    my $self   = shift;
    my $buffer = $self->_buffer;
    my $remaining = $self->_remaining;

    if (!$remaining) {
        # We're exhausted and will do no more.
        return undef;
    }
    elsif (!@$buffer) {
        # Refill the buffer if it's empty.
        @$buffer = @{ $self->_fetch_next };

        if (!@$buffer) {
            # we weren't able to refill for some reason
            $self->_remaining(0);
            return undef;
        }
    }

    # One less result to return
    $self->_remaining($remaining - 1);
    # Return the next result
    return shift @$buffer;
}

sub _fetch_next {
    my $self = shift;

    my $res = $self->ua->post(
        sprintf( '%s/_search/scroll?scroll=%s&size=%s', $self->base_url, $self->time, $self->size ),
        { content => $self->_id }
    );

    croak "failed to fetch next scrolled batch"
        unless $res->{status} == 200;

    my $content = decode_json $res->{content};

    return $content->{hits}{hits};
}

sub DEMOLISH {
    my ( $self, $gd ) = @_;
    return
        if $gd;
    my $ua = $self->ua
        or return;
    my $base_url = $self->base_url
        or return;
    my $id = $self->_id
        or return;
    my $time = $self->time
        or return;

    $ua->delete(
        sprintf( '%s/_search/scroll?scroll=%s', $base_url, $time ),
        { content => $id }
    );
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

The number of docs to pull from each shard per request.

=head2 time

The lifetime of the scroller on the server.

=head2 total

The total number of matches.

=head2 type

The Elasticsearch type to query.

=head2 ua

The user agent object for running requests.
