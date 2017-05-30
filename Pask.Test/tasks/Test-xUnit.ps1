Import-Script Pask.Test, Properties.xUnit -Package Pask.Test

# Synopsis: Run xUnit tests
Task Test-xUnit {
    $Assemblies = Get-TestAssemblies -TestFrameworkAssemblyName "xunit.core"

    if ($Assemblies) {
        $xUnit = Join-Path (Get-PackageDir "xunit.runner.console") "tools\xunit.console.exe"
        $xUnitTestResults = Join-Path $TestResultsFullPath "xUnit.xml"
        
        $Assemblies | ForEach { [System.Array]$AssemblyFiles += '"' + $_ + '"' }

        if ($xUnitTrait) { 
            $xUnitTrait | ForEach { [System.Array]$Trait += @("-trait", $_) }
        }

        if ($xUnitNoTrait) { 
            $xUnitNoTrait | ForEach { [System.Array]$NoTrait += @("-notrait", $_) }
        }

        if ($xUnitParallel) {
            $Parallel = @("-parallel", "$xUnitParallel")
        }

        if ($xUnitMaxThreads) {
            $MaxThreads = @("-maxthreads", "$xUnitMaxThreads")
        }

        New-Directory $TestResultsFullPath | Out-Null

        Exec { & "$xUnit" $AssemblyFiles -xml "$xUnitTestResults" $Trait $NoTrait $Parallel $MaxThreads }
    } else {
        Write-BuildMessage "xUnit tests not found" -ForegroundColor "Yellow"
    }
}