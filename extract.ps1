$word = New-Object -ComObject Word.Application
$word.Visible = $false

$doc1 = $word.Documents.Open("d:\E\PROJECTS 2\Project Board\Project Board Files.docx")
$doc1.Content.Text | Out-File -FilePath "d:\E\PROJECTS 2\Project Board\ProjectBoardFiles.txt" -Encoding UTF8
$doc1.Close()

$doc2 = $word.Documents.Open("d:\E\PROJECTS 2\Project Board\Prompt Book.docx")
$doc2.Content.Text | Out-File -FilePath "d:\E\PROJECTS 2\Project Board\PromptBook.txt" -Encoding UTF8
$doc2.Close()

$word.Quit()
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
Write-Host "Done extracting both documents."
