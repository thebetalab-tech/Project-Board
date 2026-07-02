$content = Get-Content 'd:\E\PROJECTS 2\Project Board\PromptBook.txt' -Raw
$idx = $content.IndexOf('5.3  Common Refinements')
if ($idx -ge 0) {
    $content.Substring($idx) | Out-File 'd:\E\PROJECTS 2\Project Board\tail.txt' -Encoding UTF8
    Write-Host "Extracted tail content"
} else {
    Write-Host "Pattern not found"
}
