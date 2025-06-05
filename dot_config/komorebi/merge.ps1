param (
    [Parameter(Mandatory=$true)]
    [string]$FirstJsonFile,

    [Parameter(Mandatory=$true)]
    [string]$SecondJsonFile,

    [Parameter(Mandatory=$true)]
    [string]$OutputFile
)

# Read and convert JSON files to hashtables
$first  = Get-Content $FirstJsonFile -Raw | ConvertFrom-Json -AsHashtable
$second = Get-Content $SecondJsonFile -Raw | ConvertFrom-Json -AsHashtable

# Create a new hashtable for the merged result
$merged = @{}

# Add all keys from the second file first
foreach ($key in $second.Keys) {
    $merged[$key] = $second[$key]
}

# Overwrite/add all keys from the first file (no recursion)
foreach ($key in $first.Keys) {
    $merged[$key] = $first[$key]
}

# Convert to JSON string
$json = $merged | ConvertTo-Json -Depth 100

# Write to output file
Set-Content -Path $OutputFile -Value $json

Write-Host "Merged JSON written to $OutputFile"

