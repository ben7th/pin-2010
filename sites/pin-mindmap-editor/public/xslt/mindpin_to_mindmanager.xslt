<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ap="http://schemas.mindjet.com/MindManager/Application/2003" xmlns:cor="http://schemas.mindjet.com/MindManager/Core/2003" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <xsl:output encoding="UTF-8" indent="no"/>
  <xsl:template match="Nodes">
    <ap:Map Dirty="0000000000000001" OId="e/71hCG/00mos3JswXjYjw==" Gen="0000000000000000" xmlns="http://www.w3.org/1999/xhtml" xmlns:ap="http://schemas.mindjet.com/MindManager/Application/2003" xmlns:cor="http://schemas.mindjet.com/MindManager/Core/2003" xmlns:pri="http://schemas.mindjet.com/MindManager/Primitive/2003" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.mindjet.com/MindManager/Application/2003 http://schemas.mindjet.com/MindManager/Application/2003 http://schemas.mindjet.com/MindManager/Core/2003 http://schemas.mindjet.com/MindManager/Core/2003 http://schemas.mindjet.com/MindManager/Delta/2003 http://schemas.mindjet.com/MindManager/Delta/2003 http://schemas.mindjet.com/MindManager/Primitive/2003 http://schemas.mindjet.com/MindManager/Primitive/2003">
      <cor:Custom Index="0" Uri="http://schemas.mindjet.com/MindManager/UpdateCompatibility/2004" Dirty="0000000000000000" cst0:UpdatedCategories="true" cst0:UpdatedVisibilityStyle="true" xmlns:cst0="http://schemas.mindjet.com/MindManager/UpdateCompatibility/2004"/>
      <ap:OneTopic>
        <xsl:call-template name="topic1"></xsl:call-template>
      </ap:OneTopic>
      <ap:StyleGroup>
        <ap:RootTopicDefaultsGroup>
          <ap:DefaultColor Dirty="0000000000000000" FillColor="ff99ccff" LineColor="ff808080" />
          <ap:DefaultText TextAlignment="urn:mindjet:Center" TextCapitalization="urn:mindjet:SentenceStyle" VerticalTextAlignment="urn:mindjet:Top" Dirty="0000000000000000" PlainText="Central Topic" ReadOnly="false">
            <ap:Font Color="ff373737" Size="14." Name="Arial" Bold="true" Italic="false" Underline="false" Strikethrough="false" />
          </ap:DefaultText>
          <ap:DefaultSubTopicShape SubTopicShape="urn:mindjet:RoundedRectangle" Dirty="0000000000000000" LeftMargin="3." TopMargin="3." BottomMargin="3." VerticalBottomMargin="2.5" VerticalLeftMargin="2.5" VerticalTopMargin="2.5" VerticalRightMargin="2.5" RightMargin="3." VerticalSubTopicShape="urn:mindjet:Rectangle" />
          <ap:DefaultLabelFloatingTopicShape LabelFloatingTopicShape="urn:mindjet:None" Dirty="0000000000000000" LeftMargin="0." TopMargin="0." BottomMargin="0." VerticalBottomMargin="2.5" VerticalLeftMargin="2.5" VerticalTopMargin="2.5" VerticalRightMargin="2.5" RightMargin="0." VerticalLabelFloatingTopicShape="urn:mindjet:None" />
          <ap:DefaultCalloutFloatingTopicShape CalloutFloatingTopicShape="urn:mindjet:None" Dirty="0000000000000000" VerticalCalloutFloatingTopicShape="urn:mindjet:None" LeftMargin="0." TopMargin="0." BottomMargin="0." VerticalBottomMargin="2.5" VerticalLeftMargin="2.5" VerticalTopMargin="2.5" VerticalRightMargin="2.5" RightMargin="0." />
          <ap:DefaultTopicLayout TopicLayoutHorizontalAlignment="urn:mindjet:Center" TopicLayoutVerticalAlignment="urn:mindjet:Center" TopicTextAndImagePosition="urn:mindjet:TextRightImageLeft" TopicWidthControl="urn:mindjet:AutoWidth" Dirty="0000000000000000" Width="50." MinimumHeight="5." Padding="1." />
          <ap:DefaultSubTopicsShape SubTopicsAlignment="urn:mindjet:Center" SubTopicsConnectionPoint="urn:mindjet:Center" SubTopicsConnectionStyle="urn:mindjet:Straight" SubTopicsGrowth="urn:mindjet:Horizontal" SubTopicsGrowthDirection="urn:mindjet:LeftAndRight" SubTopicsShape="urn:mindjet:Vertical" SubTopicsShapeWidthFactor="1." SubTopicsVerticalAlignment="urn:mindjet:Middle" SubTopicsVerticalGrowthDirection="urn:mindjet:Down" Dirty="0000000000000000" DistanceFromParent="30." VerticalDistanceFromParent="10." DistanceBetweenSiblings="7." VerticalDistanceBetweenSiblings="1." SubTopicsDepth="1" SubTopicsAlignmentDualVertical="urn:mindjet:Center" SubTopicsTreeConnectionPoint="urn:mindjet:Inside" VerticalSubTopicsConnectionStyle="urn:mindjet:Elbow" VerticalSubTopicsConnectionPoint="urn:mindjet:Outside" VerticalSubTopicsTreeConnectionPoint="urn:mindjet:Inside" />
          <ap:DefaultSubTopicsVisibility Dirty="0000000000000000" Hidden="false" />
        </ap:RootTopicDefaultsGroup>
        <ap:RootSubTopicDefaultsGroup Level="0">
          <ap:DefaultColor Dirty="0000000000000000" FillColor="ffffffff" />
          <ap:DefaultText TextAlignment="urn:mindjet:Left" TextCapitalization="urn:mindjet:None" Dirty="0000000000000000" PlainText="Main Topic" ReadOnly="false">
            <ap:Font Color="ff000000" Size="12." Name="Arial" Bold="false" Italic="false" Underline="false" Strikethrough="false" />
          </ap:DefaultText>
          <ap:DefaultSubTopicShape SubTopicShape="urn:mindjet:RoundedRectangle" Dirty="0000000000000000" LeftMargin="0.5" TopMargin="0.5" BottomMargin="0.5" VerticalBottomMargin="2." VerticalLeftMargin="2." VerticalTopMargin="2." VerticalRightMargin="2." RightMargin="0.5" VerticalSubTopicShape="urn:mindjet:Rectangle" />
          <ap:DefaultTopicLayout Dirty="0000000000000000" Width="66.848358154296875" />
          <ap:DefaultSubTopicsShape SubTopicsAlignment="urn:mindjet:Center" SubTopicsConnectionPoint="urn:mindjet:Outside" SubTopicsConnectionStyle="urn:mindjet:ShearedElbow" SubTopicsGrowth="urn:mindjet:Horizontal" SubTopicsGrowthDirection="urn:mindjet:AutomaticHorizontal" SubTopicsShape="urn:mindjet:Vertical" SubTopicsVerticalAlignment="urn:mindjet:Middle" SubTopicsVerticalGrowthDirection="urn:mindjet:AutomaticVertical" Dirty="0000000000000000" DistanceFromParent="2." VerticalDistanceFromParent="10." DistanceBetweenSiblings="1.3999999761581421" VerticalDistanceBetweenSiblings="1." SubTopicsAlignmentDualVertical="urn:mindjet:Bottom" VerticalSubTopicsConnectionStyle="urn:mindjet:Elbow" VerticalSubTopicsConnectionPoint="urn:mindjet:Outside" />
          <ap:DefaultSubTopicsVisibility Dirty="0000000000000000" Hidden="false" />
        </ap:RootSubTopicDefaultsGroup>
        <ap:RootSubTopicDefaultsGroup Level="1">
          <ap:DefaultColor Dirty="0000000000000000" FillColor="00000000" />
          <ap:DefaultText TextAlignment="urn:mindjet:Left" TextCapitalization="urn:mindjet:None" Dirty="0000000000000000" PlainText="Subtopic" ReadOnly="false">
            <ap:Font Color="ff000000" Size="10." Name="Arial" Bold="false" Italic="false" Underline="false" Strikethrough="false" />
          </ap:DefaultText>
          <ap:DefaultSubTopicShape SubTopicShape="urn:mindjet:Line" Dirty="0000000000000000" LeftMargin="0.20000000298023224" TopMargin="0.20000000298023224" BottomMargin="0.20000000298023224" VerticalBottomMargin="1." VerticalLeftMargin="1." VerticalTopMargin="1." VerticalRightMargin="1." RightMargin="0.20000000298023224" VerticalSubTopicShape="urn:mindjet:Rectangle" />
          <ap:DefaultSubTopicsShape SubTopicsAlignment="urn:mindjet:Center" SubTopicsConnectionPoint="urn:mindjet:Outside" SubTopicsGrowth="urn:mindjet:Horizontal" SubTopicsGrowthDirection="urn:mindjet:AutomaticHorizontal" SubTopicsShape="urn:mindjet:Vertical" Dirty="0000000000000000" VerticalDistanceFromParent="10." DistanceBetweenSiblings="1.3999999761581421" VerticalDistanceBetweenSiblings="1." SubTopicsAlignmentDualVertical="urn:mindjet:Bottom" VerticalSubTopicsConnectionStyle="urn:mindjet:Elbow" VerticalSubTopicsConnectionPoint="urn:mindjet:Outside" />
          <ap:DefaultSubTopicsVisibility Dirty="0000000000000000" Hidden="false" />
        </ap:RootSubTopicDefaultsGroup>
        <ap:CalloutTopicDefaultsGroup>
          <ap:DefaultColor Dirty="0000000000000000" FillColor="ffffff99" LineColor="ff808080" />
          <ap:DefaultText TextAlignment="urn:mindjet:Left" TextCapitalization="urn:mindjet:None" Dirty="0000000000000000" PlainText="Callout" ReadOnly="false">
            <ap:Font Color="ff000000" Size="9." Name="Arial" Bold="true" Italic="false" Underline="false" Strikethrough="false" />
          </ap:DefaultText>
          <ap:DefaultCalloutFloatingTopicShape CalloutFloatingTopicShape="urn:mindjet:RoundedRectangleBalloon" Dirty="0000000000000000" LeftMargin="0.5" TopMargin="0.5" BottomMargin="0.5" RightMargin="0.5" />
          <ap:DefaultSubTopicsShape SubTopicsAlignment="urn:mindjet:Center" SubTopicsConnectionPoint="urn:mindjet:Outside" SubTopicsConnectionStyle="urn:mindjet:ShearedElbow" SubTopicsGrowth="urn:mindjet:Horizontal" SubTopicsGrowthDirection="urn:mindjet:AutomaticHorizontal" SubTopicsShape="urn:mindjet:Vertical" SubTopicsVerticalAlignment="urn:mindjet:Middle" SubTopicsVerticalGrowthDirection="urn:mindjet:AutomaticVertical" Dirty="0000000000000000" DistanceFromParent="2." VerticalDistanceFromParent="10." DistanceBetweenSiblings="1.3999999761581421" VerticalDistanceBetweenSiblings="1." SubTopicsAlignmentDualVertical="urn:mindjet:Center" />
          <ap:DefaultSubTopicsVisibility Dirty="0000000000000000" Hidden="false" />
        </ap:CalloutTopicDefaultsGroup>
        <ap:CalloutSubTopicDefaultsGroup Level="0">
          <ap:DefaultColor Dirty="0000000000000000" FillColor="00000000" LineColor="ff808080" />
          <ap:DefaultText TextAlignment="urn:mindjet:Left" TextCapitalization="urn:mindjet:None" Dirty="0000000000000000" PlainText="Subtopic" ReadOnly="false">
            <ap:Font Color="ff000000" Size="10." Name="Arial" Bold="false" />
          </ap:DefaultText>
          <ap:DefaultSubTopicShape SubTopicShape="urn:mindjet:Line" Dirty="0000000000000000" LeftMargin="0.20000000298023224" TopMargin="0.20000000298023224" BottomMargin="0.20000000298023224" RightMargin="0.20000000298023224" />
          <ap:DefaultSubTopicsShape SubTopicsAlignment="urn:mindjet:Center" SubTopicsConnectionPoint="urn:mindjet:Outside" SubTopicsGrowth="urn:mindjet:Horizontal" SubTopicsGrowthDirection="urn:mindjet:AutomaticHorizontal" SubTopicsShape="urn:mindjet:Vertical" SubTopicsVerticalAlignment="urn:mindjet:Middle" SubTopicsVerticalGrowthDirection="urn:mindjet:AutomaticVertical" Dirty="0000000000000000" VerticalDistanceFromParent="10." DistanceBetweenSiblings="1.3999999761581421" VerticalDistanceBetweenSiblings="1." SubTopicsAlignmentDualVertical="urn:mindjet:Center" />
          <ap:DefaultSubTopicsVisibility Dirty="0000000000000000" Hidden="false" />
        </ap:CalloutSubTopicDefaultsGroup>
        <ap:LabelTopicDefaultsGroup>
          <ap:DefaultColor Dirty="0000000000000000" FillColor="ffffffff" LineColor="ff808080" />
          <ap:DefaultText TextAlignment="urn:mindjet:Left" TextCapitalization="urn:mindjet:None" Dirty="0000000000000000" PlainText="Floating Topic" ReadOnly="false">
            <ap:Font Color="ff000000" Size="12." Name="Arial" Bold="false" />
          </ap:DefaultText>
          <ap:DefaultLabelFloatingTopicShape LabelFloatingTopicShape="urn:mindjet:RoundedRectangle" Dirty="0000000000000000" LeftMargin="0.69999998807907104" TopMargin="0.69999998807907104" BottomMargin="0.69999998807907104" VerticalBottomMargin="2.5" VerticalLeftMargin="2.5" VerticalTopMargin="2.5" VerticalRightMargin="2.5" RightMargin="0.69999998807907104" VerticalLabelFloatingTopicShape="urn:mindjet:RoundedRectangle" />
          <ap:DefaultSubTopicsShape SubTopicsAlignment="urn:mindjet:Center" SubTopicsConnectionPoint="urn:mindjet:Outside" SubTopicsConnectionStyle="urn:mindjet:ShearedElbow" SubTopicsGrowth="urn:mindjet:Horizontal" SubTopicsGrowthDirection="urn:mindjet:AutomaticHorizontal" SubTopicsShape="urn:mindjet:Vertical" SubTopicsVerticalAlignment="urn:mindjet:Middle" SubTopicsVerticalGrowthDirection="urn:mindjet:AutomaticVertical" Dirty="0000000000000000" DistanceFromParent="2." VerticalDistanceFromParent="10." DistanceBetweenSiblings="1.3999999761581421" VerticalDistanceBetweenSiblings="1.3999999761581421" SubTopicsDepth="1" SubTopicsAlignmentDualVertical="urn:mindjet:Center" VerticalSubTopicsConnectionStyle="urn:mindjet:Elbow" VerticalSubTopicsConnectionPoint="urn:mindjet:Outside" />
          <ap:DefaultSubTopicsVisibility Dirty="0000000000000000" Hidden="false" />
        </ap:LabelTopicDefaultsGroup>
        <ap:LabelSubTopicDefaultsGroup Level="0">
          <ap:DefaultColor Dirty="0000000000000000" FillColor="00000000" LineColor="ff808080" />
          <ap:DefaultText TextAlignment="urn:mindjet:Left" TextCapitalization="urn:mindjet:None" Dirty="0000000000000000" PlainText="Subtopic" ReadOnly="false">
            <ap:Font Color="ff000000" Size="10." Name="Arial" Bold="false" />
          </ap:DefaultText>
          <ap:DefaultSubTopicShape SubTopicShape="urn:mindjet:Line" Dirty="0000000000000000" LeftMargin="0.20000000298023224" TopMargin="0.20000000298023224" BottomMargin="0.20000000298023224" VerticalBottomMargin="2." VerticalLeftMargin="2." VerticalTopMargin="2." VerticalRightMargin="2." RightMargin="0.20000000298023224" VerticalSubTopicShape="urn:mindjet:Rectangle" />
          <ap:DefaultSubTopicsShape SubTopicsAlignment="urn:mindjet:Center" SubTopicsConnectionPoint="urn:mindjet:Outside" SubTopicsGrowth="urn:mindjet:Horizontal" SubTopicsGrowthDirection="urn:mindjet:AutomaticHorizontal" SubTopicsShape="urn:mindjet:Vertical" SubTopicsVerticalAlignment="urn:mindjet:Middle" SubTopicsVerticalGrowthDirection="urn:mindjet:AutomaticVertical" Dirty="0000000000000000" VerticalDistanceFromParent="10." DistanceBetweenSiblings="1.3999999761581421" VerticalDistanceBetweenSiblings="1.3999999761581421" SubTopicsAlignmentDualVertical="urn:mindjet:Bottom" VerticalSubTopicsConnectionStyle="urn:mindjet:Elbow" />
          <ap:DefaultSubTopicsVisibility Dirty="0000000000000000" Hidden="false" />
        </ap:LabelSubTopicDefaultsGroup>
        <ap:OrgChartTopicDefaultsGroup>
          <ap:DefaultColor Dirty="0000000000000000" FillColor="ffffffff" />
          <ap:DefaultText TextAlignment="urn:mindjet:Center" TextCapitalization="urn:mindjet:None" VerticalTextAlignment="urn:mindjet:Top" Dirty="0000000000000000" PlainText="Org-Chart Topic" ReadOnly="false">
            <ap:Font Color="ff000000" Size="12." Name="Arial" Bold="false" Italic="false" Underline="false" Strikethrough="false" />
          </ap:DefaultText>
          <ap:DefaultSubTopicShape Dirty="0000000000000000" VerticalBottomMargin="2.5" VerticalLeftMargin="2.5" VerticalTopMargin="2.5" VerticalRightMargin="2.5" VerticalSubTopicShape="urn:mindjet:RoundedRectangle" />
          <ap:DefaultLabelFloatingTopicShape Dirty="0000000000000000" VerticalLabelFloatingTopicShape="urn:mindjet:RoundedRectangle" />
          <ap:DefaultCalloutFloatingTopicShape Dirty="0000000000000000" VerticalCalloutFloatingTopicShape="urn:mindjet:RoundedRectangleBalloon" VerticalBottomMargin="2.5" VerticalLeftMargin="2.5" VerticalTopMargin="2.5" VerticalRightMargin="2.5" />
          <ap:DefaultTopicLayout TopicLayoutHorizontalAlignment="urn:mindjet:Center" TopicLayoutVerticalAlignment="urn:mindjet:Center" TopicTextAndImagePosition="urn:mindjet:TextRightImageLeft" TopicWidthControl="urn:mindjet:AutoWidth" Dirty="0000000000000000" Width="50." MinimumHeight="5." Padding="1." />
          <ap:DefaultSubTopicsShape SubTopicsAlignment="urn:mindjet:Center" SubTopicsGrowth="urn:mindjet:Vertical" SubTopicsGrowthDirection="urn:mindjet:AutomaticHorizontal" SubTopicsShape="urn:mindjet:Vertical" SubTopicsShapeWidthFactor="1." SubTopicsVerticalAlignment="urn:mindjet:Middle" SubTopicsVerticalGrowthDirection="urn:mindjet:AutomaticVertical" Dirty="0000000000000000" DistanceFromParent="5." VerticalDistanceFromParent="10." DistanceBetweenSiblings="1." VerticalDistanceBetweenSiblings="1.3999999761581421" SubTopicsDepth="1" SubTopicsAlignmentDualVertical="urn:mindjet:Center" VerticalSubTopicsConnectionStyle="urn:mindjet:Elbow" VerticalSubTopicsConnectionPoint="urn:mindjet:Outside" />
          <ap:DefaultSubTopicsVisibility Dirty="0000000000000000" Hidden="false" />
        </ap:OrgChartTopicDefaultsGroup>
        <ap:OrgChartSubTopicDefaultsGroup Level="0">
          <ap:DefaultColor Dirty="0000000000000000" FillColor="00000000" />
          <ap:DefaultText TextAlignment="urn:mindjet:Center" TextCapitalization="urn:mindjet:None" VerticalTextAlignment="urn:mindjet:Top" Dirty="0000000000000000" PlainText="Topic" ReadOnly="false">
            <ap:Font Color="ff000000" Size="10." Name="Arial" Bold="false" Italic="false" Underline="false" Strikethrough="false" />
          </ap:DefaultText>
          <ap:DefaultSubTopicShape Dirty="0000000000000000" VerticalBottomMargin="2." VerticalLeftMargin="2." VerticalTopMargin="2." VerticalRightMargin="2." VerticalSubTopicShape="urn:mindjet:Rectangle" />
          <ap:DefaultCalloutFloatingTopicShape Dirty="0000000000000000" VerticalCalloutFloatingTopicShape="urn:mindjet:RectangleBalloon" VerticalBottomMargin="2." VerticalLeftMargin="2." VerticalTopMargin="2." VerticalRightMargin="2." />
          <ap:DefaultTopicLayout TopicLayoutHorizontalAlignment="urn:mindjet:Center" TopicLayoutVerticalAlignment="urn:mindjet:Center" TopicTextAndImagePosition="urn:mindjet:TextRightImageLeft" TopicWidthControl="urn:mindjet:AutoWidth" Dirty="0000000000000000" Width="50." MinimumHeight="5." Padding="1." />
          <ap:DefaultSubTopicsShape SubTopicsAlignment="urn:mindjet:Bottom" SubTopicsConnectionPoint="urn:mindjet:Outside" SubTopicsConnectionStyle="urn:mindjet:Elbow" SubTopicsGrowth="urn:mindjet:Horizontal" SubTopicsGrowthDirection="urn:mindjet:AutomaticHorizontal" SubTopicsShape="urn:mindjet:Vertical" SubTopicsShapeWidthFactor="1." SubTopicsVerticalAlignment="urn:mindjet:Middle" SubTopicsVerticalGrowthDirection="urn:mindjet:AutomaticVertical" Dirty="0000000000000000" DistanceFromParent="5." VerticalDistanceFromParent="10." DistanceBetweenSiblings="1.3999999761581421" VerticalDistanceBetweenSiblings="1." SubTopicsDepth="1" SubTopicsAlignmentDualVertical="urn:mindjet:Center" VerticalSubTopicsConnectionStyle="urn:mindjet:Elbow" VerticalSubTopicsConnectionPoint="urn:mindjet:Outside" />
          <ap:DefaultSubTopicsVisibility Dirty="0000000000000000" Hidden="false" />
        </ap:OrgChartSubTopicDefaultsGroup>
        <ap:OrgChartSubTopicDefaultsGroup Level="1">
          <ap:DefaultColor Dirty="0000000000000000" FillColor="00000000" />
          <ap:DefaultText TextAlignment="urn:mindjet:Center" TextCapitalization="urn:mindjet:None" VerticalTextAlignment="urn:mindjet:Top" Dirty="0000000000000000" PlainText="Topic" ReadOnly="false">
            <ap:Font Color="ff000000" Size="10." Name="Arial" Bold="false" Italic="false" Underline="false" Strikethrough="false" />
          </ap:DefaultText>
          <ap:DefaultSubTopicShape SubTopicShape="urn:mindjet:Rectangle" Dirty="0000000000000000" VerticalBottomMargin="2." VerticalLeftMargin="2." VerticalTopMargin="2." VerticalRightMargin="2." VerticalSubTopicShape="urn:mindjet:Rectangle" />
          <ap:DefaultCalloutFloatingTopicShape Dirty="0000000000000000" VerticalCalloutFloatingTopicShape="urn:mindjet:RectangleBalloon" VerticalBottomMargin="2." VerticalLeftMargin="2." VerticalTopMargin="2." VerticalRightMargin="2." />
          <ap:DefaultTopicLayout TopicLayoutHorizontalAlignment="urn:mindjet:Center" TopicLayoutVerticalAlignment="urn:mindjet:Center" TopicTextAndImagePosition="urn:mindjet:TextRightImageLeft" TopicWidthControl="urn:mindjet:AutoWidth" Dirty="0000000000000000" Width="50." MinimumHeight="5." Padding="1." />
          <ap:DefaultSubTopicsShape SubTopicsAlignment="urn:mindjet:Bottom" SubTopicsConnectionPoint="urn:mindjet:Outside" SubTopicsConnectionStyle="urn:mindjet:Elbow" SubTopicsGrowth="urn:mindjet:Horizontal" SubTopicsGrowthDirection="urn:mindjet:AutomaticHorizontal" SubTopicsShape="urn:mindjet:Vertical" SubTopicsShapeWidthFactor="1." SubTopicsVerticalAlignment="urn:mindjet:Middle" SubTopicsVerticalGrowthDirection="urn:mindjet:AutomaticVertical" Dirty="0000000000000000" DistanceFromParent="5." VerticalDistanceFromParent="10." DistanceBetweenSiblings="1.3999999761581421" VerticalDistanceBetweenSiblings="1." SubTopicsDepth="1" SubTopicsAlignmentDualVertical="urn:mindjet:Center" VerticalSubTopicsConnectionStyle="urn:mindjet:Elbow" VerticalSubTopicsConnectionPoint="urn:mindjet:Outside" />
        </ap:OrgChartSubTopicDefaultsGroup>
        <ap:RelationshipDefaultsGroup>
          <ap:DefaultColor Dirty="0000000000000000" FillColor="00000000" LineColor="ff0068cf" />
          <ap:DefaultLineStyle LineDashStyle="urn:mindjet:RoundDot" Dirty="0000000000000000" LineWidth="2.25" />
          <ap:DefaultConnectionStyle ConnectionShape="urn:mindjet:OvalArrow" Dirty="0000000000000000" />
          <ap:DefaultConnectionStyle ConnectionShape="urn:mindjet:OpenArrow" Dirty="0000000000000000" />
          <ap:DefaultRelationshipLineShape LineShape="urn:mindjet:Bezier" Dirty="0000000000000000" />
        </ap:RelationshipDefaultsGroup>
        <ap:BoundaryDefaultsGroup>
          <ap:DefaultLineStyle LineDashStyle="urn:mindjet:LongDash" Dirty="0000000000000000" LineWidth="1." />
          <ap:DefaultBoundaryShape BoundaryShape="urn:mindjet:CurvedLine" Dirty="0000000000000000" Margin="0." />
        </ap:BoundaryDefaultsGroup>
        <ap:ImageDefaultsGroup />
        <ap:Structure StructureGrowthDirection="urn:mindjet:Automatic" Dirty="0000000000000000" UseAutoLayout="true" MinimumMainTopicsHeight="40." FadeNotSelectedObjects="true" UseCurveAntialiasing="true" UseTextAntialiasing="true" MainTopicLineWidth="0.10000000149011612" VerticalMainTopicLineWidth="0.10000000149011612" SiblingSpacing="0." ParentChildSpacing="0." UseOrganicLines="false" HideCollapseSign="false" />
        <ap:BackgroundImageData ImageTileOption="urn:mindjet:NoFlip" ImageType="urn:mindjet:PngImage" Transparency="16" Dirty="0000000000000000">
          <cor:Uri xsi:nil="false">mmarch://bin/B7E49899-8FA5-4C17-801C-3A2E2A90CF7B.bin</cor:Uri>
        </ap:BackgroundImageData>
        <ap:NotesDefaultFont Color="ff000000" Size="10." Dirty="0000000000000000" Name="Arial" />
      </ap:StyleGroup>
      <ap:MapViewGroup ViewIndex="0" RowIndex="0" ColumnIndex="0">
        <ap:ZoomFactor ZoomFactor="1." Dirty="0000000000000000" />
        <ap:ScrollPosition Dirty="0000000000000001" CX="6.999969482421875e-002" CY="0.138519287109375" />
      </ap:MapViewGroup>
      <ap:DocumentGroup>
        <ap:Language Dirty="0000000000000000" Language="zh-sim" />
        <ap:Creator Dirty="0000000000000000" UserName="" UserEmail="" />
        <ap:LastModificator Dirty="0000000000000000" UserName="" UserEmail="" />
        <ap:Author Dirty="0000000000000000" UserName="" UserEmail="" />
        <ap:Manager Dirty="0000000000000000" UserName="" />
        <ap:Version Dirty="0000000000000001" Major="2" />
        <ap:Statistics Dirty="0000000000000001" NumberOfTopics="17" NumberOfWords="17" NumberOfHyperlinks="0" NumberOfRelationships="0" NumberOfPictures="0" NumberOfBoundaries="0" NumberOfNotes="1" />
        <ap:DateTimeStamps Dirty="0000000000000001" Created="2010-06-07T09:06:58" LastModified="2010-06-07T13:15:34" />
        <ap:Description Comments="The Mindjet MindManager 6 default map template." Dirty="0000000000000000" Subject="" />
        <ap:Keywords Dirty="0000000000000000" Keywords="" />
        <ap:CreatorCompany Dirty="0000000000000000" Name="" />
        <ap:Category Dirty="0000000000000000" Name="" />
        <ap:ModifiedProtected Dirty="0000000000000000" Password="" />
        <ap:PreviewImageData ImageType="urn:mindjet:PngImage" Dirty="0000000000000001" CustomImageType="">
          <cor:Uri xsi:nil="false">mmarch://Preview.png</cor:Uri>
        </ap:PreviewImageData>
        <ap:DocumentPath Dirty="0000000000000001" DocumentPath="\\PC-200912051530\C\Documents and Settings\Administrator\桌面\~$动物.mmap.~$save" />
      </ap:DocumentGroup>
      <ap:MarkersSetGroup>
        <ap:IconMarkersSets>
          <ap:IconMarkersSet Dirty="0000000000000000" OId="h8z9SYT/kkSNEIGZRsVp0w==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Smileys" />
            <ap:IconMarkers>
              <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="Ns8hHJglZEiIzXRKYGuR9A==" Gen="0000000000000000">
                <ap:Name Dirty="0000000000000000" Name="Happy" />
                <ap:OneStockIcon IconType="urn:mindjet:SmileyHappy" Dirty="0000000000000000" />
              </ap:IconMarker>
              <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="OmmbWotjhkKkPefH8dGU5Q==" Gen="0000000000000000">
                <ap:Name Dirty="0000000000000000" Name="Neutral" />
                <ap:OneStockIcon IconType="urn:mindjet:SmileyNeutral" Dirty="0000000000000000" />
              </ap:IconMarker>
              <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="CDOvN1NbM0SOfXXImwkawA==" Gen="0000000000000000">
                <ap:Name Dirty="0000000000000000" Name="Upset" />
                <ap:OneStockIcon IconType="urn:mindjet:SmileyAngry" Dirty="0000000000000000" />
              </ap:IconMarker>
              <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="D+Q3ifiIQU2ApIbG+05zjw==" Gen="0000000000000000">
                <ap:Name Dirty="0000000000000000" Name="Sad" />
                <ap:OneStockIcon IconType="urn:mindjet:SmileySad" Dirty="0000000000000000" />
              </ap:IconMarker>
              <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="rhWzNwdDd0e3aL2Pzkpr9Q==" Gen="0000000000000000">
                <ap:Name Dirty="0000000000000000" Name="Furious" />
                <ap:OneStockIcon IconType="urn:mindjet:SmileyScreaming" Dirty="0000000000000000" />
              </ap:IconMarker>
            </ap:IconMarkers>
          </ap:IconMarkersSet>
          <ap:IconMarkersSet Dirty="0000000000000000" OId="+8LjQpO2D0absqeypKOywQ==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Arrows" />
            <ap:IconMarkers>
              <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="MgjgvIw+h0i/VB2AxoFn2g==" Gen="0000000000000000">
                <ap:Name Dirty="0000000000000000" Name="Yes!" />
                <ap:OneStockIcon IconType="urn:mindjet:ArrowUp" Dirty="0000000000000000" />
              </ap:IconMarker>
              <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="Mtn5hMFCNUq2JOcCkujnuQ==" Gen="0000000000000000">
                <ap:Name Dirty="0000000000000000" Name="Important" />
                <ap:OneStockIcon IconType="urn:mindjet:ArrowRight" Dirty="0000000000000000" />
              </ap:IconMarker>
              <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="Pfi+NdBUhkqXMWfxCqLfmA==" Gen="0000000000000000">
                <ap:Name Dirty="0000000000000000" Name="Both ways" />
                <ap:OneStockIcon IconType="urn:mindjet:TwoEndArrow" Dirty="0000000000000000" />
              </ap:IconMarker>
              <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="N+Z22w8OFki0yaCUWpajVQ==" Gen="0000000000000000">
                <ap:Name Dirty="0000000000000000" Name="Reference" />
                <ap:OneStockIcon IconType="urn:mindjet:ArrowLeft" Dirty="0000000000000000" />
              </ap:IconMarker>
              <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="0zV5CCA7UUuuawDv99Hu7g==" Gen="0000000000000000">
                <ap:Name Dirty="0000000000000000" Name="Postponed" />
                <ap:OneStockIcon IconType="urn:mindjet:ArrowDown" Dirty="0000000000000000" />
              </ap:IconMarker>
            </ap:IconMarkers>
          </ap:IconMarkersSet>
          <ap:IconMarkersSet Dirty="0000000000000000" OId="3EXziK8jpEmvMBQrFQqmrg==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Flags" />
            <ap:IconMarkers>
              <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="tuj20mpWCkiBB5Hl3Es+dQ==" Gen="0000000000000000">
                <ap:Name Dirty="0000000000000000" Name="Go" />
                <ap:OneStockIcon IconType="urn:mindjet:FlagGreen" Dirty="0000000000000000" />
              </ap:IconMarker>
              <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="U7SpEowzrk2sYISKbR4DyA==" Gen="0000000000000000">
                <ap:Name Dirty="0000000000000000" Name="For discussion" />
                <ap:OneStockIcon IconType="urn:mindjet:FlagYellow" Dirty="0000000000000000" />
              </ap:IconMarker>
              <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="W2+aye54OEuwKDrXBatgNQ==" Gen="0000000000000000">
                <ap:Name Dirty="0000000000000000" Name="Possibility" />
                <ap:OneStockIcon IconType="urn:mindjet:FlagPurple" Dirty="0000000000000000" />
              </ap:IconMarker>
              <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="gvO262o3qk2iIF6rVZdWEA==" Gen="0000000000000000">
                <ap:Name Dirty="0000000000000000" Name="Progress" />
                <ap:OneStockIcon IconType="urn:mindjet:FlagBlue" Dirty="0000000000000000" />
              </ap:IconMarker>
              <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="s4v8UbexNEGvocisSiMtZg==" Gen="0000000000000000">
                <ap:Name Dirty="0000000000000000" Name="Careful" />
                <ap:OneStockIcon IconType="urn:mindjet:FlagOrange" Dirty="0000000000000000" />
              </ap:IconMarker>
              <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="qz7PYlMhaEabb0nVg0vg/A==" Gen="0000000000000000">
                <ap:Name Dirty="0000000000000000" Name="Caution" />
                <ap:OneStockIcon IconType="urn:mindjet:FlagRed" Dirty="0000000000000000" />
              </ap:IconMarker>
              <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="nP5XFp3qX0K46hMiHP0Wpw==" Gen="0000000000000000">
                <ap:Name Dirty="0000000000000000" Name="Risk" />
                <ap:OneStockIcon IconType="urn:mindjet:FlagBlack" Dirty="0000000000000000" />
              </ap:IconMarker>
            </ap:IconMarkers>
          </ap:IconMarkersSet>
        </ap:IconMarkersSets>
        <ap:IconMarkers>
          <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="NzVm2eD96E6x3jVfQGfn8g==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Great idea" />
            <ap:OneStockIcon IconType="urn:mindjet:ThumbsUp" Dirty="0000000000000000" />
          </ap:IconMarker>
          <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="56H5q/cB/kKKlyRXi9I1Qw==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Decision" />
            <ap:OneStockIcon IconType="urn:mindjet:JudgeHammer" Dirty="0000000000000000" />
          </ap:IconMarker>
          <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="7aCygJF6ME2nwnDz8qHcjg==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Date" />
            <ap:OneStockIcon IconType="urn:mindjet:Calendar" Dirty="0000000000000000" />
          </ap:IconMarker>
          <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="wyFkey0PAUyAknVfZH2hLA==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Budget" />
            <ap:OneStockIcon IconType="urn:mindjet:Dollar" Dirty="0000000000000000" />
          </ap:IconMarker>
          <ap:IconMarker xsi:type="ap:StockIconMarker" Dirty="0000000000000000" OId="NtVP9Y8nKky0Fj5cjz/9aA==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Emergency" />
            <ap:OneStockIcon IconType="urn:mindjet:Emergency" Dirty="0000000000000000" />
          </ap:IconMarker>
        </ap:IconMarkers>
        <ap:FillColorMarkersName Dirty="0000000000000000" Name="Fill Colors" />
        <ap:TextColorMarkersName Dirty="0000000000000000" Name="Font Colors" />
        <ap:TaskPercentageMarkersName Dirty="0000000000000000" Name="Task Complete (%)" />
        <ap:TaskPercentageMarkers>
          <ap:TaskPercentageMarker Dirty="0000000000000000" OId="nbfCpxvaGky8lj7X2aVsug==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Task start" />
            <ap:TaskPercentage TaskPercentage="0" Dirty="0000000000000000" />
          </ap:TaskPercentageMarker>
          <ap:TaskPercentageMarker Dirty="0000000000000000" OId="C5aVq6OEX0GmORmNCafLmQ==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Quarter done" />
            <ap:TaskPercentage TaskPercentage="25" Dirty="0000000000000000" />
          </ap:TaskPercentageMarker>
          <ap:TaskPercentageMarker Dirty="0000000000000000" OId="+AcNkl3bB0CIHFuJLlPIIA==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Half done" />
            <ap:TaskPercentage TaskPercentage="50" Dirty="0000000000000000" />
          </ap:TaskPercentageMarker>
          <ap:TaskPercentageMarker Dirty="0000000000000000" OId="JGMkjnkNXUSqWZT9fREFcQ==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Three quarters done" />
            <ap:TaskPercentage TaskPercentage="75" Dirty="0000000000000000" />
          </ap:TaskPercentageMarker>
          <ap:TaskPercentageMarker Dirty="0000000000000000" OId="Ze4N5bpD30OZ4sOzIFuGjA==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Task done" />
            <ap:TaskPercentage TaskPercentage="100" Dirty="0000000000000000" />
          </ap:TaskPercentageMarker>
        </ap:TaskPercentageMarkers>
        <ap:TaskPriorityMarkersName Dirty="0000000000000000" Name="Task Priorities" />
        <ap:TaskPriorityMarkers>
          <ap:TaskPriorityMarker Dirty="0000000000000000" OId="Dc8yVMjWz0aU+szVnMKV9w==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Priority 1" />
            <ap:TaskPriority TaskPriority="urn:mindjet:Prio1" Dirty="0000000000000000" />
          </ap:TaskPriorityMarker>
          <ap:TaskPriorityMarker Dirty="0000000000000000" OId="ih34gEC50UKI+EKZ4RIxvA==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Priority 2" />
            <ap:TaskPriority TaskPriority="urn:mindjet:Prio2" Dirty="0000000000000000" />
          </ap:TaskPriorityMarker>
          <ap:TaskPriorityMarker Dirty="0000000000000000" OId="YFt+J/HXF0Gq/gsPaAJXLQ==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Priority 3" />
            <ap:TaskPriority TaskPriority="urn:mindjet:Prio3" Dirty="0000000000000000" />
          </ap:TaskPriorityMarker>
          <ap:TaskPriorityMarker Dirty="0000000000000000" OId="Fv2dZ+UBy0ehtdPIIB7x/w==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Priority 4" />
            <ap:TaskPriority TaskPriority="urn:mindjet:Prio4" Dirty="0000000000000000" />
          </ap:TaskPriorityMarker>
          <ap:TaskPriorityMarker Dirty="0000000000000000" OId="iZJFLr5tsUqHZ5gfkuBf8Q==" Gen="0000000000000000">
            <ap:Name Dirty="0000000000000000" Name="Priority 5" />
            <ap:TaskPriority TaskPriority="urn:mindjet:Prio5" Dirty="0000000000000000" />
          </ap:TaskPriorityMarker>
        </ap:TaskPriorityMarkers>
      </ap:MarkersSetGroup>
    </ap:Map>
  </xsl:template>

  <xsl:template name="topic1">
    <xsl:for-each select="N">
      <ap:Topic Dirty="0000000000000001" Gen="0000000000000000" >
        <xsl:attribute name="OId">
          <xsl:value-of select="@id"></xsl:value-of>
        </xsl:attribute>
        <ap:SubTopics>
          <xsl:call-template name="topic1"></xsl:call-template>
        </ap:SubTopics>
        <xsl:if test="@i">
          <ap:OneImage>
            <ap:Image Dirty="0000000000000001" OId="S+UnYwBZ+0SuTNFRN3Ey5A==" Gen="0000000000000000">
              <ap:ImageData ImageType="urn:mindjet:PngImage" Dirty="0000000000000001" CustomImageType="">
                <cor:Uri xsi:nil="false">
                  <xsl:value-of select="@i"></xsl:value-of>
                </cor:Uri>
              </ap:ImageData>
              <ap:ImageSize Dirty="0000000000000001" >
                <xsl:attribute name="Width">
                  <xsl:value-of select="@iw"></xsl:value-of>
                </xsl:attribute>
                <xsl:attribute name="Height">
                  <xsl:value-of select="@ih"></xsl:value-of>
                </xsl:attribute>
              </ap:ImageSize>
            </ap:Image>
          </ap:OneImage>
        </xsl:if>
        <ap:TopicViewGroup ViewIndex="0"/>
        <ap:Text Dirty="0000000000000001" >
          <xsl:attribute name="ReadOnly">false</xsl:attribute>
          <xsl:attribute name="PlainText">
            <xsl:value-of select="@t"></xsl:value-of>
          </xsl:attribute>
          <ap:Font/>
        </ap:Text>
      </ap:Topic>
    </xsl:for-each>
  </xsl:template>


</xsl:stylesheet>
