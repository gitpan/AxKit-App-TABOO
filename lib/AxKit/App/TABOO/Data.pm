package AxKit::App::TABOO::Data;
use strict;
use warnings;
use Carp;

use Data::Dumper;
use Class::Data::Inheritable;
use base qw(Class::Data::Inheritable);


our $VERSION = '0.07';


use DBI;
use Exception::Class::DBI;

use XML::LibXML;

=head1 NAME

AxKit::App::TABOO::Data - Base class of abstracted Data objects for TABOO

=head1 DESCRIPTION

You would rarely if ever use this class directly. Instead, you would call a subclass of this class, depending on what kind of data you are operating on. This class does, however, define some very useful methods that its subclasses can use unaltered.

It is to be noted that I have not, neither in this class nor in the subclasses, created methods to access or set every field. Instead, I rely mainly on methods that will manipulate internal data based on the for example objects that are passed as arguments. For example, the C<write_xml>-method (below), will create XML based on all the available data in the object. This is usually all you want anyway. 

In some subclasses, you will have some degree of control of what is loaded into the object data structure in the first place, by sending the names of the fields of the storage medium (e.g. database in the present implementation).

Similarly, if data is sent from a web application, the present implementation makes it possible to pass an L<Apache::Request> object to a Data object, and it is up to a method of the Data object to take what it wants from the Apache::Request object, and intelligently store it. 

Some methods to access data will be implemented on an ad hoc basis, notably C<timestamp()>-methods, that will be important in determining the validity of cached data. 

As of 0.05_1, there are also "Plural" subclasses. Sometimes you might want to retrieve more than one object from the data store, and do stuff on these objects as a whole. Furthermore, the load methods used to retrieve multiple objects may be optimized. This a conceptual change, and it'll take some time before it is being used in all parts of TABOO. 



=head2 Methods

=over

=item C<new()>

The constructor of this class. Rarely used. 

=cut

sub new {
    my $that  = shift;
    my $class = ref($that) || $that;
    my $self = {
		ONFILE => undef,
		XMLELEMENT => 'taboo',
		XMLNS => 'http://www.kjetil.kjernsmo.net/software/TABOO/NS/Output'
	       };

    bless($self, $class);
    return $self;
}


=item C<load(what => fields, limit => {key => value, [...]})>

Will load and populate the data structure of an object with the data
from a data store. It uses named parameters, the first C<what> is used
to determine which fields to retrieve. It is a string consisting of a
commaseparated list of fields, as specified in the data store. The
C<limit> argument is to be used to determine which records to
retrieve, and must be used to identify a record uniquely. It is itself
a reference to a hash, containing data store field values as keys and
values are corresponding values to retrieve. These will be combined by
logical AND.

If there is no data that corresponds to the given arguments, this method will return C<undef>.

=cut

sub load {
  my ($self, %args) = @_;
  my $data = $self->_load(%args);
  if ($data) {
    ${$self}{'ONFILE'} = 1;
  } else {
    return undef;
  }
  foreach my $key (keys(%{$data})) {
    ${$self}{$key} = ${$data}{$key}; 
  }
  return $self;
}


=item C<_load(what => fields, limit => {key => value, [...]})>

As the underscore implies this is B<for internal use only>! It is
intended to do the hard work for this class and its subclasses. It returns a hashref of the data from the datastore.


See the documentation for the C<load> method for the details on the parameters.

=cut

sub _load {
    my ($self, %args) = @_;
    my $what = $args{'what'};
    my %arg =  %{$args{'limit'}};
    my $dbh = DBI->connect($self->dbstring(), 
			   $self->dbuser(), 
			   $self->dbpasswd(),  
			   { PrintError => 1,
			     RaiseError => 0 # ,
			    # HandleError => Exception::Class::DBI->handler
			     });
    # The subclass should give the dbfrom.
    my $query = "SELECT " . $what . " FROM " . $self->dbfrom() . " WHERE ";
    my $i=0;
    my $nothing=1;
    my @keys = keys(%arg);
    foreach my $key (@keys) {
      $i++;
      next unless ($arg{$key});
      $nothing = 0;
      $query .= $key . "=?";
      if ($i <= $#keys) {
	$query .= " AND ";
      }
    }
#    warn $query;
    if ($nothing) {
      # Then, none of the fields were actually sent with a value, so
      # load won't return anything sensible...
      carp "No fields were sent with value, so no unique record can be found.";
      return undef;
    }
    my $sth = $dbh->prepare($query);
    $i=1;
#    warn Dumper(%arg);
    foreach my $key (@keys) {
      $sth->bind_param($i, $arg{$key});
      $i++;
    }
    $sth->execute();
    return $sth->fetchrow_hashref;
}

=item C<write_xml($doc, $parent)>

Takes arguments C<$doc>, which must be an L<XML::LibXML::Document>
object, and C<$parent>, a reference to the parent node. The method
will append the object it is handed it with the data contained in the
data structure of the class in XML. This method is the jewel of this
class, it should be sufficiently generic to rarely require
subclassing. References to subclasses will be followed, and
C<write_xml> will call the C<write_xml> of that object. Arrays will be
represented with multiple instances of the same element. Fields that
have undefined values will not be included.

=cut


sub write_xml {
    my $self = shift;
    my $doc = shift;
    my $parent = shift;
    my $topel = $doc->createElementNS($self->xmlns(), $self->xmlelement());
    $parent->appendChild($topel);
    foreach my $key (split(/,\s*/, $self->elementorder())) {
      if (defined(${$self}{$key})) {
	my $content = ${$self}{$key};
	if (ref($content) eq '') {
	  my $element = $doc->createElementNS($self->xmlns(), $key);
	  my $text = XML::LibXML::Text->new($content);
	  $element->appendChild($text);
	  $topel->appendChild($element);
	} elsif (ref($content) eq "ARRAY") {
	  # The content is an array, we must go through it and add an element for each.
	  foreach (@{$content}) {
	    if (ref($_) eq '') {
	      my $element = $doc->createElementNS($self->xmlns(), $key);
	      my $text = XML::LibXML::Text->new($_);
	      $element->appendChild($text);
	      $topel->appendChild($element);
	    } else {
	      my $el = ${$_};
	      if (ref($el) =~ m/^AxKit::App::TABOO::Data/) {
		# An element in the array contained a reference to one of our subclasses, it must be written too. 
		$el->write_xml($doc, $topel);
	      }
	    }
	  }
	} elsif (ref(${$content}) =~ m/^AxKit::App::TABOO::Data/) {
	  # a reference to one of our subclasses, it must be written too. 
	  ${$content}->write_xml($doc, $topel);
        } else {
	  my $element = $doc->createElementNS($self->xmlns(), $key);
	  my $text = XML::LibXML::Text->new($content);
	  $element->appendChild($text);
	  $topel->appendChild($element);
        }
      }
    }
    return $doc;
}

=item C<populate(\%args)>

This method takes as argument a reference to a hash and will populate the data object by adding any data from a key having the same name as is used in the data storage. Fields that are not specified by the data object or that has uppercase letters are ignored. 

It may be used to insert data from an L<Apache::Request> object by first noting that in a HTTP request, the Request object is available as C<$r>, so you may create the hash to hand to this method by 

    my %args = $r->args;

=cut


sub populate {
    my $self = shift;
    my $args = shift;
    foreach my $key (keys(%{$self})) {
	next if ($key =~ m/[A-Z]/); # Uppercase keys are not in db
	${$self}{$key} = ${$args}{$key};
    }
    return $self;
}

=item C<apache_request_changed(\%args)>

Like the above method, this method takes as argument a reference to the args hash of a L<Apache::Request> object. Instead of populating the Data object, it will compare the C<\%args> with the contents of the object and return an array of fields that differs between the two. Fields that are not specified by the data object, that has uppercase letters or has no value, are ignored.


=cut


sub apache_request_changed {
    my $self = shift;
    my $args = shift;
    my @keys;
    foreach my $key (keys(%{$self})) {
	next if ($key =~ m/[A-Z]/); # Uppercase keys are not in db
	next unless defined(${$args}{$key}); # if it isn't there, we don't care.
	if (${$self}{$key} ne ${$args}{$key}) {
	  push(@keys, $key);
	}
    }
    return @keys;
}


=item C<save([$olddbkey])>

This is a generic save method, that will write a new record to the data store, or update an old one. It may have to be subclassed for certain classes. It takes an optional argument C<$olddbkey>, which is the primary key of an existing record in the data store. You may supply this in the case if you want to update the record with a new key. In that case, you'd better be sure it actually exists, because the method will trust you do. 

It is not yet a very rigorous implementation: It may well fail badly if it is given something with a reference to other Data objects, which is the case if you have a full story with all comments. Or it may cope. Only time will tell! Expect to see funny warnings in your logs if you try.


=cut

sub save {
  my $self = shift;
  my $olddbkey = shift;
  my $dbh = DBI->connect($self->dbstring(),
			 $self->dbuser(),
			 $self->dbpasswd());
#			 { PrintError => 1,
#			   RaiseError => 0,
#			   HandleError => Exception::Class::DBI->handler
#			   });
  my @fields;
  my $i=0;
  foreach my $key (keys(%{$self})) {
      next if ($key =~ m/[A-Z]/); # Uppercase keys are not in db
      next unless defined(${$self}{$key}); # No need to insert something that isn't there
      push(@fields, $key);
      $i++;
  }
  if ($i == 0) {
      carp "No data fields with anything to save";
  } else {
      my $sth;
      my $dbkey = ${$self}{$self->dbprimkey()};
      # First we check if we should update rather than insert
      if (($olddbkey) || ($self->stored)) {
	${$self}{'ONFILE'} = 1;
	# Yep, we update, but do we change the primary key?
	if ($olddbkey) { 
	  $dbkey = $olddbkey;
	}
	$sth = $dbh->prepare("UPDATE ". $self->dbtable() . " SET " . join('=?,', @fields) . "=? WHERE " . $self->dbprimkey() . "=?");
	
      } else {
	$sth = $dbh->prepare("INSERT INTO ". $self->dbtable() . " (" . join(',', @fields) . ") VALUES (" . '?,' x ($i-1) . '?)');
      }
      $i = 1;
      foreach my $key (@fields) {
	  my $content = ${$self}{$key};
	  if (ref($content) eq '') {
	      $sth->bind_param($i, $content);
	  } elsif (ref($content) eq "ARRAY") {
	      # The content is an array, save it as such, ad hoc SQL3 for now.
	      $sth->bind_param($i, "{" . join(',', @{$content}) . "}");
	  } else {
	      warn "Advanced forms of references aren't implemented meaningfully yet. Don't be surprised if I crash or corrupt something.";
	      ${$content}->save(); # IOW: Panic!! Everybody save yourselves if you can! :-)
	  }
	  $i++;
      }
      if (${$self}{'ONFILE'}) {
	  $sth->bind_param($i, $dbkey);
      }
      $sth->execute();
  }
  return $self;
}


=item C<stored()>

Checks if a record with the present object's identifier is allready present in the datastore. Returns 1 if this is so. 

=cut


sub stored {
  my $self = shift;
  return 1 if ${$self}{'ONFILE'};
  my $dbh = DBI->connect($self->dbstring(),
			 $self->dbuser(),
			 $self->dbpasswd(),
			 { PrintError => 0,
			   RaiseError => 0,
			   HandleError => Exception::Class::DBI->handler
			 });
  my $check = scalar($dbh->selectrow_array("SELECT 1 FROM " . $self->dbtable() . " WHERE " . $self->dbprimkey() . "=?", {}, ${$self}{$self->dbprimkey()}));
  ${$self}{'ONFILE'} = $check;
  return $check;
}


=item C<onfile>

Method to set a flag to indicate that the record is in the data store.

=cut

  
sub onfile {
  my $self = shift;
  ${$self}{'ONFILE'} = 1;
  return $self;
}

=item C<xmlelement($string)>

This method is I<intended> for internal use, but if you can use it without shooting somebody in the foot (including yourself), fine by me... It sets the root element that will enclose an object's data to C<$string>.

=cut


sub xmlelement {
  my $self = shift;
  if (@_) { 
    ${$self}{'XMLELEMENT'} = shift;
  }
  return ${$self}{'XMLELEMENT'};
}

=item C<xmlns($string)>

Like  C<xmlelement()>, this method is I<intended> for internal use. It sets the namespace URI of the XML representation of an object to C<$string>.

=cut



sub xmlns {
  my $self = shift;
  if (@_) { 
    ${$self}{'XMLNS'} = shift;
  }
  return ${$self}{'XMLNS'};
}


=back

=head2 Class Data Methods


=over

=item C<dbstring($string)>

A string to be passed to the DBI constructor. Currently defaults to C<"dbi:Pg:dbname=skepsis">. Yeah, it will change... 


=item C<dbuser($string)>

The user name to be passed to the DBI constructor. Currently defaults to C<'www-data'>. 

=item C<dbpasswd($string)>

The password to be passed to the DBI constructor. Currently defaults to an empty string. 



=back

=cut


#=item C<elementorder($string)>

#This string contains a comma-separated list of all fields of a class that will be included in the XML, and in the order specified.


# Some inheritable methods and defaults
AxKit::App::TABOO::Data->mk_classdata('dbstring');
AxKit::App::TABOO::Data->mk_classdata('dbuser');
AxKit::App::TABOO::Data->mk_classdata('dbpasswd');
AxKit::App::TABOO::Data->mk_classdata('dbfrom');
AxKit::App::TABOO::Data->mk_classdata('dbtable');
AxKit::App::TABOO::Data->mk_classdata('dbprimkey');
AxKit::App::TABOO::Data->mk_classdata('elementorder');

AxKit::App::TABOO::Data->dbstring("dbi:Pg:dbname=skepsis");
AxKit::App::TABOO::Data->dbuser("www-data");
AxKit::App::TABOO::Data->dbpasswd("");


=head1 STORED DATA

The data is stored in named fields, currently in a database, but there is nothing stopping you from subclassing the Data classes and storing it somewhere else. TABOO should work well, but if you want to make it less painful for yourself, you should use the same names or provide some kind of mapping between your names and the names in these Data classes. Note that any similarity between these names and the internal names of this class is purely coincidential (eh, not really). 

Consult the documentation for each individual Data class for the names of the stored data. 


=head1 BUGS/TODO

Except for still being in alpha, and should have a few bugs, there is the issue with the handling of references to other objects in the C<save()> method. It's possible it will cope, but it definately needs work.

Every load-type method should throw an exception or do something similar if it finds that the record it tries to retrieve doesn't exist. 


=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1;
