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


our $VERSION = '0.02';
# Forked off Category

=head1 NAME

AxKit::App::TABOO::Data::Productsubtype - Product Sub Types Data objects for TABOO

=head1 SYNOPSIS

  use AxKit::App::TABOO::Data::Productsubtype;
  $size = AxKit::App::TABOO::Data::Productsubtype->new();
  $size->load('XXL');


=head1 DESCRIPTION



=cut

AxKit::App::TABOO::Data::Productsubtype->elementorder("prodsubid, title, stockconfirmed, stockshipped, stockordered, ordered");
AxKit::App::TABOO::Data::Productsubtype->dbfrom("productsubtypes");

=head1 METHODS

This class implements only one method, in addition to the constructor, the rest is inherited from L<AxKit::App::TABOO::Data>.

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

=head1 STORED DATA

The data is stored in named fields, and for certain uses, it is good to know them. If you want to subclass this class, you might want to use the same names, see the documentation of L<AxKit::APP::TABOO::Data> for more about this. These are the names of the stored data of this class:

=over

=item * prodsubid

A simple word containing a unique name and identifier for the productsubtypes.



This may be extended. 

=back



=head1 XML representation

The C<write_xml()> method, implemented in the parent class, can be used to create an XML representation of the data in the object. The above names will be used as element names. The C<xmlelement()> and C<xmlns()> methods can be used to set the name of the root element and the namespace respectively. Usually, it doesn't make sense to change the default namespace, which is

=over

=item * C<http://www.kjetil.kjernsmo.net/software/TABOO/NS/Productsubtypes/Output>

=back





=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut
    
1;
