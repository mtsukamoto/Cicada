#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Cicada' );
}

diag( "Testing Cicada $Cicada::VERSION, Perl $], $^X" );
