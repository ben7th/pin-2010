<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template  match="mindmap">
    <map version="0.8.1">
      <xsl:call-template name="subtopic" />
    </map>
  </xsl:template>
  <xsl:template name="subtopic">
    <xsl:for-each select="node">
      <node>
        <xsl:attribute name="id">
          <xsl:value-of select="@id" />
        </xsl:attribute>
        <xsl:attribute name="TEXT">
          <xsl:choose>
            <xsl:when test="@img">
              <xsl:value-of select="concat('&lt;','html','&gt;','&lt;','img ',' src=',@img,' width=',@imgw,' height=',@imgh,' /&gt;','&lt;hr /&gt;',@title)" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@title" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:if test="@pos">
          <xsl:attribute name="POSITION">
            <xsl:choose>
              <xsl:when test="@pos='right'">right</xsl:when>
              <xsl:when test="@pos='left'">left</xsl:when>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>
        <xsl:call-template name="subtopic"></xsl:call-template>
      </node>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>