Import-Script Pask.Test -Package Pask.Test

# Synopsis: Create the tests artifact by copying MSBuild output for each test found in the solution to the build output directory
Task New-TestsArtifact {
    New-Directory $BuildOutputFullPath | Out-Null

    $TestProjects = Get-SolutionTestProjects | Where { $_.Name -match $TestNameArtifactPattern }

    "Creating $TestsArtifactFullPath"
	foreach ($TestProject in $TestProjects) {
        $BuildOutputFullPath = Get-ProjectBuildOutputDir $TestProject.Name
        if (-not $BuildOutputFullPath -or -not (Test-Path $BuildOutputFullPath)) {
            Write-BuildMessage ("Cannot find build output for {0}" -f $TestProject.Name)  -ForegroundColor "Yellow"
        }
        $ArtifactFullPath = Join-Path (Join-Path $TestsArtifactFullPath $TestProject.Category) $TestProject.Name
        Exec { Robocopy "$BuildOutputFullPath" "$ArtifactFullPath" /256 /MIR /XO /NP /NFL /NDL /NJH /NJS } (0..7)
	}
}