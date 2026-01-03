# AWS-Native IAM Security Observability: CloudWatch Dashboarding

## Executive Summary

This project addresses a common cloud security challenge: detecting suspicious Identity and Access Management (IAM) activity without relying on expensive third-party SIEMs or solely on opaque log files. I designed and implemented a custom observability solution using **Amazon CloudWatch** to visualize indicators of compromise (IoCs) extracted from **AWS CloudTrail** logs.

The solution provides near real-time monitoring of high-risk events—specifically user creation, access key generation, and policy changes. By converting raw logs into visual metrics and utilizing CloudWatch Math expressions, the dashboard offers an immediate "at-a-glance" view of the environment's security posture, enabling rapid response to potential identity-based attacks.

---

## Technology Stack

* **Log Ingestion:** AWS CloudTrail
* **Visualization:** Amazon CloudWatch Dashboards
* **Data Analysis:** CloudWatch Logs Insights (Query Language)
* **Logic:** CloudWatch Metric Filters & Metric Math
* **Simulation:** AWS Lambda & CloudShell (Bash/CLI)

---

## Architecture & Workflow

The architecture leverages AWS-native services to transform distinct API events into a unified threat monitoring view.

<p align="center">
  <img src=".assets/Architecture Diagram.png" alt="Architecture Diagram" width="800"/>
  <br>
  <b>Figure 1: High-Level Architecture</b>
  <br><br>
  Data flows from CloudTrail management events into CloudWatch Logs. Metric Filters extract specific IAM actions, which populate the custom dashboard widgets.
</p>

---

## Implementation Details

### Phase 1: Metric Extraction

The foundation of the dashboard relies on custom metric filters applied to CloudTrail log groups. I configured filters to track three specific signals often associated with persistence and privilege escalation tactics:
* `CreateUserCount`
* `CreateAccessKeyCount`
* `PutUserPolicyCount`

### Phase 2: Dashboard Visualization Strategy

To support different analytical workflows, I implemented multiple visualization types:

1.  **Executive Summary (Number Widget):** A rolling 5-minute counter providing a "current state" view of total security events.
2.  **Trend Analysis (Line Chart):** A 1-minute granularity timeline to identify sudden spikes in activity.
3.  **Attack Categorization (Stacked Area Chart):** A visual breakdown allowing analysts to distinguish between credential generation vs. policy manipulation attempts.

<p align="center">
  <img src=".assets/Completed Dashboard.png" alt="Completed Dashboard" width="800"/>
  <br>
  <b>Figure 2: The Security Monitoring Dashboard</b>
  <br><br>
  The final dashboard combining signal detection (metrics) and forensic evidence (logs). Note the "Combined IAM Security Activity Score" which uses Metric Math to sum distinct event types into a single risk index.
</p>

### Phase 3: Advanced Analytics with Metric Math

To reduce the cognitive load of monitoring multiple independent lines, I utilized CloudWatch Metric Math. By defining an expression `m1 + m2 + m3` (representing the sum of the three IAM metrics), I created a composite **"Combined IAM Security Activity Score."** This allows for simplified alerting on "Total Threat Activity" rather than managing alarms for every individual API call.

### Phase 4: Integrated Forensics

Detection requires verification. I embedded a **CloudWatch Logs Insights** query directly into the dashboard. This widget automatically correlates the visual spikes with the underlying log data, displaying the Timestamp, Event Name, Identity Type, and Source IP Address. This enables an analyst to pivot from detection to attribution without leaving the dashboard context.

---

## Validation & Attack Simulation

To validate the end-to-end detection pipeline, I utilized an AWS Lambda function designed to generate simulated security events. Using AWS CloudShell, I invoked this function to create "noise" in the IAM environment, generating user accounts and access keys.

<p align="center">
  <img src=".assets/Security Event Generation.png" alt="Security Event Generation" width="800"/>
  <br>
  <b>Figure 3: Threat Simulation</b>
  <br><br>
  Invoking the attack simulation Lambda via the AWS CLI in CloudShell. This process generated the specific API calls required to populate the dashboard metrics, confirming that the filter patterns and dashboard widgets were correctly wired to the log stream.
</p>

---

## Conclusion

This project demonstrates how raw telemetry can be transformed into actionable security insights using standard AWS features. By moving away from reactive log scrolling to proactive dashboard monitoring, the time required to detect identity-based threats is significantly reduced. The resulting dashboard provides a scalable, low-cost alternative to complex SIEM deployments for monitoring core IAM hygiene.
