$ErrorActionPreference = 'Stop'
$source = (Resolve-Path -LiteralPath '.artifacts/handover/Asaan_Rishta_Developer_Handover.html').Path
$targetDir = (Resolve-Path -LiteralPath '.artifacts/handover').Path
$docx = Join-Path $targetDir 'Asaan_Rishta_Developer_Handover.docx'
$pdf = Join-Path $targetDir 'Asaan_Rishta_Developer_Handover.pdf'
$word = $null
$document = $null
try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    $document = $word.Documents.Open($source, $false, $true)
    $document.SaveAs2($docx, 16)
    $document.ExportAsFixedFormat($pdf, 17)
    Write-Output "DOCX: $docx"
    Write-Output "PDF: $pdf"
    Write-Output "Pages: $($document.ComputeStatistics(2))"
}
finally {
    if ($document -ne $null) { $document.Close(0) }
    if ($word -ne $null) { $word.Quit(0) }
    if ($document -ne $null) { [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($document) }
    if ($word -ne $null) { [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) }
}
