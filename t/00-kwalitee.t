# 00-kwalitee.t
#
# Kwalitee checks for BSD::Process
#
# Copyright (C) 2007 David Landgren

use Test::More;

if (!$ENV{PERL_AUTHOR_TESTING}) {
    plan skip_all => 'PERL_AUTHOR_TESTING environment variable not set (or zero)';
    exit;
}

plan skip_all => 'Test::Kwalitee is borked'; exit;

eval { require Test::Kwalitee; Test::Kwalitee->import() };
plan( skip_all => 'Test::Kwalitee not available on this system' ) if $@;
