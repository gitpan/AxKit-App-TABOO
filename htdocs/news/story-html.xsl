<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:cat="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category/Output"
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  xmlns:html="http://www.w3.org/1999/xhtml">  
  <xsl:output method="xml" version="1.0" encoding="utf-8"
    media-type="text/xml" indent="yes"/>

  <xsl:template match="story:story">
    <html:h2><xsl:value-of select="story:title"/></html:h2>
    <html:div id="byline">
      <i18n:insert name="submit-by"/>
      <xsl:apply-templates select="user:submitter"/>
      <i18n:insert name="posted-by"/>
       <xsl:apply-templates select="user:user"/>
    </html:div>
    <html:div id="catinfo">
      <i18n:insert name="to-cat"/>
      <xsl:apply-templates select="cat:primcat"/>
    </html:div>
    <html:div id="timeinfo">
      <i18n:insert name="on"/>
      <xsl:apply-templates select="story:timestamp"/>
      <i18n:insert name="last-changed"/>
      <xsl:apply-templates select="story:lasttimestamp"/>
    </html:div>
    <html:div class="minicontent">
      <xsl:value-of select="story:minicontent"/>
    </html:div>
    <html:div class="content">
      <xsl:value-of select="story:content"/>
    </html:div>
      
  </xsl:template>

  <xsl:template match="user:user|user:submitter">
    <html:span class="by">
      <html:a>
	<xsl:attribute name="href">
	  <xsl:text>/user/</xsl:text><xsl:value-of
	  select="user:username"/>
	</xsl:attribute>
	<xsl:value-of select="user:name"/>
      </html:a>
    </html:span>
  </xsl:template>

  <xsl:template match="cat:primcat">
    <xsl:value-of select="cat:name"/>
  </xsl:template>

  <xsl:template match="story:timestamp|story:lasttimestamp">
    <html:span class="time">
      <xsl:value-of select="."/>
    </html:span>
  </xsl:template>

</xsl:stylesheet>





