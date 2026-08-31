# IAM Lab: User Lifecycle Management (JML)

This hands-on lab simulates a core Identity and Access Management process: **Joiner → Mover → Leaver (JML)**.

The objective is to practice how an IAM Engineer provisions identities, assigns access based on job responsibilities, modifies entitlements when an employee changes roles, and revokes access when an employee leaves the organization.

## Lab Environment

- Active Directory domain: `technova.local`
- Domain Controller: `TECHNOVA-DC01`
- Platform: Windows Server 2025 Active Directory Domain Services
- User OUs:
  - `TECHNOVA-Users/Finance`
  - `TECHNOVA-Users/HR`
  - `TECHNOVA-Users/IT`
  - `TECHNOVA-Users/Sales`
- Group OU: `technova-Groups`

## Lifecycle Scenario

The fictional employee used for this exercise is **Arjun Rao**.

Initial Joiner information:

| Attribute | Value |
| --- | --- |
| Employee | Arjun Rao |
| Username | `arjun.rao` |
| Department | Finance |
| Job Title | Financial Analyst |
| Company | TechNova |
| Email | `arjun.rao@technova.com` |
| Initial OU | `TECHNOVA-Users/Finance` |
| Standard Finance entitlement | `GG-Finance-Users` |

The complete exercise follows:

```text
JOINER
Arjun joins Finance
        ↓
Identity provisioned
        ↓
Finance entitlement assigned

MOVER
Arjun transfers to another department
        ↓
Finance access removed
        ↓
New department access assigned

LEAVER
Arjun leaves TechNova
        ↓
Account disabled
        ↓
Access revoked
        ↓
Identity deprovisioned
```

# Phase 1 — Joiner ✅ COMPLETED

## Objective

Provision a new Finance employee identity and grant only the access required for the employee's role.

## Implementation

The following Joiner actions were completed in Active Directory:

1. Created the user **Arjun Rao**.
2. Provisioned the account in `TECHNOVA-Users/Finance`.
3. Configured the username as `arjun.rao`.
4. Configured IAM-relevant identity attributes:
   - Department: `Finance`
   - Job Title: `Financial Analyst`
   - Company: `TechNova`
   - Email: `arjun.rao@technova.com`
5. Added Arjun to the Finance Global security group `GG-Finance-Users`.
6. Verified Arjun's group memberships in Active Directory Users and Computers.

Verified memberships:

```text
Arjun Rao
├── Domain Users
└── GG-Finance-Users
```

## Authorization Model

Arjun was not granted NTFS permissions directly. Access is provided through the existing AGDLP design:

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

This separates the employee identity from the resource permission and makes access easier to provision, review, change, and revoke.

## Joiner IAM Concepts Demonstrated

- Identity provisioning
- Identity attribute management
- Department-based placement
- Birthright/standard department access
- Security-group-based authorization
- RBAC concepts
- AGDLP
- Least privilege
- Authentication vs authorization
- Entitlement assignment

## Joiner Validation

- [x] Active Directory identity created.
- [x] User placed in the Finance OU.
- [x] Department and job information configured.
- [x] Finance entitlement assigned through `GG-Finance-Users`.
- [x] Group membership verified in ADUC.
- [x] Access assigned through a security group rather than directly to the employee account.

> End-user file-share validation remains a separate test because the Windows client VM has not yet been deployed successfully. The AD-side entitlement assignment has been verified.

# Phase 2 — Mover ⏳ NEXT

## Objective

Simulate Arjun transferring from Finance to another department and ensure that access changes follow least privilege.

### Planned Tasks

- Review Arjun's existing access before the role change.
- Update department/job attributes.
- Move the AD object to the new department OU where appropriate.
- Remove `GG-Finance-Users` membership.
- Assign the new department security group(s).
- Verify Finance entitlement removal.
- Verify the new department entitlement.
- Confirm that obsolete access does not remain and create privilege creep.

### IAM Concepts

- Access modification
- Entitlement review
- Role change
- Least privilege
- Access revocation
- Prevention of privilege/access creep

# Phase 3 — Leaver ⏳ PLANNED

## Objective

Securely deprovision Arjun when employment ends.

### Planned Tasks

- Disable the Active Directory account.
- Revoke department/resource group memberships.
- Review remaining access assignments.
- Move the account to an appropriate disabled-user location if configured.
- Record the offboarding action.
- Verify that the identity can no longer be used for normal access.

### IAM Concepts

- Identity deprovisioning
- Access revocation
- Account disablement
- Offboarding controls
- Orphaned-account prevention
- Auditability

# Overall Validation Checklist

- [x] Joiner identity provisioned.
- [x] Joiner receives the correct AD entitlement based on department/job requirements.
- [x] Joiner access assigned through security groups rather than direct resource permissions.
- [ ] Mover loses access that is no longer required.
- [ ] Mover receives access appropriate to the new role.
- [ ] Old permissions do not remain and create privilege creep.
- [ ] Leaver account is disabled promptly.
- [ ] Unnecessary group memberships are removed during offboarding.
- [ ] Lifecycle actions are documented for audit purposes.

# Evidence

Joiner implementation evidence captured during the lab includes:

- Arjun Rao present in the Finance OU.
- Identity attributes configured for the Finance Financial Analyst role.
- ADUC `Member Of` verification showing `Domain Users` and `GG-Finance-Users`.

Screenshots can be added to this repository later as portfolio evidence without exposing passwords or sensitive credentials.

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
- IAM operational documentation

## Lab Status

**Status: Joiner completed — Mover next**

---

> This project uses fictional employee identities in an isolated educational lab environment. No production credentials or sensitive organizational information are stored in this repository.
