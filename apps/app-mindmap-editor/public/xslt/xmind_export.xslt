<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml">
  <xsl:output encoding="UTF-8" standalone="no"/>
  <xsl:template match="Nodes">
    <xmap-content xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:svg="http://www.w3.org/2000/svg" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0">
      <sheet>
        <xsl:call-template name="topic" />
        <title>画布 1</title>
      </sheet>
    </xmap-content>
  </xsl:template>

  <xsl:template name="topic">
    <xsl:for-each select="N">
      <topic>
        <xsl:attribute name="id">
          <xsl:value-of select="@id" />
        </xsl:attribute>
        <children>
          <topics type="attached">
            <xsl:call-template name="topic" />
          </topics>
        </children>
        <title>
          <xsl:value-of select="@t" />
        </title>
        <xsl:if test="@i">
          <xhtml:img>
            <xsl:attribute name="svg:height">
              <xsl:value-of select="@ih" />
            </xsl:attribute>
            <xsl:attribute name="svg:width">
              <xsl:value-of select="@iw" />
            </xsl:attribute>
            <xsl:attribute name="xhtml:src">
              <xsl:value-of select="@i" />
            </xsl:attribute>
          </xhtml:img>
        </xsl:if>
      </topic>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
