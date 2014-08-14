use strict;
use warnings;

use Test::More;

# ABSTRACT: Make sure passed value of UA gets used for things.

use Test::Requires {
    'WWW::Mechanize::Cached' => 0,
    'HTTP::Tiny::Mech'       => 0,
};
use Test::Fatal qw( exception );

{

    package TrapUA;
    use Moo;
    extends 'HTTP::Tiny::Mech';

    sub mechua {
        require WWW::Mechanize::Cached;
        return WWW::Mechanize::Cached->new();
    }
}

{
    require HTTP::Tiny;
    no warnings "redefine";
    *HTTP::Tiny::request = sub {
        my ( $self, @args ) = @_;
        die "Illegal use of HTTP::Tiny" . pp( \@args );
    };
}
use MetaCPAN::Client;

my $e;
is(
    $e = exception {
        my $client = MetaCPAN::Client->new( ua => TrapUA->new() );

        my $a        = $client->author('KENTNL');
        my $releases = $a->releases;
    },
    undef,
    "No illegal methods called"
);

if ($e) { diag explain $e }

done_testing;

