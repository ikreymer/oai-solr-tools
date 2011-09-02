<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:database="http://www.oclc.org/pears/"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">

  <xsl:output method="xml" indent="yes" />
  
  <xsl:template name="oai_dc">
  
    <xsl:param name="identifier" />

    <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
      xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
      <xsl:for-each select="child::node()">
        <!-- Tests for the 15 DC elements -->

        <!--title: not to be confused with the SOLR field attribute "name", 
          this pulls from the actual Dublin Core metadata field "title" as entered 
          by user -->
        <!--However, if this field is empty, this section will populate the 
          <title> field from the <str name="name"> field - which is the name entered 
          for the collection in the web-app dialogue -->
          
        <xsl:if test="@name = 'name'">
          <xsl:element name="dc:title">
            <!-- Select the title field -->
            <xsl:variable name="title" select="../str[@name = 'title']/text()"/>
            <xsl:choose>
              <xsl:when test="$title != ''">
                <xsl:value-of select="../str[@name = 'title']/text()" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="text()" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>  <!--End Field Element -->
        </xsl:if>
        
        
        <xsl:if test="@name = 'title' and not(../str[@name = 'name'])">
          <xsl:element name="dc:{@name}">
            <xsl:value-of select="text()" />
          </xsl:element>  <!--End Field Element -->        
        </xsl:if>

        <!--description -->
        <xsl:if test="@name = 'description'">
          <xsl:element name="dc:{@name}">
            <xsl:value-of select="text()" />
          </xsl:element>  <!--End Field Element -->
        </xsl:if>

        <!-- subject -->
        <!-- Within the Archive-It webapp, this is the only Dublin Core field 
          that allows for multiple entries, which is why this section has an extra 
          "for-each" function within it. -->
        <xsl:if test="@name = 'subject'">
          <xsl:for-each select="*">
            <xsl:element name="dc:subject">
              <xsl:value-of select="text()" />
            </xsl:element>  <!--End Field Element -->
          </xsl:for-each>
        </xsl:if>

        <!--creator -->
        <xsl:if test="@name = 'creator'">
          <xsl:element name="dc:{@name}">
            <xsl:value-of select="text()" />
          </xsl:element>  <!--End Field Element -->
        </xsl:if>

        <!--date -->
        <xsl:if test="@name = 'date'">
          <xsl:element name="dc:{@name}">
            <xsl:value-of select="text()" />
          </xsl:element>  <!--End Field Element -->
        </xsl:if>

        <!--type "type" already used in SOLR database, additional output 
          field created called "metadataType" that expresses the user entered Dublin 
          Core "type" -->
        <xsl:if test="@name = 'metadataType'">
          <xsl:element name="dc:type">
            <xsl:value-of select="text()" />
          </xsl:element>  <!--End Field Element -->
        </xsl:if>

        <!--publisher -->
        <xsl:if test="@name = 'publisher'">
          <xsl:element name="dc:{@name}">
            <xsl:value-of select="text()" />
          </xsl:element>  <!--End Field Element -->
        </xsl:if>

        <!--rights -->
        <xsl:if test="@name = 'rights'">
          <xsl:element name="dc:{@name}">
            <xsl:value-of select="text()" />
          </xsl:element>  <!--End Field Element -->
        </xsl:if>

        <!--contributor -->
        <xsl:if test="@name = 'contributor'">
          <xsl:element name="dc:{@name}">
            <xsl:value-of select="text()" />
          </xsl:element>  <!--End Field Element -->
        </xsl:if>

        <!--relation -->
        <xsl:if test="@name = 'relation'">
          <xsl:element name="dc:{@name}">
            <xsl:value-of select="text()" />
          </xsl:element>  <!--End Field Element -->
        </xsl:if>

        <!--format -->
        <xsl:if test="@name = 'format'">
          <xsl:element name="dc:{@name}">
            <xsl:value-of select="text()" />
          </xsl:element>  <!--End Field Element -->
        </xsl:if>

        <!--source -->
        <xsl:if test="@name = 'source'">
          <xsl:element name="dc:{@name}">
            <xsl:value-of select="text()" />
          </xsl:element>  <!--End Field Element -->
        </xsl:if>

        <!--coverage -->
        <xsl:if test="@name = 'coverage'">
          <xsl:element name="dc:{@name}">
            <xsl:value-of select="text()" />
          </xsl:element>  <!--End Field Element -->
        </xsl:if>

        <!--language -->
        <xsl:if test="@name = 'language'">
          <xsl:element name="dc:{@name}">
            <xsl:value-of select="text()" />
          </xsl:element>  <!--End Field Element -->
        </xsl:if>

        <!--identifier -->
<!--         <xsl:if test="@name = 'identifier'">
          <xsl:element name="dc:{@name}">
            <xsl:value-of select="text()" />
          </xsl:element>  End Field Element
        </xsl:if> -->

      </xsl:for-each>
      
      <dc:identifier>
        <xsl:variable name="idField" select="string(./str[@name='identifier'])"/>
        <xsl:if test="$idField != ''">
          <xsl:value-of select="$idField"/>        
        </xsl:if>
        <xsl:if test="$idField = ''">
          <xsl:value-of select="$identifier"/>        
        </xsl:if>        
      </dc:identifier>
   
    </oai_dc:dc>  <!--For oai_cd:dc -->


  </xsl:template>

</xsl:stylesheet>
