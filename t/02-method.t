# 02-method.t
# Method tests for BSD::Process
#
# Copyright (C) 2006 David Landgren

use strict;
use Test::More tests => 18;

use BSD::Process;

{
    my $pi = BSD::Process->new();   # implicit pid
    my $pe = BSD::Process->new($$); # explicit pid

    is( $pi->{pid}, $pe->{pid}, 'attribute pid' );
    is( $pi->{sid}, $pe->{sid}, 'attribute sid' );
    is( $pi->{tsid}, $pe->{tsid}, 'attribute tsid' );

    my $time = $pi->runtime;
    $pi->refresh;
    cmp_ok( $pi->runtime, '>', $time, 'burnt some CPU time' );

    is($pe->pid,   $pe->{pid},   'method pid' );
    is($pe->ppid,  $pe->{ppid},  'method ppid');
    is($pe->pgid,  $pe->{pgid},  'method pgid');
    is($pe->tpgid, $pe->{tpgid}, 'method tpgid');
    is($pe->sid,   $pe->{sid},   'method tpgid');
    is($pe->tsid,  $pe->{tsid},  'method tsid');
    is($pe->jobc,  $pe->{jobc},  'method jobc');
    is($pe->uid,   $pe->{uid},   'method uid');
    is($pe->ruid,  $pe->{ruid},  'method ruid');
    is($pe->svuid, $pe->{svuid}, 'method svuid');
    is($pe->rgid,  $pe->{rgid},  'method rgid');
    is($pe->svgid, $pe->{svgid}, 'method svgid');

    # longhand method names
    is($pi->parent_pid,         $pi->ppid,  'alias parent_pid');
    is($pi->process_group_id,   $pi->pgid,  'alias process_group_id');
}

