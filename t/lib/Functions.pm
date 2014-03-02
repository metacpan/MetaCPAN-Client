use strict;
use warnings;
use MetaCPAN::API;
use Test::More;

my $version = $MetaCPAN::API::VERSION || 'xx';

sub mcpan {
    my $mc = MetaCPAN::API->new(
        ua_args => [ agent => "MetaCPAN::API-testing/$version" ],
    );

    isa_ok( $mc, 'MetaCPAN::API' );

    return $mc;
}

1;
