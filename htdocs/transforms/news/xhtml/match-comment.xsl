<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cust="http://www.kjetil.kjernsmo.net/software/TABOO/NS/CustomGrammar"
  xmlns:comm="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Comment/Output"
  xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:cat="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category/Output"
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  xmlns:texts="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N/Texts"
  xmlns:regexp="http://exslt.org/regular-expressions"
  extension-element-prefixes="regexp"  
  exclude-result-prefixes="cust user story comm cat i18n texts"> 

  <xsl:import href="/transforms/insert-i18n.xsl"/>
  <xsl:import href="match-user.xsl"/>

  <xsl:template match="comm:reply">
    <div class="reply">
      <xsl:attribute name="id">
	<xsl:value-of select="comm:commentpath"/>
      </xsl:attribute>
      <div class="comm-head">
	<h3><xsl:value-of select="comm:title"/></h3>
	<div class="comm-byline">
	  <xsl:value-of select="i18n:include('posted-by')"/>
	  <xsl:apply-templates select="user:user"/>
	</div>    
	<div class="comm-timeinfo">
	  <xsl:value-of select="i18n:include('on-time')"/>
	  <xsl:apply-templates select="comm:timestamp"/>
	</div>
      </div>
      <div class="comm-content">
	<xsl:apply-templates select="comm:content[not(@raw)]/*" mode="strip-ns"/>
      </div>
      <xsl:apply-templates select="comm:reply"/>

    </div>
  </xsl:template>

  <xsl:template match="comm:commentlist//comm:reply">
    <ul>
      <li>
	<xsl:choose>
	  <xsl:when test="substring-after($request.uri, '/comment') != comm:commentpath">
	    <a>
	      <xsl:attribute name="href">
		<xsl:value-of select="substring-before($request.uri, 'comment/')"/>
		<xsl:text>comment</xsl:text>
		<xsl:value-of select="comm:commentpath"/>
		<xsl:if test="substring-after($request.uri, '/') = 'thread'">
		  <xsl:text>/thread</xsl:text>
		</xsl:if>
	      </xsl:attribute>
	      <xsl:value-of select="comm:title"/>
	    </a>
	  </xsl:when>
	  <xsl:otherwise>
	      <xsl:value-of select="comm:title"/>
	  </xsl:otherwise>
	</xsl:choose>
      </li>
      <xsl:apply-templates select="comm:reply"/>
    </ul>
  </xsl:template>

</xsl:stylesheet>