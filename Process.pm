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

use vars qw($VERSION @ISA);
$VERSION = '0.01';
@ISA = qw(Exporter Class::Accessor);

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
        is_locked                => 'locked',
        controlling_tty_active   => 'isctty',
        is_session_leader        => 'issleader',
        status                   => 'stat',
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
        messages_sent             => 'msgsnt',
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
        messages_sent_ch           => 'msgsnt_ch',
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
    my $pid = shift;
    $pid = $$ unless defined $pid;
    my $self = {
        _pid  => $pid
    };
    my $info = _info($self->{_pid});
    @{$self}{keys %$info} = values %$info;

    return bless $self, $class;
}

sub refresh {
    my $self = shift;
    my $info = _info($self->{_pid});
    @{$self}{keys %$info} = values %$info;
    return $self;
}

sub info {
    return _info(0+$_[0]);
}

=head1 NAME

BSD::Process - Retrieve information about running processes

=head1 VERSION

This document describes version 0.01 of BSD::Process,
released 2006-mm-dd.

=head1 SYNOPSIS

  use BSD::Process;

=head1 DESCRIPTION

C<BSD::Process> is designed to retrieve information about running
processes from the BSD kernel. Information about a process is
encapsulated in a C<BSD::Process> object. The data may be
access via accessors, or through the underlying hash is speed is
of the essence.

=head1 FUNCTIONS

=over 8

=item info

Returns the process information specified by a pid. A numeric value
is expected. If garbage is passed, the process information of process
0 will be returned.

=item list

Returns an array of pids (process identifier) of all the running
processes on the system. Note: fleet-footed processes may have
disappeared between the time they are observed running and the time
the information is acquired about them. If this is a problem, you
should be looking at C<all()>, which will return an array of
C<BSD::Process> objects.

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

=back

=head1 METHODS

=over 8

=item new

Creates a new C<BSD::Process> object. A valid pid of a
running process is passed as a parameter. If no
parameter is given, the pid of the current process is
used by default. This routine will return undef if the
pid of a non-existent process is given.

The process information is returned and
may be accessed through read-only accessors. Since speed may
be of the essence, you are welcome to access the underlying
hash directly. Modifying the values in the hash has no
effect on the running process.

  my $init = BSD::Process(1); # get info about init

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

The following methods may be called on a C<BSD::Process>
object. Each process attribute may be accessed via a longer,
descriptive method, or a terse method. Furthermore, you may
also interpolate the attribute directly into a string.

The following three statements are equivalent:

  print "rss=", $p->resident_set_size;
  print "rss=", $p->rssize;
  print "rss=$p->{rssize};

The attribute name is the same as the terse method name.

=over 8

=item process_pid, pid

The identifier that identifies a process in a unique manner. No two
process share the same pid (process id).

=item parent_pid, ppid

The pid of the parent process that spawned the current process. Many
processes may share the same parent pid. Processes whose parents
exit before they do are reparented to init (pid 1).

=item process_group_id, pgid

A number of processes may belong to the same group (for instance,
all the process in a shell pipeline). In this case they share the
same pgid.

=item tty_process_group_id, tpgid

Similarly, a number of processes belong to the same tty process
group. This means that they were all originated from the same
console login session or terminal window.

=item process_session_id, sid

Processes also belong to a session, identified by the process
session id.

=item terminal_session_id, tsid

A process that has belongs to a tty process group will also have
a terminal session id.

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

=item estimated_cpu, estcpu

=item sleep_time, slptime

=item time_last_swap, swtime

=item elapsed_time, runtime

=item start_time, start

=item children_time, childtime

=item process_flags, flag

=item posix_advisory_lock, advlock

=item has_controlling_terminal, controlt

=item is_kernel_thread, kthread

=item no_loadavg_calc, noload

=item parent_waiting, ppwait

=item started_profiling, profil

=item stopped_profiling, stopprof

=item process_had_threads, hadthreads

=item id_privs_set, sugid

=item system_process, system

=item single_exit_not_wait, single_exit

=item traced_by_debugger, traced

=item waited_on_by_other, waited

=item working_on_exiting, wexit

=item process_called_exec, exec

=item is_locked, locked

=item controlling_tty_active, isctty

=item is_session_leader, issleader

=item status, stat

=item nice_priority, nice

=item process_lock_count, lock

=item run_queue_index, rqindex

=item current_cpu, oncpu

=item last_cpu, lastcpu

=item old_command_name, ocomm

=item wchan_message, wmesg

=item setlogin_name, login

=item name_of_lock, lockname

=item command_name, comm

=item emulation_name, emul

=item process_jail_id, jid

=item number_of_threads, numthreads

=item priority_scheduling_class, pri_class

=item priority_level, pri_level

=item priority_native, pri_native

=item priority_user, pri_user

=item user_time, utime

=item system_time, stime

=item max_resident_set_size, maxrss

=item shared_memory_size, ixrss

=item unshared_data_size, idrss

=item unshared_stack_size, isrss

=item page_reclaims, minflt

=item page_faults, majflt

=item number_of_swaps, nswap

=item block_input_ops, inblock

=item block_output_ops, oublock

=item messages_sent, msgsnt

=item messages_received, msgrcv

=item signals_received, nsignals

=item voluntary_context_switch, nvcsw

=item involuntary_context_switch, nivcsw

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

=item messages_sent_ch, msgsnt_ch

=item messages_received_ch, msgrcv_ch

=item signals_received_ch, nsignals_ch

=item voluntary_context_switch_ch, nvcsw_ch

=item involuntary_context_switch_ch => 'nivcsw_ch

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

  perl -MBSD::Process -le 'print BSD::Process::VERSION'
  perl -V

=head1 ACKNOWLEDGEMENTS

None.

=head1 AUTHOR

David Landgren, copyright (C) 2006. All rights reserved.

http://www.landgren.net/perl/

If you (find a) use this module, I'd love to hear about it.
If you want to be informed of updates, send me a note. You
know my first name, you know my domain. Can you guess my
e-mail address?

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

'The Lusty Decadent Delights of Imperial Pompeii';

