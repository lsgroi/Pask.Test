Import-Script Pask.Test, Properties.NUnit2 -Package Pask.Test

# Synopsis: Run NUnit 2.x tests
Task Test-NUnit2 {
    $Assemblies = Get-TestAssemblies -TestFrameworkAssemblyName "nunit.framework"

    if ($Assemblies) {
        $NUnit = Join-Path (Get-PackageDir "NUnit.Runners") "tools\nunit-console.exe"
        $NUnitTestResults = Join-Path $TestResultsFullPath "NUnit.xml"
        
        if ($NUnitCategory) { 
            $Include = "/include:$NUnitCategory"
        }

        if ($NUnitExcludeCategory) { 
            $Exclude = "/exclude:$NUnitExcludeCategory"
        }

        New-Directory $TestResultsFullPath | Out-Null

        Exec { & "$NUnit" /work:"$TestResultsFullPath" /result:"$NUnitTestResults" /framework:"net-$NUnitFrameworkVersion" $Include $Exclude /nologo $Assemblies }
    } else {
        Write-BuildMessage "NUnit tests not found" -ForegroundColor "Yellow"
    }
}