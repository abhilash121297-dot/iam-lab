# ============================================================
# TechNova IAM Lab - Automated Leaver Process
# Script: Disable-TechNovaUser.ps1
# Purpose: Securely offboard an Active Directory user
# ============================================================

Import-Module ActiveDirectory

# Leaver information
$SamAccountName = "rahul.kumar"
$DisabledUsersOU = "OU=TECHNOVA-Disabled Users,DC=technova,DC=local"

Write-Host ""
Write-Host "Starting Leaver process for $SamAccountName"
Write-Host "--------------------------------------------"

# Verify user exists
$User = Get-ADUser $SamAccountName -Properties Department,Title,MemberOf,Enabled

if (-not $User) {
    Write-Host "ERROR: User not found."
    exit
}

Write-Host "Employee:   $($User.Name)"
Write-Host "Department: $($User.Department)"
Write-Host "Title:      $($User.Title)"
Write-Host "Enabled:    $($User.Enabled)"

# Disable account
Disable-ADAccount -Identity $SamAccountName
Write-Host "Account disabled."

# Remove non-default group memberships
$Groups = Get-ADPrincipalGroupMembership $SamAccountName |
    Where-Object { $_.Name -ne "Domain Users" }

foreach ($Group in $Groups) {
    Remove-ADGroupMember -Identity $Group -Members $SamAccountName -Confirm:$false
    Write-Host "Removed entitlement: $($Group.Name)"
}

# Stamp offboarding date
$OffboardDate = Get-Date -Format "yyyy-MM-dd"
Set-ADUser $SamAccountName -Description "Offboarded - $OffboardDate"
Write-Host "Account marked as offboarded."

# Move account to Disabled Users OU
Get-ADUser $SamAccountName | Move-ADObject -TargetPath $DisabledUsersOU
Write-Host "Moved account to TECHNOVA-Disabled Users."

# Verify final state
$FinalUser = Get-ADUser $SamAccountName -Properties Department,Title,Description,Enabled
$FinalGroups = Get-ADPrincipalGroupMembership $SamAccountName |
    Select-Object -ExpandProperty Name

Write-Host ""
Write-Host "============================================"
Write-Host "          LEAVER PROCESS COMPLETE"
Write-Host "============================================"
Write-Host "Employee:    $($FinalUser.Name)"
Write-Host "Username:    $($FinalUser.SamAccountName)"
Write-Host "Department:  $($FinalUser.Department)"
Write-Host "Title:       $($FinalUser.Title)"
Write-Host "Enabled:     $($FinalUser.Enabled)"
Write-Host "Description: $($FinalUser.Description)"
Write-Host "Location:    $($FinalUser.DistinguishedName)"
Write-Host ""
Write-Host "Remaining Groups:"
$FinalGroups | ForEach-Object { Write-Host " - $_" }
Write-Host "============================================"
