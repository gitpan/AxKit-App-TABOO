package AxKit::App::TABOO::Data::Product;
use strict;
use warnings;
use Carp;

use AxKit::App::TABOO::Data;
use AxKit::App::TABOO::Data::Productprices;
use AxKit::App::TABOO::Data::Plurals::Productsubtypes;
use vars qw/@ISA/;
@ISA = qw(AxKit::App::TABOO::Data);

use DBI;

our $VERSION = '0.01';


=head1 NAME

AxKit::App::TABOO::Data::Product - Product Data objects for TABOO-based Webshop

=head1 SYNOPSIS

  use AxKit::App::TABOO::Data::Product;
  $product = AxKit::App::TABOO::Data::Product->new();
  $product->load('*', 't-shirt');


=head1 DESCRIPTION

This Data class contains information about a product to be found in the webshop of the site, such as name, a description, URLs to images, prices etc.

It is worth noting that this class is supposed to contain most relevant information about a product, but that some of this information is contained in related classes, particularly L<AxKit::App::TABOO::Data::Productsubtypes> and L<AxKit::App::TABOO::Data::Productprices>. For that reason, the load method will retrieve all the data, and return an object containing objects that are instances of these classes or their plural counterparts. Consult the documentation for these classes for details, and see below for the details on the fields in this class.




=cut


#AxKit::App::TABOO::Data::Product->dbtable("products");
#AxKit::App::TABOO::Data::Product->dbprimkey("prodid");
AxKit::App::TABOO::Data::Product->elementorder("prodid, catname, title, descr, imgsmallurl, imglargeurl, imgcaption, comment, productsubtypes,	number,	PRICES, PRODUCTSUBTYPES");

=head1 METHODS

This class implements two methods, the rest is inherited from L<AxKit::App::TABOO::Data>.

=over

=item C<new()>

The constructor. Nothing special.

=cut

sub new {
    my $that  = shift;
    my $class = ref($that) || $that;
    my $self = {
	prodid => undef,
	catname => undef,
	title => undef,
	descr => undef,
	imgsmallurl  => undef,
	imglargeurl  => undef,
	imgcaption   => undef,
	comment => undef,
	PRODUCTSUBTYPES => undef,
	PRICES => undef,
	XMLELEMENT => 'product',
	XMLNS => 'http://www.kjetil.kjernsmo.net/software/TABOO/NS/Product/Output',
	ONFILE => undef,
    };
    bless($self, $class);
    return $self;
}

=item C<load($prodid)>

This reimplemented load method takes as argument a product ID, a string used to identify a product. It will also call the load methods that are needed to ensure that the price information and the product subtypes are included.

=cut 

sub load {
  my $self = shift;
  my $what = shift;
  my $prodid = shift;
  my $dbh = DBI->connect($self->dbstring(), 
			 $self->dbuser(), 
			 $self->dbpasswd(),  
			 { PrintError => 0,
			   RaiseError => 0,
			   HandleError => Exception::Class::DBI->handler
			   });
  my $sth = $dbh->prepare("SELECT " . $what . " FROM products WHERE prodid=?");
  $sth->execute($prodid);
  my $data = $sth->fetchrow_hashref;
  if ($data) { ${$self}{'ONFILE'} = 1; }
  foreach my $key (keys(%{$data})) {
    ${$self}{$key} = ${$data}{$key};
  }
  my $prices = AxKit::App::TABOO::Data::Productprices->new();
  $prices->dbstring($self->dbstring());
  $prices->dbuser($self->dbuser());
  $prices->dbpasswd($self->dbpasswd());
  ${$self}{'PRICES'} = \$prices->load($prodid);
  my $subtypes = AxKit::App::TABOO::Data::Plurals::Productsubtypes->new();
  $subtypes->dbstring($self->dbstring());
  $subtypes->dbuser($self->dbuser());
  $subtypes->dbpasswd($self->dbpasswd());
  ${$self}{'PRODUCTSUBTYPES'} = \$subtypes->load({prodid => $prodid});
  return $self;
}



=back


=head1 STORED DATA

The data is stored in named fields, and for certain uses, it is good to know them. If you want to subclass this class, you might want to use the same names, see the documentation of L<AxKit::APP::TABOO::Data> for more about this. 

These are the names of the stored data of this class:

=over

=item * prodid - an identifier for the product, a simple word you use to retrieve the desired object.

=item * catname - the identifier of a category. It is convenient to classify the product into a category.

=item * title - A string meant for human consumption used to provide a short description of the product. 

=item * descr - A longer description of the product. 

=item * imgsmallurl - The URL of a small picture of the product suitable for quick viewing. 

=item * imglargeurl - The URL of a larger picture of the product.

=item * imgcaption - A text that can be used as a caption for the pictures. 

=item * comment - Short comment suitable for including things that doesn't fit anywhere else. May also be used for internal comments not for public viewing.

=back

For prices and subtypes, consult documentation of the appropriate classes.

=head1 XML representation

The C<write_xml()> method, implemented in the parent class, can be used to create an XML representation of the data in the object. The above names will be used as element names. The C<xmlelement()> and C<xmlns()> methods can be used to set the name of the root element and the namespace respectively. Usually, it doesn't make sense to change the defaults, which are 


=over

=item * C<product>

=item * C<http://www.kjetil.kjernsmo.net/software/TABOO/NS/Product/Output>

=back


=head1 TODO

This is an early release, just to show off what I've been thinking about and ease testing on different platforms. In particular, an elaborate plural version of this class is needed.


=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1;
