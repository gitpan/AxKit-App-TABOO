<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output"
  xmlns:category="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category/Output"
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  xmlns="http://www.w3.org/1999/xhtml">
 
  <xsl:import href="/transforms/news/xhtml/match-story.xsl"/>
  <xsl:output encoding="utf-8"
    media-type="text/xml" indent="yes"/>
  <xsl:template match="/">
    <html lang="en">
      <head>
	<title>
	  <i18n:insert name="mainpage-title"/>
	</title>
     </head>
      <body>
     	<h2>
	  <xsl:if test="//taboo/category:category/category:type='stsec'">
	    <xsl:value-of select="//taboo/category:category/category:name"/>
	  </xsl:if>
	</h2>
	<xsl:choose>
	  <xsl:when test="//taboo[@type='list']">
	    <table>
	      <xsl:apply-templates select="//story:story"/>
	    </table>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:apply-templates select="//story:story"/>
	  </xsl:otherwise>
	</xsl:choose>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
