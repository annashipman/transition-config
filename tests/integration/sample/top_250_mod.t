my $test = Top_250::Mod->new();
$test->{'force_production_redirector'} = 1;
$test->input_file("tests/integration/test_data/top_250_mod_urls.csv");
$test->output_file("dist/mod_sample_test_output.csv");
$test->output_error_file("dist/mod_sample_failures.csv");
$test->run_tests();
exit;


package Top_250::Mod;
use base 'IntegrationTest';

use v5.10;
use strict;
use warnings;
use Test::More;


sub test {
    my $self = shift;

    my ( $passed, $response, $test_response ) = $self->test_closed_redirects(@_);

    if ( -1 == $passed ) {
    	( $passed, $response, $test_response ) = $self->test_closed_gones(@_);
    	if ( -1 == $passed ) {
    		( $passed, $response, $test_response ) = $self->is_ok_response(@_);
    	}
    }

    return (
    	$passed,
    	$response,
    	$test_response
    );
}