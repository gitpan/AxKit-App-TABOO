<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns="http://www.w3.org/1999/xhtml">
  <xsl:import href="match-user.xsl"/>
  <xsl:import href="../../../transforms/xhtml/match-control.xsl"/>
  <xsl:output version="1.0" encoding="utf-8" 
    media-type="text/xml" indent="yes"/>  
  <xsl:template match="user">
    <html lang="en">
      <head>
	<title><xsl:copy-of select="./title/node()"/></title>
      </head>
      <body>      

	<h1><xsl:copy-of select="./title/node()"/></h1>

	<xsl:apply-templates select="//user:user"/>



	<form method="GET" action="user.xsp">
	  <fieldset>
	    <xsl:apply-templates select="./control"/>
	  </fieldset>
	</form>
	
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>