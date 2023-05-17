function Import-UsersToCreateFromCSV {
    <#
.SYNOPSIS
The Import-UsersToCreateFromCSV function uses a Windows Forms dialog to select a CSV file for importing. The function opens the CSV file using a stream reader, replaces semicolons with commas in each line, and then writes the modified lines back to the file. The function then imports the modified CSV file using the Import-Csv cmdlet.

.PARAMETER None

.INPUTS
None

.OUTPUTS
System.Data.DataRow

.NOTES
The function requires the System.Windows.Forms and System.IO assemblies to be imported.

.EXAMPLE
PS C:> Import-UsersToCreateFromCSV
This will prompt the user to select a CSV file using a Windows Forms dialog. If a file is selected, the function will modify the file by replacing semicolons with commas and then import the modified file using the Import-Csv cmdlet.
#>
    # use these assemblys
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.IO

    # create dialog object with windows.forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Title = "Select a CSV file"
    $openFileDialog.Filter = "CSV files (*.csv)|*.csv|All files (*.*)|*.*"

    if ($openFileDialog.ShowDialog() -eq "OK") {

        # filename property contains full path to item
        $filePath = $openFileDialog.FileName
        # create buffer to store lines
        $modifiedLines = @()
        # create stream reader, for performance, in case file is very large
        $streamReader = [System.IO.File]::OpenText($filePath)

        # read till end and replace
        while ($null -ne ($line = $streamReader.ReadLine())) {
            $modifiedLine = $line -replace ';', ','
            $modifiedLines += $modifiedLine
        }
        $streamReader.Close()
        
        # write replaced items back to file
        $streamWriter = [System.IO.File]::CreateText($filePath)
        foreach ($modifiedLine in $modifiedLines) {
            $streamWriter.WriteLine($modifiedLine)
        }
        $streamWriter.Close()
        # Use powershell's import-csv to prettify and import to current shell
        return (Import-Csv $filePath)
    }
} # Import-UsersToCreateFromCSV