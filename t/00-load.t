#!perl -T
use 5.012;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Parallel::MPI::map' ) || print "Bail out!\n";
}

diag( "Testing Parallel::MPI::map $Parallel::MPI::map::VERSION, Perl $], $^X" );
