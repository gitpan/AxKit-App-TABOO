package AxKit::App::TABOO::Data::Article;
use strict;
use warnings;
use Carp;
use Encode;


use Data::Dumper;
use AxKit::App::TABOO::Data;
use vars qw/@ISA/;

@ISA = qw(AxKit::App::TABOO::Data);
use AxKit::App::TABOO::Data::User;
use AxKit::App::TABOO::Data::Category;
use AxKit::App::TABOO::Data::MediaType;
use AxKit::App::TABOO::Data::Plurals::Users;
use AxKit::App::TABOO::Data::Plurals::Categories;
use Time::Piece;
use MIME::Types;

use DBI;


our $VERSION = '0.18_12';


=head1 NAME

AxKit::App::TABOO::Data::Article - Article Data object for TABOO

=head1 SYNOPSIS

  use AxKit::App::TABOO::Data::Article;
  [etc ... similar as for other Data objects]

=head1 DESCRIPTION

This Data class contains an mainly metadata for an article. These
articles are of a more static nature than typical news stories.

=head1 METHODS

This class implements several methods, reimplements the load method,
but inherits some from L<AxKit::App::TABOO::Data>.

=over

=item C<new(@dbconnectargs)>

The constructor. Nothing special.

=cut

AxKit::App::TABOO::Data::Article->dbtable("articles");
AxKit::App::TABOO::Data::Article->dbfrom("articles JOIN languages ON (languages.ID = articles.lang_ID) JOIN mediatypes ON (mediatypes.ID = articles.format_ID)");
AxKit::App::TABOO::Data::Article->dbprimkey("filename");
AxKit::App::TABOO::Data::Article->elementorder("filename, lang, primcat, seccat, freesubject, editorok, authorok, title, description, AUTHORS, date, publisher, type, format, coverage, rights");


sub new {
    my $that  = shift;
    my $class = ref($that) || $that;
    my $self = {
		filename  => undef,
		primcat => undef,
		seccat => [],
		freesubject => [],
		angles => [],
		authorok => undef,
		editorok => undef,
		title => undef,
		description => undef,
		publisher => undef,
		date => undef,
		type => undef,
		format => undef,
		lang => undef,
		coverage => undef,
		rights => [],
		authorids => [],
		AUTHORS => undef,
		DBCONNECTARGS => \@_,
		XMLELEMENT => 'article',
		XMLPREFIX => 'art',
		XMLNS => 'http://www.kjetil.kjernsmo.net/software/TABOO/NS/Article/Output',
		ONFILE => undef,
	       };
    bless($self, $class);
    return $self;
}


=item C<load(what =E<gt> fields, limit =E<gt> {filename =E<gt> value, primcat =E<gt> value, [...]})>

=cut

sub load
{
  my ($self, %args) = @_;
  my $what = $args{'what'} || '*';
  if ($what eq '*') {
    $what = 'articles.ID,articles.filename,articles.authorok,articles.editorok,articles.title,articles.description,articles.publisher,articles.date,articles.type,articles.identifieruri,articles.identifierurn,articles.coverage,articles.rights,mediatypes.mimetype,languages.code';
  }
  $args{'what'} = $what;
  my $data = $self->_load(%args);
  return undef unless ($data);
  ${$self}{'ONFILE'} = 1;
  my $dbh = DBI->connect($self->dbconnectargs());
  # TODO: check 'what'
  my $categories = $dbh->selectall_arrayref("SELECT categories.catname, articlecats.field FROM categories JOIN articlecats ON (categories.ID = Cat_ID) JOIN articles ON (articlecats.Article_ID=articles.ID) WHERE articlecats.Article_ID=?", {}, (${$data}{'id'}));

  my $users = $dbh->selectcol_arrayref("SELECT users.username FROM users JOIN articleusers ON (users.ID = Users_ID) JOIN articles ON (articleusers.Article_ID=articles.ID) WHERE articleusers.Article_ID=? ORDER BY articleusers.Users_ID", {}, (${$data}{'id'}));

  $self->populate($data,$categories,$users);
  return $self;
}

=item C<populate($articles, $categories, $users)>

This class reimplements the C<populate> method and gives it a new
interface. C<$articles> must be a hashref where the keys correspond to
that of the data store. C<categories> must be an arrayref where the
elements contain another arrayref, where the first element is the
C<catname>, i.e. identifier for the category, and the second is the
field type, i.e. whether it is a primary category, free subject words,
etc. C<$users> must contain an arrayref with the C<username>s of the
authors.

=cut



sub populate {
  my $self = shift;
  my $articles = shift;
  my $categories = shift;
  my @keys = grep(/[a-z]+/, keys(%{$self})); # all the lower-case keys
  foreach my $key (@keys) {
    if (defined(${$articles}{$key}) && (${$articles}{$key} =~ m/^\{(\S+)\}$/)) { # Support SQL3 arrays ad hoc
      my @arr = split(/\,/, $1);
      ${$self}{$key} = \@arr;
    } else {
      ${$self}{$key} = Encode::decode_utf8(${$articles}{$key});
    }
  }
  ${$self}{'authorids'} = shift;
  ${$self}{'lang'} = ${$articles}{'code'};
  ${$self}{'format'} = ${$articles}{'mimetype'};
  foreach my $cat (@{$categories}) {
    if (${$cat}[1] eq 'primcat') {
      ${$self}{'primcat'} = ${$cat}[0];
    } else {
      push(@{${$self}{${$cat}[1]}}, ${$cat}[0]);
    }
  }
  return $self;
}

=item C<adduserinfo()>

When data has been loaded into an object of this class, it will
contain a string only identifying a user, the authors of the article.
This method will replace those strings with a reference to a
L<AxKit::App::TABOO::Data::User>-object, containing the needed user
information.

=cut

sub adduserinfo {
  my $self = shift;
  my $users = AxKit::App::TABOO::Data::Plurals::Users->new($self->dbconnectargs());
  foreach my $username (@{${$self}{'authorids'}}) {
    my $user = AxKit::App::TABOO::Data::User->new($self->dbconnectargs());
    $user->xmlelement("author");
    $user->load(what => 'username,name', limit => {username => $username});
    $users->Push($user);
  }
  ${$self}{'AUTHORS'} = $users;
  return $self;
}

=item C<addcatinfo()>

Similarly to adding user info, this method will also add category
information, for different types of categories, again by creating a
reference to a L<AxKit::App::TABOO::Data::Category>-object and calling
its C<load>-method with the string from the data loaded by the article
as argument.

=cut

sub addcatinfo {
  my $self = shift;
  my @cattypes = qw(primcat seccat freesubject angles);
  foreach my $cattype (@cattypes) {
#    warn $cattype . ": ". ref(${$self}{$cattype});
    if (ref(${$self}{$cattype}) eq 'ARRAY') {
      my $cats = AxKit::App::TABOO::Data::Plurals::Categories->new($self->dbconnectargs());
      $cats->xmlelement($cattype);
      foreach my $catname (@{${$self}{$cattype}}) {
	my $cat = AxKit::App::TABOO::Data::Category->new($self->dbconnectargs());
	$cat->load(limit => {catname => $catname});
	$cats->Push($cat);
      }
      ${$self}{$cattype} = $cats;
    } elsif (defined(${$self}{$cattype})) {
      my $cat = AxKit::App::TABOO::Data::Category->new($self->dbconnectargs());
      $cat->xmlelement($cattype);
      $cat->load(limit => {catname => ${$self}{$cattype}});
      ${$self}{$cattype} = $cat;
    } else {
      # Actually, this is where we have an empty list
      ${$self}{$cattype} = [];
    }
  }
  
  return $self;
}


sub addformatinfo {
    my $self = shift;
    my $type = AxKit::App::TABOO::Data::MediaType->new($self->dbconnectargs());
    $type->load(limit => {mimetype => ${$self}{'format'}});
    ${$self}{'format'} = $type;
    return $self;
}

=item C<date([$filename|Time::Piece])>

The date method will retrieve or set the date of the
article. If the date has been loaded earlier from the data storage
(for example by the load method), you need not supply any
arguments. If the date is not available, you must supply the
filename  identifiers, the method will then load it into
the data structure first.

The date method will return a L<Time::Piece> object with the
requested time information.

To set the date, you must supply a L<Time::Piece> object, the
date is set to the time given by that object.

=cut

sub date {
  my $self = shift;
  my $arg = shift;
  if (ref($arg) eq 'Time::Piece') {
    ${$self}{'date'} = $arg->datetime;
    return $self;
  }
  if (! ${$self}{'date'}) {
    my $storyname = shift;
    $self->load(what => 'date', limit => {sectionid => $arg, storyname => $storyname});
  }
  unless (${$self}{'date'}) { return undef; }
  (my $tmp = ${$self}{'date'}) =~ s/\+\d{2}$//;
  return Time::Piece->strptime($tmp, "%Y-%m-%d");
}


=item C<editorok([($filename)])>

This is similar to the date method in interface, but can't be
used to set the value, only retrieves it. It returns the C<editorok>,
which is a boolean variable that says can be used to see if an editor
has approved a story.

It takes arguments like the date method does, and it will return
1 if the story has been approved, 0 if not.


=cut

sub editorok {
  my $self = shift;
  unless (defined(${$self}{'editorok'})) {
    my ($filename) = @_;
    $self->load(what => 'editorok', limit => {filename => $filename});
  }
  return ${$self}{'editorok'};
}


=item Additional methods

There are a few more methods that will be documented in later releases.

=cut

sub authorok {
  my $self = shift;
  unless (defined(${$self}{'authorok'})) {
    my ($filename) = @_;
    $self->load(what => 'authorok', limit => {filename => $filename});
  }
  return ${$self}{'authorok'};
}

sub mimetype {
  my $self = shift;
  if (ref(${$self}{'format'}) eq 'MIME::Type') {
    return ${$self}{'format'};
  }
  elsif (ref(${$self}{'format'}) eq 'AxKit::App::TABOO::Data::MediaType') {
    return ${$self}{'format'}->mimetype;
  }
  my $mimetypes = MIME::Types->new(only_complete => 1);
  my MIME::Type $type = $mimetypes->type(${$self}{'format'});
  return $type;
}

sub authorids {
  my $self = shift;
  return @{$self}{'authorids'};
}



=back

=head1 STORED DATA

The data is stored in named fields, and for certain uses, it is good
to know them. If you want to subclass this class, you might want to
use the same names, see the documentation of
L<AxKit::App::TABOO::Data> for more about this.

In this class it gets even more interesting, because you may pass a
list of those to the load method. This is useful if you don't want to
load all data, in those cases where you don't need all the data that
the object can hold.

This will be documented later.


=back

=head1 XML representation

The C<write_xml()> method, implemented in the parent class, can be
used to create an XML representation of the data in the object. The
above names will be used as element names. The C<xmlelement()>,
C<xmlns()> and C<xmlprefix()> methods can be used to set the name of
the root element, the namespace URI and namespace prefix
respectively. Usually, it doesn't make sense to change the defaults,
that are


=over

=item * C<article>

=item * C<http://www.kjetil.kjernsmo.net/software/TABOO/NS/Article/Output>

=item * C<art>

=back

=head1 BUGS/TODO

This class is really experimental at this point, and has not seen the
same level of testing as the rest of TABOO. More documentation is also
needed.

=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1;
