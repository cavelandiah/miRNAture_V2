use strict;
use warnings;
use Test::More;
use Cwd qw(abs_path getcwd);
use File::Spec;
use File::Temp qw(tempdir);

my $loaded = do './script/miRNAture';
if (!$loaded) {
    fail("script/miRNAture could not be loaded: $@ $!");
    done_testing;
    exit;
}

my $cwd = getcwd();
my $tmp = tempdir(CLEANUP => 1);
chdir $tmp or die "Cannot chdir to $tmp: $!";
mkdir 'inputs' or die $!;
open my $fh, '>', 'inputs/genome.fa' or die $!;
print {$fh} ">ctg\nACGT\n";
close $fh;

is(main::normalize_cli_path(undef), undef, 'undef path stays undef');
is(main::normalize_cli_path(''), '', 'empty path stays empty');
is(main::normalize_cli_path('inputs/genome.fa'), abs_path('inputs/genome.fa'), 'existing relative path is normalized with abs_path');
my $absolute = File::Spec->catfile($tmp, 'inputs', 'genome.fa');
is(main::normalize_cli_path($absolute), $absolute, 'absolute path is preserved');
like(main::normalize_cli_path('missing/file.fa'), qr{\Q$tmp\E.*/missing/file\.fa$}, 'missing relative path falls back to absolute path');

chdir $cwd or die "Cannot restore cwd: $!";
done_testing;
