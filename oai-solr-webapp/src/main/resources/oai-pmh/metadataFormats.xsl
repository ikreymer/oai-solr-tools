<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:exslt="http://exslt.org/common">

  <xsl:output method="xml" indent="yes" />

  <xsl:template name="listFormats">
    <metadataFormat>
      <metadataPrefix>oai_dc</metadataPrefix>
      <schema>http://www.openarchives.org/OAI/2.0/oai_dc.xsd</schema>
      <metadataNamespace>http://www.openarchives.org/OAI/2.0/oai_dc/</metadataNamespace>
    </metadataFormat>

    <metadataFormat>
      <metadataPrefix>oai_marc21</metadataPrefix>
      <schema>http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd</schema>
      <metadataNamespace>http://www.loc.gov/MARC21/slim</metadataNamespace>
    </metadataFormat>
  </xsl:template>

  <!-- Metadata format specific stylesheets -->

  <!-- DC -->
  <xsl:include href="metadata_oai_dc.xsl" />

  <xsl:template match="docRoot[@type='oai_dc']/doc">
    <xsl:param name="identifier"/>
    <xsl:call-template name="oai_dc">
      <xsl:with-param name="identifier" select="$identifier" />
    </xsl:call-template>
  </xsl:template>

  <!-- MARC 21, first convert to DC, then to MARC 21 -->
  <xsl:include href="metadata_oai_mark21.xsl" />

  <xsl:template match="docRoot[@type='oai_marc21']/doc">
    <xsl:param name="identifier"/>
    <xsl:variable name="dcRoot">
      <xsl:element name="dcRoot">
        <xsl:call-template name="oai_dc">
          <xsl:with-param name="identifier" select="$identifier" />
        </xsl:call-template>
      </xsl:element>
    </xsl:variable>

    <xsl:for-each select="exslt:node-set($dcRoot)">
      <xsl:call-template name="DC_to_MARC" />
    </xsl:for-each>

  </xsl:template>


</xsl:stylesheet>