$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root = (Resolve-Path -LiteralPath '.artifacts/handover').Path
$html = [System.IO.File]::ReadAllText((Join-Path $root 'Asaan_Rishta_Developer_Handover.html'))
$stage = Join-Path $root 'docx_stage'
if (-not (Test-Path -LiteralPath $stage)) { New-Item -ItemType Directory -Path $stage | Out-Null }
foreach ($folder in @('_rels','word','docProps')) {
    $path = Join-Path $stage $folder
    if (-not (Test-Path -LiteralPath $path)) { New-Item -ItemType Directory -Path $path | Out-Null }
}
function Escape-Xml([string]$value) {
    if ([string]::IsNullOrEmpty($value)) { return '' }
    return [System.Security.SecurityElement]::Escape($value)
}
function Plain-Text([string]$fragment) {
    $fragment = [regex]::Replace($fragment, '(?is)<br\s*/?>', "`n")
    $fragment = [regex]::Replace($fragment, '(?is)<[^>]*>', '')
    return [System.Net.WebUtility]::HtmlDecode($fragment).Trim()
}
function Run-Xml([string]$value) {
    $lines = $value -split "`n"
    $items = foreach ($line in $lines) { '<w:t xml:space="preserve">' + (Escape-Xml $line) + '</w:t>' }
    return '<w:r>' + ($items -join '<w:br/>') + '</w:r>'
}
function Paragraph-Xml([string]$value,[string]$style) {
    $props = if ($style) { '<w:pPr><w:pStyle w:val="' + $style + '"/><w:keepNext/></w:pPr>' } else { '' }
    return '<w:p>' + $props + (Run-Xml $value) + '</w:p>'
}
function Table-Xml([string]$fragment) {
    $result = '<w:tbl><w:tblPr><w:tblW w:w="0" w:type="auto"/><w:tblBorders><w:top w:val="single" w:sz="4" w:color="C8D2DC"/><w:left w:val="single" w:sz="4" w:color="C8D2DC"/><w:bottom w:val="single" w:sz="4" w:color="C8D2DC"/><w:right w:val="single" w:sz="4" w:color="C8D2DC"/><w:insideH w:val="single" w:sz="4" w:color="C8D2DC"/><w:insideV w:val="single" w:sz="4" w:color="C8D2DC"/></w:tblBorders></w:tblPr>'
    foreach ($row in [regex]::Matches($fragment, '(?is)<tr[^>]*>(.*?)</tr>')) {
        $result += '<w:tr>'
        foreach ($cell in [regex]::Matches($row.Groups[1].Value, '(?is)<(th|td)[^>]*>(.*?)</\1>')) {
            $isHeader = $cell.Groups[1].Value -eq 'th'
            $shade = if ($isHeader) { '<w:shd w:fill="EAF0F5"/>' } else { '' }
            $result += '<w:tc><w:tcPr><w:tcW w:w="3000" w:type="dxa"/>' + $shade + '</w:tcPr>' + (Paragraph-Xml (Plain-Text $cell.Groups[2].Value) '') + '</w:tc>'
        }
        $result += '</w:tr>'
    }
    return $result + '</w:tbl>'
}
$body = New-Object System.Text.StringBuilder
foreach ($match in [regex]::Matches($html, '(?is)<(h1|h2|h3|p|li|table)[^>]*>(.*?)</\1>')) {
    $kind = $match.Groups[1].Value.ToLowerInvariant()
    $part = $match.Groups[2].Value
    if ($kind -eq 'table') { [void]$body.Append((Table-Xml $part)); continue }
    $value = Plain-Text $part
    if (-not $value) { continue }
    if ($kind -eq 'li') { $value = [char]0x2022 + ' ' + $value }
    $style = switch ($kind) { 'h1' {'Title'} 'h2' {'Heading1'} 'h3' {'Heading2'} default {''} }
    [void]$body.Append((Paragraph-Xml $value $style))
}
$documentXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>' + $body.ToString() + '<w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="900" w:right="900" w:bottom="900" w:left="900" w:header="450" w:footer="450" w:gutter="0"/></w:sectPr></w:body></w:document>'
$stylesXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Aptos" w:hAnsi="Aptos"/><w:sz w:val="20"/><w:color w:val="202A34"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="100" w:line="275" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults><w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/></w:style><w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:after="240"/><w:keepNext/></w:pPr><w:rPr><w:b/><w:color w:val="000000"/><w:sz w:val="46"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="260" w:after="120"/><w:keepNext/></w:pPr><w:rPr><w:b/><w:color w:val="173C5C"/><w:sz w:val="30"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="180" w:after="80"/><w:keepNext/></w:pPr><w:rPr><w:b/><w:color w:val="244F6C"/><w:sz w:val="22"/></w:rPr></w:style></w:styles>'
$contentTypes = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/><Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/><Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/><Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/></Types>'
$rels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/><Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/></Relationships>'
$wordRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/></Relationships>'
$core = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:title>Asaan Rishta Developer Handover Requirements</dc:title><dc:subject>Repository-based current-state specification</dc:subject></cp:coreProperties>'
$app = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"><Application>Microsoft Office Word</Application></Properties>'
$utf8 = New-Object System.Text.UTF8Encoding $false
@{
    '[Content_Types].xml' = $contentTypes
    '_rels/.rels' = $rels
    'word/document.xml' = $documentXml
    'word/styles.xml' = $stylesXml
    'word/_rels/document.xml.rels' = $wordRels
    'docProps/core.xml' = $core
    'docProps/app.xml' = $app
}.GetEnumerator() | ForEach-Object {
    $target = Join-Path $stage ($_.Key -replace '/', [IO.Path]::DirectorySeparatorChar)
    $parent = Split-Path -Parent $target
    if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
    [IO.File]::WriteAllText($target, $_.Value, $utf8)
}
$docx = Join-Path $root 'Asaan_Rishta_Developer_Handover.docx'
$stream = [IO.File]::Open($docx, [IO.FileMode]::Create)
try {
    $archive = New-Object IO.Compression.ZipArchive($stream, [IO.Compression.ZipArchiveMode]::Create, $false)
    try {
        foreach ($file in Get-ChildItem -LiteralPath $stage -File -Recurse) {
            $entryName = $file.FullName.Substring($stage.Length + 1).Replace('\', '/')
            [void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $file.FullName, $entryName)
        }
    } finally { $archive.Dispose() }
} finally { $stream.Dispose() }
Write-Output "DOCX: $docx"
Write-Output "Paragraphs: $([regex]::Matches($documentXml, '<w:p>').Count)"
