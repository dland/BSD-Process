# 02-method.t
# Method tests for BSD::Process
#
# Copyright (C) 2006 David Landgren

use strict;
use Test::More tests => 3;

use BSD::Process;

{
    my $pi = BSD::Process->new();   # implicit pid
    my $pe = BSD::Process->new($$); # explicit pid

    is( $pi->{pid}, $pe->{pid}, 'attribute pid' );
    is( $pi->{sid}, $pe->{sid}, 'attribute sid' );
    is( $pi->{tsid}, $pe->{tsid}, 'attribute tsid' );
}

