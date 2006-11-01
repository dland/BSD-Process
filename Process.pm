# BSD::Process.pm
#
# Copyright (c) 2006 David Landgren
# All rights reserved

package BSD::Process;

use strict;
use warnings;

use Exporter;
use XSLoader;
use base qw(Class::Accessor);

use vars qw($VERSION @ISA @EXPORTER);
$VERSION = '0.01';
@ISA = qw(Exporter Class::Accessor);

@EXPORTER = ('process_info');

BEGIN {
    my %alias = (
        process_pid              => 'pid',
        parent_pid               => 'ppid',
        process_group_id         => 'pgid',
        tty_process_group_id     => 'tpgid',
        process_session_id       => 'sid',
        terminal_session_id      => 'tsid',
        job_control_counter      => 'jobc',
        effective_user_id        => 'uid',
        real_user_id             => 'ruid',
        saved_effective_user_id  => 'svuid',
        real_group_id            => 'rgid',
        saved_effective_group_id => 'svgid',
        number_of_groups         => 'ngroups',
        group_list               => 'groups',
        virtual_size             => 'size',
        resident_set_size        => 'rssize',
        rssize_before_swap       => 'swrss',
        text_size                => 'tsize',
        data_size                => 'dsize',
        stack_size               => 'ssize',
        exit_status              => 'xstat',
        accounting_flags         => 'acflag',
        percent_cpu              => 'pctcpu',
        estimated_cpu            => 'estcpu',
        sleep_time               => 'slptime',
        time_last_swap           => 'swtime',
        elapsed_time             => 'runtime',
        start_time               => 'start',
        children_time            => 'childtime',
        process_flags            => 'flag',
        posix_advisory_lock      => 'advlock',
        has_controlling_terminal => 'controlt',
        is_kernel_thread         => 'kthread',
        no_loadavg_calc          => 'noload',
        parent_waiting           => 'ppwait',
        started_profiling        => 'profil',
        stopped_profiling        => 'stopprof',
        process_had_threads      => 'hadthreads',
        id_privs_set             => 'sugid',
        system_process           => 'system',
        single_exit_not_wait     => 'single_exit',
        traced_by_debugger       => 'traced',
        waited_on_by_other       => 'waited',
        working_on_exiting       => 'wexit',
        process_called_exec      => 'exec',
        kernel_session_flag      => 'kiflag',
        is_locked                => 'locked',
        controlling_tty_active   => 'isctty',
        is_session_leader        => 'issleader',
        process_status           => 'stat',
        is_being_forked          => 'stat_1',
        is_runnable              => 'stat_2',
        is_sleeping_on_addr      => 'stat_3',
        is_stopped               => 'stat_4',
        is_a_zombie              => 'stat_5',
        is_waiting_on_intr       => 'stat_6',
        is_blocked               => 'stat_7',
        nice_priority            => 'nice',
        process_lock_count       => 'lock',
        run_queue_index          => 'rqindex',
        current_cpu              => 'oncpu',
        last_cpu                 => 'lastcpu',
        old_command_name         => 'ocomm',
        wchan_message            => 'wmesg',
        setlogin_name            => 'login',
        name_of_lock             => 'lockname',
        command_name             => 'comm',
        emulation_name           => 'emul',
        process_jail_id          => 'jid',
        number_of_threads        => 'numthreads',
        priority_scheduling_class => 'pri_class',
        priority_level            => 'pri_level',
        priority_native           => 'pri_native',
        priority_user             => 'pri_user',
        user_time                 => 'utime',
        system_time               => 'stime',
        max_resident_set_size     => 'maxrss',
        shared_memory_size        => 'ixrss',
        unshared_data_size        => 'idrss',
        unshared_stack_size       => 'isrss',
        page_reclaims             => 'minflt',
        page_faults               => 'majflt',
        number_of_swaps           => 'nswap',
        block_input_ops           => 'inblock',
        block_output_ops          => 'oublock',
        messages_sent             => 'msgsnd',
        messages_received         => 'msgrcv',
        signals_received          => 'nsignals',
        voluntary_context_switch   => 'nvcsw',
        involuntary_context_switch => 'nivcsw',
        user_time_ch               => 'utime_ch',
        system_time_ch             => 'stime_ch',
        max_resident_set_size_ch   => 'maxrss_ch',
        shared_memory_size_ch      => 'ixrss_ch',
        unshared_data_size_ch      => 'idrss_ch',
        unshared_stack_size_ch     => 'isrss_ch',
        page_reclaims_ch           => 'minflt_ch',
        page_faults_ch             => 'majflt_ch',
        number_of_swaps_ch         => 'nswap_ch',
        block_input_ops_ch         => 'inblock_ch',
        block_output_ops_ch        => 'oublock_ch',
        messages_sent_ch           => 'msgsnd_ch',
        messages_received_ch       => 'msgrcv_ch',
        signals_received_ch        => 'nsignals_ch',
        voluntary_context_switch_ch   => 'nvcsw_ch',
        involuntary_context_switch_ch => 'nivcsw_ch',
    );

    # make some shorthand accessors
    BSD::Process->mk_ro_accessors( values %alias );

    # and map some longhand aliases to them
    no strict 'refs';
    for my $long (keys %alias) {
        *{$long} = *{$alias{$long}};
    }
}

XSLoader::load __PACKAGE__, $VERSION;

sub new {
    my $class = shift;
    my $pid   = shift;
    my $args;
    if (ref($pid) eq 'HASH') {
        $args = $pid;
        $pid  = $$;
    }
    else {
        $args = shift || {};
    }
    $pid = $$ unless defined $pid;
    my $self = {
        _pid  => $pid
    };
    $self->{_resolve} = exists $args->{resolve} ? $args->{resolve} : 0;
    my $info = _info($self->{_pid}, $self->{_resolve});
    @{$self}{keys %$info} = values %$info;

    return bless $self, $class;
}

sub refresh {
    my $self = shift;
    my $info = _info($self->{_pid}, $self->{_resolve});
    @{$self}{keys %$info} = values %$info;
    return $self;
}

sub info {
    my $pid = shift;
    my $args;
    if (ref($pid) eq 'HASH') {
        $args = $pid;
        $pid  = $$;
    }
    else {
        $args = shift || {};
    }
    $pid = $$ unless defined $pid;
    my $resolve = exists $args->{resolve} ? $args->{resolve} : 0;
    return _info($pid, $resolve);
}

*process_info = *info;

=head1 NAME

BSD::Process - Retrieve information about running processes

=head1 VERSION

This document describes version 0.01 of BSD::Process,
released 2006-mm-dd.

=head1 SYNOPSIS

  use BSD::Process;

  my $proc = BSD::Process->new;
  print $proc->rssize, " resident set size\n";
  print "This process has made $proc->{minflt}  page reclaims\n";

  print $proc->user_time, " seconds spent on the CPU\n";
  $proc->refresh;
  print "And now $proc->{utime} seconds\n";

=head1 DESCRIPTION

C<BSD::Process> retrieves information about running
processes from the BSD kernel and stores them in an object.

=head1 FUNCTIONS

=over 8

=item info
=item process_info

Returns the process information specified by a process identifier
(or I<pid>).

The input value will be coerced to a number, thus, if a some random
string is passed in, it will be coerced to 0, and you will receive
the process information of process 0 (the swapper). If no parameter
is passed, the pid of the running process is assumed.

A hash reference may be passed as an optional second parameter, to
adjust the way the information is formatted.

=over 4

=item resolve

Indicates whether the fields that correspond to user ids (uids)
and group ids (gids) should be resovled to their symbolic
equivalents. Internally, the code calls C<getpwuid> and
C<getgrgid> as appropriate.

  my $proc = BSD::Process::info( $$, {resolve => 1} );
  print $proc->{uid};
  # on my system, prints 'david', rather than 1001

=back

A reference to a hash is returned, which is basically a C<BSD::Process>
object, without all the object-oriented fluff around it. The keys
are documented below in the METHODS section.  Only the short names
exist, the longer descriptive names are not defined.

If the pid does not (or does no longer) correspond to process, undef
is returned.

The function C<info> is not exportable (since many programs will
no doubt already have a routine named C<info>). The alias C<process_info>
is exportable.

=item list

Returns an array of pids identifier) of all the running processes
on the system. Note: fleet-footed processes may have
disappeared between the time they are observed running and the time
the information is acquired about them. If this is a problem, you
should be looking at C<all()>, which will return an array of
C<BSD::Process> objects. The list is not sorted.

A C<BSD::Process> object is instantiated from a pid, hence the
utility of this routine. Note: this routine is not exported, you
have to call it by its fully-qualified name.

  my @pid = BSD::Process::list;
  for my $p (@pid) {
    my $proc =  BSD::Process::info($p);
    print "$p $proc->{ppid}\n"; # print each pid and its parent pid
  }

=item all

Return a list of C<BSD::Process> objects representing the
current running processes.

  my @proc = BSD::Process::all;
  for my $p (@proc) {
    print $p->pid, ' ' $p->ppid, $/;
    # or
    print "$p->{pid} $p->{ppid}\n";
  }

This routine runs more slowly than C<list()>, since it has
to instantiate the process objects.

NOT YET IMPLEMENTED.

=item max_kernel_groups

Returns the maximum number of groups to which a process may belong.
This is probably not of direct importance to the average Perl
programmer, but it makes the number of regression tests to be run
easier to calculate in a cross-platform manner.

=back

=head1 METHODS

=over 8

=item new

Creates a new C<BSD::Process> object. The caveats that apply
to the input parameter for C<list> concerning the input parameter
(the pid of the process to examine) also apply here.

  my $init = BSD::Process->new(1); # get info about init
  print "children of init have taken $init->{childtime} seconds\n";

=item refresh

Refreshes the information of a C<BSD::Process> object. For
instance, the following snippet shows a very accurate way
of measuring elapsed CPU time:

  my $proc  = BSD::Process->new;
  my $begin = $proc->runtime; # microseconds
  lengthy_calculation();

  $proc->refresh;
  my $elapsed = $proc->runtime - $begin;
  print "that took $elapsed microseconds of CPU time\n";

=back

The following methods may be called on a C<BSD::Process> object.
Each process attribute may be accessed via two methods, a longer,
more descriptive name, or a terse name (inspired by the member
name in the underlying C<kinfo_proc> C struct).

Furthermore, you may also interpolate the attribute (equivalent to
the terse method name) directly into a string. This can lead to
simpler code. The following three statements are equivalent:

  print "rss=", $p->resident_set_size;
  print "rss=", $p->rssize;
  print "rss=$p->{rssize};

A modification of a value in the underlying hash of the object
has no corresponding effect on the system process it represents.

=over 8

=item process_pid, pid

The identifier that identifies a process in a unique manner. No two
process share the same pid (process id).

=item parent_pid, ppid

The pid of the parent process that spawned the current process.
Many processes may share the same parent pid. Processes whose parents
exit before they do are reparented to init (pid 1).

=item process_group_id, pgid

A number of processes may belong to the same group (for instance,
all the process in a shell pipeline). In this case they share the
same pgid.

=item tty_process_group_id, tpgid

Similarly, a number of processes belong to the same tty process
group. This means that they were all originated from the same console
login session or terminal window.

=item process_session_id, sid

Processes also belong to a session, identified by the process session
id.

=item terminal_session_id, tsid

A process that has belongs to a tty process group will also have a
terminal session id.

=item job_control_counter, jobc

The job control counter of a process. (purpose?)

=item effective_user_id, uid

The user id under which the process is running. A program with the
setuid bit set can be launched by any user, and the effective user
id will be that of the program itself, rather than that of the user.

=item real_user_id, ruid

The user id of the user that launched the process.

=item saved_effective_user_id, svuid

The saved effective user id of the process. (purpose?)

=item real_group_id, rgid

The primary group id of the user that launched the process.

=item saved_effective_group_id, svgid

The saved effective group id of the process. (purpose?)

=item number_of_groups, ngroups

The number of groups to which the process belongs.

=item virtual_size, size

The size (in bytes) of virtual memory occupied by the process.

=item resident_set_size, rssize

The size (in kilobytes) of physical memory occupied by the process.

=item rssize_before_swap, swrss

The resident set size of the process before the last swap.

=item text_size, tsize

Text size (in pages) of the process.

=item data_size, dsize

Data size (in pages) of the process.

=item stack_size, ssize

Stack size (in pages) of the process.

=item exit_status, xstat

Exit status of the process (usually zero).

=item accounting_flags, acflag

Process accounting flags (TODO: decode them).

=item percent_cpu, pctcpu

Percentage of CPU time used by the process (for the duration of
swtime, see below).

=item estimated_cpu, estcpu

Time averaged value of ki_cpticks. (as per the comment in user.h,
purpose?)

=item sleep_time, slptime

Number of seconds since the process was last blocked.

=item time_last_swap, swtime

Number of seconds since the process was last swapped in or out.

=item elapsed_time, runtime

Real time used by the process, in microseconds.

=item start_time, start

Epoch time of the creation of the process.

=item children_time, childtime

Amount of real time used by the children processes (if any) of the
process.

=item process_flags, flag

A bitmap of process flags (decoded in the following methods as 0
or 1).

=item posix_advisory_lock, advlock

Flag indicating whether the process holds a POSIX advisory lock.

=item has_controlling_terminal, controlt

Flag indicating whether the process has a controlling terminal (if
true, the terminal session id is stored in the C<tsid> attribute).

=item is_kernel_thread, kthread

Flag indicating whether the process is a kernel thread.

=item no_loadavg_calc, noload

Flag indicating whether the process contributes to the load average
calculations of the system.

=item parent_waiting, ppwait

Flag indicating whether the parent is waiting for the process to
exit.

=item started_profiling, profil

Flag indicating whether the process has started profiling.

=item stopped_profiling, stopprof

Flag indicating whether the process has a thread that has requesting
profiling to stop.

=item process_had_threads, hadthreads

Flag indicating whether the process has had thresds.

=item id_privs_set, sugid

Flag indicating whether the process has set id privileges since
last exec.

=item system_process, system

Flag indicating whether the process is a system process.

=item single_exit_not_wait, single_exit

Flag indicating that threads that are suspended should exit, not
wait.

=item traced_by_debugger, traced

Flag indicating that the process is being traced by a debugger.

=item waited_on_by_other, waited

Flag indicating that another process is waiting for the process.

=item working_on_exiting, wexit

Flag indicating that the process is working on exiting.

=item process_called_exec, exec

Flag indicating that the process has called exec.

=item kernel_session_flag, kiflag

A bitmap described kernel session status of the process, described
via the following attributes.

=item is_locked, locked

Flag indicating that the process is waiting on a lock (whose name
may be obtained from the C<lock> attribute).

  if ($p->is_locked) {
    print "$p->{comm} is waiting on lock $p->{lockname}\n";
  }
  else {
    print "not waiting on a lock\n";
  }

=item controlling_tty_active, isctty

Flag indicating that the vnode of the controlling tty is active.

=item is_session_leader, issleader

Flag indicating that the process is a session leader.

=item process_status, stat

Numeric value indicating the status of the process, decoded via the
following attibutes.

=item is_being_forked, stat_1

Status indicates that the process is being forked.

=item is_runnable, stat_2

Status indicates the process is runnable.

=item is_sleeping_on_addr, stat_3

Status indicates the process is sleeping on an address.

=item is_stopped, stat_4

Status indicates the process is stopped, either suspended or in a
debugger.

=item is_a_zombie, stat_5

Status indicates the process is a zombie. It is waiting for its
parent to collect its exit code.

=item is_waiting_on_intr, stat_6

Status indicates the process is waiting for an interrupt.

=item is_blocked, stat_7

Status indicates the process is blocked by a lock.

=item nice_priority, nice

The nice value of the process. The more positive the value, the
nicer the process (that is, the less it seeks to sit on the CPU).

=item process_lock_count, lock

Process lock count. If locked, swapping is prevented.

=item run_queue_index, rqindex

When multiple processes are runnable, the run queue index shows the
order in which the processes will be scheduled to run on the CPU.

=item current_cpu, oncpu

Identifies which CPU the process is running on.

=item last_cpu, lastcpu

Identifies the last CPU on which the process was running.

=item old_command_name, ocomm

The old command name.

=item wchan_message, wmesg

wchan message. (purpose?)

=item setlogin_name, login

Name of the user login process that launched the command.

=item name_of_lock, lockname

Name of the lock that the process is waiting on (if the process is
waiting on a lock).

=item command_name, comm

Name of the command.

=item emulation_name, emul

Name of the emulation.

=item process_jail_id, jid

The process jail identifier

=item number_of_threads, numthreads

Number of threads in the process.

=item priority_scheduling_class, pri_class

=item priority_level, pri_level

=item priority_native, pri_native

=item priority_user, pri_user

The parameters pertaining to the scheduling of the process.

=item user_time, utime

Process resource usage information. The amount of time spent by the
process in userland.

=item system_time, stime

Process resource usage information. The amount of time spent by the
process in the kernel (system calls).

=item max_resident_set_size, maxrss

Process resource usage information. The maximum resident set size
(the high-water mark of physical memory used) of the process.

=item shared_memory_size, ixrss

Process resource usage information. The size of shared memory.

=item unshared_data_size, idrss

Process resource usage information. The size of unshared memory.

=item unshared_stack_size, isrss

Process resource usage information. The size of unshared stack.

=item page_reclaims, minflt

Process resource usage information. Minor page faults, the number
of page reclaims.

=item page_faults, majflt

Process resource usage information. Major page faults, the number
of page faults.

=item number_of_swaps, nswap

Process resource usage information. The number of swaps the
process has undergone.

=item block_input_ops, inblock

Process resource usage information. Total number of input block
operations performed by the process.

=item block_output_ops, oublock

Process resource usage information. Total number of output block
operations performed by the process.

=item messages_sent, msgsnd

Process resource usage information. Number of messages sent by
the process.

=item messages_received, msgrcv

Process resource usage information. Number of messages received by
the process.

=item signals_received, nsignals

Process resource usage information. Number of signals received by
the process.

=item voluntary_context_switch, nvcsw

Process resource usage information. Number of voluntary context
switches performed by the process.

=item involuntary_context_switch, nivcsw

Process resource usage information. Number of involuntary context
switches performed by the process.

=item user_time_ch, utime_ch

=item system_time_ch, stime_ch

=item max_resident_set_size_ch, maxrss_ch

=item shared_memory_size_ch, ixrss_ch

=item unshared_data_size_ch, idrss_ch

=item unshared_stack_size_ch, isrss_ch

=item page_reclaims_ch, minflt_ch

=item page_faults_ch, majflt_ch

=item number_of_swaps_ch, nswap_ch

=item block_input_ops_ch, inblock_ch

=item block_output_ops_ch, oublock_ch

=item messages_sent_ch, msgsnd_ch

=item messages_received_ch, msgrcv_ch

=item signals_received_ch, nsignals_ch

=item voluntary_context_switch_ch, nvcsw_ch

=item involuntary_context_switch_ch => 'nivcsw_ch

These attributes store the resource usage of the child processes
spawned by this process. Currently, the kernel only fills in the
information for the the C<utime_ch> and C<stime_ch> fields.

=back

=head1 DIAGNOSTICS

None.

=head1 NOTES

=head1 SEE ALSO

=over 8

=item L<BSD::Sysctl>

General information about Perl.

=back

=head1 BUGS

None known.

Please report all bugs at
L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=BSD-Process|rt.cpan.org>

Make sure you include the output from the following two commands:

  perl -MBSD::Process -le 'print BSD::Process::VERSION' perl -V

=head1 ACKNOWLEDGEMENTS

None.

=head1 AUTHOR

David Landgren, copyright (C) 2006. All rights reserved.

http://www.landgren.net/perl/

If you (find a) use this module, I'd love to hear about it.  If you
want to be informed of updates, send me a note. You know my first
name, you know my domain. Can you guess my e-mail address?

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

'The Lusty Decadent Delights of Imperial Pompeii';

