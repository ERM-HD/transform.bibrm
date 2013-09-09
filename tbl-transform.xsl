<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE rdf:RDF [
<!ENTITY bibrm "http://vocab.ub.uni-leipzig.de/bibrm/">
<!ENTITY erm-hd "http://erm-hd2/">
<!ENTITY item "http://erm-hd2/item/">
<!ENTITY contract "http://erm-hd2/contract/">
<!ENTITY publisher "http://erm-hd2/publisher/">
<!ENTITY package "http://erm-hd2/package/">
<!ENTITY body "http://erm-hd2/organization/">
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
            xmlns:publisher="&publisher;"
            >
            <xsl:apply-templates select="E_x0020_Journals_x0020_2012"/>
            <xsl:apply-templates select="/dataroot/Lieferant"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="E_x0020_Journals_x0020_2012">
        <xsl:element name="bibrm:BibRessource">
            <xsl:attribute name="rdf:about">&item;<xsl:value-of select="ID" /></xsl:attribute>
            <xsl:attribute name="rdfs:label"><xsl:value-of select="normalize-space(Titel)" /></xsl:attribute>
        </xsl:element>
        <!-- Tokenize E-ISSN -->
        <xsl:call-template name="tokenizeString">
            <xsl:with-param name="preToken" select="'urn:ISSN:'"/>
            <xsl:with-param name="list" select="E_x0020_ISSN"/>
            <xsl:with-param name="postToken" select="''"/>
            <xsl:with-param name="delimiter" select="';'"/>
            <xsl:with-param name="isResource" select="'true'"/>
            <xsl:with-param name="element" select="concat('&item;', ID)"/>
            <xsl:with-param name="property">bibrm:EISSN</xsl:with-param>
        </xsl:call-template>
        <!-- Tokenize P-ISSN -->
        <xsl:call-template name="tokenizeString">
            <xsl:with-param name="preToken" select="'urn:ISSN:'"/>
            <xsl:with-param name="list" select="P_x0020_ISSN"/>
            <xsl:with-param name="postToken" select="''"/>
            <xsl:with-param name="delimiter" select="';'"/>
            <xsl:with-param name="isResource" select="'true'"/>
            <xsl:with-param name="element" select="concat('&item;', ID)"/>
            <xsl:with-param name="property">bibrm:PISSN</xsl:with-param>
        </xsl:call-template>
        <!-- Tokenize Verlag -->
        <xsl:call-template name="tokenizePublisher">
            <xsl:with-param name="preToken" select="''"/>
            <xsl:with-param name="list" select="Verlag"/>
            <xsl:with-param name="postToken" select="''"/>
            <xsl:with-param name="delimiter" select="';'"/>
            <xsl:with-param name="element" select="concat('http://erm-hd2/item/', ID)"/>
        </xsl:call-template>
        <xsl:call-template name="writePackage">
            <xsl:with-param name="abostatusId"><xsl:value-of select="Abostatus"/></xsl:with-param>
            <xsl:with-param name="lieferantenId"><xsl:value-of select="Lieferant"/></xsl:with-param>
            <xsl:with-param name="verlag"><xsl:value-of select="Verlag"/></xsl:with-param>
            <xsl:with-param name="bibItem" select="concat('&item;' ,ID)"/>
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
                            true
                        </xsl:when>
                        <xsl:when test="contains($abo, 'Full')">
                            <xsl:variable name="package" select="'FullCollection'"/>
                            true
                        </xsl:when>
                        <xsl:otherwise>
                            false
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="contains($verlag,'Springer')">
                    <xsl:variable name="tempVerlag" select="'Springer'"/>
                    <xsl:choose>
                        <xsl:when test="contains($abo, 'Grundvertrag')">
                            <xsl:variable name="package" select="'Grundvertrag'"/>
                            true
                        </xsl:when>
                        <xsl:when test="contains($abo, 'Cross')">
                            <xsl:variable name="package" select="'CrossAccess'"/>
                            true
                        </xsl:when>
                        <xsl:otherwise>
                            false
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            <xsl:when test="contains($verlag,'Oxford')">
                    <xsl:variable name="tempVerlag" select="'Oxford'"/>
                    <xsl:choose>
                        <xsl:when test="contains($abo, 'Grundvertrag')">
                            <xsl:variable name="package" select="'Grundvertrag'"/>
                            true
                        </xsl:when>
                        <xsl:when test="contains($abo, 'Cross')">
                            <xsl:variable name="package" select="'CrossAccess'"/>
                            true
                        </xsl:when>
                        <xsl:otherwise>
                            false
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="contains($verlag,'Wiley')">
                    <xsl:variable name="tempVerlag" select="'Wiley'"/>
                    <xsl:choose>
                        <xsl:when test="contains($abo, 'Grundvertrag')">
                            <xsl:variable name="package" select="'Grundvertrag'"/>
                            true
                        </xsl:when>
                        <xsl:when test="contains($abo, 'Full')">
                            <xsl:variable name="package" select="'FullCollection'"/>
                            true
                        </xsl:when>
                        <xsl:otherwise>
                            false
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    false
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
            <xsl:choose>
                <xsl:when test="contains($abo, 'Einzelabo') and contains($passed, 'false')">
                    <xsl:element name="rdf:Description">
                        <xsl:attribute name="rdf:about"><xsl:value-of select="concat('&contract;',ID)"/></xsl:attribute>
                        <xsl:element name="rdf:type">bibrm:LicenseContract</xsl:element>
                        <xsl:element name="bibrm:hasItem">&item;<xsl:value-of select="ID"/></xsl:element>
                        <xsl:element name="rdfs:label"><xsl:value-of select="concat('Einzelabo ', Verlag)"/></xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="contains($passed, 'true')">
                    <xsl:call-template name="writePackage">
                        <xsl:with-param name="abo" select="$abo"/>
                        <xsl:with-param name="bibItem" select="$bibItem"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
    </xsl:template>

    <xsl:template name="writePackage">
        <xsl:param name="abostatusId"/>
        <xsl:param name="lieferantenId"/>
        <xsl:param name="bibItem"/>
        <xsl:variable name="licenseAgent" select="document('xml/Lieferant.xml')//dataroot/Lieferant/ID[text() = $lieferantenId]/../Lieferant"/>
        <xsl:variable name="abo" select="document('xml/Abostatus.xml')//dataroot/Abostatus/ID[text() = $abostatusId]/../Feld1"/>
        <xsl:variable name="contractAgent">
            <xsl:choose>
                <xsl:when test="string-length($licenseAgent)==0">false</xsl:when>
                <xsl:otherwise>true</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="package">
            <xsl:choose>
                <xsl:when test="contains($abo, 'Grundvertrag')">Einzelvertrag</xsl:when>
                <xsl:when test="string-length($abo)==0">false</xsl:when>
                <xsl:otherwise>true</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <!-- unclear states -->
            <xsl:when test="contains($contractAgent, 'false') and contains($abo, 'false')"/>
            <xsl:when test="contains($contractAgent, 'true') and contains($abo, 'false')"/>
            <!-- No contract but a package 'Einzelvertrag' -->
            <xsl:when test="contains($contractAgent, 'false') and contains($package, 'Einzelvertrag')">
                <xsl:element name="rdf:LicenseContract">
                    <xsl:attribute name="rdf:about"><xsl:value-of select="translate($licenseAgent, ' ', '')"/></xsl:attribute>
                    <xsl:attribute name="rdfs:label"><xsl:value-of select="concat('Einzelvertag mit ', translate($licenseAgent, ' ', ''))"/></xsl:attribute>
                </xsl:element>
            </xsl:when>
            <!-- Found LicenseAgent and Package -->
            <xsl:when test="contains($contractAgent, 'true') and contains($package, 'true')"/>
            <xsl:otherwise>
                <xsl:element name="bibrm:Package">
                    <xsl:attribute name="rdf:about">&package;<xsl:value-of select="concat(normalize-space($contract), $package)"/></xsl:attribute>
                </xsl:element>
                <xsl:element name="bibrm:LicenseContract">
                    <xsl:attribute name="rdf:about">&contract;"><xsl:value-of select="normalize-space($contract)"/></xsl:attribute>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="tokenizePublisher">
        <xsl:param name="preToken"/>
        <xsl:param name="list"/>
        <xsl:param name="postToken"/>
        <xsl:param name="delimiter"/>
        <xsl:param name="element"/>
        <xsl:if test="string-length($list)!=0">
            <xsl:choose>
                <xsl:when test="contains($list, $delimiter)">
                    <xsl:call-template name="matchPublisher">
                        <xsl:with-param name="verlagToken" select="concat($preToken, normalize-space(substring-before($list,$delimiter)), $postToken)"/>
                        <xsl:with-param name="element" select="$element"/>
                    </xsl:call-template>
                    <xsl:call-template name="tokenizePublisher">
                        <xsl:with-param name="preToken" select="$preToken"/>
                        <xsl:with-param name="list"><xsl:value-of select="normalize-space(substring-after($list,$delimiter))"/></xsl:with-param>
                        <xsl:with-param name="postToken" select="$postToken"/>
                        <xsl:with-param name="delimiter" select="$delimiter"/>
                        <xsl:with-param name="element" select="$element"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$list = ''">
                            <xsl:text/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="matchPublisher">
                                <xsl:with-param name="verlagToken" select="concat($preToken, normalize-space($list), $postToken)"/>
                                <xsl:with-param name="element" select="$element"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template name="matchPublisher">
        <xsl:param name="verlagToken"/>
        <xsl:param name="element"/>
        <xsl:variable name="match" select="document('xml/Lieferant.xml')//dataroot/Lieferant/Lieferant[contains($verlagToken, text())]/../Lieferant"/>
        <xsl:if test="string-length($match)!=0">
            <xsl:element name="bibrm:Publisher">
                <xsl:attribute name="rdf:about"><xsl:value-of select="concat('&publisher;',translate($match,' ', ''))"/></xsl:attribute>
            </xsl:element>
            <!--<xsl:element name="rdf:Description">
                <xsl:attribute name="rdf:about"><xsl:value-of select="$element"/></xsl:attribute>
                <xsl:element name="bibrm:publisher">'
                    <xsl:element name="bibrm:Publisher">
                        <xsl:attribute name="rdf:about"><xsl:value-of select="concat('&publisher;',$verlagToken)"/></xsl:attribute>
                    </xsl:element>
                </xsl:element>
            </xsl:element>-->
        </xsl:if>
    </xsl:template>

    <xsl:template name="tokenizeString">
        <xsl:param name="preToken"/>
        <xsl:param name="list"/>
        <xsl:param name="postToken"/>
        <xsl:param name="delimiter"/>
        <xsl:param name="element"/>
        <xsl:param name="property"/>
        <xsl:param name="isResource"/>
        <xsl:if test="string-length($list)!=0">
            <xsl:choose>
                <xsl:when test="contains($list, $delimiter)">
                    <xsl:element name="rdf:Description">
                        <xsl:attribute name="rdf:about"><xsl:value-of select="$element"/></xsl:attribute>
                        <xsl:element name="{$property}">
                            <xsl:attribute name="rdf:about"><xsl:value-of select="concat($preToken, normalize-space(substring-before($list,$delimiter)), $postToken)"/></xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                    <xsl:call-template name="tokenizeString">
                        <xsl:with-param name="preToken" select="$preToken"/>
                        <xsl:with-param name="list"><xsl:value-of select="normalize-space(substring-after($list,$delimiter))"/></xsl:with-param>
                        <xsl:with-param name="postToken" select="$postToken"/>
                        <xsl:with-param name="delimiter" select="$delimiter"/>
                        <xsl:with-param name="element" select="$element"/>
                        <xsl:with-param name="isResource" select="$isResource"/>
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
                                <xsl:element name="{$property}">
                                    <xsl:attribute name="rdf:about" ><xsl:value-of select="concat($preToken, normalize-space($list), $postToken)"/></xsl:attribute>
                                </xsl:element>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
