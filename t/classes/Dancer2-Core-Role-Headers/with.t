use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use HTTP::Headers:from<Perl5>;
use HTTP::Headers::Fast:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 6;

{
    package Object;
    use Moo;
    with 'Dancer2::Core::Role::Headers';
}

subtest 'Default' => sub {
    plan tests => 4;

    my $object = Object->new();
    isa_ok( $object, 'Object' );
    can_ok( $object, qw<headers header push_header headers_to_array> );
    ok( $object->DOES('Dancer2::Core::Role::Headers'), 'Does role' );
    isa_ok( $object->headers, 'HTTP::Headers' );
};

subtest 'Set headers with object' => sub {
    plan tests => 8;

    for my $class ( 'HTTP::Headers', 'HTTP::Headers::Fast' ) {
        my $headers = $class->new();
        isa_ok( $headers, $class );

        $headers->header( 'Host' => 'Foo' );

        my $object = Object->new( headers => $headers );
        isa_ok( $object, 'Object'  );
        isa_ok( $object->headers, $class, 'headers' );
        is( $object->header('Host'), 'Foo', 'Set headers correctly' );
    }
};

subtest 'Set headers with array' => sub {
    plan tests => 2;

    my $object = Object->new(
        headers => [ 'Host' => 'Foo' ]
    );

    isa_ok( $object->headers, 'HTTP::Headers', 'headers' );
    is( $object->header('Host'), 'Foo', 'Set headers correctly' );
};

subtest 'Change headers' => sub {
    plan tests => 4;

    my $object = Object->new();
    $object->header( 'Host' => 'Foo' );
    is( $object->header('Host'), 'Foo', 'Add header correctly' );
    is( $object->headers->header('Host'), 'Foo', 'Add header correctly' );

    $object->header( 'Host' => 'Bar' );
    is( $object->header('Host'), 'Bar', 'Change header correctly' );
    is( $object->headers->header('Host'), 'Bar', 'Changeheader correctly' );
};

subtest 'Add multiple headers' => sub {
    plan tests => 1;

    my $object = Object->new();
    $object->push_header( 'X-Foo' => 'Bar' );
    $object->push_header( 'X-Foo' => 'Baz' );

    my @values = $object->header('X-Foo');
    is_deeply( \@values, [ 'Bar', 'Baz' ], 'Successfully adding many headers' );
};

subtest 'headers_to_array' => sub {
    plan tests => 1;

    my $object = Object->new(
        headers => [
            'Host'         => 'Foo',
            'Content-Type' => 'text/plain',
            'X-Multi'      => 'Bar',
        ]
    );

    $object->push_header( 'X-Multi' => 'Baz' );

    my $headers = $object->headers_to_array;
    is_deeply(
        $headers,
        [
            'Host'         => 'Foo',
            'Content-Type' => 'text/plain',
            'X-Multi'      => 'Bar',
            'X-Multi'      => 'Baz',
        ],
        'Correctly created an array from headers',
    );
};

done_testing;
EOF
