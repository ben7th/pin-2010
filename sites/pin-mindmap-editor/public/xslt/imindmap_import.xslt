<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:param name="emptynode">Empty Node</xsl:param>
  <xsl:param name="root_id" select="/map/mindmap/@mindmap_root_node" />

  <xsl:template match="map">
    <Nodes>
      <xsl:attribute name="maxid">
        <xsl:value-of select="count(//branch)+1"/>
      </xsl:attribute>
      <xsl:call-template name="root" />
    </Nodes>
  </xsl:template>

  
  <xsl:template name="root">
    <xsl:for-each select="//branch">
      <xsl:variable name="x">
        <xsl:number level="any" />
      </xsl:variable>
      <xsl:if test="@id=$root_id">
        <N>
          <xsl:attribute name="id">
            <xsl:value-of select="$x" />
          </xsl:attribute>
          <xsl:attribute name="t">
            <xsl:value-of select="@name" />
          </xsl:attribute>
          <xsl:call-template name="subtopic">
            <xsl:with-param name="parent_id" select="@id" />
          </xsl:call-template>
        </N>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="subtopic">
    <xsl:for-each select="//branch">
      <xsl:variable name="x">
        <xsl:number level="any" />
      </xsl:variable>
      <xsl:if test="@parent_id=$parent_id">
        <N>
          <xsl:attribute name="id">
            <xsl:value-of select="$x" />
          </xsl:attribute>
          <xsl:attribute name="t">
            <xsl:value-of select="@name" />
          </xsl:attribute>
          <xsl:call-template name="subtopic">
            <xsl:with-param name="parent_id" select="@id" />
          </xsl:call-template>
        </N>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>