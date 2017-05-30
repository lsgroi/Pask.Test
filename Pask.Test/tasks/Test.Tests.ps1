$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Test" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Test-VSTest"
        Install-NuGetPackage -Name Pask.Test
    }

    Context "No tests" {
        BeforeAll {
            # Act
            Invoke-Pask (Join-Path $Here "NoTests") -Task Restore-NuGetPackages, Clean, Build, Test
        }

        It "does not create any report" {
            Join-Path $Here "NoTests\.build\output\TestResults\*.*" | Should Not Exist
        }
    }

    Context "Tests without having built the solution" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Test
        }

        It "does not create any report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\*.*" | Should Not Exist
        }
    }

    Context "All tests" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test
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