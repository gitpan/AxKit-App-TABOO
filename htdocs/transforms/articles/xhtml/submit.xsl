<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cust="http://www.kjetil.kjernsmo.net/software/TABOO/NS/CustomGrammar"
  xmlns:ct="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Control"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:art="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Article/Output"
  xmlns:cat="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category/Output"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:wn="http://xmlns.com/wordnet/1.6/"      
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  xmlns:texts="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N/Texts"
  xmlns:office="http://openoffice.org/2000/office" 
  exclude-result-prefixes="office user art rdf wn dc i18n texts html cust ct"> 


  <xsl:import href="/transforms/xhtml/header.xsl"/>
  <xsl:import href="/transforms/xhtml/footer.xsl"/>
  <xsl:import href="/transforms/insert-i18n.xsl"/>
  <xsl:import href="match-content.xsl"/>
  <xsl:import href="match-author.xsl"/>
  <xsl:import href="/transforms/news/xhtml/match-breadcrumbs.xsl"/>
  <xsl:import href="/transforms/match-instructions.xsl"/>
  <xsl:import href="/transforms/xhtml/match-control.xsl"/>

  <xsl:output version="1.0" encoding="utf-8" indent="yes"
    method="html" media-type="text/html" 
    doctype-public="-//W3C//DTD HTML 4.01//EN" 
    doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>  

  <xsl:param name="request.headers.host"/>
  <xsl:param name="request.uri"/>
  <xsl:param name="session.id"/>
  <xsl:param name="neg.lang">en</xsl:param>


  <xsl:template match="cust:submit">
    <html lang="{$neg.lang}">
      <head>
	<title>
	  <xsl:apply-templates select="./cust:title/node()"/>
	  <xsl:text> | </xsl:text>
	  <xsl:value-of select="document('/site/main.rdf')//dc:title/rdf:Alt/rdf:_2"/>
	</title>
	<xsl:call-template name="CommonHTMLHead"/>
	<link rel="top" href="/"/>
      </head>
      <body>
	<xsl:call-template name="CreateHeader"/>
	<div id="breadcrumb">
	  <xsl:call-template name="BreadcrumbTop"/>
	</div>
	<div id="container">
	  <xsl:variable name="uri" select="concat('http://',
	    $request.headers.host, '/menu.xsp?SID=' , $session.id)"/>
	  <xsl:copy-of select="document($uri)"/>
	  <div class="main">
	    <h2 class="pagetitle"><xsl:apply-templates select="./cust:title/node()"/></h2>

	    <xsl:apply-templates select="./art:article-submission"/>


	    <xsl:choose>
	      <xsl:when test="//art:store=1">
		<xsl:value-of select="i18n:include('article-stored')"/>
		<p>
		  <xsl:value-of
		      select="i18n:include('return-to-top-page')"/> 
		  <a rel="top" href="/"><xsl:value-of
		  select="document('/site/main.rdf')//dc:title/rdf:Alt/rdf:_1"/>
		  </a>
		</p>
	      </xsl:when>
	      <xsl:otherwise>
		<form method="post" enctype="multipart/form-data" action="/articles/submit.xsp">
		  <div class="fields">
		    <xsl:apply-templates select="./ct:control"/>
		  </div>
		</form>
		
		<xsl:call-template name="TextileInstructions"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </div>
	</div>
	<xsl:call-template name="CreateFooter"/>

      </body>
    </html>
  </xsl:template>

  <xsl:template match="art:article-submission">
    <h3 id="byline">
      <xsl:call-template name="ArticleAuthors"/>
    </h3>

    <xsl:value-of select="@contenturl"/>

    <!-- xsl:call-template name="ArticleContent">
      <xsl:with-param name="content" select="document(@contenturl)"/>
    </xsl:call-template -->


  </xsl:template>


</xsl:stylesheet>