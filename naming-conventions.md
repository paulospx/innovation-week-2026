**Azure Key Vault Naming Convention**

### Recommended Naming Convention

**`kv-{environment}-{purpose}-{region}-{sequence}`**

Or the slightly shorter version (if you prefer brevity):

**`kv-{env}-{purpose}-{region}{seq}`**

### Breakdown & Reasoning

| Component     | Format          | Length | Purpose / Reasoning |
|---------------|-----------------|--------|---------------------|
| **Prefix**    | `kv-`           | 3      | Clearly identifies the resource type as a Key Vault. Makes it instantly recognizable in lists, monitoring, and IaC. |
| **Environment** | `dev`, `test`, `stg`, `uat`, `prod`, `dr` | 3-4 | Critical for governance, cost allocation, RBAC, and policy application. Avoids mixing production secrets with dev ones. |
| **Purpose**   | Short descriptor (e.g. `app`, `shared`, `infra`, `data`, `api`, `web`) | 3-8 | Describes the business or technical purpose. Helps teams quickly understand what the vault is for. |
| **Region**    | `weu`, `eus`, `sea`, `wus2`, etc. (Azure region short codes) | 3-5 | Important when you have multi-region deployments. Helps with disaster recovery and geo-redundancy visibility. |
| **Sequence**  | `001`, `01`, or nothing if only one exists | 2-3 | Allows multiple vaults for the same purpose (e.g. different applications or sharded vaults). |

**Why this structure?**
- **Readability**: Human-friendly when scanning hundreds of resources in the Azure Portal, Azure CLI, PowerShell, or Terraform/Bicep.
- **Sorting**: Components are ordered from most general (environment) to most specific.
- **Compliance & Security**: Clear separation of environments reduces risk of accidental cross-environment access.
- **Scalability**: Supports growth without name collisions.
- **Azure Limits**: Key Vault names must be **3-24 characters**, alphanumeric + hyphens. This convention stays safely under the limit in most cases.

### Examples

| Environment | Purpose              | Region     | Sequence | Full Name                  | Notes |
|-------------|----------------------|------------|----------|----------------------------|-------|
| Production  | Shared services      | West Europe| -        | `kv-prod-shared-weu`       | Central vault for common secrets |
| Production  | Customer app         | East US    | 01       | `kv-prod-app-eus01`        | Main application vault |
| Development | Web frontend         | West Europe| -        | `kv-dev-web-weu`           | Dev environment |
| Staging     | Data platform        | Southeast Asia | 001  | `kv-stg-data-sea001`       | First data vault in SEA |
| Production  | Infrastructure       | West US 2  | -        | `kv-prod-infra-wus2`       | For Terraform state keys, etc. |
| DR          | Application recovery | North Europe | -      | `kv-dr-app-neu`            | Disaster Recovery vault |

### Alternative Conventions (Depending on Your Needs)

1. **Even Shorter** (very common in small/medium orgs):
   - `kv-{env}-{appname}`
   - Examples: `kv-prod-contoso`, `kv-dev-eshop`

2. **Project-Centric**:
   - `kv-{project}-{env}-{purpose}`
   - Examples: `kv-acme-prod-certs`, `kv-finance-dev-secrets`

3. **Team/Department Based**:
   - `kv-{team}-{env}-{purpose}`
   - Examples: `kv-platform-prod-shared`, `kv-payments-stg-keys`

### Best Practices & Tips

- **Always use lowercase** (Azure is case-insensitive for Key Vault names but consistency matters).
- **Be consistent** across your entire estate (Terraform modules, Bicep, Policy, etc.).
- **Document it** in your Cloud Center of Excellence / Landing Zone documentation.
- **Add metadata** via tags:
  - `Environment`, `Purpose`, `Owner`, `Application`, `CreatedBy`, etc.
- **Avoid** including sensitive words or actual secret names in the vault name.
- **Global uniqueness**: Key Vault names are **globally unique** across all Azure subscriptions, so the convention helps prevent collisions.

Would you like me to adjust this convention based on your specific context (e.g., number of subscriptions, use of Azure Landing Zones, team structure, or preference for shorter names)?
