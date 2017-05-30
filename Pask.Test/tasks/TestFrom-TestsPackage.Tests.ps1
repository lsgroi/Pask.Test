$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "TestFrom-TestsPackage" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Test-VSTest"
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

        It "creates the TRX test report" {
            Get-Item -Path (Join-Path $TestSolutionFullPath ".build\output\TestResults\*.trx") | Should Not BeNullOrEmpty
        }

        It "runs all the tests" {
            [xml]$TestResult = Get-Content -Path (Get-Item -Path (Join-Path $TestSolutionFullPath ".build\output\TestResults\*.trx")).FullName
            $TestResult.TestRun.ResultSummary.Counters.passed | Should Be 12
        }
    }
}