package AxKit::App::TABOO::Data::Plurals::Stories;
use strict;
use warnings;
use Carp;

use Data::Dumper;
use AxKit::App::TABOO::Data;
use AxKit::App::TABOO::Data::Story;
use AxKit::App::TABOO::Data::Plurals;


use vars qw/@ISA/;
@ISA = qw(AxKit::App::TABOO::Data::Plurals);

use DBI;
use Exception::Class::DBI;


our $VERSION = '0.01';

AxKit::App::TABOO::Data::Plurals::Stories->dbtable("stories");
AxKit::App::TABOO::Data::Plurals::Stories->dbfrom("stories");


=head1 NAME

AxKit::App::TABOO::Data::Plurals::Stories - Data objects to handle multiple Stories in TABOO

=head1 DESCRIPTION

Often, you want to retrieve many different stories from the data store, for example all belonging to a certain category or a certain section. This is a typical situation where this class shoule be used.

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
	XMLELEMENT => 'stories',
	XMLNS => 'http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output',
    };
    bless($self, $class);
    return $self;
}


=item C<load(what => fields, limit => {key => value, [...]})>

It takes a hashref where the keys are data storage names and the values are corresponding values to retrieve. These will be combined by logical AND. It will retrieve the data, and then call C<populate()> for each of the records retrieved to ensure that the plural data objects actually consists of an array of L<AxKit::App::TABOO::Data::Story>s. But it calls the internal C<_load()>-method to do the hard work (and that's in the parent class).

=cut


sub load {
  my ($self, %args) = @_;
  my @cats;
  my $data = $self->_load(%args); # Does the hard work
  foreach my $entry (@{$data}) {
    my $cat = AxKit::App::TABOO::Data::Story->new();
    $cat->populate($entry);
    $cat->onfile;
    push(@cats, $cat);
  }
  ${$self}{ENTRIES} = \@cats;
  return $self;
}

=back

=head1 BUGS/TODO


=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1;


