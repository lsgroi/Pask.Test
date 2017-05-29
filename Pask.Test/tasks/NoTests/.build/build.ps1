Import-Task Restore-NuGetPackages, Clean, Build, Test, Test-NUnit2, Test-xUnit, Test-VSTest, New-TestsArtifact, TestFrom-TestsArtifact

# Synopsis: Default task
Task . Restore-NuGetPackages, Clean, Build, Test