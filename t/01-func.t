# 01-func.t
# Basic sanity checks for BSD::Process
#
# Copyright (C) 2006 David Landgren

use strict;
use Test::More tests => 14;

use BSD::Process;

{
    my @proc = BSD::Process::list();
    cmp_ok( scalar(@proc), '>', 10, 'list of processes' )
        or diag("proclist: (@proc)");
}

{
    my $info = BSD::Process::info($$);
    is( $info->{pid}, $$, "system says my pid is the same ($$)" );
    isnt( $info->{pid}, $info->{ppid}, 'I am not my parent' );
    ok( defined(getpwuid(delete $info->{uid})), 'user id' );
    ok( defined(getpwuid(delete $info->{ruid})), 'real user id' );
    ok( defined(getgrgid(delete $info->{rgid})), 'real group id' );
    ok( defined(getpwuid(delete $info->{svuid})), 'saved user id' );
    ok( defined(getgrgid(delete $info->{svgid})), 'saved group id' );

    cmp_ok( $info->{runtime}, '>', 1, "positive runtime ($info->{runtime}usec)" );
    cmp_ok( $info->{dsize}, '>', 1, "data segment size ($info->{dsize}Kb)" );
    cmp_ok( $info->{ssize}, '>', 1, "stack segment size ($info->{ssize}Kb)" );
    cmp_ok( $info->{tsize}, '>', 1, "text segment size ($info->{tsize}Kb)" );
    cmp_ok( $info->{rssize}, '>', 1, "resident set size ($info->{rssize}Kb)" );
    cmp_ok( $info->{size}, '>', 1, "virtual memory size ($info->{size}b)" );

    delete @{$info}{qw(pid ppid runtime dsize ssize tsize size rssize)};
    for (sort keys %$info) {
        # diag( "$_: $info->{$_}\n" );
    }
}

