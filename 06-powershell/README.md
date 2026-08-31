# PowerShell IAM Automation Lab

This project demonstrates how repetitive Active Directory identity-management tasks can be automated with PowerShell.

## Current Automation: Joiner Provisioning

The first script in this lab is:

```text
New-TechNovaUser.ps1
```

It automates the Joiner portion of the user lifecycle by creating a new Active Directory identity and assigning department-based access.

## Lab Environment

- Domain: `technova.local`
- Domain Controller: `TECHNOVA-DC01`
- Platform: Windows Server 2025 Active Directory Domain Services
- Group OU: `technova-groups`
- Department OUs under `TECHNOVA-Users`

## What the Script Automates

The script performs the following IAM tasks:

1. Imports the Active Directory PowerShell module.
2. Accepts employee identity information through configurable variables.
3. Automatically generates:
   - `SamAccountName`
   - User Principal Name (UPN)
   - Email address
   - Display name
4. Maps the employee's department to the correct OU and department security group.
5. Checks whether the username already exists.
6. Prompts securely for a temporary password.
7. Creates and enables the Active Directory account.
8. Configures identity attributes including:
   - Department
   - Job title
   - Company
   - Email
9. Requires the employee to change the password at first logon.
10. Assigns the appropriate department Global Security Group.
11. Retrieves the new AD object and displays a provisioning summary for verification.

## Department Mapping

Current lab mappings are:

| Department | OU | Role Group |
| --- | --- | --- |
| Finance | `TECHNOVA-Users/Finance` | `GG-Finance-Users` |
| IT | `TECHNOVA-Users/IT` | `GG-IT-Users` |
| HR | `TECHNOVA-Users/HR` | `GG-HR-Users` |
| Sales | `TECHNOVA-Users/Sales` | `GG-Sales-Users` |

> The mapped department group must already exist. If a group is missing, the script reports a warning rather than silently claiming that access was provisioned.

## Successful Test Case

The script was tested by automatically provisioning the fictional employee **Rahul Kumar**.

Test input:

```text
First Name: Rahul
Last Name: Kumar
Department: HR
Job Title: HR Analyst
Company: TechNova
```

Generated identity:

```text
Username: rahul.kumar
UPN: rahul.kumar@technova.local
Email: rahul.kumar@technova.com
OU: TECHNOVA-Users/HR
Role Group: GG-HR-Users
Enabled: True
```

PowerShell reported successful account creation and group assignment. Active Directory Users and Computers was then used as an independent validation source.

Verified final memberships:

```text
Rahul Kumar
├── Domain Users
└── GG-HR-Users
```

This confirms that the automation performed both identity provisioning and department entitlement assignment successfully.

## IAM Concepts Demonstrated

- Active Directory PowerShell administration
- Joiner automation
- Identity provisioning
- Attribute-based account configuration
- Username and UPN generation
- Department-to-OU mapping
- Group-based authorization
- RBAC concepts
- Least privilege
- Duplicate-account prevention
- Secure password input
- Post-provisioning validation

## Manual PowerShell Learning Completed Before Automation

Before building the reusable script, the lab also used PowerShell to:

- Query existing AD users with `Get-ADUser`.
- Verify disabled account state.
- Review group memberships with `Get-ADPrincipalGroupMembership`.
- Locate department OUs with `Get-ADOrganizationalUnit`.
- Create and update user attributes.
- Create Global Security Groups.
- Move AD objects into the correct OU.
- Assign security-group memberships.

A separate test identity, **Neha Verma**, was provisioned manually through individual PowerShell commands before those tasks were consolidated into the reusable Joiner script.

## Files

```text
06-powershell/
├── README.md
└── New-TechNovaUser.ps1
```

## Next Steps

Planned automation improvements:

- Mover automation
- Leaver/offboarding automation
- CSV-based bulk provisioning
- Logging and audit output
- Better error handling
- Input validation
- Full reusable JML automation workflow

## Status

**Joiner automation: ✅ Implemented and tested**

**Mover automation: ⏳ Next**

**Leaver automation: ⏳ Planned**

---

> This is an educational IAM lab using fictional identities and an isolated test domain. No production credentials or sensitive organizational data are stored in this repository.
