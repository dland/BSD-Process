# 02-method.t
# Method tests for BSD::Process
#
# Copyright (C) 2006 David Landgren

use strict;
use Test::More tests => 109;

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
    is($pe->flag,      $pe->{flag},      'method flag');
    is($pe->advlock,   $pe->{advlock},   'method advlock');
    is($pe->controlt,  $pe->{controlt},  'method controlt');
    is($pe->kthread,   $pe->{kthread},   'method kthread');
	is($pe->noload,    $pe->{noload},    'method noload');
	is($pe->ppwait,    $pe->{ppwait},    'method ppwait');
	is($pe->profil,    $pe->{profil},    'method profil');
    is($pe->stopprof,  $pe->{stopprof},  'method stopprof');
    is($pe->hadthreads, $pe->{hadthreads}, 'method hadthreads');
    is($pe->sugid,     $pe->{sugid},     'method sugid');
	is($pe->system,    $pe->{system},    'method system');
	is($pe->single_exit, $pe->{single_exit}, 'method single_exit');
	is($pe->traced,    $pe->{traced},    'method traced');
	is($pe->waited,    $pe->{waited},    'method waited');
    is($pe->wexit,     $pe->{wexit},     'method wexit');
    is($pe->exec,      $pe->{exec},      'method exec');
    is($pe->locked,    $pe->{locked},    'method locked');
    is($pe->isctty,    $pe->{isctty},    'method isctty');
    is($pe->issleader, $pe->{issleader}, 'method issleader');
    is($pe->stat,      $pe->{stat},      'method stat');
    is($pe->nice,      $pe->{nice},      'method nice');
    is($pe->lock,      $pe->{lock},      'method lock');
    is($pe->rqindex,   $pe->{rqindex},   'method rqindex');
    is($pe->oncpu,     $pe->{oncpu},     'method oncpu');
    is($pe->lastcpu,   $pe->{lastcpu},   'method lastcpu');
    is($pe->ocomm,     $pe->{ocomm},     'method ocomm');
    is($pe->wmesg,     $pe->{wmesg},     'method wmesg');
    is($pe->login,     $pe->{login},     'method login');
    is($pe->lockname,  $pe->{lockname},  'method lockname');
    is($pe->comm,      $pe->{comm},      'method comm');
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
    is($pe->inblock,    $pe->{inblock},    'method inblock');
    is($pe->oublock,    $pe->{oublock},    'method oublock');
    is($pe->msgsnt,     $pe->{msgsnt},     'method msgsnt');
    is($pe->msgrcv,     $pe->{msgrcv},     'method msgrcv');
    is($pe->nsignals,   $pe->{nsignals},   'method nsignals');
    is($pe->nvcsw,      $pe->{nvcsw},      'method nvcsw');
    is($pe->nivcsw,     $pe->{nivcsw},     'method nivcsw');
    is($pe->utime_ch,    $pe->{utime_ch},    'method utime');
    is($pe->stime_ch,    $pe->{stime_ch},    'method stime');
    is($pe->maxrss_ch,   $pe->{maxrss_ch},   'method maxrss');
    is($pe->ixrss_ch,    $pe->{ixrss_ch},    'method ixrss');
    is($pe->idrss_ch,    $pe->{idrss_ch},    'method idrss');
    is($pe->isrss_ch,    $pe->{isrss_ch},    'method isrss');
    is($pe->minflt_ch,   $pe->{minflt_ch},   'method minflt');
    is($pe->majflt_ch,   $pe->{majflt_ch},   'method majflt');
    is($pe->nswap_ch,    $pe->{nswap_ch},    'method nswap');
    is($pe->inblock_ch,  $pe->{inblock_ch},  'method inblock');
    is($pe->oublock_ch,  $pe->{oublock_ch},  'method oublock');
    is($pe->msgsnt_ch,   $pe->{msgsnt_ch},   'method msgsnt');
    is($pe->msgrcv_ch,   $pe->{msgrcv_ch},   'method msgrcv');
    is($pe->nsignals_ch, $pe->{nsignals_ch}, 'method nsignals');
    is($pe->nvcsw_ch,    $pe->{nvcsw_ch},    'method nvcsw');
    is($pe->nivcsw_ch,   $pe->{nivcsw_ch},   'method nivcsw');

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
    cmp_ok($pi->{start}, '<', time+1, 'attribute start');
    cmp_ok( $pi->runtime, '>', $time, 'refresh updates counters' );

    $time = $pi->runtime;
    $pi->refresh;
    my $diff = $pi->{runtime} - $time;
    diag( "refresh takes $diff microseconds\n" );
}
