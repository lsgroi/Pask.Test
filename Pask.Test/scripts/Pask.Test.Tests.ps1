$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace "\.Tests\.", "."
. "$Here\$Sut"

Describe "Get-TestProjectCategory" {
    Context "Test name MyCompany.MyProject.Core" {
        It "returns empty type" {
            Get-TestProjectCategory "MyCompany.MyProject.Core" | Should Be ""
        }
    }

    Context "Test name MyCompany.MyProject.Test" {
        It "returns Test" {
            Get-TestProjectCategory "MyCompany.MyProject.Test" | Should Be "Test"
        }
    }

    Context "Test name MyCompany.MyProject.Tests (from pipeline)" {
        It "returns Tests" {
            "MyCompany.MyProject.Tests" | Get-TestProjectCategory | Should Be "Tests"
        }
    }

    Context "Test name MyCompany.MyProject.IntegrationTests (from pipeline)" {
        It "returns IntegrationTests" {
            "MyCompany.MyProject.IntegrationTests" | Get-TestProjectCategory | Should Be "Integration"
        }
    }

    Context "Test name MyCompany.MyProject.Test.Acceptance" {
        It "returns Acceptance" {
            Get-TestProjectCategory "MyCompany.MyProject.Test.Acceptance" | Should Be "Acceptance"
        }
    }

    Context "Test name MyCompany.MyProject.Tests.Unit" {
        It "returns Unit" {
            Get-TestProjectCategory "MyCompany.MyProject.Tests.Unit" | Should Be "Unit"
        }
    }
}

Describe "Get-SolutionTestProjects" {
    Context "Using the default test name pattern, solution with two test projects and a solution folder" {
        BeforeAll {
            ## Arrange
            . (Join-Path $BuildFullPath "scripts\Pask.ps1")
            Mock Get-SolutionProjects { 
                    $Result = @()
                    $Result += New-Object PSObject -Property @{ Name = "PowerShellProject"; File = "ScriptsProject.pssproj"; Directory = (Join-Path $TestDrive "PowerShell") }
                    $Result += New-Object PSObject -Property @{ Name = "Project"; File = "Project.csproj"; Directory = (Join-Path $TestDrive "Project") }
                    $Result += New-Object PSObject -Property @{ Name = "Project.UnitTests"; File = "Project.UnitTests.csproj"; Directory = (Join-Path $TestDrive "Tests\Unit") } 
                    $Result += New-Object PSObject -Property @{ Name = "Project.IntegrationTests"; File = "Project.IntegrationTests.csproj"; Directory = (Join-Path $TestDrive "Tests\Integration") }
                    return $Result
                }

            # Act
            $Result = Get-SolutionTestProjects
        }

        It "gets two projects" {
            $Result.Count | Should Be 2
        }

        It "gets the first test project name" {
            $Result[0].Name | Should Be "Project.UnitTests"
        }

        It "gets the first test project file" {
            $Result[0].File | Should Be "Project.UnitTests.csproj"
        }

        It "gets the first test project directory" {
            $Result[0].Directory | Should Be (Join-Path $TestDrive "Tests\Unit")
        }

        It "gets the first test project category" {
            $Result[0].category | Should Be "Unit"
        }

        It "gets the second test project name" {
            $Result[1].Name | Should Be "Project.IntegrationTests"
        }

        It "gets the second test project file" {
            $Result[1].File | Should Be "Project.IntegrationTests.csproj"
        }

        It "gets the second test project directory" {
            $Result[1].Directory | Should Be (Join-Path $TestDrive "Tests\Integration")
        }

        It "gets the second test project category" {
            $Result[1].Category | Should Be "Integration"
        }
    }
}
