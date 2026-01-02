# AWS-Native IAM Security Observability: Real-Time Detection & Dashboarding

## Executive Summary

This project implements a fully AWS-native security observability solution designed to convert raw CloudTrail logs into near real-time actionable intelligence. By bypassing third-party SIEM complexity, I built a custom detection engine using Amazon CloudWatch that identifies high-fidelity Indicators of Compromise (IoCs) related to Identity and Access Management (IAM) abuse.

The system focuses on detecting the "Persistence" and "Privilege Escalation" tactics of the MITRE ATT&CK framework. Through the use of custom Metric Filters, CloudWatch Metric Math expressions, and embedded Logs Insights, the solution provides a single-pane-of-glass dashboard. This allows security analysts to detect, quantify, and investigate suspicious identity activities—such as unauthorized user creation or credential forging—within minutes of occurrence.

---

## Technology Stack

* **Observability & Visualization:** Amazon CloudWatch (Dashboards, Metrics, Logs Insights)
* **Log Ingestion:** AWS CloudTrail
* **Detection Logic:** CloudWatch Metric Filters, CloudWatch Metric Math
* **Automation & Testing:** AWS Lambda (Python/Boto3), AWS IAM
* **Query Language:** CloudWatch Logs Query Syntax

---

## Architecture & Workflow

The solution architecture follows a linear detection pipeline: Logging $\rightarrow$ Extraction $\rightarrow$ Aggregation $\rightarrow$ Visualization. The system ingests management events from CloudTrail, extracts specific security signals using metric filters, and aggregates them into a composite risk score.

<p align="center">
  <img src=".assets/Completed Dashboard.png" alt="Security Monitoring Dashboard" width="800"/>
  <br>
  <b>Figure 1: The Completed Security Monitoring Dashboard</b>
  <br><br>
  This dashboard serves as the operational hub for the project. It aggregates distinct security signals into high-level metrics (top row numbers), visualizes attack velocity (line charts), creates a composite risk score using Metric Math (middle row), and allows for immediate drill-down into raw log evidence via the embedded Logs Insights table (bottom).
</p>

---

## Implementation Phases

### Phase 1: Signal Extraction (Metric Filters)

Raw CloudTrail logs are voluminous and difficult to parse manually. I configured **CloudWatch Metric Filters** to sift through the log stream and extract specific API calls that indicate security risks.

* **CreateUserCount:** Filters for `eventName="CreateUser"`.
* **CreateAccessKeyCount:** Filters for `eventName="CreateAccessKey"`.
* **PutUserPolicyCount:** Filters for `eventName="PutUserPolicy"`.

These filters convert unstructured log data into numerical metrics (`1` count per event), enabling mathematical analysis and time-series tracking.

### Phase 2: Dashboard Engineering & Metric Math

To reduce alert fatigue and improve signal clarity, I utilized **CloudWatch Metric Math** to create a composite score.

* **Combined Activity Score:** Using the expression `m1 + m2 + m3` (summing all three event types), I created a single "Threat Index." This allows for trend-based detection; a spike in the combined score indicates an active campaign, regardless of the specific technique used.
* **Stacked Area Analysis:** To differentiate between attack types, a stacked area chart breaks down the total volume. This helps analysts immediately determine if an attacker is focused on lateral movement (Access Keys) or persistence (User Creation).

### Phase 3: Investigation & Attribution

Detection is useless without context. I embedded a **CloudWatch Logs Insights** query directly into the dashboard to bridge the gap between metrics and logs.

**Query Logic:**
`fields @timestamp, eventName, userIdentity.type, sourceIPAddress | filter eventName in ["CreateUser", "CreateAccessKey", "PutUserPolicy"] | sort @timestamp desc | limit 20`

This query dynamically pulls the relevant metadata—who did it, from what IP, and when—allowing for immediate attribution without leaving the dashboard view.

### Phase 4: Validation & Attack Simulation

To ensure the detection pipeline was functioning correctly, I developed a Python-based **AWS Lambda** function to act as an adversary simulator. The function performs a sequence of IAM actions—creating a user, generating keys, attaching policies, and then cleaning up—to generate realistic "noise" in the environment.

<p align="center">
  <img src=".assets/Security Event Generation.png" alt="Attack Simulation Execution" width="800"/>
  <br>
  <b>Figure 2: Generating Security Events via CloudShell</b>
  <br><br>
  Validating the pipeline by invoking the `generate-security-events` Lambda function using the AWS CLI. The JSON output confirms the successful execution of IAM actions (`CreateUser`, `CreateAccessKey`), which propagate through CloudTrail to populate the dashboard metrics in near real-time.
</p>

---

## Root Cause & Threat Model

* **Threat Vector:** Identity Persistence. Attackers who compromise an environment often create "backdoor" users or access keys to maintain access even if the initial entry point is patched.
* **Operational Gap:** CloudTrail logs are reactive and often reviewed only *after* an incident is suspected.
* **Solution:** By lifting these specific events into real-time metrics, the organization shifts from reactive forensics to proactive containment.

---

## Conclusion

This project demonstrates that effective security observability does not require expensive third-party tools. By mastering first-party AWS services like CloudWatch Metric Filters and Metric Math, I built a robust detection mechanism that provides visibility into critical IAM changes. The resulting workflow reduces the Mean Time to Detect (MTTD) for identity-based threats from hours (log review) to minutes (dashboard visualization).
