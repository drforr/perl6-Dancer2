use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Test::Fatal:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 1;

require Dancer2;

SKIP: {
    skip "### XXX Fix this later", 1 if $] < 6;
like(
    exception { Dancer2->import() },
    qr{Engine 'foo' is not supported},
    'Correct compilation issue',
);
}

done_testing;
EOF
