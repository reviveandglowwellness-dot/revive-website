# Assembles the brand manual from parts/ into brand-book.html, then renders it
# to PDF with headless Chrome. Parts are concatenated in filename order, so the
# numeric prefixes control the book's sequence.
#
#   powershell -ExecutionPolicy Bypass -File build.ps1
#
# Chrome must be run with the Bash tool's sandbox disabled, otherwise the PDF
# write fails with "Access is denied".

$ErrorActionPreference = 'Stop'
$root  = Split-Path -Parent $MyInvocation.MyCommand.Path
$parts = Join-Path $root 'parts'
$html  = Join-Path $root 'brand-book.html'
$pdf   = Join-Path $root 'Revive-and-Glow-Brand-Book.pdf'

# Sort on the numeric prefix, not the whole filename. PowerShell's default
# Sort-Object is culture-aware and ignores punctuation, which put '05b-x.html'
# BEFORE '05-x.html' and silently reordered the book.
$files = Get-ChildItem -Path $parts -Filter '*.html' |
         Sort-Object @{ Expression = { [int]($_.Name -split '-', 2)[0] } }, Name
Write-Host "Assembling $($files.Count) parts:"
$files | ForEach-Object { Write-Host "  $($_.Name)" }

$sb = New-Object System.Text.StringBuilder
foreach ($f in $files) {
  [void]$sb.AppendLine("<!-- ===== $($f.Name) ===== -->")
  [void]$sb.AppendLine([System.IO.File]::ReadAllText($f.FullName))
}
[void]$sb.AppendLine('</body>')
[void]$sb.AppendLine('</html>')

[System.IO.File]::WriteAllText($html, $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
$kb = [math]::Round((Get-Item $html).Length / 1KB, 1)
Write-Host "`nWrote $html ($kb KB)"
Write-Host "Now render with:"
Write-Host "  chrome --headless --disable-gpu --no-sandbox --no-pdf-header-footer --virtual-time-budget=20000 --print-to-pdf=`"$pdf`" `"file:///$($html -replace '\\','/')`""
