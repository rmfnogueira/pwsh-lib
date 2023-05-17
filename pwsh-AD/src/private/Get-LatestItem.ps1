function Get-LatestItem {
    param (
        [int]$count = 1,
        [string]$Name,
        [string]$Path,
        [string]$Destination
    )
    Get-ChildItem $Path | 
    Where-Object Name -like "$name*" | 
    Sort-Object -Property LastWriteTime -Descending |
    Select-Object -First 1
} # Get-LatestItem