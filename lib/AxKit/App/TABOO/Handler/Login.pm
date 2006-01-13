package AxKit::App::TABOO::Handler::Login;

# This is a simple mod_perl Handler to implement session tracking,
# just for the purpose of login users in.

use Apache::Constants qw(:common);
use Apache;
use Apache::Request;
#use Apache::Cookie;
use Session;
use AxKit::App::TABOO::Data::User::Contributor;
use AxKit::App::TABOO;
use strict;
use warnings;
use Carp;


our $VERSION = '0.02';

sub handler {
  my $r = shift;
# my $r = Apache->request;

  my %session_config = AxKit::App::TABOO::session_config($r);

  my $cookie = $r->header_in('Cookie');
  if (defined($cookie) && $cookie =~ m/VID=(\w*)/) {
    # so, the user is logged in allready. Kill that session, then
    my $session = new Session $1, %session_config;
    $session->delete if defined $session;
  }
  my $outtext = '<html><head><title>Log in</title></head><body><h1>Log in</h1>';
  my $req = Apache::Request->instance($r);
  my $user = AxKit::App::TABOO::Data::User::Contributor->new();
  my $authlevel = $user->load_authlevel($req->param('username'));
  if ($authlevel) { # So, the user exists
    my $encrypted = $user->load_passwd($req->param('username'));
    if ($req->param('clear') && $encrypted && (crypt($req->param('clear'),$encrypted) eq $encrypted)) {
      my $session = new Session undef, %session_config;
      $r->header_out("Set-Cookie" => 'VID='.$session->session_id());
      $session->set(authlevel => $authlevel);
      $session->set(loggedin => $req->param('username'));
      $outtext .= '<p>Password is valid, go to <a href="/">main page</a>.</p>';
    } else {
      $outtext .= '<p>Password is invalid, go back and try again!</p>';
    }
  } else {
    $outtext .= '<p>Username was not found, go back and try again!</p>';
  }
  $r->send_http_header('text/html');
  $r->print($outtext."\n</body></html>\n");
  return OK;
}

1;
