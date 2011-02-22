<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:param name="emptynode">Empty Node</xsl:param>
  <xsl:template  match="map">
    <mindmap>
      <xsl:attribute name="ver">0.5</xsl:attribute>
      <xsl:call-template name="subtopic">
      </xsl:call-template>
    </mindmap>
  </xsl:template>
  <xsl:template name="subtopic">
    <xsl:for-each select="node">
      <xsl:variable name="x">
      <xsl:number level="any"/>
      </xsl:variable>
      <node>
        <xsl:attribute name="id"><xsl:value-of select="$x" /></xsl:attribute>
        <xsl:attribute name="title">
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
        <xsl:call-template name="subtopic"></xsl:call-template>
      </node>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>