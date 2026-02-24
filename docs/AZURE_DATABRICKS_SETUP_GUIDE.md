# Tableflow on Azure with Databricks

End-to-end walkthrough for setting up Confluent Cloud Tableflow with Azure Data Lake Storage Gen2 and Databricks Unity Catalog.

---

## Prerequisites

Before you begin, make sure you have:

- A **Confluent Cloud** account
- An **Azure subscription** with permissions to create resources
- **Azure CLI** installed and logged in (`az login`)
- A **Databricks workspace** on Azure (Premium tier required for Unity Catalog)
- Access to the **Databricks Account Console** (https://accounts.azuredatabricks.net)

---

## Part 1 -- Confluent Cloud Setup

### 1.1 Create an Environment

1. Go to [Confluent Cloud](https://confluent.cloud) and create a new environment
2. Click **Add environment**
3. Name it (e.g., `tableflow-azure-demo`)
4. Click **Create**

### 1.2 Create a Kafka Cluster

Inside your new environment, create an Azure-region Kafka cluster.

1. Click **Create cluster**
2. Select cluster type (Basic or Standard)
3. Cloud provider: **Azure**
4. Region: **East US** (or whichever region you plan to use for Azure resources)
5. Name the cluster and click **Launch cluster**

### 1.3 Create a Datagen Connector

Add a sample data source so you have messages flowing through Tableflow.

1. Go to **Connectors** > **+ Add connector**
2. Search for **Datagen Source** and select it
3. Configure the connector:

| Setting | Value |
|---------|-------|
| Topic | `stock_trades` |
| Output record value format | `AVRO` |
| Quickstart | `STOCK_TRADES` |
| Max interval (ms) | `10` |
| Tasks | `1` |

4. Click **Launch**

Optionally repeat with topic `users` and quickstart `USERS`.

---

## Part 2 -- Azure Storage Setup

### 2.1 Create an ADLS Gen2 Storage Account

1. Go to **Azure Portal** > **Storage accounts** > **+ Create**
2. Fill in the **Basics** tab:

| Setting | Value |
|---------|-------|
| Resource group | `tableflow-rg` (create if needed) |
| Storage account name | `tableflowtutorial...` must be unique globally |
| Region | Same as your Kafka cluster (e.g., East US) |
| Preferred Storage Type | Azure Blob Storage or Azure Data Lake Storage Gen 2 |
| Primary Workload | Big Data Analytics ** Required for tableflow to be hierarchical |
| Performance | Standard |
| Redundancy | ZRS |

5. Click **Review + Create** > **Create**

### 2.2 Create a Container

1. Open the new storage account
2. Go to **Containers** > **+ Container**
3. Name: `tableflow-data` (or similar)
4. Access level: **Private**
5. Click **Create**

> **Important:** The container must be empty. Pre-existing objects can cause Tableflow to fail.

---

## Part 3 -- Connect Azure to Confluent

### 3.1 Create a Provider Integration in Confluent

1. In Confluent Cloud, go to your environment
2. Navigate to **Provider Integrations**
3. Click **+ Add provider integration**
4. Select **Microsoft Entra ID**
5. Give the Provider Integration a name like 'Azure Tableflow Provider Integration'
6. Click Continue

7. Click `Create Entra ID app` in order to Generate an Entra ID app in Confluent’s environment. It will be used to create a service principal to access Azure services.



> Keep this page open. You will return to enter the Tenant ID in step 3.4.

### 3.2 Create the Service Principal in Azure

The Application ID from the previous step represents Confluent's multi-tenant application. You need to register it in your Azure tenant.

```sh
az login
az ad sp create --id <APPLICATION_ID>
```
You can run this in Azure Cloudshell without needing to login.

From the output, note:
- `appDisplayName` -- starts with `cspi-...` (e.g., `cspi-abcd1234`)
- `id` -- the object ID (needed for role assignments)

### 3.3 Assign IAM Roles to the Confluent Service Principal

Confluent needs two roles to access your storage.

**Role 1: Reader** -- assigned at the **Subscription** level

1. Azure Portal > **Subscriptions** > select yours
2. **Access Control (IAM)** > **+ Add role assignment**
3. Role: **Reader** > Next
4. **+ Select Members** > search `cspi-...` > select > **Review + Assign**

**Role 2: Storage Blob Data Contributor** -- assigned at the **Storage Account** level

1. Azure Portal > **Storage accounts** > select yours
2. **Access Control (IAM)** > **+ Add role assignment**
3. Role: **Storage Blob Data Contributor** > Next
4. **+ Select Members** > search `cspi-...` > select > **Review + Assign**

| Role | Scope | Purpose |
|------|-------|---------|
| Reader | Subscription | Read Azure resource metadata |
| Storage Blob Data Contributor | Storage Account | Read/write blob data |

### 3.4 Provide Tenant ID to Confluent

1. Azure Portal > **Microsoft Entra ID**
2. Copy the **Tenant ID** from the Overview page
3. Return to the Confluent provider integration page from step 3.1
4. Paste the Tenant ID
5. Click **Validate** -- the connection should succeed

---

## Part 4 -- Enable Tableflow

### 4.1 Enable Tableflow on Your Topic

1. In Confluent Cloud, go to your cluster > **Topics** > select `stock_trades`
2. Click **Enable Tableflow**
3. Configure:

| Setting | Value |
|---------|-------|
| Provider integration | The integration from step 3.1 |
| Storage account name | Your storage account from step 2.1 |
| Container name | Your container from step 2.2 |

4. Continue & Launch
5. Wait for data to appear in Azure storage (typically 5-10 minutes)
6. Verify by checking the container in Azure Portal -- you should see new files

---

## Part 5 -- Databricks + Unity Catalog Integration

### 5.1 Create an Access Connector for Azure Databricks

An Access Connector provides a managed identity that lets Databricks access ADLS Gen2 without service principal secrets.

1. Azure Portal > **+ Create a resource**
2. Search for **"Access Connector for Azure Databricks"**
3. Click **Create** and fill in:

| Setting | Value |
|---------|-------|
| Subscription | Same as your storage account |
| Resource group | Same as your storage account (e.g., `tableflow-rg`) |
| Name | e.g., `tableflow-access-connector` |
| Region | Same as your storage account |

4. On the **Managed Identity** tab, set **System-assigned** to **On**
5. Click **Review + Create** > **Create**

After creation, open the resource and copy the **Resource ID** from the Overview page. It looks like:

```
/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Databricks/accessConnectors/<name>
```

### 5.2 Grant Storage Roles to the Access Connector

The Access Connector's managed identity needs two roles on the storage account.

1. Azure Portal > your **Storage Account** > **Access Control (IAM)** > **+ Add role assignment**
2. Assign access to: **Managed Identity**
3. **+ Select Members** > Managed identity dropdown: **"Access Connector for Azure Databricks"** > select yours
4. Repeat for each role:

| # | Role | Purpose |
|---|------|---------|
| 1 | Storage Blob Data Contributor | Read/write blob data |
| 2 | Storage Queue Data Contributor | Storage queues used by the file events pipeline |

**CLI shortcut:**

```sh
ASSIGNEE="<access-connector-managed-identity-object-id>"
SCOPE="/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<account>"

for ROLE in "Storage Blob Data Contributor" "Storage Queue Data Contributor"; do
  az role assignment create --assignee "$ASSIGNEE" --role "$ROLE" --scope "$SCOPE"
done
```

To find the managed identity object ID: Access Connector > **Identity** > copy the **Object ID**.

> **Note:** Role assignments can take up to 10 minutes to propagate.

### 5.3 Create a Storage Credential in Databricks

1. Open your Databricks workspace
2. Sidebar > **Catalog** > **External data** > **Credentials** tab
3. Click **Create credential**

| Setting | Value |
|---------|-------|
| Credential type | Storage credential |
| Auth type | Azure Managed Identity |
| Name | e.g., `tableflow-storage-credential` |
| Access Connector ID | The Resource ID from step 5.1 |

4. Click **Create**

### 5.4 Create an External Location in Databricks

1. **Catalog** > **External data** > **External Locations** tab
2. Click **Create location**

| Setting | Value |
|---------|-------|
| Name | e.g., `tableflow-external-location` |
| Storage type | Azure Data Lake Storage |
| URL | `abfss://<container>@<storage-account>.dfs.core.windows.net/` |
| Storage credential | The credential from step 5.3 |

> **The trailing `/` in the URL is required.** Without it, the connection test may fail.

3. Click **Create**

If creation fails on validation, try force-creating the external location (skip validation). It will still work.

4. Click **Test connection**

Expected results:

| Check | Expected |
|-------|----------|
| Read | Success |
| List | Success |
| Write | Success |
| Delete | Success |
| Path Exists | Success |
| Hierarchical Namespace Enabled | Success |
| File Events Resource Provision | Success (may require force-create) |
| File Events Resource Teardown | Success (may require force-create) |

> If the File Events checks fail but all others pass, you can force-create the external location and it will still work for Tableflow. The File Events checks relate to Event Grid notifications which are not strictly required.

### 5.5 Create a Catalog in Databricks

1. **Catalog** > **+ Add** > **Add a catalog**
2. Name: e.g., `tableflow-catalog`
3. Set **Storage location** to the external location from step 5.4
4. Click **Create**

### 5.6 Create a Databricks Service Principal

This service principal will be used by Confluent to authenticate with Databricks and register tables in Unity Catalog.

1. Go to the top right of the Databricks workspace with your photo or initial, and select Settings > Identity and Access > Service Principals (Manage)
3. Click **Add service principal** and select Databricks Managed
4. Name: e.g., `tableflow-confluent-sp`
5. Click **Add**

### 5.7 Generate an OAuth Secret


1. Click on the service principal from step 5.6
2. Go to the **Secrets** tab
3. Click **Generate secret** and pick a Lifetime (# of days)
4. Copy the **Client ID** and **Secret** immediately

> **The secret is only shown once.** Save both values securely. These are the credentials you will enter in the Confluent catalog integration.


### 5.8 Grant Permissions to the Service Principal

The service principal needs permissions on the **storage credential**, **external location**, and **catalog**. All three are required.

**Option A: Via SQL Editor**

```sql
-- Storage credential permissions
GRANT ALL_PRIVILEGES, MANAGE
ON STORAGE CREDENTIAL `tableflow-storage-credential`
TO `<service-principal-application-id>`;

-- External location permissions
GRANT ALL_PRIVILEGES, MANAGE, EXTERNAL_USE_LOCATION,
      CREATE_EXTERNAL_TABLE, READ_FILES, WRITE_FILES
ON EXTERNAL LOCATION `tableflow-external-location`
TO `<service-principal-application-id>`;

-- Catalog permissions
GRANT ALL_PRIVILEGES, EXTERNAL_USE_SCHEMA, MANAGE,
      CREATE_SCHEMA, CREATE_TABLE, SELECT,
      USE_CATALOG, USE_SCHEMA
ON CATALOG `tableflow-catalog`
TO `<service-principal-application-id>`;

-- Allow all account users to browse the catalog
GRANT ALL_PRIVILEGES, BROWSE, EXTERNAL_USE_SCHEMA, MANAGE
ON CATALOG `tableflow-catalog`
TO `account users`;

-- Allow all account users to use the external location
GRANT ALL_PRIVILEGES, EXTERNAL_USE_LOCATION, MANAGE
ON EXTERNAL LOCATION `tableflow-external-location`
TO `account users`;
```

**Option B: Via Catalog UI**

For each resource (storage credential, external location, catalog), go to its **Permissions** tab and add the service principal with the privileges listed above.

> **Common mistake:** Granting only `ALL_PRIVILEGES` is not sufficient. Databricks does not include `EXTERNAL_USE_SCHEMA`, `EXTERNAL_USE_LOCATION`, or `MANAGE` under `ALL_PRIVILEGES`. You must grant these explicitly.

---

## Part 6 -- Connect It All Together

### 6.1 Set Up Tableflow Catalog Integration in Confluent

1. In Confluent Cloud, go to your environment > **Tableflow** > **Catalog Integration**
2. Click **+ Add catalog integration**
3. Select **Databricks Unity Catalog**
4. Enter:

| Setting | Value |
|---------|-------|
| Host | Your Databricks workspace URL (e.g., `adb-123456.18.azuredatabricks.net`) |
| Client ID | From step 5.7 |
| Client Secret | From step 5.7 (the **Databricks OAuth secret**, not an Azure AD secret) |
| Catalog | The catalog name from step 5.5 |

5. Click **Save and Validate**

> **If you get a 401 error:** Double-check that you are using the Databricks OAuth secret (generated in the Databricks Account Console), not an Azure AD client secret. This is the most common cause of authentication failures.

---

## Verification

Once the catalog integration validates, Confluent will automatically register your Kafka topics as tables in Databricks Unity Catalog.

**Verify in Databricks:**

1. Open your workspace
2. Go to **Catalog** > select the catalog you specified
3. You should see schemas/tables corresponding to your Kafka topics
4. Run a test query:

```sql
SELECT * FROM <catalog>.<schema>.stock_trades LIMIT 10;
```

**Checklist:**

- [ ] Confluent datagen connector is running and producing messages
- [ ] Tableflow shows data flowing to Azure storage
- [ ] Azure container has Iceberg/Delta files
- [ ] Databricks external location test passes
- [ ] Catalog integration in Confluent shows **SUCCESSFUL** status
- [ ] Tables appear in Databricks Unity Catalog
- [ ] You can query the data from Databricks

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| **401 error on catalog integration** | You are using the wrong secret. Use the **Databricks OAuth M2M secret** (generated in Databricks Account Console > Service Principal > Secrets tab), not an Azure AD client secret. Confluent authenticates via the Databricks `/oidc/v1/token` endpoint. |
| **Tableflow fails to write data** | Verify hierarchical namespace is enabled on the storage account. Ensure the container is empty. Check that the Confluent service principal (`cspi-...`) has Storage Blob Data Contributor on the storage account. |
| **External location test fails on Read/Write/Delete** | Verify the Access Connector has Storage Blob Data Contributor on the storage account. Ensure the Access Connector and storage account are in the same region. |
| **External location test fails on File Events** | Force-create the external location -- it will still work for Tableflow. If you want the checks to pass, ensure Storage Queue Data Contributor is assigned and wait 10 minutes for propagation. |
| **Catalog integration stuck in PENDING** | Wait 5-10 minutes for data to materialize in storage. Verify the datagen connector is running. Check service principal credentials. |
| **Permission errors in Databricks** | Verify the service principal is added to the workspace. Check that grants include `EXTERNAL_USE_SCHEMA`, `EXTERNAL_USE_LOCATION`, and `MANAGE` -- these are **not** included in `ALL_PRIVILEGES` and must be granted explicitly. |
| **External location URL error** | Ensure the URL has a trailing `/` after `.dfs.core.windows.net`. |
| **Duplicate service principals** | If you see multiple SPs with the same name in Databricks after reprovisioning, delete the stale ones from the Databricks UI. Only the one matching your current Client ID is needed. |

---

## Automating with Terraform

This entire setup can be automated using the Terraform configuration in this repository. The Terraform config auto-provisions:

- ADLS Gen2 storage account and container
- Azure AD service principal with Storage Blob Data Contributor role
- Databricks workspace (Premium SKU)
- Access Connector with managed identity
- Unity Catalog metastore, storage credential, external location, and catalog
- All required grants (including `EXTERNAL_USE_SCHEMA`, `MANAGE`, `EXTERNAL_USE_LOCATION`, etc.)
- Databricks OAuth M2M secret
- Confluent environment, Kafka cluster, datagen connectors, and Tableflow topic

See the [main README](../README.md) for Terraform usage instructions.

After `terraform apply`, retrieve the catalog integration credentials:

```sh
terraform output azure_databricks_workspace_url   # Host
terraform output databricks_sp_client_id           # Client ID
terraform output databricks_oauth_secret           # Client Secret (Databricks OAuth M2M)
terraform output databricks_catalog_name           # Catalog
```
