use strict;
use warnings;
package MetaCPAN::API::Role::Path;
# ABSTRACT: Role for API path implementations

use Any::Moose 'Role';

requires 'prefix';

1;

__END__

=head1 DESCRIPTION

Role for any L<MetaCPAN::API> path implementation (such as
L<MetaCPAN::API::Release>).

Meanwhile it just makes sure the implementation has a 'prefix' attribute (or
method).

