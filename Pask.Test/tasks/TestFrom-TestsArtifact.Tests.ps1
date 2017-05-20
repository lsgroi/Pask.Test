$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "TestFrom-TestsArtifact" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Test"
        Install-NuGetPackage -Name Pask.Test
    }

    Context "No tests" {
        BeforeAll {
            # Arrange
            Invoke-Pask (Join-Path $Here "NoTests") -Task Restore-NuGetPackages, Clean, Build, New-TestsArtifact
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary.UnitTests\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary.UnitTests\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.AcceptanceTests\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.AcceptanceTests\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.IntegrationTests\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.IntegrationTests\obj")

            # Act
            Invoke-Pask (Join-Path $Here "NoTests") -Task TestFrom-TestsArtifact
        }

        It "does not create any report" {
            Join-Path $Here "NoTests\.build\output\TestResults\*.*" | Should Not Exist
        }
    }

    Context "All tests from tests artifact" {
        BeforeAll {
            # Arrange
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, New-TestsArtifact
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary.UnitTests\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary.UnitTests\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.AcceptanceTests\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.AcceptanceTests\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.IntegrationTests\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.IntegrationTests\obj")
            
            # Act
            Invoke-Pask $TestSolutionFullPath -Task TestFrom-TestsArtifact
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

    Context "Filtered tests from tests artifact" {
        BeforeAll {
            # Arrange
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, New-TestsArtifact
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary.UnitTests\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary.UnitTests\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.AcceptanceTests\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.AcceptanceTests\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.IntegrationTests\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.IntegrationTests\obj")
            
            # Act
            Invoke-Pask $TestSolutionFullPath -Task TestFrom-TestsArtifact -TestNamePattern "UnitTests?$"
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml" | Should Exist
        }

        It "creates the NUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml" | Should Exist
        }

        It "runs the MSpec tests" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 3
        }

        It "runs the NUnit tests" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml")
            $NUnitResult.'test-run'.total | Should Be 2
        }
    }
}