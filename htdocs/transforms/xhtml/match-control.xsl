<?xml version="1.0"?>
<!-- The control stuff here is actually just a bad reinvention of -->
<!-- XForms... At this point, I think it is too much to change to go -->
<!-- with XForms, but it is certainly desireable for the future. -->

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ct="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Control"
  xmlns:story="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Story/Output"
  xmlns:user="http://www.kjetil.kjernsmo.net/software/TABOO/NS/User/Output"
  xmlns:cat="http://www.kjetil.kjernsmo.net/software/TABOO/NS/Category/Output"
  xmlns:i18n="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N"
  xmlns:texts="http://www.kjetil.kjernsmo.net/software/TABOO/NS/I18N/Texts"
  extension-element-prefixes="i18n"
  exclude-result-prefixes="user story cat ct i18n texts">


  <xsl:import href="../../transforms/insert-i18n.xsl"/>

  <xsl:template match="ct:control">
    <xsl:choose>
      <xsl:when test="@type='hidden'">
	<xsl:choose>
	  <xsl:when test="./ct:value/i18n:insert">
	    <input name="{@name}" id="{@name}" type="{@type}" 
		   value="{i18n:include(./ct:value/i18n:insert)}"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <input name="{@name}" id="{@name}" type="{@type}" 
		   value="{./ct:value}"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<div class="control">
	  <label for="{@name}">
	    <xsl:apply-templates select="./ct:title/node()"/>
	  </label>
	  
	  <xsl:if test="./ct:descr">
	    <p class="description">
	      <xsl:apply-templates select="./ct:descr/node()"/>
	    </p>
	  </xsl:if>
	  
	  <xsl:choose>
	    <xsl:when test="@element='input'">
	      <xsl:choose>
		<xsl:when test="@type='checkbox'">
		  <input name="{@name}" id="{@name}" type="checkbox"
			 value="1"> 
		    <xsl:if test="./ct:value='1'">
		      <xsl:attribute name="checked">checked</xsl:attribute>
		    </xsl:if>
		  </input>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:choose>
		    <xsl:when test="./ct:value/i18n:insert">
		      <input name="{@name}" id="{@name}" type="{@type}" 
			     value="{i18n:include(./ct:value/i18n:insert)}">
			<xsl:if test="@size">
			  <xsl:attribute name="size">
			    <xsl:value-of select="@size"/>
			  </xsl:attribute>
			</xsl:if>
			<xsl:if test="@maxlength">
			  <xsl:attribute name="maxlength">
			    <xsl:value-of select="@maxlength"/>
			  </xsl:attribute>
			</xsl:if>
		      </input>
		    </xsl:when>
		    <xsl:otherwise>
		      <input name="{@name}" id="{@name}" type="{@type}" 
			     value="{./ct:value}">
			<xsl:if test="@size">
			  <xsl:attribute name="size">
			    <xsl:value-of select="@size"/>
			  </xsl:attribute>
			</xsl:if>
			<xsl:if test="@maxlength">
			  <xsl:attribute name="maxlength">
			    <xsl:value-of select="@maxlength"/>
			  </xsl:attribute>
			</xsl:if>
		      </input>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:when>
	    <xsl:when test="@element='textarea'">
	      <textarea name="{@name}" id="{@name}"
			rows="{@rows}" cols="{@cols}">
		<xsl:apply-templates select="./ct:value/node()"/>
	      </textarea>
	    </xsl:when>
	    <xsl:when test="@element='select'">
	      <select name="{./@name}" id="{./@name}">
		<xsl:if test="../@type='multiple'">
		  <xsl:attribute name="multiple">multiple</xsl:attribute>
		</xsl:if>
		<xsl:for-each select="./ct:value/user:level">
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
      </xsl:otherwise>
    </xsl:choose>
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
      <xsl:if test="../..//ct:value=cat:catname">
	<xsl:attribute name="selected">selected</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="cat:name"/>
    </option>
  </xsl:template>
  

</xsl:stylesheet>
