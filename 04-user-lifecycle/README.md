# IAM Lab: User Lifecycle Management (JML)

This hands-on lab simulates a core Identity and Access Management process: **Joiner → Mover → Leaver (JML)**.

The objective is to practice how an IAM Engineer provisions identities, assigns access based on job responsibilities, modifies entitlements when an employee changes roles, and revokes access when an employee leaves the organization.

## Lab Environment

- Active Directory domain: `technova.local`
- Domain Controller: `TECHNOVA-DC01`
- Platform: Windows Server 2025 Active Directory Domain Services
- User OUs: Finance, HR, IT, Sales under `TECHNOVA-Users`
- Group OU: `technova-Groups`
- Resource root: `C:\Shares`

## Lifecycle Scenario

The fictional employee used for this exercise is **Arjun Rao**.

### Initial Joiner identity

| Attribute | Value |
| --- | --- |
| Employee | Arjun Rao |
| Username | `arjun.rao` |
| Department | Finance |
| Job Title | Financial Analyst |
| Company | TechNova |
| Email | `arjun.rao@technova.com` |
| Initial OU | `TECHNOVA-Users/Finance` |
| Finance entitlement | `GG-Finance-Users` |

# Phase 1 — Joiner ✅ COMPLETED

Arjun was provisioned as a Finance employee and assigned Finance access through group membership rather than direct resource permissions.

### Completed Joiner actions

- [x] Created Arjun Rao in Active Directory.
- [x] Placed the account in `TECHNOVA-Users/Finance`.
- [x] Configured username `arjun.rao`.
- [x] Set Department to `Finance`.
- [x] Set Job Title to `Financial Analyst`.
- [x] Set Company to `TechNova`.
- [x] Added Arjun to `GG-Finance-Users`.
- [x] Verified group membership in ADUC.

### Finance authorization model

```text
Arjun Rao
    ↓
GG-Finance-Users
    ↓
DL-Finance-Share-RW
    ↓
C:\Shares\Finance
    ↓
Modify permission
```

This demonstrates group-based authorization, AGDLP, RBAC concepts, and least privilege.

# Phase 2 — Mover ✅ COMPLETED

## Mover Scenario

Arjun transferred from the **Finance department to the IT department**.

| Attribute | Before | After |
| --- | --- | --- |
| Department | Finance | IT |
| Job Title | Financial Analyst | IAM Support Analyst |
| OU | `TECHNOVA-Users/Finance` | `TECHNOVA-Users/IT` |
| Department group | `GG-Finance-Users` | `GG-IT-Users` |

## Completed Mover Actions

### 1. Pre-move entitlement review

Before making the role change, Arjun's memberships were reviewed and confirmed as:

```text
Domain Users
GG-Finance-Users
```

This established the employee's entitlement state before access modification.

### 2. Revoked obsolete Finance access

Arjun was removed from:

```text
GG-Finance-Users
```

The old department entitlement was deliberately revoked before the new IT entitlement was assigned, reducing the risk of **privilege/access creep**.

### 3. Moved the identity to the IT OU

Arjun's AD object was moved from:

```text
TECHNOVA-Users/Finance
```

to:

```text
TECHNOVA-Users/IT
```

### 4. Updated identity attributes

Arjun's organizational attributes were updated to:

```text
Department: IT
Job Title: IAM Support Analyst
Company: TechNova
```

### 5. Created and assigned the IT role group

A Global Security Group was created:

```text
GG-IT-Users
```

Arjun was added to this group. Post-move membership was verified in ADUC as:

```text
Arjun Rao
├── Domain Users
└── GG-IT-Users
```

`GG-Finance-Users` was absent, confirming obsolete Finance entitlement removal.

### 6. Created the IT resource access group

A Domain Local Security Group was created:

```text
DL-IT-Share-RW
```

This group represents the permission to read and modify the IT network share.

### 7. Implemented AGDLP group nesting

The IT Global group was nested into the IT Domain Local resource group:

```text
GG-IT-Users
    ↓ member of
DL-IT-Share-RW
```

The membership was verified through the `DL-IT-Share-RW` Members tab in ADUC.

### 8. Created the IT resource

The following folder was created on the domain controller:

```text
C:\Shares\IT
```

It was shared with the network share name:

```text
IT
```

Expected UNC path:

```text
\\TECHNOVA-DC01\IT
```

### 9. Configured share permissions

Broad `Everyone` share access was removed and the resource access group was assigned:

```text
DL-IT-Share-RW
```

Share permissions:

```text
Change: Allow
Read:   Allow
Full Control: Not assigned
```

### 10. Configured NTFS permissions

Inheritance on `C:\Shares\IT` was disabled and existing inherited entries were converted to explicit permissions before the access model was finalized.

Verified NTFS entries:

```text
Administrators (TECHNOVA\Administrators)
    Full control
    Applies to: This folder, subfolders and files

SYSTEM
    Full control
    Applies to: This folder, subfolders and files

CREATOR OWNER
    Full control
    Applies to: Subfolders and files only

DL-IT-Share-RW
    Modify
    Applies to: This folder, subfolders and files
```

No broad `Users` or `Everyone` NTFS entry was present in the final configuration.

## Final IT Authorization Model

```text
Arjun Rao
    ↓
GG-IT-Users
    ↓
DL-IT-Share-RW
    ↓
C:\Shares\IT / \\TECHNOVA-DC01\IT
    ↓
Modify permission
```

This completes the AD-side IT authorization model using **AGDLP**:

```text
Accounts → Global Groups → Domain Local Groups → Permissions
```

## Mover IAM Concepts Demonstrated

- Pre-change entitlement review
- Identity attribute modification
- Organizational role change
- Access revocation
- New entitlement provisioning
- Security-group-based authorization
- AGDLP
- RBAC concepts
- Least privilege
- Prevention of privilege/access creep
- Share vs NTFS permission design
- Separation of identity, role membership, and resource permissions
- Audit-friendly lifecycle sequencing

## Mover Validation

- [x] Existing Finance access reviewed before change.
- [x] `GG-Finance-Users` removed.
- [x] Arjun moved from Finance OU to IT OU.
- [x] Department changed from Finance to IT.
- [x] Job title changed from Financial Analyst to IAM Support Analyst.
- [x] `GG-IT-Users` Global Security Group created.
- [x] Arjun added to `GG-IT-Users`.
- [x] Post-move membership verified as `Domain Users` + `GG-IT-Users`.
- [x] Finance group absent from post-move membership.
- [x] `DL-IT-Share-RW` Domain Local Security Group created.
- [x] `GG-IT-Users` nested into `DL-IT-Share-RW`.
- [x] `C:\Shares\IT` created and shared as `IT`.
- [x] Share permissions restricted to `DL-IT-Share-RW` with Change + Read.
- [x] NTFS `Modify` permission assigned to `DL-IT-Share-RW`.
- [x] Broad user access excluded from the final NTFS configuration.
- [x] Complete AD-side IT AGDLP authorization chain verified.

> End-user access testing through `\\TECHNOVA-DC01\IT` remains a separate validation step because the Windows client VM has not yet been successfully deployed. The group nesting, share permissions, and NTFS authorization model have been configured and verified on the server.

# Phase 3 — Leaver ⏳ NEXT

The Leaver phase will securely deprovision Arjun after his employment ends.

Planned controls include:

- Review current access before offboarding.
- Disable the Active Directory account.
- Revoke IT department/resource group memberships.
- Review remaining entitlements.
- Move the identity to an appropriate disabled-user location if configured.
- Record the offboarding action.
- Verify that the account is disabled and no longer retains unnecessary role access.

# Overall Validation Checklist

- [x] Joiner identity provisioned.
- [x] Joiner Finance entitlement assigned through a security group.
- [x] Mover's obsolete Finance entitlement revoked.
- [x] Mover identity and organizational attributes updated.
- [x] New IT role entitlement assigned.
- [x] Post-move membership confirms Finance access was not retained.
- [x] IT resource authorization implemented through AGDLP.
- [x] IT share and NTFS permissions configured according to least privilege.
- [x] Mover phase completed on the AD/server side.
- [ ] Disable Leaver account.
- [ ] Revoke Leaver entitlements.
- [ ] Complete final lifecycle access review.

# Evidence Captured

Lab evidence currently includes:

- Joiner membership showing `Domain Users` and `GG-Finance-Users`.
- Mover pre-change Finance membership review.
- Arjun moved into the IT OU.
- Updated IT / IAM Support Analyst identity attributes.
- Post-move membership showing `Domain Users` and `GG-IT-Users` with Finance membership absent.
- `DL-IT-Share-RW` membership showing `GG-IT-Users` nested inside it.
- IT share permissions showing `DL-IT-Share-RW` with Change + Read.
- Final NTFS permissions showing `DL-IT-Share-RW` with Modify access and administrative/system entries preserved.

Screenshots can be added to this repository later as portfolio evidence without exposing passwords or sensitive credentials.

# Skills Demonstrated

- Active Directory user administration
- Joiner/Mover/Leaver lifecycle management
- Identity provisioning
- Identity attribute management
- Group-based access control
- RBAC concepts
- AGDLP
- Windows share permissions
- NTFS permissions
- Least-privilege implementation
- Entitlement management
- Access reviews
- Access revocation
- Privilege-creep prevention
- IAM operational documentation

## Lab Status

**Status: Joiner completed — Mover completed — Leaver next**

---

> This project uses fictional employee identities in an isolated educational lab environment. No production credentials or sensitive organizational information are stored in this repository.
