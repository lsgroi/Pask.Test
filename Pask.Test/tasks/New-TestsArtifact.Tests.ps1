$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "New-TestsArtifact" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "New-TestsArtifact"
        Install-NuGetPackage -Name Pask.Test
    }

    Context "Full tests artifact" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Clean, Build, New-TestsArtifact
        }

        It "creates the tests artifact directory" {
            Join-Path $TestSolutionFullPath ".build\output\Tests" | Should Exist
        }

        It "the artifact has all the test assemblies" {
            Join-Path $TestSolutionFullPath ".build\output\Tests\Tests\ClassLibrary.Tests\ClassLibrary.Tests.dll" | Should Exist
            Join-Path $TestSolutionFullPath ".build\output\Tests\Unit\ClassLibrary.UnitTests\ClassLibrary.UnitTests.dll" | Should Exist
            Join-Path $TestSolutionFullPath ".build\output\Tests\Integration\ClassLibrary.IntegrationTests\ClassLibrary.IntegrationTests.dll" | Should Exist
            Join-Path $TestSolutionFullPath ".build\output\Tests\Acceptance\ClassLibrary.AcceptanceTests\ClassLibrary.AcceptanceTests.dll" | Should Exist
        }
    }

    Context "Filtered tests artifact" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Clean, Build, New-TestsArtifact -TestNameArtifactPattern "\.AcceptanceTests"
        }

        It "creates the tests artifact directory" {
            Join-Path $TestSolutionFullPath ".build\output\Tests" | Should Exist
        }

        It "the artifact has all the test assemblies matching the filter" {
            Join-Path $TestSolutionFullPath ".build\output\Tests\Acceptance\ClassLibrary.AcceptanceTests\ClassLibrary.AcceptanceTests.dll" | Should Exist
            Get-ChildItem -Path (Join-Path $TestSolutionFullPath ".build\output\Tests") -Exclude "Acceptance" | Should BeNullOrEmpty
        }
    }
}