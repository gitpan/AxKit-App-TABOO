package AxKit::App::TABOO::Data::Plurals;
use strict;
use warnings;
use Carp;

use Data::Dumper;
use AxKit::App::TABOO::Data;



use vars qw/@ISA/;
@ISA = qw(AxKit::App::TABOO::Data);

use DBI;
use Exception::Class::DBI;


our $VERSION = '0.05_1';


=head1 NAME

AxKit::App::TABOO::Data::Plurals - Base class to handle multiple Data objects in TABOO

=head1 DESCRIPTION

Sometimes, it is desireable to retrieve and handle multiple instances of a data object, and most economic to do it in a single operation. That is what the Plural data objects are for. The load methods should generally retrieve all records as efficiently as they can, and then return an array of their singular counterparts.

This is a conceptual advancement in TABOO, and the main reason for this release.

=head1 METHODS

It (re)implements some methods, but nothing you really need to be aware of. If you want to raise your awareness anyway, this is for you:

=over

=item C<_load(\%arg)>

As the underscore implies this is B<for internal use only>! It can do the hard work for subclasses of this class. It takes a hashref where the keys are data storage names and the values are corresponding values to retrieve. These will be combined by logical AND. It will return an arrayref containing the data from the storage. 

=cut

sub _load {
  my ($self, %args) = @_;
  my $what = $args{'what'};
  my %arg =  %{$args{'limit'}};
  my $dbh = DBI->connect($self->dbstring(), 
			 $self->dbuser(), 
			 $self->dbpasswd(),  
			 { PrintError => 0,
			   RaiseError => 0,
			   HandleError => Exception::Class::DBI->handler
			 });
  my $query = "SELECT " . $what . " FROM " . $self->dbfrom() . " WHERE ";
  my $i=1;
  my @keys = keys(%arg);
  foreach my $key (@keys) {
    $query .= $key . "=?";
    if ($i <= $#keys) {
      $query .= " AND ";
    }
    $i++;
  }
  my $sth = $dbh->prepare($query);
  $i=1;
  foreach my $key (@keys) {
    $sth->bind_param($i, $arg{$key});
    $i++;
  }
  $sth->execute();
  return $sth->fetchall_arrayref({});
}


=item C<write_xml($doc, $parent)>

To avoid bloating the parent class too much, this takes care of some
specifics for plurals, but leaves most of the job to the parent
class. Has a completely identical interface as the parent class, and can be called like it without further ado. 

=cut

sub write_xml {
  my $self = shift;
  my $doc = shift;
  my $parent = shift;
  foreach my $entry (@{${$self}{ENTRIES}}) {
    $entry->write_xml($doc, $parent);
  }
  return $doc;
}

=back

=head1 BUGS/TODO

The save method is not yet reimplemented and may not work.

=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1;





