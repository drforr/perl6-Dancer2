use v6;
use Inline::Perl5;
EVAL q:to/EOF/, :lang<perl5>;
#!/usr/bin/env perl

use strict;

BEGIN {
    $|  = 1;
    $^W = 1;
}
use Test::More tests => 1;

use_ok('Dancer2::Template::Implementation::ForkedTiny');
done_testing;
EOF
