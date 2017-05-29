Import-Script Pask.Test, Properties.xUnit -Package Pask.Test

# Synopsis: Run xUnit tests
Task Test-xUnit {
    $Assemblies = Get-TestAssemblies -TestFrameworkAssemblyName "xunit.core"

    if ($Assemblies) {
        $xUnit = Join-Path (Get-PackageDir "xunit.runner.console") "tools\xunit.console.exe"
        $xUnitTestResults = Join-Path $TestResultsFullPath "xUnit.xml"
        
        $Trait = @()
        if ($xUnitTrait) { 
            $xUnitTrait | ForEach { $Trait += @("-trait", $_) }
        }

        $NoTrait = @()
        if ($xUnitNoTrait) { 
            $xUnitNoTrait | ForEach { $NoTrait += @("-notrait", $_) }
        }

        if ($xUnitParallel) {
            $Parallel = @("-parallel", "$xUnitParallel")
        }

        if ($xUnitMaxThreads) {
            $MaxThreads = @("-maxthreads", "$xUnitMaxThreads")
        }

        New-Directory $TestResultsFullPath | Out-Null

        Exec { & "$xUnit" ("{0}" -f ($Assemblies -join "`" `"")) -xml "$xUnitTestResults" $Trait $NoTrait $Parallel $MaxThreads }
    } else {
        Write-BuildMessage "xUnit tests not found" -ForegroundColor "Yellow"
    }
}