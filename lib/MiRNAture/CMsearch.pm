package MiRNAture::CMsearch;

use Moose::Role;
use Data::Dumper;
with 'MiRNAture::CMsearch';
with 'MiRNAture::ToolBox';
with 'MiRNAture::Evaluate';

sub searchCMhomology {
	my ($shift, $zscore,$minBitscore, $maxthreshold) = @_;
	cmsearch_rfam_parallel($shift->genome_subject, $shift->subject_species, $shift->output_folder."/".$shift->subject_species, $shift->path_covariance, 1, $shift->cmsearch_program_path->stringify, $zscore, $shift->cmsearch_options);
	##cmsearch($shift->cm_model, $shift->genome_subject, $shift->subject_species, $shift->output_folder."/".$shift->subject_species, $shift->path_covariance, 1, $shift->cmsearch_program_path->stringify, $zscore);
	return;
}

sub cmsearch_rfam_parallel {
	my ($genome, $genomeTag, $outFolder, $path_cm, $mode, $cmsearch_path, $zscore, $cmsearch_options) = @_; #modes: 1 X.cm 0 other name
	existenceProgram($cmsearch_path);
	$cmsearch_options ||= {};
	$genome =~ s/"//g;
	foreach my $path_cm_specific (@$path_cm){
		next if $path_cm_specific =~ /^$/;
		my $cmsearch_args = build_cmsearch_args($zscore, $cmsearch_options, "--tblout", "$outFolder/{/.}_$genomeTag.tab", "-o", "$outFolder/{/.}_$genomeTag.out");
		my $parallel_jobs = defined $cmsearch_options->{jobs} && $cmsearch_options->{jobs} ne "" ? " -j $cmsearch_options->{jobs}" : "";
		system("parallel --will-cite$parallel_jobs $cmsearch_path $cmsearch_args $path_cm_specific/{/.}\.cm $genome 1> /dev/null ::: $path_cm_specific/RF*\.cm");
	}
	return;
}

sub cmsearch {
	#In: out, CM model, genome
	my ($nameCM, $genome, $genomeTag, $outFolder, $path_cm, $mode, $cmsearch_path, $zscore, $cmsearch_options) = @_; #modes: 1 X.cm 0 other name
	existenceProgram($cmsearch_path);
	my $nameCMFinal;
	if($mode == 1){ #From other source
		$nameCMFinal = "${nameCM}.cm";
	} elsif ($mode == 0){ #From metazoa
		$nameCMFinal = "${nameCM}_metazoa.cm";
	}
	$genome =~ s/"//g;
	foreach my $path_cm_specific (@$path_cm){
		if (-e "$path_cm_specific/${nameCMFinal}" && !-z "$path_cm_specific/${nameCMFinal}"){
			my $param = build_cmsearch_args($zscore, { %{$cmsearch_options || {}}, include_cpu => 1 }, "--tblout", "$outFolder/${nameCM}_$genomeTag.tab", "-o", "$outFolder/${nameCM}_$genomeTag.out") . " $path_cm_specific/${nameCMFinal} $genome";
			system "$cmsearch_path $param 1> /dev/null";
		} 
	}
	return;
}

no Moose::Role;
1;
