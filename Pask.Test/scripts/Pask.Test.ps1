<#
.SYNOPSIS 
   Gets the category of a test project

.PARAMETER Name <string>
   The project name

.OUTPUTS <string>
   The project category
#>
function script:Get-TestProjectCategory {
    param([Parameter(ValueFromPipeline=$true,Mandatory=$true)][string]$Name)

    if ($Name -notmatch '.*Tests?.*') {
        # The name does not contain Tests or Test
        return [string]::Empty 
    } elseif ($Name -match '\.Tests?$') {
        # The name ends by .Tests or .Test
        return $Name -split '\.' | Select -Last 1
    } elseif ($Name -match 'Tests?$') {
        # The name ends by Tests or Test
        return $Name -split '\.*Tests?$' -split '\.' | ? {$_} | Select -Last 1
    }
    
    return $Name -split '\.*Tests?(\.)*' -split '\.' | ? {$_} | Select -Last 1
}

<#
.SYNOPSIS 
   Gets all test projects in the solution matching a name pattern

.PARAMETER Pattern <string> = $TestNamePattern
   A regular expression pattern

.OUTPUTS <object[]>
   ------------------- EXAMPLE -------------------
   @(
      @{
         Name = 'Project.UnitTests'
         File = 'Project.UnitTests.csproj'
         Directory = 'C:\Solution_Dir\Project_Dir'
         Category = 'UnitTests'
      }
   )
#>
function script:Get-SolutionTestProjects {
    param([string]$Pattern = $TestNamePattern)

    Get-SolutionProjects `
        | Where { $_.Name -match $Pattern } `
        | Select Name, File, Directory, @{ Name="Category"; Expression={$_.Name | Get-TestProjectCategory} }
}

<#
.SYNOPSIS 
   Gets the assembly to run tests against

.PARAMETER TestFrameworkAssemblyName <string> = ""
   The name of the test framework assembly to be found within the assembly's directory

.OUTPUTS
    None
#>
function script:Get-TestAssemblies {
    param([string]$TestFrameworkAssemblyName = "")

    Import-Properties -Package Pask.Test

    if ($TestFromArtifact -and $TestFromArtifact -eq $true) {
        $Assemblies = Get-ChildItem -Path $TestsArtifactFullPath -Recurse -File -Include *.dll `
                        | Where { $_.BaseName -match $TestNamePattern } `
                        | Select -ExpandProperty FullName
    } else {
        Import-Script Properties.MSBuild -Package Pask
    
        $Assemblies = Get-SolutionTestProjects `
                            | Where { $_.Name -match $TestNamePattern } `
                            | Select -ExpandProperty Directory `
                            | Join-Path -ChildPath "bin" `
                            | Where { Test-Path $_ } `
                            | Get-ChildItem -Recurse -File -Include *.dll `
                            | Where {
                                ((Split-Path (Split-Path $_ -Parent) -Leaf) -eq $BuildConfiguration -or (Split-Path (Split-Path $_ -Parent) -Leaf) -eq "bin") `
                                -and $_.BaseName -match $TestNamePattern
                                } `
                            | Select -ExpandProperty FullName
    }

    if(-not $TestFrameworkAssemblyName) {
        return $Assemblies
    }

    return Get-ChildItem -Path $Assemblies `
            | Where { Test-Path (Join-Path (Split-Path $_.FullName) "$TestFrameworkAssemblyName.dll") } `
            | Select -ExpandProperty FullName
}