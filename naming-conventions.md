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




**Azure Resource Naming Convention (Enterprise-Ready)**

### Recommended General Convention

**`{resource-type}-{environment}-{purpose}-{region}-{sequence}`**

This is the most widely adopted, readable, and scalable pattern used by many organizations.

### Component Breakdown

| Component       | Examples                          | Recommended Length | Purpose |
|-----------------|-----------------------------------|--------------------|-------|
| **Resource Type** | `rg`, `kv`, `vnet`, `snet`, `vm`, `app`, `sql`, `st`, `aks` | 2-6 | Quick identification of resource type |
| **Environment**   | `dev`, `test`, `stg`, `uat`, `prod`, `dr` | 3-4 | Governance, security, cost separation |
| **Purpose**       | `shared`, `app1`, `web`, `data`, `infra`, `main` | 3-12 | Business or functional context |
| **Region**        | `weu`, `eus`, `sea`, `wus2`, `ne` | 3-5 | Geographic location (use short codes) |
| **Sequence**      | `001`, `01`, or omitted            | 2-3 | For multiple similar resources |

---

### Official Azure Resource Type Abbreviations

Here’s a standardized abbreviation list for the most common Azure resources:

| Resource                        | Abbreviation | Example |
|-------------------------------|--------------|--------|
| Resource Group                | `rg`         | `rg-prod-shared-weu` |
| Key Vault                     | `kv`         | `kv-prod-app-weu001` |
| Storage Account               | `st`         | `stprodsharedweu001` (no hyphens allowed) |
| Virtual Network               | `vnet`       | `vnet-prod-main-weu` |
| Subnet                        | `snet`       | `snet-prod-app-weu` |
| Network Security Group        | `nsg`        | `nsg-prod-web-weu` |
| Public IP                     | `pip`        | `pip-prod-app-weu` |
| Load Balancer                 | `lb`         | `lb-prod-web-weu` |
| Application Gateway           | `agw`        | `agw-prod-api-weu` |
| Virtual Machine               | `vm`         | `vm-prod-app01-weu` |
| Azure Kubernetes Service      | `aks`        | `aks-prod-main-weu` |
| App Service Plan              | `plan`       | `plan-prod-web-weu` |
| App Service / Web App         | `app`        | `app-prod-web-weu` |
| Function App                  | `func`       | `func-prod-order-weu` |
| SQL Database Server           | `sql`        | `sql-prod-main-weu` |
| Cosmos DB                     | `cosmos`     | `cosmos-prod-data-weu` |
| Azure SQL Database            | `sqldb`      | `sqldb-prod-app-weu` |
| Log Analytics Workspace       | `log`        | `log-prod-shared-weu` |
| Application Insights          | `appi`       | `appi-prod-web-weu` |
| API Management                | `apim`       | `apim-prod-api-weu` |
| Front Door                    | `fd`         | `fd-prod-global` |
| Container Registry            | `cr`         | `crprodsharedweu` |

---

### Real-World Examples

**Resource Group**  
`rg-prod-shared-weu`  
`rg-dev-finance-eus`

**Networking**  
`vnet-prod-main-weu`  
`snet-prod-app-weu`  
`nsg-prod-web-weu`

**Compute & Containers**  
`vm-prod-app01-weu`  
`aks-prod-main-weu01`

**Data & Storage**  
`stprodsharedweu001` *(no hyphens)*  
`kv-prod-secrets-weu`  
`cosmos-prod-data-weu`

**Application**  
`app-prod-web-weu`  
`func-prod-notification-weu`  
`plan-prod-backend-weu`

---

### Important Resource-Specific Rules

| Resource Type       | Special Rules |
|---------------------|---------------|
| **Storage Account** | Lowercase only, **no hyphens**, max 24 characters |
| **Key Vault**       | 3-24 chars, alphanumeric + hyphens |
| **Virtual Machine** | Can include numbers for instances (`vm-prod-app01`) |
| **Global Resources** (Front Door, Traffic Manager, etc.) | Use `global` instead of region: `fd-prod-global` |

---

### Best Practices

1. **Use lowercase** for everything (except where not allowed).
2. **Be consistent** across all environments and teams.
3. **Apply Tags** (very important):
   - `Environment`, `Purpose`, `Owner`, `Application`, `CostCenter`, `CreatedBy`
4. **Keep names under 24-40 characters** when possible for readability.
5. **Document** this convention in your Azure Landing Zone / Cloud Adoption Framework docs.
6. **Enforce via Azure Policy** (highly recommended).

---

**Would you like me to**:

- Generate a full Excel/CSV reference table for all major Azure services?
- Create a version tailored to your company (e.g., with company prefix like `contoso-`)?
- Provide Bicep/Terraform module examples using this convention?
- Make a shorter or longer version based on your scale?

Let me know your environment size, number of teams, or any specific preferences!
