<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output"
  xmlns:comm="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Comment/Output"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:wn="http://xmlns.com/wordnet/1.6/"      
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  xmlns:texts="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N/Texts"
  exclude-result-prefixes="user comm story rdf wn dc i18n texts"> 

  <xsl:import href="match-story.xsl"/>
  <xsl:import href="match-comment.xsl"/>
  <xsl:import href="/transforms/xhtml/header.xsl"/>
  <xsl:import href="/transforms/xhtml/footer.xsl"/>

  <xsl:output version="1.0" encoding="utf-8" indent="yes"
    method="html" media-type="text/html" 
    doctype-public="-//W3C//DTD HTML 4.01//EN" 
    doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>  

  <xsl:param name="request.headers.host"/>
  <xsl:param name="request.uri"/>
  <xsl:param name="session.id"/>
  <xsl:param name="neg.lang">en</xsl:param>

  <xsl:template match="/taboo">
    <html lang="{$neg.lang}">
      <head>
	<title>
	  <xsl:choose>
	    <xsl:when test="@commentstatus = 'threadonly'">
	      <xsl:value-of select="i18n:include('comments')"/>
	      <xsl:value-of select="i18n:include('to')"/>
	    </xsl:when>
	    <xsl:when test="@commentstatus = 'singlecomment'">
	      <xsl:value-of select="/taboo/comm:reply/user:user/user:name"/>
	      <xsl:value-of select="i18n:include('comments-verb')"/>
	      <xsl:text>: </xsl:text>
	      <xsl:value-of select="/taboo/comm:reply/comm:title"/>
	      <xsl:text> | </xsl:text>
	    </xsl:when>
	  </xsl:choose>
	  <xsl:value-of select="/taboo/story:story/story:title"/>
	  <xsl:if test="@commentstatus='everything'">
	    <xsl:value-of select="i18n:include('with')"/>
	    <xsl:value-of select="i18n:include('comments')"/>
	  </xsl:if>
	  <xsl:text> | </xsl:text>
	  <xsl:value-of select="document('/site/main.rdf')//dc:title/rdf:Alt/rdf:_2"/>
	
	</title>
	<link rel="stylesheet" type="text/css" href="/css/basic.css"/>
	<link rel="top" href="/"/>
      </head>
      <body>
	<xsl:call-template name="CreateHeader"/>
	<div id="container">
	  <xsl:variable name="uri" select="concat('http://',
	    $request.headers.host, '/menu.xsp?SID=' , $session.id)"/>
	  <xsl:copy-of select="document($uri)"/>
	  <div class="main">
	    <xsl:apply-templates select="/taboo/story:story"/>
	    <xsl:if test="not(@commentstatus = 'singlecomment' or @commentstatus = 'threadonly')">
	      <div class="reply-link">
		<a>
		  <xsl:attribute name="href">
		    <xsl:value-of select="substring-before($request.uri, 'comment/')"/>
		    <xsl:text>comment/respond</xsl:text>
		  </xsl:attribute>
		  <xsl:value-of select="i18n:include('reply-to-this')"/>
		</a>
	      </div>
	    </xsl:if>
	    <xsl:apply-templates select="/taboo/comm:reply"/>
	    <div class="commentlist">
	      <xsl:apply-templates select="/taboo/comm:commentlist/comm:reply"/>
	    </div>
	  </div>
	</div>
	<xsl:call-template name="CreateFooter"/>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
