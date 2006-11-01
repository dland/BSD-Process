# 02-method.t
# Method tests for BSD::Process
#
# Copyright (C) 2006 David Landgren

use strict;
use Test::More tests => 55;

use BSD::Process;

{
    my $pi = BSD::Process->new();   # implicit pid
    my $pe = BSD::Process->new($$); # explicit pid

    is( $pi->{pid}, $pe->{pid}, 'attribute pid' );
    is( $pi->{sid}, $pe->{sid}, 'attribute sid' );
    is( $pi->{tsid}, $pe->{tsid}, 'attribute tsid' );

    ok(defined($pe->{start}), 'attribute start (coalesced struct timeval)' );
    ok(defined($pe->{childtime}), 'attribute childtime (coalesced struct timeval)');

    is($pe->pid,       $pe->{pid},       'method pid' );
    is($pe->ppid,      $pe->{ppid},      'method ppid');
    is($pe->pgid,      $pe->{pgid},      'method pgid');
    is($pe->tpgid,     $pe->{tpgid},     'method tpgid');
    is($pe->sid,       $pe->{sid},       'method tpgid');
    is($pe->tsid,      $pe->{tsid},      'method tsid');
    is($pe->jobc,      $pe->{jobc},      'method jobc');
    is($pe->uid,       $pe->{uid},       'method uid');
    is($pe->ruid,      $pe->{ruid},      'method ruid');
    is($pe->svuid,     $pe->{svuid},     'method svuid');
    is($pe->rgid,      $pe->{rgid},      'method rgid');
    is($pe->svgid,     $pe->{svgid},     'method svgid');
    is($pe->ngroups,   $pe->{ngroups},   'method ngroups');
    is($pe->size,      $pe->{size},      'method size');
    is($pe->rssize,    $pe->{rssize},    'method rssize');
    is($pe->tsize,     $pe->{tsize},     'method tsize');
    is($pe->dsize,     $pe->{dsize},     'method dsize');
    is($pe->ssize,     $pe->{ssize},     'method ssize');
    is($pe->xstat,     $pe->{xstat},     'method xstat');
    is($pe->acflag,    $pe->{acflag},    'method acflag');
    is($pe->pctcpu,    $pe->{pctcpu},    'method pctcpu');
    is($pe->estcpu,    $pe->{estcpu},    'method estcpu');
    is($pe->slptime,   $pe->{slptime},   'method slptime');
    is($pe->swtime,    $pe->{swtime},    'method swtime');
    is($pe->runtime,   $pe->{runtime},   'method runtime');
    is($pe->xstat,     $pe->{xstat},     'method xstat');
    is($pe->childtime, $pe->{childtime}, 'method childtime');
    is($pe->nice,      $pe->{nice},      'method nice');
    is($pe->stat,      $pe->{stat},      'method stat');
    is($pe->ocomm,     $pe->{ocomm},     'method ocomm');
    is($pe->comm,      $pe->{comm},      'method comm');
    is($pe->wmesg,     $pe->{wmesg},     'method wmesg');
    is($pe->login,     $pe->{login},     'method login');
    is($pe->jid,       $pe->{jid},       'method jid');
    is($pe->numthreads, $pe->{numthreads}, 'method numthreads');
    is($pe->pri_class,  $pe->{pri_class},  'method pri_class');
    is($pe->pri_level,  $pe->{pri_level},  'method pri_level');
    is($pe->pri_native, $pe->{pri_native}, 'method pri_native');
    is($pe->pri_user,   $pe->{pri_user},   'method pri_user');
    is($pe->utime,      $pe->{utime},      'method utime');
    is($pe->stime,      $pe->{stime},      'method stime');

    is($pe->maxrss,     $pe->{maxrss},     'method maxrss');
    is($pe->ixrss,      $pe->{ixrss},      'method ixrss');
    is($pe->idrss,      $pe->{idrss},      'method idrss');
    is($pe->isrss,      $pe->{isrss},      'method isrss');
    is($pe->minflt,     $pe->{minflt},     'method minflt');
    is($pe->majflt,     $pe->{majflt},     'method majflt');
    is($pe->nswap,      $pe->{nswap},      'method nswap');

    # longhand method names
    is($pi->parent_pid,       $pi->ppid, 'alias parent_pid');
    is($pi->process_group_id, $pi->pgid, 'alias process_group_id');
    is($pi->number_of_threads,        1, 'alias number_of_threads');

    cmp_ok(length($pi->command_name),     '>', 0, 'alias command_name');
    cmp_ok(length($pi->old_command_name), '>', 0, 'alias old_command_name');
    cmp_ok(length($pi->setlogin_name),    '>', 0, 'alias setlogin_name');
    ok(defined($pi->wchan_message), 'alias wchan_message');

    my $time = $pi->runtime;
    $pi->refresh;
    cmp_ok( $pi->runtime, '>', $time, 'burnt some CPU time' );

    cmp_ok($pe->{start}, '<', time+1, 'method start');
}

