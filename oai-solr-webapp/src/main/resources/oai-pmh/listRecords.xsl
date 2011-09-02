<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes" />

  <xsl:include href="record.xsl" />
  <xsl:import href="resumptionToken.xsl" />

  <xsl:template name="buildRecordList">

    <xsl:param name="params" />
    <xsl:param name="includeData" />

    <xsl:variable name="numDocs" select="count(./doc)" />

    <xsl:variable name="collectionIdField"
      select="string($params/str[@name='collectionIdField'])" />

    <xsl:variable name="identifier"
      select="string($params/str[@name='identifier'])" />

    <xsl:if test="$numDocs = 0">
      <error code="noRecordsMatch">
        <xsl:value-of select="$params/str[@name='noRecordsMatch']" />
      </error>
    </xsl:if>

    <xsl:for-each select="./doc">
      <xsl:variable name="collId" select="./long[@name=$collectionIdField]" />
      <xsl:variable name="collIdentifier"
        select="concat($identifier, string($collId))" />

      <xsl:if test="$includeData">
        <xsl:call-template name="record">
          <xsl:with-param name="identifier" select="$collIdentifier" />
          <xsl:with-param name="params" select="$params" />
        </xsl:call-template>
      </xsl:if>

      <xsl:if test="not($includeData)">
        <xsl:call-template name="header">
          <xsl:with-param name="identifier" select="$collIdentifier" />
          <xsl:with-param name="params" select="$params" />
        </xsl:call-template>
      </xsl:if>

    </xsl:for-each>

    <xsl:if test="$numDocs > 0">
      <xsl:call-template name="buildResumptionToken">
        <xsl:with-param name="params" select="$params" />
      </xsl:call-template>
    </xsl:if>

  </xsl:template>

</xsl:stylesheet>