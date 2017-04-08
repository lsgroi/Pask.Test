Import-Properties -Package Pask.Test

# Synopsis: Create an artifact of test projects in the form of ZIP archive
Task Zip-TestsArtifact {
    Assert ($TestsArtifactFullPath -and (Test-Path $TestsArtifactFullPath)) "Cannot not find tests artifact directory $TestsArtifactFullPath"

    $7za = Join-Path (Get-PackageDir "7-Zip.CommandLine") "tools\7za.exe"
	
    $ZipFile = Join-Path $BuildOutputFullPath ("{0}.{1}.zip" -f $TestsArtifactName, $Version.InformationalVersion)
	
    "Creating archive $ZipFile"
    Exec { & "$7za" u -tzip "$ZipFile" ("-ir!{0}" -f (Join-Path "$TestsArtifactFullPath" "*")) -mx9 | Out-Null }
}