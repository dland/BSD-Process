# BSD::Process.pm
#
# Copyright (c) 2006 David Landgren
# All rights reserved

package BSD::Process;

use strict;
use warnings;

use Exporter;
use XSLoader;
use Class::Accessor;

use vars qw/$VERSION @ISA/;
$VERSION = '0.01';
@ISA = qw(Exporter);

XSLoader::load __PACKAGE__, $VERSION;

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

=head1 METHODS

=over 8

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
    # print each pid and its parent pid
    print "$p ", BSD::Process->new($p)->ppid, $/;
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

=cut

sub new {
    my $class = shift;
    my $pid = shift;
    $pid = $$ unless defined $pid;
    return bless {
        _pid => $pid,
        _info($pid),
    },
    $class;
}

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
