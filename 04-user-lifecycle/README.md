# IAM Lab: User Lifecycle Management (JML)

This hands-on lab simulates a core Identity and Access Management process: **Joiner → Mover → Leaver (JML)**.

The objective is to practice how an IAM Engineer provisions identities, assigns access based on job responsibilities, modifies entitlements when an employee changes roles, and securely deprovisions access when an employee leaves the organization.

## Lab Environment

- Active Directory domain: `technova.local`
- Domain Controller: `TECHNOVA-DC01`
- Platform: Windows Server 2025 Active Directory Domain Services
- User OUs: Finance, HR, IT, Sales under `TECHNOVA-Users`
- Disabled identities OU: `TECHNOVA-Disabled-Users`
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

# Phase 2 — Mover ✅ COMPLETED

Arjun transferred from the **Finance department to the IT department**.

| Attribute | Before | After |
| --- | --- | --- |
| Department | Finance | IT |
| Job Title | Financial Analyst | IAM Support Analyst |
| OU | `TECHNOVA-Users/Finance` | `TECHNOVA-Users/IT` |
| Department group | `GG-Finance-Users` | `GG-IT-Users` |

## Completed Mover Actions

1. Reviewed Arjun's existing memberships before the change: `Domain Users` and `GG-Finance-Users`.
2. Removed `GG-Finance-Users` to prevent privilege/access creep.
3. Moved Arjun from `TECHNOVA-Users/Finance` to `TECHNOVA-Users/IT`.
4. Updated Department to `IT` and Job Title to `IAM Support Analyst`.
5. Created `GG-IT-Users` and added Arjun to it.
6. Verified post-move membership as `Domain Users` + `GG-IT-Users`, with Finance access absent.
7. Created Domain Local Security Group `DL-IT-Share-RW`.
8. Nested `GG-IT-Users` into `DL-IT-Share-RW`.
9. Created `C:\Shares\IT` and shared it as `IT`.
10. Removed broad `Everyone` share access and granted `DL-IT-Share-RW` Change + Read share permissions.
11. Configured NTFS permissions so `DL-IT-Share-RW` has Modify access while Administrators and SYSTEM retain Full Control.

### Final IT authorization model

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

This implements the **AGDLP** model:

```text
Accounts → Global Groups → Domain Local Groups → Permissions
```

> End-user access testing through `\\TECHNOVA-DC01\IT` remains a separate validation step because the Windows client VM has not yet been successfully deployed. The AD group nesting, share permissions, and NTFS authorization model were configured and verified on the server.

# Phase 3 — Leaver ✅ COMPLETED

## Leaver Scenario

Arjun has now left TechNova. The goal of the Leaver process is to stop authentication promptly, revoke role-based access, retain the identity for audit/history, and separate the disabled identity from active employees.

## Completed Leaver Actions

### 1. Pre-offboarding entitlement review

Before deprovisioning, Arjun's current memberships were reviewed in Active Directory Users and Computers.

Verified state:

```text
Domain Users
GG-IT-Users
```

`GG-Finance-Users` was not present, confirming that the previous Mover cleanup remained effective.

### 2. Disabled the Active Directory account

Arjun's Active Directory account was disabled before entitlement removal.

This prevents normal authentication while preserving the directory object for audit, investigation, retention, and controlled administrative handling.

The account was **not deleted**.

### 3. Revoked IT role access

Arjun was removed from:

```text
GG-IT-Users
```

Because IT resource authorization was implemented through AGDLP, removing the user from the Global role group breaks Arjun's authorization path to the IT resource:

```text
Before:
Arjun Rao
    ↓
GG-IT-Users
    ↓
DL-IT-Share-RW
    ↓
IT Share

After:
Arjun Rao (Disabled)
    ↓
Domain Users only
```

The shared resource groups themselves remain intact for other authorized IT employees. This demonstrates why permissions should be assigned to groups instead of directly to individual users.

### 4. Created a dedicated Disabled Users OU

A new Organizational Unit was created:

```text
TECHNOVA-Disabled-Users
```

Protection from accidental deletion was retained for the OU.

### 5. Moved the disabled identity out of the active IT OU

Arjun's account was moved from:

```text
TECHNOVA-Users/IT
```

to:

```text
TECHNOVA-Disabled-Users
```

This separates inactive identities from the active departmental user population and provides a clear administrative location for retained disabled accounts.

### 6. Final entitlement review

A final `Member Of` review confirmed that Arjun's only remaining membership is:

```text
Domain Users
```

The IT role entitlement `GG-IT-Users` is no longer present.

This provides evidence that role-based IT access was revoked successfully.

## Final Leaver State

```text
Identity: Arjun Rao
Account: Disabled
Location: TECHNOVA-Disabled-Users
Role entitlement: GG-IT-Users removed
Finance entitlement: GG-Finance-Users absent
Remaining primary/default membership: Domain Users
Direct resource permission: None
```

## Leaver IAM Concepts Demonstrated

- Pre-offboarding access review
- Account disablement
- Authentication termination
- Entitlement revocation
- Group-based deprovisioning
- Least privilege
- Separation of inactive identities
- Disabled-account retention instead of immediate deletion
- Post-offboarding entitlement verification
- Audit-friendly offboarding sequencing

# Full JML Lifecycle Summary

```text
JOINER
Arjun joins Finance
    ↓
Create identity
    ↓
GG-Finance-Users
    ↓
Finance resource access

MOVER
Finance → IT
    ↓
Review existing access
    ↓
Remove GG-Finance-Users
    ↓
Update OU + identity attributes
    ↓
Add GG-IT-Users
    ↓
DL-IT-Share-RW
    ↓
IT resource access

LEAVER
Employment ends
    ↓
Review current entitlements
    ↓
Disable account
    ↓
Remove GG-IT-Users
    ↓
Move to TECHNOVA-Disabled-Users
    ↓
Verify Domain Users only
```

# Overall Validation Checklist

## Joiner

- [x] Identity provisioned.
- [x] Finance attributes configured.
- [x] Finance entitlement assigned through a security group.
- [x] Initial group membership verified.

## Mover

- [x] Existing Finance access reviewed.
- [x] Obsolete Finance entitlement revoked.
- [x] Identity moved to IT OU.
- [x] Department and job title updated.
- [x] New IT role group created and assigned.
- [x] Finance entitlement absence verified.
- [x] IT Domain Local resource group created.
- [x] AGDLP nesting configured.
- [x] IT share created.
- [x] Share permissions configured according to least privilege.
- [x] NTFS Modify permission assigned to the Domain Local resource group.

## Leaver

- [x] Pre-offboarding entitlement review completed.
- [x] Active Directory account disabled.
- [x] IT role entitlement revoked.
- [x] `TECHNOVA-Disabled-Users` OU created.
- [x] Disabled identity moved out of active IT OU.
- [x] Final membership review completed.
- [x] Only `Domain Users` remains in the final membership view.
- [x] Account retained rather than deleted.

# Evidence Captured

Lab evidence includes:

- Joiner membership showing `Domain Users` and `GG-Finance-Users`.
- Mover pre-change Finance membership review.
- Arjun moved into the IT OU.
- Updated IT / IAM Support Analyst attributes.
- Post-move membership showing `Domain Users` and `GG-IT-Users` with Finance membership absent.
- `DL-IT-Share-RW` membership showing `GG-IT-Users` nested inside it.
- IT share permissions showing `DL-IT-Share-RW` with Change + Read.
- NTFS permissions showing `DL-IT-Share-RW` with Modify access.
- Leaver pre-offboarding membership showing `Domain Users` and `GG-IT-Users`.
- Arjun located in `TECHNOVA-Disabled-Users` after offboarding.
- Final Leaver membership showing only `Domain Users`.

Screenshots can be added later as portfolio evidence without exposing passwords or sensitive credentials.

# Skills Demonstrated

- Active Directory user administration
- Joiner/Mover/Leaver lifecycle management
- Identity provisioning and deprovisioning
- Identity attribute management
- Account disablement
- Organizational Unit administration
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
- Offboarding controls
- IAM operational documentation

## Lab Status

**Status: Joiner ✅ — Mover ✅ — Leaver ✅ — JML LAB COMPLETED**

---

> This project uses fictional employee identities in an isolated educational lab environment. No production credentials or sensitive organizational information are stored in this repository.
