package AxKit::App::TABOO::Data::Productprices;
use strict;
use warnings;
use Carp;

use AxKit::App::TABOO::Data;
use vars qw/@ISA/;
@ISA = qw(AxKit::App::TABOO::Data);

use DBI;

our $VERSION = '0.01';


=head1 NAME

AxKit::App::TABOO::Data::Productprices - Data object for product prices for TABOO-based Webshop.

=head1 SYNOPSIS

  use AxKit::App::TABOO::Data::Product;
  $product = AxKit::App::TABOO::Data::Product->new();
  $product->load('t-shirt');


=head1 DESCRIPTION

This Data class contains a price structure for a product. The price structure is meant to take into account that the price may be vary with the number of items ordered. This is represented by a threshold volume, and the price of a single item for up to and including that threshold.

=cut


#AxKit::App::TABOO::Data::Product->dbtable("products");
#AxKit::App::TABOO::Data::Product->dbprimkey("prodid");
#AxKit::App::TABOO::Data::Product->elementorder("prodid, catname, title, descr, imgsmallurl, imglargeurl, imgcaption, comment, productsubtypes,	volume,	price");

=head1 METHODS

This class reimplements two methods in addition to the constructor, the rest is inherited from L<AxKit::App::TABOO::Data>.

=over

=item C<new()>

The constructor. Nothing special.

=cut

sub new {
    my $that  = shift;
    my $class = ref($that) || $that;
    my $self = {
	prodid => undef,
	price => undef,
	XMLELEMENT => 'price',
	XMLNS => 'http://www.kjetil.kjernsmo.net/software/TABOO/NS/Product/Output',
	ONFILE => undef,
    };
    bless($self, $class);
    return $self;
}

=item C<load($prodid)>

This reimplemented load method takes as argument a product ID, a string used to identify a product.

=cut 

sub load {
  my $self = shift;
  my $prodid = shift;
  my $dbh = DBI->connect($self->dbstring(), 
			 $self->dbuser(), 
			 $self->dbpasswd(),  
			 { PrintError => 0,
			   RaiseError => 0,
			   HandleError => Exception::Class::DBI->handler
			   });
  my $data = $dbh->selectcol_arrayref("SELECT volume, price FROM productprices WHERE prodid=?",
 					 { Columns=>[1,2] },
					 $prodid);
  my %tmp = @$data;
  ${$self}{'price'} = \%tmp;
  ${$self}{'prodid'} = $prodid;
  ${$self}{'ONFILE'} = 1;
  return $self;
}


=item C<write_xml($doc, $parent)>

This class reimplements the C<write_xml>-method, which takes arguments C<$doc>, which must be an L<XML::LibXML::Document> object, and C<$parent>, a reference to the parent node. The method will append the object it is handed it with the data contained in the data structure of the class in XML. 

The price structure will be represented with a price element, containing the product ID in an attribute C<prodid> and the threshold volume in an attribute C<volume>, and the corresponding price is in the element content.


=cut

sub write_xml {
    my $self = shift;
    my $doc = shift;
    my $parent = shift;
    foreach my $volume (keys(%{${$self}{'price'}})) {
      my $topel = $doc->createElementNS($self->xmlns(), $self->xmlelement());
      $parent->appendChild($topel);
      my $text = XML::LibXML::Text->new(${${$self}{'price'}}{$volume});
      $topel->setAttribute('volume', $volume);
      $topel->setAttribute('prodid', ${$self}{'prodid'});
      $topel->appendChild($text);
    }
    return $doc;
}


=back

=head1 STORED DATA

The data is stored in named fields, and for certain uses, it is good to know them. If you want to subclass this class, you might want to use the same names, see the documentation of L<AxKit::APP::TABOO::Data> for more about this. 

These are the names of the stored data of this class:

=over

=item * prodid - an identifier for the product, a simple word you use to retrieve the desired object.

=item * volume - A threshold volume. If an order contains up to an including this volume of a product, the customer will pay the price contained in the corresponding price field for each item ordered. 

=item * price - see above. 


=back

=head1 TODO

Not much, actually... It may have to implement a C<save>-method, perhaps.

=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1;
