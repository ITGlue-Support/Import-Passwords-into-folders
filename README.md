# Import Passwords

# Pre-requisite:

1. CVS file (With template shown below)
<img width="1301" height="412" alt="image" src="https://github.com/user-attachments/assets/9f35898e-5586-4bc3-b258-027eab3cb95b" />
2. Download or copy the code from the PowerShell script attached to this repository
3. Run the script on Windows PowerShell ISE or any platform that supports PowerShell
4. You need your subdomain and credentials for IT Glue

# Description:

This is a PowerShell script that can be executed on any machine that supports PowerShell. You do not need any Admin access on your machine to run this script. For instance, in the EU and AU regions, please make sure to update the URL to use the EU and AU script.

1. You need to create a CSV file with the columns shown below:

a. name = <Password_name>	***Required Field**
b. password_folder = <Password_folder_name>	**Optional Field**
c. organization	= <organization_name> ***Required Field**
d. username	= <username_for_the_password> ***Required Field**
e. password	= <Password_value> ***Required Field**
f. otp_secret	= <OTP__secret_key>(Base32 Format) **Optional Field**
g. password_category = <Password_Category> **Optional Field**
h. url =	<Site_URL> **Optional Field**
i. notes = <Additional_Notes> **Optional Field**

2. This script will fetch the information from the CSV file and first find the Organization with extract same name and extract the organization ID via API calls. This script will not attempt to create an organization in IT Glue. **Please make sure the organization already exists**

3. 

