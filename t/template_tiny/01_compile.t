use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;

BEGIN {
    plan tests => 1;
    $|  = 1;
    $^W = 1;
}
use_ok('Dancer2::Template::Implementation::ForkedTiny');
done_testing;
EOF
