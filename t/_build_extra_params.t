#!perl

use strict;
use warnings;

use Test::More tests => 5;
use Test::Fatal;
use t::lib::Functions;

my $mcpan = mcpan();

like(
    exception { $mcpan->_build_extra_params('one') },
    qr/^Incorrect number of params, must be key\/value/,
    'Check for key/value params',
);

my $output;
is(
    exception { $output = $mcpan->_build_extra_params },
    undef,
    'No exception or problem on empty args',
);

is(
    $output,
    '',
    'No output either',
);

# regular
is(
    $mcpan->_build_extra_params( param1 => 'one', param2 => 'two' ),
    'param1=one&param2=two',
    'Basic params',
);

# throw some symbols in there
is(
    $mcpan->_build_extra_params( param1 => 'one', param2 => 'two space' ),
    'param1=one&param2=two%20space',
    'Escaping HTML in params',
);

