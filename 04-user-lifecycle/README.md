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

## Scenario

A fictional employee joins TechNova and progresses through the complete identity lifecycle.

The exercise will demonstrate three IAM lifecycle events:

```text
JOINER
New employee joins Finance
        ↓
Identity provisioned
        ↓
Department access assigned

MOVER
Employee transfers to another department
        ↓
Old access removed
        ↓
New role/department access assigned

LEAVER
Employee leaves the organization
        ↓
Account disabled
        ↓
Access revoked
        ↓
Account moved to appropriate disabled-user location
```

# Phase 1 — Joiner

## Objective

Provision a new employee identity and grant only the access required for the employee's job.

### Planned Tasks

- Create a new Active Directory user.
- Place the identity in the correct department OU.
- Configure the employee's basic identity attributes.
- Assign the appropriate department security group.
- Verify inherited/group-based access.
- Confirm the user does not receive unnecessary access.

### IAM Concepts

- Identity provisioning
- Birthright access
- Role/group-based access assignment
- Least privilege
- Security group membership
- Authentication vs authorization

# Phase 2 — Mover

## Objective

Simulate an employee transferring from one department to another.

### Planned Tasks

- Update the employee's department information.
- Move the AD object to the new department OU when appropriate.
- Review existing group memberships.
- Remove access that is no longer required.
- Assign the new department's security group(s).
- Verify that previous department access has been revoked.
- Verify that new department access is available.

### IAM Concepts

- Access modification
- Entitlement review
- Role change
- Least privilege
- Access revocation
- Prevention of access accumulation / privilege creep

# Phase 3 — Leaver

## Objective

Securely deprovision the employee when employment ends.

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

# Validation Checklist

The completed lab should demonstrate that:

- [ ] A Joiner receives the correct access based on department/job requirements.
- [ ] Access is assigned through security groups rather than directly wherever possible.
- [ ] A Mover loses access that is no longer required.
- [ ] A Mover receives access appropriate to the new role.
- [ ] Old permissions do not remain and create privilege creep.
- [ ] A Leaver account is disabled promptly.
- [ ] Unnecessary group memberships are removed during offboarding.
- [ ] The lifecycle actions are documented for audit purposes.

# Evidence to Capture

As the lab is implemented, screenshots and implementation notes can be added showing:

1. User creation and department OU placement.
2. User properties and relevant identity attributes.
3. Joiner security-group membership.
4. Mover group-membership changes.
5. Removal of previous department access.
6. Assignment of new department access.
7. Disabled account during the Leaver phase.
8. Final group-membership/access review.

# Skills Demonstrated

Completing this project will provide hands-on evidence of:

- Active Directory user administration
- Joiner/Mover/Leaver lifecycle management
- Identity provisioning and deprovisioning
- Group-based access control
- RBAC concepts
- Least-privilege implementation
- Entitlement management
- Access reviews
- Account offboarding
- IAM operational documentation

## Lab Status

**Status: Planned / Implementation in progress**

The README defines the implementation plan before configuration changes are performed. It will be updated with actual results and evidence as each lifecycle phase is completed.

---

> This project uses fictional employee identities in an isolated educational lab environment. No production credentials or sensitive organizational information are stored in this repository.
