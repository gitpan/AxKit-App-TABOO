<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output"
  xmlns="http://www.w3.org/1999/xhtml">
  <xsl:import href="match-story.xsl"/>
  <xsl:output  encoding="utf-8"
    media-type="text/xml" indent="yes"/>
  <xsl:template match="/">
    <html lang="en">
      <head>
	<title><xsl:value-of select="//story:story/story:title"/></title>
      </head>
      <body>      	
	<xsl:apply-templates select="//story:story"/>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
