<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:cat="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category/Output"
  xmlns="http://www.w3.org/1999/xhtml">
  <xsl:import href="story-html.xsl"/>
  <xsl:import href="/control-html.xsl"/>
  <xsl:output version="1.0" encoding="utf-8"
    media-type="text/xml" indent="yes"/>  
  <xsl:template match="submit">
    <html lang="en">
      <head>
	<title><xsl:copy-of select="./title/node()"/></title>
      </head>
      <body>      
	<h1><xsl:copy-of select="./title/node()"/></h1>
	<xsl:apply-templates select="./story:story-submission/story:story"/>

	<xsl:if test="//story:store=1">
	  <xsl:text>Story Stored</xsl:text>
	</xsl:if>
	
	<form method="GET" action="submit.xsp">
	  <fieldset>
	    <xsl:apply-templates select="./control"/>
	  </fieldset>
	</form>
	
      </body>      
    </html>
  </xsl:template>
  
</xsl:stylesheet>


