package AxKit::App::TABOO::Provider::Classification;
use strict;
use warnings;
use Carp;

# This is the "Classification" Provider, that is, it constructs
# objects that eventually gives back XML containing classification of
# stories and articles.  It just implements the AxKit Provider API,
# and therefore contains no method that anybody should use for
# anything, so the POD deals with what you should expect from this
# module.


our $VERSION = '0.19_02';

=head1 NAME

AxKit::App::TABOO::Provider::Classification - Provider for classifiying things in TABOO

=head1 SYNOPSIS

In the Apache config:

  <Location /category/>
  	PerlHandler AxKit
        AxContentProvider AxKit::App::TABOO::Provider::Classification
  </Location>


=head1 DESCRIPTION

This is a Provider, it implements the AxKit Provider API, and
therefore contains no method that anybody should use for anything. For
that reason, this documentation deals with what you should expect to
be returned for different URIs.


It is intended to be used to get an overview of articles, stories
etc. that can be found classified into different categories, of
different types.

In accordance with the TABOO philosophy, it interacts with Data
objects, that are Perl objects responsible for retrieving data from a
data storage, make up sensible data structures, return XML markup,
etc. In contrast with the News provider, this provider mainly
interacts with Plural objects to make lists of stories. Also, it
doesn't deal with comments.

The rest of the documentation has yet to be written, but as one can
guess, it may share some things with the NewsList Provider.

=head1 CONFIGURATION DIRECTIVES

=over

=item TABOOListDefaultRecords

The maximum number of stories TABOO will retrieve from the data store
if the user gives no other instructions in the URI (see below). It is
recommended that you set this to some reasonable value.

=item TABOOListMaxRecords

The maximum number of stories TABOO will retrieve from the data store
in any case. If the user requests more than this number, a 403
Forbidden error will be returned. It is highly recommended that you
set this to a value you think your server can handle.

=back

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
use AxKit::App::TABOO::Data::Plurals::Stories;
use AxKit::App::TABOO::Data::Category;
use AxKit::App::TABOO::Data::Plurals::Categories;
use AxKit::App::TABOO::Data::Article;
use AxKit::App::TABOO::Data::Plurals::Articles;

use Apache::AxKit::Plugin::BasicSession;


sub init {
  my $self = shift;

  my $r = $self->apache_request();
  
  AxKit::Debug(10, "[Classification] Request object: " . $r->as_string);
  AxKit::Debug(8, "[Classification] Provider using URI " . $r->uri);
  
  $self->{number} = $r->dir_config('TABOOListDefaultRecords');
  $self->{maxrecords} = $r->dir_config('TABOOListMaxRecords');

  $self->{uri} = $r->uri;
  my @uri = split('/', $r->uri);
  splice(@uri, 0, 2); # The first part is just a keyword,
  $self->{cats} = \@uri;

  AxKit::Debug(9, "[Classification] Data parsed in init: " . Dumper($self));
  return $self;
}

sub process {
  my $self = shift;
  $self->{foundcats} = AxKit::App::TABOO::Data::Plurals::Categories->new();
  foreach my $catname (@{$self->{cats}}) {
    my $category = AxKit::App::TABOO::Data::Category->new();
    unless ($category->load(limit => {catname => $catname})) {
      $self->{exists} = 0;
      $self->{catnotfound} = $catname;
      last;
    } else {
      $self->{foundcats}->Push($category);
      $self->{exists} = 1;
    }
  }
  if ($self->{exists}) {
    $self->{articles} = AxKit::App::TABOO::Data::Plurals::Articles->new();
    $self->{stories} = AxKit::App::TABOO::Data::Plurals::Stories->new();
    unless ($self->{articles}->incat(@{$self->{cats}})) {
      $self->{articles} = undef;
      unless ($self->{stories}->incat(@{$self->{cats}})) { 
	$self->{exists} = 0;
      }
    }
  }
  return $self->{exists};
}

sub exists {
  my $self = shift;
  if ($self->{exists}) {
    return 1;
  } else {
    return 0;
  }
  # Thanks, Kip! :-)
}


sub key {
  no warnings; # To avoid warning when no credential_0 exists
  my $self = shift;
  return $self->{uri} . "/" . $Apache::AxKit::Plugin::BasicSession::session{credential_0};
}


sub mtime {
  my $self=shift;
  return time();
}


sub get_fh {
  throw Apache::AxKit::Exception::IO(
	      -text => "No fh for Classification Provider");
}

sub get_dom {
  my $self = shift;
  unless ($self->{dom}) {
    unless ($self->{exists}) {
      throw Apache::AxKit::Exception::Retval(
					     return_code => 404,
					     -text => "Category " . $self->{catnotfound} . " was not found");
    }
    warn "ANT: " . Dumper($self);
    if (scalar(@{$self->{cats}}) == 1) {
      my %limit;
      if (! defined($Apache::AxKit::Plugin::BasicSession::session{authlevel})
	  || ($Apache::AxKit::Plugin::BasicSession::session{authlevel} < 4)) {
	$limit{'editorok'} = 1;
      } elsif ($self->{editor}) {
	$limit{'editorok'} = 0;
      }
      $limit{'primcat'} = ${$self->{cats}}[0];
      
      $self->{stories}->load(what => 'storyname,sectionid,primcat,editorok,title,submitterid,timestamp',
			     limit => \%limit, 
			     orderby => 'timestamp DESC');
      $self->{stories}->addcatinfo;
      $self->{stories}->adduserinfo;
    } else {
      $self->{stories} = undef;
    }
    my $doc = XML::LibXML::Document->new();
    my $rootel = $doc->createElement('taboo');
    $rootel->setAttribute('type', 'catlists');
    $rootel->setAttribute('origin', 'Classification');
    $doc->setDocumentElement($rootel);
    if ($self->{stories}) {
      $self->{stories}->write_xml($doc, $rootel);
    }
    $self->{foundcats}->write_xml($doc, $rootel);
    my $anyarticles = 0;
    if($self->{articles}) {
      my %limit;
      if (! defined($Apache::AxKit::Plugin::BasicSession::session{authlevel})
	  || ($Apache::AxKit::Plugin::BasicSession::session{authlevel} < 4)) {
	$limit{'editorok'} = 1;
	$limit{'authorok'} = 1;
      }
      if ($self->{articles}->load(limit => \%limit)) {
	$anyarticles = 1;
      }
      $self->{articles}->addcatinfo;
      $self->{articles}->adduserinfo;
      $self->{articles}->addformatinfo;
      $self->{articles}->write_xml($doc, $rootel);
    }
    warn Dumper($self->{stories});
    warn Dumper($self->{articles});
    
    unless (($anyarticles) || (defined($self->{stories}))) {
      if (defined($Apache::AxKit::Plugin::BasicSession::session{authlevel})) {
	throw Apache::AxKit::Exception::Retval(
					       return_code => 403,
					       -text => "Articles or stories exist, but are only accessible to editors.");
      } else {
	throw Apache::AxKit::Exception::Retval(
					       return_code => 401,
					       -text => "Articles or stories exist, but are only accessible to editors, you have to log in as one.");
      }
    }

    $self->{dom} = $doc;
  }
  return $self->{dom};
}

sub get_strref {
  my $self = shift;
  return \ $self->get_dom->toString(1);
}



sub get_styles {
  my $self = shift;
  my @styles = (
		{ type => "text/xsl",
		  href => "/transforms/categories/xhtml/class-provider.xsl" },
	       );
  return \@styles;
}



=head1 URI USAGE




=head1 TODO

Write more documentation.





=head1 SEE ALSO

L<AxKit::App::TABOO::Data::Provider::News>,
L<AxKit::App::TABOO::Data::Plurals::Stories>


=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut



1;


