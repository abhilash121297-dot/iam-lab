# IAM Lab: User Lifecycle Management (JML)

This hands-on lab simulates a core Identity and Access Management process: **Joiner → Mover → Leaver (JML)**.

The objective is to practice how an IAM Engineer provisions identities, assigns access based on job responsibilities, modifies entitlements when an employee changes roles, and revokes access when an employee leaves the organization.

## Lab Environment

- Active Directory domain: `technova.local`
- Domain Controller: `TECHNOVA-DC01`
- Platform: Windows Server 2025 Active Directory Domain Services
- User OUs: Finance, HR, IT, Sales under `TECHNOVA-Users`
- Group OU: `technova-Groups`

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

# Phase 2 — Mover 🚧 IN PROGRESS

## Mover Scenario

Arjun has transferred from the **Finance department to the IT department**.

| Attribute | Before | After |
| --- | --- | --- |
| Department | Finance | IT |
| Job Title | Financial Analyst | IAM Support Analyst |
| OU | `TECHNOVA-Users/Finance` | `TECHNOVA-Users/IT` |
| Department group | `GG-Finance-Users` | `GG-IT-Users` |

## Completed Mover Actions

### 1. Pre-move access review

Before making the role change, Arjun's memberships were reviewed and confirmed as:

```text
Domain Users
GG-Finance-Users
```

This establishes the employee's existing entitlement state before modifying access.

### 2. Revoked obsolete Finance access

Arjun was removed from:

```text
GG-Finance-Users
```

The old department entitlement was deliberately revoked before assigning the new IT entitlement. This reduces the risk of **privilege/access creep** during role changes.

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

Arjun's organization attributes were changed to reflect the new role:

```text
Department: IT
Job Title: IAM Support Analyst
Company: TechNova
```

### 5. Created the IT role group

A new Global Security Group was created:

```text
GG-IT-Users
```

Purpose: represent standard IT department membership and provide a reusable role/group layer for IT authorization.

### 6. Assigned the new IT entitlement

Arjun was added to `GG-IT-Users`.

Post-move membership was verified in ADUC as:

```text
Arjun Rao
├── Domain Users
└── GG-IT-Users
```

`GG-Finance-Users` is no longer present, confirming that obsolete Finance entitlement was removed rather than accumulated alongside the new role.

## Mover IAM Concepts Demonstrated

- Pre-change entitlement review
- Identity attribute modification
- Organizational role change
- Access revocation
- New entitlement provisioning
- Security-group-based authorization
- Least privilege
- Prevention of privilege/access creep
- Separation of identity attributes from authorization
- Audit-friendly lifecycle sequencing

## Mover Validation So Far

- [x] Existing Finance access reviewed before change.
- [x] `GG-Finance-Users` removed.
- [x] Arjun moved from Finance OU to IT OU.
- [x] Department changed from Finance to IT.
- [x] Job title changed from Financial Analyst to IAM Support Analyst.
- [x] `GG-IT-Users` Global Security Group created.
- [x] Arjun added to `GG-IT-Users`.
- [x] Post-move membership verified as `Domain Users` + `GG-IT-Users`.
- [x] Finance group is absent from post-move membership.
- [ ] Create an IT resource access group such as `DL-IT-Share-RW`.
- [ ] Create/configure the IT resource and permissions.
- [ ] Nest `GG-IT-Users` into the appropriate Domain Local access group.
- [ ] Validate the complete IT AGDLP authorization chain.

## Planned IT Authorization Model

To maintain the same AGDLP architecture used for Finance, the next implementation step is:

```text
Arjun Rao
    ↓
GG-IT-Users
    ↓
DL-IT-Share-RW
    ↓
IT resource
    ↓
Modify permission
```

The Mover phase will only be marked fully completed after this IT resource authorization model is implemented and verified.

# Phase 3 — Leaver ⏳ PLANNED

The Leaver phase will securely deprovision Arjun after the Mover exercise is complete.

Planned controls include:

- Disable the Active Directory account.
- Revoke department/resource group memberships.
- Review remaining entitlements.
- Move the identity to an appropriate disabled-user location if configured.
- Record the offboarding action.
- Verify the identity can no longer be used for normal access.

# Overall Validation Checklist

- [x] Joiner identity provisioned.
- [x] Joiner Finance entitlement assigned through a security group.
- [x] Mover's obsolete Finance entitlement revoked.
- [x] Mover identity and organizational attributes updated.
- [x] New IT role entitlement assigned.
- [x] Post-move membership confirms Finance access was not retained.
- [ ] Complete IT resource authorization through AGDLP.
- [ ] Complete Mover phase.
- [ ] Disable Leaver account.
- [ ] Revoke Leaver entitlements.
- [ ] Complete final lifecycle access review.

# Evidence Captured

Lab evidence currently includes:

- Joiner membership showing `Domain Users` and `GG-Finance-Users`.
- Mover pre-change Finance membership review.
- Arjun moved into the IT OU.
- Updated IT / IAM Support Analyst identity attributes.
- Post-move ADUC membership showing `Domain Users` and `GG-IT-Users`, with the previous Finance group absent.

Screenshots can be added later as portfolio evidence without exposing passwords or sensitive credentials.

# Skills Demonstrated

- Active Directory user administration
- Joiner/Mover/Leaver lifecycle management
- Identity provisioning
- Identity attribute management
- Group-based access control
- RBAC concepts
- AGDLP
- Least-privilege implementation
- Entitlement management
- Access reviews
- Access revocation
- Privilege-creep prevention
- IAM operational documentation

## Lab Status

**Status: Joiner completed — Mover in progress (IT resource authorization next)**

---

> This project uses fictional employee identities in an isolated educational lab environment. No production credentials or sensitive organizational information are stored in this repository.
