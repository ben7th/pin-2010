<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template  match="Nodes">
    <map version="0.9.0">
      <xsl:call-template name="subtopic" />
    </map>
  </xsl:template>
  <xsl:template name="subtopic">
    <xsl:for-each select="N">
      <node>
        <xsl:attribute name="id">
          <xsl:value-of select="@id" />
        </xsl:attribute>
        <xsl:if test="@pr">
          <xsl:attribute name="POSITION">
            <xsl:choose>
              <xsl:when test="@pr='1'">right</xsl:when>
              <xsl:when test="@pr='0'">left</xsl:when>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>
        <richcontent TYPE="NODE">
          <html>
            <head>
            </head>
            <body>
              <xsl:if test="@i">
                <img>
                  <xsl:attribute name="src">
                    <xsl:value-of select="@i" />
                  </xsl:attribute>
                  <xsl:attribute name="width">
                    <xsl:value-of select="@iw" />
                  </xsl:attribute>
                  <xsl:attribute name="height">
                    <xsl:value-of select="@ih" />
                  </xsl:attribute>
                </img>
              </xsl:if>
              <div>
                <xsl:value-of select="@t" />
              </div>
            </body>
          </html>
        </richcontent>
        <xsl:call-template name="subtopic"></xsl:call-template>
      </node>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>