<?xml version="1.0" encoding="UTF-8"?>
<!--
	This stylesheet was originally developed by The MITRE Corporation.
	It has been designed to generate documenation about the elements
	and types by looking at the annotation elements found in the OVAL
	Schema. It is maintained by The Mitre Corporation and developed
	for use by the public OVAL Community.  For more information,
	including how to get involved in the project, please visit the
	OVAL website at http://oval.mitre.org.

	The stylesheet has been modified for use with the CCI schema.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cci="http://fso.disa.mil/XMLSchema/cci">

	<xsl:output method="html"/>

	<xsl:variable name="root_element_name" select="xs:schema/xs:element[position()=1]/@name"/>
    <xsl:variable name="cci_namespace_prefix">cci</xsl:variable>
      
	<xsl:template match="xs:schema">
		<html>
		<head>
			<title>CCI Schema Element Dictionary</title>
			<style type="text/css">
				body { font-family: sans-serif; }
			</style>
		</head>
		<body bgcolor="#ffffff">

		<xsl:for-each select="xs:annotation">
			<h1 align="center">- Open Vulnerability and Assessment Language -<br/>Element Dictionary</h1>
			<ul>
			<li>Schema: <xsl:value-of select="xs:appinfo/schema"/></li>
			<li>Version: <xsl:value-of select="xs:appinfo/version"/></li>
			<li>Release Date: <xsl:value-of select="xs:appinfo/date"/></li>
			</ul>
			<xsl:for-each select="xs:documentation">
				<p align="justify"><xsl:value-of select="."/></p>
			</xsl:for-each>
		</xsl:for-each>

		<xsl:for-each select="xs:element|xs:complexType|xs:simpleType|xs:group|xs:attributeGroup">
			<xsl:choose>
				<xsl:when test="name()='xs:element'"><xsl:call-template name="global_element"/></xsl:when>
				<xsl:when test="name()='xs:complexType'"><xsl:call-template name="global_complex_type"/></xsl:when>
				<xsl:when test="name()='xs:simpleType'"><xsl:call-template name="global_simple_type"/></xsl:when>
				<xsl:when test="name()='xs:group'"><xsl:call-template name="global_element_group"/></xsl:when>
				<xsl:when test="name()='xs:attributeGroup'"><xsl:call-template name="global_attribute_group"/></xsl:when>
			</xsl:choose>
		</xsl:for-each>

		</body>
		</html>
	</xsl:template>
	
	<xsl:template name="global_element">
		<xsl:element name="h3">			
			<xsl:element name="a">
				<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
			</xsl:element>
			<b><u>
			<xsl:value-of select="@name"/>
			</u></b>
			<font size="-1">  (Element)</font>
		</xsl:element>
		
		<xsl:call-template name="annotation"/>
		<xsl:if test="xs:complexType/xs:attribute">
			<xsl:call-template name="attributes"/>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="xs:complexType/xs:complexContent/xs:extension/xs:sequence/xs:choice/xs:sequence/*"><xsl:call-template name="children"/></xsl:when>
			<xsl:when test="xs:complexType/xs:complexContent/xs:extension/xs:sequence/*"><xsl:call-template name="children"/></xsl:when>
			<xsl:when test="xs:complexType/xs:choice/xs:sequence/*"><xsl:call-template name="children"/></xsl:when>
			<xsl:when test="xs:complexType/xs:sequence/*"><xsl:call-template name="children"/></xsl:when>
		</xsl:choose>
            <xsl:if test="xs:annotation/xs:appinfo/evaluation_documentation">
	          <p align="justify"><xsl:value-of select="xs:annotation/xs:appinfo/evaluation_documentation"/></p>
	          <xsl:for-each select="xs:annotation/xs:appinfo/evaluation_chart">
	               <xsl:call-template name="evaluation_chart"/>
	          </xsl:for-each>
            </xsl:if>
	      <xsl:for-each select="xs:annotation/xs:appinfo/example">
	            <xsl:call-template name="example"/>
	      </xsl:for-each>
	      <br/>
	</xsl:template>
	
	<xsl:template name="global_complex_type">	
		<xsl:element name="h3">
			<xsl:element name="a">
				<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
			</xsl:element>
			<b><u>
			<xsl:value-of select="@name"/>
			</u></b>
			<font size="-1">  (complex type)</font>
		</xsl:element>
		
		<xsl:call-template name="annotation"/>
		<xsl:if test="xs:attribute">
			<xsl:call-template name="attributes"/>
		</xsl:if>
		<xsl:if test="xs:sequence/*|xs:choice/*">
			<xsl:call-template name="children"/>
		</xsl:if>
		<xsl:if test="xs:simpleContent">
			<xsl:call-template name="simpleContent"/>
		</xsl:if>
	     <xsl:if test="xs:annotation/xs:appinfo/evaluation_documentation">
	          <p align="justify"><xsl:value-of select="xs:annotation/xs:appinfo/evaluation_documentation"/></p>
	          <xsl:for-each select="xs:annotation/xs:appinfo/evaluation_chart">
	               <xsl:call-template name="evaluation_chart"/>
	          </xsl:for-each>
	     </xsl:if>
	     
		<br/>
	</xsl:template>
	
	<xsl:template name="global_simple_type">
		<xsl:element name="h3">
			<xsl:element name="a">
				<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
			</xsl:element>
			<b><u>
			<xsl:value-of select="@name"/>
			</u></b>
			<font size="-1">  (simple type)</font>
		</xsl:element>
		
		<xsl:call-template name="annotation"/>
		
		<xsl:if test="xs:restriction/xs:pattern">
			<xsl:call-template name="pattern"/>
		</xsl:if>
		<xsl:if test="xs:restriction/xs:enumeration">
			<xsl:call-template name="enumeration"/>
		</xsl:if>

		<xsl:if test="xs:annotation/xs:appinfo/evaluation_documentation">
			<p align="justify"><xsl:value-of select="xs:annotation/xs:appinfo/evaluation_documentation"/></p>
			<xsl:for-each select="xs:annotation/xs:appinfo/evaluation_chart">
				<xsl:call-template name="evaluation_chart"/>
			</xsl:for-each>
		</xsl:if>

		<br/>
	</xsl:template>
	
	<xsl:template name="global_element_group">		
		<xsl:element name="h3">
			<xsl:element name="a">
				<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
			</xsl:element>
			<xsl:text>-- </xsl:text>
			<xsl:value-of select="@name"/>
			<xsl:text> --</xsl:text>
		</xsl:element>
		<xsl:call-template name="annotation"/>
		<xsl:if test="xs:choice/*">
			<xsl:call-template name="children"/>
		</xsl:if>
		<br/>
	</xsl:template>
	
	<xsl:template name="global_attribute_group">
		<xsl:element name="h3">
			<xsl:text>-- </xsl:text>
				<xsl:value-of select="@name"/>
			<xsl:text> --</xsl:text>
		</xsl:element>
		
		<xsl:call-template name="annotation"/>
		
		<xsl:if test="xs:attribute">
			<xsl:call-template name="attributes"/>
		</xsl:if>

		<br/>
	</xsl:template>
	
	<xsl:template name="annotation">
		<xsl:for-each select="xs:annotation">
			<xsl:for-each select="xs:documentation">
				<p align="justify"><xsl:value-of select="."/></p>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="attributes">
	<blockquote>
		<table bgcolor="#F9F9F9" border="1" cellpadding="5" cellspacing="0" style="table-layout:fixed" width="88%">
			<colgroup span="6">
				<col width="150"/>
				<col width="150"/>
				<col width="150"/>
				<col width="*"/>
			</colgroup>
			<tr bgcolor="#F0F0F0">
				<td><b>Attributes</b></td>
				<td><b>Type</b></td>
				<td><b>Notes</b></td>
				<td><b>Documentation</b></td>
			</tr>

			<xsl:for-each select="xs:attribute|                          xs:complexType/xs:attribute">
			<xsl:element name="tr">
				<td><xsl:value-of select="@name"/></td>
				<td>
					<xsl:choose>
						<xsl:when test="not(@type)">n/a</xsl:when>	
						<xsl:otherwise><xsl:value-of select="@type"/></xsl:otherwise>
					</xsl:choose>
				</td>
				<td>
					<xsl:if test="@use">
						<font size="-1">
						(<xsl:value-of select="@use"/>)
						</font>
					</xsl:if>
					<xsl:if test="@default">
					<font size="-1">
						default: <xsl:value-of select="@default"/>
						</font>
					</xsl:if>
				</td>
				<td><font size="-1"><xsl:value-of select="xs:annotation/xs:documentation"/></font></td>
			</xsl:element>
			</xsl:for-each>
			
		</table>
	</blockquote>
	</xsl:template>
	
	<xsl:template name="children">
		<blockquote>
		<table bgcolor="#F9F9F9" border="1" cellpadding="5" cellspacing="0" style="table-layout:fixed" width="88%">
			<colgroup span="5">
				<col width="150"/>
				<col width="150"/>
				<col width="*"/>
				<col width="80"/>
				<col width="80"/>
			</colgroup>
			<tr bgcolor="#F0F0F0">
				<td><b>Child Elements</b></td>
				<td><b>Type</b></td>
				<td><b>Documentation</b></td>
				<td align="center"><b><font size="-1">MinOccurs</font></b></td>
				<td align="center"><b><font size="-1">MaxOccurs</font></b></td>
			</tr>
				
			<xsl:for-each select="xs:complexType/xs:complexContent/xs:extension/xs:sequence/xs:choice/xs:sequence/*|                          xs:complexType/xs:complexContent/xs:extension/xs:sequence/*|                          xs:complexType/xs:choice/xs:sequence/*|                          xs:complexType/xs:sequence/*|                          xs:choice/*|                          xs:sequence/*">
				<xsl:variable name="context" select="."/>
				<xsl:choose>
					<xsl:when test="@name|@ref[.!='oval-def:set']">
						<xsl:call-template name="writeChildElmRow"/>
					</xsl:when>
					<xsl:when test="name()='xs:choice' and name(../..)='xs:choice'">						
						<xsl:for-each select="$context/xs:sequence/*">
							<xsl:call-template name="writeChildElmRow"/>
						</xsl:for-each>						
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>

		</table>
		</blockquote>
	</xsl:template>
	
	<xsl:template name="simpleContent">
		<xsl:for-each select="xs:simpleContent/xs:extension">
			<xsl:call-template name="attributes"/>
		</xsl:for-each>
		<xsl:if test="xs:simpleContent/xs:extension/@base">
		<blockquote>
		<table border="3" cellpadding="5" cellspacing="0" style="table-layout:fixed" width="88%">
			<colgroup span="2">
				<col width="200"/>
				<col width="*"/>
			</colgroup>
			<tr bgcolor="#FAFAFA">
				<td><b>Simple Content</b></td>
				<td><xsl:value-of select="xs:simpleContent/xs:extension/@base"/></td>
			</tr>
		</table>
		</blockquote>
		</xsl:if>
		<xsl:if test="xs:simpleContent/xs:restriction/xs:enumeration">
			<xsl:for-each select="xs:simpleContent">
				<xsl:call-template name="enumeration"/>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="pattern">
		<blockquote>
			<b>Pattern:  </b><xsl:value-of select="xs:restriction/xs:pattern/@value"/>
		</blockquote>
	</xsl:template>
	
	<xsl:template name="enumeration">
		<blockquote>
		<b>Enumeration:</b>
		<table bgcolor="#F9F9F9" border="1" cellpadding="5" cellspacing="0" style="table-layout:fixed" width="88%">
			<colgroup span="2">
				<col width="300"/>
				<col width="*"/>
			</colgroup>
			<tr bgcolor="#F0F0F0">
				<td><b>Value</b></td>
				<td><b>Description</b></td>
			</tr>
			
			<xsl:for-each select="xs:restriction/xs:enumeration">
			<xsl:element name="tr">
				
				<td valign="top">
					<xsl:value-of select="@value"/> 
				</td>
				<td>
					<xsl:for-each select="xs:annotation/xs:documentation">
						<xsl:value-of select="."/>
					</xsl:for-each>
				</td>
			</xsl:element>
			</xsl:for-each>
			
		</table>
		</blockquote>
	</xsl:template>

	<xsl:template name="evaluation_chart">
		<blockquote>
		<table align="center" bgcolor="#FCFCFC" border="5" cellpadding="5" cellspacing="0">
		<tr>
			<td><br/><pre><xsl:value-of select="."/></pre></td>
		</tr>
		</table>
		</blockquote>
	</xsl:template>

	<xsl:template name="example">
	    <blockquote>
	          <table bgcolor="#FCFCFC" border="2" cellpadding="5" cellspacing="0" width="88%">
	                <tr>
	                      <td>
	                            <b><xsl:text>Example:</xsl:text></b><br/>
	                            <xsl:value-of select="title"/>
	                            <hr width="100%"/>
	                            XML
	                      </td>
	                </tr>
	          </table>
	    </blockquote>
	</xsl:template>

	<xsl:template name="writeChildElmRow">
		<xsl:element name="tr">
			<td>
				<font size="-1">
					<xsl:choose>
						<xsl:when test="@name"><xsl:value-of select="@name"/></xsl:when>
						<xsl:when test="name()='xs:any'">xs:any</xsl:when>
					</xsl:choose>
				</font>
			</td>
			<td>
				<font size="-1">
					<xsl:choose>
						<xsl:when test="not(@type)">n/a</xsl:when>
						<xsl:otherwise><xsl:value-of select="@type"/></xsl:otherwise>
					</xsl:choose>
				</font>
			</td>
			<td>
				<font size="-1">
					<xsl:value-of select="xs:annotation/xs:documentation"/>
				</font>
			</td>
			<td align="center">
				<font size="-1">
					<xsl:choose>
						<xsl:when test="@minOccurs"><xsl:value-of select="@minOccurs"/></xsl:when>
						<xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
					</xsl:choose>
				</font>
			</td>
			<td align="center">
				<font size="-1">
					<xsl:choose>
						<xsl:when test="@maxOccurs"><xsl:value-of select="@maxOccurs"/></xsl:when>
						<xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
					</xsl:choose>
				</font>
			</td>
			
		</xsl:element>
		
	</xsl:template>
</xsl:stylesheet>