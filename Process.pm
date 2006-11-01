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

