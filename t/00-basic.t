# 00-basic.t
# Documentation (POD) checks for BSD::Process
#
# Copyright (C) 2006-2007 David Landgren

use strict;
use Test::More;

if (!$ENV{PERL_AUTHOR_TESTING}) {
    plan skip_all => 'PERL_AUTHOR_TESTING environment variable not set (or zero)';
    exit;
}

my %tests = (
    POD          => 3,
    POD_COVERAGE => 1,
);
my %tests_skip = %tests;

eval qq{use Test::Pod};
$@ and delete $tests{POD};

eval qq{use Test::Pod::Coverage};
$@ and delete $tests{POD_COVERAGE};

if (keys %tests) {
    my $nr = 0;
    $nr += $_ for values %tests;
    plan tests => $nr;
}
else {
    plan skip_all => 'POD and Kwalitee testing modules not installed';
}

SKIP: {
    skip( 'Test::Pod not installed on this system', $tests_skip{POD} )
        unless $tests{POD};
    pod_file_ok( 'Process.pm' );
    pod_file_ok( 'eg/showprocattr' );
    pod_file_ok( 'eg/topten' );
}

SKIP: {
    skip( 'Test::Pod::Coverage not installed on this system', $tests_skip{POD_COVERAGE} )
        unless $tests{POD_COVERAGE};
    pod_coverage_ok( 'BSD::Process', 'POD coverage is go' );
};

