<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:param name="emptynode">Empty Node</xsl:param>
  <xsl:template  match="map">
    <Nodes>
      <xsl:attribute name="maxid"> <xsl:value-of select="count(//node)+1"/> </xsl:attribute>
      <xsl:call-template name="subtopic">
      </xsl:call-template>
    </Nodes>
  </xsl:template>
  <xsl:template name="subtopic">
    <xsl:for-each select="node">
      <xsl:variable name="x">
      <xsl:number level="any"/>
      </xsl:variable>
      <N>
        <xsl:attribute name="id"><xsl:value-of select="$x" /></xsl:attribute>
        <xsl:attribute name="t">
	  <xsl:choose>
	  <xsl:when test="attribute::TEXT!=''">
	     <xsl:value-of select="attribute::TEXT" />
	  </xsl:when>
	  <xsl:when test="attribute::TEXT=''">
	     <xsl:value-of select="$emptynode"/>
	  </xsl:when>
	  <xsl:otherwise>
		<xsl:for-each select="richcontent">
		  <xsl:if test="attribute::TYPE='NODE'">
		    <xsl:for-each select="child::html/body/p">
		     <xsl:if test="normalize-space(text())!=''">
		     <xsl:value-of select="normalize-space(text())"/>
		     </xsl:if>
	            </xsl:for-each>
		  </xsl:if>
		</xsl:for-each>
	  </xsl:otherwise>
	  </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="sc"><xsl:value-of select="count(descendant::node)" /></xsl:attribute>
        <xsl:call-template name="subtopic"></xsl:call-template>
      </N>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>