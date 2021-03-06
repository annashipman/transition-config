use strict;
use warnings;
use Test::More tests=>25;
use Mappings;


my $mappings = Mappings->new( 'tests/unit/test_data/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );

my $directgov_redirect = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies.html',
	'New Url'	=> 'https://www.gov.uk/working-tax-credit/overview',
	'Status'	=> 301, 
};
my( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $redirect_type, 'location',
	'If host is Directgov and type is redirect, type of nginx block is location' );
is( $redirect, qq(location ~* ^/en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies\\.html/?\$ { return 301 https://www.gov.uk/working-tax-credit/overview; }\n),
    'Nginx config is as expected' );


my $directgov_cy_gone = {
	'Old Url'	=> 'http://www.direct.gov.uk/cy/Governmentcitizensandrights/Consumerrights/Protectyourselffromscams/DG_195967CY',
	'New Url'	=> '',
	'Status'	=> 410,
};
my( $gone_host, $gone_type, $gone ) = $mappings->row_as_nginx_config($directgov_cy_gone);
is( $gone_host, 'www.direct.gov.uk',
	'Host that config applies to is directgov' );
is( $gone_type, 'location',
	'If host is Directgov and type is gone, type of nginx block is location'  );
is( $gone, qq(location ~* ^/cy/Governmentcitizensandrights/Consumerrights/Protectyourselffromscams/DG_195967CY/?\$ { return 410; }\n),
    'Nginx config is as expected' );

$directgov_cy_gone = {
	'Old Url'	=> 'http://www.direct.gov.uk/cy/Pensionsandretirementplanning/EndOfLife/WhatToDoAfterADeath/DG_10027878CY',
	'New Url'	=> '',
	'Status'	=> 410,
};
( $gone_host, $gone_type, $gone ) = $mappings->row_as_nginx_config($directgov_cy_gone);
is( $gone_host, 'www.direct.gov.uk',
	'Host that config applies to is directgov' );
is( $gone_type, 'location',
	'If host is Directgov and type is gone, type of nginx block is location'  );
is( $gone, qq(location ~* ^/cy/Pensionsandretirementplanning/EndOfLife/WhatToDoAfterADeath/DG_10027878CY/?\$ { return 410; }\n),
    'Nginx config is as expected' );

my $directgov_gone = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/Dl1/Directories.html',
	'New Url'	=> '',
	'Status'	=> 410, 
};
( $gone_host, $gone_type, $gone ) = $mappings->row_as_nginx_config($directgov_gone);
is( $gone_host, 'www.direct.gov.uk', 
	'Host that config applies to is directgov' );
is( $gone_type, 'location',
	'If host is Directgov and type is gone, type of nginx block is location'  );
is( $gone, qq(location ~* ^/en/Dl1/Directories\\.html/?\$ { return 410; }\n),
    'Nginx config is as expected' );


my $directgov_redirect_awaiting_content = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/TravelAndTransport/Passports/Howtochangethenameonyourpassport.html',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag'	=> 'content-type:article section:travel-and-transport site:directgov source:mapping-exercise status:awaiting-content destination:content',
};
my( $awaiting_content_host, $awaiting_content_type, $awaiting_content ) = $mappings->row_as_nginx_config($directgov_redirect_awaiting_content);
is( $awaiting_content_host, 'www.direct.gov.uk', 
	'Host that config applies to is Directgov' );
is( $awaiting_content_type, 'location',
	'If host is Directgov and type is awaiting content, type of nginx block is location'  );
is( $awaiting_content, qq(location ~* ^/en/TravelAndTransport/Passports/Howtochangethenameonyourpassport\\.html/?\$ { return 302 https://www.gov.uk; }\n),
    'Nginx config is as expected' );



my $directgov_no_url_open = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/TravelAndTransport/Passports/Howtochangethenameonyourpassporttest.html',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag'	=> 'content-type:article section:travel-and-transport site:directgov source:mapping-exercise status:open destination:content',
};
my( $no_new_url_open_host, $no_new_url_open_type, $no_new_url_open_content ) = $mappings->row_as_nginx_config($directgov_no_url_open);
is( $no_new_url_open_host, 'www.direct.gov.uk', 
	'Host that config applies to is Directgov' );
is( $no_new_url_open_type, 'unresolved',
	"If status is 301, whole tag 'status' is open, and there is no new url, this should be flagged as unresolved."  );
is( $no_new_url_open_content, "http://www.direct.gov.uk/en/TravelAndTransport/Passports/Howtochangethenameonyourpassporttest.html\n",
    'The unresolved file will be populated with the URL.' );


my $directgov_no_url_closed = { 
	'Old Url'	=> 'http://www.direct.gov.uk/en/TravelAndTransport/Passports/Howtochangethenameonyourdrivinglicence.html',
	'New Url'	=> '',
	'Status'	=> 301,
	'Whole Tag'	=> 'content-type:article section:travel-and-transport site:directgov source:mapping-exercise status:closed destination:content',
};
my( $no_new_url_closed_host, $no_new_url_closed_type, $no_new_url_closed_content ) = $mappings->row_as_nginx_config($directgov_no_url_closed);
is( $no_new_url_closed_host, 'www.direct.gov.uk', 
	'Host that config applies to is Directgov' );
is( $no_new_url_closed_type, 'no_destination_error',
	"If status is 301, whole tag 'status' is closed, and there is no new url, this is a 'no destination' error."  );
is( $no_new_url_closed_content, "http://www.direct.gov.uk/en/TravelAndTransport/Passports/Howtochangethenameonyourdrivinglicence.html\n",
    "The 'no destination' error file will be populated with the URL." );

my $empty_row = undef;
my( $n_host, $no_type, $no_more ) = $mappings->row_as_nginx_config($empty_row);
ok( !defined $n_host,                      'no host when EOF' );
ok( !defined $no_type,                     'no type when EOF' );
ok( !defined $no_more,                     'no mapping when EOF' );