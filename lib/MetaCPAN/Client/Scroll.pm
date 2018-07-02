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

has _done => (
    is       => 'rw',
    isa      => Bool,
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

    $args{_id}     = $content->{_scroll_id};
    $args{total}   = $content->{hits}{total};
    $args{_buffer} = $content->{hits}{hits};

    $args{aggregations} = $content->{aggregations}
        if $content->{aggregations} and is_hashref( $content->{aggregations} );

    return \%args;
}

sub next {
    my $self   = shift;
    my $buffer = $self->_buffer;

    # We're exhausted and will do no more.
    return if $self->_done;

    # Refill the buffer if it's empty.
    @$buffer = @{ $self->_fetch_next }
        unless @$buffer;

    # Grab the next result from the buffer.  If there's no result, then that's
    # all, folks!
    my $next = shift @$buffer;

    $self->_done(1) unless $next;

    return $next;
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
    my $self = shift;

    $self->ua->delete(
        sprintf( '%s/_search/scroll?scroll=%s', $self->base_url, $self->time ),
        { content => $self->_id }
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
