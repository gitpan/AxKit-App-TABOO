<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/TR/xhtml1/strict">
  <xsl:output method="xml" version="1.0" encoding="utf-8"
    media-type="text/html" indent="yes"/>  
  <xsl:template match="submit/form">
  <html lang="en">
    <body>      
	<xsl:apply-templates/>
 
    </body>      
  </html>
  </xsl:template>
 
  <xsl:template match="categories">
    <select name="primcat">
      <xsl:apply-templates/>
    </select>
  </xsl:template>
  
  <xsl:template match="category">
    <option value="{catname}">
      <xsl:value-of select="name"/>
    </option>
  </xsl:template>
  
  
  <!-- xsl:template match="namespace-uri() = 'http://www.w3.org/TR/xhtml1/strict'">
      <xsl:copy-of select="."/>
    
  </xsl:template>

  <xsl:template match="//p">
    <xsl:text>namespace-uri: </xsl:text>
    <xsl:value-of select="namespace-uri(.)"/>
    <xsl:apply-templates/>
  </xsl:template -->

  <xsl:template match="html:*">
    <xsl:copy-of select="."/>

  </xsl:template>
  
</xsl:stylesheet>
