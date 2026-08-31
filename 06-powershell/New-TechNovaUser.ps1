# ============================================================
# TechNova IAM Lab - Automated Joiner Provisioning
# Script: New-TechNovaUser.ps1
# Purpose: Create a new AD user and assign department access
# ============================================================

Import-Module ActiveDirectory

# ------------------------------------------------------------
# 1. EMPLOYEE INFORMATION
# Change these values for each new employee
# ------------------------------------------------------------

$FirstName  = "Rahul"
$LastName   = "Kumar"
$Department = "HR"
$Title      = "HR Analyst"
$Company    = "TechNova"

# ------------------------------------------------------------
# 2. GENERATE IDENTITY ATTRIBUTES
# ------------------------------------------------------------

$SamAccountName = "$($FirstName.ToLower()).$($LastName.ToLower())"
$UserPrincipalName = "$SamAccountName@technova.local"
$EmailAddress = "$SamAccountName@technova.com"
$DisplayName = "$FirstName $LastName"

Write-Host "Preparing Joiner account for $DisplayName"
Write-Host "Username: $SamAccountName"

# ------------------------------------------------------------
# 3. DEPARTMENT-BASED ACCESS MAPPING
# ------------------------------------------------------------

switch ($Department) {

    "Finance" {
        $OU = "OU=Finance,OU=TECHNOVA-Users,DC=technova,DC=local"
        $Group = "GG-Finance-Users"
    }

    "IT" {
        $OU = "OU=IT,OU=TECHNOVA-Users,DC=technova,DC=local"
        $Group = "GG-IT-Users"
    }

    "HR" {
        $OU = "OU=HR,OU=TECHNOVA-Users,DC=technova,DC=local"
        $Group = "GG-HR-Users"
    }

    "Sales" {
        $OU = "OU=Sales,OU=TECHNOVA-Users,DC=technova,DC=local"
        $Group = "GG-Sales-Users"
    }

    default {
        Write-Host "ERROR: Invalid department."
        exit
    }
}

# ------------------------------------------------------------
# 4. CHECK WHETHER USER ALREADY EXISTS
# ------------------------------------------------------------

$ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'"

if ($ExistingUser) {

    Write-Host "ERROR: $SamAccountName already exists."
    exit
}

# ------------------------------------------------------------
# 5. REQUEST TEMPORARY PASSWORD
# ------------------------------------------------------------

Write-Host "Enter a temporary password for $DisplayName"

$Password = Read-Host -AsSecureString

# ------------------------------------------------------------
# 6. CREATE ACTIVE DIRECTORY ACCOUNT
# ------------------------------------------------------------

New-ADUser `
    -Name $DisplayName `
    -GivenName $FirstName `
    -Surname $LastName `
    -DisplayName $DisplayName `
    -SamAccountName $SamAccountName `
    -UserPrincipalName $UserPrincipalName `
    -EmailAddress $EmailAddress `
    -Department $Department `
    -Title $Title `
    -Company $Company `
    -Path $OU `
    -AccountPassword $Password `
    -Enabled $true `
    -ChangePasswordAtLogon $true

Write-Host "AD account created successfully."

# ------------------------------------------------------------
# 7. ASSIGN ROLE-BASED ACCESS
# ------------------------------------------------------------

$TargetGroup = Get-ADGroup -Identity $Group -ErrorAction SilentlyContinue

if ($TargetGroup) {

    Add-ADGroupMember -Identity $Group -Members $SamAccountName

    Write-Host "$SamAccountName added to $Group."
}
else {

    Write-Host "WARNING: $Group does not exist."
}

# ------------------------------------------------------------
# 8. VERIFY PROVISIONING
# ------------------------------------------------------------

$CreatedUser = Get-ADUser $SamAccountName `
    -Properties Department,Title,Company,EmailAddress

Write-Host ""
Write-Host "============================================"
Write-Host "       JOINER PROVISIONING COMPLETE"
Write-Host "============================================"

Write-Host "Employee:   $($CreatedUser.Name)"
Write-Host "Username:   $($CreatedUser.SamAccountName)"
Write-Host "UPN:        $($CreatedUser.UserPrincipalName)"
Write-Host "Email:      $($CreatedUser.EmailAddress)"
Write-Host "Department: $($CreatedUser.Department)"
Write-Host "Title:      $($CreatedUser.Title)"
Write-Host "Company:    $($CreatedUser.Company)"
Write-Host "Enabled:    $($CreatedUser.Enabled)"
Write-Host "AD Group:   $Group"

Write-Host "============================================"
