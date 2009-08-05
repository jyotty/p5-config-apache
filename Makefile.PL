use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Config::Apache',
    AUTHOR              => 'Josh Yotty',
    VERSION_FROM        => 'lib/Config/Apache.pm',
    ABSTRACT_FROM       => 'lib/Config/Apache.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'IPC::System::Simple' => 0,
        'Mouse' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Config-Apache-*' },
);
