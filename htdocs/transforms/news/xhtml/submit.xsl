<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ct="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Control"
  xmlns:cust="http://www.kjetil.kjernsmo.net/software/TABOO/NS/CustomGrammar"
  xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:cat="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category/Output"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:wn="http://xmlns.com/wordnet/1.6/"      
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  xmlns:texts="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N/Texts"
  exclude-result-prefixes="ct cust story user cat rdf wn dc i18n texts"> 

  <xsl:import href="match-story.xsl"/>
  <xsl:import href="../../../transforms/xhtml/match-control.xsl"/>
  <xsl:import href="/transforms/xhtml/header.xsl"/>
  <xsl:import href="/transforms/xhtml/footer.xsl"/>
  <xsl:import href="/transforms/insert-i18n.xsl"/>

  <xsl:output version="1.0" encoding="utf-8" indent="yes"
    method="html" media-type="text/html" 
    doctype-public="-//W3C//DTD HTML 4.01//EN" 
    doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>  


  <xsl:param name="request.headers.host"/>
  <xsl:param name="session.id"/>
  <xsl:param name="neg.lang">en</xsl:param>

 
  <xsl:template match="cust:submit">
    <html lang="{$neg.lang}">
      <head>
	<title>
	  <xsl:apply-templates select="./cust:title/node()"/>
	  <xsl:text> | </xsl:text>
	  <xsl:value-of select="document('/site/main.rdf')//dc:title/rdf:Alt/rdf:_2"/>
	</title>
	<link rel="stylesheet" type="text/css" href="/css/basic.css"/>	
      </head>
      <body>      
	<xsl:call-template name="CreateHeader"/>
	<div id="container">
	  <h2 class="pagetitle"><xsl:apply-templates select="./cust:title/node()"/></h2>
	  
	  <xsl:variable name="uri" select="concat('http://',
	    $request.headers.host, '/menu.xsp?SID=' , $session.id)"/>
	  <xsl:copy-of select="document($uri)"/>
	  
	  <div class="main">
	    
	    <xsl:apply-templates select="./story:story-submission/story:story"/>
	    
	    <xsl:if test="//story:store=1">
	      <xsl:value-of select="i18n:include('story-stored')"/>
	      <p>
		<xsl:value-of
		  select="i18n:include('return-to-top-page')"/> 
		<a rel="top" href="/"><xsl:value-of
		    select="document('/site/main.rdf')//dc:title/rdf:Alt/rdf:_1"/>
		</a>
	      </p>
	    </xsl:if>
	    
	    <form method="post" action="submit">
	      <div class="fields">
		<xsl:apply-templates select="./ct:control"/>
	      </div>
	    </form>
	  </div>
	</div>
	<xsl:call-template name="CreateFooter"/>
      </body>      
    </html>
  </xsl:template>
  
</xsl:stylesheet>


