function Get-LatestItem {
    param (
        [int]$count = 1,
        [String]$path,
        [String]$name
    )
    Get-ChildItem $path | 
    Where-Object Name -like "$name*" | 
    Sort-Object -Property LastWriteTime -Descending |
    Select-Object -First 1
} # Get-LatestItem