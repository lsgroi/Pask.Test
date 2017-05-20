Import-Task Restore-NuGetPackages, Clean, Build, Test, New-TestsArtifact, Zip-TestsArtifact, TestFrom-TestsArtifact, TestFrom-TestsPackage

# Synopsis: Default task
Task . Restore-NuGetPackages, Clean, Build, Test, New-TestsArtifact