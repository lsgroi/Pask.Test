Set-Property TestNamePattern -Default "Tests?$"
Set-Property TestNameArtifactPattern -Default { $TestNamePattern }
Set-Property TestsArtifactName -Default { "{0}.Tests" -f $ProjectName }
Set-Property TestsArtifactFullPath -Value { Join-Path $BuildOutputFullPath $TestsArtifactName }