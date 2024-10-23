# Set the working directory
$workingDir = "G:\My Drive\Medical\barmenia\Einreichungen"
Set-Location -Path $workingDir

# CSV file to save extracted data
$csvFile = "$workingDir\extracted_data.csv"

# Create CSV header if the file doesn't exist
if (-not (Test-Path $csvFile)) {
    "FileName,ExtractedText" | Out-File -FilePath $csvFile
}

# Function to extract the first page of a PDF and save the text to CSV
function Extract-FirstPage-Text {
    param (
        [string]$pdfFile
    )

    # Use PDF24 command-line to extract the first page to a temporary file (assumes pdf24-cli.exe exists)
    $firstPagePdf = "$workingDir\first_page.pdf"
    & "C:\Program Files\PDF24\pdf24.exe" extract-pages -from 1 -to 1 -source $pdfFile -target $firstPagePdf

    # Extract text from the first page (using PDF24 or another utility like pdftotext if necessary)
    $extractedText = & "C:\Program Files\PDF24\pdf24.exe" extract-text -source $firstPagePdf

    # Save the extracted text to the CSV file
    "$pdfFile,$extractedText" | Out-File -Append -FilePath $csvFile

    # Delete the temporary first page file
    Remove-Item -Path $firstPagePdf
}

# Function to remove the first page of the PDF and save the result with _done.pdf
function Remove-FirstPage-And-Save {
    param (
        [string]$pdfFile
    )

    # Create new file name with _done.pdf
    $newFile = [System.IO.Path]::ChangeExtension($pdfFile, "_done.pdf")

    # Use PDF24 command-line to delete the first page and save the rest
    & "C:\Program Files\PDF24\pdf24.exe" delete-pages -from 1 -to 1 -source $pdfFile -target $newFile

    # Optionally, delete the original file (uncomment if needed)
    # Remove-Item -Path $pdfFile
}

# Process all PDFs in the directory
Get-ChildItem -Path $workingDir -Filter *.pdf | ForEach-Object {
    $pdfFile = $_.FullName
    Extract-FirstPage-Text -pdfFile $pdfFile
    Remove-FirstPage-And-Save -pdfFile $pdfFile
}

Write-Host "Processing complete."
