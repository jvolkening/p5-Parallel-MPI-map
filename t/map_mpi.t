#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use Parallel::MPI::map;

my @bar = map_mpi {square_it($_)} (0..5);

cmp_ok( scalar(@bar), '==', 6,  "received correct result count" );
ok( ref($bar[0]) eq 'ARRAY',    "received nested structures" );
cmp_ok( $bar[5]->[1], '==', 25, "received expected result" );

done_testing();

sub square_it {

    my $in = shift;
    return [$in, $in**2];

}
