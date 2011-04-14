<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output encoding="UTF-8" indent="no"/>
  <xsl:template match="Nodes">
    <map>
      <xsl:for-each select="/Nodes/N">
        <floating_image id="3b4d5691129638edc64-f" branch_image_filename="ellipse.png" associated_image_filename="" floating_image_bounds_x="0.0" floating_image_bounds_y="0.0" floating_image_bounds_width="165.0" floating_image_bounds_height="110.0" back_front_order_index="0" image_in_note="false" image_rotation="0.0" image_is_icon="false" >
          <xsl:attribute name="floating_image_parent_branch_id">
            <xsl:value-of select="@id" />
          </xsl:attribute>
        </floating_image>
        <mindmap id="3b4d5691129638edc64-7f55" mindmap_organic_level="5" mindmap_focused="false" mindmap_layout_mode="1" mindmap_project_view="false" mindmap_text_view="false" mindmap_sort="0" mindmap_zoom="100" shadow_colour="-4144960" imindmap_major_version="4" imindmap_minor_version="0" imindmap_build_number="0" imindmap_extra_version_info="290409" mindmap_main_edge_start_width="30" mindmap_medium_edge_width="5" mindmap_minor_edge_width="1" mindmap_is_read_only="false" mindmap_next_auto_colour_index="5" mindmap_background_colour="-1" mindmap_default_font_colour="-16777216" mindmap_is_text_colour_same_as_branch="false" sdocument-path="C:\imindmap.mmd" >
          <xsl:attribute name="mindmap_root_node">
            <xsl:value-of select="@id" />
          </xsl:attribute>
          <xsl:attribute name="name">
            <xsl:value-of select="@t" />
          </xsl:attribute>
        </mindmap>
        <branch text="" font_name="Serif.bold" font_style="1" font_size="28" branch_label_style="1" branch_colour="-16777216" branch_edge_mode="2" branch_label_align="3" branch_text_colour="-16777216" branch_order="99" task_start_date="1277254800375" task_end_date="1277341200375" branch_milestone="false" branch_project_managed="true" task_priority="0" task_percent_complete="0" parent_id="" branch_end_point_x="2817.5" branch_end_point_y="1995.0" branch_width="165" branch_height="110" branch_is_collapsed="false" branch_resource_index="-1" branch_resource_name="" branch_background_colour="-1" >
          <xsl:attribute name="id">
            <xsl:value-of select="@id" />
          </xsl:attribute>
          <xsl:attribute name="name">
            <xsl:value-of select="@t" />
          </xsl:attribute>
        </branch>
      </xsl:for-each>
      <xsl:call-template name="subtopic" />
    </map>
  </xsl:template>
  
  <xsl:template name="subtopic">
    <xsl:for-each select="/Nodes/N//N">
      <branch text="" font_name="Serif.plain" font_style="0" font_size="22" branch_label_style="1" branch_colour="-7154688" branch_edge_mode="2" branch_label_align="2" branch_text_colour="-16777216" branch_order="1" task_start_date="1277254800718" task_end_date="1277341200718" branch_milestone="false" branch_project_managed="true" task_priority="0" task_percent_complete="0" branch_end_point_x="2000" branch_end_point_y="2000" branch_width="0" branch_height="0" branch_is_collapsed="false" branch_resource_index="-1" branch_resource_name="" branch_background_colour="-1">
        <xsl:attribute name="parent_id">
          <xsl:value-of select="../@id" />
        </xsl:attribute>
        <xsl:attribute name="id">
          <xsl:value-of select="@id" />
        </xsl:attribute>
        <xsl:attribute name="name">
          <xsl:value-of select="@t" />
        </xsl:attribute>
      </branch>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>