# generate Makefile for building BSD::Process
#
# Copyright (C) 2006 David Landgren

use strict;
use ExtUtils::MakeMaker;
use Config;

my $module_name = 'BSD::Process';

if ($Config{osname} ne 'freebsd') {
    die "$module_name does not support the ($Config{osname}) platform.\n";
}

eval "use ExtUtils::MakeMaker::Coverage";
if( $@ ) {
    print "Can't load ExtUtils::MakeMaker::Coverage, not adding testcover target\n";
}
else {
    print "Adding testcover target\n";
}

WriteMakefile(
    NAME          => $module_name,
    ABSTRACT_FROM => 'Process.pm',
    VERSION_FROM  => 'Process.pm',
    AUTHOR        => 'David Landgren',
    LIBS          => ['-lkvm'],
    LICENSE       => 'perl',
    PREREQ_PM     => {
        'XSLoader'        => 0,
        'Class::Accessor' => '0.25',
    },
);
