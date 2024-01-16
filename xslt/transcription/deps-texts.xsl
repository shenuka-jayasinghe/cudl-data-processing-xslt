<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema"    xmlns:util="http://cudl.lib.cam.ac.uk/xtf/ns/util"
    exclude-result-prefixes="#all">
    
    <xsl:param name="deps_dir" as="xs:string*" required="yes" /><!-- Point to the output directory -->
    <xsl:param name="chunk_dir" as="xs:string*" required="no" />
    <xsl:param name="data_dir" as="xs:string*" required="no" />
    <xsl:param name="path_to_buildfile" as="xs:string*" required="no"/>
    
    <xsl:variable name="repo.root" select="string-join(tokenize(replace(document-uri(doc('deps-texts.xsl')),'^file:',''),'/')[position() lt (last() - 3) ],'/')"/>
    <xsl:variable name="clean_dest_dir" select="util:path-to-directory($deps_dir,$path_to_buildfile)"/>
    <xsl:variable name="clean_data_dir" select="util:path-to-directory($data_dir,$path_to_buildfile)"/>
    <xsl:variable name="clean_chunk_dir" select="util:path-to-directory($chunk_dir,$path_to_buildfile)"/>
    
    <xsl:key name="pb-by-facs" match="tei:pb" use="for $x in tokenize(normalize-space(@facs),'\s+') return replace($x,'^#','')"/>
    
    <xsl:template match="/*">
        <xsl:variable name="root_filename" select="replace(tokenize(document-uri(root(/)), '/')[position() eq last()],'\.xml$', '')" as="xs:string"/>
        <xsl:variable name="subpath" select="replace(string-join(tokenize(replace(document-uri(root(/)), concat($clean_data_dir,'/'), ''), '/')[position() lt last()],'/'), '^file:', '')"/>
        <xsl:message select="$root_filename"/>
        <xsl:message select="$clean_data_dir"/>
        <xsl:message select="$clean_chunk_dir"/>
        <xsl:message select="$subpath"></xsl:message>
        <xsl:message select="concat($clean_chunk_dir,'/', $subpath, '?select=*.xml;on-error=ignore')"></xsl:message>
        <xsl:result-document method="xml" encoding="UTF-8" indent="yes" href="{concat($clean_dest_dir,'/', $root_filename, '/texts.xml')}">
            <facsimile xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:try>
                    <xsl:for-each select="collection(concat($clean_chunk_dir,'/', $subpath, '?select=*.xml;on-error=ignore'))//tei:surface[normalize-space(@xml:id)]">
                        <!--<xsl:sort select="number(replace(@xml:id,'\D+',''))"/>-->
                        <xsl:variable name="surfaceID" select="@xml:id" as="xs:string*"/>
                        <xsl:for-each select="key('pb-by-facs',@xml:id)">
                            <!--<xsl:sort select="ancestor::tei:div[@type='translation']/@type"/>-->
                            <xsl:variable name="type_val" select="(ancestor::tei:div[@type='translation']/normalize-space(@type), 'transcription')[1]"/>
                            <surface nid="{$surfaceID}" type="{$type_val}" xmlns:tei="http://www.tei-c.org/ns/1.0"/>
                        </xsl:for-each>
                    </xsl:for-each>
                    <xsl:catch/>
                </xsl:try>
            </facsimile>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:function name="util:path-to-directory" as="xs:string">
        <xsl:param name="dir"/>
        <xsl:param name="build_dir"/>
        
        <xsl:variable name="directory" select="replace(normalize-space($dir),'/$','')"/>
        
        <xsl:choose>
            <xsl:when test="normalize-space($build_dir) !=''">
                <xsl:choose>
                    <xsl:when test="$directory != ''">
                        <xsl:choose>
                            <xsl:when test="matches($directory,'^/')">
                                <!-- directory is absolute path -->
                                <xsl:value-of select="$directory"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- Directory is set in build file and relative to build file -->
                                <xsl:value-of select="replace(resolve-uri(concat(normalize-space($build_dir),'/',$directory)),'^file:','')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$directory"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>