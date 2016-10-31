package Parallel::MPI::map 0.001;

use 5.012;

use strict;
use warnings;

use Exporter qw/import/;
use Parallel::MPI::Simple;

our @EXPORT = qw/map_mpi/;

sub map_mpi (&@) {

    my $code     = \&{shift @_};
    my @subjects = @_;
   
    my $tag = 'map_mpi';

    MPI_Init();

    my $comm   = MPI_COMM_WORLD;
    my $rank   = MPI_Comm_rank($comm);
    my $n_proc = MPI_Comm_size($comm);

    # root node assigns work
    if ($rank == 0) {

        my @payloads;

        # assign subjects to workers in an interleaved fashion
        for (0..$#subjects) {
            my $worker = $_ % $n_proc;
            push @{ $payloads[$worker] }, $subjects[$_];
        }

        # If there are more workers than subjects, assign dummy payloads
        # (without this, extra workers will wait forever for input)
        for my $worker ($#subjects+1..$n_proc-1) {
            $payloads[$worker] = [];
        }
           
        for my $dest (0..$#payloads) {
            MPI_Send( $payloads[$dest], $dest, $tag, $comm );
        }
    }

    # each worker does work
    my $payload   = MPI_Recv( 0, $tag, $comm );
    my @processed = map {$code->($_)} @$payload;
    my @gathered  = MPI_Gather( [@processed], 0, $comm );

    MPI_Finalize();

    # root node processes results
    if ($rank == 0) {
      
        my @final;

        # the gathered results must be "un-interleaved"
        for my $w (0..$#gathered) {
            my @results = @{ $gathered[$w] };
            for my $i (0..$#results) {
                $final[$n_proc*$i+$w] = $results[$i];
            }
        }

        return @final;

    }

    # all non-root nodes should explicitly exit now
    exit;

}

1;


__END__

=head1 NAME

Parallel::MPI::map - a parallel map using MPI

=head1 SYNOPSIS

    use Parallel::MPI::map;

    # you can do this, but why?
    my @squares = map_mpi { $_**2 } 0..10;

    # this is more usual
    my @results = map_mpi { slow_calc($_) } @inputs;

=head1 DESCRIPTION

C<Parallel::MPI::map> provides an (almost) drop-in replacement for C<map>
which utilizes MPI to run in parallel. It uses <Parallel::MPI::Simple>
internally to distribute work and collect results.

Using this module, adding parallel processing to perl code can be as easy as
replacing the built-in C<map> with the provided C<map_mpi>. It says "almost"
above because the C<map_mpi> function, unlike the C<map> built-in, requires a
code BLOCK for the first argument and won't accept an EXPR.

As with other MPI-enabled programs, executables that use this module must be
run using "mpirun" or "mpiexec" to take advantage of parallelization. If not,
the code should run but only on a single thread.

Many of the caveats that apply to MPI programming in general also apply here.
In particular, be aware that there is overhead involved in making the MPI
calls, and that network latency should be considered when running on a
cluster. Generally, this module is suitable for instances where the work to be
done on each input is complex or 

=head1 EXPORTS

=over 4

=item B<map_mpi> BLOCK LIST

    my @results = map_mpi { slow_calc($_) } @inputs;

Emulates the built-in C<map> function, but processes the input list in
parallel when run within an MPI environment.

=back

=head1 CAVEATS AND BUGS

Please reports bugs to the author.

=head1 AUTHOR

Jeremy Volkening <jdv@base2bio.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2014-2016 Jeremy Volkening

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.

=cut

