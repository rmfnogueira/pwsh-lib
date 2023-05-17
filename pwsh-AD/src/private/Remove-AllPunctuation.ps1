function Edit-AllPunctuation {
    <#
.SYNOPSIS
Edit-AllPunctuation replaces accented characters and special characters in a string with its equivalent non-accented character.

.DESCRIPTION
The function takes a string or an array of strings as input and replaces accented characters and special characters
present in the input string(s) with its equivalent non-accented character.

.PARAMETER InputString
The string (or an array of strings) to be processed. 
This parameter is mandatory and must be specified.

.EXAMPLE
Edit-AllPunctuation -InputString "Olá, como estás?"

- returns: "Ola, como estas?"

.NOTES
The function is case-sensitive.

.OUTPUTS
The function returns the processed string,
with accented characters and special characters replaced with their equivalent non-accented characters.

.FUNCTIONALITY
Replaces accented characters and special characters in a string.
#>
    [cmdletbinding()]
    param  (    
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelinebyPropertyName,
            HelpMessage = 'Please enter a String or an Array of Strings to replace accented characters')]
        [string[]]$InputString
    )
    BEGIN {
        Write-Verbose "[BEGIN]Starting $($MyInvocation.MyCommand)"
        $SubsPMin = @{
            'à' = 'a'
            'á' = 'a'
            'â' = 'a'
            'ã' = 'a'
            'ä' = 'a'
            'è' = 'e'
            'é' = 'e'
            'ê' = 'e'
            'ë' = 'e'
            'ì' = 'i'
            'í' = 'i'
            'î' = 'i'
            'ï' = 'i'
            'ò' = 'o'
            'ó' = 'o'
            'ô' = 'o'
            'õ' = 'o'
            'ö' = 'o'
            'ù' = 'u'
            'ú' = 'u'
            'û' = 'u'
            'ü' = 'u'
            'ç' = 'c'
            'ñ' = 'n'
        }
        $SubsPMai = @{
            'À' = 'A'
            'Á' = 'A'
            'Â' = 'A'
            'Ã' = 'A'
            'Ä' = 'A'
            'È' = 'E'
            'É' = 'E'
            'Ê' = 'E'
            'Ë' = 'E'
            'Ì' = 'I'
            'Í' = 'I'
            'Î' = 'I'
            'Ò' = 'O'
            'Ó' = 'O'
            'Ô' = 'O'
            'Õ' = 'O'
            'Ö' = 'O'
            'Ù' = 'U'
            'Ú' = 'U'
            'Û' = 'U'
            'Ü' = 'U'
            'Ç' = 'C'
            'Ñ' = 'N'
        }
    }#begin
    PROCESS {
        foreach ($string in $InputString) {
            Write-Verbose "[PROCESS] Starting string operations."
            foreach ($key in $SubsPMin.Keys) {
                $string = $string.Replace($key, $SubsPMin.$key)
                foreach ($key in $SubsPMai.Keys) {
                    $string = $string.Replace($Key, $SubsPMai.$Key)
                }
            }
            Write-Output $string
        }
    }#process
    END {}
}#Edit-AllPunctuation
