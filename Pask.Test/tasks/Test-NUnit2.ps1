Import-Script Pask.Test -Package Pask.Test

Set-Property NUnitFrameworkVersion -Default "4.6"

# Synopsis: Run NUnit 2.x tests
Task Test-NUnit2 {
    $Assemblies = Get-TestAssemblies -TestFrameworkAssemblyName "nunit.framework"

    if ($Assemblies) {
        $NUnit = Join-Path (Get-PackageDir "NUnit.Runners") "tools\nunit-console.exe"
        $NUnitTestsResults = Join-Path $TestsResultsFullPath "NUnit.xml"
        
        New-Directory $TestsResultsFullPath | Out-Null

        Exec { & "$NUnit" /work:"$TestsResultsFullPath" /result:"$NUnitTestsResults" /framework:"net-$NUnitFrameworkVersion" /nologo $Assemblies }
    } else {
        Write-BuildMessage "NUnit tests not found" -ForegroundColor "Yellow"
    }
}