package AxKit::App::TABOO::XSP::Story;
use 5.6.0;
use strict;
use warnings;
use Apache::AxKit::Language::XSP::SimpleTaglib;
use Apache::AxKit::Exception;
use Exception::Class::DBI;
use Exception::Class;
use AxKit;
use AxKit::App::TABOO::Data::Story;
use Apache::AxKit::Plugin::BasicSession;
use Time::Piece ':override';
use XML::LibXML;

use vars qw/$NS/;

our $VERSION = '0.076';

=head1 NAME

AxKit::App::TABOO::XSP::Story - News story management tag library for TABOO

=head1 SYNOPSIS

Add the story: namespace to your XSP C<<xsp:page>> tag, e.g.:

    <xsp:page
         language="Perl"
         xmlns:xsp="http://apache.org/xsp/core/v1"
         xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story"
    >

Add this taglib to AxKit (via httpd.conf or .htaccess):

  AxAddXSPTaglib AxKit::App::TABOO::XSP::Story


=head1 DESCRIPTION

This XSP taglib provides a single (for now) tag to store information related to news stories, as it communicates with TABOO Data objects, particulary L<AxKit::App::TABOO::Data::Story>.

L<Apache::AxKit::Language::XSP::SimpleTaglib> has been used to write this taglib.

=cut


$NS = 'http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story';

push @Exception::Class::Base::ISA, 'Error';

# Some constants
# TODO: This stuff should go somewhere else!

use constant GUEST     => 0;
use constant NEWMEMBER => 1;
use constant MEMBER    => 2;
use constant OLDTIMER  => 3;
use constant ASSISTANT => 4;
use constant EDITOR    => 5;
use constant ADMIN     => 6;
use constant DIRECTOR  => 7;
use constant GURU      => 8;
use constant GOD       => 9;

package AxKit::App::TABOO::XSP::Story::Handlers;

=head1 Tag Reference

=head2 C<<store/>>

It will take whatever data it finds in the L<Apache::Request> object held by AxKit, and hand it to a new L<AxKit::App::TABOO::Data::Story> object, which will use whatever data it finds useful. It will not store anything unless the user is logged in and authenticated with an authorization level. If an authlevel is not found in the user's session object, it will throw an exceptions with an C<AUTH_REQUIRED> code. If asked to store certain priviliged fields, it will check the authorization level and throw an exception with a C<FORBIDDEN> code if not satisfied. If timestamps do not exist, they will be created based on the system clock. 

Finally, the Data object is instructed to save itself. 

If successful, it will return a C<store> element in the output namespace with the number 1. 

=cut


sub store : node({http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output}store) {
    return << 'EOC'
	my %args = $r->args;
    $args{'username'} = $Apache::AxKit::Plugin::BasicSession::session{credential_0};

    my $authlevel =  $Apache::AxKit::Plugin::BasicSession::session{authlevel};
  AxKit::Debug(6, "Logged in as $args{'username'} at level $authlevel");
    unless (defined($authlevel)) {
	throw Apache::AxKit::Exception::Retval(
					       return_code => AUTH_REQUIRED,
					       -text => "Not authenticated and authorized with an authlevel");
    }
    if (($args{'sectionid'} eq 'subqueue') && (! $args{'storyname'}))
    {
	$args{'storyname'} = int(rand(100000));
    } elsif ($args{'sectionid'} ne 'subqueue') {
	if ($authlevel < AxKit::App::TABOO::XSP::Story::EDITOR) {
	    throw Apache::AxKit::Exception::Retval(
						   return_code => FORBIDDEN,
						   -text => "Editor Priviliges are needed to store non-subqueue section. Your level: " . $authlevel);
	}
    }
    if (($args{'editorok'}) && ($authlevel < AxKit::App::TABOO::XSP::Story::EDITOR)) {
	throw Apache::AxKit::Exception::Retval(
					       return_code => FORBIDDEN,
					       -text => "Editor Priviliges are needed to OK an article. Your level: " . $authlevel);
    }
    
    if (! $args{'submitterid'}) {
	# If the submitterid is not set, we set it to the current username
	$args{'submitterid'} = $args{'username'}
    }

    my $story = AxKit::App::TABOO::Data::Story->new();

    my $oldstorykey = undef;
    if ($args{'auto-storyname'}) {
	$oldstorykey = $args{'auto-storyname'};
	delete $args{'auto-storyname'};
    }

    my $timestamp = localtime;
    unless ($args{'timestamp'}) {
	$args{'timestamp'} = $timestamp->datetime;
    }
    unless ($args{'lasttimestamp'}) {
	$args{'lasttimestamp'} = $timestamp->datetime;
    }

    $story->populate(\%args);
#    try {
	$story->save($oldstorykey);
#      }
#      catch Exception::Class::DBI with {
#  	my $ex = shift;
#      AxKit::Debug(1, "DBI Error " . $ex->error);
#  	throw Apache::AxKit::Exception::IO(
#  					   -text => $ex->error
#  					   );
#    };
    1;
EOC
}


=head2 C<<this-story/>>

Will return an XML representation of the data submitted in the last request, enclosed in a C<story-submission> element. Particularly useful for previewing a submission. 

=cut

sub this_story : struct {
    return << 'EOC'
	my %args = $r->args;
    $args{'username'} = $Apache::AxKit::Plugin::BasicSession::session{credential_0};
    
    unless ($args{'submitterid'}) {
      # If the submitterid is not set, we set it to the current username
	$args{'submitterid'} = $args{'username'}
    }
    
    
    my $timestamp = localtime;
    unless ($args{'timestamp'}) {
      $args{'timestamp'} = $timestamp->datetime;
    }
    unless ($args{'lasttimestamp'}) {
      $args{'lasttimestamp'} = $timestamp->datetime;
    }
    my $story = AxKit::App::TABOO::Data::Story->new();
    $story->populate(\%args);
    $story->adduserinfo();
    $story->addcatinfo();
    
    my $doc = XML::LibXML::Document->new();
    my $root = $doc->createElementNS('http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output', 'story-submission');
    $doc->setDocumentElement($root);
    $story->write_xml($doc, $root); # Return an XML representation
EOC
}


=head2 C<<get-story/>>

Will return an XML representation of the data for a previously saved
story, enclosed in a C<story-loaded> element. It needs to get the
story identified by C<storyname> and C<sectionid> attributes or child
elements.

=cut


sub get_story : struct attribOrChild(storyname,sectionid) {
    return << 'EOC'
    my %args = $r->args;

    unless ($args{'username'}) {
      $args{'username'} = $Apache::AxKit::Plugin::BasicSession::session{credential_0};
    }

    my $story = AxKit::App::TABOO::Data::Story->new();
    unless ($story->load(what => '*', limit => {sectionid => $attr_sectionid, storyname=> $attr_storyname})) {
      throw Apache::AxKit::Exception::Retval(
					     return_code => 404,
					     -text => "Requested story $attr_storyname not found.");
    }
    $story->adduserinfo();
    unless ($story->editorok) {
      if ($Apache::AxKit::Plugin::BasicSession::session{authlevel} < 4) {
	throw Apache::AxKit::Exception::Retval(
					       return_code => 401,
					       -text => "Authentication and higher priviliges required to load story");
      }
    }
    my $doc = XML::LibXML::Document->new();
    my $root = $doc->createElementNS('http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output', 'story-loaded');
    $doc->setDocumentElement($root);
    $story->write_xml($doc, $root); # Return an XML representation
EOC
}


1;

=head1 Quirks 

There are a few things that I'm not sure how to handle that I've included in this release in an inelegant way. For example, if you want to update an old record with a new storyname (which is not unusual, if for example you don't like the storyname used by the submitter), then you need to include this somehow. For the time being, you must supply the storyname as a query parameter C<auto-storyname>, and the supplied C<submit.xsp> does this. It is then understood by the C<<store>> tag, which does the right thing, but I feel that such a tag shouldn't really need to be aware of such things, from an aestetical POW, suggestion on how to do it differently are welcome. 


=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut
