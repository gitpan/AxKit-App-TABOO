package AxKit::App::TABOO::Data::Story;
use strict;
use warnings;
use Carp;

use Data::Dumper;
use AxKit::App::TABOO::Data;
use vars qw/@ISA/;

@ISA = qw(AxKit::App::TABOO::Data);
use AxKit::App::TABOO::Data::User;
use AxKit::App::TABOO::Data::Category;
use Time::Piece;

use DBI;


our $VERSION = '0.022';


=head1 NAME

AxKit::App::TABOO::Data::Story - Story Data object for TABOO

=head1 SYNOPSIS

  use AxKit::App::TABOO::Data::Story;
  $story = AxKit::App::TABOO::Data::Story->new();
  $story->load('*', $sectionid, $storyname);
  $story->adduserinfo();
  $story->addcatinfo();
  $timestamp = $story->timestamp();
  $lasttimestamp = $story->lasttimestamp();


=head1 DESCRIPTION

This Data class contains a story, as posted by the editors of a site. 

=head1 METHODS

This class implements several methods, reimplements the load method, but inherits some from L<AxKit::App::TABOO::Data>.

=over

=item C<new()>

The constructor. Nothing special.

=cut

AxKit::App::TABOO::Data::Story->dbtable("stories");
AxKit::App::TABOO::Data::Story->dbprimkey("storyname");
AxKit::App::TABOO::Data::Story->elementorder("storyname, sectionid, image, primcat, seccat, freesubject, editorok, title, minicontent, content, USER, SUBMITTER, linktext, timestamp, lasttimestamp");

sub new {
    my $that  = shift;
    my $username = shift;
    my $class = ref($that) || $that;
    my $self = {
	storyname  => undef,
	sectionid => undef,
	image => undef,
	primcat => undef,
	seccat => [],
	freesubject => [],
	editorok => 0,
	title => undef,
	minicontent => undef,
	content => undef,
	username => undef,
	USER => undef,
	submitterid => undef,
	SUBMITTER => undef,
	linktext => undef,
	timestamp => undef,
	lasttimestamp => undef,
	XMLELEMENT => 'story',
	XMLNS => 'http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output',
	ONFILE => undef,
    };
    bless($self, $class);
    return $self;
}

#use Alias qw(attr);
#our ($storyname, $sectionid, $image, $primcat, $seccat, $freesubject, $editorok, $title, $minicontent, $content, $username, $USER, $submitterid, $SUBMITTER, $linktext, $timestamp, $lasttimestamp, $ONFILE);


=item C<load($what, $section, $storyname)>

This class reimplements the load method, to accomodate for the possibility that one may not want to load all the data, one may for example only want to load the title and when it was posted. The load method now takes three arguments:

=over

=item * The first is a comma-separated list of fields from the data storage, see L<"STORED DATA"> for details and available values. For all fields, use C<'*'>.


=item * The second parameter is a word identifying a section which the story has been posted to. Typically, this string will be taken directly from the URI. The use of sections makes it possible to devide the site in different ways. It is not intended that sections will coincide with L<categories|AxKit::App::TABOO::Data::Category>, rather one can have sections with "small news", i.e. blatant rip-offs of other news sites with a few comments added, or longer articles with more unique content.

=item * The third parameter is a unique identifier for the story. This too will typically be derived from the URI directly.

=back


=cut

sub load
{
  my $self = shift;
  my ($what, $section, $storyname) = @_;
  my $dbh = DBI->connect($self->dbstring(), 
			 $self->dbuser(), 
			 $self->dbpasswd(),  
			 { PrintError => 0,
			   RaiseError => 0,
			   HandleError => Exception::Class::DBI->handler
			   });
  my $sth = $dbh->prepare("SELECT " . $what . " FROM stories WHERE sectionid=? AND storyname=?");
  $sth->execute($section, $storyname);
  my $data = $sth->fetchrow_hashref;
  if ($data) { ${$self}{'ONFILE'} = 1; }
  foreach my $key (keys(%{$data})) {
    if (defined(${$data}{$key}) && (${$data}{$key} =~ m/^\{(\S+)\}$/)) { # Support SQL3 arrays ad hoc
      my @arr = split(/\,/, $1);
      ${$self}{$key} = \@arr;
    } else {
      ${$self}{$key} = ${$data}{$key};
    }
  }
  return $self;
}

=item C<adduserinfo()>

When data has been loaded into an object of this class, it will contain a string only identifying a user. 
This method will replace those strings (for the user posting the article, and for the submitter who sent the article to the site) with a reference to a L<AxKit::App::TABOO::Data::User>-object, and that object's C<load_name> method will be called. After this has been done, the story will effectively have all the user information it needs. 

=cut

sub adduserinfo {
    my $self = shift;
    my $user = AxKit::App::TABOO::Data::User->new();
    $user->dbstring($self->dbstring());
    $user->dbuser($self->dbuser());
    $user->dbpasswd($self->dbpasswd());
    # This calls a _addinfo method in the parent class, which should only be used by subclasses for this purpose. It adds the reference itself.
    $self->_addinfo($user,'username','USER');
    $user = AxKit::App::TABOO::Data::User->new();
    $user->xmlelement("submitter");
    $self->_addinfo($user,'submitterid','SUBMITTER');
    return $self;
}

=item C<addcatinfo()>

Similarly to adding user info, this method will also add category information, for different types of categories, again by creating a reference to a L<AxKit::App::TABOO::Data::Category>-object and calling its C<load>-method with the string from the data loaded by the story as argument. 

=cut

sub addcatinfo {
    my $self = shift;
    my $category = AxKit::App::TABOO::Data::Category->new();
    $category->dbstring($self->dbstring());
    $category->dbuser($self->dbuser());
    $category->dbpasswd($self->dbpasswd());
    # There is only one primary category allowed.
    $self->_addinfo($category,'primcat','primcat');

    # We allow several secondary categories, so we may get an array to run through. 
    my $i = 0;
    foreach my $catname (@{${$self}{'seccat'}}) {
      my $cat = AxKit::App::TABOO::Data::Category->new();
      $cat->xmlelement("seccat");
      $cat->load($catname);
      ${$self}{'seccat'}[$i] = \$cat;
      $i++;
    }
    $i = 0;
    foreach my $catname (@{${$self}{'freesubject'}}) {
      my $cat = AxKit::App::TABOO::Data::Category->new();
      $cat->xmlelement("freesubject");
      $cat->load($catname);
      ${$self}{'freesubject'}[$i] = \$cat;
      $i++;
    }
    return $self;
}

=item C<timestamp([($section, $storyname)])>

The timestamp method will retrieve the timestamp of the story. If the timestamp has been loaded earlier from the data storage (for example by the load method), you need not supply any arguments. If the timestamp is not available, you must supply the section and storyname identifiers, the method will then load it into the data structure first. 

The timestamp method will return a Time::Piece object with the requested time information.

=cut

sub timestamp {
  my $self = shift;
  if (! ${$self}{'timestamp'}) {
    my ($section, $storyname) = @_;
    $self->load('timestamp', $section, $storyname);
  }
  (my $tmp = ${$self}{'timestamp'}) =~ s/\+\d{2}$//;
  return Time::Piece->strptime($tmp, "%Y-%m-%d %H:%M:%S");
}

=item C<lasttimestamp([($section, $storyname)])>

This does exactly the same as the timestamp method, but instead returns the lasttimestamp, which is intended to show when anything connected to the story (which may include comments) last changed. 

It may require arguments like the timestamp method does, and it will return a Time::Piece object.

=back

=cut

sub lasttimestamp {
  my $self = shift;
  if (! ${$self}{'lasttimestamp'}) {
    my ($section, $storyname) = @_;
    $self->load('lasttimestamp', $section, $storyname);
  }
  (my $tmp = ${$self}{'lasttimestamp'}) =~ s/\+\d{2}$//;
  return Time::Piece->strptime($tmp, "%Y-%m-%d %H:%M:%S");
}

=head1 STORED DATA

The data is stored in named fields, and for certain uses, it is good to know them. If you want to subclass this class, you might want to use the same names, see the documentation of L<AxKit::APP::TABOO::Data> for more about this. 

In this class it gets even more interesting, because you may pass a list of those to the load method. This is useful if you don't want to load all data, in those cases where you don't need all the data that the object can hold. 

These are the names of the stored data of this class:

=over

=item * storyname - an identifier for the story, a simple word you use to retrieve the desired object. 

=item * sectionid - an identifier for the section, also a simple word you use to retrieve the desired object. 

=item * image - the URL of an image that you want to associate with the story.

=item * primcat - the primary category. You want to classify the story into one primary category.

=item * seccat - the secondary categories. May be an array, so you can classify the story into any number of categories. This may be useful when you try to find relevant articles but searching along different paths. 

=item * freesubject - free categories. The primary categories are intended to be controlled vocabularies, whereas free subjects can be used and created more ad hoc. Also an array, you can have any number of such categories.

=item * editorok - a boolean variable indicated if an editor has approved the story for publishing. 

=item * title - the main title of the story. 

=item * minicontent - Intended to be used as a summary or introduction to a story. Typically, the minicontent will be shown on a front page, where a visitor clicks happily along to read the full story. 

=item * content - the full story text.

=item * username - the username of the user who actually does the posting of hte story. Would usually be an editor. 

=item * submitterid - the username of the user who submitted the article to the site for review and posting. 

=item * linktext - "Read More" makes a bad link text. Link texts should be meaningful when read out of context, and this should contain such a text.

=item * timestamp - typically the time when the story was posted. See also the C<timestamp()> method.

=item * lasttimestamp - typically the time when something attached to the story was last changed, for example when a comment was last submitted. See also the C<lasttimestamp()> method.

=back

=head1 XML representation

The C<write_xml()> method, implemented in the parent class, can be used to create an XML representation of the data in the object. The above names will be used as element names. The C<xmlelement()> and C<xmlns()> methods can be used to set the name of the root element and the namespace respectively. Usually, it doesn't make sense to change the defaults, which are 


=over

=item * C<story>

=item * C<http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output>
 
=back

=head1 BUGS/TODO

Besides that it is a pre-alpha, there is a quirk in the load method. I use SQL3 arrays in the underlying database, but the database driver doesn't support this. So, there is a very hackish ad hoc implementation to parse the arrays in that method. It works partly for reading, but just with  L<DBD::Pg> greater than 1.32.

=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1;
