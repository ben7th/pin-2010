<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:sl="http://schemas.microsoft.com/schemaLibrary/2003/core" xmlns:aml="http://schemas.microsoft.com/aml/2001/core" xmlns:wx="http://schemas.microsoft.com/office/word/2003/auxHint" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882" xmlns:wsp="http://schemas.microsoft.com/office/word/2003/wordml/sp2" xmlns="http://www.w3.org/1999/xhtml" >
  <xsl:output encoding="UTF-8" indent="no" standalone="yes"/>

  <xsl:template match="mindmap">
    <xsl:processing-instruction name="mso-application">progid="Word.Document"</xsl:processing-instruction>
    <w:wordDocument xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:sl="http://schemas.microsoft.com/schemaLibrary/2003/core" xmlns:aml="http://schemas.microsoft.com/aml/2001/core" xmlns:wx="http://schemas.microsoft.com/office/word/2003/auxHint" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882" xmlns:wsp="http://schemas.microsoft.com/office/word/2003/wordml/sp2" w:macrosPresent="no" w:embeddedObjPresent="no" w:ocxPresent="no" xml:space="preserve">
      <w:ignoreElements w:val="http://schemas.microsoft.com/office/word/2003/wordml/sp2"/>
      
      <w:styles>
        <w:style w:type="paragraph" w:default="on" w:styleId="a">
          <w:name w:val="Normal"/>
          <wx:uiName wx:val="正文"/>
          <w:pPr>
            <w:widowControl w:val="off"/>
            <w:jc w:val="both"/>
          </w:pPr>
          <w:rPr>
            <wx:font wx:val="Times New Roman"/>
            <w:kern w:val="2"/>
            <w:sz w:val="21"/>
            <w:sz-cs w:val="24"/>
            <w:lang w:val="EN-US" w:fareast="ZH-CN" w:bidi="AR-SA"/>
          </w:rPr>
        </w:style>
        <w:style w:type="paragraph" w:styleId="1">
          <w:name w:val="heading 1"/>
          <wx:uiName wx:val="标题 1"/>
          <w:basedOn w:val="a"/>
          <w:next w:val="a"/>
          <w:rsid w:val="003C0AE3"/>
          <w:pPr>
            <w:pStyle w:val="1"/>
            <w:keepNext/>
            <w:keepLines/>
            <w:spacing w:before="340" w:after="330" w:line="578" w:line-rule="auto"/>
            <w:outlineLvl w:val="0"/>
          </w:pPr>
          <w:rPr>
            <wx:font wx:val="Times New Roman"/>
            <w:b/>
            <w:b-cs/>
            <w:kern w:val="44"/>
            <w:sz w:val="44"/>
            <w:sz-cs w:val="44"/>
          </w:rPr>
        </w:style>
        <w:style w:type="paragraph" w:styleId="2">
          <w:name w:val="heading 2"/>
          <wx:uiName wx:val="标题 2"/>
          <w:basedOn w:val="a"/>
          <w:next w:val="a"/>
          <w:rsid w:val="003C0AE3"/>
          <w:pPr>
            <w:pStyle w:val="2"/>
            <w:keepNext/>
            <w:keepLines/>
            <w:spacing w:before="260" w:after="260" w:line="416" w:line-rule="auto"/>
            <w:outlineLvl w:val="1"/>
          </w:pPr>
          <w:rPr>
            <w:rFonts w:ascii="Arial" w:fareast="黑体" w:h-ansi="Arial"/>
            <wx:font wx:val="Arial"/>
            <w:b/>
            <w:b-cs/>
            <w:sz w:val="32"/>
            <w:sz-cs w:val="32"/>
          </w:rPr>
        </w:style>
        <w:style w:type="paragraph" w:styleId="3">
          <w:name w:val="heading 3"/>
          <wx:uiName wx:val="标题 3"/>
          <w:basedOn w:val="a"/>
          <w:next w:val="a"/>
          <w:rsid w:val="003C0AE3"/>
          <w:pPr>
            <w:pStyle w:val="3"/>
            <w:keepNext/>
            <w:keepLines/>
            <w:spacing w:before="260" w:after="260" w:line="416" w:line-rule="auto"/>
            <w:outlineLvl w:val="2"/>
          </w:pPr>
          <w:rPr>
            <wx:font wx:val="Times New Roman"/>
            <w:b/>
            <w:b-cs/>
            <w:sz w:val="32"/>
            <w:sz-cs w:val="32"/>
          </w:rPr>
        </w:style>
        <w:style w:type="paragraph" w:styleId="4">
          <w:name w:val="heading 4"/>
          <wx:uiName wx:val="标题 4"/>
          <w:basedOn w:val="a"/>
          <w:next w:val="a"/>
          <w:rsid w:val="003C0AE3"/>
          <w:pPr>
            <w:pStyle w:val="4"/>
            <w:keepNext/>
            <w:keepLines/>
            <w:spacing w:before="280" w:after="290" w:line="376" w:line-rule="auto"/>
            <w:outlineLvl w:val="3"/>
          </w:pPr>
          <w:rPr>
            <w:rFonts w:ascii="Arial" w:fareast="黑体" w:h-ansi="Arial"/>
            <wx:font wx:val="Arial"/>
            <w:b/>
            <w:b-cs/>
            <w:sz w:val="28"/>
            <w:sz-cs w:val="28"/>
          </w:rPr>
        </w:style>
        <w:style w:type="paragraph" w:styleId="5">
          <w:name w:val="heading 5"/>
          <wx:uiName wx:val="标题 5"/>
          <w:basedOn w:val="a"/>
          <w:next w:val="a"/>
          <w:rsid w:val="003C0AE3"/>
          <w:pPr>
            <w:pStyle w:val="5"/>
            <w:keepNext/>
            <w:keepLines/>
            <w:spacing w:before="280" w:after="290" w:line="376" w:line-rule="auto"/>
            <w:outlineLvl w:val="4"/>
          </w:pPr>
          <w:rPr>
            <wx:font wx:val="Times New Roman"/>
            <w:b/>
            <w:b-cs/>
            <w:sz w:val="28"/>
            <w:sz-cs w:val="28"/>
          </w:rPr>
        </w:style>
        <w:style w:type="paragraph" w:styleId="6">
          <w:name w:val="heading 6"/>
          <wx:uiName wx:val="标题 6"/>
          <w:basedOn w:val="a"/>
          <w:next w:val="a"/>
          <w:rsid w:val="003C0AE3"/>
          <w:pPr>
            <w:pStyle w:val="6"/>
            <w:keepNext/>
            <w:keepLines/>
            <w:spacing w:before="240" w:after="64" w:line="320" w:line-rule="auto"/>
            <w:outlineLvl w:val="5"/>
          </w:pPr>
          <w:rPr>
            <w:rFonts w:ascii="Arial" w:fareast="黑体" w:h-ansi="Arial"/>
            <wx:font wx:val="Arial"/>
            <w:b/>
            <w:b-cs/>
            <w:sz w:val="24"/>
          </w:rPr>
        </w:style>
        <w:style w:type="paragraph" w:styleId="7">
          <w:name w:val="heading 7"/>
          <wx:uiName wx:val="标题 7"/>
          <w:basedOn w:val="a"/>
          <w:next w:val="a"/>
          <w:rsid w:val="003C0AE3"/>
          <w:pPr>
            <w:pStyle w:val="7"/>
            <w:keepNext/>
            <w:keepLines/>
            <w:spacing w:before="240" w:after="64" w:line="320" w:line-rule="auto"/>
            <w:outlineLvl w:val="6"/>
          </w:pPr>
          <w:rPr>
            <wx:font wx:val="Times New Roman"/>
            <w:b/>
            <w:b-cs/>
            <w:sz w:val="24"/>
          </w:rPr>
        </w:style>
        <w:style w:type="paragraph" w:styleId="8">
          <w:name w:val="heading 8"/>
          <wx:uiName wx:val="标题 8"/>
          <w:basedOn w:val="a"/>
          <w:next w:val="a"/>
          <w:rsid w:val="003C0AE3"/>
          <w:pPr>
            <w:pStyle w:val="8"/>
            <w:keepNext/>
            <w:keepLines/>
            <w:spacing w:before="240" w:after="64" w:line="320" w:line-rule="auto"/>
            <w:outlineLvl w:val="7"/>
          </w:pPr>
          <w:rPr>
            <w:rFonts w:ascii="Arial" w:fareast="黑体" w:h-ansi="Arial"/>
            <wx:font wx:val="Arial"/>
            <w:sz w:val="24"/>
          </w:rPr>
        </w:style>
        <w:style w:type="paragraph" w:styleId="9">
          <w:name w:val="heading 9"/>
          <wx:uiName wx:val="标题 9"/>
          <w:basedOn w:val="a"/>
          <w:next w:val="a"/>
          <w:rsid w:val="003C0AE3"/>
          <w:pPr>
            <w:pStyle w:val="9"/>
            <w:keepNext/>
            <w:keepLines/>
            <w:spacing w:before="240" w:after="64" w:line="320" w:line-rule="auto"/>
            <w:outlineLvl w:val="8"/>
          </w:pPr>
          <w:rPr>
            <w:rFonts w:ascii="Arial" w:fareast="黑体" w:h-ansi="Arial"/>
            <wx:font wx:val="Arial"/>
            <w:sz-cs w:val="21"/>
          </w:rPr>
        </w:style>
        <w:style w:type="paragraph" w:styleId="a3">
          <w:name w:val="Title"/>
          <wx:uiName wx:val="标题"/>
          <w:basedOn w:val="a"/>
          <w:rsid w:val="003C0AE3"/>
          <w:pPr>
            <w:pStyle w:val="a3"/>
            <w:spacing w:before="240" w:after="60"/>
            <w:jc w:val="center"/>
            <w:outlineLvl w:val="0"/>
          </w:pPr>
          <w:rPr>
            <w:rFonts w:ascii="Arial" w:h-ansi="Arial" w:cs="Arial"/>
            <wx:font wx:val="Arial"/>
            <w:b/>
            <w:b-cs/>
            <w:sz w:val="32"/>
            <w:sz-cs w:val="32"/>
          </w:rPr>
        </w:style>
      </w:styles>

      <w:body>
        <wx:sect>
          <xsl:call-template name="sub_section">
            <xsl:with-param name="layer" select="0" />
          </xsl:call-template>
        </wx:sect>
      </w:body>
      
    </w:wordDocument>
  </xsl:template>

  <xsl:template name="sub_section">
    <xsl:for-each select="node">

      <xsl:param name="i">
        <xsl:number level="single"/>
      </xsl:param>

      <wx:sub-section>
        
        <xsl:if test="@title">
          <w:p>
            <w:pPr>
              <w:pStyle>
                <xsl:choose>
                  <xsl:when test="$layer=0">
                    <xsl:attribute name="w:val">a3</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="w:val">
                      <xsl:value-of select="concat('',$layer)">
                      </xsl:value-of>
                    </xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </w:pStyle>
              <w:rPr>
                <w:rFonts w:hint="fareast"/>
              </w:rPr>
            </w:pPr>

            <w:r>
              <w:t>
                <xsl:value-of select="@title" />
              </w:t>
            </w:r>
            
          </w:p>
        </xsl:if>

        <note>
          <xsl:attribute name="id">
            <xsl:value-of select="@id"></xsl:value-of>
          </xsl:attribute>
        </note>

      </wx:sub-section>

      <xsl:call-template name="sub_section">
        <xsl:with-param name="layer" select="$layer+1" />
      </xsl:call-template>
      
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
