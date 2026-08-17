$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$source = Join-Path $root 'highlight-nossa-historia.html'
$output = Join-Path $root 'Revive-and-Glow-Highlight-Nossa-Historia.docx'
$stage = Join-Path $root '_docx_stage'
$zip = Join-Path $root '_docx_stage.zip'

if (Test-Path $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
if (Test-Path $zip) { Remove-Item -LiteralPath $zip -Force }
if (Test-Path $output) { Remove-Item -LiteralPath $output -Force }

New-Item -ItemType Directory -Path $stage, (Join-Path $stage '_rels'), (Join-Path $stage 'word'), (Join-Path $stage 'word\_rels'), (Join-Path $stage 'docProps') | Out-Null

function Escape-Xml([string]$value) {
    return [System.Security.SecurityElement]::Escape($value)
}

function Strip-Html([string]$value) {
    $text = [regex]::Replace($value, '<br\s*/?>', "`n", 'IgnoreCase')
    $text = [regex]::Replace($text, '<[^>]+>', '')
    return [System.Net.WebUtility]::HtmlDecode($text).Trim()
}

function Para-Xml([string]$text, [string]$style = 'Normal', [bool]$pageBreak = $false) {
    if ([string]::IsNullOrWhiteSpace($text)) { return '' }
    $pPr = "<w:pStyle w:val=`"$style`"/>"
    if ($pageBreak) { $pPr += '<w:pageBreakBefore/>' }
    $runs = New-Object System.Text.StringBuilder
    $lines = $text -split "`r?`n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($i -gt 0) { [void]$runs.Append('<w:r><w:br/></w:r>') }
        $safe = Escape-Xml $lines[$i]
        [void]$runs.Append("<w:r><w:t xml:space=`"preserve`">$safe</w:t></w:r>")
    }
    return "<w:p><w:pPr>$pPr</w:pPr>$runs</w:p>"
}

$html = [System.IO.File]::ReadAllText($source, [System.Text.Encoding]::UTF8)
$pattern = '(?is)<(h1|h2|h3|p|li)\b([^>]*)>(.*?)</\1>|<div\s+class="(eyebrow|subtitle|story-head|screen|prompt)"[^>]*>(.*?)</div>'
$matches = [regex]::Matches($html, $pattern)
$body = New-Object System.Text.StringBuilder
$seenFirstH2 = $false

foreach ($m in $matches) {
    if ($m.Groups[1].Success) {
        $tag = $m.Groups[1].Value.ToLowerInvariant()
        $attrs = $m.Groups[2].Value
        $text = Strip-Html $m.Groups[3].Value
        if (-not $text) { continue }

        switch ($tag) {
            'h1' { [void]$body.Append((Para-Xml $text 'Title')) }
            'h2' {
                $break = $seenFirstH2
                [void]$body.Append((Para-Xml $text 'Heading1' $break))
                $seenFirstH2 = $true
            }
            'h3' { [void]$body.Append((Para-Xml $text 'Heading2')) }
            'li' { [void]$body.Append((Para-Xml $text 'ListBullet')) }
            'p' {
                $style = if ($attrs -match 'class="lead"') { 'Lead' } elseif ($attrs -match 'class="small"') { 'Small' } else { 'Normal' }
                [void]$body.Append((Para-Xml $text $style))
            }
        }
    }
    else {
        $class = $m.Groups[4].Value
        $text = Strip-Html $m.Groups[5].Value
        if (-not $text) { continue }
        $style = switch ($class) {
            'eyebrow' { 'Kicker' }
            'subtitle' { 'Subtitle' }
            'story-head' { 'StoryHead' }
            'screen' { 'StoryText' }
            'prompt' { 'Prompt' }
        }
        [void]$body.Append((Para-Xml $text $style))
    }
}

$document = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    $body
    <w:sectPr>
      <w:pgSz w:w="12240" w:h="15840"/>
      <w:pgMar w:top="1152" w:right="1123" w:bottom="1080" w:left="1123" w:header="708" w:footer="708"/>
      <w:cols w:space="720"/>
      <w:docGrid w:linePitch="360"/>
    </w:sectPr>
  </w:body>
</w:document>
"@

$styles = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/><w:sz w:val="21"/><w:color w:val="1B241E"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="120" w:line="290" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:after="120" w:line="290" w:lineRule="auto"/></w:pPr><w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/><w:sz w:val="21"/><w:color w:val="1B241E"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:next w:val="Subtitle"/><w:qFormat/><w:pPr><w:jc w:val="center"/><w:spacing w:before="1800" w:after="120"/></w:pPr><w:rPr><w:rFonts w:ascii="Georgia" w:hAnsi="Georgia"/><w:sz w:val="64"/><w:color w:val="223A2E"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Subtitle"><w:name w:val="Subtitle"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:jc w:val="center"/><w:spacing w:after="520"/></w:pPr><w:rPr><w:rFonts w:ascii="Georgia" w:hAnsi="Georgia"/><w:i/><w:sz w:val="30"/><w:color w:val="5B4636"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Kicker"><w:name w:val="Kicker"/><w:basedOn w:val="Normal"/><w:pPr><w:jc w:val="center"/><w:spacing w:before="180" w:after="80"/></w:pPr><w:rPr><w:b/><w:caps/><w:spacing w:val="30"/><w:sz w:val="16"/><w:color w:val="B9863F"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:qFormat/><w:keepNext/><w:pPr><w:spacing w:before="200" w:after="180"/><w:pBdr><w:bottom w:val="single" w:sz="8" w:space="6" w:color="B9863F"/></w:pBdr></w:pPr><w:rPr><w:rFonts w:ascii="Georgia" w:hAnsi="Georgia"/><w:sz w:val="44"/><w:color w:val="223A2E"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:qFormat/><w:keepNext/><w:pPr><w:spacing w:before="240" w:after="90"/></w:pPr><w:rPr><w:rFonts w:ascii="Georgia" w:hAnsi="Georgia"/><w:b/><w:sz w:val="28"/><w:color w:val="223A2E"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Lead"><w:name w:val="Lead"/><w:basedOn w:val="Normal"/><w:pPr><w:ind w:left="240" w:right="240"/><w:spacing w:before="100" w:after="200" w:line="320" w:lineRule="auto"/><w:shd w:val="clear" w:color="auto" w:fill="F7F1E7"/><w:pBdr><w:left w:val="single" w:sz="20" w:space="8" w:color="B9863F"/></w:pBdr></w:pPr><w:rPr><w:rFonts w:ascii="Georgia" w:hAnsi="Georgia"/><w:i/><w:sz w:val="25"/><w:color w:val="5B4636"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="StoryHead"><w:name w:val="Story Head"/><w:basedOn w:val="Normal"/><w:next w:val="StoryText"/><w:keepNext/><w:pPr><w:spacing w:before="220" w:after="0"/><w:shd w:val="clear" w:color="auto" w:fill="223A2E"/><w:ind w:left="160" w:right="160"/></w:pPr><w:rPr><w:b/><w:sz w:val="20"/><w:color w:val="F1EADB"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="StoryText"><w:name w:val="Story Text"/><w:basedOn w:val="Normal"/><w:pPr><w:ind w:left="220" w:right="220"/><w:spacing w:before="0" w:after="160" w:line="310" w:lineRule="auto"/><w:shd w:val="clear" w:color="auto" w:fill="FCFAF5"/><w:pBdr><w:left w:val="single" w:sz="18" w:space="8" w:color="7D9A86"/></w:pBdr></w:pPr><w:rPr><w:rFonts w:ascii="Georgia" w:hAnsi="Georgia"/><w:sz w:val="26"/><w:color w:val="223A2E"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Prompt"><w:name w:val="Prompt"/><w:basedOn w:val="Normal"/><w:pPr><w:ind w:left="160" w:right="160"/><w:spacing w:before="80" w:after="180" w:line="270" w:lineRule="auto"/><w:shd w:val="clear" w:color="auto" w:fill="F3F4F2"/></w:pPr><w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/><w:sz w:val="17"/><w:color w:val="1B241E"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="Small"><w:name w:val="Small"/><w:basedOn w:val="Normal"/><w:rPr><w:sz w:val="18"/><w:color w:val="5C6B60"/></w:rPr></w:style>
  <w:style w:type="paragraph" w:styleId="ListBullet"><w:name w:val="List Bullet"/><w:basedOn w:val="Normal"/><w:pPr><w:numPr><w:ilvl w:val="0"/><w:numId w:val="1"/></w:numPr><w:spacing w:after="80"/></w:pPr></w:style>
</w:styles>
'@

$numbering = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:numbering xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:abstractNum w:abstractNumId="0"><w:multiLevelType w:val="hybridMultilevel"/>
    <w:lvl w:ilvl="0"><w:start w:val="1"/><w:numFmt w:val="bullet"/><w:lvlText w:val="•"/><w:lvlJc w:val="left"/><w:pPr><w:tabs><w:tab w:val="num" w:pos="540"/></w:tabs><w:ind w:left="540" w:hanging="260"/></w:pPr><w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/></w:rPr></w:lvl>
  </w:abstractNum>
  <w:num w:numId="1"><w:abstractNumId w:val="0"/></w:num>
</w:numbering>
'@

$contentTypes = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/word/numbering.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
</Types>
'@

$rootRels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>
'@

$docRels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering" Target="numbering.xml"/>
</Relationships>
'@

$core = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>Highlight Nossa História - Revive &amp; Glow Wellness</dc:title>
  <dc:subject>Roteiro de Instagram Stories</dc:subject>
  <dc:creator>Revive &amp; Glow Wellness</dc:creator>
  <cp:keywords>Instagram; Stories; Highlight; Marca</cp:keywords>
</cp:coreProperties>
'@

$app = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes"><Application>Microsoft Office Word</Application></Properties>
'@

$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Join-Path $stage '[Content_Types].xml'), $contentTypes, $utf8)
[System.IO.File]::WriteAllText((Join-Path $stage '_rels\.rels'), $rootRels, $utf8)
[System.IO.File]::WriteAllText((Join-Path $stage 'word\document.xml'), $document, $utf8)
[System.IO.File]::WriteAllText((Join-Path $stage 'word\styles.xml'), $styles, $utf8)
[System.IO.File]::WriteAllText((Join-Path $stage 'word\numbering.xml'), $numbering, $utf8)
[System.IO.File]::WriteAllText((Join-Path $stage 'word\_rels\document.xml.rels'), $docRels, $utf8)
[System.IO.File]::WriteAllText((Join-Path $stage 'docProps\core.xml'), $core, $utf8)
[System.IO.File]::WriteAllText((Join-Path $stage 'docProps\app.xml'), $app, $utf8)

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$stream = [System.IO.File]::Open($output, [System.IO.FileMode]::CreateNew)
$archive = New-Object System.IO.Compression.ZipArchive(
    $stream, [System.IO.Compression.ZipArchiveMode]::Create, $false
)
try {
    Get-ChildItem -LiteralPath $stage -Recurse -File | ForEach-Object {
        $relative = $_.FullName.Substring($stage.Length + 1).Replace('\', '/')
        $entry = $archive.CreateEntry($relative, [System.IO.Compression.CompressionLevel]::Optimal)
        $entryStream = $entry.Open()
        try {
            $fileStream = [System.IO.File]::OpenRead($_.FullName)
            try { $fileStream.CopyTo($entryStream) } finally { $fileStream.Dispose() }
        }
        finally { $entryStream.Dispose() }
    }
}
finally {
    $archive.Dispose()
    $stream.Dispose()
}

Write-Host "Created: $output"
Write-Host "Source blocks: $([regex]::Matches($html, $pattern).Count)"
