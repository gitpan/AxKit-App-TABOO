package AxKit::App::TABOO::Data::User;
use strict;
use warnings;
use Carp;

use AxKit::App::TABOO::Data;
use vars qw/@ISA/;
@ISA = qw(AxKit::App::TABOO::Data);

use DBI;


=head1 NAME

AxKit::App::TABOO::Data::User - User Data objects for TABOO

=head1 SYNOPSIS

  use AxKit::App::TABOO::Data::User;
  $user = AxKit::App::TABOO::Data::User->new();
  $user->load('kjetil');
  my $fullname = $user->load_name('kjetil');

=head1 DESCRIPTION

This Data class contains basic user information, such as name, e-mail address, an encrypted password, and so on. 

=cut

AxKit::App::TABOO::Data::User->dbquery("SELECT * FROM users WHERE username=?");
AxKit::App::TABOO::Data::User->elementorder("USERNAME, NAME, EMAIL, URI, PASSWD");

=head1 METHODS

This class implements two methods, the rest is inherited from L<AxKit::App::TABOO::Data>.

=over

=item C<new()>

The constructor. Nothing special.

=cut

sub new {
    my $that  = shift;
    my $class = ref($that) || $that;
    my $self = {
	USERNAME => undef,
	NAME => undef,
	EMAIL => undef,
	URI => undef,
	PASSWD => undef,
	XMLELEMENT => 'user',
    };
    bless($self, $class);
    return $self;
}

use Alias qw(attr);
our ($USERNAME, $NAME, $EMAIL, $URI, $PASSWD);

=item C<load_name($username)>

This is an ad hoc method to retrieve the full name of a user, and it takes a C<$username> key to identify the user to retrieve. It will return a string with the full name, but it will also populate the corresponding data fields of the object. You may therefore call C<write_xml> on the object afterwards and have markup for the username and name. 

=cut

sub load_name {
    my $self = attr shift;
    my $username = shift;
    my $dbh = DBI->connect($self->dbstring(), $self->dbuser(), $self->dbpasswd());
    my $sth = $dbh->prepare("SELECT name FROM users WHERE username=?");
    $sth->execute($username);
    my @data = $sth->fetchrow_array;
    $NAME = join('', @data);
    $USERNAME = $username;
    return $NAME;
}

=back

=head1 STORED DATA

The data is stored in named fields, and for certain uses, it is good to know them. If you want to subclass this class, you might want to use the same names, see the documentation of L<AxKit::APP::TABOO::Data> for more about this.

This class is quite certain to be subclassed at some point as TABOO grows: One may record more information about contributors to the site, or customers for a webshop. 

These are the names of the stored data of this class:

=over

=item * username

A simple word containing a unique name and identifier for the category. Usually known as a username... 

=item * name

The person's full name.

=item * email

The person's e-mail address. 

=item * uri

In the Semantic Web you'd like to identify things and their relationships with URIs. So, we try to record URIs for everybody. For those who have stable home page, it may be convenient to use that URL, but for others, we may just have to come up with something smart.

=item * passwd

The user's encrypted password. Allthough it C<is> encrypted, you may not want to throw it around too much. Perhaps it should have been stored somewhere else entirely. YMMV.

=back

=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1
