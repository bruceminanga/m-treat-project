## 🧪 Friction-Driven Experiments (Testing Operational Pain)

> *"Don't add abstractions until you feel the friction."*  
> Use these self-directed challenges to test the limits of this baseline architecture and experience real-world DevOps friction firsthand.

---

### 🔬 Experiment 1: The Multi-Environment Clone Challenge
* **The Goal:** Attempt to deploy an identical `staging` environment alongside `dev` without deleting the current infrastructure.
* **The Action:** Try running the configuration with a different environment name or workspace.
* **💥 Friction Hit:** 
  - S3 bucket name collision (`BucketAlreadyExists`).
  - IAM role name collision (`EntityAlreadyExists`).
  - State file overwrite collision (`dev/terraform.tfstate`).
* **💡 The Lesson / Fix:** Learn why we parameterize resource names with variables (e.g., `bucket = "my-app-${var.environment}-media"`) and dynamic backend state keys.

---

### 🔬 Experiment 2: The Isolated Teardown Challenge
* **The Goal:** Destroy and recreate the EC2 server (simulating a corrupted VM) **without** deleting the S3 media bucket or VPC.
* **The Action:** Run `tflocal destroy` or attempt targeted destruction.
* **💥 Friction Hit:** 
  - `terraform destroy` wipes the entire infrastructure (network, storage, and server) all at once.
  - Targeted destruction (`-target`) is manual, messy, and error-prone.
* **💡 The Lesson / Fix:** Learn why production architectures split monolithic state files into decoupled layers (e.g., `01-networking/`, `02-storage/`, `03-compute/`).

---

### 🔬 Experiment 3: The Code Reusability Challenge
* **The Goal:** Start a second application (e.g., a new microservice) that requires the same VPC and S3 setup.
* **The Action:** Create a new folder and set up networking from scratch.
* **💥 Friction Hit:** 
  - Copy-pasting 100+ lines of boilerplate VPC, Subnet, Route Table, and S3 configuration.
  - Maintaining fixes across multiple duplicate files.
* **💡 The Lesson / Fix:** Learn when it is actually time to extract resources into reusable **Terraform Modules**.

---

### 🚀 Refactor & Level Up Checklist
- [ ] Make resource names dynamic using `var.environment`
- [ ] Decouple storage state from compute state
- [ ] Extract repeated networking code into a reusable module
- [ ] Add AWS Secrets Manager for runtime secret injection