# Import Passwords into Password folder

## Overview
This script helps you import passwords into IT Glue password folders using the API.

## Features
- Bulk import from CSV
- Creates folders automatically
- Supports OTP secret
- Works across NA, EU, AU regions

# Pre-requisite:

1. CVS file (With template shown below)
<img width="1301" height="412" alt="image" src="https://github.com/user-attachments/assets/9f35898e-5586-4bc3-b258-027eab3cb95b" />
2. Download or copy the code from the PowerShell script attached to this repository
3. Run the script on Windows PowerShell ISE or any platform that supports PowerShell
4. You need your subdomain and credentials for IT Glue

# Description:

This is a PowerShell script that can be executed on any machine that supports PowerShell. You do not need any Admin access on your machine to run this script. For instance, in the EU and AU regions, please make sure to update the URL to use the EU and AU script. **You will need to use the IT Glue credentials to authorize and run the script.** If you have SSO enabled, then you will need to temporarily add the user to the bypass/override list. Use the script in the link [here](https://github.com/ITGlue-Support/Import-Passwords-into-folders/blob/main/Import_with%20SSO_disable.ps1)

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

2. This script will fetch the information from the CSV file, first find the organization with the same name, and extract the organization ID via API calls. This script will not attempt to create an organization in IT Glue. **Please make sure the organization already exists**

3. The script will attempt to create the Password folder if the folder with the same name does not exist in IT Glue, and for password categories.

Please download the CSV file attached for the template. This script is not capable of adding resource ID and resource type to the passwords. However, feel free to update the script and add that section.

# Thank you for the Support!

