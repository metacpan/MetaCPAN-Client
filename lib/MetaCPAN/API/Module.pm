use strict;
use warnings;
package MetaCPAN::API::Module;
# ABSTRACT: Module and dist information for MetaCPAN::API

use Any::Moose 'Role';

requires '_http_req';

has module_prefix => (
    is      => 'ro',
    isa     => 'Str',
    default => 'module',
);

# http://api.metacpan.org/module/_search?q=dist:moose
sub search_dist {
    my $self     = shift;
    my $dist     = shift;
    my %req_opts = @_;
    my $base     = $self->base_url;
    my $prefix   = $self->module_prefix;
    my $url      = "$base/$prefix/_search?q=distname:$dist";
    my @hits     = $self->_get_hits(
        $self->_http_req( $url, \%req_opts )
    );

    return @hits;
}

# http://api.metacpan.org/module/Moose
sub search_module {
    my $self     = shift;
    my $module   = shift;
    my %req_opts = @_ || ();
    my $base     = $self->base_url;
    my $prefix   = $self->module_prefix;
    my $url      = "$base/$prefix/$module";
    my @hits     = $self->_get_hits(
        $self->_http_req( $url, \%req_opts )
    );

    return @hits;
}

1;

__END__

=head1 DESCRIPTION

This role provides MetaCPAN::API with several methods to get the module and
dist information.

=head1 ATTRIBUTES

=head2 module_prefix

This attribute helps set the path to the module and dist requests in the REST
API. You will most likely never have to touch this as long as you have an
updated version of MetaCPAN::API.

Default: I<module>.

This attribute is read-only (immutable), meaning that once it's set on
initialize (via C<new()>), you cannot change it. If you need to, create a
new instance of MetaCPAN::API. Why is it immutable? Because it's better.

=head1 METHODS

=head2 search_dist

    my @dists = $mcpan->search_dist('Moose');

Searches MetaCPAN for a dist.

=head2 search_module

    my @modules = $mcpan->search_module('Moose');

Searches MetaCPAN for a module.

