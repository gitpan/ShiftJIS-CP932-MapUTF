use ExtUtils::MakeMaker;

use File::Copy qw();

my $arg = $ARGV[0] || "";

if (($] < 5.0060009 || $arg =~ /^n/i) and -f "MapUTF.xs") {
    print STDERR "Disabling XS in sources...\n";

    die "***** Failed, sources could be inconsistent! *****\n"
     unless File::Copy::move('MANIFEST',	'MANIFEST.X')
	and File::Copy::move('MANIFEST.N',	'MANIFEST')
	and File::Copy::move('MapUTF.pm',	'MapUTF.pmX')
	and File::Copy::move('MapUTF.xs',	'MapUTF.xsX')
	and File::Copy::move('MapUTF.pmN',	'MapUTF.pm');
}
elsif ($arg =~ /^x/i and -f "MapUTF.xsX") {
    print STDERR "Enabling XS in sources...\n";

    die "***** Failed, sources could be inconsistent! *****\n"
     unless File::Copy::move('MANIFEST',	'MANIFEST.N')
	and File::Copy::move('MANIFEST.X',	'MANIFEST')
	and File::Copy::move('MapUTF.pm',	'MapUTF.pmN')
	and File::Copy::move('MapUTF.xsX',	'MapUTF.xs')
	and File::Copy::move('MapUTF.pmX',	'MapUTF.pm');
}

my $clean = {};

if (-f "MapUTF.xs") {
    print STDERR "Making header files for XS...\n";
    do "mkheader";
    $clean = {FILES=> 'fmcp932.h tocp932.h'};
}

WriteMakefile(
    'NAME'		=> 'ShiftJIS::CP932::MapUTF',
    'VERSION_FROM'	=> 'MapUTF.pm',
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'MapUTF.pod',
       AUTHOR     => 'SADAHIRO Tomoyuki <SADAHIRO@cpan.org>') : ()),
    clean => $clean,
);

