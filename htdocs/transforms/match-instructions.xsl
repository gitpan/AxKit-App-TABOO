<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:template name="TextileInstructions">
    <xsl:variable name="textile" select="document('/internal/textile.nb.xhtml')"/>
    <div class="documentation" id="textile">
      <h2><xsl:value-of select="$textile/html/body/section/h"/></h2>
      <xsl:copy-of select="$textile/html/body/section/p|$textile/html/body/section/ul"/>
    </div>
  </xsl:template>
</xsl:stylesheet>