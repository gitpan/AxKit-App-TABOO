use 5.007003;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'AxKit::App::TABOO',
    'VERSION_FROM'	=> 'lib/AxKit/App/TABOO.pm', # finds $VERSION
    'PREREQ_PM'		=> { Data::Dumper => 0,
			     DBI => 0,
			     DBD::Pg => 1.32,
			     Exception::Class::DBI => 0,
			     Time::Piece => 0,
			     Class::Data::Inheritable => 0,
			     XML::LibXML => 1.57,
			     AxKit => 1.62,
			     AxKit::XSP::QueryParam => 0.02,
                             AxKit::XSP::Sendmail => 0,
			     Crypt::GeneratePassword => 0,
			     Apache::AxKit::Exception => 0,
			     Session => 0,
			     Formatter::HTML::Textile => 0.5,
			     Apache::AxKit::Plugin::AddXSLParams::Request => 0,
			     Encode => 2.09,
			     XML::LibXSLT => 0,
			     Apache::AxKit::Plugin::Param::Expr => 0,
			     MIME::Types => 0,
			     Text::Unaccent => 1.07,
			     IDNA::Punycode => 0,
			   }, # E.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
     (ABSTRACT_FROM => 'lib/AxKit/App/TABOO.pm', # retrieve abstract from module
      AUTHOR     => 'Kjetil Kjernsmo <kjetilk@cpan.org>') : ()),
);
