use strict;
use warnings;
use Term::ANSIColor;
use MetaCPAN::Client;

$|=1;

my $dist  = shift || 'Hijk';
my $mcpan = MetaCPAN::Client->new;

print "\n\n", colored( "* $dist", 'green' ), "\n";
dig( $dist, 0 );

sub dig {
    my $dist  = shift;
    my $level = shift;

    my $res   = $mcpan->reverse_dependencies($dist);

    while ( my $item = $res->next ) {
        if ( $level ) {
            printf "%s%s\n",
                colored( '....' x $level, 'yellow' ),
                $item->distribution;
        } else {
            printf "\n>> %s\n",
                colored( $item->distribution, 'blue' );
        }

        dig( $item->distribution, $level + 1 );
    }
}
