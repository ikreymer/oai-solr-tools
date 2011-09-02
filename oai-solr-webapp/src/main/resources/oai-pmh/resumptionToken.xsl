<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes" />

  <xsl:template name="buildResumptionToken">
  
    <xsl:param name="params"/>
    
    <xsl:variable name="metadataPrefix"
      select="string($params/str[@name='metadataPrefix'])" />

    <xsl:variable name="start" select="number(@start)" />

    <xsl:variable name="rows"
      select="number($params/str[@name='rows'])" />

    <xsl:variable name="from"
      select="string($params/str[@name='from'])" />

    <xsl:variable name="until"
      select="string($params/str[@name='until'])" />

    <xsl:variable name="totalCount" select="number(@numFound)" />

    <xsl:choose>
      <xsl:when test="($start = 0) and ($rows >= $totalCount)">
        <!-- Getting the entire list at once, so no Resumption Token needed -->
      </xsl:when>
      <xsl:when test="($start + $rows) >= $totalCount">
        <!-- At the end of the list, so add empty resumption token -->
        <resumptionToken></resumptionToken>
      </xsl:when>
      <xsl:otherwise>
        <resumptionToken cursor="{$start}"
          completeListSize="{$totalCount}">
          <xsl:variable name="fullToken"
            select="concat($start + $rows, ',', $rows, ',', $metadataPrefix, ',', $from, ',', $until)"  />
          <xsl:value-of select="$fullToken" />
        </resumptionToken>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>