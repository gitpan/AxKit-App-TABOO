package AxKit::App::TABOO::XSP::Article;
use 5.6.0;
use strict;
use warnings;
use Apache::AxKit::Language::XSP::SimpleTaglib;
use Apache::AxKit::Exception;
use AxKit;
use AxKit::App::TABOO::Data::Article;
use Apache::AxKit::Plugin::BasicSession;
use Time::Piece ':override';
use XML::LibXML;
use IO::File;
use MIME::Type;

use vars qw/$NS/;

our $VERSION = '0.18_11';

=head1 NAME

AxKit::App::TABOO::XSP::Article - Article management tag library for TABOO

=head1 SYNOPSIS

Add the story: namespace to your XSP C<E<lt>xsp:pageE<gt>> tag, e.g.:

    <xsp:page
         language="Perl"
         xmlns:xsp="http://apache.org/xsp/core/v1"
         xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Article"
    >

Add this taglib to AxKit (via httpd.conf or .htaccess):

  AxAddXSPTaglib AxKit::App::TABOO::XSP::Article


=head1 DESCRIPTION

This XSP taglib provides tags to store information related to news
stories and to fetch and return XML representations of that data, as
it communicates with TABOO Data objects, particulary
L<AxKit::App::TABOO::Data::Article>.

L<Apache::AxKit::Language::XSP::SimpleTaglib> has been used to write
this taglib.

=head1 TODO

This taglib will be documented further in upcoming releases. While
there is quite a lot of working stuff here, it also has some bad
issues.


=cut


$NS = 'http://www.kjetil.kjernsmo.net/software/TABOO/NS/Article';

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

# Internal function to get a filename we can work with.
sub _sanatize_filename {
  my $file = shift;
  $file =~ tr#A-Za-z0-9+#_#cd; # Replace any non-base64 with underscores
  return substr($file, 0, 29); # Return the 30 first chars.
}

sub _write_file {
    my $upload = shift;
    my $primcat = shift;
    my $docroot = shift;
    my $fh = new IO::File;
    my ($filename, $ext) = $upload->filename =~ m/^(.*)\.(\w*)$/;
    $filename = _sanatize_filename($filename);
    my $lookupfile = $docroot ."/articles/content/$primcat/$filename/";
    mkdir $lookupfile, 0775 || die "Failed to create directory " . $lookupfile;
    $lookupfile .= "$filename.$ext";
    if ($fh->open("> " . $lookupfile)) {
	my $uploadedfh = $upload->fh;
	while (<$uploadedfh>) {
	    print $fh $_;
	}
	$fh->close;
    } else { die "Failed to open file at $lookupfile for writing"  }
    return "/articles/content/$primcat/$filename/$filename.$ext";
}

package AxKit::App::TABOO::XSP::Article::Handlers;

=head1 Tag Reference

=cut


sub store : node({http://www.kjetil.kjernsmo.net/software/TABOO/NS/Article/Output}store) {
    return << 'EOC'
      my $fh = new IO::File;
      my $upload =  $cgi->upload->fh;
      if ($fh->open("> /tmp/dahut")) {
      while (<$upload>) {
        print $fh $_;
}
        $fh->close;

    } else { die "screaming" }

    1;
EOC
}

sub this_article : struct attribOrChild(primcat) {
  return << 'EOC'
  my %args = map { $_ => $cgi->param($_) } $cgi->param;
  my $upload =  $cgi->upload;

  my $lookupurl = AxKit::App::TABOO::XSP::Article::_write_file($upload, $attr_primcat, $r->document_root);
  $args{'format'} = $upload->type;
  # TODO: Security sanity checks.

  unless ($args{'date'}) {
      my $timestamp = localtime;
      $args{'date'} = $timestamp->datetime;
  }

  $args{'authorids'} = [$args{'authorid'}]; # Has to change to support more authors
  my $article = AxKit::App::TABOO::Data::Article->new();
  $article->populate(\%args);
  $article->adduserinfo();
  $article->addcatinfo();
  $article->addformatinfo();
    
  my $doc = XML::LibXML::Document->new();
  my $addel = $doc->createElementNS('http://www.kjetil.kjernsmo.net/software/TABOO/NS/Article/Output', 'art:article-submission');
  $addel->setAttribute('contenturl', $lookupurl);
  $doc->setDocumentElement($addel);
  $article->write_xml($doc, $addel); # Return an XML representation
EOC
}



sub get_article : struct attribOrChild(filename,primcat) {
    return << 'EOC'
    my $article = AxKit::App::TABOO::Data::Article->new();
    unless ($article->load(limit => { filename => $attr_filename })) {
	throw Apache::AxKit::Exception::Retval(
					       return_code => 404,
					       -text => "Article with identifier $attr_filename not found");
    }	

    unless ($article->editorok && $article->authorok) {
	if (! $Apache::AxKit::Plugin::BasicSession::session{authlevel}) {
	    throw Apache::AxKit::Exception::Retval(
						   return_code => 401,
						   -text => "Not authorised with an authlevel");
	}
	unless (grep(/$Apache::AxKit::Plugin::BasicSession::session{credential_0}/, @{$article->authorids}) || 
		($Apache::AxKit::Plugin::BasicSession::session{authlevel} >= 5)) {
	    throw Apache::AxKit::Exception::Retval(
						   return_code => 403,
						   -text => "Authentication and higher priviliges required to load article");
      }
    }
	    
    $article->adduserinfo;
    $article->addcatinfo;
    $article->addformatinfo();

    my $lookupurl;
    foreach my $ext ($article->mimetype->extensions) {
	my $lookupfile = "/articles/content/$attr_primcat/$attr_filename/$attr_filename.$ext";
	if (-r $r->document_root . $lookupfile) {
	    $lookupurl = 'http://' . $r->get_server_name . ':' . $r->get_server_port . $lookupfile;
	}
	last if $lookupurl;
    }
    AxKit::Debug(8, "Content really at: " . $lookupurl);

    unless ($lookupurl) {
	throw Apache::AxKit::Exception::Retval(
					       return_code => 404,
					       -text => "Content $lookupurl not found");
    }

    my $doc = XML::LibXML::Document->new();
    my $rootel = $doc->createElement('taboo');
    $rootel->setAttribute('contenturl', $lookupurl);
    #  $rootel->setAttribute('type', 'article');
    #  $rootel->setAttribute('origin', 'Article');
    $doc->setDocumentElement($rootel);
    $article->write_xml($doc, $rootel);
EOC
}




1;




=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut
