package AxKit::App::TABOO::Provider::NewsList;
use strict;
use warnings;
use Carp;

# This is the "NewsList" Provider, that is, it constructs objects that 
# eventually gives back XML containing listed stories.
# It just implements the AxKit Provider API, and therefore contains 
# no method that anybody should use for anything, so the POD deals with 
# what you should expect from this module. 


our $VERSION = '0.07';

=head1 NAME

AxKit::App::TABOO::Provider::NewsList - Provider for listing news stories in TABOO

=head1 DESCRIPTION 

This is a Provider, it implements the AxKit Provider API, and
therefore contains no method that anybody should use for anything. For
that reason, this documentation deals with what you should expect to
be returned for different URIs.

It will return lists of news stories, so it makes use of Plural Stories objects. 

In accordance with the TABOO philosophy, it interacts with Data
objects, that are Perl objects responsible for retrieving data from a
data storage, make up sensible data structures, return XML markup,
etc. In contrast with the News provider, this provider mainly
interacts with Plural objects to make lists of stories. Also, it
doesn't deal with comments.

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
use AxKit::App::TABOO::Data::Plurals::Stories;
use AxKit::App::TABOO::Data::Plurals::Categories;

use Apache::AxKit::Plugin::BasicSession;


sub init {
  my $self = shift;

  my $r = $self->apache_request();
  
  AxKit::Debug(10, "[NewsList] Request object: " . $r->as_string);
  AxKit::Debug(8, "[NewsList] Provider using URI " . $r->uri);
  
  $self->{number} = $r->dir_config('TABOOListDefaultRecords');
  $self->{maxrecords} = $r->dir_config('TABOOListMaxRecords');

  $self->{uri} = $r->uri;

  my @uri = split('/', $r->uri);
  
  foreach my $part (@uri) {

    if ($part =~ m/^[0-9]+$/) {
      $self->{number} = $part;
      next;
    }
    if ($part eq 'list') {
      $self->{list} = 1;
      next;
    }
    if ($part eq 'editor') {
      $self->{editor} = 1;
      next;
    }
    if ($part eq 'unpriv') {
      $self->{unpriv} = 1;
      next;
    }

    if ($part ne 'news') {
      $self->{sectionid} = $part;
    }

  }
  AxKit::Debug(9, "[NewsList] Data parsed in init: " . Dumper($self));

  return $self;
}

sub process {
  my $self = shift;
  if ($self->{uri} =~ m|/news/.*/$|) {
    # URIs should never end with / unless it is just /news/
    throw Apache::AxKit::Exception::Retval(
					   return_code => 404,
					   -text => "URIs should not end with /");  
  }
  if (($Apache::AxKit::Plugin::BasicSession::session{authlevel} < 4) && ($self->{editor})) {
    throw Apache::AxKit::Exception::Retval(
					   return_code => 401,
					   -text => "You're not allowed to see editor-only stories without being authenticated as one.");
  }
  if (($self->{unpriv}) && ($self->{editor})) {
    throw Apache::AxKit::Exception::Retval(
					   return_code => 404,
					   -text => "Editor and Unpriviliged are mutually exclusive.");
  }
  if ($self->{number} > $self->{maxrecords}) {
    throw Apache::AxKit::Exception::Retval(
					   return_code => 403,
					   -text => "The server limit for number of records is " . $self->{maxrecords});
    }
  
  if ($self->{sectionid}) {
    # Iff a resource doesn't exist, it means that the section doesn't
    # exist, so we just check the list of sections
    my $test = AxKit::App::TABOO::Data::Plurals::Categories->new();  
    unless ($test->load(what => 'catname', 
			limit => {type => 'stsec',
				  catname => $self->{sectionid}}, 
			entries => 1)) {
      throw Apache::AxKit::Exception::Retval(
					     return_code => 404,
					     -text => "Not found by NewsList Provider.");
    }
  }
  # No exceptions thrown means that we go ahead here:
  $self->{exists} = 1;
  return 1;
}

sub exists {
  my $self = shift;
  if (defined($self->{exists})) {
    return 1;
  } else {
    return 0;
  }
  # Thanks, Kip! :-)
}


sub key {
  my $self = shift;
  return $self->{uri};
}


sub mtime {
  my $self=shift;
  return time();
}


sub get_fh {
  throw Apache::AxKit::Exception::IO(
	      -text => "No fh for News Provider");
}

sub get_strref {
  my $self = shift;
  my $what = 'storyname,sectionid,primcat,editorok,title,submitterid,timestamp';
  unless ($self->{list}) {
    $what .= ',minicontent,seccat,freesubject,image,username,linktext,lasttimestamp';
  }
  my %limit;
  if (($Apache::AxKit::Plugin::BasicSession::session{authlevel} < 4) || ($self->{unpriv})) {
    $limit{'editorok'} = 1;
  } elsif ($self->{editor}) {
    $limit{'editorok'} = 0;
  }
  if ($self->{sectionid}) {
    $limit{'sectionid'} = $self->{sectionid};
  }
  AxKit::Debug(9, "[NewsList] Limit records to: " . Dumper(%limit));

  $self->{stories} = AxKit::App::TABOO::Data::Plurals::Stories->new();
  $self->{stories}->load(what => $what, 
			 limit => \%limit, 
			 orderby => 'timestamp DESC', 
			 entries => $self->{number});
  my $doc = XML::LibXML::Document->new();
  my $rootel = $doc->createElement('taboo');
  $doc->setDocumentElement($rootel);
  $self->{stories}->write_xml($doc, $rootel);
  $self->{out} = $doc;
  AxKit::Debug(10, Dumper($self->{out}->toString(1)));

  return \$self->{out}->toString(1);
}


=head1 TODO

Actually, what's non-trivial is to configure both the News and NewsList providers to work at the same time. That's a TODO for the next release. 

XSL Transformations need to be done soon too.

Since every resource comes with a C<lasttimestamp>, it should be relatively simple to implement C<mtime> better than it is now, but the question is if all code updates C<lasttimestamp> reliably enough...

=head1 BUGS

Well, it is an alpha, so there can be bugs...


=head1 SEE ALSO

L<AxKit::App::TABOO::Data::Plurals::Stories>


=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut



1;


