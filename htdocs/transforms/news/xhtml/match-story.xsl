<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cust="http://www.kjetil.kjernsmo.net/software/TABOO/NS/CustomGrammar"
  xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:cat="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category/Output"
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  xmlns:texts="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N/Texts"
  exclude-result-prefixes="cust user story cat i18n texts"> 

  <xsl:import href="/transforms/insert-i18n.xsl"/>
  <xsl:import href="match-user.xsl"/>


  <xsl:template match="taboo[@type='story']/story:story|/cust:submit//story:story">
    <h2>
      <xsl:choose>
	<xsl:when test="/taboo[@commentstatus='singlecomment'] or /taboo[@commentstatus='threadonly']">
	  <a>
	    <xsl:attribute name="href">
	      <xsl:text>/news/</xsl:text><xsl:value-of
		select="story:sectionid"/><xsl:text>/</xsl:text><xsl:value-of
		select="story:storyname"/><xsl:text>/comment/</xsl:text>
	    </xsl:attribute>
	    <xsl:value-of select="story:title"/>
	  </a>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="story:title"/>
	</xsl:otherwise>
      </xsl:choose>
    </h2>
    <div id="byline">
      <xsl:if test="user:submitter">
	<xsl:value-of select="i18n:include('submit-by')"/>
	<xsl:apply-templates select="user:submitter"/>
      </xsl:if>
      <xsl:if test="user:user">
	<xsl:value-of select="i18n:include('posted-by')"/>
	<xsl:apply-templates select="user:user"/>
      </xsl:if>
    </div>
    <xsl:if test="cat:primcat">
      <div id="catinfo">
	<xsl:value-of select="i18n:include('to-cat')"/>
	<xsl:apply-templates select="cat:primcat"/>
      </div>
    </xsl:if>
    <div id="timeinfo">
      <xsl:value-of select="i18n:include('on-time')"/>
      <xsl:apply-templates select="story:timestamp"/>
      <xsl:value-of select="i18n:include('last-changed')"/>
      <xsl:apply-templates select="story:lasttimestamp"/>
    </div>
    <div class="minicontent">
      <xsl:apply-templates select="story:minicontent[not(@raw)]/*" mode="strip-ns"/>
    </div>
    <div class="content">
      <xsl:apply-templates select="story:content[not(@raw)]/*" mode="strip-ns"/>
    </div>
      
  </xsl:template>

  <xsl:template match="taboo[@type='stories']/story:story">
    <div>
      <xsl:attribute name="class">
	<xsl:choose>
	  <xsl:when test="story:editorok=1">
	    <xsl:text>editor-ok</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>editor-not-ok</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <h3>
	<a>
	  <xsl:attribute name="href">
	    <xsl:text>/news/</xsl:text><xsl:value-of
	      select="story:sectionid"/><xsl:text>/</xsl:text><xsl:value-of
	      select="story:storyname"/><xsl:text>/comment/</xsl:text>
	  </xsl:attribute>
	  <xsl:value-of select="story:title"/>
	</a>
      </h3>
      <div class="byline">
	<xsl:value-of select="i18n:include('submit-by')"/>
	<xsl:apply-templates select="user:submitter"/>
	<xsl:value-of select="i18n:include('posted-by')"/>
	<xsl:apply-templates select="user:user"/>
      </div>
      <div class="catinfo">
	<xsl:value-of select="i18n:include('to-cat')"/>
	<xsl:apply-templates select="cat:primcat"/>
      </div>
      <div class="timeinfo">
	<xsl:value-of select="i18n:include('on-time')"/>
	<xsl:apply-templates select="story:timestamp"/>
	<xsl:value-of select="i18n:include('last-changed')"/>
	<xsl:apply-templates select="story:lasttimestamp"/>
      </div>
      <div class="minicontent">
	<xsl:apply-templates select="story:minicontent[not(@raw)]/*" mode="strip-ns"/>
      </div>
      <div class="readmorelink">
	<a>
	  <xsl:attribute name="href">
	    <xsl:text>/news/</xsl:text><xsl:value-of
	      select="story:sectionid"/><xsl:text>/</xsl:text><xsl:value-of
	      select="story:storyname"/><xsl:text>/comment/</xsl:text>
	  </xsl:attribute>
	  <xsl:value-of select="story:linktext"/>
	</a>
      </div>
      <xsl:if test="/taboo[@can-edit]">
	<div class="editlink">
	  <a href="/news/{story:sectionid}/{story:storyname}/edit">
	    <xsl:value-of select="i18n:include('edit')"/>
	  </a>
	</div>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="taboo[@type='list']/story:story">
    <tr>
      <xsl:attribute name="class">
	<xsl:choose>
	  <xsl:when test="story:editorok=1">
	    <xsl:text>editor-ok</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>editor-not-ok</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <td>
	<a>
	  <xsl:attribute name="href">
	    <xsl:text>/news/</xsl:text><xsl:value-of
	      select="story:sectionid"/><xsl:text>/</xsl:text><xsl:value-of
	      select="story:storyname"/><xsl:text>/</xsl:text>
	  </xsl:attribute>
	  <xsl:value-of select="story:title"/>
	</a>
      </td>
      <td><xsl:apply-templates select="user:submitter"/></td>
      <td><xsl:apply-templates select="cat:primcat"/></td>
      <td><xsl:apply-templates select="story:timestamp"/></td>
      <td><xsl:apply-templates select="story:lasttimestamp"/></td>
      <xsl:if test="/taboo[@can-edit]">
	<td>
	  <a href="/news/{story:sectionid}/{story:storyname}/edit">
	    <xsl:value-of select="i18n:include('edit')"/>
	  </a>
	</td>
      </xsl:if>
    </tr>
  </xsl:template>

  <xsl:template match="cat:primcat">
    <xsl:value-of select="cat:name"/>
  </xsl:template>

  <xsl:template match="story:timestamp|story:lasttimestamp">
    <span class="time">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template match="*" mode="strip-ns">
    <xsl:element name="{local-name()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="strip-ns"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
