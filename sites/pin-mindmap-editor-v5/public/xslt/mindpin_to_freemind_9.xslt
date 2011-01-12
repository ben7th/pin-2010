<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template  match="mindmap">
    <map version="0.9.0">
      <xsl:call-template name="subtopic" />
    </map>
  </xsl:template>
  <xsl:template name="subtopic">
    <xsl:for-each select="node">
      <node>
        <xsl:attribute name="id">
          <xsl:value-of select="@id" />
        </xsl:attribute>
        <xsl:if test="@pos">
          <xsl:attribute name="POSITION">
            <xsl:choose>
              <xsl:when test="@pos='right'">right</xsl:when>
              <xsl:when test="@pos='left'">left</xsl:when>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>
        <richcontent TYPE="NODE">
          <html>
            <head>
            </head>
            <body>
              <xsl:if test="@img">
                <img>
                  <xsl:attribute name="src">
                    <xsl:value-of select="@img" />
                  </xsl:attribute>
                  <xsl:attribute name="width">
                    <xsl:value-of select="@imgw" />
                  </xsl:attribute>
                  <xsl:attribute name="height">
                    <xsl:value-of select="@imgh" />
                  </xsl:attribute>
                </img>
              </xsl:if>
              <p>
                <xsl:value-of select="@title" />
              </p>
            </body>
          </html>
        </richcontent>
        <xsl:call-template name="subtopic"></xsl:call-template>
      </node>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>