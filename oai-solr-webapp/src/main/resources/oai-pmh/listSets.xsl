<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes" />

  <xsl:import href="resumptionToken.xsl" />

  <xsl:template name="buildSets">

    <xsl:param name="params" />

    <xsl:variable name="numDocs" select="count(./doc)" />

    <xsl:variable name="setPrefix"
      select="string($params/str[@name='setPrefix'])" />

    <xsl:variable name="fullPrefix" select="concat($setPrefix, ':')" />

    <xsl:variable name="setIdField"
      select="string($params/str[@name='setIdField'])" />

    <xsl:variable name="setNameField"
      select="string($params/str[@name='setNameField'])" />

    <xsl:variable name="setDescField"
      select="string($params/str[@name='setDescField'])" />

    <xsl:if test="$numDocs = 0 or setIdField = '' or setNameField = ''">
      <error code="noSetHierarchy">
        <xsl:value-of select="$params/str[@name='noSetHierarchy']" />
      </error>
    </xsl:if>

    <xsl:if test="$numDocs > 0">
      <!-- Add Root Set for first page -->
      <xsl:if test="@start = 0">
        <set>
          <setSpec>
            <xsl:value-of select="$setPrefix" />
          </setSpec>
          <setName>
            <xsl:value-of select="$setPrefix" />
          </setName>
        </set>
      </xsl:if>

      <xsl:for-each select="./doc">
        <set>
          <setSpec>
            <xsl:value-of
              select="concat($fullPrefix, string(./*[@name=$setIdField]))" />
          </setSpec>
          <xsl:if test="./str[@name=$setNameField]">
            <setName>
              <xsl:value-of select="./str[@name=$setNameField]" />
            </setName>
          </xsl:if>
          <xsl:if test="$setDescField and ./str[@name=$setDescField]">
            <setDescription>
              <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
                xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ 
          http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
                <dc:description><xsl:value-of
                  select="./str[@name=$setDescField]" /></dc:description>
              </oai_dc:dc>
            </setDescription>
          </xsl:if>
        </set>
      </xsl:for-each>

      <xsl:call-template name="buildResumptionToken">
        <xsl:with-param name="params" select="$params" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>