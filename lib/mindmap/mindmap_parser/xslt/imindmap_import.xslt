<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:param name="emptynode">Empty Node</xsl:param>
  <xsl:param name="root_id" select="/map/mindmap/@mindmap_root_node" />

  <xsl:template match="map">
    <mindmap>
      <xsl:attribute name="ver">0.5</xsl:attribute>
      <xsl:call-template name="root" />
    </mindmap>
  </xsl:template>

  
  <xsl:template name="root">
    <xsl:for-each select="//branch">
      <xsl:variable name="x">
        <xsl:number level="any" />
      </xsl:variable>
      <xsl:if test="@id=$root_id">
        <node>
          <xsl:attribute name="id">
            <xsl:value-of select="$x" />
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:value-of select="@name" />
          </xsl:attribute>
          <xsl:call-template name="subtopic">
            <xsl:with-param name="parent_id" select="@id" />
          </xsl:call-template>
        </node>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="subtopic">
    <xsl:for-each select="//branch">
      <xsl:variable name="x">
        <xsl:number level="any" />
      </xsl:variable>
      <xsl:if test="@parent_id=$parent_id">
        <node>
          <xsl:attribute name="id">
            <xsl:value-of select="$x" />
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:value-of select="@name" />
          </xsl:attribute>
          <xsl:call-template name="subtopic">
            <xsl:with-param name="parent_id" select="@id" />
          </xsl:call-template>
        </node>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>