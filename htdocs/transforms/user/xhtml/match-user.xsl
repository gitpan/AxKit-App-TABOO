<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  xmlns:html="http://www.w3.org/1999/xhtml">  
  <xsl:output method="xml" version="1.0" encoding="utf-8"
    media-type="text/xml" indent="yes"/>


  <xsl:template match="user:user">
    <html:h2><xsl:value-of select="./user:name"/></html:h2>
    <html:dl>
      <html:dt>
	Username
      </html:dt>
      <html:dd><xsl:value-of select="./user:username"/></html:dd>
      <html:dt>
	E-mail
      </html:dt>
      <html:dd>
	<html:a href="mailto:{./user:email}">
	  <xsl:value-of select="./user:email"/>
	</html:a>
      </html:dd>
      <html:dt>
	Bio
      </html:dt>
      <html:dd><xsl:value-of select="./user:bio"/></html:dd>
    </html:dl>
  </xsl:template>
</xsl:stylesheet>
