<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:cat="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category/Output"
  xmlns="http://www.w3.org/1999/xhtml">

  <xsl:template match="control">
    <div class="control">
      <label for="{@name}">
	<xsl:value-of select="./title"/>
      </label>
      
      <p class="description">
	<xsl:copy-of select="./descr/node()"/>
      </p>

      <xsl:choose>
	<xsl:when test="@element='input'">
	  <xsl:choose>
	    <xsl:when test="@type='checkbox'">
	      <input name="{@name}" id="{@name}" type="checkbox"
		value="1"> 
		<xsl:if test="./value='1'">
		  <xsl:attribute name="checked">checked</xsl:attribute>
		</xsl:if>
	      </input>
	    </xsl:when>
	    <xsl:otherwise>
	      <input name="{@name}" id="{@name}" type="{@type}" value="{./value}"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:when>
	<xsl:when test="@element='textarea'">
	  <textarea name="{@name}" id="{@name}">
	    <xsl:value-of select="./value"/>
	  </textarea>
	</xsl:when>
	<xsl:when test="@element='select'">
	  <select name="{./@name}" id="{./@name}">
	    <xsl:if test="../@type='multiple'">
	      <xsl:attribute name="multiple">multiple</xsl:attribute>
	    </xsl:if>
	    <xsl:for-each select="./value/user:level">
	      <option>
		<!-- xsl:attribute name="value"><xsl:number
		from="0"/></xsl:attribute -->
		<!-- This has to mark as selected both in the case where we have
		a single parameter found by param:get, but also where there are
		multiple as found by param:enumerate -->
		<xsl:if test=".=//user:authlevel">
		  <xsl:attribute name="selected">selected</xsl:attribute>
		</xsl:if>
		<xsl:value-of select="."/>
	      </option>
	    </xsl:for-each>     
	  </select>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates select="./cat:categories"/>
	</xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
  
  
  <xsl:template match="cat:categories">
    <select name="{../@name}" id="{../@name}">
      <xsl:if test="../@type='multiple'">
	<xsl:attribute name="multiple">multiple</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="./cat:category|cat:primcat"/>
    </select>
  </xsl:template>
  
  <xsl:template match="cat:category|cat:primcat">
    <option value="{cat:catname}">
      <!-- This has to mark as selected both in the case where we have
      a single parameter found by param:get, but also where there are
      multiple as found by param:enumerate -->
      <xsl:if test="../..//value=cat:catname">
	<xsl:attribute name="selected">selected</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="cat:name"/>
    </option>
  </xsl:template>
  

</xsl:stylesheet>
