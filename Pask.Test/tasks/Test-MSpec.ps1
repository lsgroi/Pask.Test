Import-Script Pask.Test, Properties.MSpec -Package Pask.Test

# Synopsis: Run MSpec tests
Task Test-MSpec {
    $Assemblies = Get-TestAssemblies -TestFrameworkAssemblyName "Machine.Specifications"

    if ($Assemblies) {
        $MSpec = Join-Path (Get-PackageDir "Machine.Specifications.Runner.Console") "tools\mspec-clr4.exe"
        $MSpecTestResults = Join-Path $TestResultsFullPath "MSpec.xml"
        
        if ($MSpecTag) { 
            $Include = @("--include", $MSpecTag) 
        }

        if ($MSpecExcludeTag) { 
            $Exclude = @("--exclude", $MSpecExcludeTag)
        }

        New-Directory $TestResultsFullPath | Out-Null

        Exec { & "$MSpec" --xml "$MSpecTestResults" $Include $Exclude --progress $Assemblies }
    } else {
        Write-BuildMessage "MSpec tests not found" -ForegroundColor "Yellow"
    }
}