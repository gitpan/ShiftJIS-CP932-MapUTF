use ExtUtils::MakeMaker;

use File::Copy ();

if ($] < 5.0060009 and -f "MapUTF.xs") {
    do "disableXS";
}

my $clean = {};

if (-f "MapUTF.xs") {
    print STDERR "Making header files for XSUB...\n";
    do "mkheader";
    $clean = {FILES=> 'fmcp932.h tocp932.h'};
}

WriteMakefile(
    'NAME'		=> 'ShiftJIS::CP932::MapUTF',
    'VERSION_FROM'	=> 'MapUTF.pm',
    clean => $clean,
);

