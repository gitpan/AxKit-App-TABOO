package AxKit::App::TABOO::Data::Comment;
use strict;
use warnings;
use Carp;

use Data::Dumper;
use AxKit::App::TABOO::Data;
use AxKit::App::TABOO::Data::User;

use vars qw/@ISA/;
@ISA = qw(AxKit::App::TABOO::Data);

use DBI;


our $VERSION = '0.021';



=head1 NAME

AxKit::App::TABOO::Data::Comment - Comment Data object for TABOO

=head1 SYNOPSIS

  use AxKit::App::TABOO::Data::Comment;
  $comment = AxKit::App::TABOO::Data::Comment->new();
  $comment->load('*', $commentpath, $sectionid, $commentname);
  $comment->tree('*');
  $comment->adduserinfo();
  $timestamp = $comment->timestamp();

=head1 DESCRIPTION

This Data class contains a comment, which may be posted by any registered user of the site. Each object will also contain an identifier of replies to the comment, that may be replaced with a reference to another comment object. 

=head1 METHODS

This class implements several methods, reimplements the load method, but inherits some from L<AxKit::App::TABOO::Data>.

=over

=item C<new()>

The constructor. Nothing special.

=cut

AxKit::App::TABOO::Data::Comment->elementorder("commentpath, title, content, timestamp, USER, REPLIES");

sub new {
    my $that  = shift;
    my $class = ref($that) || $that;
    my $self = {
	commentpath => undef,
	storyname => undef,
	sectionid => undef,
	title => undef,
	content => undef,
	timestamp => undef,
	username => undef,
	USER => undef,
	REPLIES => [],
	XMLELEMENT => 'reply',
	XMLNS => 'http://www.kjetil.kjernsmo.net/software/TABOO/NS/Comment/Output',
	ONFILE => undef,

    };
    bless($self, $class);
    return $self;
}

#use Alias qw(attr);
#our ($commentpath, $storyname, $sectionid, $title, $content, $timestamp, $username, @REPLIES);

=item C<load($what, $commentpath, $section, $storyname)>

The load method is reimplemented to support a more elaborate scheme for identifying comments, as well as the ability of selecting a subset of data to load. It now takes four arguments, three of them are identical to those of L<AxKit::App::TABOO::Data::Story>.

=over

=item * The first is a comma-separated list of fields from the data storage, see L<"STORED DATA"> for details and available values. For all fields, use C<'*'>.

=item * The second is a commentpath. Conceptually, a commentpath is a string that identifies a comment by appending the username of the poster for each reply posted, separated by a C</>. Thus, commentpaths will grow as people respond to each other's comments. For example, if user bar replies to user foo, the commentpath to bar's comment will be C</foo/bar>. The commenpath will typically be in the URI of a comment. 

=item * The third parameter is a word identifying a section which the story has been posted to. Typically, this string will be taken directly from the URI.

=item * The fourth parameter is a unique identifier for the story. This too will typically be derived from the URI directly.

=back

The $commentpath, $section amd $storyname together identifies a comment. 

When loaded, the comment object will also contain an array of commentpaths of the replies to the comment. There is currently no method to retrieve this array, but you shouldn't need to.

=cut

sub load {
    my $self = shift;
    my ($what, $commentpath, $section, $storyname) = @_;
    my $dbh = DBI->connect($self->dbstring(), 
			   $self->dbuser(), 
			   $self->dbpasswd(),  
			   { PrintError => 0,
			     RaiseError => 0,
			     HandleError => Exception::Class::DBI->handler
			   });
    my $sth = $dbh->prepare("SELECT $what FROM comments WHERE commentpath=? AND sectionid=? AND storyname=?");
    $sth->execute($commentpath, $section, $storyname);
    my $data = $sth->fetchrow_hashref;
    if ($data) {
      ${$self}{'ONFILE'} = 1;
    }
    # Here, data will contain the basic data from the database
    # We are interested in the replies as well. Therefore, we retrieve the 
    # commentpaths by selecting the commentpaths that start with the 
    # commentpath of the present comment
    my $tmp = $dbh->selectcol_arrayref("SELECT commentpath FROM comments WHERE commentpath ~ ? AND sectionid=? AND storyname=?", {}, $commentpath . '/[a-z]+$', $section, $storyname); # '
    @{$data}{'REPLIES'} = $tmp; # these are now in an array
    foreach my $key (keys(%{$data})) {
	${$self}{$key} = ${$data}{$key}; 
    }
    $sth->finish;
    $dbh->disconnect;
    return $self;
}

=item C<tree($what)>

Once you've C<load()>ed the object, you may call this method on it. It will replace the commentpath array with references to the objects, and does it recursively, so you'll have references with references (etc) to I<all> comments that are below this comment. Furthermore, it calls C<adduserinfo()> (below) on all the objects, so after having called C<tree()> on an object, you should have everything that's intersting in there. 

Like C<load()>, C<tree($what)> takes an argument, a comma-separated list of fields from the data storage, see L<"STORED DATA"> available values. For all fields, use C<'*'>.

=cut

sub tree {
    my $self = shift;
    my $what = shift;
    my $i = 0;
    foreach my $commentpath (@{${$self}{'REPLIES'}}) {
	my $comment = AxKit::App::TABOO::Data::Comment->new();
	$comment->load($what, $commentpath, ${$self}{'sectionid'}, ${$self}{'storyname'});
	$comment->adduserinfo();
	$comment->tree($what);
	${$self}{'REPLIES'}[$i] = \$comment;
        $i++;
    }
    return $self;
}

=item C<root($section, $storyname)>

The C</> commentpath does not refer to a comment. The root is simply not a comment, so you can't C<load( ... , '/', ... , ...)>. To address this problem, the root method returns a reference to an array containing all the commentpaths of comments attached directly to a story. You may then run through the array and call C<load> on each element in the array. It takes two arguments, an identifier for the section and for the story, see C<load()>. This is slightly inelegant, since it does not deal with a single object of this class like the others do, but it was the best solution I found now. 

=cut


sub root {
  my $self = shift;
  my ($section, $storyname) = @_;
  my $dbh = DBI->connect($self->dbstring(), 
			 $self->dbuser(), 
			 $self->dbpasswd(),  
			 { PrintError => 0,
			   RaiseError => 0,
			   HandleError => Exception::Class::DBI->handler
			 });
  return $dbh->selectcol_arrayref("SELECT commentpath FROM comments WHERE commentpath ~ ? AND sectionid=? AND storyname=?", {}, '^/[a-z]+$', $section, $storyname); # '
}


=item C<adduserinfo()>

When data has been loaded into an object of this class, it will contain a string only identifying the user who posted the comment. 
This method will replace that string with a reference to a L<AxKit::App::TABOO::Data::User>-object, and that object's C<load_name> method will be called. After this has been done, the story will effectively have all the user information it needs. 

=cut


sub adduserinfo {
    my $self = shift;
    my $user = AxKit::App::TABOO::Data::User->new();
    $user->dbstring($self->dbstring());
    $user->dbuser($self->dbuser());
    $user->dbpasswd($self->dbpasswd());
    $self->_addinfo($user,'username','USER');
    return $self;
}


=item C<timestamp([($section, $storyname)])>

The timestamp method will retrieve the timestamp of the comment. If the timestamp has been loaded earlier from the data storage (for example by the load method), you need not supply any arguments. If the timestamp is not available, you must supply the section and storyname identifiers, the method will then load it into the data structure first. 

The timestamp method will return a Time::Piece object with the requested time information.

=back

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


1;

=head1 STORED DATA

The data is stored in named fields, and for certain uses, it is good to know them. If you want to subclass this class, you might want to use the same names, see the documentation of L<AxKit::APP::TABOO::Data> for more about this. 

In this class it gets even more interesting, because you may pass a list of those to the load method. This is useful if you for example just want the title of the comments, not all their content.

These are the names of the stored data of this class:

=over

=item * commentpath - the identifying commentpath, as described above. 

=item * storyname - an identifier for the story, a simple word you use to retrieve the desired object. 

=item * sectionid - an identifier for the section, also a simple word you use to retrieve the desired object. 

=item * title - the title for the comment chosen by the poster. 

=item * content - the full comment text.

=item * timestamp - typically the time when the comment was posted. See also the C<timestamp()> method.

=item * username - the username of the user who posted the comment.

=back


=head1 XML representation

The C<write_xml()> method, implemented in the parent class, can be used to create an XML representation of the data in the object. The above names will be used as element names. The C<xmlelement()> and C<xmlns()> methods can be used to set the name of the root element and the namespace respectively. Usually, it doesn't make sense to change the defaults, which are 


=over

=item * C<reply>

=item * C<http://www.kjetil.kjernsmo.net/software/TABOO/NS/Comment/Output>
 
=back

=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut
