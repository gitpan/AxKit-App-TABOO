package AxKit::App::TABOO::Data::Plurals::Productsubtypes;
use strict;
use warnings;
use Carp;

use Data::Dumper;
use AxKit::App::TABOO::Data;
use AxKit::App::TABOO::Data::Productsubtype;
use AxKit::App::TABOO::Data::Plurals;


use vars qw/@ISA/;
@ISA = qw(AxKit::App::TABOO::Data::Plurals);


use DBI;
use Exception::Class::DBI;


our $VERSION = '0.011_1';

AxKit::App::TABOO::Data::Plurals::Productsubtypes->dbtable("productsubtypes");
AxKit::App::TABOO::Data::Plurals::Productsubtypes->dbfrom("productsubtypes");

=head1 NAME

AxKit::App::TABOO::Data::Plurals::Productsubtypes - Data objects to handle multiple Product sub types in TABOO

=head1 DESCRIPTION

=head2 Methods

=over

=item C<new()>

The constructor. Nothing special.

=cut

sub new {
    my $that  = shift;
    my $class = ref($that) || $that;
    my $self = {
	ENTRIES => [], # Internally, some methods finds it useful that the entries are stored in a array of this name.
	XMLELEMENT => undef,
	XMLNS => undef,
	ONFILE => undef,
    };
    bless($self, $class);
    return $self;
}


=item C<load(what => fields, limit => {key => value, [...]})>

It takes a hashref where the keys are data storage names and the values are corresponding values to retrieve. These will be combined by logical AND. It will retrieve the data, and then call C<populate()> for each of the records retrieved to ensure that the plural data objects actually consists of an array of L<AxKit::App::TABOO::Data::Productsubtype>s. But it calls the internal C<_load()>-method to do the hard work (and that's in the parent class).

=cut


sub load {
  my ($self, %args) = @_;
  my @prodsubs;
  my $data = $self->_load(%args); # Does the hard work
  foreach my $entry (@{$data}) {
    my $prodsub = AxKit::App::TABOO::Data::Productsubtype->new();
    $prodsub->populate($entry);
    $prodsub->onfile;
    push(@prodsubs, $prodsub);
  }
  ${$self}{ENTRIES} = \@prodsubs;
  return $self;
}

=back

=head1 BUGS/TODO

This class has not seen a lot of testing, and the documentation really needs more work. 

=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1;



