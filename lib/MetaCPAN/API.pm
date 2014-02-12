package MetaCPAN::API;
# ABSTRACT: A comprehensive, DWIM-featured API to MetaCPAN

use Moo;
use Carp;

use MetaCPAN::API::Request;
use MetaCPAN::API::Author;
use MetaCPAN::API::Distribution;
use MetaCPAN::API::Module;
use MetaCPAN::API::File;
use MetaCPAN::API::Favorite;
use MetaCPAN::API::Release;
use MetaCPAN::API::ResultSet;

has request => (
    is      => 'ro',
    lazy    => 1,
    builder => sub { MetaCPAN::API::Request->new },
    handles => [qw<fetch post ssearch>],
);

my @supported_searches = qw<
    author distribution favorite module rating release
>;

sub author {
    my $self   = shift;
    my $arg    = shift;
    my $params = shift;

    return $self->_get_or_search( 'author', $arg, $params );
}

sub module {
    my $self   = shift;
    my $arg    = shift;
    my $params = shift;

    return $self->_get_or_search( 'module', $arg, $params );
}

sub distribution {
    my $self   = shift;
    my $arg    = shift;
    my $params = shift;

    return $self->_get_or_search( 'distribution', $arg, $params );
}

sub file {
    my $self   = shift;
    my $path   = shift
        or croak 'file takes file path as parameter';

    my $params = shift;

    return $self->_get( 'file', $path, $params );
}

#
# $api->rating({ dist => "Moose" })
#   is equal to http://api.metacpan.org/v0/favorite/_search?q=distribution:Moose
#
# $api->rating({ author => "DOY" })
#   is equal to http://api.metacpan.org/v0/favorite/_search?q=author:DOY
#
sub favorite {
    my $self   = shift;
    my $args   = shift;
    my $params = shift;

    ref($args) eq 'HASH'
        or croak "favorite takes a hash ref as parameter";

    return $self->_search( 'favorite', $args, $params );
}

#
# $api->rating({ rating => "4.0" })
#   is equal to http://api.metacpan.org/v0/rating/_search?q=rating:4.0
#
# $api->rating({ distribution => "Moose" })
#   is equal to http://api.metacpan.org/v0/rating/_search?q=distribution:Moose
#
sub rating {
    my $self   = shift;
    my $args   = shift;
    my $params = shift;

    ref($args) eq 'HASH'
        or croak 'rating takes a hash ref as parameter';

    return $self->_search( 'rating', $args, $params );
}

#
# $api->release({ author => "XSAWYERX" })
#   is equal to http://api.metacpan.org/v0/release/_search?q=author:XSAWYERX
#
sub release {
    my $self   = shift;
    my $arg    = shift;
    my $params = shift;

    return $self->_get_or_search( 'release', $arg, $params );
}

sub pod {}



###

sub _get {
    my $self = shift;
    scalar(@_) == 2
        or croak "_get takes type and search string as parameters";

    my $type = shift;
    my $arg  = shift;

    my $response = $self->fetch("$type/$arg");
    ref $response eq 'HASH'
        or croak sprintf("Failed to fetch %s (%s)", ucfirst($type), $arg);

    my $class = "MetaCPAN::API::" . ucfirst($type);
    return $class->new_from_request($response);
}

sub _search {
    my $self   = shift;
    my $type   = shift;
    my $args   = shift;
    my $params = shift;

    ref $args eq 'HASH'
        or croak '_search takes a hash ref as query';

    !defined $params or ref $params eq 'HASH'
        or croak '_search takes a hash ref as query parameters';
    $params ||= {};

    grep { $_ eq $type } @supported_searches
        or croak "search type is not supported";

    my $scroller = $self->ssearch($type, $args, $params);

    return MetaCPAN::API::ResultSet->new(
        scroller => $scroller,
        type     => $type,
    );
}

sub _get_or_search {
    my $self   = shift;
    my $type   = shift;
    my $arg    = shift;
    my $params = shift;

    ref $arg eq 'HASH' and
        return $self->_search( $type, $arg, $params );

    defined $arg and $arg =~ /\w/ and
        return $self->_get($type, $arg);

    croak "$type: invalid args (takes scalar value or search parameters hash ref)";
}


1;


__END__

=head1 SYNOPSIS

    # simple usage
    my $mcpan  = MetaCPAN::API->new();
    my $author = $mcpan->author('XSAWYERX');
    my $dist   = $mcpan->distribuion('MetaCPAN-API');

    # advanced usage with cache (contributed by Kent Fredric)
    use CHI;
    use WWW::Mechanize::Cached;
    use HTTP::Tiny::Mech;
    use MetaCPAN::API;

    my $mcpan = MetaCPAN::API->new(
      ua => HTTP::Tiny::Mech->new(
        mechua => WWW::Mechanize::Cached->new(
          cache => CHI->new(
            driver   => 'File',
            root_dir => '/tmp/metacpan-cache',
          ),
        ),
      ),
    );

    # now $mcpan caches results

=head1 DESCRIPTION

This is a hopefully-complete API-compliant interface to MetaCPAN
(L<https://metacpan.org>) with DWIM capabilities, to make your life easier.

=head1 ATTRIBUTES

=head2 request

Internal attribute representing the request object making the request to
MetaCPAN and analyzing the results. You probably don't want to set this, nor
should you have any usage of it.

=head1 METHODS

=head2 author

    my $author = $mcpan->author('XSAWYERX');
    my $author = $mcpan->author($search_spec);

Finds an author by either its PAUSE ID or by a search spec defined by a hash
reference. Since it is common to many other searches, it is explained below
under C<SEARCH SPEC>.

Return a L<MetaCPAN::API::Author> object on a simple search (PAUSE ID), or
a L<MetaCPAN::API::ResultSet> object propagated with L<MetaCPAN::API::Author>
objects on a complex (search spec based) search.

=head2 module

    my $module = $mcpan->module('MetaCPAN::API');
    my $module = $mcpan->module($search_spec);

Finds a module by either its module name or by a search spec defined by a hash
reference. Since it is common to many other searches, it is explained below
under C<SEARCH SPEC>.

Return a L<MetaCPAN::API::Module> object on a simple search (module name), or
a L<MetaCPAN::API::ResultSet> object propagated with L<MetaCPAN::API::Module>
objects on a complex (search spec based) search.

=head2 distribution

    my $dist = $mcpan->dist('MetaCPAN-API');
    my $dist = $mcpan->dist($search_spec);

Finds a distribution by either its distribution name or by a search spec
defined by a hash reference. Since it is common to many other searches, it is
explained below under C<SEARCH SPEC>.

Return a L<MetaCPAN::API::Distribution> object on a simple search
(distribution name), or a L<MetaCPAN::API::ResultSet> object propagated with
L<MetaCPAN::API::Distribution> objects on a complex (search spec based) search.

=head2 file

Return a L<MetaCPAN::API::File> object.

=head2 favorite

Return a L<MetaCPAN::API::Favorite> object.

=head2 rating

Return a L<MetaCPAN::API::Rating> object.

=head2 release

    my $release = $mcpan->release('MetaCPAN-API');
    my $release = $mcpan->release($search_spec);

Finds a release by either its distribution name or by a search spec defined by
a hash reference. Since it is common to many other searches, it is explained
below under C<SEARCH SPEC>.

Return a L<MetaCPAN::API::Release> object on a simple search (release name),
or a L<MetaCPAN::API::ResultSet> object propagated with
L<MetaCPAN::API::Release> objects on a complex (search spec based) search.

=head2 pod

Not implemented yet.

=head1 SEARCH SPEC

The hash-based search spec is common to many searches. It is quite
feature-rich and allows to disambiguate different types of searches.

=head2 Simple

Simple searches just contain keys and values:

    my $author = $mcpan->author( { name => 'Micha Nasriachi' } );

    # the following is the same as ->author('MICKEY')
    my $author = $mcpan->author( { pauseid => 'MICKEY' } );

    # find all people named Dave, not covering Davids
    my @daves = $mcpan->author( { name => 'Dave *' } );

=head2 OR

If you want to do a more complicated query that has an I<OR> condition,
such as "this or that", you can use the following syntax with the C<either>
key:

    # any author named "Dave" or "David"
    my @daves = $mcpan->author( {
        either => [
            { name => 'Dave *'  },
            { name => 'David *' },
        ]
    } );

=head2 AND

If you want to do a more complicated query that has an I<AND> condition,
such as "this and that", you can use the following syntax with the C<all>
key:

    # any users named 'John' with a Gmail account
    my @gravatar_johns = $mcpan->author( {
        all => [
            { name  => 'John *'     },
            { email => '*gmail.com' },
        ]
    } );

=head1 DESIGN

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
account how they affect your compile-time, run-time, overall memory
consumption, and CPU usage.

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

You can (and should) read up on the general methods, which will explain how
their DWIMish nature works, and what searches they run.

=back

