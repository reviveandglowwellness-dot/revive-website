# Visual QA helper. Assembles the shell plus only the parts you name into
# preview.html, so a single section can be screenshotted at a readable size
# instead of rendering the whole book.
#
#   powershell -File preview.ps1 03-part2a.html
#   powershell -File preview.ps1 03-part2a.html 04-part2b.html

param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Parts)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
# NB: not $parts — PowerShell variables are case-insensitive, so that would
# clobber the $Parts parameter.
$dir  = Join-Path $root 'parts'
$out  = Join-Path $root 'preview.html'

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine([System.IO.File]::ReadAllText((Join-Path $dir '00-shell.html')))
foreach ($p in $Parts) {
  $f = Join-Path $dir $p
  if (-not (Test-Path $f)) { throw "no such part: $p" }
  [void]$sb.AppendLine([System.IO.File]::ReadAllText($f))
}
[void]$sb.AppendLine('</body></html>')

[System.IO.File]::WriteAllText($out, $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
Write-Host "preview.html <- shell + $($Parts -join ', ')"
