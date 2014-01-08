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

has request => (
    is      => 'ro',
    lazy    => 1,
    builder => sub { MetaCPAN::API::Request->new },
    handles => [qw<fetch post>],
);

my @supported_searches = qw<
    author distribution favorite module rating release
>;

sub author {
    my $self = shift;
    my $arg  = shift;

    ref($arg) eq 'HASH' and
        return $self->_search('author', $arg);

    defined $arg and $arg =~ /\w/ and
        return $self->_get('author', $arg);

    croak 'author takes either PAUSE ID or hash as a parameter';
}

sub module {
    my $self = shift;
    my $arg  = shift;

    ref($arg) eq 'HASH' and
        return $self->_search('module', $arg);

    defined $arg and $arg =~ /\w/ and
        return $self->_get('module', $arg);

    croak 'module takes either a name or hash (search arguments) as a parameter';
}

sub distribution {
    my $self = shift;
    my $arg  = shift;

    ref($arg) eq 'HASH' and
        return $self->_search('distribution', $arg);

    defined $arg and $arg =~ /\w/ and
        return $self->_get('distribution', $arg);

    croak 'distribution takes either a name or hash (search arguments) as a parameter';
}

sub file {
    my $self = shift;
    my $path = shift
        or croak 'file takes file path as parameter';

    return $self->_get('file', $path);
}

#
# $api->rating({ dist => "Moose" })
#   is equal to http://api.metacpan.org/v0/favorite/_search?q=distribution:Moose
#
# $api->rating({ author => "DOY" })
#   is equal to http://api.metacpan.org/v0/favorite/_search?q=author:DOY
#
sub favorite {
    my $self = shift;
    my $args = shift;
    ref($args) eq 'HASH' or
        croak "favorite takes a hash ref as parameter";

    return $self->_search('favorite', $args);
}

#
# $api->rating({ rating => "4.0" })
#   is equal to http://api.metacpan.org/v0/rating/_search?q=rating:4.0
#
# $api->rating({ distribution => "Moose" })
#   is equal to http://api.metacpan.org/v0/rating/_search?q=distribution:Moose
#
sub rating {
    my $self = shift;
    my $args = shift;
    ref($args) eq 'HASH' or
        croak "rating takes a hash ref as parameter";

    return $self->_search('rating', $args);
}

#
# $api->release({ author => "XSAWYERX" })
#   is equal to http://api.metacpan.org/v0/release/_search?q=author:XSAWYERX
#
sub release {
   my $self = shift;
   my $arg  = shift;

   ref($arg) eq 'HASH' and
       return $self->_search('release', $arg);

   defined $arg and $arg =~ /\w/ and
       return $self->_get('release', $arg);

   croak 'release takes either a name or hash (search arguments) as a parameter';
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
    ref($response) eq 'HASH'
        or croak sprintf("Failed to fetch %s (%s)", ucfirst($type), $arg);

    my $class = "MetaCPAN::API::" . ucfirst($type);
    return $class->new_from_request($response);
}

sub _search {
    my $self = shift;
    my $type = shift;
    my $args = shift;

    ref($args) eq 'HASH'
        or croak "_search takes a hash ref as parameter";

    grep { $_ eq $type } @supported_searches
        or croak "search type is not supported";

    my $query = $self->_build_search_string($args);

    my $results = $self->fetch(
        "$type/_search",
        q => $query
    );

    exists $results->{hits}{hits}
        or return;

    # fix to return ResultSet
    return [ map { $_->{_source} } @{ $results->{'hits'}{'hits'} } ];
}

sub _build_search_string {
    my $self = shift;
    my $args = shift;

    ref($args) eq 'HASH' or croak "search argument must be a hash ref";
    scalar keys %{$args} == 1
        or croak "search arg sent must contain one key/val pair";

    my ($key) = keys %{$args};
    my $val = $args->{$key};
    my $_key = $key;  $_key =~ s/^([a-z]+).*$/$1/;

    if ( $key eq 'either' and ref($val) eq 'ARRAY' ) {
        return sprintf('(%s)',
            join 'OR' => map { $self->_build_search_string($_) } @{$val});

    } elsif ( $key eq 'all' and ref($val) eq 'ARRAY' ) {
        return sprintf('(%s)',
            join 'AND' => map { $self->_build_search_string($_) } @{$val});

    } elsif ( ! ref $val ) {
        return sprintf '(%s:%s)', $key, $val;

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

