use strict;
use warnings;
package MetaCPAN::Client::Types;
# ABSTRACT: type checking helper class

use Type::Tiny      ();
use Types::Standard ();
use Ref::Util qw< is_ref >;

use parent 'Exporter';
our @EXPORT_OK = qw< Str Int Time ArrayRef HashRef >;

sub Str      { Types::Standard::Str      }
sub Int      { Types::Standard::Int      }
sub ArrayRef { Types::Standard::ArrayRef }
sub HashRef  { Types::Standard::HashRef  }

sub Time {
    return Type::Tiny->new(
        name       => "Time",
        constraint => sub { !is_ref($_) and /^[1-9][0-9]*(?:s|m|h)$/ },
        message    => sub { "$_ is not in time format (e.g. '5m')" },
    );
}

1;
__END__

=head1 METHODS

=head2 ArrayRef

=head2 HashRef

=head2 Int

=head2 Str

=head2 Time
