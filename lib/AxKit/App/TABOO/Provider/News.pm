package AxKit::App::TABOO::Provider::News;
use strict;
use warnings;
use Carp;

# This is the "News" Provider, that is, it constructs objects that 
# eventually gives back XML containing a story, and a threaded bunch 
# of comments. 
# It just implements the AxKit Provider API, and therefore contains 
# no method that anybody should use for anything, so the POD deals with 
# what you should expect from this module. 


our $VERSION = '0.04';

=head1 NAME

AxKit::App::TABOO::Provider::News - News Provider for TABOO

=head1 DESCRIPTION 

This is a Provider, it implements the AxKit Provider API, and therefore contains no method that anybody should use for anything. For that reason, this documentation deals with what you should expect to be returned for different URIs. 

The News articles that are managed with this provider, are posts that may have been submitted by users of the site, reviewed by an editor and posted. It will consist of the editor-approved content, called the Story, and content provided as responses by site users, called Comments.

In accordance with the TABOO philosophy, it interacts with Data objects, that are Perl objects responsible for retrieving data from a data storage, make up sensible data structures, return XML markup, etc. 

=cut

use Data::Dumper;
use XML::LibXML;

use vars qw/@ISA/;
@ISA = ('Apache::AxKit::Provider');

use Apache;
use Apache::Log;
use Apache::AxKit::Exception;
use Apache::AxKit::Provider;

use AxKit;
use AxKit::App::TABOO::Data::Story;
use AxKit::App::TABOO::Data::Comment;

use Apache::AxKit::Plugin::BasicSession;


# sub: Init
# Here we do some initialization stuff.
sub init {
  my $self = shift;
  my (%p) = @_;

  my $r = $self->apache_request();
  
  AxKit::Debug(10, "[News] Request object: " . $r->as_string);
  AxKit::Debug(8, "[News] Provider using URI " . $r->uri);
  $self->{uri} = $r->uri;
  
  # Remember: No user named "all", "thread" or "comment" 
    
    
  # Parse the URI to find if we thread, have comments, name of post, etc
  $r->uri =~ m|^/news/(.*?)/(.*?)/|i;
  $self->{section} = $1;
  $self->{storyname} = $2;
  $self->{showthread} = ($r->uri =~ m|/thread$|i) ?1:0;
  $self->{showall} = ($r->uri =~ m|/all$|i) ?1:0;
  $self->{getcomments} = ($r->uri =~ m|/comment/|i) ?1:0;
  if($self->{getcomments}) {
    $r->uri =~ m|/comment(/.*?)$|i;
    $self->{commentpath} = $1;
    if($self->{showthread}) {
      $self->{commentpath} =~ s|/thread$||i;
    }
    if($r->uri =~ m|/comment/thread$|i) {
      $self->{commentpath} = '/';
    }
    if($self->{showall}) {
      $self->{commentpath} =~ s|/all$|/|i;
    }
  }

  # We're just loading the part of the story we are sure to be using. 
  $self->{story} = AxKit::App::TABOO::Data::Story->new();
  $self->{story}->load('storyname,sectionid,editorok,title,timestamp,lasttimestamp', $self->{section}, $self->{storyname});
  $self->{editorok} = $self->{story}->editorok();
  AxKit::Debug(10, "[News] Initial Story Fetched: " . Dumper($self->{story}));
  # No point in going any further if the user isn't authorized:
  unless ($self->{editorok}) {
      if ($Apache::AxKit::Plugin::BasicSession::session{authlevel} < 4) {
	 	throw Apache::AxKit::Exception::Retval(
					       return_code => 401,
					       -text => "Authentication and higher priviliges required");
	    }
  } 
  # Get the timestamps of the story
  $self->{storytimestamp} =  $self->{story}->timestamp();
  if ($self->{getcomments}) {
    $self->{lasttimestamp} =  $self->{story}->lasttimestamp();
    if (($self->{commentpath} ne '/') && ($self->{commentpath} ne '')) {
      # At this point, we know that at least parts of this comment will be used, so we might as well load it all.
      $self->{rootcomment} = AxKit::App::TABOO::Data::Comment->new();
      $self->{rootcomment}->load('*', $self->{commentpath}, $self->{section}, $self->{storyname});
      $self->{commenttimestamp} = $self->{rootcomment}->timestamp();
    } else { 
      $self->{commenttimestamp} = $self->{lasttimestamp};
    }
  }
  AxKit::Debug(9, "[News] Parsed data: " . Dumper($self));
  
}


# sub: process
sub process {
    my $self = shift;
    if($self->{getcomments} && ($self->{commentpath} ne '/') && ($self->{uri} =~ m|/$|)) {
	# URIs should never end with / if they have a bunch of comments
	throw Apache::AxKit::Exception::Retval(
					       return_code => 404,
					       -text => "URIs should not end with /");
    }
    my $exists = $self->exists();
    if (! $exists) {
	throw Apache::AxKit::Exception::Retval(
					       return_code => 404,
					       -text => "Not found by News Provider.");
    }
    return $exists;
}



# sub: key
# should return a unique identifier for the resource.
sub key {
  my $self = shift;
  return $self->{uri};
}

# sub: exists
# should return 1 only if the resource actually exists.
sub exists {
  my $self = shift;
  my $exists = 0;
  if ($self->{storytimestamp}) # This exists iff the story is OK
  {
      $exists = 1;
  }
  if($self->{getcomments})
  {
      $exists = ($self->{commenttimestamp}) ?1:0;
  } else {
      $exists = ($self->{uri} =~ m|^/news/.*?/.*?/$|i) ?1:0;
  }
  return $exists;
}


# sub: mtime
# Return the modification time in days before the current time.
# It's used to test the validity of cached data.
sub mtime {
  my $self=shift;
  return time();
}


sub get_fh {
  throw Apache::AxKit::Exception::IO(
	      -text => "No fh for News Provider");
}

# Here, the correct stuff is retrieved from the db.
# We are fed URLs on the form 
# /news/section/storyname/comment/username/username/thread
sub get_strref {
  my $self = shift;
  if ($self->{out}) {
    # There's a gotcha here in the AxKit framework: It will run every 
    # provider twice, the second time around to deal with styles and 
    # transformations. It is a bit a waste, because we don't want to 
    # regenerate everything. 
    # The problem is, much of the data is preserved, and some things 
    # are altered by the provider, such as creating a tree of replies. 
    # If we run it twice, the tree algorithm will be confused. So, we 
    # simply check if we've been run before. 
    AxKit::Debug(5, "[News] Output allready created in earlier run, reusing");
  } else {
    my $doc = XML::LibXML::Document->new();
    my $rootel = $doc->createElement('taboo');
    $doc->setDocumentElement($rootel);
    # ===============================================
    # Main logic of what to display goes here
    if($self->{getcomments}) {
      # We need to identify the first comments:
      my $tmpcom = AxKit::App::TABOO::Data::Comment->new();
      my $roots = $tmpcom->root($self->{section}, $self->{storyname});
      if($self->{showthread}) {
	# We shall show a thread, not the story OK
	AxKit::Debug(7, "[News] We shall show a thread, not the story");
	$self->{story}->write_xml($doc, $rootel);
	if($self->{commentpath} eq '/') {
	  $self->_expand_root('*', $roots, $doc, $rootel);
	} else {
	  $self->{rootcomment}->adduserinfo();
	  $self->{rootcomment}->tree('*');
	  $self->{rootcomment}->write_xml($doc, $rootel);
	}
      } elsif($self->{commentpath} ne '/' && (! $self->{showthread})) {
	# We shall show a single comment OK
	AxKit::Debug(7, "[News] We shall show a single comment");
	# The comment itself is in rootcomment allready.
	$self->{story}->write_xml($doc, $rootel);
	$self->{rootcomment}->adduserinfo();
	$self->{rootcomment}->write_xml($doc, $rootel);
	# But we want a list of headers too. 
	my $commentlistel = $doc->createElement('commentlist');
	$self->_expand_root('commentpath,sectionid,storyname,title,username,timestamp', $roots, $doc, $commentlistel);
	$rootel->appendChild($commentlistel);
      } elsif($self->{showall}) {
	# We shall show the full story and all the expanded comments OK
	AxKit::Debug(7, "[News] We shall show the full story and all the expanded comments");
	$self->{story}->load('*', $self->{section}, $self->{storyname});
	$self->{story}->adduserinfo();
	$self->{story}->addcatinfo();
	$self->{story}->write_xml($doc, $rootel);
	$self->_expand_root('*', $roots, $doc, $rootel);
      } else {
	# We shall show the full story, but only headings of comments OK
	AxKit::Debug(7, "[News] We shall show the full story, but only headings of comments");
	$self->{story}->load('*', $self->{section}, $self->{storyname});
	$self->{story}->adduserinfo();
	$self->{story}->addcatinfo();
	$self->{story}->write_xml($doc, $rootel);
	my $commentlistel = $doc->createElement('commentlist');
	$self->_expand_root('commentpath,sectionid,storyname,title,username,timestamp', $roots, $doc, $commentlistel);
	$rootel->appendChild($commentlistel);
      }
    } else {
      # We shall only display the story, no comments OK
      AxKit::Debug(7, "[News] We shall only display the story, no comments");
      $self->{story}->load('*', $self->{section}, $self->{storyname});
      $self->{story}->adduserinfo();
      $self->{story}->addcatinfo();
      $self->{story}->write_xml($doc, $rootel); 
    }
    
    
    # =========================
    # Wrapping up and returning
    $self->{out} = $doc;
    AxKit::Debug(10, Dumper($self->{out}->toString(1)));
  }
  return \$self->{out}->toString(1);
}

=head1 URI USAGE

The URI in the News Provider consists of several parts that is parsed by the Provider and used directly to construct the objects that contain the data we wish to send to the user. 

The URIs currently begin with C</news>. This should be made customizable in the future, but currently needs to be hardcoded in the httpd.conf and is hardcoded in the Provider itself. 

The next part of the URI is the section. The section is coded as a simple word in the URI and use to identify the section for the story, as detailed in L<AxKit::App::TABOO::Data::Story>. 

Then comes the story name, used to identify the story, also as detailed in L<AxKit::App::TABOO::Data::Story>. 

If we take C<features> to be our section and C<coolhack> to be the name of the story, we can now construct the minimal URI that will make the News Provider return something (as presently implemented): C</news/features/coolhack/>. This will return markup containing the Story only, no comments. 

If we want to see the comments, we should append C<comment/>. The URI C</news/features/coolhack/comment/> (remember the trailing slash) will give us the whole story but only the headings of comments, that is, the title and author fullname. 

At this point, one can append the key words C<all> or C<thread>. Neither of this may have a trailing slash. E.g. C</news/features/coolhack/comment/all> will return everything that is known for this story, the full story and all the comments. The example C</news/features/coolhack/comment/thread>, OTOH will return all the comments, but only the title (and things like timestamp), of the story itself.
The C<all> keyword can only be used in this context.

We may now use commentpaths to access specific comments. See L<AxKit::App::TABOO::Data::Comment> for details on commentpaths. The short story is that commentpaths is a series of usernames, separated by slashes, and not just any user name, but the usernames of those who posted the comments. For example, if user foo posts a comment, that comment will have commentpath C</foo> and if bar responds to it, that comment will have commentpath C</foo/bar>. No trailing slash. If you want bar's latest comment the URI of that comment is C</news/features/coolhack/comment/foo/bar>. That is, you get the title of the story, but you also get a nested list of all the comments containing only title and author name. 

Finally, you can append C</thread> behind any commentpath, and you get the full text comment and every response to that comment, in addition to the title of the story. To get both foo and bar's comments, nicely nested, you want C</news/features/coolhack/comment/foo/thread>

So, you get nice, human understandable URIs for everything. That's actually one of the main design aims of TABOO. 

You don't get as fine-grained control of which comments you'd like to see like on Slashdot, but then, not many sites attracts as many comments as Slashdot.

=head1 RETURNED XML

It is the Data object's task to return XML marking up the data contained in the object. For the most part, the element name is the same as the field name used in the data storage, see the DATA STORAGE section for L<AxKit::App::TABOO::Data::Story> and L<AxKit::App::TABOO::Data::Comment>. What elements are used is most interesting for an XSLT developer, who might want to look at the output the Provider gives. 

There are a few things worth noting: 

=over

=item * User information can be found within C<user> or C<submitter> elements.

=item * Every reply, even the first root responses will be found within C<reply> elements. Furthermore, a reply to a comment will appear within the C<reply> element of the parent comment. 

=item * The nested lists of comment titles will appear exactly like the full comments, except that the fields with no content are represented with empty elements, and the whole thing will be enclosed in a C<commentlist> element.

=back

=cut


# This is a method to return the transformations
# ******* Quite unlikely I'll ever use this, rather use Conf Directives
#  sub get_styles {
#      my $self = shift;
#      my @transforms;
#      my $href= '/transforms/news/html.xsl';
#      my $type= 'text/xsl';
#      my $module= 'Apache::AxKit::Language::LibXSLT';
#  #    my $module = 'Apache::AxKit::Language::Sablot';
#      my %style = ( type => $type, href => $href, module => $module );
#      push(@transforms, \%style);
#      AxKit::Debug(10, Dumper(@transforms));
#      return \@transforms;
#  }

# Internal method to get a tree of comments from root to the highest branch
sub _expand_root {
  my $self = shift;
  my $what = shift;
  my $roots = shift;
  my $doc = shift;
  my $parent = shift;
  foreach my $commentpath (@{$roots}) {
    my $comment = AxKit::App::TABOO::Data::Comment->new();
    $comment->load($what, $commentpath, $self->{section}, $self->{storyname});
    $comment->adduserinfo();
    $comment->tree($what);
    $comment->write_xml($doc, $parent);
  }
}



=head1 BUGS/TODO

Well, it is an alpha, so there can be bugs...

=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1;
