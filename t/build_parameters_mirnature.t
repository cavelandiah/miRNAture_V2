use strict;
use warnings;
use Test::More;

BEGIN {
    system("$^X -Ilib -MMir::miRNAture -e 1 >/dev/null 2>&1") == 0
        or plan skip_all => "Mir::miRNAture dependencies are not installed";
    require Mir::miRNAture;
    Mir::miRNAture->import;
}

my $variables = [ {}, {}, {}, {
    Default_folders => {
        List_cm_miRNAs => 't/data/models.list',
        Blast_queries => 't/data/blast_queries',
        Data_folder => 't/data',
        CM_folder => 't/data/cms',
        Other_CM_folder => 't/data/other_cms',
        User_CM_folder => 't/data/user_cms',
        HMM_folder => 't/data/hmms',
        Other_HMM_folder => 't/data/other_hmms',
        User_HMM_folder => 't/data/user_hmms',
        User_folder => 't/data/user',
    },
    Homology_options => {
        Blast_strategies => [qw(blastn tblastx)],
        Parallel => 0,
        Parallel_linux => 2,
        Repetition_threshold => 'default,200,100',
        Threshold_bitscore => 0.8,
        cmsearch_evalue => 0.001,
        cmsearch_profile => 'sensitive',
        cmsearch_cpu => 3,
        cmsearch_jobs => 4,
        cmsearch_extra_args => '--toponly',
    },
    Species_data => { Tag => 'tst', Name => 'Test_species' },
}, {
    User_results => { Output_miRNAture_folder => 'out/miRNA_prediction' },
} ];

my $params = Mir::miRNAture::build_parameters_mirnature($variables);
ok(exists $params->{blast}, 'blast parameters are present');
ok(exists $params->{rfam}, 'rfam parameters are present');
like($params->{blast}, qr/-str blastn,tblastx/, 'blast strategies are joined');
like($params->{rfam}, qr/--cmsearch_evalue "0\.001"/, 'cmsearch e-value is forwarded to rfam');
like($params->{hmm}, qr/--cmsearch_profile "sensitive"/, 'cmsearch profile is forwarded to hmm');
like($params->{mirbase}, qr/--cmsearch_cpu "3"/, 'cmsearch cpu is forwarded to mirbase');
like($params->{user}, qr/--cmsearch_extra_args "--toponly"/, 'cmsearch extra args are forwarded to user mode');
unlike($params->{final}, qr/cmsearch_/, 'final homology parameters do not include cmsearch options');

done_testing;
