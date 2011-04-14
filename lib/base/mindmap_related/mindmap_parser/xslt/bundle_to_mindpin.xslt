<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" version="1.0" encoding="utf-8"/>

  <xsl:template  match="bundle">
    <Nodes>
      <xsl:attribute name="maxid">
        <xsl:value-of select="count(//image|//text|//link)+1"/>
      </xsl:attribute>
      <N id="0" f="0" t="根节点">
        <xsl:call-template name="node" />
      </N>
    </Nodes>
  </xsl:template>

  <xsl:template name="node">
    <xsl:for-each select="text|image|link">
      <N>
        <xsl:choose>
          <xsl:when test="local-name()='text'">
            <xsl:variable name="x">
              <xsl:number level="any" />
            </xsl:variable>
            <xsl:attribute name="id">
              <xsl:value-of select="$x"/>
            </xsl:attribute>

            <xsl:attribute name="t">
              <xsl:value-of select="@value"/>
            </xsl:attribute>

          </xsl:when>
          <xsl:when test="local-name()='image'">
            <xsl:variable name="y">
              <xsl:number level="any" />
            </xsl:variable>
            <xsl:attribute name="id">
              <xsl:value-of select="$y + count(//text)"/>
            </xsl:attribute>

            <xsl:attribute name="t">image</xsl:attribute>

            <xsl:attribute name="i">
              <xsl:value-of select="@src"/>
            </xsl:attribute>

            <xsl:attribute name="ih">100</xsl:attribute>

            <xsl:attribute name="iw">100</xsl:attribute>
          
          </xsl:when>
          <xsl:when test="local-name()='link'">

            <xsl:variable name="z">
              <xsl:number level="any" />
            </xsl:variable>
            <xsl:attribute name="id">
              <xsl:value-of select="$z + count(//text|//image)"/>
            </xsl:attribute>

            <xsl:attribute name="t">
              <xsl:value-of select="concat(@text,' -- ',@href)"/>
            </xsl:attribute>
            
          </xsl:when>
        </xsl:choose>

        <xsl:call-template name="node" />
      </N>
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>