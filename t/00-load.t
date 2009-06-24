#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Config::Apache' );
}

diag( "Testing Config::Apache $Config::Apache::VERSION, Perl $], $^X" );
