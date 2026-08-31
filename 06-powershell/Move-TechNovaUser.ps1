# ============================================================
# TechNova IAM Lab - Automated Mover Process
# Script: Move-TechNovaUser.ps1
# Purpose: Move an existing AD user between departments
# ============================================================

Import-Module ActiveDirectory

# User / role change information
$SamAccountName = "rahul.kumar"
$NewDepartment  = "IT"
$NewTitle       = "IAM Support Analyst"

Write-Host "Starting Mover process for $SamAccountName"

# Get current user
$User = Get-ADUser $SamAccountName -Properties Department,Title,MemberOf

if (-not $User) {
    Write-Host "ERROR: User not found."
    exit
}

$OldDepartment = $User.Department
Write-Host "Current Department: $OldDepartment"
Write-Host "New Department: $NewDepartment"

# Department mapping
switch ($NewDepartment) {
    "Finance" {
        $NewOU = "OU=Finance,OU=TECHNOVA-Users,DC=technova,DC=local"
        $NewGroup = "GG-Finance-Users"
    }
    "IT" {
        $NewOU = "OU=IT,OU=TECHNOVA-Users,DC=technova,DC=local"
        $NewGroup = "GG-IT-Users"
    }
    "HR" {
        $NewOU = "OU=HR,OU=TECHNOVA-Users,DC=technova,DC=local"
        $NewGroup = "GG-HR-Users"
    }
    "Sales" {
        $NewOU = "OU=Sales,OU=TECHNOVA-Users,DC=technova,DC=local"
        $NewGroup = "GG-Sales-Users"
    }
    default {
        Write-Host "ERROR: Invalid department."
        exit
    }
}

# Remove old department access
$DepartmentGroups = @(
    "GG-Finance-Users",
    "GG-IT-Users",
    "GG-HR-Users"
)

foreach ($Group in $DepartmentGroups) {
    $ExistingGroup = Get-ADGroup -Identity $Group -ErrorAction SilentlyContinue

    if ($ExistingGroup) {
        $IsMember = Get-ADGroupMember $Group -Recursive |
            Where-Object { $_.SamAccountName -eq $SamAccountName }

        if ($IsMember) {
            Remove-ADGroupMember -Identity $Group -Members $SamAccountName -Confirm:$false
            Write-Host "Removed old entitlement: $Group"
        }
    }
}

# Update user attributes
Set-ADUser $SamAccountName -Department $NewDepartment -Title $NewTitle
Write-Host "Updated department and job title."

# Move user to new OU
Get-ADUser $SamAccountName | Move-ADObject -TargetPath $NewOU
Write-Host "Moved user to $NewDepartment OU."

# Assign new department access
$TargetGroup = Get-ADGroup -Identity $NewGroup -ErrorAction SilentlyContinue

if ($TargetGroup) {
    Add-ADGroupMember -Identity $NewGroup -Members $SamAccountName
    Write-Host "Assigned new entitlement: $NewGroup"
}
else {
    Write-Host "WARNING: $NewGroup does not exist."
}

# Verify final state
$UpdatedUser = Get-ADUser $SamAccountName -Properties Department,Title
$FinalGroups = Get-ADPrincipalGroupMembership $SamAccountName |
    Select-Object -ExpandProperty Name

Write-Host ""
Write-Host "============================================"
Write-Host "          MOVER PROCESS COMPLETE"
Write-Host "============================================"
Write-Host "Username:       $($UpdatedUser.SamAccountName)"
Write-Host "Department:     $($UpdatedUser.Department)"
Write-Host "Title:          $($UpdatedUser.Title)"
Write-Host "Distinguished:  $($UpdatedUser.DistinguishedName)"
Write-Host ""
Write-Host "Current Groups:"
$FinalGroups | ForEach-Object { Write-Host " - $_" }
Write-Host "============================================"
