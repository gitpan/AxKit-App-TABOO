
package AxKit::App::TABOO::Data;
use strict;
use warnings;
use Carp;

use Data::Dumper;
use Class::Data::Inheritable;
use base qw(Class::Data::Inheritable);


use DBI;
use XML::Writer;


=head1 NAME

AxKit::App::TABOO::Data - Base class of abstracted Data objects for TABOO

=head1 DESCRIPTION

You would rarely if ever use this class directly. Instead, you would call a subclass of this class, depending on what kind of data you are operating on. This class does, however, define some very useful methods that its subclasses can use unaltered.

It is to be noted that I have not, neither in this class nor in the subclasses, created methods to access or set every field. Instead, I rely mainly on methods that will manipulate internal data based on the for example objects that are passed as arguments. For example, the C<write_xml>-method (below), will create XML based on all the available data in the object. This is usually all you want anyway. 

In some subclasses, you will have some degree of control of what is loaded into the object data structure in the first place, by sending the names of the fields of the storage medium (e.g. database in the present implementation).

Similarly, if data is sent from a web application, I expect that the Data objects will be passed an Apache::Request object, and it is up to a method of the Data object to take what it wants from the Apache::Request object, and intelligently store it. 

Some methods to access data will be implemented on an ad hoc basis, notably C<timestamp()>-methods, that will be important in determining the validity of cached data. 



=head2 Methods

=over

=item C<new()>

The constructor of this class. Rarely used. 

=cut

sub new {
    my $that  = shift;
    my $username = shift;
    my $class = ref($that) || $that;
    my $self = {
		XMLELEMENT => 'taboo'
	       };

    bless($self, $class);
    return $self;
}

=item C<load($key)>

Will load and populate the data structure of an instance with the data from a the data source, given a key in the string C<$key>. 

=cut

sub load {
    my $self = shift;
    my $dbkey = shift;
    my $dbhandle = DBI->connect($self->dbstring(), $self->dbuser(), $self->dbpasswd());
    # just get the data, the subclass should give of the dbquery.
    my $sth = $dbhandle->prepare($self->dbquery());
    $sth->execute($dbkey);
    my $data = $sth->fetchrow_hashref;
    # DB fields are lower case, class fields are upper. 
    foreach my $key (keys(%{$data})) {
      (my $up = $key) =~ tr/[a-z]/[A-Z]/;
      ${$self}{$up} = ${$data}{$key}; 
    }
    $sth->finish;
    $dbhandle->disconnect;
    return $self;
}

=item C<write_xml($writer)>

Takes an argument C<$writer>, which must be an XML::Writer object, and appends it with the data contained in the data structure of the class in XML. This method is the jewel of this class, it should be sufficiently generic to rarely require subclassing. References to subclasses will be followed, and C<write_xml> will call the C<write_xml> of that object. Arrays will be represented with multiple instances of the same element. Fields that have undefined values will be represented by an empty element. 

=cut


sub write_xml {
    my $self = shift;
    my $writer = shift;
    $writer->startTag($self->xmlelement());
    foreach my $key (split(/,\s*/, $self->elementorder())) {
      # Fields are in uppercase, elements in lower
      (my $low = $key) =~ tr/[A-Z]/[a-z]/;
      if (defined(${$self}{$key})) {
	my $content = ${$self}{$key};
	if (ref($content) eq '') {
	  $writer->dataElement($low, $content);
	} elsif (ref($content) eq "ARRAY") {
	  # The content is an array, we must go through it and add an element for each.
	  foreach (@{$content}) {
	    if (ref($_) eq '') {
	      $writer->dataElement($low, $_);
	    } else {
	      my $el = ${$_};
	      if (ref($el) =~ m/^AxKit::App::TABOO::Data/) {
		# An element in the array contained a reference to one of our subclasses, it must be written too. 
		$el->write_xml($writer);
	      }
	    }
	  }
	} elsif (ref(${$content}) =~ m/^AxKit::App::TABOO::Data/) {
	  # a reference to one of our subclasses, it must be written too. 
	  ${$content}->write_xml($writer);
        } else {
	  $writer->dataElement($low, $content);
        }
      } else {
	$writer->emptyTag($low);
      }
    }
    $writer->endTag($self->xmlelement());
    return $writer;
}

=item C<xmlelement($string)>

This method is I<intended> for internal use, but if you can use it without shooting somebody in the foot (including yourself), fine by me... It sets the parent element of an object to C<$string>.

=cut



sub xmlelement {
  my $self = shift;
  if (@_) { 
    ${$self}{'XMLELEMENT'} = shift;
  }
  return ${$self}{'XMLELEMENT'};
}

=item C<_addinfo($add, $this, $that)>

B<This method is for use by subclasses only.> It can be used by methods like C<adduserinfo()>, and will be used to replace a field (C<$this>) with another field (C<$that>) containing a reference to a different class that will be added, C<$add>. 

=back

=cut

sub _addinfo {
    my $self = shift;
    my $add = shift;
    my $this = shift;
    my $that = shift;
    if (${$self}{$this}) {
      if (ref($add) eq 'AxKit::App::TABOO::Data::User') {
	$add->load_name(${$self}{$this});
      } else {
	$add->load(${$self}{$this});
      }
      ${$self}{$that} = \$add;
    } else {
      carp $this . " had no value to replace.";
    }
    return $self;
}



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

#=item C<dbquery($string)>
#
#The load method of the present class will use this string as a SQL statement. This is a relatively simple way for subclasses to use the load method rather than implement their own. It can be used in the cases where the query is specific to the class rather than the specific instances. I<It is intended for use by subclasses only.>

#=item C<elementorder($string)>

#This string contains a comma-separated list of all fields of a class that will be included in the XML, and in the order specified.


# Some inheritable methods and defaults
AxKit::App::TABOO::Data->mk_classdata('dbstring');
AxKit::App::TABOO::Data->mk_classdata('dbuser');
AxKit::App::TABOO::Data->mk_classdata('dbpasswd');
AxKit::App::TABOO::Data->mk_classdata('dbquery');
AxKit::App::TABOO::Data->mk_classdata('elementorder');

AxKit::App::TABOO::Data->dbstring("dbi:Pg:dbname=skepsis");
AxKit::App::TABOO::Data->dbuser("www-data");
AxKit::App::TABOO::Data->dbpasswd("");


=head1 STORED DATA

The data is stored in named fields, currently in a database, but there is nothing stopping you from subclassing the Data classes and storing it somewhere else. TABOO should work well, but if you want to make it less painful for yourself, you should use the same names or provide some kind of mapping between your names and the names in these Data classes. Note that any similarity between these names and the internal names of this class is purely coincidential (eh, not really). 

Consult the documentation for each individual Data class for the names of the stored data. 


=head1 BUGS/TODO

Hey, it is a pre-alpha!

=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1;

