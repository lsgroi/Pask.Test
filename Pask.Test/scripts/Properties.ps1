Set-Property TestNamePattern -Default "Tests?$"
Set-Property TestNameArtifactPattern -Default { $TestNamePattern }
Set-Property TestsArtifactName -Default "Tests"
Set-Property TestsArtifactFullPath -Value { Join-Path $BuildOutputFullPath $TestsArtifactName }