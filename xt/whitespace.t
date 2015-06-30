use v6;
use Inline::Perl5;
EVAL q:to/EOF/, :lang<perl5>;
use Test::Whitespaces {

    dirs => [qw(
        lib
        script
        t
        tools
        xt
    )],

    ignore => [
        qr{\.dancer$}, # XXX JMG Changes
        qr{\.dd$},
        qr{\.exists$},
        qr{\.pod$},
        qr{fakescript.pl$},
        qr{t/sessions/},
        qr{t/template_tiny/samples},
    ],

};
EOF
