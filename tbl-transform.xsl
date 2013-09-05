<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE rdf:RDF [
<!ENTITY bibrm "http://vocab.ub.uni-leipzig.de/bibrm/">
<!ENTITY erm-hd "http://erm-hd2/">
<!ENTITY item "http://erm-hd2/item/">
<!ENTITY contract "http://erm-hd2/contract/">
<!ENTITY body "http://erm-hd2/body/">
<!ENTITY foaf "http://xmlns.com/foaf/0.1/">
<!ENTITY rdf "http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<!ENTITY rdfs "http://www.w3.org/2000/01/rdf-schema#">
<!ENTITY xsl "http://www.w3.org/1999/XSL/Transform">
<!ENTITY str "http://exslt.org/strings">

]>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:bibrm="&bibrm;"
    xmlns:rdf="&rdf;"
    xmlns:rdfs="&rdfs;"
    xmlns:str="&str;"
    xmlns:foaf="&foaf;"
    version="1.0"
    >
    <xsl:output method="xml" indent="yes" encoding="utf-8"/>
    <xsl:template match="/dataroot">
        <rdf:RDF
            xml:base="&erm-hd;"
            xmlns:bibrm="&bibrm;"
            xmlns:rdf="&rdf;"
            xmlns:rdfs="&rdfs;"
            xmlns:foaf="&foaf;"
            xmlns:body="&body;"
            xmlns:item="&item;"
            xmlns:contract="&contract;"
            >
            <xsl:apply-templates select="E_x0020_Journals_x0020_2012"/>
            <xsl:apply-templates select="/dataroot/Lieferant"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="E_x0020_Journals_x0020_2012">
        <xsl:element name="bibrm:BibRessource">
            <xsl:attribute name="rdf:about">&item;<xsl:value-of select="ID" /></xsl:attribute>
            <xsl:attribute name="rdfs:label"><xsl:value-of select="normalize-space(Titel)" /></xsl:attribute>
            <!--<xsl:element name="rdfs:Resource">
                <xsl:attribute name="rdf:about"><xsl:value-of select="concat('urn:ISSN:', E_x0020_ISSN)" /></xsl:attribute>
            </xsl:element>-->
            <xsl:attribute name="bibrm:PISSN"><xsl:value-of select="concat('urn:issn:', P_x0020_ISSN)" /></xsl:attribute>
        </xsl:element>
        <xsl:call-template name="tokenizeString">
            <xsl:with-param name="list" select="Verlag"/>
            <xsl:with-param name="delimiter" select="';'"/>
            <xsl:with-param name="element" select="concat('http://erm-hd2/item/', ID)"/>
            <xsl:with-param name="property">bibrm:Publisher</xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="checkPackage">
            <xsl:with-param name="abostatusId"><xsl:value-of select="Abostatus"/></xsl:with-param>
            <xsl:with-param name="verlag"><xsl:value-of select="Verlag"/></xsl:with-param>
            <xsl:with-param name="bibItem" select="concat('http://erm-hd/item/', ID)"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="/dataroot/Lieferant">
        <xsl:element name="bibrm:Body">
            <xsl:attribute name="rdf:about">&body;<xsl:value-of select="ID" /></xsl:attribute>
            <xsl:attribute name="bibrm:name"><xsl:value-of select="Lieferant" /></xsl:attribute>
            <xsl:attribute name="rdfs:label"><xsl:value-of select="Lieferant" /></xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template name="checkPackage">
        <xsl:param name="abostatusId"/>
        <xsl:param name="verlag"/>
        <xsl:param name="bibItem"/>
        <xsl:variable name="abo" select="document('xml/Abostatus.xml')//dataroot/Abostatus/ID[text() = $abostatusId]/../Feld1"/>
        <xsl:variable name="passed" >
            <xsl:choose>
                <xsl:when test="contains($verlag,'Elsevier')">
                    <xsl:variable name="tempVerlag" select="'Elsevier'"/>
                    <xsl:choose>
                        <xsl:when test="contains($abo, 'Grundvertrag')">
                            <xsl:variable name="package" select="'Grundvertrag'"/>
                            <xsl:variable name="passed" select="'true'"/>
                        </xsl:when>
                        <xsl:when test="contains($abo, 'Full')">
                            <xsl:variable name="package" select="'FullCollection'"/>
                            <xsl:variable name="passed" select="'true'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="passed" select="'false'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="contains($verlag,'Springer')">
                    <xsl:variable name="tempVerlag" select="'Springer'"/>
                    <xsl:choose>
                        <xsl:when test="contains($abo, 'Grundvertrag')">
                            <xsl:variable name="package" select="'Grundvertrag'"/>
                            <xsl:variable name="passed" select="'true'"/>
                        </xsl:when>
                        <xsl:when test="contains($abo, 'Cross')">
                            <xsl:variable name="package" select="'CrossAccess'"/>
                            <xsl:variable name="passed" select="'true'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="passed" select="'false'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="contains($verlag,'Oxford')">
                    <xsl:variable name="tempVerlag" select="'Oxford'"/>
                    <xsl:choose>
                        <xsl:when test="contains($abo, 'Grundvertrag')">
                            <xsl:variable name="package" select="'Grundvertrag'"/>
                            <xsl:variable name="passed" select="'true'"/>
                        </xsl:when>
                        <xsl:when test="contains($abo, 'Cross')">
                            <xsl:variable name="package" select="'CrossAccess'"/>
                            <xsl:variable name="passed" select="'true'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="passed" select="'false'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="contains($verlag,'Wiley')">
                    <xsl:variable name="tempVerlag" select="'Wiley'"/>
                    <xsl:choose>
                        <xsl:when test="contains($abo, 'Grundvertrag')">
                            <xsl:variable name="package" select="'Grundvertrag'"/>
                            <xsl:variable name="passed" select="'true'"/>
                        </xsl:when>
                        <xsl:when test="contains($abo, 'Full')">
                            <xsl:variable name="package" select="'FullCollection'"/>
                            <xsl:variable name="passed" select="'true'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="passed" select="'false'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="passed" select="'false'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <Test><xsl:value-of select="$passed"/></Test>
            <xsl:choose>
                <xsl:when test="contains($abo, 'Einzelabo') and contains($passed, 'false')">
                    <xsl:element name="rdf:Description">
                        <xsl:attribute name="rdf:about"><xsl:value-of select="concat('http://erm-hd2/contract/',ID)"/></xsl:attribute>
                        <xsl:element name="rdf:type">bibrm:LicenseContract</xsl:element>
                        <xsl:element name="bibrm:hasItem">&item;<xsl:value-of select="ID"/></xsl:element>
                        <xsl:element name="rdfs:label"><xsl:value-of select="concat('Einzelabo ', Verlag)"/></xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="contains($passed, 'true')">
                    <xsl:variable name="body" select="document('xml/Lieferant.xml')//dataroot/Lieferant[text() = $tempVerlag]/../ID"/>
                    <xsl:call-template name="writePackage">
                        <xsl:with-param name="package" select="$package"/>
                        <xsl:with-param name="verlag" select="$tempVerlag"/>
                        <xsl:with-param name="bibItem" select="$bibItem"/>
                        <xsl:with-param name="contract" select="$contract"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
    </xsl:template>

        <xsl:template name="writePackage">
        <xsl:param name="contract"/>
        <xsl:param name="package"/>
        <xsl:param name="verlag"/>
        <xsl:param name="bibItem"/>
        <xsl:element name="rdf:Description">
            <xsl:attribute name="rdf:about"><xsl:value-of select="concat('http://ebrm-hd2/contract/', $verlag)"/></xsl:attribute>
            <xsl:element name="rdf:type"><xsl:value-of select="'bibrm:LicenseContract'"/></xsl:element>
            <xsl:element name="bibrm:hasItem"><xsl:value-of select="concat('http://erm-hd2/package/', $verlag, $package)"/></xsl:element>
            <xsl:element name="rdfs:label"><xsl:value-of select="concat('Vertrag mit ', Verlag)"/></xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template name="tokenizeString">
        <xsl:param name="list"/>
        <xsl:param name="delimiter"/>
        <xsl:param name="element"/>
        <xsl:param name="property"/>
        <xsl:choose>
            <xsl:when test="contains($list, $delimiter)">
                <xsl:element name="rdf:Description">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="$element"/></xsl:attribute>
                    <xsl:element name="{$property}"><xsl:value-of select="normalize-space(substring-before($list,$delimiter))"/></xsl:element>
                </xsl:element>
                <xsl:call-template name="tokenizeString">
                    <xsl:with-param name="list"><xsl:value-of select="substring-after($list,$delimiter)"/></xsl:with-param>
                    <xsl:with-param name="delimiter" select="$delimiter"/>
                    <xsl:with-param name="element" select="$element"/>
                    <xsl:with-param name="property" select="$property"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$list = ''">
                        <xsl:text/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="rdf:Description">
                            <xsl:attribute name="rdf:about"><xsl:value-of select="$element"/></xsl:attribute>
                            <xsl:element name="{$property}"><xsl:value-of select="normalize-space($list)"/></xsl:element>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
