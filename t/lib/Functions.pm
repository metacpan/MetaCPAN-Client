use strict;
use warnings;
use MetaCPAN::API;

my $version = $MetaCPAN::API::VERSION || 'xx';

sub mcpan {
    return MetaCPAN::API->new(
        ua_args => [ agent => "MetaCPAN::API-testing/$version" ],
    );
}

1;
