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


our $VERSION = '0.07';


=head1 NAME

AxKit::App::TABOO::Data::Plurals - Base class to handle multiple Data objects in TABOO

=head1 DESCRIPTION

Sometimes, it is desireable to retrieve and handle multiple instances of a data object, and most economic to do it in a single operation. That is what the Plural data objects are for. The load methods should generally retrieve all records as efficiently as they can, and then return an array of their singular counterparts.

This is a conceptual advancement in TABOO, and the main new thing in the 0.05 release.

=head1 METHODS

It implements a single new method, with a name that should ring bells
for everyone. It also reimplements some methods, but nothing you
really need to be aware of. If you want to raise your awareness
anyway, the documentation of them is for you:

=over



=item C<Push($singular)>

This does pretty much what C<push> does in a normal context, it adds a singular version C<$singular> of a object to the plural object that the method is used on. 

=cut

sub Push {
  my $self = shift;
  my $singular = shift;
  push(@{${$self}{ENTRIES}}, $singular);
  return $self;
}



=item C<Grep($pattern, $field)>

Somewhat similar to the usual C<grep> function, but takes as argument
a pattern to search for, but I<not> enclosed in slashes, and which
data field to look in. Will return an object of the same class with
the records that matched, or C<undef> if there were no matches.

=cut

sub Grep {
  my $self = shift;
  my $pattern = shift;
  my $field = shift;
  my $work = ref($self)->new();
  my $one;
  foreach my $tmp (@{${$self}{ENTRIES}}) {
    if (${$tmp}{$field} =~ m/$pattern/) {
      $work->Push($tmp);
      $one = 1;
    }
  }
  if ($one) {
    return $work;
  } else {
    return undef;
  }
}



=item C<_load(%args)>

As the underscore implies this is B<for internal use only>! It can do
the hard work for subclasses of this class. It uses named parameters,
the first C<what> is used to determine which fields to retrieve. It is
a string consisting of a commaseparated list of fields, as specified
in the data store. The C<limit> argument is to be used to determine
which records to retrieve, these will be combined by logical AND. You
may also supply a C<orderby> argument, which is an expression used to
determine the order of entries returned. Usually, it would be a simple
string with the field name to use, e.g. C<'timestamp'>, but you might
want to append the keyword "C<DESC>" to it for descending
order. Finally, you may supply a C<entries> argument, which is the
maximum number of entries to retrieve.  It will return an arrayref
containing the data from the storage.

=cut

sub _load {
  my ($self, %args) = @_;
  my $what = $args{'what'};
  my %arg =  %{$args{'limit'}};
  my $orderby = $args{'orderby'};
  my $entries = $args{'entries'};
  my $dbh = DBI->connect($self->dbstring(), 
			 $self->dbuser(), 
			 $self->dbpasswd(),  
			 { PrintError => 0,
			   RaiseError => 0,
			   HandleError => Exception::Class::DBI->handler
			 });
  my $query = "SELECT " . $what . " FROM " . $self->dbfrom();
  if (%arg) {
    $query .= " WHERE ";
  }
  my $i=1;
  my @keys = keys(%arg);
  foreach my $key (@keys) {
    $query .= $key . "=?";
    if ($i <= $#keys) {
      $query .= " AND ";
    }
    $i++;
  }
  if ($orderby) {
    $query .= ' ORDER BY ' . $orderby;
  }
  if ($entries) {
    $query .= ' LIMIT ' . $entries;
  }

  my $sth = $dbh->prepare($query);
  $i=1;
  foreach my $key (@keys) {
    $sth->bind_param($i, $arg{$key});
    $i++;
  }
# Couldn't get parameter binding to work, but they should be passed OK...:
#  if ($orderby) {
#    $sth->bind_param($i, $orderby);
#    $i++;
#  }
#  if ($entries) {
#    $sth->bind_param($i, $entries);
#  }

  $sth->execute();
  return $sth->fetchall_arrayref({});
}


=item C<write_xml($doc, $parent)>

To avoid bloating the parent class too much, this takes care of some
specifics for plurals, but leaves most of the job to the parent
class. Has a completely identical interface as the parent class, and
can be called like it without further ado.

If an object of this class has had its element and/or namespace set
with C<xmlelement()>/C<xmlns()> respectively, the individual entries
will have the same element and/or namespace.

=cut

sub write_xml {
  my $self = shift;
  my $doc = shift;
  my $parent = shift;
  foreach my $entry (@{${$self}{ENTRIES}}) {
    # If the object has had its element and/or NS set to something, we pass it on.
    if (${$self}{XMLELEMENT}) {
      $entry->xmlelement($self->xmlelement());
    }
    if (${$self}{XMLNS}) {
      $entry->xmlns($self->xmlns());
    }

    $entry->write_xml($doc, $parent);
  }
  return $doc;
}

sub populate {
  die "populate method not yet implemented for Plurals";
}

sub apache_request_changed {
  die "apache_request_changed method not yet implemented for Plurals";
}

sub stored {
  die "stored method not yet implemented for Plurals";
}


sub onfile {
  die "onfile method not yet implemented for Plurals";
}


=back

=head1 BUGS/TODO

The save method is not yet reimplemented and may not work.

=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1;





