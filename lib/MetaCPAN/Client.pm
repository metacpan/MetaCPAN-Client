use strict;
use warnings;
package MetaCPAN::Client;
# ABSTRACT: A comprehensive, DWIM-featured client to the MetaCPAN API

use Moo;
use Carp;
use Ref::Util qw< is_arrayref is_hashref is_ref >;
use URI::Escape qw< uri_escape_utf8 >;

use MetaCPAN::Client::Request;
use MetaCPAN::Client::Author;
use MetaCPAN::Client::Distribution;
use MetaCPAN::Client::DownloadURL;
use MetaCPAN::Client::Module;
use MetaCPAN::Client::File;
use MetaCPAN::Client::Favorite;
use MetaCPAN::Client::Pod;
use MetaCPAN::Client::Rating;
use MetaCPAN::Client::Release;
use MetaCPAN::Client::Mirror;
use MetaCPAN::Client::Package;
use MetaCPAN::Client::Permission;
use MetaCPAN::Client::ResultSet;
use MetaCPAN::Client::Cover;

has request => (
    is      => 'ro',
    handles => [qw<ua fetch post ssearch>],
);

my @supported_searches = qw<
    author distribution favorite module rating release mirror file permission package cover
>;

sub BUILDARGS {
    my ( $class, %args ) = @_;

    $args{'request'} ||= MetaCPAN::Client::Request->new(
        ( ua     => $args{ua}     )x!! $args{ua},
        ( domain => $args{domain} )x!! $args{domain},
        ( debug  => $args{debug}  )x!! $args{debug},
    );

    return \%args;
}

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
    my $arg    = shift;
    my $params = shift;

    return $self->_get_or_search( 'file', $arg, $params );
}

sub package {
    my $self   = shift;
    my $arg    = shift;
    my $params = shift;

    return $self->_get_or_search( 'package', $arg, $params );
}

sub permission {
    my $self   = shift;
    my $arg    = shift;
    my $params = shift;

    return $self->_get_or_search( 'permission', $arg, $params );
}

sub cover {
    my $self   = shift;
    my $arg    = shift;
    my $params = shift;

    return $self->_get_or_search( 'cover', $arg, $params );
}

sub pod {
    my $self   = shift;
    my $name   = shift;
    my $params = shift || {};

    return MetaCPAN::Client::Pod->new({
        request => $self->request,
        name    => $name,
        %$params
    });
}

sub favorite {
    my $self   = shift;
    my $args   = shift;
    my $params = shift;

    is_hashref($args)
        or croak 'favorite takes a hash ref as parameter';

    return $self->_search( 'favorite', $args, $params );
}

sub rating {
    my $self   = shift;
    my $args   = shift;
    my $params = shift;

    is_hashref($args)
        or croak 'rating takes a hash ref as parameter';

    return $self->_search( 'rating', $args, $params );
}

sub release {
    my $self   = shift;
    my $arg    = shift;
    my $params = shift;

    return $self->_get_or_search( 'release', $arg, $params );
}

sub mirror {
    my $self   = shift;
    my $arg    = shift;
    my $params = shift;

    return $self->_get_or_search( 'mirror', $arg, $params );
}

sub reverse_dependencies {
    my $self = shift;
    my $dist = shift;

    $dist =~ s/::/-/g;

    return $self->_reverse_deps($dist);
}

*rev_deps = *reverse_dependencies;

sub recent {
    my $self = shift;
    my $size = shift || 100;

    $size eq 'today'
        and return $self->_recent(
            size   => 1000,
            filter => _filter_today()
        );

    $size =~ /^[0-9]+$/
        and return $self->_recent( size => $size );

    croak "recent: invalid size value";
}

sub all {
    my $self   = shift;
    my $type   = shift;
    my $params = shift;

    # This endpoint used to support only pluralized types (mostly) and convert
    # to singular types before redispatching.  Now it accepts both plural and
    # unplural forms directly and relies on the underlying methods it
    # dispatches to to check types (using the global supported types array).
    $type =~ s/s$//;

    $params and !is_hashref($params)
        and croak "all: params must be a hashref";

    if ( $params->{fields} and !is_arrayref($params->{fields}) ) {
        $params->{fields} = [ split /,/ => $params->{fields} ];
    }

    return $self->$type( { __MATCH_ALL__ => 1 }, $params );
}

sub download_url {
    my $self   = shift;
    my $module = shift;

    return $self->_get( 'download_url', $module );
}

sub autocomplete {
    my $self = shift;
    my $q    = shift;

    my $res;

    eval {
        $res = $self->fetch( '/search/autocomplete?q=' . uri_escape_utf8($q) );
        1;

    } or do {
        warn $@;
        return [];
    };

    return [
        map { $_->{fields} } @{ $res->{hits}{hits} }
    ];
}

sub autocomplete_suggest {
    my $self = shift;
    my $q    = shift;

    my $res;

    eval {
        $res = $self->fetch( '/search/autocomplete/suggest?q=' . uri_escape_utf8($q) );
        1;

    } or do {
        warn $@;
        return [];
    };

    return $res->{suggestions};
}

###

sub _get {
    my $self = shift;

    ( scalar(@_) == 2
      or ( scalar(@_) == 3 and ( !defined $_[2] or is_hashref($_[2]) ) ) )
        or croak '_get takes type and search string as parameters (and an optional params hash)';

    my $type   = shift;
    my $arg    = shift;
    my $params = shift;

    my $fields_filter = $self->_read_fields( $params );

    my $response = $self->fetch(
        sprintf("%s/%s%s", $type ,$arg, $fields_filter||'')
    );
    is_hashref($response)
        or croak sprintf( 'Failed to fetch %s (%s)', ucfirst($type), $arg );

    $type = 'DownloadURL' if $type eq 'download_url';

    my $class = 'MetaCPAN::Client::' . ucfirst($type);
    return $class->new_from_request($response, $self);
}

sub _read_fields {
    my $self   = shift;
    my $params = shift;
    $params or return;

    my $fields = delete $params->{fields};
    $fields or return;

    if ( is_arrayref($fields) ) {
        grep { ref $_ } @$fields
            and croak "fields array should not contain any refs.";

        return sprintf( "?fields=%s", join q{,} => @$fields );

    } elsif ( !ref $fields ) {

        return "?fields=$fields";
    }

    croak "invalid param: fields";
}

sub _search {
    my $self   = shift;
    my $type   = shift;
    my $args   = shift;
    my $params = shift;

    is_hashref($args)
        or croak '_search takes a hash ref as query';

    ! defined $params or is_hashref($params)
        or croak '_search takes a hash ref as query parameters';

    $params ||= {};

    grep { $_ eq $type } @supported_searches
        or croak 'search type is not supported';

    my $scroller = $self->ssearch($type, $args, $params);

    return MetaCPAN::Client::ResultSet->new(
        scroller => $scroller,
        type     => $type,
    );
}

sub _get_or_search {
    my $self   = shift;
    my $type   = shift;
    my $arg    = shift;
    my $params = shift;

    is_hashref($arg) and
        return $self->_search( $type, $arg, $params );

    defined $arg and !is_ref($arg)
        and return $self->_get($type, $arg, $params);

    croak "$type: invalid args (takes scalar value or search parameters hashref)";
}

sub _reverse_deps {
    my $self = shift;
    my $dist = shift;

    my $res;

    eval {
        $res = $self->fetch(
            "/reverse_dependencies/dist/$dist",
            {
                size   => 5000,
                query  => { match_all => {} },
                filter => {
                    and => [
                        { term => { 'status'     => 'latest' } },
                        { term => { 'authorized' => 1        } },
                    ]
                },
            }
        );
        1;

    } or do {
        warn $@;
        return _empty_result_set('release'),
    };

    return MetaCPAN::Client::ResultSet->new(
        items => $res->{'data'},
        type  => 'release',
    );
}

sub _recent {
    my $self = shift;
    my @args = @_;

    my $res;

    eval {
        $res = $self->fetch(
            '/release/_search',
            {
                from   => 0,
                query  => { match_all => {} },
                @args,
                sort   => [ { 'date' => { order => "desc" } } ],
            }
        );
        1;

    } or do {
        warn $@;
        return _empty_result_set('release');
    };

    return MetaCPAN::Client::ResultSet->new(
        items => $res->{'hits'}{'hits'},
        type  => 'release',
    );
}

sub _filter_today {
    return { range => { date => { from => "now/1d+0h" } } };
}

sub _empty_result_set {
    my $type = shift;

    return MetaCPAN::Client::ResultSet->new(
        items => [],
        type  => $type,
    );
}

1;

__END__

=head1 SYNOPSIS

    # simple usage
    my $mcpan  = MetaCPAN::Client->new();
    my $author = $mcpan->author('XSAWYERX');
    my $dist   = $mcpan->distribution('MetaCPAN-Client');

    # advanced usage with cache (contributed by Kent Fredric)
    use CHI;
    use WWW::Mechanize::Cached;
    use HTTP::Tiny::Mech;
    use MetaCPAN::Client;

    my $mcpan = MetaCPAN::Client->new(
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

This is a hopefully-complete API-compliant client to MetaCPAN
(L<https://metacpan.org>) with DWIM capabilities, to make your life easier.

=head1 ATTRIBUTES

=head2 request

Internal attribute representing the request object making the request to
MetaCPAN and analyzing the results. You probably don't want to set this, nor
should you have any usage of it.

=head2 ua

If provided, L<MetaCPAN::Client::Request> will use the user agent object
instead of the default, which is L<HTTP::Tiny>.

Then it can be used to fetch the user agent object used by
L<MetaCPAN::Client::Request>.

=head2 domain

If given, will be used to alter the API domain.

=head2 debug

If given, errors will include some low-level detailed message.

=head1 METHODS

=head2 author

    my $author = $mcpan->author('XSAWYERX');
    my $author = $mcpan->author($search_spec);

Finds an author by either its PAUSE ID or by a search spec defined by a hash
reference. Since it is common to many other searches, it is explained below
under C<SEARCH SPEC>.

Returns a L<MetaCPAN::Client::Author> object on a simple search (PAUSE ID), or
a L<MetaCPAN::Client::ResultSet> object propagated with
L<MetaCPAN::Client::Author> objects on a complex (L<search spec based|/"SEARCH SPEC">) search.

=head2 cover

    my $cover = $mcpan->cover('Moose-2.2007');

Returns a L<MetaCPAN::Client::Cover> object.

=head2 distribution

    my $dist = $mcpan->distribution('MetaCPAN-Client');
    my $dist = $mcpan->distribution($search_spec);

Finds a distribution by either its distribution name or by a search spec
defined by a hash reference. Since it is common to many other searches, it is
explained below under C<SEARCH SPEC>.

Returns a L<MetaCPAN::Client::Distribution> object on a simple search
(distribution name), or a L<MetaCPAN::Client::ResultSet> object propagated with
L<MetaCPAN::Client::Distribution> objects on a complex (L<search spec based|/"SEARCH SPEC">)
search.

=head2 file

Returns a L<MetaCPAN::Client::File> object.

=head2 favorite

    my $favorite = $mcpan->favorite({ distribution => 'Moose' });

Returns a L<MetaCPAN::Client::ResultSet> object containing
L<MetaCPAN::Client::Favorite> results.

=head2 rating

    my $rating = $mcpan->rating({ distribution => 'Moose' });

Returns a L<MetaCPAN::Client::ResultSet> object containing
L<MetaCPAN::Client::Rating> results.

=head2 release

    my $release = $mcpan->release('MetaCPAN-Client');
    my $release = $mcpan->release($search_spec);

Finds a release by either its distribution name or by a search spec defined by
a hash reference. Since it is common to many other searches, it is explained
below under C<SEARCH SPEC>.

Returns a L<MetaCPAN::Client::Release> object on a simple search (release name),
or a L<MetaCPAN::Client::ResultSet> object propagated with
L<MetaCPAN::Client::Release> objects on a complex (L<search spec based|/"SEARCH SPEC">) search.

=head2 mirror

    my $mirror = $mcpan->mirror('kr.freebsd.org');

Returns a L<MetaCPAN::Client::Mirror> object.

=head2 module

    my $module = $mcpan->module('MetaCPAN::Client');
    my $module = $mcpan->module($search_spec);

Finds a module by either its module name or by a search spec defined by a hash
reference. Since it is common to many other searches, it is explained below
under C<SEARCH SPEC>.

Returns a L<MetaCPAN::Client::Module> object on a simple search (module name), or
a L<MetaCPAN::Client::ResultSet> object propagated with
L<MetaCPAN::Client::Module> objects on a complex (L<search spec based|/"SEARCH SPEC">) search.

=head2 package

    my $package = $mcpan->package('MooseX::Types');

Returns a L<MetaCPAN::Client::Package> object.

=head2 permission

    my $permission = $mcpan->permission('MooseX::Types');

Returns a L<MetaCPAN::Client::Permission> object.

=head2 reverse_dependencies

    my $deps = $mcpan->reverse_dependencies('Search::Elasticsearch');

all L<MetaCPAN::Client::Release> objects of releases that are directly
dependent on a given module, returned as L<MetaCPAN::Client::ResultSet>.

=head2 rev_deps

Alias to C<reverse_dependencies> described above.

=head2 autocomplete

    my $ac = $mcpan->autocomplete('Danc');

Call the search/autocomplete endpoint with a query string.

Returns an array reference.

=head2 autocomplete_suggest

    my $ac = $mcpan->autocomplete_suggest('Moo');

Call the search/autocomplete/suggest endpoint with a query string.

Returns an array reference.

=head2 recent

    my $recent = $mcpan->recent(10);
    my $recent = $mcpan->recent('today');

return the latest N releases, or all releases from today.

returns a L<MetaCPAN::Client::ResultSet> of L<MetaCPAN::Client::Release>.

=head2 pod

Get POD for given file/module name.
returns a L<MetaCPAN::Client::Pod> object, which supports various output
formats (html, plain, x_pod & x_markdown).

    my $pod = $mcpan->pod('Moo')->html;
    my $pod = $mcpan->pod('Moo', { url_prefix => $prefix })->html;

=head2 download_url

Retrieve information from the 'download_url' endpoint

    my $download_url = $mcpan->download_url('Moose')

Returns a L<MetaCPAN::Client::DownloadURL> object

=head2 all

Retrieve all matches for authors/modules/distributions/favorites or releases.

    my $all_releases = $mcpan->all('releases')

When called with a second parameter containing a hash ref,
will support the following keys:

=head3 fields

See SEARCH PARAMS.

   my $all_releases = $mcpan->all('releases', { fields => [...] })

=head3 _source

See SEARCH PARAMS.

   my $all_releases = $mcpan->all('releases', { _source => [...] })

=head3 es_filter

Pass a raw Elasticsearch filter structure to reduce the number
of elements returned by the query.

    my $some_releases = $mcpan->all('releases', { es_filter => {...} })

=head2 BUILDARGS

Internal construction wrapper. Do not use.

=head1 SEARCH PARAMS

Most searches take params as an optional hash-ref argument.
these params will be passed to the search action.

In non-scrolled searches, 'fields' filter is the only supported
parameter ATM.

=head2 fields

Filter the fields to reduce the amount of data pulled from MetaCPAN.
can be passed as a csv list or an array ref.

    my $module = $mcpan->module('Moose', { fields => "version,author" });
    my $module = $mcpan->module('Moose', { fields => [qw/version author/] });

=head2 _source

Note: this param and its description are a bit too Elasticsearch specific.
just like 'es_filter' - use only if you know what you're dealing with.

Some fields are not indexed in Elasticsearch but stored as part of
the entire document.

These fields can still be read, but without the internal Elasticsearch
optimizations and the server will internally read the whole document.

Why do we even need those? because we don't index everything and some things
we can't to begin with (like non-leaf fields that hold a structure)

    my $module = $mcpan->all('releases', { _source => "stat" });

=head2 scroller_time

Note: please use with caution.

This parameter will set the maximum lifetime of the Elasticsearch scroller on
the server (default = '5m').  Normally you do not need to set this value (as
tweaking this value can affect resources on the server).  In case you do, you
probably need to check the efficiency of your code/queries.  (Feel free to
reach out to us for assistance).

    my $module = $mcpan->all('releases', { scroller_time => '3m' });

=head2 scroller_size

Note: please use with caution.

This parameter will set the buffer size to be pulled from Elasticsearch
when scrolling (default = 1000).
This will affect query performance and memory usage, but you will still
get an iterator back to fetch one object at a time.

    my $module = $mcpan->all('releases', { scroller_size => 500 });

=head3 sort

Pass a raw Elasticsearch sort specification for the query.

    my $some_releases = $mcpan->all('releases', { sort => [{ date => { order => 'desc' } }] })

Note: this param and is a bit too specific to Elasticsearch.  Just like
L</es_filter>, only use this if you know what you're dealing with.

=head1 SEARCH SPEC

The hash-based search spec is common to many searches. It is quite
feature-rich and allows you to disambiguate different types of searches.

Basic search specs just contain a hash of keys and values:

    my $author = $mcpan->author( { name => 'Micha Nasriachi' } );

    # the following is the same as ->author('MICKEY')
    my $author = $mcpan->author( { pauseid => 'MICKEY' } );

    # find all people named Dave, not covering Davids
    # will return a resultset
    my $daves = $mcpan->author( { name => 'Dave *' } );

=head2 OR

If you want to do a more complicated query that has an I<OR> condition,
such as "this or that", you can use the following syntax with the C<either>
key:

    # any author named "Dave" or "David"
    my $daves = $mcpan->author( {
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
    my $johns = $mcpan->author( {
        all => [
            { name  => 'John *'     },
            { email => '*gmail.com' },
        ]
    } );

If you want to do something even more complicated,
You can also nest your queries, e.g.:

    my $gmail_daves_or_cpan_sams = $mcpan->author( {
        either => [
            { all => [ { name => 'Dave *'  },
                       { email => '*gmail.com' } ]
            },
            { all => [ { name => 'Sam *' },
                       { email => '*cpan.org' } ]
            },
        ],
    } );

=head2 NOT

If you want to filter out some of the results of an either/all query
adding a I<NOT> filter condition, such as "not these", you can use the
following syntax with the C<not> key:

    # any author named "Dave" or "David"
    my $daves = $mcpan->author( {
        either => [
            { name => 'Dave *'  },
            { name => 'David *' },
        ],
        not => [
            { email => '*gmail.com' },
        ],
    } );

=head1 DESIGN

This module has three purposes:

=over 4

=item * Provide 100% of the MetaCPAN API

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
