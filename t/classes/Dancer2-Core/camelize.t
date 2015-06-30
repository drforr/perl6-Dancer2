use v6;
use Inline::Perl5;
EVAL q:to/EOF/, :lang<perl5>;
use strict;
use warnings;
use Dancer2::Core;
use Test::More tests => 4;

my %tests = (
    'test'       => 'Test',
    'class_name' => 'ClassName',
    'class_nAME' => 'ClassNAME',
    'class_NAME' => 'ClassNAME',
);

foreach my $test ( keys %tests ) {
    my $value = $tests{$test};

    is(
        Dancer2::Core::camelize($test),
        $value,
        "$test camelized as $value",
    );
}

done_testing;
EOF
