use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

require 5.006;

do "mkheader";

WriteMakefile(
    'NAME'		=> 'ShiftJIS::CP932::MapUTF',
    'VERSION_FROM'	=> 'MapUTF.pm',
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'MapUTF.pm',
       AUTHOR     => 'SADAHIRO Tomoyuki <SADAHIRO@cpan.org>') : ()),
    clean =>  {FILES=> 'fmcp932.h tocp932.h'},
);
