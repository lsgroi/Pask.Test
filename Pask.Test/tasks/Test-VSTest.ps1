Import-Script Pask.Test, Properties.VSTest -Package Pask.Test

# Synopsis: Run tests via VSTest.Console
Task Test-VSTest {
    $Assemblies = Get-TestAssemblies

    if ($Assemblies) {
        New-Directory $TestResultsFullPath | Out-Null
        Push-Location -Path $TestResultsFullPath

        try {
            if ($VSTestCaseFilterExpression) {
                $VSTestCaseFilterOption = "/TestCaseFilter:""{0}""" -f $VSTestCaseFilterExpression
            }

            if ($VSTestPlatform) {
                $VSTestPlatformOption = "/Platform:""{0}""" -f $VSTestPlatform
            }

            if ($VSTestFramework) {
                $VSTestFrameworkOption = "/Framework:""{0}""" -f $VSTestFramework
            }

            if ($VSTestCodeCoverage -eq $true) {
                $VSTestCodeCoverageOption = "/EnableCodeCoverage"
            }

            if ($VSTestSettingsFile -and (Test-Path $VSTestSettingsFile)) {
                $VSTestSettingsFileOption = "/Settings:""{0}""" -f $VSTestSettingsFile
            }

            Exec { & (Get-VSTest) $Assemblies /TestAdapterPath:"$(Get-PackagesDir)" /Parallel /Logger:"$VSTestLogger" $VSTestCaseFilterOption $VSTestPlatformOption $VSTestFrameworkOption $VSTestCodeCoverageOption $VSTestSettingsFileOption }
        } catch {
            throw $_
        } finally {
            if (Test-Path TestResults) {
                Move-Item -Path TestResults\* .
                Remove-PaskItem TestResults
            }
            Pop-Location
        }
    } else {
        Write-BuildMessage "Tests not found" -ForegroundColor "Yellow"
    }
}

function script:Get-VSTest {
    $VSWhere = Join-Path  (Get-PackageDir "vswhere") "tools\vswhere.exe"
    $VSVersionRange = "[{0}.0,{1}.0)" -f [int]$VSTestVersion, ([int]$VSTestVersion + 1)
    $VSPath = Exec { & $VSWhere -latest -products * -requires Microsoft.VisualStudio.PackageGroup.TestTools.Core -property installationPath -version $VSVersionRange }
    $VSTest = Join-Path $VSPath 'Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe'

    Assert (Test-Path $VSTest) "Cannot find vstest.console.exe"
    
    return $VSTest
}