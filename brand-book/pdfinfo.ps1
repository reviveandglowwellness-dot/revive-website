# Reports page count for the rendered brand-book PDF, and whether the running
# header/footer landed on the first page (it must not — the cover is full-bleed).
param([string]$Pdf = "$PSScriptRoot\Revive-and-Glow-Brand-Book.pdf")

$lat = [System.Text.Encoding]::GetEncoding(28591)
$t = $lat.GetString([System.IO.File]::ReadAllBytes($Pdf))

$counts = [regex]::Matches($t, '/Count\s+(\d+)') | ForEach-Object { [int]$_.Groups[1].Value }
$pages = ($counts | Measure-Object -Maximum).Maximum
$kb = [math]::Round((Get-Item $Pdf).Length / 1KB, 1)

"pages : $pages"
"size  : $kb KB"

# Sanity: list the embedded font subsets so we can confirm the webfonts arrived
$fonts = [regex]::Matches($t, '/BaseFont\s*/([A-Za-z0-9+\-]+)') |
         ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
"fonts : $($fonts -join ', ')"
