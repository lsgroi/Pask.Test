$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Test-MSpec" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Test-MSpec"
        Install-NuGetPackage -Name Pask.Test
    }

    Context "Run all MSpec tests" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-MSpec
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml" | Should Exist
        }

        It "runs all the tests" {
            [xml]$Results = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml")
            $NumberOfTests = 0
            $Results.MSpec.assembly.concern | foreach { $_.context.specification | foreach { if ($_ -ne $null) { $NumberOfTests += 1 } } }
            $NumberOfTests | Should Be 4
        }
    }
}