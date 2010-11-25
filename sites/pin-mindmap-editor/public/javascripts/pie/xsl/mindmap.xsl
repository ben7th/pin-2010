<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" />
	<xsl:output encoding="utf-8" />

	<xsl:template match="/">
		<xsl:apply-templates select="Nodes/N" />
	</xsl:template>

	<xsl:template match="N">
		<xsl:choose>
			<xsl:when test="../../Nodes">
				<div>
					<xsl:attribute name="id"><xsl:value-of select="@id" /></xsl:attribute>
					<xsl:attribute name="class">root</xsl:attribute>
					<xsl:attribute name="style"> position:absolute;
						left:<xsl:value-of select="../@x" />px;top:<xsl:value-of select="../@y" />px;
					</xsl:attribute>
		
					<!--image-->
					<xsl:choose>
						<xsl:when test="@i!=''">
							<img>
								<xsl:attribute name="id">i_<xsl:value-of select="@id"/></xsl:attribute>
								<xsl:attribute name="src">/mindmap_editor/javascripts/pie/img/1px.gif</xsl:attribute>
								<xsl:attribute name="border"><xsl:value-of select="@ib"/></xsl:attribute>
								<xsl:attribute name="width"><xsl:value-of select="@iw"/></xsl:attribute>
								<xsl:attribute name="height"><xsl:value-of select="@ih"/></xsl:attribute>
								<xsl:attribute name="onerror">return false;</xsl:attribute>
								<xsl:attribute name="style">width:<xsl:value-of select="@iw"/>px;height:<xsl:value-of select="@ih"/>px;background-image:url(<xsl:value-of select="@i"/>);</xsl:attribute>
							</img>
						</xsl:when>
					</xsl:choose>
		
					<!--title-->
					<div>
						<div class="pn_title" style="">
							<xsl:choose>
								<xsl:when test="@t!=''">
									<xsl:value-of select="@t" />
								</xsl:when>
								<xsl:otherwise>Empty Node</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</div>

				<xsl:apply-templates select="N"/>

			</xsl:when>
			<xsl:otherwise>
				<div class="mindmap-container">
					<xsl:attribute name="id">c_<xsl:value-of select="@id" /></xsl:attribute>
					<xsl:attribute name="style">position:absolute;</xsl:attribute>
					<div>
						<xsl:attribute name="id"><xsl:value-of select="@id" /></xsl:attribute>
					    <xsl:attribute name="class">node</xsl:attribute>
						<xsl:attribute name="style"> position:absolute;</xsl:attribute>
			
						<!--image-->
						<xsl:choose>
							<xsl:when test="@i!=''">
								<img>
									<xsl:attribute name="id">i_<xsl:value-of select="@id"/></xsl:attribute>
									<xsl:attribute name="src">/mindmap_editor/javascripts/pie/img/1px.gif</xsl:attribute>
									<xsl:attribute name="border"><xsl:value-of select="@ib"/></xsl:attribute>
									<xsl:attribute name="width"><xsl:value-of select="@iw"/></xsl:attribute>
									<xsl:attribute name="height"><xsl:value-of select="@ih"/></xsl:attribute>
									<xsl:attribute name="onerror">return false;</xsl:attribute>
									<xsl:attribute name="style">width:<xsl:value-of select="@iw"/>px;height:<xsl:value-of select="@ih"/>px;background-image:url(<xsl:value-of select="@i"/>);</xsl:attribute>
								</img>
							</xsl:when>
						</xsl:choose>
			
						<!--title-->
						<div>
							<div class="pn_title" style="">
								<xsl:choose>
									<xsl:when test="@t!=''">
										<xsl:value-of select="@t" />
									</xsl:when>
									<xsl:otherwise>Empty Node</xsl:otherwise>
								</xsl:choose>
							</div>
						</div>
					</div>

			        <div>
			          <xsl:attribute name="id">f_<xsl:value-of select="@id"/></xsl:attribute>
			          <xsl:choose>
			            <xsl:when test="@f=1">
			              <xsl:attribute name="class">foldhandler_plus</xsl:attribute>
			            </xsl:when>
			            <xsl:otherwise>
			              <xsl:attribute name="class">foldhandler_minus</xsl:attribute>
			            </xsl:otherwise>
			          </xsl:choose>
			          <xsl:attribute name="style">position:absolute;
						  <xsl:choose>
							<xsl:when test="N">
							</xsl:when>
							<xsl:otherwise>
								display:none;
							</xsl:otherwise>
						  </xsl:choose>
			          </xsl:attribute>
			        </div>

					<div class="mindmap-children">
						<xsl:attribute name="id">children_<xsl:value-of select="@id" /></xsl:attribute>
						<xsl:attribute name="style">position:absolute;</xsl:attribute>
						<xsl:apply-templates select="N"/>
					</div>
					
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
