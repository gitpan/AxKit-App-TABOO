<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:wn="http://xmlns.com/wordnet/1.6/"      
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns="http://www.w3.org/1999/xhtml">
  <xsl:import href="match-story.xsl"/>
  <xsl:import href="/transforms/xhtml/header.xsl"/>
  <xsl:output encoding="utf-8"
    media-type="text/xml" indent="yes"/>
  <xsl:template match="/">
    <html lang="en">
      <head>
	<title>
	  <xsl:value-of select="//story:story/story:title"/>
	  <xsl:text> | </xsl:text>
	  <xsl:value-of select="document('/main.rdf')//dc:title/rdf:Alt/rdf:_2"/>
	
	</title>
	<link rel="top" href="/"/>
      </head>
      <body>      	
	<xsl:call-template name="CreateHeader"/>
	<xsl:apply-templates select="//story:story"/>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
