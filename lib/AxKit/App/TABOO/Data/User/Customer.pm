package AxKit::App::TABOO::Data::User::Customer;
use strict;
use warnings;
use Carp;

use AxKit::App::TABOO::Data;
use AxKit::App::TABOO::Data::User;
use vars qw/@ISA/;
@ISA = qw(AxKit::App::TABOO::Data::User);

use DBI;


our $VERSION = '0.07_1';
# Forked off A::A::T::D::U::Contributor

=head1 NAME

AxKit::App::TABOO::Data::User::Customer - Customer Data objects for TABOO

=head1 SYNOPSIS

  use AxKit::App::TABOO::Data::User::Customer;
  $user = AxKit::App::TABOO::Data::User::Customer->new();
  $user->load(what => '*', limit => {'username' => 'kjetil'});


=head1 DESCRIPTION

This Data class subclasses L<AxKit::App::TABOO::Data::User> to add more contact information for customers to a webshop. 


=cut

AxKit::App::TABOO::Data::User::Customer->dbfrom("users INNER JOIN customers ON (users.username = customers.username)");
AxKit::App::TABOO::Data::User::Customer->dbtable("users,customers");
AxKit::App::TABOO::Data::User::Customer->elementorder("username, name, email, uri, passwd, address, locality, code, contactstatus, comment");

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

# We reimplement the load method with no changes to the API. Actually,
# the reason is to preserve the API, we need to do it because we're
# getting data from two tables, and they both have a username field.

sub load {
  my ($self, %args) = @_;
  my $tmp = $args{'limit'}{'username'};
  if ($tmp) {
    delete $args{'limit'}{'username'};
    $args{'limit'}{'users.username'} = $tmp;
  }

  my $data = $self->_load(%args);
  if ($data) {
    ${$self}{'ONFILE'} = 1;
  } else {
    return undef;
  }
  foreach my $key (keys(%{$data})) {
    ${$self}{$key} = ${$data}{$key}; 
  }
  return $self;
}



=item C<save()>

The C<save()> method has been reimplemented in this class. It is less generic than the method of the grandparent class, but it saves data to two different tables, and should do its job well. It takes no parameters.


=cut


# This is an exact copy of the method in A::A::T::D::U::Contributor, and that's not good OO design. Should probably implement it differently at some point. 
sub save {
  my $self = shift;
  my $dbh = DBI->connect($self->dbstring(),
			 $self->dbuser(),
			 $self->dbpasswd(),
			 { PrintError => 1,
			   RaiseError => 0,
			   HandleError => Exception::Class::DBI->handler,
			   });
  my (@fields, @confields);
  my $i=0;
  my $j=0;
  foreach my $key (keys(%{$self})) {
      next if ($key =~ m/[A-Z]/); # Uppercase keys are not in db
      next unless defined(${$self}{$key}); # No need to insert something that isn't there
      if (($key eq 'bio') || ($key eq 'authlevel')) {
	# TODO: This is too ad-hoc, should have a better way to split the keys
	push(@confields, $key);
	$j++;
      } elsif (($key eq 'username') && (! ${$self}{'ONFILE'})) {
	push(@confields, $key);
	$j++;
	push(@fields, $key);
	$i++;
      } else {
	push(@fields, $key);
	$i++;
      }
    }
    if (($i == 0) && ($j == 0)) {
      carp "No data fields with anything to save";
    } else {
      my ($sth1, $sth2);
      if (${$self}{'ONFILE'}) {
	$sth1 = $dbh->prepare("UPDATE users SET " . join('=?,', @fields) . "=? WHERE username=?");
	$sth2 = $dbh->prepare("UPDATE customers SET " . join('=?,', @confields) . "=? WHERE username=?");
      } else {
	$sth1 = $dbh->prepare("INSERT INTO users (" . join(',', @fields) . ") VALUES (" . '?,' x ($i-1) . '?)');
  	$sth2 = $dbh->prepare("INSERT INTO customers (" . join(',', @confields) . ") VALUES (" . '?,' x ($j-1) . '?)');
      }
      my $k=1;
      foreach my $key (@fields) {
	$sth1->bind_param($k, ${$self}{$key});
	$k++;
      }
      if (${$self}{'ONFILE'}) {
	  $sth1->bind_param($k, ${$self}{'username'});
      }
      $k=1;
      foreach my $key (@confields) {
	$sth2->bind_param($k, ${$self}{$key});
	$k++;
      }
      if (${$self}{'ONFILE'}) {
	  $sth2->bind_param($k, ${$self}{'username'});
      }
      if ($i > 0) {
	$sth1->execute();
      }
      if ($j > 0) {
	$sth2->execute();
      }
  }
  return $self;
}



=back

=head1 STORED DATA

The data is stored in named fields, and for certain uses, it is good to know them. If you want to subclass this class, you might want to use the same names, see the documentation of L<AxKit::APP::TABOO::Data> for more about this.

In addition to the names of the L<parent|AxKit::APP::TABOO::Data::User>, this class adds the following fields:


=over

=item * address

A string representing the street address of the customer.

=item * locality

A string representing the locality of the user. May be used to provide more information about the address if needed. 

=item * code

A string that may be used for ZIP codes or similar things. 

=item * contactstatus

An integer that may be used to indicate if the contact information to the customer is OK. If, for example, our e-mail to the given e-mail address bounces, we may set it to a value to signify that. Currently, TABOO does not specify what the values mean, it may at a later point, but it is suggested that 0 is used to mean OK. 

=item * comment

May be used to enter a short string with customer information that doesn't fit anywhere else. 

=back

This is likely to be extended in future versions. 

=head1 BUGS/TODO

The save method has a really bad implementation... I'm not really sure it saves...


You cannot use the save method in this class to save an object in the case where there is a record for the parent class, but lacks one for this class. 


=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut

1;
