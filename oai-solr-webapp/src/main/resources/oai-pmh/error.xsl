<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common">
  <xsl:output method="xml" indent="yes" />

  <xsl:template match="/">
    <xsl:param name="errorMsg" select="'Unexpected Error'" />
    <xsl:param name="errorCode" select="'badArgument'" />
    <xsl:param name="requestStr" />

    <OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ex="http://exslt.org/dates-and-times"
      xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">

      <responseDate>
        <xsl:value-of select="ex:date-time()" />
      </responseDate>

      <request>
        <xsl:value-of select="$requestStr" />
      </request>

      <error code="{$errorCode}"><xsl:value-of select="$errorMsg" /></error>

    </OAI-PMH>
  </xsl:template>
  
</xsl:stylesheet>