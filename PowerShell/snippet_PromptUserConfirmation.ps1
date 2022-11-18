$title    = 'something'
$question = 'Are you sure you want to proceed?'
$choices  = '&Yes', '&No'

$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {
    Write-Host 'confirmed'
}
else {
    Write-Host 'cancelled'
}


# Ref: https://stackoverflow.com/a/24649481