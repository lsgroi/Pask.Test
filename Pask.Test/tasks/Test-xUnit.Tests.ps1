$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Test-xUnit" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Test-xUnit"
        Install-NuGetPackage -Name Pask.Test
    }

    Context "No tests" {
        BeforeAll {
            # Act
            Invoke-Pask (Join-Path $Here "NoTests") -Task Restore-NuGetPackages, Clean, Build, Test-xUnit
        }

        It "does not create the xUnit XML report" {
            Join-Path $Here "NoTests\.build\output\TestResults\xUnit.xml" | Should Not Exist
        }
    }

    Context "All tests" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-xUnit
        }

        It "creates the xUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml" | Should Exist
        }

        It "runs all the tests" {
            [xml]$xUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml")
            ($xUnitResult.assemblies.assembly.total | Measure -Sum).Sum | Should Be 4
            $xUnitResult.assemblies.assembly.collection.test.method | Sort | Should Be @('Test_1', 'Test_2', 'Test_3', 'Test_4')
        }
    }

    Context "Tests with traits" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-xUnit -xUnitTrait @( "category=category1", "category=category2" )
        }

        It "creates the xUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml" | Should Exist
        }

        It "runs all the tests with the given traits" {
            [xml]$xUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml")
            ($xUnitResult.assemblies.assembly.total | Measure -Sum).Sum | Should Be 3
            $xUnitResult.assemblies.assembly.collection.test.method | Sort | Should Be @('Test_1', 'Test_2', 'Test_4')
        }
    }

    Context "Tests without traits" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-xUnit -xUnitNoTrait @( "category=category1", "category=category2" )
        }

        It "creates the xUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml" | Should Exist
        }

        It "runs all the tests without the given traits" {
            [xml]$xUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml")
            ($xUnitResult.assemblies.assembly.total | Measure -Sum).Sum | Should Be 1
            $xUnitResult.assemblies.assembly.collection.test.method | Sort | Should Be 'Test_3'
        }
    }
}