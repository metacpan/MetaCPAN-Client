use strict;
use warnings;
package MetaCPAN::API::POD;
# ABSTRACT: POD information for MetaCPAN::API

use Any::Moose 'Role';

requires '_http_req';

has pod_prefix => (
    is      => 'ro',
    isa     => 'Str',
    default => 'pod',
);

# http://api.metacpan.org/pod/AAA::Demo
sub search_pod {
    my $self    = shift;
    my $dist    = shift;
    my $base    = $self->base_url;
    my $prefix  = $self->pod_prefix;
    my $url     = "$base/$prefix/$dist";
    my $result  = $self->_http_req($url);

    return $result;
}

1;

__END__

=head1 DESCRIPTION

This role provides MetaCPAN::API with several methods to get the CPAN Ratings
information.

=head1 ATTRIBUTES

=head2 pod_prefix

This attribute helps set the path to the POD requests in the REST API.
You will most likely never have to touch this as long as you have an updated
version of MetaCPAN::API.

Default: I<pod>.

This attribute is read-only (immutable), meaning that once it's set on
initialize (via C<new()>), you cannot change it. If you need to, create a
new instance of MetaCPAN::API. Why is it immutable? Because it's better.

=head1 METHODS

=head2 search_pod

    my $result = $mcpan->search_pod('MetaCPAN::API');

Search for the POD of a specific module.

