<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:userinc="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Include"
  xmlns:html="http://www.w3.org/1999/xhtml">
  <xsl:output method="xml" version="1.0" encoding="utf-8"
    media-type="text/xml" indent="yes"/>  

  <xsl:template match="user">
    <user>
      <!-- xsl:copy-of select="title"/>
      <xsl:apply-templates select="//user:user"/ -->
      <xsl:apply-templates select="control"/>
      <xsl:apply-templates select="//html:*"/>
      <xsl:copy-of select="//user:authlevel"/>
    </user>
  </xsl:template>
  
  <xsl:template match="control">
    <xsl:choose>
      <xsl:when test="@name='authlevel'">
	<xsl:if test="boolean(value/user:level)">
	  <!-- If the user can't set the authlevel, we shouldn't
	  display the control -->
	  <control>
	    <xsl:copy-of select="title|descr|@*"/>
	    <value>
	      <xsl:copy-of select="value/user:level"/>
	    </value>
	  </control>
	</xsl:if>
      </xsl:when>
      <xsl:otherwise>
	<control>
	  <xsl:copy-of select="title|descr|@*"/>
	  <value>
	    <xsl:apply-templates select="value/userinc:*"/>
	    <xsl:value-of select="value"/>
	  </value>
	</control>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="userinc:name">
    <xsl:value-of select="//user:name"/>
  </xsl:template>
  <xsl:template match="userinc:email">
    <xsl:value-of select="//user:email"/>
  </xsl:template>
  
  <xsl:template match="userinc:uri">
    <xsl:value-of select="//user:uri"/>
  </xsl:template>

  <xsl:template match="user:user">
    <html:li>
      <xsl:value-of select="user:username"/>
    </html:li>
    <html:li>
      <xsl:value-of select="user:name"/>
    </html:li>
  </xsl:template>

  <xsl:template match="html:*">
    <xsl:copy-of select="."/>
  </xsl:template>


</xsl:stylesheet>


