<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:art="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Article/Output"
  xmlns:cat="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category/Output"
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  xmlns:texts="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N/Texts"
  exclude-result-prefixes="user cat art i18n texts"> 

  <xsl:import href="/transforms/articles/xhtml/match-author.xsl"/>
  
  <xsl:param name="request.uri"/>

  <xsl:template match="art:article">
    <dt>
      <a class="article-title">
	<xsl:attribute name="href">
	  <xsl:text>/articles/</xsl:text>
	  <xsl:value-of select="./cat:primcat/cat:catname"/>
	  <xsl:text>/</xsl:text>
	  <xsl:value-of select="./art:filename"/>
	</xsl:attribute>
	<xsl:value-of select="./art:title"/>
      </a>
      <span class="byline">
	<xsl:value-of select="i18n:include('by')"/>
	<xsl:call-template name="ArticleAuthors"/>
      </span>
    </dt>
    <dd>
      <div class="catinfo">
	<xsl:value-of select="i18n:include('cats-title-menu')"/>
	<xsl:text>:</xsl:text>  
	<xsl:for-each select="./cat:*">
	  <a>	
	    <xsl:attribute name="href">
	      <xsl:variable name="catname">
		<xsl:text>/</xsl:text>
		<xsl:value-of select="./cat:catname"/>
	      </xsl:variable>
	      <xsl:choose> <!-- TODO, doesn't really work -->
		<xsl:when test="contains($request.uri, $catname)">
		  <xsl:text>/cats/</xsl:text> <!-- TODO: has to change when using a different name -->
		  <xsl:value-of select="./cat:catname"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="./cat:catname"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:attribute>
	    <xsl:value-of select="./cat:name"/>
	  </a>
	  <xsl:text>, </xsl:text>  
	</xsl:for-each>

      </div>
      <p class="description">
      	<xsl:value-of select="./art:description"/>
      </p>
    </dd>
  </xsl:template>
</xsl:stylesheet>