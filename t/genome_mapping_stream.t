use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use File::Spec;

BEGIN {
    system("$^X -Ilib -MMir::ConfigurationFile -e 1 >/dev/null 2>&1") == 0
        or plan skip_all => "Mir::ConfigurationFile dependencies are not installed";
    require Mir::ConfigurationFile;
    Mir::ConfigurationFile->import;
}

my $tmp = tempdir(CLEANUP => 1);
Mir::ConfigurationFile::create_map_genome('t/data/tiny.fa', 'tst', $tmp, 'tiny.fa');

my $new_fa = File::Spec->catfile($tmp, 'tiny.fa.new.fa');
my $map = File::Spec->catfile($tmp, 'tiny.fa.map');
ok(-s $new_fa, 'normalized FASTA was created');
ok(-s $map, 'contig map was created');

open my $fa_fh, '<', $new_fa or die $!;
my $fa = do { local $/; <$fa_fh> };
close $fa_fh;
like($fa, qr/>tst1\nACGTACGTACGT/, 'first contig is relabeled with species tag');
like($fa, qr/>tst2\nTTTTCCCCAAAAGGGG/, 'second contig is relabeled with species tag');

open my $map_fh, '<', $map or die $!;
my @map = <$map_fh>;
close $map_fh;
chomp @map;
my %seen = map { $_ => 1 } @map;
ok($seen{"tst1\tcontig_alpha first contig"}, 'first original contig name is recorded');
ok($seen{"tst2\tcontig_beta second contig"}, 'second original contig name is recorded');

done_testing;
