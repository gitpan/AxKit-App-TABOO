package AxKit::App::TABOO::Data::User::Contributor;
use strict;
use warnings;
use Carp;

use AxKit::App::TABOO::Data;
use AxKit::App::TABOO::Data::User;
use vars qw/@ISA/;
@ISA = qw(AxKit::App::TABOO::Data::User);

use DBI;


=head1 NAME

AxKit::App::TABOO::Data::User::Contributor - Contributor Data objects for TABOO

=head1 SYNOPSIS

  use AxKit::App::TABOO::Data::User::Contributor;
  $user = AxKit::App::TABOO::Data::User::Contributor->new();
  $user->load('kjetil');
  my $fullname = $user->load_authlevel('kjetil');

=head1 DESCRIPTION

This Data class subclasses L<AxKit::App::TABOO::Data::User> to add an authentication level and optional biographical information for a contributor to a site. 


=cut

AxKit::App::TABOO::Data::User::Contributor->selectquery("SELECT * FROM users INNER JOIN contributors ON (users.username = contributors.username) WHERE users.username=?");
AxKit::App::TABOO::Data::User::Contributor->dbtable("users,contributors");
AxKit::App::TABOO::Data::User::Contributor->elementorder("username, name, email, uri, passwd, bio, authlevel");

=head1 METHODS

This class implements two methods, the rest is inherited from L<AxKit::App::TABOO::Data::User>.

=over

=item C<new()>

The constructor. Makes sure that we inherit the data members from our superclass. Apart from that, nothing special.

=cut

sub new {
    my $that  = shift;
    my $class = ref($that) || $that;
    my $self = $class->SUPER::new();
    $self->{authlevel} = 0;
    $self->{bio} = undef;
    bless($self, $class);
    return $self;
}



=item C<load_authlevel($username)>

This is an ad hoc method to retrieve the authorization level of a user, and it takes a C<$username> key to identify whose level to retrieve. It will return a number that may be used to decide whether or not to grant access to an object or a data member. It will also populate the corresponding data fields of the object. You may therefore call C<write_xml> on the object afterwards and have markup for the username and level. 

=cut

sub load_authlevel {
    my $self = shift;
    my $username = shift;
    my $dbh = DBI->connect($self->dbstring(), 
			   $self->dbuser(), 
			   $self->dbpasswd(),  
			   { PrintError => 0,
			     RaiseError => 0,
			     HandleError => Exception::Class::DBI->handler
			     });
    my $sth = $dbh->prepare("SELECT authlevel FROM contributors WHERE username=?");
    $sth->execute($username);
    my @data = $sth->fetchrow_array;
    ${$self}{'authlevel'} = join('', @data);
    ${$self}{'username'} = $username;
    return ${$self}{'authlevel'};
}

=back

=head1 STORED DATA

The data is stored in named fields, and for certain uses, it is good to know them. If you want to subclass this class, you might want to use the same names, see the documentation of L<AxKit::APP::TABOO::Data> for more about this.

In addition to the names of the L<parent|AxKit::APP::TABOO::Data::User>, this class adds the following fields:


=over

=item * authlevel

An integer representing the authorization level of a user. In the present implementation, it is a signed two-byte integer. It is intended to be used to decide whether or not to grant access to an object or a data member.

=item * bio

The contributors biographical information. 

=back

This is likely to be extended in future versions. 


=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1;
