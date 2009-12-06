#!perl -T

use Test::More tests => 8;
use Cicada;

BEGIN {
	use_ok( 'Cicada::plugin::db' );
	use_ok( 'Cicada::plugin::decoded_content' );
	use_ok( 'Cicada::plugin::extract_content' );
	use_ok( 'Cicada::plugin::feedpp' );
	use_ok( 'Cicada::plugin::history' );
	use_ok( 'Cicada::plugin::log' );
	use_ok( 'Cicada::plugin::mechanize' );
	use_ok( 'Cicada::plugin::timestamp' );
}

diag( "Testing Cicada $Cicada::VERSION, Perl $], $^X" );
