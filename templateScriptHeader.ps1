############################################################
#
#  TITLE
#  ---------------------------------------------------------
#  Subtitle
#
#        Written by: Mike Owens
#        Email:      mikeowens (at) fastmail (dot) com
#        Website:    https://michaelowens.me
#        GitLab:     https://gitlab.com/mikeo85
#        GitHub:     https://github.com/mikeo85
#        Mastodon:   https://infosec.exchange/@m0x4d
#        Twitter:    https://twitter.com/quietmike8192
#
#  .SYNOPSIS 
#  This script [TBD]
#
#  .DESCRIPTION 
#  Use Case: TBD
#
#  Preparations:
#  - TBD
#  .PARAMETER [First Param]
#  First Param does [this]
#  .INPUTS
#  [TBD]
#  .OUTPUTS
#  [System.String containing the blah blah]
#  .EXAMPLE
#  
#  PS> <[TBD]>
#  
############################################################

# SAMPLE PARAMETER BLOCK
Param(
    [Parameter(Mandatory)] [ValidateScript({Resolve-Path $_})] [String] $Path,
    [ValidateScript({Resolve-Path $_})] [String] $OutDirectory = '.'
)

Write-Verbose "Beginning $($MyInvocation.InvocationName)"
#region Main



#endregion
Write-Verbose "`n$($MyInvocation.InvocationName) is complete"

# //============= REFERENCES ===================\\
# - TBD
# https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.3
# \\============================================//

# eof