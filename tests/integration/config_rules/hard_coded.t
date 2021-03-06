use v5.10;
use strict;
use warnings;

use Test::More;
require 'tests/integration/config_rules/get_response.pl';


# ruDetail
my ( $response_code, $redirect_location ) = get_response ( 'http://www.businesslink.gov.uk/bdotg/action/ruDetail?itemId=1080466320&type=REGUPDATE' );
is( '410', $response_code, "Anything containining ruDetail should be a 410" );

( $response_code, $redirect_location ) = get_response ( 'http://www.businesslink.gov.uk/bdotg/action/ruDetail?itemId=1079357338&type=REGUPDATE' );
is( '410', $response_code, "Anything containining ruDetail should be a 410" );

# hub
( $response_code, $redirect_location ) = get_response ( 'https://online.businesslink.gov.uk/hub/action/render?pageId=tasklist&wid=1097105114' );
is( '301', $response_code, "anything /hub should redirect to business setting-up" );
is( 'https://www.gov.uk/browse/business/setting-up', $redirect_location, "redirect is to  https://www.gov.uk" );

( $response_code, $redirect_location ) = get_response ( 'https://online.businesslink.gov.uk/hub/action/render?pageId=mynewbusiness&r.i=5001195777&r.t=ONEOFFPAGE' );
is( '301', $response_code, "anything /hub should redirect to business setting-up" );
is( 'https://www.gov.uk/browse/business/setting-up', $redirect_location, "redirect is to  https://www.gov.uk" );

# lsplinks
( $response_code, $redirect_location ) = get_response ( 'http://www.ukwelcomes.businesslink.gov.uk/bdotg/action/lsplink?country=1&area_code=DA&lgsl_id=860&site=2000' );
is( '301', $response_code, "anything /lsplink should redirect to licence-finder" );
is( 'https://www.gov.uk/licence-finder', $redirect_location, "redirect is to  licence finder" );

( $response_code, $redirect_location ) = get_response ( 'https://www.businesslink.gov.uk/bdotg/action/lsplink?country=1&area_code=26UC&lgsl_id=646&site=2000' );
is( '301', $response_code, "anything /lsplink should redirect to licence-finder" );
is( 'https://www.gov.uk/licence-finder', $redirect_location, "redirect is to  licence finder" );

done_testing();

