<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  xmlns:texts="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N/Texts"
  xmlns="http://www.w3.org/1999/xhtml">
  <xsl:output method="html" encoding="utf-8"
    media-type="text/html" indent="yes"/>
  
  <xsl:template match="//i18n:insert">
    <xsl:variable name="Text" select="@name"/>
    <xsl:value-of
    select="document('/i18n.en.xml')/texts:translations/texts:text[@id=$Text]"/>
  </xsl:template>


  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>