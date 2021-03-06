package SourcesTest;

use v5.10;
use strict;
use warnings;

use Test::More;
use Text::CSV;
use HTTP::Request;
use LWP::UserAgent;
use URI;


sub new {
    my $class = shift;
    my $file  = shift;

    my $self = {
            input_file => $file,
        };
    bless $self, $class;

    return $self;
}

sub run_tests {
    my $self = shift;

    my $csv = Text::CSV->new({ binary => 1 })
                or die "Cannot use CSV: " . Text::CSV->error_diag();

    open( my $fh, "<", $self->{'input_file'} )
            or die "$self->{'input_file'}: $!";

    my $names = $csv->getline( $fh );
    $csv->column_names( @$names );

    while ( my $row = $csv->getline_hr( $fh ) ) {
        $self->test($row);
    }

    done_testing();
}

sub test_source_line {
    my $self = shift;
    my $row  = shift;

    # only test closed sources
    my $mapping_status = lc($row->{'Whole Tag'} // '');
    return if $mapping_status && $mapping_status !~ m{\bclosed\b};

    my $old_url = $row->{'Old Url'};
    ok(
        $old_url ne '#REF!',
        "Old Url '${old_url}' should not be '#REF!'"
    );
    ok(
        $old_url =~ m{^https?://},
        "Old Url '${old_url}' should be a full URL"
    );

    # strip leading/trailing whitespace before comparing
    $old_url =~ s{^\s*(.*?)\s*$}{$1};
    my $old_uri = URI->new($old_url);
    is(
        $old_uri,
        $old_url,
        "Old Url '${old_url}' should be a valid URL"
    );

    my $new_url = $row->{'New Url'};
    ok(
        $new_url !~ m{^http://www.gov.uk},
        "'${old_url}' points to '${new_url}' - should point to HTTPS"
    );

    if ( "301" eq $row->{'Status'} && $new_url ne '' ) {
        # strip leading/trailing whitespace before comparing
        $new_url =~ s{^\s*(.*?)\s*$}{$1};
        my $new_uri = URI->new($new_url);

        ok(
            $new_url =~ m{^https?://},
            "${new_url} (from ${old_url}) should be a full URL"
        );
        is(
            $new_uri,
            $new_url,
            "${new_url} (from ${old_url}) should be a valid URL"
        );
    }
}

1;
