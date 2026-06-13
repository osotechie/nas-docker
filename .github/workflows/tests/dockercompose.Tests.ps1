#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

# Validates every docker-compose.yml in the repo by running
# `docker compose config -q` and checking the result is clean.
#
# A passing test means: exit code 0 AND no output on stdout/stderr.
# We deliberately check stderr too because docker emits WARN[0000]
# lines when a compose file references an env var that isn't defined
# in the stack's .env file. Tokenized placeholders like `#{DOMAIN}#`
# are valid values (they get substituted at deploy time), so they
# don't trigger warnings — only genuinely missing variables do.

$composeFiles = Get-ChildItem -Recurse -Filter 'docker-compose.yml' -File

Describe 'Docker Compose stack validation' {

    It 'Stack <_.Directory.Name> is valid' -ForEach $composeFiles {
        $composePath = $_.FullName

        $output = & docker compose -f $composePath config -q 2>&1
        $exitCode = $LASTEXITCODE
        $outputText = if ($output) { ($output | Out-String).Trim() } else { '' }

        $exitCode | Should -Be 0 -Because "docker compose exited $exitCode for $composePath`n--- output ---`n$outputText"
        $outputText | Should -BeNullOrEmpty -Because "docker compose produced output for $composePath`n--- output ---`n$outputText"
    }
}
