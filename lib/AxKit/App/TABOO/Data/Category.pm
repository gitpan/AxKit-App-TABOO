package AxKit::App::TABOO::Data::Category;
use strict;
use warnings;
use Carp;

use Data::Dumper;
use AxKit::App::TABOO::Data;
use vars qw/@ISA/;
@ISA = qw(AxKit::App::TABOO::Data);

use DBI;
use Exception::Class::DBI;


our $VERSION = '0.031';


=head1 NAME

AxKit::App::TABOO::Data::Category - Category Data objects for TABOO

=head1 SYNOPSIS

  use AxKit::App::TABOO::Data::Category;
  $cat = AxKit::App::TABOO::Data::Category->new();
  $cat->load('kitten');


=head1 DESCRIPTION

It is often convenient to lump articles together in categories. People do that to organize subjects that interest them, find things that are related and so on. In the TABOO framework, the intention is to use several types of categories, but they are conceptually similar, and so, stored together. 

=cut

AxKit::App::TABOO::Data::Category->elementorder("catname, name, type, uri, description");
AxKit::App::TABOO::Data::Category->selectquery("SELECT * FROM categories WHERE catname=?");

=head1 METHODS

This class implements only one method, in addition to the constructor, the rest is inherited from L<AxKit::App::TABOO::Data>.

=over

=item C<new()>

The constructor. Nothing special.


=item C<load_name($catname)>

This is an ad hoc method to retrieve the full name of a category, and it takes a C<$catname> key to identify the category to retrieve. It will return a string with the name, but it will also populate the corresponding data fields of the object. You may therefore call C<write_xml> on the object afterwards and have markup for the categoryname and name. 

=cut

sub load_name {
    my $self = shift;
    my $catname = shift;
    my $dbh = DBI->connect($self->dbstring(), 
			   $self->dbuser(), 
			   $self->dbpasswd(),  
			   { PrintError => 0,
			     RaiseError => 0,
			     HandleError => Exception::Class::DBI->handler
			   });
    my $sth = $dbh->prepare("SELECT name FROM categories WHERE catname=?");
    $sth->execute($catname);
    my @data = $sth->fetchrow_array;
    if (@data) {
      ${$self}{'ONFILE'} = 1;
    }
    ${$self}{'name'} = join('', @data);
    ${$self}{'catname'} = $catname;
    return ${$self}{'name'};
}

=back

=head1 STORED DATA

The data is stored in named fields, and for certain uses, it is good to know them. If you want to subclass this class, you might want to use the same names, see the documentation of L<AxKit::APP::TABOO::Data> for more about this. These are the names of the stored data of this class:

=over

=item * catname

A simple word containing a unique name and identifier for the category.

=item * name

An expanded name intended for human consumption.

=item * type

TABOO (is intended to) recognize several types of categories, for different uses. The content of type should be one of several 5-character strings:

=over

=item * categ - the basic category, for a hacker website, for example "Perl", "Apache" etc. However, it is the intention that categ should be a controlled vocabulary, i.e. your article should fit in one or more categories, and you have to choose from those provided to you.

=item * frees - Sort of like a category, but Free Subjects. If it doesn't really fit in any of the categories, you should be free to specify something, and this may also be useful in lumping things together in an ad hoc way. 

=item * angle - People write articles about the same subject but see it from different angles. For example, an anthropologist will view hackerdom from a different angle than a programmer. 

=back

This may be extended. 

=item * uri

In the Semantic Web you'd like to identify things and their relationships with URIs. So, we try to record an URI for everything. 

=item * description

A longer description of a category, intended as an explanation to a human what kind of things belong in that category. 

=back



=head1 XML representation

The C<write_xml()> method, implemented in the parent class, can be used to create an XML representation of the data in the object. The above names will be used as element names. The C<xmlelement()> and C<xmlns()> methods can be used to set the name of the root element and the namespace respectively. Usually, it doesn't make sense to change the default namespace, which is

=over

=item * C<http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category/Output>

=back

However, the root element may change depending on what kind of category we have. The default is C<primcat>.

=cut

sub new {
    my $that  = shift;
    my $class = ref($that) || $that;
    my $self = {
		catname => undef,
		name => undef,
		type => undef,
		uri => undef,
		description => undef,
		XMLELEMENT => 'primcat',	
		XMLNS => 'http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category/Output',
		ONFILE => undef,
    };
    bless($self, $class);
    return $self;
}

#use Alias qw(attr);
#our ($CATNAME, $NAME, $TYPE, $URI, $DESCRIPTION);

=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1;


