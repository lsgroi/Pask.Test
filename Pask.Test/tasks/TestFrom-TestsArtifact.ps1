Import-Task Test

# Synopsis: Run all automated tests from a tests artifact
Task TestFrom-TestsArtifact {
    Set-Property TestFromArtifact -Value $true
}, Test