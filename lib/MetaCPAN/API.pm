package MetaCPAN::API;
# ABSTRACT: A comprehensive, DWIM-featured API to MetaCPAN

use Moo;
use Carp;
use List::Util 'first';

use MetaCPAN::API::Request;
use MetaCPAN::API::Author;

my @supported_searches = qw<
    author
>;

sub author {
    my $self    = shift;
    my $pauseid = shift or croak "author takes pauseid as parameter";

    my $author_details = MetaCPAN::API::Request->new->fetch("author/$pauseid");
    ref $author_details eq 'HASH' or croak "failed to fetch author $pauseid";

    return MetaCPAN::API::Author->new( data => {
        map +( $_ => $author_details->{$_} ),
        @{ MetaCPAN::API::Author->known_fields }
    } );
}

sub author_search {
    my $self = shift;
    my $args = shift;
    ref $args eq 'HASH' or croak "author_search takes a hash ref as parameter";

    return $self->_search( 'author', $args );
}

sub _search {
    my $self = shift;
    my $type = shift;
    my $args = shift;
    ref $args eq 'HASH' or croak "_search takes a hash ref as parameter";

    unless ( first { $_ eq $type } @supported_searches ) {
        croak "search type is not supported";
    }

    my $query = $self->_build_search_string( $args );

    my $results = MetaCPAN::API::Request->new->fetch("$type/_search?q=$query");
}

sub _build_search_string {
    my $self = shift;
    my $args = shift;

    ref $args eq 'HASH' or croak "search argument must be a hash ref";
    scalar(keys %$args) == 1
        or croak "search argsent must contain one key/val pair";
    my ($key) = keys %$args;
    my $val = $args->{$key};

    if ( $key eq 'either' and ref $val eq 'ARRAY' ) {
        return sprintf("(%s)",
            join 'OR' => map { $self->_build_search_string($_) } @$val);

    } elsif ( $key eq 'all' and ref $val eq 'ARRAY' ) {
        return sprintf("(%s)",
            join 'AND' => map { $self->_build_search_string($_) } @$val);

    } elsif ( grep { $key eq $_ } @{ MetaCPAN::API::Author->known_fields } and
              ! ref $val )
    {
        return sprintf "(%s:%s)", $key, $val;

    } else {
        croak "invalid search parameters";
    }
}


1;


__END__


1;

=head1 SYNOPSIS

    # simple usage
    my $mcpan  = MetaCPAN::API->new();
    my $author = $mcpan->author('XSAWYERX');
    my $dist   = $mcpan->release( distribution => 'MetaCPAN-API' );

    # advanced usage with cache (contributed by Kent Fredric)
    require CHI;
    require WWW::Mechanize::Cached;
    require HTTP::Tiny::Mech;
    require MetaCPAN::API;

    my $mcpan = MetaCPAN::API->new(
      ua => HTTP::Tiny::Mech->new(
        mechua => WWW::Mechanize::Cached->new(
          cache => CHI->new(
            driver => 'File',
            root_dir => '/tmp/metacpan-cache',
          ),
        ),
      ),
    );

=head1 DESCRIPTION

This is a hopefully-complete API-compliant interface to MetaCPAN
(L<https://metacpan.org>) with DWIM capabilities, to make your life easier.

This module has three purposes:

=over 4

=item * Provide 100% of the beta MetaCPAN API

This module will be updated regularly on every MetaCPAN API change, and intends
to provide the user with as much of the API as possible, no shortcuts. If it's
documented in the API, you should be able to do it.

Because of this design decision, this module has an official MetaCPAN namespace
with the blessing of the MetaCPAN developers.

Notice this module currently only provides the beta API, not the old
soon-to-be-deprecated API.

=item * Be lightweight, to allow flexible usage

While many modules would help make writing easier, it's important to take into
account how they affect your compile-time, run-time and overall memory
consumption.

By providing a slim interface implementation, more users are able to use this
module, such as long-running processes (like daemons), CLI or GUI applications,
cron jobs, and more.

=item * DWIM

While it's possible to access the methods defined by the API spec, there's still
a matter of what you're really trying to achieve. For example, when searching
for I<"Dave">, you want to find both I<Dave Cross> and I<Dave Rolsky> (and any
other I<Dave>), but you also want to search for a PAUSE ID of I<DAVE>, if one
exists.

This is where DWIM comes in. This module provides you with additional generic
methods which will try to do what they think you want.

Of course, this does not prevent you from manually using the API methods. You
still have full control over that, if that's what you wish.

You can (and should) read up on the generic methods, which will explain how
their DWIMish nature works, and what searches they run.

=back


=head3 author_search

(TODO: write doc for author_search here)

  SIMPLE:
    { name => 'a*' }


  OR:
    {
        either => [
            { name => 'a*' },
            { name => '*b' }
        ],
    }

  AND:
    {
        all => [
            { name  => 'a*' },
            { email => '*cpan*' }
        ],
    }

  COMPLEX:
    {
        either => [
            {
                all => [
                    { name  => 'a*' },
                    { email => '*cpan*' }
                ],
            },
            {
                all => [
                    { name  => 'b*' },
                    { email => '*cpan*' }
                ],
            },
        ]
    }

