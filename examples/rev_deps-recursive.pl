use strict;
use warnings;
use Term::ANSIColor;
use MetaCPAN::Client;

$|=1;

my $dist  = 'Hijk';
my $mcpan = MetaCPAN::Client->new;

print "\n\n", colored( "* $dist", 'green' ), "\n";
dig( $dist, 0 );

sub dig {
    my $dist  = shift;
    my $level = shift;

    my $res   = $mcpan->reverse_dependencies($dist);

    for ( @{$res} ) {
        if ( $level ) {
            printf "%s%s\n",
                colored( '....' x $level, 'yellow' ),
                $_->distribution;
        } else {
            printf "\n>> %s\n",
                colored( $_->distribution, 'blue' );
        }

        dig( $_->distribution, $level + 1 );
    }
};
