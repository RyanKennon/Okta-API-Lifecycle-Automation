# Okta-API-Lifecycle-Automation

### 1) API Token and Postman Setup

1. In **Okta** open the **Security** dropdown then select **API**
2. Select the **Tokens** tab then press **Create Token**
3. Create a token with the following information:
   - **Name:** KT-API-Lab
   - **Originate From:** Any IP
  
# Image 1

4. Save the **Token Value**
5. Create a [Postman](https://web.postman.co) account and sign in
6. In **Postman** open the dropdown that says **No Environment** then select **Create New Environment**
7. Name the environment **Okta Lab**
8. Click where it says **Add Variable** and enter **url** then for **Value** enter **your Okta org's URL**
9. Click again where it says **Add Variable** and enter **apikey** then for **Value** enter **your API Key**

# Image 2

10. On the left hover over **My Collection** then select the **three dots**
11. Select **Rename** then enter **Okta API Automation**
12. Hover over **Get Data** then select the **three dots** then **Rename** it to **Who am I**
13. Hover over **Post Data** then select the **three dots** then **Delete**

# Image 3

14. In **Postman** click **Okta API Automation** to open its **Settings**
15. Open the **Authorization** tab then press **API Key** then enter the following information then **Save**
    - **Auth Type:** API Key
    - **Key:** Authorization
    - **Value:** SSWS {{apikey}}
    - **Add To:** Header
   
# Image 4

16. On the left select **Who am I** then replace the url next to **Get** with the following:
    `{{url}}/api/v1/users/me`
17. Open the **Authorization** tab then make sure that it says **Inherited** next to **API Key**

# Image 5

18. Press **Send**
19. The bottom of the page should look like the following, make sure it says **200 OK**

# Image 6

### 2) Querying Users and Groups

1. On the left of the screen hover over **Okta API Automation** then press the **Plus**
2. Select the **three dots** and rename it **List Users**
3. Next to **Get** enter the following url:
    `{{url}}/api/v1/users?limit=25`

# Image 7

4. Press **Send** then **Save**
5. The bottom of the page should look like the following, make sure it says **200 OK**

# Image 8

6. On the left of the screen hover over **Okta API Automation** then press the **Plus**
7. Select the **three dots** and rename it **List Groups**
8. Next to **Get** enter the following url:
    `{{url}}/api/v1/groups`

# Image 9

9. Press **Send** then **Save**
10. The bottom of the page should look like the following, make sure it says **200 OK**

# Image 10

11. Next to **Get** enter the following then **Send:**
    `{{url}}/api/v1/groups?q=Everyone`
12. At the bottom of the page look for **id:** and copy the id

# Image 11

13. Next to **Get** enter the following then **Save:**
    `{{url}}/api/v1/groups`
14. On the left of the screen hover over **Okta API Automation** then press the **Plus**
15. Select the **three dots** and rename it **List Group Members**
16. Next to **Get** enter the following url:
    `{{url}}/api/v1/groups/EVERYONE_GROUP_ID/users`

# Image 12

17. Press **Send** then **Save**
18. The bottom of the page should look like the following, make sure it says **200 OK**

# Image 13

### 3) Joiner
