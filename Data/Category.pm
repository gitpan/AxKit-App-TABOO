package AxKit::App::TABOO::Data::Category;
use strict;
use warnings;
use Carp;

use Data::Dumper;
use AxKit::App::TABOO::Data;
use vars qw/@ISA/;
@ISA = qw(AxKit::App::TABOO::Data);

use DBI;


=head1 NAME

AxKit::App::TABOO::Data::Category - Category Data objects for TABOO

=head1 SYNOPSIS

  use AxKit::App::TABOO::Data::Category;
  $cat = AxKit::App::TABOO::Data::Category->new();
  $cat->load('kitten');


=head1 DESCRIPTION

It is often convenient to lump articles together in categories. People do that to organize subjects that interest them, find things that are related and so on. In the TABOO framework, the intention is to use several types of categories, but they are conceptually similar, and so, stored together. 

=cut

AxKit::App::TABOO::Data::Category->elementorder("CATNAME, NAME, TYPE, URI, DESCRIPTION");
AxKit::App::TABOO::Data::Category->dbquery("SELECT * FROM categories WHERE catname=?");

=head1 METHODS

This class implements only one method, the rest is inherited from L<AxKit::App::TABOO::Data>.

=over

=item C<new()>

The constructor. Nothing special.

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


=cut

sub new {
    my $that  = shift;
    my $class = ref($that) || $that;
    my $self = {
		CATNAME => undef,
		NAME => undef,
		TYPE => undef,
		URI => undef,
		DESCRIPTION => undef,
		XMLELEMENT => 'primcat',
    };
    bless($self, $class);
    return $self;
}

#use Alias qw(attr);
#our ($CATNAME, $NAME, $TYPE, $URI, $DESCRIPTION);

=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1
