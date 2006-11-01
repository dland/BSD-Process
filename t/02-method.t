# 02-method.t
# Method tests for BSD::Process
#
# Copyright (C) 2006 David Landgren

use strict;
use Test::More tests => 35;

use BSD::Process;

{
    my $pi = BSD::Process->new();   # implicit pid
    my $pe = BSD::Process->new($$); # explicit pid

    is( $pi->{pid}, $pe->{pid}, 'attribute pid' );
    is( $pi->{sid}, $pe->{sid}, 'attribute sid' );
    is( $pi->{tsid}, $pe->{tsid}, 'attribute tsid' );

    ok(defined($pe->{start}), 'attribute start (coalesced struct timeval)' );
    ok(defined($pe->{childtime}), 'attribute childtime (coalesced struct timeval)');

    is($pe->pid,     $pe->{pid},     'method pid' );
    is($pe->ppid,    $pe->{ppid},    'method ppid');
    is($pe->pgid,    $pe->{pgid},    'method pgid');
    is($pe->tpgid,   $pe->{tpgid},   'method tpgid');
    is($pe->sid,     $pe->{sid},     'method tpgid');
    is($pe->tsid,    $pe->{tsid},    'method tsid');
    is($pe->jobc,    $pe->{jobc},    'method jobc');
    is($pe->uid,     $pe->{uid},     'method uid');
    is($pe->ruid,    $pe->{ruid},    'method ruid');
    is($pe->svuid,   $pe->{svuid},   'method svuid');
    is($pe->rgid,    $pe->{rgid},    'method rgid');
    is($pe->svgid,   $pe->{svgid},   'method svgid');
    is($pe->ngroups, $pe->{ngroups}, 'method ngroups');
    is($pe->size,    $pe->{size},    'method size');
    is($pe->rssize,  $pe->{rssize},  'method rssize');
    is($pe->tsize,   $pe->{tsize},   'method tsize');
    is($pe->dsize,   $pe->{dsize},   'method dsize');
    is($pe->ssize,   $pe->{ssize},   'method ssize');
    is($pe->xstat,   $pe->{xstat},   'method xstat');
    is($pe->acflag,  $pe->{acflag},  'method acflag');
    is($pe->pctcpu,  $pe->{pctcpu},  'method pctcpu');
    is($pe->estcpu,  $pe->{estcpu},  'method estcpu');
    is($pe->slptime, $pe->{slptime}, 'method slptime');
    is($pe->swtime,  $pe->{swtime},  'method swtime');
    is($pe->runtime, $pe->{runtime}, 'method runtime');
    is($pe->xstat,   $pe->{xstat},   'method xstat');
	is($pe->childtime, $pe->{childtime}, 'method childtime');

    # longhand method names
    is($pi->parent_pid,         $pi->ppid,  'alias parent_pid');
    is($pi->process_group_id,   $pi->pgid,  'alias process_group_id');

    cmp_ok(length($pi->command_name), '>', 0, 'alias command_name');
    cmp_ok(length($pi->old_command_name), '>', 0, 'alias old_command_name');

    my $time = $pi->runtime;
    $pi->refresh;
    cmp_ok( $pi->runtime, '>', $time, 'burnt some CPU time' );

    cmp_ok($pe->{start}, '<', time+1, 'method start');
}

