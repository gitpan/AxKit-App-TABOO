<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:menu="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Menu"
  xmlns:ct="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Control"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  extension-element-prefixes="i18n"
  xmlns="http://www.w3.org/1999/xhtml">

  
  <xsl:import href="/transforms/xhtml/match-control.xsl"/>
  <xsl:import href="/transforms/insert-i18n.xsl"/>

  <xsl:template match="menu:menu">
    <div class="menu">
      <xsl:for-each select="./menu:section">
	<div class="menu-section">
	  <xsl:if test="./menu:header">
	    <h4 class="menu-header">
	      <xsl:apply-templates select="./menu:header/node()"/>
	    </h4>
	  </xsl:if>
	  <ul>
	    <xsl:for-each select="./menu:li">
	      <li>
		<xsl:choose>
		  <xsl:when test="./menu:url">
		    <a href="{./menu:url}"><xsl:apply-templates
			select="./menu:text/node()"/></a>
		  </xsl:when>
		  <xsl:when test="./menu:text">
		    <xsl:attribute name="class">disabled</xsl:attribute>
		    <xsl:apply-templates select="./menu:text/node()"/>
		  </xsl:when>
		  <xsl:when test="@id='login'">
		    <xsl:attribute name="class">form</xsl:attribute>
		    <form method="GET" action="/login">
		      <fieldset class="login">
			<xsl:apply-templates select="./ct:control"/>
		      </fieldset>
		    </form>
		  </xsl:when>
		</xsl:choose>
	      </li>
	    </xsl:for-each>
	  </ul>
	</div>
      </xsl:for-each>
    </div>
  </xsl:template>
</xsl:stylesheet>
