<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common">
  <xsl:output method="xml" indent="yes" />

  <xsl:template name="header">

    <xsl:param name="params" />
    <xsl:param name="identifier" />

    <xsl:variable name="datestampField"
      select="string($params/str[@name='datestampField'])" />

    <xsl:variable name="setIdField"
      select="string($params/str[@name='setIdField'])" />
      
    <xsl:variable name="datestamp" select="date[@name=$datestampField]" />
    <xsl:variable name="setId" select="*[@name=$setIdField]" />      

    <xsl:variable name="setPrefix"
      select="concat($params/str[@name='setPrefix'], ':')" />
      
    <header>
      <identifier>
        <xsl:value-of select="$identifier" />
      </identifier>
      <datestamp>
        <xsl:value-of select="$datestamp" />
      </datestamp>
      <xsl:if test="$setId">
        <setSpec>
          <xsl:value-of select="concat($setPrefix, $setId)" />
        </setSpec>
      </xsl:if>
    </header>

  </xsl:template>

</xsl:stylesheet>