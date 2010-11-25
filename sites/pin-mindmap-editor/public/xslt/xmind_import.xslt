<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output encoding="UTF-8" indent="no"/>
  <xsl:template match="xmap-content/sheet">
    <Nodes>
      <xsl:attribute name="maxid">
        <xsl:value-of select="count(//topic)+1"/>
      </xsl:attribute>
      <xsl:call-template name="node" />
    </Nodes>
  </xsl:template>

  <xsl:template name="node">
    <xsl:for-each select="topic">
      <xsl:variable name="x">
        <xsl:number level="any"/>
      </xsl:variable>
      <N>
        <xsl:attribute name="id">
          <xsl:value-of select="$x"/>
        </xsl:attribute>
        <xsl:attribute name="t">
          <xsl:value-of select="title"/>
        </xsl:attribute>
        <xsl:call-template name="subnode">
        </xsl:call-template>
      </N>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="subnode">
    <xsl:for-each select="children/topics">
      <xsl:call-template name="node">
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>