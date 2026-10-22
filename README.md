# Okta-API-Lifecycle-Automation

## 1) API Token and Postman Setup

### Create API Token

1. In **Okta** open the **Security** dropdown then select **API**
2. Select the **Tokens** tab then press **Create Token**
3. Create a token with the following information:
   - **Name:** KT-API-Lab
   - **Originate From:** Any IP
  
# Image 1

4. Save the **Token Value**

### Configure Postman

1. Create a [Postman](https://web.postman.co) account and sign in
2. In **Postman** open the dropdown that says **No Environment** then select **Create New Environment**
3. Name the environment **Okta Lab**
4. Click where it says **Add Variable** and enter **url** then for **Value** enter **your Okta org's URL**
5. Click again where it says **Add Variable** and enter **apikey** then for **Value** enter **your API Key**

# Image 2

6. On the left hover over **My Collection** then select the **three dots**

### Test the Connection

1. Select **Rename** then enter **Okta API Automation**
2. Hover over **Get Data** then select the **three dots** then **Rename** it to **Who am I**
3. Hover over **Post Data** then select the **three dots** then **Delete**

# Image 3

4. In **Postman** click **Okta API Automation** to open its **Settings**
5. Open the **Authorization** tab then press **API Key** then enter the following information then **Save**
    - **Auth Type:** API Key
    - **Key:** Authorization
    - **Value:** SSWS {{apikey}}
    - **Add To:** Header
   
# Image 4

6. On the left select **Who am I** then replace the url next to **Get** with the following:
    `{{url}}/api/v1/users/me`
7. Open the **Authorization** tab then make sure that it says **Inherited** next to **API Key**

# Image 5

8. Press **Send**
9. The bottom of the page should look like the following, make sure it says **200 OK**

# Image 6

## 2) Querying Users and Groups

### List Users

1. On the left of the screen hover over **Okta API Automation** then press the **Plus**
2. Select the **three dots** and rename it **List Users**
3. Next to **Get** enter the following url:
    `{{url}}/api/v1/users?limit=25`

# Image 7

4. Press **Send** then **Save**
5. The bottom of the page should look like the following, make sure it says **200 OK**

# Image 8

### List Groups

1. On the left of the screen hover over **Okta API Automation** then press the **Plus**
2. Select the **three dots** and rename it **List Groups**
3. Next to **Get** enter the following url:
    `{{url}}/api/v1/groups`

# Image 9

4. Press **Send** then **Save**
5. The bottom of the page should look like the following, make sure it says **200 OK**

# Image 10

### List Group Members

1. Next to **Get** enter the following then **Send:**
    `{{url}}/api/v1/groups?q=Everyone`
2. At the bottom of the page look for **id:** and copy the id

# Image 11

3. Next to **Get** enter the following then **Save:**
    `{{url}}/api/v1/groups`
4. On the left of the screen hover over **Okta API Automation** then press the **Plus**
5. Select the **three dots** and rename it **List Group Members**
6. Next to **Get** enter the following url:
    `{{url}}/api/v1/groups/EVERYONE_GROUP_ID/users`

# Image 12

7. Press **Send** then **Save**
8. The bottom of the page should look like the following, make sure it says **200 OK**

# Image 13

## 3) Joiner: Onboarding a New User

### Create Environment Variables

1. In **Postman** on the left side under **Environments** click **Okta Lab**
2. Create three new **Variables** with the following names, leave the **Value** empty then **Save:**
   - engGroupId
   - mktGroupId
   - userId

# Image 14

### Create Department Groups

1. On the left hover over **Okta API Automation** and press the **Plus**
2. Rename the new request **Create Group**
3. Press **Get** to open the dropdown and select **Post** then enter the following:
   `{{url}}/api/v1/groups`
4. Open the **Body** tab then select **Raw** select **JSON** on the dropdown
5. Paste the following code:
   `{
  "profile": {
    "name": "KT-API-Engineering",
    "description": "Engineering department, managed via API"
  }
}`

# Image 16

6. Press **Send** then **Save**
7. The bottom of the page should look like the following, make sure it says **200 OK**
8. Save the **Engineering Group id**

# Image 17

9. Replace the code with the following code:
    `{
  "profile": {
    "name": "KT-API-Marketing",
    "description": "Marketing department, managed via API"
  }
}`

# Image 17.5

10. Press **Send** then **Save**
11. The bottom of the page should look like the following, make sure it says **200 OK**
12. Save the **Marketing Group id**

# Image 17.75

### Create and Activate the User

1. On the left hover over **Okta API Automation** and press the **Plus**
2. Rename the new request **Create User**
3. Press **Get** to open the dropdown and select **Post** then enter the following:
    `{{url}}/api/v1/users?activate=true`
4. Open the **Body** tab then select **Raw** select **JSON** on the dropdown
5. Paste the following code:
    `{
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
}`

# Image 19

6. Replace `YOUR_TEST_PASSWORD` with a new password
7. Press **Send** then **Save**
8. The bottom of the page should look like the following, make sure it says **200 OK**
9. Copy **Alex's id**

# Image 20

### Store the IDs as Environment Variables

1. On the left under the **Environments** dropdown select **Okta Lab**
2. Fill the **engGroupId, mktGroupId, and userId** with the **id** values we just got
3. **Save**

# Image 21

### Assign the User to a Group

1. On the left hover over **Okta API Automation** and press the **Plus**
2. Rename the new request **Add User to Group**
3. Press **Get** to open the dropdown and select **Put** then enter the following:
    `{{url}}/api/v1/groups/{{engGroupId}}/users/{{userId}}`

# Image 22

4. Press **Send** then **Save**
5. The bottom of the page should look empty, make sure it says **204 No Content**

# Image 23

### Verify Access

1. On the left under **Okta API Automation** and press **Group Members**
2. Change the url to the following:
    `{{url}}/api/v1/groups/{{engGroupId}}/users`

# Image 24

3. Press **Send** then **Save**
4. The bottom of the page should look like the following, make sure it says **200 OK**
5. Find **Alex's Profile**

# Image 25

6. In the **Okta Admin Console** open the **Directory** dropdown then select **People**
7. Check for **Alex**

# Image 26

8. On the **Directory** dropdown then select **Groups**
9. Find the **KT-API-Engineering** group select it and confirm **Alex's** membership

# Image 27

10. In an **Incognito Window** log in to **Alex's Okta Account**
11. On the top right open the **Profile** dropdown then select **Account Settings**

# Image 28

---

## 4) Mover

### Update the User Profile

1. In **Postman** on the left hover over **Okta API Automation** and press the **Plus**
2. Rename the new request **Update User**
3. Press **Get** to open the dropdown and select **Post** then enter the following:
   `{{url}}/api/v1/users/{{userId}}`
4. Open the **Body** tab then choose **Raw** then enter the following:
   `{
  "profile": {
    "department": "Marketing",
    "title": "Marketing Specialist"
  }
}`

# Image 29

5. Press **Send** then **Save**
6. The bottom of the page should look like the following, make sure it says **200 OK**

# Image 30

### Remove the Old Group

1. On the left hover over **Okta API Automation** and press the **Plus**
2. Rename the new request **Remove User from Group**
3. Press **Get** to open the dropdown and select **Delete** then enter the following:
    `{{url}}/api/v1/groups/{{engGroupId}}/users/{{userId}}`

# Image 31

4. Press **Send** then **Save**
5. The bottom of the page should look like the following, make sure it says **204 No Content**

# Image 32

### Add the New Group

1. On the left hover over **Add User to Group** and press the **three dots** then **Duplicate**
2. Rename the new request **Add User to Marketing**
3. Change the URL to the following:
    `{{url}}/api/v1/groups/{{mktGroupId}}/users/{{userId}}`

# Image 33

4. Press **Send** then **Save**
5. The bottom of the page should look like the following, make sure it says **204 No Content**

# Image 34

### Verify Access

1. Open the **Group Members** request
2. Change the URL to the following:
    `{{url}}/api/v1/groups/{{mktGroupId}}/users`

# Image 35

3. Press **Send** then **Save**
4. The bottom of the page should look like the following, make sure it says **200 OK**

# Image 36

5. In the **Okta Admin Console** open the **Directory** dropdown then select **People**
6. Select **Alex Rivera** then open the **Groups** tab then confirm **KT-API-Marketing** appears

# Image 37

---

## 5) Leaver

### End Active Sessions

1. In **Postman** on the left hover over **Okta API Automation** and press the **Plus**
2. Rename the new request **Clear User Sessions**
3. Press **Get** to open the dropdown and select **Delete** then enter the following:
   `{{url}}/api/v1/users/{{userId}}/sessions`

# Image 38

4. Press **Send** then **Save**
5. The bottom of the page should look like the following, make sure it says **204 No Content**

# Image 39

### Remove Group Access

1. On the left hover over **Remove User to Group** and press the **three dots** then **Duplicate**
2. Rename the new request **Remove User to Marketing**
3. Press **Get** to open the dropdown and select **Delete** then enter the following:
   `{{url}}/api/v1/groups/{{mktGroupId}}/users/{{userId}}`

# Image 40

4. Press **Send** then **Save**
5. The bottom of the page should look like the following, make sure it says **204 No Content**

# Image 41

### Deactivate the Account

1. On the left hover over **Okta API Automation** and press the **Plus**
2. Rename the new request **Deactivate User**
3. Press **Get** to open the dropdown and select **Post** then enter the following:
   `{{url}}/api/v1/users/{{userId}}/lifecycle/deactivate`

# Image 42

4. Press **Send** then **Save**
5. The bottom of the page should look like the following, make sure it says **200 OK**

# Image 43

### Verify Offboarding

1. On the left open the **Group Members** request
2. Replace the URL with the following:
    `{{url}}/api/v1/groups/{{mktGroupId}}/users`

# Image 44

3. Press **Send** then **Save**
4. The bottom of the page should look like the following, make sure it says **200 OK**

# Image 45

5. On the left hover over **Okta API Automation** and press the **Plus**
6. Rename the new request **Get User**
7. For the URL enter the following:
   `{{url}}/api/v1/users/{{userId}}`

# Image 46

8. Press **Send** then **Save**
9. The bottom of the page should look like the following, make sure it says **200 OK**

# Image 47

10. In the **Okta Admin Console** open the **Directory** dropdown then select **People**
11. Find **Alex Rivera** and confirm that his **Status** is **Deactivated**

# Image 48

12. In an **Incognito Window** attempt log in to **Alex's Okta Account**

# Image 49

---

## 6) MFA Report Script

### Create Test Users

1. In **Postman** on the left open the **Create User** request
2. Replace the code in the body with the following:
   `{
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
}`

3. Replace **YOUR_TEST_PASSWORD** with your password

# Image 50

4. Press **Send** then **Save**
5. The bottom of the page should look like the following, make sure it says **200 OK**

# Image 51

6. Repeat the process but enter the following code:
   `{
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
}`

# Image 52

7. Press **Send** then **Save**
8. The bottom of the page should look like the following, make sure it says **200 OK**

# Image 53

9. Repeat the process but enter the following code:
    `{
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
}`

# Image 54

10. Press **Send** then **Save**
11. The bottom of the page should look like the following, make sure it says **200 OK**

# Image 55

### Enroll MFA for Test Users

1. In an **Incognito Window** log in to **Priya's Okta Account**
2. When Okta prompts you to set up authenticator choose **Okta Verify** and set it up

# Image 56

3. Log out of **Priya's Okta Account** then log in to **Jordan's Okta Account**
4. Set up the **Okta Verify** authenticator for **Jordan's Okta Account**
5. Sign out of **Joran's Okta Account**

### Run the MFA Report

1. Open **Windows Powershell 7** the run the **[Get-MfaReport.ps1](Scripts/Get-MfaReport.ps1)** script

# Image 57

2. On your desktop an Excel file named **mfa-report.csv** would have been created
3. Open the **mfa-report.csv** file and confirm it looks like thie following:

# Image 58

### Verify in the Admin Console

1. In the **Okta Admin Console** open the **Directory** dropdown then select **People**
2. Select **Priya Shah** then open the **More Actions** dropdown then select **Reset Authenticators**
3. Confirm **Okta Verify** is showing as her only authenticator

# Image 59

4. Open **Marcus Bell's** profile then open the **More Actions** dropdown then select **Reset Authenticators**
5. Confirm there are **No Authenticators** set up for **Marcus Bell**

# Image 60















