<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:wn="http://xmlns.com/wordnet/1.6/"      
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  exclude-result-prefixes="rdf wn i18n dc"> 

  <xsl:template name="CreateHeader">
    <div id="top" class="main-header">
      <h1>
	<a rel="top" href="/">
	  <xsl:value-of
	    select="document('/site/main.rdf')//dc:title/rdf:Alt/rdf:_1"/>
	</a>
      </h1>
      <p class="slogan">
	<xsl:value-of
	  select="document('/site/main.rdf')/rdf:RDF/rdf:Description/wn:slogan"/>
      </p>
    </div>
  </xsl:template>
</xsl:stylesheet>