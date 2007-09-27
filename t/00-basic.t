# 01-basic.t
# Basic sanity checks for BSD::Process
#
# Copyright (C) 2006-2007 David Landgren

use strict;
use Test::More tests => 5;

BEGIN { use_ok('BSD::Process'); }

SKIP: {
    skip( 'Test::Pod not installed on this system', 3 )
        unless do {
            eval { require Test::Pod; import Test::Pod };
            $@ ? 0 : 1;
        };
    pod_file_ok( 'Process.pm' );
    pod_file_ok( 'eg/showprocattr' );
    pod_file_ok( 'eg/topten' );
};

SKIP: {
    skip( 'Test::Pod::Coverage not installed on this system', 1 )
        unless do {
            eval { require Test::Pod::Coverage; import Test::Pod::Coverage };
            $@ ? 0 : 1;
        };
    pod_coverage_ok( 'BSD::Process', 'POD coverage is go' );
};
