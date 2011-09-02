<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:exslt="http://exslt.org/common">
  <xsl:output method="xml" indent="yes" />

  <xsl:import href="metadataFormats.xsl" />
  <xsl:import href="verbs.xsl" />

  <xsl:template match="response">

    <xsl:variable name="params" select="//lst[@name='params']" />

    <xsl:variable name="verb" select="string($params/str[@name='verb'])" />

    <xsl:variable name="requestStr"
      select="string($params/str[@name='requestStr'])" />

    <xsl:variable name="metadataPrefix"
      select="string($params/str[@name='metadataPrefix'])" />

    <xsl:variable name="identifier"
      select="string($params/str[@name='identifier'])" />

    <xsl:variable name="from" select="string($params/str[@name='from'])" />

    <xsl:variable name="until" select="string($params/str[@name='until'])" />

    <xsl:variable name="resumptionToken"
      select="string($params/str[@name='resumptionToken'])" />

    <xsl:variable name="set" select="string($params/str[@name='set'])" />

    <OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ex="http://exslt.org/dates-and-times"
      xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">

      <responseDate>
        <xsl:value-of select="ex:date-time()" />
      </responseDate>

      <!-- Set if the metadataPrefix field is significant and needs to be 
        validated -->
      <!-- True only for GetRecord, ListRecords, ListIdentifiers verbs -->
      <xsl:variable name="validatePrefix"
        select="$verb='GetRecords' or $verb='ListRecords' or $verb='ListIdentifiers'" />

      <xsl:variable name="listFormats">
        <xsl:call-template name="listFormats" />
      </xsl:variable>

      <xsl:variable name="responses">
        <xsl:choose>
          <xsl:when
            test="($validatePrefix = true()) and (not(exslt:node-set($listFormats)//metadataPrefix[text() = $metadataPrefix]))">
            <error code="cannotDisseminateFormat">
              <xsl:value-of select="$params/str[@name='cannotDisseminateFormat']"/>
              <xsl:value-of select="$metadataPrefix" />
            </error>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="//result">
              <xsl:with-param name="params" select="$params" />
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="responseNode" select="exslt:node-set($responses)" />

      <xsl:choose>
        <xsl:when test="name($responseNode/*[1]) = 'error'">
        
          <request>
            <xsl:value-of select="$requestStr" />
          </request>
          <xsl:copy-of select="$responseNode/*[1]" />
        
        </xsl:when>

        <xsl:otherwise>
        
          <xsl:element name="request">
            <xsl:attribute name="verb"><xsl:value-of
              select="$verb" /></xsl:attribute>

            <xsl:if test="string-length(metadataPrefix) > 0">
              <xsl:attribute name="metadataPrefix"><xsl:value-of
                select="$metadataPrefix" /></xsl:attribute>
            </xsl:if>

            <xsl:if test="$verb='GetRecord'">
              <xsl:attribute name="identifier"><xsl:value-of
                select="$identifier" /></xsl:attribute>
            </xsl:if>

            <xsl:if test="string-length($from) > 0">
              <xsl:attribute name="from"><xsl:value-of
                select="$from" /></xsl:attribute>
            </xsl:if>

            <xsl:if test="string-length($until) > 0">
              <xsl:attribute name="until"><xsl:value-of
                select="$until" /></xsl:attribute>
            </xsl:if>

            <xsl:if test="string-length($set) > 0">
              <xsl:attribute name="set"><xsl:value-of
                select="$set" /></xsl:attribute>
            </xsl:if>

            <xsl:if test="string-length($resumptionToken) > 0">
              <xsl:attribute name="resumptionToken"><xsl:value-of
                select="$resumptionToken" /></xsl:attribute>
            </xsl:if>

            <xsl:text><xsl:value-of select="$requestStr" /></xsl:text>
          </xsl:element>

          <xsl:element name="{$verb}">
            <xsl:copy-of select="$responseNode" />
          </xsl:element>
   
        </xsl:otherwise>
      </xsl:choose>

    </OAI-PMH>
  </xsl:template>

</xsl:stylesheet>