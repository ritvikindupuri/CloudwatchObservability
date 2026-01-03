**Logs Insights Query:**
```sql
fields @timestamp, eventName, userIdentity.type, sourceIPAddress
| filter eventName in ["CreateUser", "CreateAccessKey", "PutUserPolicy"]
| sort @timestamp desc
| limit 20
