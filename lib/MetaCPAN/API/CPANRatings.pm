use strict;
use warnings;
package MetaCPAN::API::CPANRatings;
# ABSTRACT: CPAN Ratings information for MetaCPAN::API

use Any::Moose 'Role';

requires '_http_req';

has cpanratings_prefix => (
    is      => 'ro',
    isa     => 'Str',
    default => 'cpanratings',
);

# http://api.metacpan.org/cpanratings/Moose
sub search_cpanratings_exact {
    my $self    = shift;
    my $dist    = shift;
    my $base    = $self->base_url;
    my $prefix  = $self->cpanratings_prefix;
    my $url     = "$base/$prefix/$dist";
    my $result  = $self->_http_req($url);

    return $result;
}

# http://api.metacpan.org/cpanratings/_search?q=dist:Moose
sub search_cpanratings_like {
    my $self   = shift;
    my $dist   = shift;
    my $base   = $self->base_url;
    my $prefix = $self->cpanratings_prefix;
    my $url    = "$base/$prefix/_search?q=dist:$dist";
    my $result = $self->_http_req($url);

    return $result;
}

1;

__END__

=head1 DESCRIPTION

This role provides MetaCPAN::API with several methods to get the CPAN Ratings
information.

=head1 ATTRIBUTES

=head2 cpanratings_prefix

This attribute helps set the path to the CPAN ratings requests in the REST API.
You will most likely never have to touch this as long as you have an updated
version of MetaCPAN::API.

Default: I<cpanratings>.

This attribute is read-only (immutable), meaning that once it's set on
initialize (via C<new()>), you cannot change it. If you need to, create a
new instance of MetaCPAN::API. Why is it immutable? Because it's better.

=head1 METHODS

=head2 search_cpanratings_exact

    my $result = $mcpan->search_cpanratings_exact('Moose');

Search for a CPAN Ratings entry about a specific distribution.

=head2 search_cpanratings_like

    my $result = $mcpan->search_cpanratings_like('Moose');

Search for a CPAN Ratings entry with anything that has the string you gave in
it. Searching for I<"Moose"> is equivalent to anything that has I<Moose> in it.

