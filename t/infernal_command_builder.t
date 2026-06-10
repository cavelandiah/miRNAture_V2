use strict;
use warnings;
use Test::More;

BEGIN {
    system("$^X -Ilib -MMiRNAture::ToolBox -e 1 >/dev/null 2>&1") == 0
        or plan skip_all => "MiRNAture::ToolBox dependencies are not installed";
    require MiRNAture::ToolBox;
    MiRNAture::ToolBox->import;
}

is(
    MiRNAture::ToolBox::build_cmsearch_args(123, {}, '--tblout', 'hits.tbl'),
    '-E 0.015 --notrunc --nohmmonly -Z 123 --tblout hits.tbl',
    'default cmsearch args use canonical profile and default e-value'
);

is(
    MiRNAture::ToolBox::build_cmsearch_args(50, { profile => 'sensitive', evalue => 0.001, include_cpu => 1, cpu => 2 }, '--noali'),
    '--cpu 2 -E 0.001 --notrunc --max -Z 50 --noali',
    'sensitive profile, explicit e-value, and CPU are included'
);

is(
    MiRNAture::ToolBox::build_cmsearch_args(10, { cmsearch_profile => 'fast', cmsearch_extra_args => '--toponly' }),
    '-E 0.015 --notrunc -Z 10 --toponly',
    'CLI-style option names and extra arguments are supported'
);

done_testing;
