use strict;
use warnings;
use Test::More;
use Test::Fatal;
use Ref::Util qw< is_hashref >;

use lib '.';
use t::lib::Functions;

my $mc = mcpan();
can_ok( $mc, qw< reverse_dependencies rev_deps > );

my $module = 'MetaCPAN::Client';

my $rs = $mc->reverse_dependencies($module);
isa_ok( $rs, 'MetaCPAN::Client::ResultSet' );

my @revdeps;

while ( my $release = $rs->next ) {
    is(
        ref $release,
        'MetaCPAN::Client::Release',
        'ResultSet->next with ' . $release->distribution . ' is ok',
    ),

    push @revdeps, $release->distribution;
}

ok( @revdeps > 2, 'revdep count for MetaCPAN::Client seems ok' );

foreach my $dep (@revdeps) {
    $dep =~ s/-/::/g;

    my $ok = eval {
        $mc->module($dep)->name;
        1;
    };

    is( $ok, 1, "$dep is a valid reverse dependency" );
}

# Counting here would be fragile since it depends on dependency changes
done_testing();
