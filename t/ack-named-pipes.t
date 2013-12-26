#!perl -T

use strict;
use warnings;
use lib 't';

use File::Temp;
use Test::More;
use Util;

sub has_mkfifo {
    system 'which mkfifo >/dev/null 2>/dev/null';
    return $? == 0;
}

sub mkfifo {
    my ( $filename ) = @_;

    system 'mkfifo', $filename;

    return;
}

sub touch {
    my ( $filename ) = @_;
    my $fh;
    open $fh, '>>', $filename or die "Unable to append to $filename: $!";
    close $fh;

    return;
}

prep_environment();

if ( ! has_mkfifo() ) {
    plan skip_all => q{You need the 'mkfifo' command to be able to run this test};
}

plan tests => 2;

local $SIG{'ALRM'} = sub {
    fail 'Timeout';
    exit;
};

alarm 5; # Should be plenty of time.

my $tempdir = File::Temp->newdir;
mkdir "$tempdir/foo";
mkfifo( "$tempdir/foo/test.pipe" );
touch( "$tempdir/foo/bar.txt" );

my @results = run_ack( '-f', $tempdir );

is_deeply \@results, [
    "$tempdir/foo/bar.txt",
];
