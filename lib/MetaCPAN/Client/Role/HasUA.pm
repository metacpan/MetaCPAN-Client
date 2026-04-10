use strict;
use warnings;
package MetaCPAN::Client::Role::HasUA;
# ABSTRACT: Role for supporting user-agent attribute

use Moo::Role;
use Carp;
use HTTP::Tiny;

has _user_ua => (
    init_arg  => 'ua',
    is        => 'ro',
    predicate => '_has_user_ua',
);

has ua => (
    init_arg => undef,
    is       => 'ro',
    lazy     => 1,
    builder  => '_build_ua',
);

has user_agent => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_user_agent',
);

has ua_args => (
    is      => 'ro',
    default => sub { [] },
);

sub _build_user_agent {
    return 'MetaCPAN::Client/' . ($MetaCPAN::Client::VERSION || 'xx');
}

sub _build_ua {
    my $self = shift;

    # This level of indirection is so that if a user has not specified a custom UA
    # MetaCPAN::Client will have its own UA's
    #
    # But if the user **has** specified a custom UA, that UA is used for both.
    if ( $self->_has_user_ua ) {
        my $ua = $self->_user_ua;
        croak "cannot use given ua (must support 'get' and 'post' methods)"
            unless $ua->can("get") and $ua->can("post");

        return $self->_user_ua;
    }

    return HTTP::Tiny->new(
        agent      => $self->user_agent,
        verify_SSL => 1,
        @{ $self->ua_args },
    );
}

1;
__END__

=head1 ATTRIBUTES

=head2 ua

    my $mcpan = MetaCPAN::Client->new( ua => HTTP::Tiny->new(...) );

The user agent object for running requests.

It must provide an interface that matches L<HTTP::Tiny>. Explicitly:

=over 4

=item * Implement post()

Method C<post> must be available that accepts a request URL and a hashref of
options.

=item * Implement get()

Method C<get> must be available that accepts a request URL.

=item * Return result hashref

Must return a result hashref which has key C<success> and key C<content>.

=back

Default: L<HTTP::Tiny>,

=head2 user_agent

    my $mcpan = MetaCPAN::Client->new(
        user_agent => 'MyApp/1.0',
    );

Sets the user agent string used by the built-in L<HTTP::Tiny> client.

Default: B<MetaCPAN::Client/$version>.

=head2 ua_args

    my $mcpan = MetaCPAN::Client->new(
        ua_args => [ agent => 'MyAgent' ],
    );

Arguments sent to the user agent.

Default: none. These arguments are applied on top of the default
C<HTTP::Tiny-E<gt>new> construction and may override C<user_agent>.
