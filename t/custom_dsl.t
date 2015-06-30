use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
use strict;
use warnings;
use Plack::Test;
use HTTP::Request::Common;

use FindBin qw($Bin);
# XXX JMG change here
use lib "$Bin/t/lib";
use Dancer2 dsl => 'MyDancerDSL';

envoie '/' => sub {
    request->method;
};

prend '/' => sub {
    proto { ::ok('in proto') }; # no sub!
    request->method;
};


my $test = Plack::Test->create( __PACKAGE__->to_app );

is( $test->request( GET '/' )->content,
    'GET', '[GET /] Correct content'
);
is( $test->request( POST '/' )->content,
    'POST', '[POST /] Correct content'
);

done_testing;
EOF
