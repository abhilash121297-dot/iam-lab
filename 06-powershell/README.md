# PowerShell IAM Automation Lab

This project demonstrates how repetitive Active Directory identity lifecycle tasks can be automated with PowerShell.

## Implemented Automation

### 1. Joiner - `New-TechNovaUser.ps1`
Automates new-user provisioning, including identity generation, department OU placement, AD attributes, secure temporary password handling, account enablement, department security-group assignment, and verification.

### 2. Mover - `Move-TechNovaUser.ps1`
Automates an employee department/role change by identifying the current user, removing obsolete department access, updating department and title attributes, moving the AD object to the new department OU, assigning the new department security group, and displaying the final state for validation.

### 3. Leaver - `Disable-TechNovaUser.ps1`
Automates user offboarding by disabling the AD account, removing non-default group memberships, stamping an offboarding date in the Description attribute, moving the account into the disabled-users OU, and verifying the final disabled state and remaining memberships.

## Lab Environment

- Domain: `technova.local`
- Domain Controller: `TECHNOVA-DC01`
- Platform: Windows Server 2025 Active Directory Domain Services
- Group OU: `technova-groups`
- Department OUs under `TECHNOVA-Users`
- Disabled Users OU: `TECHNOVA-Disabled Users`

## Department Mapping

| Department | OU | Role Group |
| --- | --- | --- |
| Finance | `TECHNOVA-Users/Finance` | `GG-Finance-Users` |
| IT | `TECHNOVA-Users/IT` | `GG-IT-Users` |
| HR | `TECHNOVA-Users/HR` | `GG-HR-Users` |
| Sales | `TECHNOVA-Users/Sales` | `GG-Sales-Users` |

> Department groups are expected to exist before entitlement assignment. The lab currently uses the groups created during the hands-on exercises.

## Joiner Test Case

The Joiner script was tested by provisioning the fictional employee **Rahul Kumar**.

```text
First Name: Rahul
Last Name: Kumar
Department: HR
Job Title: HR Analyst
Company: TechNova
Username: rahul.kumar
UPN: rahul.kumar@technova.local
Email: rahul.kumar@technova.com
Role Group: GG-HR-Users
Enabled: True
```

Independent validation in Active Directory confirmed:

```text
Domain Users
GG-HR-Users
```

## Mover Test Case

Rahul Kumar was then used to test the automated Mover workflow.

```text
User: rahul.kumar
Old Department: HR
New Department: IT
Old Title: HR Analyst
New Title: IAM Support Analyst
```

The Mover automation removed the obsolete HR entitlement, updated the Department and Title attributes, moved the account from the HR OU to the IT OU, assigned `GG-IT-Users`, and displayed the final state for verification.

Final PowerShell verification confirmed:

```text
Department: IT
Title: IAM Support Analyst
OU: TECHNOVA-Users/IT
Enabled: True

Group memberships:
Domain Users
GG-IT-Users
```

`GG-HR-Users` was no longer present, demonstrating removal of obsolete access and prevention of privilege/access creep.

## Leaver Test Case

The same fictional employee, **Rahul Kumar**, was used to test the automated Leaver workflow after the Mover phase.

The Leaver script performed the following actions:

1. Retrieved the existing AD identity and current lifecycle attributes.
2. Disabled the Active Directory account.
3. Removed all non-default group memberships while preserving `Domain Users`.
4. Stamped the account Description with an offboarding date.
5. Moved the account to `TECHNOVA-Disabled Users`.
6. Retrieved the final account state and remaining memberships for verification.

Final PowerShell verification confirmed:

```text
Department: IT
Title: IAM Support Analyst
Enabled: False
Description: Offboarded - 2026-08-31
OU: TECHNOVA-Disabled Users

Remaining group memberships:
Domain Users
```

`GG-IT-Users` was no longer present. This confirms that authentication was disabled and role-based access was revoked while the identity object was retained for audit/history.

## Complete Automated JML Flow

```text
JOINER
Create user
  ↓
Set identity attributes
  ↓
Place in department OU
  ↓
Assign department group
  ↓
Verify provisioning

MOVER
Review existing identity
  ↓
Remove obsolete department access
  ↓
Update Department + Title
  ↓
Move to new department OU
  ↓
Assign new department group
  ↓
Verify final access

LEAVER
Retrieve current identity
  ↓
Disable account
  ↓
Remove non-default entitlements
  ↓
Stamp offboarding date
  ↓
Move to Disabled Users OU
  ↓
Verify disabled state and remaining memberships
```

## IAM Concepts Demonstrated

- Active Directory PowerShell administration
- Joiner-Mover-Leaver lifecycle automation
- Automated identity provisioning and deprovisioning
- Attribute-based identity management
- Department-to-OU mapping
- Group-based authorization
- RBAC concepts
- Least privilege
- Removal of obsolete entitlements
- Privilege/access-creep prevention
- Duplicate-account prevention
- Secure password input
- Account disablement
- Offboarding metadata
- Disabled-account retention
- Post-change validation

## Manual PowerShell Learning

Before building the reusable automation, the lab used individual PowerShell commands to query users and OUs, inspect account state and group memberships, create users and security groups, update identity attributes, move AD objects, and assign entitlements.

A fictional employee, **Neha Verma**, was provisioned manually through individual PowerShell commands before those tasks were consolidated into the Joiner automation.

## Files

```text
06-powershell/
├── README.md
├── New-TechNovaUser.ps1
├── Move-TechNovaUser.ps1
└── Disable-TechNovaUser.ps1
```

## Next Steps

- CSV-based bulk provisioning
- Logging and audit output to CSV/text files
- Better error handling and rollback
- Input validation
- Parameterized scripts instead of hard-coded test values
- Full reusable JML orchestration workflow

## Status

**Joiner automation: ✅ Implemented and tested**

**Mover automation: ✅ Implemented and tested**

**Leaver automation: ✅ Implemented and tested**

**PowerShell JML automation lab: ✅ COMPLETED**

---

> This is an educational IAM lab using fictional identities and an isolated test domain. No production credentials or sensitive organizational data are stored in this repository.
