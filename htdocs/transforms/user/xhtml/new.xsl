<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:ct="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Control"
  xmlns:cust="http://www.kjetil.kjernsmo.net/software/TABOO/NS/CustomGrammar"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:wn="http://xmlns.com/wordnet/1.6/"      
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns="http://www.w3.org/1999/xhtml">
  <xsl:import href="match-user.xsl"/>
  <xsl:import href="/transforms/insert-i18n.xsl"/>
  <xsl:import href="/transforms/xhtml/match-control.xsl"/>
  <xsl:import href="/transforms/xhtml/header.xsl"/>
  <xsl:output version="1.0" encoding="utf-8" method="html"
    media-type="text/html" indent="yes"/>  
  
  <xsl:param name="request.headers.host"/>
  <xsl:param name="session.id"/>

  <xsl:template match="cust:user">
    <html lang="en">
      <head>
	<title>
	  <xsl:apply-templates select="./cust:title/node()"/>
	  <xsl:text> | </xsl:text>
	  <xsl:value-of
	  select="document('/site/main.rdf')//dc:title/rdf:Alt/rdf:_2"/>
	</title>
	<link rel="stylesheet" type="text/css" href="/css/basic.css"/>
      </head>
      <body>      
	<xsl:call-template name="CreateHeader"/>
	<h2 class="pagetitle"><xsl:apply-templates select="./cust:title/node()"/></h2>

	<xsl:variable name="uri" select="concat('http://',
	  $request.headers.host, '/menu.xsp?SID=' , $session.id)"/>
	<xsl:copy-of select="document($uri)"/>

	<div class="main">
	  <xsl:apply-templates select="//user:user"/>
	  
	  <form method="GET" action="/user/submit/new">
	    <fieldset>
	      <xsl:apply-templates select="./ct:control"/>
	    </fieldset>
	  </form>
	</div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>

