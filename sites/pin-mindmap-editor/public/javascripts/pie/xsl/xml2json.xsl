<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" />
	<xsl:output encoding="utf-8" />

	<xsl:param name="nodepaddingleft">0</xsl:param>
	<xsl:param name="folderwidth">11</xsl:param>
	<xsl:param name="folderbottom">6</xsl:param>

	<xsl:template match="/">
		<xsl:apply-templates select="Nodes/N" />
	</xsl:template>

	<xsl:template match="N">
		<xsl:choose>
			<xsl:when test="../../Nodes">{
					id:"<xsl:value-of select="@id" />",
					posX:"<xsl:value-of select="../@x" />",
					posY:"<xsl:value-of select="../@y" />",
					maxid:"<xsl:value-of select="../@maxid" />",
					title:"<xsl:value-of select="@t" />",
					richtitle:"<xsl:value-of select="@rt" />",
					<xsl:choose>
						<xsl:when test="@i!=''">
							image:{
								url:"<xsl:value-of select="@i" />",
								width:"<xsl:value-of select="@iw" />",
								height:"<xsl:value-of select="@ih" />",
								border:"<xsl:value-of select="@ib" />"
							},
						</xsl:when>
					</xsl:choose>
					children:[<xsl:apply-templates select="N"/>]
			}</xsl:when>
			<xsl:otherwise>{
					<xsl:choose>
						<xsl:when test="../../../Nodes">
							free:"<xsl:value-of select="@fr" />",
							freeX:"<xsl:value-of select="@x" />",
							freeY:"<xsl:value-of select="@y" />",
							putright:"<xsl:value-of select="@pr" />",
						</xsl:when>
					</xsl:choose>
					id:"<xsl:value-of select="@id" />",
					title:"<xsl:value-of select="@t" />",
					richtitle:"<xsl:value-of select="@rt" />",
					<xsl:choose>
						<xsl:when test="@i!=''">
							image:{
								url:"<xsl:value-of select="@i" />",
								width:"<xsl:value-of select="@iw" />",
								height:"<xsl:value-of select="@ih" />",
								border:"<xsl:value-of select="@ib" />"
							},
						</xsl:when>
					</xsl:choose>
					fold:"<xsl:value-of select="@f" />",
					children:[<xsl:apply-templates select="N"/>]
			},</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
