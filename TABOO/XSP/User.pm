package AxKit::App::TABOO::XSP::User;
use 5.6.0;
use strict;
use warnings;
use Apache::AxKit::Language::XSP::SimpleTaglib;
use Apache::AxKit::Exception;
use AxKit;
use AxKit::App::TABOO::Data::User;
use AxKit::App::TABOO::Data::User::Contributor;
use Apache::AxKit::Plugin::BasicSession;
use Data::Dumper;

use vars qw/$NS/;



=head1 NAME

AxKit::App::TABOO::XSP::User - User information managament tag library for TABOO


=head1 SYNOPSIS

Add the user: namespace to your XSP C<<xsp:page>> tag, e.g.:

    <xsp:page
         language="Perl"
         xmlns:xsp="http://apache.org/xsp/core/v1"
         xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User"
    >

Add this taglib to AxKit (via httpd.conf or .htaccess):

  AxAddXSPTaglib AxKit::App::TABOO::XSP::User


=head1 DESCRIPTION

This XSP taglib provides a few tags to retrieve, set, modify and save user information, as it communicates with TABOO Data objects, particulary L<AxKit::App::TABOO::Data::User> and <AxKit::App::TABOO::Data::User::Contributor>. 

L<Apache::AxKit::Language::XSP::SimpleTaglib> has been used to write this taglib.

=cut

$NS = 'http://www.kjetil.kjernsmo.net/software/TABOO/NS/User';

# Shamelessly lifted from Joergs module
sub makeSalt {
	my $result = '$1$';
	my @chars = ('.', '/', 0..9, 'A'..'Z', 'a'..'z');
	for (0..7) {
		$result .= $chars[int(rand(64))];
	}
	$result .= '$';
	return $result;
}


package AxKit::App::TABOO::XSP::User::Handlers;


=head1 Tag Reference

=head2 C<<store/>>

It will take whatever data it finds in the L<Apache::Request> object held by AxKit, and hand it to a new L<AxKit::App::TABOO::Data::User> object, which will use whatever data it finds useful. If it encounters a password field, the password will be encrypted before it is sent to the Data object. The Data object is then instructed to save itself. 

=cut

sub store {
  return << 'EOC';
  my %args = $r->args;
  my $user = AxKit::App::TABOO::Data::User->new();
  AxKit::Debug(9, "Passwd: " . $args{'passwd'});
  $args{'passwd'} = crypt($args{'passwd'}, 
			AxKit::App::TABOO::XSP::User::makeSalt());

  $user->apache_request_data(\%args);
  $user->save();
EOC
}

=head2 C<<get-passwd username="foo"/>>

This tag will return the password of a user. The username may be given in an attribute or child element named C<username>.

=cut

sub get_passwd : expr attribOrChild(username)
{
    return << 'EOC';
    my $user = AxKit::App::TABOO::Data::User->new();
    $user->load_passwd($attr_username); 
EOC
}



=head2 C<<get-authlevel username="foo"/>>

This tag will return the authorization level of a user, which is an integer that may be used to grant or deny access to certain elements or pages. The username may be given in an attribute or child element named C<username>.

=cut


sub get_authlevel : expr attribOrChild(username)
{
    return << 'EOC';
    my $user = AxKit::App::TABOO::Data::User::Contributor->new();
    $user->load_authlevel($attr_username); 
EOC
}


=head2 C<<password-matches>>

This tag is a boolean tag, which has child elements C<<true>> and C<<false>>. First, it needs a username, which may be given as an attribute or a child element named C<username>, and the cleartext password in a child element C<<clear>>. If the password is valid, the contents of the C<<true>> element will be included in the output document. Conversely, if it is invalid, the contents of C<<false>> will be in the result document. For example:

      <user:password-matches>
	<user:username>foo</user:username>
	<user:clear>trustno1</user:clear>
	<user:true><p>Password is valid</p></user:true>
	<user:false><p>Password is invalid</p></user:false>
      </user:password-matches>

=cut


sub password_matches : attribOrChild(username) child(clear) {
    return ''; # Gotta be something here
}

sub password_matches___true__open {
return << 'EOC';
    my $user = AxKit::App::TABOO::Data::User->new();
    my $encrypted = $user->load_passwd($attr_username);
# AxKit::Debug(10, "Passwds: $attr_clear, $encrypted, " . crypt($attr_clear,$encrypted));
    if ($attr_clear && $encrypted && (crypt($attr_clear,$encrypted) eq $encrypted)) {
EOC
}

sub password_matches___true {
  return '}'
}


sub password_matches___false__open {
return << 'EOC';
    my $user = AxKit::App::TABOO::Data::User->new();
    my $encrypted = $user->load_passwd($attr_username); 
    if (crypt($attr_clear,$encrypted) ne $encrypted) {
EOC
}

sub password_matches___false {
  return '}'
}

=head2 C<<is-authorized authlevel="5">>

This is a boolean tag, which has child elements C<<true>> and C<<false>>. It takes an autherization level in an attribute or child element named C<authlevel>, and if the authenticated user has it least this level, the contents of the C<<true>> element will be included in the output document. Conversely, if the user has insufficient priviliges the contents of C<<false>> will be in the result document. If the user has not been authenticated at all, the tag will throw a exception with an C<AUTH_REQUIRED> code. 

B<NOTE:> This should I<not> be looked upon as a "security feature".  While it is possible to use it to make sure that an input control is not shown to someone who is not authorized to modify it (and this may indeed be its primary use), a malicious user could still insert data to that field by supplying arguments in a POST or GET request. Consequently, critical data must be checked for sanity before they are passed to the Data objects. The Data objects themselves are designed to believe anything they're fed, so it is most natural to do it in a taglib before handing the data to a Data object. See e.g. L<AxKit::App::TABOO::XSP::Story> internals for an example. 


=cut


sub is_authorized : attribOrChild(authlevel) {
    return ''; # Gotta be something here
}

sub is_authorized___true__open {
    return << 'EOC';
    unless ($Apache::AxKit::Plugin::BasicSession::session{authlevel}) {
	throw Apache::AxKit::Exception::Retval(
					       return_code => AUTH_REQUIRED,
					       -text => "Not authenticated and authorized with an authlevel");
    }
    if ($attr_authlevel <= $Apache::AxKit::Plugin::BasicSession::session{authlevel}) # Grant access
{
EOC
}


sub is_authorized___true {
  return '}'
}


sub is_authorized___false__open {
    return << 'EOC';
    if ($attr_authlevel > $Apache::AxKit::Plugin::BasicSession::session{authlevel}) # Deny access
{
EOC
}


sub is_authorized___false {
  return '}'
}


1;



=head1 FORMALITIES

See L<AxKit::App::TABOO>.

=cut
