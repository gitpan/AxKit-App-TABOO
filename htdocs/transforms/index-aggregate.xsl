<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output"
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  xmlns:aggr="http://www.kjetil.kjernsmo.net/software/TABOO/NS/IndexAggr"
  xmlns="http://www.w3.org/1999/xhtml">
  <xsl:output encoding="utf-8"
    media-type="text/xml" indent="yes"/>
  
  <xsl:param name="session.id"/>
  <xsl:param name="request.headers.host"/>

  <xsl:template match="/aggr:stories">
    <!-- constructing the URI using Apache::AxKit::Plugin::Passthru
    and Apache::AxKit::Plugin::AddXSLParams::Request -->
    <xsl:variable name="uri" select="concat('http://',
      $request.headers.host, aggr:story, '?passthru=1&amp;SID=', $session.id)"/>

    <xsl:copy-of select="document($uri)"/>
  </xsl:template>
</xsl:stylesheet>
  