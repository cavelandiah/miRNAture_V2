package MiRNAture::Othersearch;

use Moose::Role;
use Data::Dumper;

with 'MiRNAture::ToolBox';

sub searchOthershomology {
	my $shift = shift;
	my $zscore = shift;
	my $minBitscore = shift;
	my $maxthreshold = shift;
	my $models = $shift->path_covariance;
	cmsearch_mirbase_parallel($shift->genome_subject, $shift->subject_species, $shift->output_folder."/".$shift->subject_species, $models, 1, $shift->cmsearch_program_path->stringify, $zscore, $shift->cmsearch_options);
	return;
}

sub cmsearch_mirbase_parallel {
	my ($genome, $genomeTag, $outFolder, $path_cm, $mode, $cmsearch_path, $zscore, $cmsearch_options) = @_; #modes: 1 X.cm 0 other name
	existenceProgram($cmsearch_path);
	$cmsearch_options ||= {};
	$genome =~ s/"//g;
	foreach my $path_cm_specific (@$path_cm){
		next if $path_cm_specific =~ /^$/;
		next if $path_cm_specific =~ /RFAM/;
		my $cmsearch_args = build_cmsearch_args($zscore, $cmsearch_options, "--tblout", "$outFolder/{/.}_$genomeTag.tab", "-o", "$outFolder/{/.}_$genomeTag.out");
		my $parallel_jobs = defined $cmsearch_options->{jobs} && $cmsearch_options->{jobs} ne "" ? " -j $cmsearch_options->{jobs}" : "";
		system("parallel --will-cite$parallel_jobs $cmsearch_path $cmsearch_args $path_cm_specific/{/.}\.cm $genome 1> /dev/null ::: $path_cm_specific/*\.cm");
	}
	return;
}


no Moose::Role;
1;
