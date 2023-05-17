function Edit-AllPunctuation {
    [cmdletbinding()]
    param  (    
        [Parameter(Mandatory=$true,
        Position=0,
        ValueFromPipeline,
        ValueFromPipelinebyPropertyName,
        HelpMessage='Introduza a frase ou conjunto de frases (tipo String) para substituição de caracteres com pontuação, por sem')]
        [string[]]$InputString
    )
    BEGIN{
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
        'À'='A'
        'Á'='A'
        'Â'='A'
        'Ã'='A'
        'Ä'='A'
        'È'='E'
        'É'='E'
        'Ê'='E'
        'Ë'='E'
        'Ì'='I'
        'Í'='I'
        'Î'='I'
        'Ò'='O'
        'Ó'='O'
        'Ô'='O'
        'Õ'='O'
        'Ö'='O'
        'Ù'='U'
        'Ú'='U'
        'Û'='U'
        'Ü'='U'
        'Ç'='C'
        'Ñ'='N'
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
