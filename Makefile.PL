use 5.008003;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    # XX NAME              => 'Crypt',
    NAME              => 'My::Crypt',
    # XX VERSION_FROM      => 'lib/Crypt.pm', # finds $VERSION
    VERSION_FROM      => 'lib/My/Crypt.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      # XX (ABSTRACT_FROM  => 'lib/Crypt.pm', # retrieve abstract from module
      (ABSTRACT_FROM  => 'lib/My/Crypt.pm', # retrieve abstract from module
       AUTHOR         => 'Reto Hersiczky <retoh@infocopter.com>') : ()),
    LIBS              => [''], # e.g., '-lm'
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    INC               => '-I.', # e.g., '-I. -I/usr/include/other'
	# Un-comment this if you add C files to link with later:
    # OBJECT            => '$(O_FILES)', # link all the C files too
);
