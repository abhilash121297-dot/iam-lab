# PowerShell IAM Automation Lab

This project demonstrates how repetitive Active Directory identity lifecycle tasks can be automated with PowerShell.

## Implemented Automation

### 1. Joiner - `New-TechNovaUser.ps1`
Automates new-user provisioning, including identity generation, department OU placement, AD attributes, secure temporary password handling, account enablement, department security-group assignment, and verification.

### 2. Mover - `Move-TechNovaUser.ps1`
Automates an employee department/role change by identifying the current user, removing obsolete department access, updating department and title attributes, moving the AD object to the new department OU, assigning the new department security group, and displaying the final state for validation.

## Lab Environment

- Domain: `technova.local`
- Domain Controller: `TECHNOVA-DC01`
- Platform: Windows Server 2025 Active Directory Domain Services
- Group OU: `technova-groups`
- Department OUs under `TECHNOVA-Users`

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

Change request:

```text
User: rahul.kumar
Old Department: HR
New Department: IT
Old Title: HR Analyst
New Title: IAM Support Analyst
```

The Mover automation performed the following lifecycle actions:

1. Retrieved the existing AD identity.
2. Identified the user's previous department.
3. Removed the obsolete HR department entitlement.
4. Updated the Department attribute to `IT`.
5. Updated the Title attribute to `IAM Support Analyst`.
6. Moved the account from the HR OU to the IT OU.
7. Assigned the `GG-IT-Users` entitlement.
8. Retrieved the final identity and group state for verification.

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

`GG-HR-Users` was no longer present. This demonstrates removal of obsolete access during a role change and helps prevent privilege accumulation/access creep.

## IAM Concepts Demonstrated

- Active Directory PowerShell administration
- Joiner-Mover-Leaver (JML) lifecycle concepts
- Automated identity provisioning
- Automated mover/role-change processing
- Attribute-based identity management
- Department-to-OU mapping
- Group-based authorization
- RBAC concepts
- Least privilege
- Removal of obsolete entitlements
- Access-creep prevention
- Duplicate-account prevention
- Secure password input
- Post-change validation

## Manual PowerShell Learning

Before building the reusable automation, the lab used individual PowerShell commands to query users and OUs, inspect account state and group memberships, create users and security groups, update identity attributes, move AD objects, and assign entitlements.

A fictional employee, **Neha Verma**, was provisioned manually through individual PowerShell commands before those tasks were consolidated into the Joiner automation.

## Files

```text
06-powershell/
├── README.md
├── New-TechNovaUser.ps1
└── Move-TechNovaUser.ps1
```

## Next Steps

- Leaver/offboarding automation
- CSV-based bulk provisioning
- Logging and audit output
- Improved error handling and rollback
- Input validation
- Full reusable JML workflow

## Status

**Joiner automation: ✅ Implemented and tested**

**Mover automation: ✅ Implemented and tested**

**Leaver automation: ⏳ Next**

---

> This is an educational IAM lab using fictional identities and an isolated test domain. No production credentials or sensitive organizational data are stored in this repository.
