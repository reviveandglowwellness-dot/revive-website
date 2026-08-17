$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$html = Join-Path $root 'highlight-nossa-historia.html'
$docx = Join-Path $root 'Revive-and-Glow-Highlight-Nossa-Historia.docx'
$pdf  = Join-Path $root 'Revive-and-Glow-Highlight-Nossa-Historia-QA.pdf'

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
$word.AutomationSecurity = 3

try {
    # Explicitly identify the source as a web page so Word does not wait on a
    # hidden file-conversion dialog during unattended generation.
    $doc = $word.Documents.OpenNoRepairDialog(
        $html, $false, $true, $false, '', '', $false, '', '', 7
    )
    $doc.SaveAs2($docx, 16)
    $doc.ExportAsFixedFormat($pdf, 17)
    $doc.Close($false)
}
finally {
    $word.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
}

Write-Host "Created: $docx"
Write-Host "QA PDF:  $pdf"
