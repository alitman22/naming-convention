# Boring is Beautiful: A Senior Engineer's Guide to Infrastructure Naming Conventions

**Author:** Ali Fattahi  
**Role:** Senior Linux System Administrator / DevOps & Infrastructure Engineer  

---

## 📖 The Philosophy

In the rush to get an MVP out the door or spin up a proof-of-concept, infrastructure naming is usually the first casualty. Things get named `test-api-new`, `db-temp`, or worse, after a developer's favorite movie character. 

As a Senior DevOps & Infrastructure Engineer, I have seen firsthand how "we'll fix it later" technical debt turns into an operational nightmare. When your infrastructure scales from 10 servers to 1,000, naming conventions stop being a cosmetic preference and become the foundational taxonomy of your entire platform. Inconsistent naming breaks automation, destroys observability, and dramatically increases cognitive load during incident response.

This repository outlines the standards, psychological compromises, and automated enforcements required to build scalable, predictable, and "boring" infrastructure.

---

## 🚫 The Anti-Pattern: The "Middle-Earth" Infrastructure

Every SRE has fought this battle: a development team decides to theme their microservices. Suddenly, you are managing `gondor`, `sauron`, and `gandalf`. 

While it might seem fun during sprint planning, themed names fail catastrophically in production for three reasons:

1. **The Cognitive Load Tax:** At 3:00 AM during a Sev-1 outage, you do not have the mental bandwidth to remember if `gandalf` is the authentication database or the email-sending worker. 
2. **The Onboarding Nightmare:** When the developer who named the service quits, new hires are forced to memorize arbitrary trivia just to read an architecture diagram.
3. **Finite Scalability:** Themes run out. If you pick "The Avengers," you eventually scale to 150 microservices and end up with critical services named after background characters nobody recognizes.

---

## 💥 Real-World Frustration: Why Bad Naming Breaks Automation

To understand the impact of poor naming, look at monitoring and observability. 

In a past scaling phase, my team hit a bottleneck: we were manually adding Grafana alerts for every new resource and metric. As our infrastructure grew, this manual toil became unsustainable. The goal was to dynamically discover new VMs and services using PromQL regex patterns. 

**The roadblock?** Because services lacked a unified naming standard, a clean dynamic query was impossible. I had to pause the automation effort entirely to collaborate with development teams and refactor the naming methodologies of systemd units and VMs. 

**The result:** Once we standardized, a single PromQL query like `{job=~"prod-.*-billing-.*"}` could instantly capture all production billing components. New servers were automatically monitored the second they joined the cluster. Good naming unlocked scalable automation.

---

## 🏗️ The Anatomy of a Standardized Name

A robust naming convention should answer the most critical questions about a resource just by looking at it. 

### The Standard Pattern
Names should be delimited by hyphens (`-`) and flow from macro to micro:

`[Environment]-[Region]-[Project/Domain]-[Component]-[Resource Type]-[Instance]`

**Example: `prod-usw2-billing-api-vm-01`**
* **Environment:** `prod`, `stag`, `dev`, `qa`
* **Region:** `usw2` (US-West-2), `euw1` (EU-West-1), `onprem`
* **Project/Domain:** `billing`, `auth`, `inventory`
* **Component:** `api`, `worker`, `frontend`, `cache`
* **Resource Type:** `vm` (Virtual Machine), `db` (Database), `lb` (Load Balancer), `k8s` (Kubernetes cluster)
* **Instance:** `01`, `02`, `a`, `b`

### The Golden Rules
1. **Lowercase Only:** Avoid CamelCase. Systems handle case sensitivity differently (DNS, AWS S3, etc.); lowercase prevents silent failures.
2. **Hyphens, Not Underscores:** Hyphens are universally accepted in URLs, hostnames, and cloud resource IDs. Underscores are often invalid in DNS.
3. **No Personal Names:** Never use `ali-test-server`. Map resources to teams and domains, not individuals.
4. **Build for Parsing:** The hyphen acts as a delimiter, allowing scripts, log aggregators, and monitoring tools to split the string and tag data dynamically.

---

## 🤝 Handling the "I Developed It" Argument

Changing engineering culture is harder than changing code. When developers insist on creative names, use these strategies:

### 1. The "Codename" Compromise (Recommended)
Separate the *Project Name* from the *Service Name*.
> "You can call the project *Gandalf*. You can name your Slack channel `#team-gandalf`. You can use it in Jira. But the Kubernetes deployment, Git repository, and Grafana dashboard must be named `core-auth-api`."

### 2. The PagerDuty Rule (The Harsh Reality)
Ownership implies operational liability. 
> "If you name it non-standard, SRE cannot support it with our automated alerting. Therefore, your team is 100% on-call for 'sauron' 24/7." 
Usually, functional names become much more appealing when developers realize the alternative is carrying a weekend pager.

---

## 🛡️ Enforcing the Standard (Preventing Drift)

Wiki pages and documentation don't prevent drift. You must enforce conventions programmatically. Human arguments take too much energy—let the pipeline be the bad guy.

* **Infrastructure as Code (IaC) Modules:** Never let developers name resources directly. Provide Terraform modules that take variables (`env = "prod"`, `project = "billing"`) and output the concatenated standard name.
* **Pipeline Linters (Policy as Code):** Integrate tools like **Open Policy Agent (OPA)** or **Conftest** into your CI/CD. If a Pull Request contains a resource name failing the regex standard (`^[a-z]+-[a-z]+-[a-z]+$`), the pipeline fails immediately.
* **Cloud Tagging & Service Control Policies (SCPs):** Set up cloud provider policies (AWS SCPs, Azure Policies) that actively block the creation of any resource lacking the required naming structure and corresponding tags.

---

### Final Thoughts
Boring infrastructure is reliable infrastructure. Save the creativity for the application logic, and leave the infrastructure taxonomy to strict, predictable patterns.