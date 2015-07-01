use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Test::Fatal:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 1;

require Dancer2;

is(
    exception { Dancer2->import() },
    undef,
    'No compilation issue',
);

done_testing;
EOF
