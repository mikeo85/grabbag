#region RUN AS ADMINISTRATOR
$isAdmin = ([Security.Principal.WindowsPrincipal] `
[Security.Principal.WindowsIdentity]::GetCurrent() `
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin -eq $false) {
	# If not running as admin, prompt user for confirmation then elevate or exit.
	$title    = 'Script must be executed with administrator privileges.'
	$question = 'Enter `Y` to attempt to open an elevated PowerShell session and continue. Enter `N` to exit.'
	$choices  = '&Yes', '&No'
	
	$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
	if ($decision -eq 0) {
		Write-Output "Attempting to open elevated PowerShell session"
        try {
		    Start-Process PowerShell -ArgumentList "$PSCommandPath" -Verb RunAs
            Write-Output "Successfully opened elevated PowerShell session. Continuing there..."
        }
        catch {
            Write-Warning -Message "Unable to open elevated PowerShell session. Manually open a privileged Windows Terminal or PowerShell session then re-run the script from there."
            exit 1
        }
        Write-Host -NoNewLine 'Press any key to continue...';$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
		exit 0
	}
	else {
		Write-Warning 'Exiting. Unable to execute script without administrator privileges.'
		exit 1
	}
}
else {
	# If running as admin, continue with the script
	Write-Verbose "Script is running with administrator privileges. Continuing..."
}
#endregion RUN AS ADMINISTRATOR
