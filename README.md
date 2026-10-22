<p align="center">
  <img src="Images/Header.png" alt="Okta API Lifecycle Automation">
</p>

# Okta API Lifecycle Automation

This lab automates the full Okta user lifecycle through the Okta REST API for the fictional company Kennon Technologies. Using Postman and PowerShell, I onboarded a new user, moved them between departments, and offboarded them without making changes in the admin console. I then built a PowerShell script that audits every active users MFA enrollment and flags anyone without a strong authenticator.

---

## Skills Demonstrated

- Okta REST API (users, groups, sessions, lifecycle, and factors endpoints)
- Postman environments, variables, and inherited authorization
- Joiner, mover, and leaver lifecycle automation
- Least privilege group changes during role transfers
- PowerShell scripting with paginated API calls and CSV reporting
- MFA enrollment auditing and weak factor identification
- Secure API token handling

---

## Prerequisites

- An Okta org with Super Administrator access
- A free [Postman](https://web.postman.co) account
- PowerShell 7
- A phone with Okta Verify installed, for MFA enrollment in Phase 6

---

## Environment

| Component | Details |
|---|---|
| Identity Provider | Okta Integrator org (Kennon Technologies) |
| API Client | Postman (web) |
| Scripting | PowerShell 7.6 on Windows |
| Test Users | Alex Rivera, Jordan Lee, Priya Shah, Marcus Bell |
| Test Groups | KT-API-Engineering, KT-API-Marketing |

---

## Table of Contents

1. [API Token and Postman Setup](#1-api-token-and-postman-setup)
2. [Querying Users and Groups](#2-querying-users-and-groups)
3. [Joiner: Onboarding a New User](#3-joiner-onboarding-a-new-user)
4. [Mover: Department Transfer](#4-mover-department-transfer)
5. [Leaver: Offboarding](#5-leaver-offboarding)
6. [MFA Report Script](#6-mfa-report-script)

---

## 1) API Token and Postman Setup

Create an Okta API token and configure Postman to authenticate with it, so every request in the lab inherits the same secure authorization.

### Create API Token

1. In **Okta** open the **Security** dropdown then select **API**
2. Select the **Tokens** tab then press **Create Token**
3. Create a token with the following information:
   - **Name:** KT-API-Lab
   - **Originate From:** Any IP
  
<p align="center">
  <img src="Images/Image%201.PNG" alt="Image 1">
</p>

4. Copy the **Token Value** and store it somewhere secure. **Okta only shows it once**

### Configure Postman

1. Create a [Postman](https://web.postman.co) account and sign in
2. In **Postman** open the dropdown that says **No Environment** then select **Create New Environment**
3. Name the environment **Okta Lab**
4. Click where it says **Add Variable** and enter **url** then for **Value** enter **your Okta org's URL**
5. Click again where it says **Add Variable** and enter **apikey** then for **Value** enter **your Token Value**
   - Set the type to **secret** so the token is hidden
6. Open the environment dropdown in the top right and select **Okta Lab**

<p align="center">
  <img src="Images/Image%202.PNG" alt="Image 2">
</p>

7. On the left hover over **My Collection** then select the **three dots**
8. Select **Rename** then enter **Okta API Automation**
9. Hover over **Get Data** then select the **three dots** then **Rename** it to **Who am I**
10. Hover over **Post Data** then select the **three dots** then **Delete**

<p align="center">
  <img src="Images/Image%203.PNG" alt="Image 3">
</p>

11. In **Postman** click **Okta API Automation** to open its **Settings**
12. Open the **Authorization** tab then enter the following information then **Save**
    - **Auth Type:** API Key
    - **Key:** Authorization
    - **Value:** SSWS {{apikey}}
    - **Add To:** Header
   
<p align="center">
  <img src="Images/Image%204.PNG" alt="Image 4">
</p>

### Test the Connection

1. On the left select **Who am I** then replace the url next to **Get** with the following:
    `{{url}}/api/v1/users/me`
2. Open the **Authorization** tab then make sure that it says **Inherited** next to **API Key**

<p align="center">
  <img src="Images/Image%205.PNG" alt="Image 5">
</p>

3. Press **Send** then **Save**
4. The response should say **200 OK** and show your admin account's profile

<p align="center">
  <img src="Images/Image%206.png" alt="Image 6">
</p>

---

## 2) Querying Users and Groups

Use the API to read users, groups, and group membership from the Okta org, confirming the connection works before making any changes.

### List Users

1. On the left of the screen hover over **Okta API Automation** then press the **Plus**
2. Hover over the new request, select the **three dots** and rename it **List Users**
3. Next to **Get** enter the following url:
    `{{url}}/api/v1/users?limit=25`

<p align="center">
  <img src="Images/Image%207.PNG" alt="Image 7">
</p>

4. Press **Send** then **Save**
5. The response should say **200 OK** and list the users in your org

<p align="center">
  <img src="Images/Image%208.png" alt="Image 8">
</p>

### List Groups

1. On the left of the screen hover over **Okta API Automation** then press the **Plus**
2. Hover over the new request, select the **three dots** and rename it **List Groups**
3. Next to **Get** enter the following url:
    `{{url}}/api/v1/groups`

<p align="center">
  <img src="Images/Image%209.PNG" alt="Image 9">
</p>

4. Press **Send** then **Save**
5. The response should say **200 OK** and list your groups, including the built in **Everyone** group

<p align="center">
  <img src="Images/Image%2010.png" alt="Image 10">
</p>

### List Group Members

The API identifies groups by ID, not name, so look up the Everyone group's ID first.

1. In the **List Groups** request, next to **Get** enter the following then **Send:**
    `{{url}}/api/v1/groups?q=Everyone`
2. At the bottom of the page look for **id:** and copy the id

<p align="center">
  <img src="Images/Image%2011.png" alt="Image 11">
</p>

3. Next to **Get** enter the following then **Save:**
    `{{url}}/api/v1/groups`
4. On the left of the screen hover over **Okta API Automation** then press the **Plus**
5. Hover over the new request, select the **three dots** and rename it **Group Members**
6. Next to **Get** enter the following url:
    `{{url}}/api/v1/groups/EVERYONE_GROUP_ID/users`

<p align="center">
  <img src="Images/Image%2012.PNG" alt="Image 12">
</p>

7. Press **Send** then **Save**
8. The response should say **200 OK** and list every active user in the **Everyone** group

<p align="center">
  <img src="Images/Image%2013.png" alt="Image 13">
</p>

---

## 3) Joiner: Onboarding a New User

New hire Alex Rivera joins Kennon Technologies as a Software Engineer. Create the department groups and Alex’s account, then grant access through group membership, all through the API.

### Create Environment Variables

1. In **Postman** on the left side under **Environments** click **Okta Lab**
2. Create three new **Variables** with the following names, leave the **Value** empty then **Save:**
   - engGroupId
   - mktGroupId
   - userId

<p align="center">
  <img src="Images/Image%2014.PNG" alt="Image 14">
</p>

### Create Department Groups

1. On the left hover over **Okta API Automation** and press the **Plus**
2. Rename the new request **Create Group**
3. Press **Get** to open the dropdown and select **Post** then enter the following:
   `{{url}}/api/v1/groups`
4. Open the **Body** tab then select **Raw** select **JSON** on the dropdown
5. Paste the following code:

```json
   {
     "profile": {
       "name": "KT-API-Engineering",
       "description": "Engineering department, managed via API"
     }
   }
```

<p align="center">
  <img src="Images/Image%2016.PNG" alt="Image 16">
</p>

6. Press **Send** then **Save**
7. The response should say **200 OK** and show the new **KT-API-Engineering** group with a type of **OKTA_GROUP**
8. Save the **Engineering Group id**

<p align="center">
  <img src="Images/Image%2017.png" alt="Image 17">
</p>

9. Replace the code with the following code:

```json
   {
     "profile": {
       "name": "KT-API-Marketing",
       "description": "Marketing department, managed via API"
     }
   }
```

<p align="center">
  <img src="Images/Image%2017.5.PNG" alt="Image 17.5">
</p>

10. Press **Send** then **Save**
11. The response should say **200 OK** and show the new **KT-API-Marketing** group with a type of **OKTA_GROUP**
12. Save the **Marketing Group id**

<p align="center">
  <img src="Images/Image%2017.75.png" alt="Image 17.75">
</p>

### Create and Activate the User

1. On the left hover over **Okta API Automation** and press the **Plus**
2. Rename the new request **Create User**
3. Press **Get** to open the dropdown and select **Post** then enter the following:
    `{{url}}/api/v1/users?activate=true`
4. Open the **Body** tab then select **Raw** select **JSON** on the dropdown
5. Paste the following code:

```json
   {
     "profile": {
       "firstName": "Alex",
       "lastName": "Rivera",
       "email": "alex.rivera@kennon.tech",
       "login": "alex.rivera@kennon.tech",
       "department": "Engineering",
       "title": "Software Engineer"
     },
     "credentials": {
       "password": { "value": "YOUR_TEST_PASSWORD" }
     }
   }
```

<p align="center">
  <img src="Images/Image%2019.PNG" alt="Image 19">
</p>

6. Replace `YOUR_TEST_PASSWORD` with a new password
7. Press **Send** then **Save**
8. The response should say **200 OK** and show Alex's profile with a status of **ACTIVE**
9. Copy **Alex's id**

<p align="center">
  <img src="Images/Image%2020.png" alt="Image 20">
</p>

### Store the IDs as Environment Variables

Storing IDs as variables lets later requests reference them without pasting long values into each URL.

1. On the left under the **Environments** dropdown select **Okta Lab**
2. Fill in the **engGroupId, mktGroupId, and userId** with the **id** values we just got
3. **Save**

<p align="center">
  <img src="Images/Image%2021.PNG" alt="Image 21">
</p>

### Assign the User to a Group

1. On the left hover over **Okta API Automation** and press the **Plus**
2. Rename the new request **Add User to Group**
3. Press **Get** to open the dropdown and select **Put** then enter the following:
    `{{url}}/api/v1/groups/{{engGroupId}}/users/{{userId}}`

<p align="center">
  <img src="Images/Image%2022.PNG" alt="Image 22">
</p>

4. Press **Send** then **Save**
5. The response should say **204 No Content** with an empty body, which means Alex was added to the group

<p align="center">
  <img src="Images/Image%2023.png" alt="Image 23">
</p>

### Verify Access

1. On the left under **Okta API Automation** press **Group Members**
2. Change the url to the following:
    `{{url}}/api/v1/groups/{{engGroupId}}/users`

<p align="center">
  <img src="Images/Image%2024.PNG" alt="Image 24">
</p>

3. Press **Send** then **Save**
4. The response should say **200 OK** and list Alex as a member of **KT-API-Engineering**
5. Find **Alex's Profile**

<p align="center">
  <img src="Images/Image%2025.png" alt="Image 25">
</p>

6. In the **Okta Admin Console** open the **Directory** dropdown then select **People**
7. Check for **Alex**

<p align="center">
  <img src="Images/Image%2026.PNG" alt="Image 26">
</p>

8. Open the **Directory** dropdown then select **Groups**
9. Find the **KT-API-Engineering** group select it and confirm **Alex's** membership

<p align="center">
  <img src="Images/Image%2027.PNG" alt="Image 27">
</p>

10. In an **Incognito Window** log in to **Alex's Okta Account**
11. On the top right open the **Profile** dropdown then select **Account Settings**

<p align="center">
  <img src="Images/Image%2028.PNG" alt="Image 28">
</p>

---

## 4) Mover: Department Transfer

Alex transfers from Engineering to Marketing as a Marketing Specialist. Update the profile, then remove the old group before adding the new one, so Alex never holds both departments’ access at once.

### Update the User Profile

1. In **Postman** on the left hover over **Okta API Automation** and press the **Plus**
2. Rename the new request **Update User**
3. Press **Get** to open the dropdown and select **Post** then enter the following:
   `{{url}}/api/v1/users/{{userId}}`
4. Open the **Body** tab then choose **Raw** then enter the following:

```json
   {
     "profile": {
       "department": "Marketing",
       "title": "Marketing Specialist"
     }
   }
```

<p align="center">
  <img src="Images/Image%2029.PNG" alt="Image 29">
</p>

5. Press **Send** then **Save**
6. The response should say **200 OK** and show Alex's department as **Marketing** and title as **Marketing Specialist**

<p align="center">
  <img src="Images/Image%2030.png" alt="Image 30">
</p>

### Remove the Old Group

Removing the old group before adding the new one follows least privilege, so Alex never holds both departments' access at once.

1. On the left hover over **Okta API Automation** and press the **Plus**
2. Rename the new request **Remove User from Group**
3. Press **Get** to open the dropdown and select **Delete** then enter the following:
    `{{url}}/api/v1/groups/{{engGroupId}}/users/{{userId}}`

<p align="center">
  <img src="Images/Image%2031.PNG" alt="Image 31">
</p>

4. Press **Send** then **Save**
5. The response should say **204 No Content**, which means Alex was removed from **KT-API-Engineering**

<p align="center">
  <img src="Images/Image%2032.PNG" alt="Image 32">
</p>

### Add the New Group

1. On the left hover over **Add User to Group** and press the **three dots** then **Duplicate**
2. Rename the new request **Add User to Marketing**
3. Change the URL to the following:
    `{{url}}/api/v1/groups/{{mktGroupId}}/users/{{userId}}`

<p align="center">
  <img src="Images/Image%2033.PNG" alt="Image 33">
</p>

4. Press **Send** then **Save**
5. The response should say **204 No Content**, which means Alex was added to **KT-API-Marketing**

<p align="center">
  <img src="Images/Image%2034.PNG" alt="Image 34">
</p>

### Verify Access

1. Open the **Group Members** request
2. Change the URL to the following:
    `{{url}}/api/v1/groups/{{mktGroupId}}/users`

<p align="center">
  <img src="Images/Image%2035.PNG" alt="Image 35">
</p>

3. Press **Send** then **Save**
4. The response should say **200 OK** and list Alex as a member of **KT-API-Marketing**

<p align="center">
  <img src="Images/Image%2036.png" alt="Image 36">
</p>

5. In the **Okta Admin Console** open the **Directory** dropdown then select **People**
6. Select **Alex Rivera** then open the **Groups** tab then confirm **KT-API-Marketing** appears

<p align="center">
  <img src="Images/Image%2037.PNG" alt="Image 37">
</p>

---

## 5) Leaver: Offboarding

Alex leaves Kennon Technologies. End all active sessions, remove group access, and deactivate the account, keeping the record for audit purposes instead of deleting it.

### End Active Sessions

Clearing sessions signs Alex out everywhere immediately, so an already open session can't keep being used.

1. In **Postman** on the left hover over **Okta API Automation** and press the **Plus**
2. Rename the new request **Clear User Sessions**
3. Press **Get** to open the dropdown and select **Delete** then enter the following:
   `{{url}}/api/v1/users/{{userId}}/sessions`

<p align="center">
  <img src="Images/Image%2038.PNG" alt="Image 38">
</p>

4. Press **Send** then **Save**
5. The response should say **204 No Content**, which means all of Alex's sessions were ended

<p align="center">
  <img src="Images/Image%2039.PNG" alt="Image 39">
</p>

### Remove Group Access

1. On the left hover over **Remove User from Group** and press the **three dots** then **Duplicate**
2. Rename the new request **Remove User from Marketing**
3. Change the URL to the following:
   `{{url}}/api/v1/groups/{{mktGroupId}}/users/{{userId}}`

<p align="center">
  <img src="Images/Image%2040.PNG" alt="Image 40">
</p>

4. Press **Send** then **Save**
5. The response should say **204 No Content**, which means Alex was removed from **KT-API-Marketing**

<p align="center">
  <img src="Images/Image%2041.PNG" alt="Image 41">
</p>

### Deactivate the Account

Deactivating instead of deleting keeps the account record available for audits.

1. On the left hover over **Okta API Automation** and press the **Plus**
2. Rename the new request **Deactivate User**
3. Press **Get** to open the dropdown and select **Post** then enter the following:
   `{{url}}/api/v1/users/{{userId}}/lifecycle/deactivate`

<p align="center">
  <img src="Images/Image%2042.PNG" alt="Image 42">
</p>

4. Press **Send** then **Save**
5. The response should say **200 OK** with an empty **{}** body, which means the account was deactivated

<p align="center">
  <img src="Images/Image%2043.PNG" alt="Image 43">
</p>

### Verify Offboarding

Okta shows a generic sign in error instead of saying the account is deactivated, which prevents attackers from learning which accounts exist.

1. On the left open the **Group Members** request
2. Replace the URL with the following:
    `{{url}}/api/v1/groups/{{mktGroupId}}/users`

<p align="center">
  <img src="Images/Image%2044.PNG" alt="Image 44">
</p>

3. Press **Send** then **Save**
4. The response should say **200 OK** with an empty list **[]**, since Alex is no longer in the group

<p align="center">
  <img src="Images/Image%2045.PNG" alt="Image 45">
</p>

5. On the left hover over **Okta API Automation** and press the **Plus**
6. Rename the new request **Get User**
7. For the URL enter the following:
   `{{url}}/api/v1/users/{{userId}}`

<p align="center">
  <img src="Images/Image%2046.PNG" alt="Image 46">
</p>

8. Press **Send** then **Save**
9. The response should say **200 OK** and show Alex's status as **DEPROVISIONED**

<p align="center">
  <img src="Images/Image%2047.png" alt="Image 47">
</p>

10. In the **Okta Admin Console** open the **Directory** dropdown then select **People**
11. Find **Alex Rivera** and confirm that his **Status** is **Deactivated**

<p align="center">
  <img src="Images/Image%2048.PNG" alt="Image 48">
</p>

12. In an **Incognito Window** attempt to log in to **Alex's Okta Account**

<p align="center">
  <img src="Images/Image%2049.PNG" alt="Image 49">
</p>

---

## 6) MFA Report Script

Create test users with and without MFA, then run a PowerShell script that audits every active user’s enrolled factors and flags anyone missing a strong authenticator.

### Create Test Users

1. In **Postman** on the left open the **Create User** request
2. Replace the code in the body with the following:

```json
   {
     "profile": {
       "firstName": "Jordan",
       "lastName": "Lee",
       "email": "jordan.lee@kennon.tech",
       "login": "jordan.lee@kennon.tech",
       "department": "Finance",
       "title": "Financial Analyst"
     },
     "credentials": {
       "password": { "value": "YOUR_TEST_PASSWORD" }
     }
   }
```

3. Replace **YOUR_TEST_PASSWORD** with a test password

<p align="center">
  <img src="Images/Image%2050.PNG" alt="Image 50">
</p>

4. Press **Send** then **Save**
5. The response should say **200 OK** and show Jordan's profile with a status of **ACTIVE**

<p align="center">
  <img src="Images/Image%2051.png" alt="Image 51">
</p>

6. Repeat the process but enter the following code:

```json
   {
     "profile": {
       "firstName": "Priya",
       "lastName": "Shah",
       "email": "priya.shah@kennon.tech",
       "login": "priya.shah@kennon.tech",
       "department": "Engineering",
       "title": "DevOps Engineer"
     },
     "credentials": {
       "password": { "value": "YOUR_TEST_PASSWORD" }
     }
   }
```

<p align="center">
  <img src="Images/Image%2052.PNG" alt="Image 52">
</p>

7. Press **Send** then **Save**
8. The response should say **200 OK** and show Priya's profile with a status of **ACTIVE**

<p align="center">
  <img src="Images/Image%2053.png" alt="Image 53">
</p>

9. Repeat the process but enter the following code:

```json
   {
     "profile": {
       "firstName": "Marcus",
       "lastName": "Bell",
       "email": "marcus.bell@kennon.tech",
       "login": "marcus.bell@kennon.tech",
       "department": "Marketing",
       "title": "Content Strategist"
     },
     "credentials": {
       "password": { "value": "YOUR_TEST_PASSWORD" }
     }
   }
```

<p align="center">
  <img src="Images/Image%2054.PNG" alt="Image 54">
</p>

10. Press **Send** then **Save**
11. The response should say **200 OK** and show Marcus's profile with a status of **ACTIVE**

<p align="center">
  <img src="Images/Image%2055.png" alt="Image 55">
</p>

### Enroll MFA for Test Users

1. In an **Incognito Window** log in to **Priya's Okta Account**
2. When Okta prompts you to set up an authenticator choose **Okta Verify** and set it up

<p align="center">
  <img src="Images/Image%2056.PNG" alt="Image 56">
</p>

3. Log out of **Priya's Okta Account** then log in to **Jordan's Okta Account**
4. Set up the **Okta Verify** authenticator for **Jordan's Okta Account**
5. Sign out of **Jordan's Okta Account**

### Run the MFA Report

Okta can enroll the email authenticator automatically, so the script excludes email and only counts strong factors like Okta Verify.

1. Open **PowerShell 7** in the folder containing the **[Get-MfaReport.ps1](Scripts/Get-MfaReport.ps1)** script and run the following, replacing the token and URL with your own:

```powershell
   $env:OKTA_API_TOKEN = "YOUR_TOKEN_VALUE"
   Unblock-File .\Get-MfaReport.ps1
   .\Get-MfaReport.ps1 -OktaUrl "https://YOUR_ORG.okta.com"
```

<p align="center">
  <img src="Images/Image%2057.PNG" alt="Image 57">
</p>

2. On your desktop a CSV file named **mfa-report.csv** will be created
3. Open the **mfa-report.csv** file and confirm it looks like the following:

<p align="center">
  <img src="Images/Image%2058.PNG" alt="Image 58">
</p>

### Verify in the Admin Console

1. In the **Okta Admin Console** open the **Directory** dropdown then select **People**
2. Select **Priya Shah** then open the **More Actions** dropdown then select **Reset Authenticators**
3. Confirm **Okta Verify** is showing as her only authenticator

<p align="center">
  <img src="Images/Image%2059.PNG" alt="Image 59">
</p>

4. Open **Marcus Bell's** profile then open the **More Actions** dropdown then select **Reset Authenticators**
5. Confirm there are **No Authenticators** set up for **Marcus Bell**

<p align="center">
  <img src="Images/Image%2060.PNG" alt="Image 60">
</p>

---

## Closing Note

This lab took a user through the full identity lifecycle using only the Okta REST API, from onboarding and a department transfer to offboarding, then audited MFA across the org with a PowerShell script.

The most useful finding came from the first run of the MFA report, which showed every user as enrolled. Digging into the results revealed that Okta had automatically enrolled the email authenticator, which counted as a factor. Since email is a weak factor, I updated the script to only count strong authenticators like Okta Verify, and the second run correctly flagged the user without real MFA.

After finishing the lab, I revoked the API token so it could not be reused.
