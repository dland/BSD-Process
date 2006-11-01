# 01-func.t
# Basic sanity checks for BSD::Process
#
# Copyright (C) 2006 David Landgren

use strict;
use Test::More tests => 4;

use BSD::Process;

{
    my @proc = BSD::Process::list();
    cmp_ok( scalar(@proc), '>', 10, 'list of processes' )
        or diag("proclist: (@proc)");
}

{
    my $info = BSD::Process::info($$);
    is($info->{pid}, $$, "system says my pid is the same ($$)");
    isnt($info->{pid}, $info->{ppid}, "I am not my parent");
    cmp_ok($info->{runtime}, '>', 0, "runtime greater than one microsecond ($info->{run_time})");
}

