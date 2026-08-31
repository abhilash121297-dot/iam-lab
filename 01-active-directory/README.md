# Active Directory IAM Lab

This lab simulates identity and access management tasks in a Windows Active Directory environment. The goal is to build practical IAM engineering skills around directory structure, users, security groups, RBAC-style access assignment, least privilege, and the AGDLP permission model.

## Lab Environment

- Hypervisor: Oracle VirtualBox
- Domain Controller: `TECHNOVA-DC01`
- Server OS: Windows Server 2025 Standard Evaluation (Desktop Experience)
- Active Directory domain: `technova.local`
- DNS: Active Directory-integrated DNS installed with AD DS
- Lab network: VirtualBox Internal Network `technova-lab`

## Active Directory Structure

The following organizational structure has been created in `technova.local`:

```text
technova.local
├── TECHNOVA-Users
│   ├── Finance
│   ├── HR
│   ├── IT
│   └── Sales
├── technova-Groups
├── technova-Computers
└── technova-ServiceAccounts
```

This structure separates users, groups, computers, and service identities and provides department-level organization for lifecycle and access-management exercises.

## Test Identity

A test employee identity was created for the Finance department:

- Display name: `Priya Sharma`
- Department OU: `TECHNOVA-Users/Finance`
- Intended sign-in identity: `priya.sharma`

The account is used to demonstrate group-based authorization rather than assigning resource permissions directly to an individual user.

## Finance Access Model

Security groups created:

- `GG-Finance-Users` — Global group representing Finance users
- `DL-Finance-Share-RW` — Domain Local group representing Modify access to the Finance file share

The access chain follows Microsoft's AGDLP model:

```text
Priya Sharma
    ↓ member of
GG-Finance-Users
    ↓ member of
DL-Finance-Share-RW
    ↓ granted Modify
C:\Shares\Finance
```

**AGDLP:** Accounts → Global Groups → Domain Local Groups → Permissions.

This makes access easier to manage and demonstrates an IAM/RBAC principle: permissions are assigned to access groups, while identities receive access through role/group membership.

## Finance File Share

A Finance resource was created on the domain controller:

```text
Local path: C:\Shares\Finance
UNC path:   \\TECHNOVA-DC01\Finance
```

The NTFS permission design was hardened to avoid broad user access.

Configured permissions:

| Principal | Permission | Scope |
| --- | --- | --- |
| `Administrators` | Full Control | This folder, subfolders and files |
| `SYSTEM` | Full Control | This folder, subfolders and files |
| `DL-Finance-Share-RW` | Modify | This folder, subfolders and files |
| `CREATOR OWNER` | Full Control | Subfolders and files only |

Broad `Users` access was removed and inheritance was disabled so Finance access is controlled through the dedicated domain-local access group.

## IAM Concepts Demonstrated

- Active Directory Domain Services deployment
- Domain and forest creation
- DNS integration
- Organizational Unit design
- User provisioning
- Security group creation
- Global vs Domain Local group scopes
- Nested group membership
- AGDLP permission model
- Group-based authorization
- Role-based access concepts
- Least privilege
- NTFS permissions
- Department resource access design

## Current Status

Completed:

- Windows Server 2025 domain controller deployed
- `technova.local` forest/domain created
- Department and IAM-related OUs created
- Finance test user created
- Finance Global and Domain Local security groups created
- AGDLP group nesting configured
- Finance shared folder created
- NTFS permissions restricted to the Finance access group

Pending:

- Windows client domain join
- End-user Finance share access validation
- Negative access test using a non-Finance user
- Joiner/Mover/Leaver lifecycle exercises
- PowerShell IAM automation
- Microsoft Entra ID labs

## Next Lab

The next Active Directory exercise will simulate the **Joiner → Mover → Leaver (JML)** identity lifecycle process. It will demonstrate provisioning, entitlement changes, access revocation, account disablement, and IAM documentation.

---

> This is an educational lab environment using fictional identities and an isolated test domain. No production credentials or sensitive organizational data are stored in this repository.
