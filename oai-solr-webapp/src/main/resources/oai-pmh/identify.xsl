<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exslt="http://exslt.org/common">
  <xsl:output method="xml" indent="yes" />

  <!-- Specify the following fields to properly identify your OAI Provider -->
  <!-- repositoryName: Name of your repository -->
  <!-- adminEmail: contact e-mail for your repository -->
  
  <!-- For Additional details on the Identify verb, refer to the OAI specification at: -->
  <!-- http://www.openarchives.org/OAI/openarchivesprotocol.html -->
  
  <xsl:template name="identify">
    <xsl:param name="params" />
    
    <xsl:variable name="requestStr"
      select="string($params/str[@name='requestStr'])" />
    <repositoryName>Sample Institution OAI Collections</repositoryName>
    <baseURL>
      <xsl:value-of select="$requestStr" />
    </baseURL>
    <protocolVersion>2.0</protocolVersion>
    <adminEmail>myemail@example.org</adminEmail>
    <earliestDatestamp>2000-12-21T00:00:00Z</earliestDatestamp>
    <deletedRecord>transient</deletedRecord>
    <granularity>YYYY-MM-DDThh:mm:ssZ</granularity>
  </xsl:template>

</xsl:stylesheet>