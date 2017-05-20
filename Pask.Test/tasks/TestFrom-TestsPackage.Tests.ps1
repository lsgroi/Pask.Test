$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "TestFrom-TestsPackage" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Test"
        Install-NuGetPackage -Name Pask.Test
    }

    Context "All tests" {
        BeforeAll {
            # Arrange
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, New-TestsArtifact, Zip-TestsArtifact
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary.UnitTests\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary.UnitTests\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.AcceptanceTests\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.AcceptanceTests\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.IntegrationTests\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.IntegrationTests\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath ".build\output\ClassLibrary.Tests")
            
            # Act
            Invoke-Pask $TestSolutionFullPath -Task TestFrom-TestsPackage
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml" | Should Exist
        }

        It "creates the NUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml" | Should Exist
        }

        It "runs all MSpec tests" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 4
        }

        It "runs all NUnit tests" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml")
            $NUnitResult.'test-run'.total | Should Be 4
        }
    }
}