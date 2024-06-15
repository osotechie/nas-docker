$TestCases = Get-ChildItem -Recurse -Filter 'docker-compose.yml'

Describe 'Validate Docker Stack' {

    It " <_.Directory.Name> - should have a valid <_.Name>" -ForEach $TestCases {
        try {
            Invoke-Expression "docker compose -f '$($_.fullName)' config -q 2>tmp.dockercompose.log"
            $result = Get-Content "tmp.dockercompose.log"
            
            # Check result is empty, if not we have an error
            $result | Should -BeNullOrEmpt
        }
        Catch
        {
            $errorMessage = $_.Exception.Message
            Write-Host "Error validating $($_.FullName): $errorMessage"
            throw $_.Exception
        }
        
    }
}
