<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output"
  xmlns:html="http://www.w3.org/1999/xhtml">
  <xsl:import href="/news/story-html.xsl"/>
  <xsl:output encoding="utf-8"
    media-type="text/html" indent="yes"/>
  <xsl:template match="/">
    <html:html lang="en">
      <html:head>
	<html:title><xsl:value-of select="//story:story/story:title"/></html:title>
      </html:head>
      <html:body>      	
	<html:h1><xsl:value-of select="//story:story/story:title"/></html:h1>
	<xsl:apply-templates select="story:story"/>
      </html:body>
    </html:html>
  </xsl:template>
</xsl:stylesheet>