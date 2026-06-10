use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use File::Copy qw(copy);
use File::Spec;

BEGIN {
    system("$^X -Ilib -MMiRNAture::Evaluate -e 1 >/dev/null 2>&1") == 0
        or plan skip_all => "MiRNAture::Evaluate dependencies are not installed";
    require MiRNAture::Evaluate;
    MiRNAture::Evaluate->import;
}

my $tmp = tempdir(CLEANUP => 1);
mkdir File::Spec->catdir($tmp, 'Final') or die $!;
my $tbl = File::Spec->catfile($tmp, 'mixed.tblout');
open my $out, '>', $tbl or die $!;
open my $accepted, '<', 't/data/cmsearch_accepted.tblout' or die $!;
print {$out} <$accepted>;
close $accepted;
open my $rejected, '<', 't/data/cmsearch_rejected.tblout' or die $!;
print {$out} <$rejected>;
close $rejected;
close $out;

my %bitscores = ( RF00001 => 50 );
my %lengths = ( 'miR-test' => 100, RF00001 => 100 );
my %names = ( RF00001 => 'miR-test' );
MiRNAture::Evaluate::cleancmsearch($tbl, 0.8, 1, \%bitscores, \%lengths, \%names, 20);

my $true_file = File::Spec->catfile($tmp, 'Final', 'mixed.tblout.true.table');
my $false_file = File::Spec->catfile($tmp, 'Final', 'mixed.tblout.false.table');
ok(-s $true_file, 'accepted candidates are written to true table');
ok(-s $false_file, 'rejected candidates are written to false table');

open my $true_fh, '<', $true_file or die $!;
my @true = <$true_fh>;
close $true_fh;
open my $false_fh, '<', $false_file or die $!;
my @false = <$false_fh>;
close $false_fh;
is(scalar @true, 1, 'one candidate passed filters');
is(scalar @false, 1, 'one candidate failed filters');
like($true[0], qr/60\.0\t1e-5\t100$/, 'accepted row keeps the high bitscore and appends model length');
like($false[0], qr/10\.0\t1e-5\t100$/, 'rejected row keeps the low bitscore and appends model length');

done_testing;
