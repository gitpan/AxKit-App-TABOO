package AxKit::App::TABOO::AddXSLParams::Session;
use 5.6.0;
use strict;
use warnings;
use AxKit;
use AxKit::App::TABOO;
use Session;
use Apache::Constants;
use Apache::Cookie;
use Apache::Request;
use Apache::URI;
use AxKit::App::TABOO;

our $VERSION = '0.01';

sub handler {
  my $r = shift;
  my $uri = $r->uri;
  my $cgi = Apache::Request->instance($r);
  
  my $session = AxKit::App::TABOO::session($r);
  if (defined($session)) {
    $cgi->parms->set('session.id' => $session->session_id);
    $cgi->parms->set('session.authlevel' => AxKit::App::TABOO::authlevel($session));    
    $cgi->parms->set('session.loggedin' => AxKit::App::TABOO::loggedin($session));
  } else {
    $cgi->parms->set('session.authlevel' => '0');
    $cgi->parms->set('session.loggedin' => 'guest');
  }
  return OK;
}

1;
__END__
