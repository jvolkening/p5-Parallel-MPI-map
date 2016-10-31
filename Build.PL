use 5.012;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Parallel::MPI::map',
    license             => 'Artistic_2_0',
    dist_author         => q{Jeremy Volkening <jdv@base2bio.com>},
    dist_version_from   => 'lib/Parallel/MPI/map.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'Parallel::MPI::Simple' => 0.101,
    },
    add_to_cleanup     => [ 'Parallel-MPI-map-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
