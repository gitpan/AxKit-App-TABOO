package AxKit::App::TABOO::XSP::Category;
use 5.6.0;
use strict;
use warnings;
use Apache::AxKit::Language::XSP::SimpleTaglib;
use Apache::AxKit::Exception;
use AxKit;
use AxKit::App::TABOO::Data::Category;
use AxKit::App::TABOO::Data::Plurals::Categories;
use Apache::AxKit::Plugin::BasicSession;
use Time::Piece ':override';
use Data::Dumper;
use XML::LibXML;


use vars qw/$NS/;


our $VERSION = '0.05';


=head1 NAME

AxKit::App::TABOO::XSP::Category - Category management tag library for TABOO

=head1 SYNOPSIS

Add the category: namespace to your XSP C<<xsp:page>> tag, e.g.:

    <xsp:page
         language="Perl"
         xmlns:xsp="http://apache.org/xsp/core/v1"
         xmlns:category="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category"
    >

Add this taglib to AxKit (via httpd.conf or .htaccess):

  AxAddXSPTaglib AxKit::App::TABOO::XSP::Category


=head1 DESCRIPTION

This XSP taglib provides a single (for now) tag to retrieve a structured XML fragment with all categories of a certain type. 

L<Apache::AxKit::Language::XSP::SimpleTaglib> has been used to write this taglib.

=cut



$NS = 'http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category';



package AxKit::App::TABOO::XSP::Category::Handlers;


=head1 Tag Reference

=head2 C<<get-categories type="foo"/>>

This tag will replace itself with some structured XML containing all
categories of type C<foo>.  It relates to the TABOO Data object
L<AxKit::App::TABOO::Data::Plurals::Category>, and calls on that to do
the hard work. See the documentation of that class to see the
available types.

The root element of the returned object is C<categories> and each category is wrapped in an element (surprise!) C<category> and contains C<catname> and C<name>. 

=cut

sub get_categories : struct attribOrChild(type) {
    return << 'EOC'
    my $cats = AxKit::App::TABOO::Data::Plurals::Categories->new();
    $cats->load(what => '*', limit => {type => $attr_type});
    my $doc = XML::LibXML::Document->new();
    my $root = $doc->createElementNS('http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category/Output', 'categories');
    $root->setAttribute('type', $attr_type);
    $doc->setDocumentElement($root);
    $cats->xmlelement('primcat');
    $doc = $cats->write_xml($doc, $root);
    $doc;
EOC
}

#  sub store {
#      return << 'EOC'
#  	my %args = $r->args;
#      $args{'username'} = $Apache::AxKit::Plugin::BasicSession::session{credential_0};

#      my $authlevel =  $Apache::AxKit::Plugin::BasicSession::session{authlevel};
#    AxKit::Debug(9, "Logged in as $args{'username'} at level $authlevel");
#      unless ($authlevel) {
#  	throw Apache::AxKit::Exception::Retval(
#  					       return_code => AUTH_REQUIRED,
#  					       -text => "Not authenticated and authorized with an authlevel");
#      }    my $story = AxKit::App::TABOO::Data::Category->new();
#      if (($args{'sectionid'} eq 'subqueue') && (! $args{'storyname'}))
#      {
#  	$args{'storyname'} = int(rand(100000));
#      } elsif ($args{'sectionid'} ne 'subqueue') {
#  	if ($authlevel < AxKit::App::TABOO::XSP::Category::EDITOR) {
#  	    throw Apache::AxKit::Exception::Retval(
#  						   return_code => FORBIDDEN,
#  						   -text => "Editor Priviliges are needed to store non-subqueue section. Your level: " . $authlevel);
#  	}
#      }
#      my $timestamp = localtime;
#      if (! $args{'timestamp'}) {
#  	$args{'timestamp'} = $timestamp->datetime;
#      }
#      if (! $args{'lasttimestamp'}) {
#  	$args{'lasttimestamp'} = $timestamp->datetime;
#      }
#      $story->populate(\%args);
#      $story->save();    
#  EOC
#  }

    
1;


=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut
