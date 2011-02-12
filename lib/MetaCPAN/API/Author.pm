use strict;
use warnings;
package MetaCPAN::API::Author;
# ABSTRACT: Author information for MetaCPAN::API

use Any::Moose 'Role';
use URI::Escape;

requires '_http_req';

has author_prefix => (
    is      => 'ro',
    isa     => 'Str',
    default => 'author',
);

sub search_author {
    my $self = shift;
    my $term = shift;
    my @hits = ();

    # clean leading/trailing spaces
    $term =~ s/^\s+//;
    $term =~ s/\s+$//;

    # if there are no spaces, it might be a PAUSE ID
    if ( $term !~ /\s/ ) {
        push @hits, $self->_get_hits( $self->search_author_pauseid($term) );
    }

    # search by name
    push @hits, $self->_get_hits( $self->search_author_name($term) );

    # search by wildcard
    push @hits, $self->_get_hits( $self->search_author_wildcard($term) );

    # remove uniques
    my %seen   = ();
    my @unique = grep { ! $seen{ $_->{'_id'} }++ } @hits;

    return @unique;
}

# http://api.metacpan.org/author/DROLSKY
sub search_author_pauseid {
    my $self    = shift;
    my $pauseid = shift;
    my $base    = $self->base_url;
    my $prefix  = $self->author_prefix;
    my $url     = "$base/$prefix/$pauseid";
    my $result  = $self->_http_req($url);

    return $result;
}

# http://api.metacpan.org/author/_search?q=name:Dave
# http://api.metacpan.org/author/_search?q=name:%22dave%20rolsky%22
sub search_author_name {
    my $self   = shift;
    my $name   = shift;
    my $base   = $self->base_url;
    my $prefix = $self->author_prefix;

    # escape letters, specifying the regex because by default
    # it will not escape quotations, which it should
    $name = uri_escape( $name, q{^A-Za-z0-9\-\._~} );

    my $url    = "$base/$prefix/_search?q=name:$name";
    my $result = $self->_http_req($url);

    return $result;
}

# http://api.metacpan.org/author/_search?q=author:D*
sub search_author_wildcard {
    my $self   = shift;
    my $term   = shift; # you decide on the wildcard when you call the method
    my $base   = $self->base_url;
    my $prefix = $self->author_prefix;
    my $url    = "$base/$prefix/_search?q=author:$term";
    my $result = $self->_http_req($url);

    return $result;
}

1;

__END__

=head1 DESCRIPTION

This role provides MetaCPAN::API with several methods to get the author
information.

=head1 ATTRIBUTES

=head2 author_prefix

This attribute helps set the path to the author requests in the REST API.
You will most likely never have to touch this as long as you have an updated
version of MetaCPAN::API.

Default: I<author>.

This attribute is read-only (immutable), meaning that once it's set on
initialize (via C<new()>), you cannot change it. If you need to, create a
new instance of MetaCPAN::API. Why is it immutable? Because it's better.

=head1 METHODS

=head2 search_author

    my @authors = $mcpan->search_author('Dave');

This method is the DWIM interface for the author searches. It tries to do what
you probably want. It does so in the following steps:

=over 4

=item 1. Trimming leading and trailing spaces

=item 2. Checks if it's possibly a PAUSE ID

If there are no spaces, meaning it's a single word, it's assumed to optionally
be a PAUSE ID, so it searches it as a PAUSE ID.

=item 3. Searches by author name

As if you gave I<"Olaf Alders"> as the search.

=item 4. Searches by wildcard

As if you gave I<"Olaf"> but want to find anything with I<Olaf> in it.

=back

It stacks the results on top of each other, so you find the PAUSE ID (if there
is one) first, the full name search second and the wildcards last. The purpose
is to try to get as accurate results as possible first time around.

Feel free to submit patches to improve this!

=head2 search_author_pauseid

    my $author = $mcpan->search_author_pauseid('XSAWYERX');

Searches MetaCPAN for a specific PAUSE ID.

=head2 search_author_name

    my $author = $mcpan->search_author_name('Sawyer X');

Searches MetaCPAN for a specific name.

=head2 search_author_wildcard

    my $author = $mcpan->search_author_wildcard('Dave');

Searches MetaCPAN for an author using a string, and full wildcard on both
sides. Equivalent to searching I<*Dave*>.

