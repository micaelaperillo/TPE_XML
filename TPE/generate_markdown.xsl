<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>

<xsl:template match="/">
	<xsl:apply-templates select="//error"/>
	<xsl:apply-templates select="//season"/>
	<xsl:apply-templates select="//stages/stage"/>
</xsl:template>

<xsl:template match="error">
	<xsl:value-of select="."/>
</xsl:template>

<xsl:template match="season">
# Season <xsl:value-of select="name"/>
___
### Competition <xsl:value-of select="competition"/>
#### Year: <xsl:value-of select="date/year"/>. From <xsl:value-of select="date/start"/> to <xsl:value-of select="date/end"/>.
___
___
</xsl:template>

<xsl:template match="stage">
    <xsl:for-each select="groups/group">
#### Competitors:
    <xsl:for-each select="competitor">
- <xsl:value-of select="name"/> (<xsl:value-of select="country"/>)
    </xsl:for-each>
#### Events:
        <xsl:for-each select="event">
            <xsl:sort select="@start_time"/>
| Date | Local | Visitor |
| ---- | ----- | ------- |
|<xsl:value-of select="@start_time"/>|<xsl:value-of  select="local/score"/>|<xsl:value-of select="visitor/score"/>|
| |<xsl:value-of select="local/name"/>|<xsl:value-of select="visitor/name"/>|
        </xsl:for-each>
    </xsl:for-each>
___
</xsl:template>
</xsl:stylesheet>
