use strict;
use warnings;
package MetaCPAN::API::Module;
# ABSTRACT: Module and dist information for MetaCPAN::API

use Any::Moose 'Role';

requires 'render_result';

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
    my $url      = "$base/$prefix/_search?q=dist:$dist";
    my @hits     = $self->_get_hits(
        $self->ua->request(
            'GET',
            $url,
            \%req_opts,
        )
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
    print $self->ua->request('GET', $url, \%req_opts), "\n";
    my @hits     = $self->_get_hits(
        $self->ua->request(
            'GET',
            $url,
            \%req_opts,
        )
    );

    return @hits;
}

1;
