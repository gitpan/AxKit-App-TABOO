package AxKit::App::TABOO::Data::Productsubtype;
use strict;
use warnings;
use Carp;

use Data::Dumper;
use AxKit::App::TABOO::Data;
use vars qw/@ISA/;
@ISA = qw(AxKit::App::TABOO::Data);

use DBI;
use Exception::Class::DBI;


our $VERSION = '0.021_1';
# Forked off Category

=head1 NAME

AxKit::App::TABOO::Data::Productsubtype - Product Sub Types Data objects for TABOO

=head1 SYNOPSIS

  use AxKit::App::TABOO::Data::Productsubtype;
  $size = AxKit::App::TABOO::Data::Productsubtype->new();
  $size->load(what => '*', limit => {prodsubid =>  'XXL'});


=head1 DESCRIPTION

The documentation for this class is not yet written. There isn't a lot of code in this class either, but in a webshop it plays the role of recording things like how many items you have in stock of a subtype of a product, for example a T-shirt size. With the inherited methods, it can actually perform this role in it's present form pretty much.

=cut

AxKit::App::TABOO::Data::Productsubtype->elementorder("prodsubid, title, stockconfirmed, stockshipped, stockordered, ordered");
AxKit::App::TABOO::Data::Productsubtype->dbfrom("productsubtypes");

=head1 METHODS

This class implements only the constructor, the rest is inherited from L<AxKit::App::TABOO::Data>.

=over

=item C<new()>

The constructor. Nothing special.


=cut

sub new {
    my $that  = shift;
    my $class = ref($that) || $that;
    my $self = {
		prodsubid => undef,
		prodid => undef,
		title => undef,
		volume => undef,
		stockconfirmed => undef,
		stockshipped => undef,
		stockordered => undef,
		XMLELEMENT => 'subtype',	
		XMLNS => 'http://www.kjetil.kjernsmo.net/software/TABOO/NS/Productsubtypes/Output',
		ONFILE => undef,
    };
    bless($self, $class);
    return $self;
}



=back




=head1 XML representation

The C<write_xml()> method, implemented in the parent class, can be used to create an XML representation of the data in the object. The above names will be used as element names. The C<xmlelement()> and C<xmlns()> methods can be used to set the name of the root element and the namespace respectively. The defaults are


=over

=item * C<http://www.kjetil.kjernsmo.net/software/TABOO/NS/Productsubtypes/Output>

=item * C<subtype>

=back





=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1;
