package AxKit::App::TABOO::Data::Order;
use strict;
use warnings;
use Carp;

use AxKit::App::TABOO::Data;
use AxKit::App::TABOO::Data::OrderedItem;
use AxKit::App::TABOO::Data::Plurals::OrderedItems;
use vars qw/@ISA/;
@ISA = qw(AxKit::App::TABOO::Data);

use DBI;

our $VERSION = '0.01';


=head1 NAME

AxKit::App::TABOO::Data::Order - Order Data objects for TABOO-based Webshop

=head1 SYNOPSIS

  use AxKit::App::TABOO::Data::Order;
  $product = AxKit::App::TABOO::Data::Order->new();
  $product->load('*', 't-shirt');


=head1 DESCRIPTION

This Data class contains information about a product to be found in the webshop of the site, such as name, a description, URLs to images, prices etc.

It is worth noting that this class is supposed to contain most relevant information about a product, but that some of this information is contained in related classes, particularly L<AxKit::App::TABOO::Data::OrderedItems> and L<AxKit::App::TABOO::Data::OrderedItem>. For that reason, the load method will retrieve all the data, and return an object containing objects that are instances of these classes or their plural counterparts. Consult the documentation for these classes for details, and see below for the details on the fields in this class.




=cut


AxKit::App::TABOO::Data::Order->dbfrom("orders");
#AxKit::App::TABOO::Data::Order->dbprimkey("prodid");
AxKit::App::TABOO::Data::Order->elementorder("prodid, catname, title, descr, imgsmallurl, imglargeurl, imgcaption, comment, ordersubtypes,	number,	PRICES, ORDERSUBTYPES");

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
       orderid	 => undef,
       username	 => undef,
       totalprice  => undef,
       paid 	   => undef,
       paymentopt  => undef,
       status	   => undef,
       orderdate   => undef,
       paiddate     => undef,
       shippeddate  => undef,
       tracker	    => undef,
       errormode    => undef,
       comment      => undef,
       ORDEREDITEMS => undef,
       XMLELEMENT => 'order',
       XMLNS => 'http://www.kjetil.kjernsmo.net/software/TABOO/NS/Order/Output',
       ONFILE => undef,
    };
    bless($self, $class);
    return $self;
}

=item C<load($what, $orderid)>

This reimplemented load method takes as arguments a string consisting of a comma-separated list of datafields to be retrieved, an order ID, a string used to identify an order. It will also call the load method to include the ordered items. 


=cut

sub load {
  my ($self, %args) = @_;
  my $data = $self->_load(%args);
  if ($data) { ${$self}{'ONFILE'} = 1; }
  foreach my $key (keys(%{$data})) {
    ${$self}{$key} = ${$data}{$key};
  }
  my $orderid = ${$args{'limit'}}{'orderid'};
  if (($orderid) && (${$args{'limit'}} ~= m/volume|\*/)) {
    # This means, we should populate the rest of the object with all data.
    my $items = AxKit::App::TABOO::Data::Plurals::OrderedItems->new();
    $items->dbstring($self->dbstring());
    $items->dbuser($self->dbuser());
    $items->dbpasswd($self->dbpasswd());
    my $ordereditems = $items->load(what => '*', limit => {orderid => $orderid});
    my %products = $ordereditems->orderedproductids();
    my @products;
    foreach my $prodid (keys(%products)) {
      my $prod =  AxKit::App::TABOO::Data::Plurals::Product->new();
      
  }
  return $self;
}



=back


=head1 STORED DATA

The data is stored in named fields, and for certain uses, it is good to know them. If you want to subclass this class, you might want to use the same names, see the documentation of L<AxKit::APP::TABOO::Data> for more about this. 

These are the names of the stored data of this class:

=over

=item * orderid - an identifier for the product, a simple word you use to retrieve the desired object.

=item * catname - the identifier of a category. It is convenient to classify the product into a category.

=item * title - A string meant for human consumption used to provide a short description of the product. 

=item * descr - A longer description of the product. 

=item * imgsmallurl - The URL of a small picture of the product suitable for quick viewing. 

=item * imglargeurl - The URL of a larger picture of the product.

=item * imgcaption - A text that can be used as a caption for the pictures. 

=item * comment - Short comment suitable for including things that doesn't fit anywhere else. May also be used for internal comments not for public viewing.

=back

For prices and items, consult documentation of the appropriate classes.

=head1 XML representation

The C<write_xml()> method, implemented in the parent class, can be used to create an XML representation of the data in the object. The above names will be used as element names. The C<xmlelement()> and C<xmlns()> methods can be used to set the name of the root element and the namespace respectively. Usually, it doesn't make sense to change the defaults, which are 


=over

=item * C<product>

=item * C<http://www.kjetil.kjernsmo.net/software/TABOO/NS/Order/Output>

=back


=head1 TODO

This is an early release, just to show off what I've been thinking about and ease testing on different platforms. In particular, an elaborate plural version of this class is needed.


=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1;
