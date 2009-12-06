use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Cicada',
    AUTHOR              => 'Makio Tsukamoto <tsukamoto@gmail.com>',
    VERSION_FROM        => 'lib/Cicada.pm',
    ABSTRACT_FROM       => 'lib/Cicada.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Carp' => 1.10,
        'File::Path' => 2.07,
        #for plugins
        #'Compress::Zlib' => 2.017,
        #'DBI' => 1.607,
        #'Digest::MD5' => 2.38,
        #'Encode' => 2.26,
        #'Encode::Guess' => 2.02,
        #'HTML::ExtractContent' => 0.09,
        #'Log::Dispatch' => 2.24,
        #'SQL::Abstract' => 1.60,
        #'XML::FeedPP' => 0.40,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Cicada-*' },
);
