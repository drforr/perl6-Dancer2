use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;

BEGIN {
    plan tests => 1;
    $|  = 1;
    $^W = 1;
}
use Dancer2::Template::Implementation::ForkedTiny ();

sub process {
    my $stash    = shift;
    my $input    = shift;
    my $expected = shift;
    my $message  = shift || 'Template processed ok';
    my $output   = '';
    Dancer2::Template::Implementation::ForkedTiny->new->process(
        \$input,
        $stash, \$output
    );
    is( $output, $expected, $message );
}


######################################################################
# Main Tests

process( { foo => 'World' },
    <<'END_TEMPLATE', <<'END_EXPECTED', 'Trivial ok' );
Hello [% foo %]!
END_TEMPLATE
Hello World!
END_EXPECTED
done_testing;
EOF
