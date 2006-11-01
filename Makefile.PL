# generate Makefile for building BSD::Process
#
# Copyright (C) 2006 David Landgren

use strict;
use ExtUtils::MakeMaker;

eval "use ExtUtils::MakeMaker::Coverage";
if( $@ ) {
    print "Can't load ExtUtils::MakeMaker::Coverage, not adding testcover target\n";
}
else {
    print "Adding testcover target\n";
}

WriteMakefile(
    NAME          => 'BSD::Process',
    ABSTRACT_FROM => 'Process.pm',
    VERSION_FROM  => 'Process.pm',
    AUTHOR        => 'David Landgren',
    LIBS          => ['-lkvm'],
    LICENSE       => 'perl',
    PREREQ_PM     => {
        'XSLoader'        => 0,
        'Class::Accessor' => 0.25,
    },
);
