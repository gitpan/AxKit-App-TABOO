<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output"
  xmlns:category="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category/Output"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:wn="http://xmlns.com/wordnet/1.6/"      
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  xmlns:texts="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N/Texts"
  xmlns="http://www.w3.org/1999/xhtml">
 
  <xsl:import href="/transforms/insert-i18n.xsl"/>
  <xsl:import href="/transforms/news/xhtml/match-story.xsl"/>
  <xsl:import href="/transforms/xhtml/header.xsl"/>
  <xsl:output encoding="utf-8" method="html"
    media-type="text/html" indent="yes"/>
  
  <xsl:param name="request.headers.host"/>
  <xsl:param name="session.id"/>

  <xsl:template match="/">
    <html lang="en">
      <head>
	<title>
	  <xsl:choose>
	    <xsl:when test="taboo/category:category/category:type='stsec'">
	      <xsl:value-of select="taboo/category:category/category:name"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="i18n:include('listing-everything')"/>
	    </xsl:otherwise>
	  </xsl:choose>
	  <xsl:text> | </xsl:text>
	  <xsl:value-of select="document('/site/main.rdf')//dc:title/rdf:Alt/rdf:_2"/>
	</title>
	<link rel="stylesheet" type="text/css" href="/css/basic.css"/>
	<link rel="up" href=".."/>
	<link rel="top" href="/"/>
      </head>
      <body> 
	<xsl:call-template name="CreateHeader"/>
     	<h2 id="sectionhead">
	  <xsl:choose>
	    <xsl:when test="taboo/category:category/category:type='stsec'">
	      <xsl:value-of select="taboo/category:category/category:name"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="i18n:include('listing-everything')"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</h2>
	<xsl:variable name="uri" select="concat('http://',
	  $request.headers.host, '/menu.xsp?SID=' , $session.id)"/>
	<xsl:copy-of select="document($uri)"/>
	<div class="main">
	  <xsl:choose>
	    <xsl:when test="taboo[@type='list']">
	      <table>
		<xsl:apply-templates select="//story:story"/>
	      </table>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:apply-templates select="//story:story"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
