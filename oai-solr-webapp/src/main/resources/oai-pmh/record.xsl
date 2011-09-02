<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common">
  <xsl:output method="xml" indent="yes" />

  <xsl:include href="metadataFormats.xsl" />
  <xsl:import href="header.xsl" />

  <xsl:template name="GetRecord">
    <xsl:param name="params" />

    <xsl:variable name="identifier"
      select="string($params/str[@name='identifier'])" />
    <xsl:choose>
      <xsl:when test="string-length($identifier) = 0">
        <error code="badArgument">
          <xsl:value-of select="$params/str[@name='badArgument']" />
        </error>
      </xsl:when>

      <xsl:when test="not(./doc)">
        <error code="idDoesNotExist">
          <xsl:value-of select="$params/str[@name='idDoesNotExist']" />
          <xsl:value-of select="$identifier" />
        </error>
      </xsl:when>

      <xsl:otherwise>
        <xsl:for-each select="./doc[1]">
          <xsl:call-template name="record">
            <xsl:with-param name="params" select="$params" />
            <xsl:with-param name="identifier" select="$identifier" />
          </xsl:call-template>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="record">

    <xsl:param name="params" />
    <xsl:param name="identifier" />

    <xsl:variable name="metadataPrefix"
      select="string($params/str[@name='metadataPrefix'])" />

    <record>
      <xsl:call-template name="header">
        <xsl:with-param name="params" select="$params" />
        <xsl:with-param name="identifier" select="$identifier" />
      </xsl:call-template>

      <metadata>
        <xsl:variable name="docRoot">
          <docRoot type="{$metadataPrefix}">
            <xsl:copy-of select="." />
          </docRoot>
        </xsl:variable>
        <xsl:apply-templates select="exslt:node-set($docRoot)">
          <xsl:with-param name="identifier" select="$identifier" />
        </xsl:apply-templates>
      </metadata>
    </record>

  </xsl:template>

  <!-- Default error doc when none other match -->
  <xsl:template match="doc">
    <error code="cannotDisseminateFormat">
      <xsl:value-of select="//lst[@name='params']/str[@name='cannotDisseminateFormat2']" />
    </error>
  </xsl:template>

</xsl:stylesheet>