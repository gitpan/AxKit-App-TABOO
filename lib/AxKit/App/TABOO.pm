package AxKit::App::TABOO;

use 5.6.0;
use strict;
use warnings;

our $VERSION = '0.074';


# Preloaded methods go here.

1;
__END__


=head1 NAME

AxKit::App::TABOO - Object Oriented Publishing Framework for AxKit

=head1 INTRODUCTION

There is no code in this file. It may be some day, but for now, it is
a placeholder, but one where it is convenient to say what this is, and
my design philosophy for it. 

AxKit::App::TABOO is a object oriented approach to creating a
publishing system on the top of AxKit, the XML Application Server. 
The two O's thus stands for Object Oriented, AB for AxKit-Based. 
I don't know what the T stands for yet, suggestions are welcome! 


=head1 DESIGN PHILOSOPHY

There are three main ideas that forms the basis for TABOO:

=over 

=item 1. The data should be abstracted to objects so that the AxKit
things never have to deal with where and how the data are stored. 

=item 2. URIs should be sensible and human-readable, reflect what kind
of content you will see, and easy to maintain and independent of
underlying server code.

=item 3. Use providers for all the real content that's served to the
user. I like the abstraction Providers give for URIs, and so is an
excellent vehicle to achieve the above goal. Also, they provide the
cleanest separation of markup from code. 

=back

To detail this: I noticed while looking at other people's code, that
though it was a lot of interesting code, it would be rather hard to
integrate all the interesting parts into a coherent whole. That's why
I made the fundamental design choice with TABOO that all data
is to be abstracted to objects. Furthermore, everybody has their own
way of storing data, and scattered files or different databases didn't
seem right to me.

With TABOO, everything that interacts with AxKit just interacts with
the Data objects. That means, if you don't want to store things in the
PostgreSQL database my Data objects use, you could always subclass it,
rewrite the classes or whatever. You would mostly just have to rewrite
the load method. It is also the Data object's job to create XML of its
own data, save itself, etc.

The intention is to write Data objects for every kind of thing you
might want to do. From the start, there will be Slashdot-type stories
of varying length, with comments. These are ever-changing in the sense
that people can come in an add comments at any time. 

It is the intention, however, that TABOO should be a framework where
one can add many very different things. 

TABOO makes extensive use of Providers. That is mostly because I like
the abstraction and direct control of URIs that Providers provide. It
makes it easy to create a framework where URIs are sensible and should
be easy to maintain for foreseeable future. Also, there is no markup
in the code, that's also rather important to make it maintainable. 

=head1 DESCRIPTION

This is what TABOO contains at this point.:

The base data object, L<AxKit::App::TABOO::Data> and a wealth of
subclasses of it, some of which is again subclassed. There are too
many to list.  They provide an abstraction layer that can manage the
data for each of the types. They can load data from a data storage,
currently a PostgreSQL data base, and they can write their data as
XML, and write it back to the database. There are now also Plural
subclasses, built on the L<AxKit::App::TABOO::Data::Plurals> base
class. These classes makes it easier to work on more than one of the
above objects at a time, something that's often necessary. It also
provides some containment of complexity, taking worries off of your
head!

Then, there are two AxKit Providers:
L<AxKit::App::TABOO::Provider::News> and
L<AxKit::App::TABOO::Provider::NewsList>, that makes use of the above
subclasses, especially Story and Comment in the first case and the
Stories in the second. The first provider creates a page containing an
editor-reviewed story and user-submitted comments. The second makes
lists of stories. By simply manipulating the URI in easy-to-understand
ways, you can load just the story, view the comments, separately, in a
list or as a thread, or get simple lists or good overviews of stories.

Currently, it supplies three Taglibs,
L<User|AxKit::App::TABOO::XSP::User>,
L<Story|AxKit::App::TABOO::XSP::Story> and
L<Category|AxKit::App::TABOO::XSP::Category>. These taglibs provide
several tags that you may use interface with the Data objects.

Some XSP and XSLT have been written that allows you to enter and edit
stories, etc.

Furthermore, there is also some user-management code, including
authentication and authorization, to allow adding new users and
editing the information of existing users.

As of 0.04, I have tried to include a final step in the stylesheet
chain, which can take all strings of text from a separate XML file and
insert them in the final product. This will hopefully make it easy to
provide many translations with TABOO.

=head1 CONFIGURATION EXAMPLE

The following is most of the author's AxKit configuration, and should
be sufficient to get the code that is currently in TABOO going. Apart
from installing TABOO, you would also need to copy the stuff in
C<htdocs/> directory in the distribution to C</var/www> or some other
DocumentRoot (and adjust the below accordingly). You may also want to
get some of the data in the C<sql/> directory into a database called
C<skepsis> or at least create this database and tables.


  RewriteEngine on

  RewriteRule ^/user/(.*[^\.xsp].*) /user/user.xsp?username=$1 

  Alias /news/submit /var/www/news/submit.xsp 

  PerlModule AxKit
  SetHandler AxKit

  PerlModule Apache::AxKit::Plugin::BasicAuth

  AxAddStyleMap application/x-xsp Apache::AxKit::Language::XSP

  AxAddStyleMap text/xsl Apache::AxKit::Language::LibXSLT


  <Location />
      AuthType Apache::AxKit::Plugin::BasicAuth
      AuthName TABOO
  </Location>


  # Session Management
  AxAddPlugin Apache::AxKit::Plugin::BasicSession
  PerlSetVar TABOODataStore DB_File
  PerlSetVar TABOOArgs      "FileName => /tmp/session"

  AxAddPlugin Apache::AxKit::Plugin::BasicSession
  AxAddPlugin Apache::AxKit::Plugin::AddXSLParams::BasicSession

  PerlSetVar TABOOLoginScript /login.xsp

  AxAddXSPTaglib AxKit::XSP::BasicAuth
  AxAddXSPTaglib AxKit::XSP::BasicSession

  AxAddXSPTaglib AxKit::XSP::Param
  AxAddXSPTaglib AxKit::XSP::QueryParam
  AxAddXSPTaglib AxKit::XSP::Sendmail

  AxAddXSPTaglib AxKit::App::TABOO::XSP::User
  AxAddXSPTaglib AxKit::App::TABOO::XSP::Story
  AxAddXSPTaglib AxKit::App::TABOO::XSP::Category

  <Location /news/>
  	PerlHandler AxKit
        AxContentProvider AxKit::App::TABOO::Provider::NewsList
    	PerlSetVar TABOOListDefaultRecords 20
    	PerlSetVar TABOOListMaxRecords 200
  </Location>


  <Location /news/submit>
  	PerlHandler AxKit
	AxContentProvider Apache::AxKit::Provider::File
  </Location>


  <LocationMatch ^/news/(.+)/(.+)/($|comment)>
        PerlHandler AxKit
        AxContentProvider AxKit::App::TABOO::Provider::News
  </LocationMatch>


This should get you the authentication and authorization code you
need, set up XSP and the taglibs you need. Note that the order of the
Locations matter. The second of them is rather hackish, it doesn't
feel good, but it was the way I it working...



=head1 TODO

A lot. Because this is a POD, I'm stopping with my lofty visions here
(there's more of that in the README). It is still in sort of an alpha
state, but Real Soon Now it should be a beta useful enough to put on a
test website and have random folks playing with.


Allthough it is not included in the present distro, I have also mostly
finished an Article Provider, which is intended to be used for more
static content. However, most attention will be given to the News
part, because that is the first thing that will give people something
to play with.

Finally note that things that are there are B<not stable>! Names may
change, parameters may be different, and I may decide to do things
differently, depending on how this projects evolves, what new things I
learn (this is very much a learning process for me), and what kind of
feedback hackers provide. 

The new webshop code is very badly documented, and since the deadline
for it whooshed by, it is now halted a bit... Some of the code is
quite OK though, allthough it doesn't work yet. TABOO will make a
great webshop platform...!


=head1 SUPPORT

There is now a taboo-dev mailing list that can be subscribed to at 
http://lists.kjernsmo.net/mailman/listinfo/taboo-dev

=head1 BUGS

In this release L<AxKit::App::TABOO::Data::Comment> doesn't work. It
needs to be reworked to support the new Plurals concept, but that's
not at the top of my list for the moment.


There are surely some... Please report any you find through CPAN RT:
http://rt.cpan.org/NoAuth/Bugs.html?Dist=AxKit-App-TABOO .

=head1 AUTHOR

Kjetil Kjernsmo, E<lt>kjetilk@cpan.orgE<gt>

=head1 SEE ALSO

L<AxKit>, L<AxKit::App::TABOO::Data>, L<AxKit::App::TABOO::Provider::News>.

=head1 COPYRIGHT AND LICENCE

Copyright (c) 2003-2004 Kjetil Kjernsmo. Some rights reserved. This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself. 


=cut
