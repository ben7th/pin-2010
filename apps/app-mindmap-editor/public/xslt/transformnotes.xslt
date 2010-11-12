<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ap="http://schemas.mindjet.com/MindManager/Application/2003">
  <xsl:output method="html" encoding="UTF-8" indent="no"/>
  <xsl:template match="ap:Map|ap:MapTemplate">
    <xsl:for-each select="ap:OneTopic">
      <Notes>
        <xsl:call-template name="topic2">
        </xsl:call-template>
      </Notes>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="topic2">
    <xsl:for-each select="ap:Topic">
      <xsl:variable name="x">
        <xsl:number level="any"/>
      </xsl:variable>
        <xsl:call-template name="subtopic2">
        </xsl:call-template>
        <xsl:if test="ap:NotesGroup/ap:NotesXhtmlData">
          <Note>
            <xsl:attribute name="id">
              <xsl:value-of select="$x"/>
            </xsl:attribute>
            <xsl:copy-of select="ap:NotesGroup/ap:NotesXhtmlData/*"/>
          </Note>
        </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="subtopic2">
    <xsl:for-each select="ap:SubTopics">
      <xsl:call-template name="topic2">
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>