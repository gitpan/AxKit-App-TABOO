<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:cat="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category/Output"
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  xmlns="http://www.w3.org/1999/xhtml">  
  <xsl:output method="xml" version="1.0" encoding="utf-8"
    media-type="text/xml" indent="yes"/>

  <xsl:template match="/taboo[@type='story']/story:story|/submit//story:story">
    <h2><xsl:value-of select="story:title"/></h2>
    <div id="byline">
      <i18n:insert name="submit-by"/>
      <xsl:apply-templates select="user:submitter"/>
      <i18n:insert name="posted-by"/>
       <xsl:apply-templates select="user:user"/>
    </div>
    <div id="catinfo">
      <i18n:insert name="to-cat"/>
      <xsl:apply-templates select="cat:primcat"/>
    </div>
    <div id="timeinfo">
      <i18n:insert name="on"/>
      <xsl:apply-templates select="story:timestamp"/>
      <i18n:insert name="last-changed"/>
      <xsl:apply-templates select="story:lasttimestamp"/>
    </div>
    <div class="minicontent">
      <xsl:value-of select="story:minicontent"/>
    </div>
    <div class="content">
      <xsl:value-of select="story:content"/>
    </div>
      
  </xsl:template>

  <xsl:template match="/taboo[@type='stories']/story:story">
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
      <h2>
	<a>
	  <xsl:attribute name="href">
	    <xsl:text>/news/</xsl:text><xsl:value-of
	      select="story:sectionid"/><xsl:text>/</xsl:text><xsl:value-of
	      select="story:storyname"/><xsl:text>/</xsl:text>
	  </xsl:attribute>
	  <xsl:value-of select="story:title"/>
	</a>
      </h2>
      <div class="byline">
	<i18n:insert name="submit-by"/>
	<xsl:apply-templates select="user:submitter"/>
	<i18n:insert name="posted-by"/>
	<xsl:apply-templates select="user:user"/>
      </div>
      <div class="catinfo">
	<i18n:insert name="to-cat"/>
	<xsl:apply-templates select="cat:primcat"/>
      </div>
      <div class="timeinfo">
	<i18n:insert name="on"/>
	<xsl:apply-templates select="story:timestamp"/>
	<i18n:insert name="last-changed"/>
	<xsl:apply-templates select="story:lasttimestamp"/>
      </div>
      <div class="minicontent">
	<xsl:value-of select="story:minicontent"/>
      </div>
      <div class="readmorelink">
	<a>
	  <xsl:attribute name="href">
	    <xsl:text>/news/</xsl:text><xsl:value-of
	      select="story:sectionid"/><xsl:text>/</xsl:text><xsl:value-of
	      select="story:storyname"/><xsl:text>/</xsl:text>
	  </xsl:attribute>
	  <xsl:value-of select="story:linktext"/>
	</a>
      </div>
      <xsl:if test="/taboo[@can-edit]">
	<a>
	  <xsl:attribute name="href">
	    <xsl:text>/news/submit?edit=true&amp;sectionid=</xsl:text>
	    <xsl:value-of select="story:sectionid"/>
	    <xsl:text>&amp;storyname=</xsl:text>
	    <xsl:value-of select="story:storyname"/>
	  </xsl:attribute>
	  <i18n:insert name="edit"/>
	</a>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="/taboo[@type='list']/story:story">
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
	  <a>
	    <xsl:attribute name="href">
	      <xsl:text>/news/submit?edit=true&amp;sectionid=</xsl:text>
	      <xsl:value-of select="story:sectionid"/>
	      <xsl:text>&amp;storyname=</xsl:text>
	      <xsl:value-of select="story:storyname"/>
	    </xsl:attribute>
	    <i18n:insert name="edit"/>
	  </a>
	</td>
      </xsl:if>
    </tr>
  </xsl:template>


  <xsl:template match="user:user|user:submitter">
    <span class="by">
      <a>
	<xsl:attribute name="href">
	  <xsl:text>/user/</xsl:text><xsl:value-of
	  select="user:username"/>
	</xsl:attribute>
	<xsl:value-of select="user:name"/>
      </a>
    </span>
  </xsl:template>

  <xsl:template match="cat:primcat">
    <xsl:value-of select="cat:name"/>
  </xsl:template>

  <xsl:template match="story:timestamp|story:lasttimestamp">
    <span class="time">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

</xsl:stylesheet>





