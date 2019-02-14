use Test::More;
use Test::Exception;

use Data::Dumper;
use MooseX::Simplify;

subtest 'simplify non moose object' => sub {

    my $object = {
        a => 1,
        b => 2,
    };
    bless( $object, 'NonMooseObject' );

    my $hash;
    lives_ok {
        $hash = moosex_simplify( $object );
    } 'Lives through simplify';

    cmp_ok( ref($hash), 'eq', '', 'Got back a scalar' );
    note( Dumper( $hash ) );
};



done_testing;
