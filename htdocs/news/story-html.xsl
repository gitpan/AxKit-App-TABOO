<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:cat="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category/Output"
  xmlns:html="http://www.w3.org/1999/xhtml">  
  <xsl:output method="xml" version="1.0" encoding="utf-8"
    media-type="text/xml" indent="yes"/>  

  <xsl:template match="html:*">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>   
  </xsl:template>
  
  <xsl:template match="node()|@*" >
    <xsl:copy >
      <xsl:apply-templates select="node()|@*" />
    </xsl:copy>
  </xsl:template> 
  
<!-- xsl:template match="html:html">
    <html:html>
      <xsl:apply-templates/>
    </html:html>
  </xsl:template>


  <xsl:template match="html:*">
    <xsl:copy-of select="."/>
    <xsl:apply-templates/>
  </xsl:template -->

  <xsl:template match="story:story">
    <html:h2><xsl:value-of select="story:title"/></html:h2>
    <html:div id="byline">
      <xsl:text>Submitted by </xsl:text>
      <xsl:apply-templates select="user:submitter"/>
      <xsl:text>Posted by </xsl:text>
      <xsl:apply-templates select="user:user"/>
    </html:div>
    <html:div id="catinfo">
      <xsl:text>To Category </xsl:text>
      <xsl:apply-templates select="cat:primcat"/>
    </html:div>
    <html:div id="timeinfo">
      <xsl:text>On </xsl:text>
      <xsl:apply-templates select="story:timestamp"/>
      <xsl:text>Last changed </xsl:text>
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



 <xsl:template match="*|/">
    <xsl:apply-templates/>
  </xsl:template>


</xsl:stylesheet>





