Import-Properties -Package Pask.Test

# Synopsis: Extract the tests artifact from a ZIP archive
Task Extract-TestsArtifact {
    # Find the ZIP archive
    $ZipArtifact = Get-ChildItem -Path (Join-Path $BuildOutputFullPath "$TestsArtifactName*.zip") | Select -Last 1

    Assert ($ZipArtifact -and (Test-Path $ZipArtifact)) "Cannot not find the ZIP tests artifact"

    $7za = Join-Path (Get-PackageDir "7-Zip.CommandLine") "tools\7za.exe"
	
    # Remove and re-create the artifact directory
    Remove-ItemSilently $TestsArtifactFullPath
    New-Directory $TestsArtifactFullPath | Out-Null
	
    "Extracting artifact {0}" -f $ZipArtifact.Name
    Exec { & "$7za" x ("{0}" -f $ZipArtifact.FullName) "-o$TestsArtifactFullPath" -r -y | Out-Null }
}