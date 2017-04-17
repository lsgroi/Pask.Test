Import-Script Pask.Tests.Infrastructure -Package Pask

# Synopsis: Test manually the package installation
Task Test-PackageInstallation Clean, Pack-Nuspec, Push-Local, {
    $Assertion = {
        $PaskVersion = (([xml](Get-Content (Join-Path $ProjectFullPath "Pask.Test.nuspec"))).package.metadata.dependencies.dependency | Where { $_.id -eq "Pask" }).version
        Assert ((([xml](Get-Content (Join-Path $SolutionFullPath "Application\packages.config"))).packages.package | Where { $_.id -eq "Pask" }).version -eq $PaskVersion) "Incorrect version of Pask installed into project 'Application'"
    }

    Test-PackageInstallation -Name Pask.Test -Assertion $Assertion -InstallationTargetInfo "Install into 'Application' project"
}