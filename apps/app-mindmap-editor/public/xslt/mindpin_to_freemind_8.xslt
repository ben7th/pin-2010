<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template  match="Nodes">
    <map version="0.8.1">
      <xsl:call-template name="subtopic" />
    </map>
  </xsl:template>
  <xsl:template name="subtopic">
    <xsl:for-each select="N">
      <node>
        <xsl:attribute name="id">
          <xsl:value-of select="@id" />
        </xsl:attribute>
        <xsl:attribute name="TEXT">
          <xsl:choose>
            <xsl:when test="@i">
              <xsl:value-of select="concat('&lt;','html','&gt;','&lt;','img ',' src=',@i,' width=',@iw,' height=',@ih,' /&gt;','&lt;hr /&gt;',@t)" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@t" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:if test="@pr">
          <xsl:attribute name="POSITION">
            <xsl:choose>
              <xsl:when test="@pr='1'">right</xsl:when>
              <xsl:when test="@pr='0'">left</xsl:when>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>
        <xsl:call-template name="subtopic"></xsl:call-template>
      </node>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>