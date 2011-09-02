<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes" />

  <xsl:import href="header.xsl" />
  <xsl:import href="record.xsl" />
  <xsl:import href="identify.xsl" />
  <xsl:import href="listRecords.xsl" />
  <xsl:import href="listSets.xsl" />

  <xsl:template match="result">

    <xsl:param name="params" />

    <xsl:variable name="verb" select="string($params/str[@name='verb'])" />

    <xsl:choose>
      <!-- Identify -->
      <xsl:when test="$verb = 'Identify'">
        <xsl:call-template name="identify">
          <xsl:with-param name="params" select="$params" />
        </xsl:call-template>
      </xsl:when>

      <!-- ListMetadataFormats -->
      <xsl:when test="$verb = 'ListMetadataFormats'">
        <xsl:call-template name="listFormats" />
      </xsl:when>

      <!-- ListIdentifiers -->
      <xsl:when test="$verb = 'ListIdentifiers'">
        <xsl:call-template name="buildRecordList">
          <xsl:with-param name="params" select="$params" />
          <xsl:with-param name="includeData" select="false()" />
        </xsl:call-template>
      </xsl:when>

      <!-- ListRecords -->
      <xsl:when test="$verb = 'ListRecords'">
        <xsl:call-template name="buildRecordList">
          <xsl:with-param name="params" select="$params" />
          <xsl:with-param name="includeData" select="true()" />
        </xsl:call-template>
      </xsl:when>

      <!-- GetRecord -->
      <xsl:when test="$verb = 'GetRecord'">
        <xsl:call-template name="GetRecord">
          <xsl:with-param name="params" select="$params" />
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="$verb='ListSets'">
        <xsl:call-template name="buildSets">
          <xsl:with-param name="params" select="$params" />
        </xsl:call-template>
      </xsl:when>

      <!-- Invalid Verb Error -->
      <xsl:otherwise>
        <error code="badVerb">
          <xsl:value-of select="$params/str[@name='badVerb']" />
          <xsl:value-of select="$verb" />
        </error>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>