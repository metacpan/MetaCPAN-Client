use strict;
use warnings;
use MetaCPAN::Client;
use Test::More;

my $version = $MetaCPAN::Client::VERSION || 'xx';

sub mcpan {
    my $mc = MetaCPAN::Client->new(
        ua_args => [ agent => "MetaCPAN::Client-testing/$version" ],
    );

    isa_ok( $mc, 'MetaCPAN::Client' );

    return $mc;
}

1;
