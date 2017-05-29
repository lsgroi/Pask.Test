$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Test-VSTest" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Test-VSTest"
        Install-NuGetPackage -Name Pask.Test
    }

    Context "No tests" {
        BeforeAll {
            # Act
            Invoke-Pask (Join-Path $Here "NoTests") -Task Restore-NuGetPackages, Clean, Build, Test-VSTest
        }

        It "does not create the test report" {
            Join-Path $Here "NoTests\.build\output\TestResults\*.*" | Should Not Exist
        }
    }

    Context "All tests" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-VSTest
        }

        It "creates the test report" {
            Get-Item -Path (Join-Path $TestSolutionFullPath ".build\output\TestResults\*.trx") | Should Not BeNullOrEmpty
        }

        It "runs all the tests" {
            [xml]$TestResult = Get-Content -Path (Get-Item -Path (Join-Path $TestSolutionFullPath ".build\output\TestResults\*.trx")).FullName
            $TestResult.TestRun.ResultSummary.Counters.passed | Should Be 12
        }
    }

    Context "Tests filtered by category" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-VSTest -VSTestCaseFilterExpression "TestCategory=category1"
        }

        It "creates the test report" {
            Get-Item -Path (Join-Path $TestSolutionFullPath ".build\output\TestResults\*.trx") | Should Not BeNullOrEmpty
        }

        It "runs all the tests with the given category" {
            [xml]$TestResult = Get-Content -Path (Get-Item -Path (Join-Path $TestSolutionFullPath ".build\output\TestResults\*.trx")).FullName
            $TestResult.TestRun.ResultSummary.Counters.passed | Should Be 7 # MSpec adapter does not support tags
        }
    }

    Context "Tests run with custom settings file specifying a test results directory" {
        BeforeAll {
            # Arrange
            $TestResultsDirectory = Join-Path $TestDrive "TestResults"
            $SettingsValue = @"
<?xml version="1.0" encoding="utf-8"?>
<RunSettings>
   <RunConfiguration>
     <ResultsDirectory>{0}</ResultsDirectory>
   </RunConfiguration>
</RunSettings>
"@ -f $TestResultsDirectory
            $SettingsFile = New-Item -Path (Join-Path $TestDrive "custom.runsettings") -ItemType File -Value $SettingsValue

            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-VSTest -VSTestSettingsFile ("{0}" -f $SettingsFile.FullName)
        }

        It "does not create the test report in the default directory" {
            Get-Item -Path (Join-Path $TestSolutionFullPath ".build\output\TestResults\*.*") | Should BeNullOrEmpty
        }

        It "creates the test report in the custom directory" {
            Get-Item -Path (Join-Path $TestResultsDirectory "*.trx") | Should Not BeNullOrEmpty
        }

        It "runs all the tests" {
            [xml]$TestResult = Get-Content -Path (Get-Item -Path (Join-Path $TestResultsDirectory "*.trx")).FullName
            $TestResult.TestRun.ResultSummary.Counters.passed | Should Be 12
        }
    }
}