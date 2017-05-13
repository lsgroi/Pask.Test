$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "ZipExtract-TestsArtifact" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "ZipExtract-TestsArtifact"
        Install-NuGetPackage -Name Pask.Test
    }

    Context "Zip and extract a tests artifact" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Clean, Build, New-TestsArtifact, Zip-TestsArtifact, Extract-TestsArtifact
        }

        It "creates the zip artifact" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary.*.zip" | Should Exist
        }

        It "extracts the tests assemblies" {
            Join-Path $TestSolutionFullPath ".build\output\ClassLibrary.Tests\Unit\ClassLibrary.UnitTests\ClassLibrary.UnitTests.dll" | Should Exist
        }
    }

    Context "Extract a tests artifact with custom name" {
        BeforeAll {
            # Arrange
            Invoke-Pask $TestSolutionFullPath -Task Clean, Build, New-TestsArtifact, Zip-TestsArtifact
            Remove-PaskItem (Join-Path $TestSolutionFullPath ".build\output\ClassLibrary.Tests")
            $ZipArtifact = Get-ChildItem -Path (Join-Path $TestSolutionFullPath ".build\output\ClassLibrary.*.zip")
            Rename-Item -Path $ZipArtifact.FullName -NewName ($ZipArtifact.Name -replace "ClassLibrary.Tests", "NewClassLibrary.Tests")
            
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Extract-TestsArtifact -TestsArtifactName "NewClassLibrary.Tests"
        }

        It "extracts the tests assemblies" {
            Join-Path $TestSolutionFullPath ".build\output\NewClassLibrary.Tests\Unit\ClassLibrary.UnitTests\ClassLibrary.UnitTests.dll" | Should Exist
        }
    }
}