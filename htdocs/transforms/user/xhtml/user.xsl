<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:wn="http://xmlns.com/wordnet/1.6/"      
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns="http://www.w3.org/1999/xhtml">
  <xsl:import href="match-user.xsl"/>
  <xsl:import href="/transforms/xhtml/match-control.xsl"/>
  <xsl:import href="/transforms/xhtml/header.xsl"/>
  <xsl:output version="1.0" encoding="utf-8" 
    media-type="text/xml" indent="yes"/>  
  <xsl:template match="user">
    <html lang="en">
      <head>
	<title>
	  <xsl:copy-of select="./title/node()"/>
	  <xsl:text> | </xsl:text>
	  <xsl:value-of
	  select="document('/main.rdf')//dc:title/rdf:Alt/rdf:_2"/>
	</title>
      </head>
      <body>      
	<xsl:call-template name="CreateHeader"/>
	<h2><xsl:copy-of select="./title/node()"/></h2>

	<xsl:apply-templates select="//user:user"/>



	<form method="GET" action="submit/">
	  <fieldset>
	    <xsl:apply-templates select="./control"/>
	  </fieldset>
	</form>
	
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>