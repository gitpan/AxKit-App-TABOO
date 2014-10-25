<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cust="http://www.kjetil.kjernsmo.net/software/TABOO/NS/CustomGrammar"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  xmlns:texts="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N/Texts"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:wn="http://xmlns.com/wordnet/1.6/"      
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns="http://www.w3.org/1999/xhtml">
 
  <xsl:import href="/transforms/xhtml/header.xsl"/>
  <xsl:import href="/transforms/xhtml/footer.xsl"/>
  <xsl:import href="/transforms/insert-i18n.xsl"/>
  <xsl:output encoding="utf-8" method="html"
    media-type="text/html" indent="yes"/>

  <xsl:param name="session.id"/>
  <xsl:param name="session.keys.credential_0" value="unknown"/>
  <xsl:param name="request.headers.host"/>
  <xsl:param name="neg.lang">en</xsl:param>


  <xsl:template match="/cust:loginpage">
    <html lang="{$neg.lang}">
      <head>
	<title>
	  <xsl:value-of select="i18n:include('login')"/> 
	  <xsl:text> | </xsl:text>
	  <xsl:value-of select="document('/site/main.rdf')//dc:title/rdf:Alt/rdf:_1"/>
	</title>
	<link rel="stylesheet" type="text/css" href="/css/basic.css"/>
	<link rel="up" href="/"/>
	<link rel="top" href="/"/>
      </head>
      <body>
	<xsl:call-template name="CreateHeader"/>
	<div id="container">
	  <h2 class="pagetitle">
	    <xsl:value-of select="i18n:include('login')"/>
	    <xsl:value-of select="$session.keys.credential_0"/> 
	  </h2>
	  <!-- xsl:variable name="uri" select="concat('http://',
	  $request.headers.host, '/menu.xsp?SID=' , $session.id)"/>
	  <xsl:copy-of select="document($uri)"/ -->
	  <div class="main">
	    
	    <p>
	      <xsl:apply-templates/>
	      <xsl:value-of
		select="i18n:include('return-to-top-page')"/> 
	      <a rel="top" href="/"><xsl:value-of
		  select="document('/site/main.rdf')//dc:title/rdf:Alt/rdf:_1"/>
	      </a>
	    </p>
	  </div>
	</div>
	<xsl:call-template name="CreateFooter"/>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>