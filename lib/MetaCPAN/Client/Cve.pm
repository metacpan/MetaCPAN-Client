use strict;
use warnings;
package MetaCPAN::Client::Cve;
# ABSTRACT: A CVE data object

use Moo;

with 'MetaCPAN::Client::Role::Entity';

my %known_fields = (
    scalar   => [qw< cpansa_id description distribution reported severity >],
    arrayref => [qw< affected_versions cves references releases versions >],
    hashref  => [],
);

my @known_fields =
    map { @{ $known_fields{$_} } } qw< scalar arrayref hashref >;

foreach my $field (@known_fields) {
    has $field => (
        is      => 'ro',
        lazy    => 1,
        default => sub {
            my $self = shift;
            return $self->data->{$field};
        },
    );
}

sub _known_fields { return \%known_fields }

1;

__END__

=head1 SYNOPSIS

    # Get a specific CVE by CPANSA ID
    my $cve = $mcpan->cve('CPANSA-DBD-SQLite-2019-5018');
    print $cve->distribution;  # 'DBD-SQLite'
    print $cve->severity;      # e.g., 'high'

    # Search for CVEs by distribution
    my $cve_resultset = $mcpan->cve({ distribution => 'DBD-SQLite' });
    while (my $cve = $cve_resultset->next) {
        print $cve->cpansa_id, "\n";
    }

    # Search for CVEs by severity
    my $cve_resultset = $mcpan->cve({ severity => 'high' });

    # Search for CVEs by CVE ID - requires all() with ElasticSearch query
    my $by_cve_id_resultset = $mcpan->all('cve', { es_filter => { 'match_phrase' => { 'cves' => 'CVE-2026-5083' } } });
    while (my $cve = $by_cve_id_resultset->next) {
        print $cve->cpansa_id, "\n";
    }

    # Get all CVEs
    my $all_cves = $mcpan->all('cve');

=head1 DESCRIPTION

A MetaCPAN CVE (CPAN Security Advisory) entity object.

=head2 How to get CVE objects

There are several ways to retrieve CVE objects:

=over 4

=item 1. By CPANSA ID (returns single object)

    my $cve = $mcpan->cve('CPANSA-DBD-SQLite-2019-5018');

The CPANSA ID format is: C<CPANSA-DistributionName-YYYY-NNNNN>

=item 2. By search criteria (returns ResultSet)

    # Search by distribution name (use dashes, not ::)
    my $cve_resultset = $mcpan->cve({ distribution => 'YAML-Syck' });

    # Search by severity
    my $cve_resultset = $mcpan->cve({ severity => 'high' });

    # Search by reported date
    my $cve_resultset = $mcpan->cve({ reported => '2024-01-01' });

Then iterate through results:

    while (my $cve = $cve_resultset->next) {
        # process each CVE
    }

=item 3. By CVE ID (requires ElasticSearch query)

B<Note:> The C<cves> field is not a supported search parameter for the C<cve()> method.
To search by CVE ID, use C<all()> with an ElasticSearch query:

    my $cve_resultset = $mcpan->all('cve', { es_filter => { 'match_phrase' => { 'cves' => 'CVE-2026-5083' } } });
    while (my $cve = $cve_resultset->next) {
        print $cve->cpansa_id, "\n";
    }

=item 4. All CVEs

    my $all_cve_resultset = $mcpan->all('cve');

=back

=head1 ATTRIBUTES

=head2 cpansa_id

Returns the CPAN Security Advisory Database id

=head2 description

The CVE description

=head2 distribution

The CPAN distribution

=head2 reported

The reporting date of the CVE

=head2 severity

The severity of the CVE

=head2 affected_versions

Ranges of CPAN affected versions

=head2 cves

List of CVEs

=head2 references

List of references (URLs)

=head2 releases

List of CPAN releases

=head2 versions

Extracted list of existing CPAN releases
