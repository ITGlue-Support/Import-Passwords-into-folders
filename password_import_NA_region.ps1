############### Authorization Token ###############################

function authorization_token
{
    param (
        
        [string]$subdomain,
        [string]$email,
        [string]$password,
        [int]$otp
    
    )

$body = @"
{
    "user":
    {
        "email": "$email",
        "password":  "$password",
        "otp_attempt": "$otp"
    }
}

"@
try{

    $auth_headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $auth_headers.Add("Content-Type", "application/json")

    $gen_jwt_url = "https://$($subdomain).itglue.com/login?generate_jwt=1"

    $gen_jwt = Invoke-RestMethod -Uri $gen_jwt_url -Method 'POST' -Body $body -Headers $auth_headers

    $gen_access_token_url = "https://$($subdomain).itglue.com/jwt/token?refresh_token=$($gen_jwt.token)"

    $gen_access_token = Invoke-RestMethod -Uri $gen_access_token_url -Method 'GET' -Headers $auth_headers
    
    $access_token = $gen_access_token.token

    Write-Host "Authorizatoin complete!" -ForegroundColor Green

    set_header -token "$access_token"
}
catch{

    Write-Host "Unable to authorize with provided credentials: $($_.exception.message)" -ForegroundColor Red
    break
}

}
################### Headers ###################################
function set_header {
    param (

        [string]$token
    
    )

    $global:headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $global:headers.Add("Content-Type", "application/json")
    $global:headers.Add("Authorization", "Bearer $token")

}

#################### Get Organization ID ########################

function get_org_id {

    param (
        [string]$org_name
    )
    try{

        $org_url = "https://api.itglue.com/organizations?filter[name]=" + [uri]::EscapeDataString($org_name)

        $find_org = Invoke-RestMethod -Uri $org_url -Method 'GET' -Headers $headers

        return $($find_org.data.id)
    }
    catch {
        Write-Host "Make sure organization $org_name already exist in IT Glue! Error: $($_.exception.message)" -ForegroundColor Red

    }
}


################# Get/Create Password Folder ####################

function new_folder {
    param (
    
        [string]$new_folder,
        [string]$endurl
    )

    try{

$fold_body = @"
{
    "data": {
        "type": "password-folders",
        "attributes": {      
            "name": "$new_folder"
            }
    }
}
"@

        $create_new_folder = Invoke-RestMethod -Uri $endurl -Method 'POST' -Headers $headers -Body $fold_body
    
        return $($create_new_folder.data.id)
    }
    catch{
     Write-Host "$($_.exception.message)"
     return
    }

}

function get_pass_folder {

    param (
        [int]$id,
        [string]$name,
        [string]$folder_name

    )
    try{
        
        $pass_folder_URL="https://api.itglue.com/organizations/$id/relationships/password_folders"

        $find_folder = Invoke-RestMethod -Uri $pass_folder_URL -Method 'GET' -Headers $headers

        
        if($($find_folder.data) -eq $null){


            Write-Host "No password folders found in $name. Creating new password folder $folder_name!" -ForegroundColor Yellow

            return new_folder -new_folder "$folder_name" -endurl "$pass_folder_URL"
        }
        else {

            foreach ($records in $find_folder.data){


                if($($records.attributes.name) -eq $folder_name){
                    
                    return $($records.id)
                }
              
            }
            Write-Host "Unable to find the folder with name $folder_name, creating a new folder!" -ForegroundColor Blue
            return new_folder -new_folder "$folder_name" -endurl "$pass_folder_URL"

        }

    }
    catch {
        Write-Host "$($_.exception.message)" -ForegroundColor Red
        return
    }
}


################# Get/Create Password Category ##################
function new_type {
    param (
    
        [string]$new_type
    )

    try{
$type_body = @"
{
  "data": {
    "type": "password-categories",
    "attributes": {
      "name": "$new_type"
    }
  }
}
"@

        $create_new_category = Invoke-RestMethod 'https://api.itglue.com/password_categories' -Method 'POST' -Headers $headers -Body $type_body
    
        return $($create_new_category.data.id)
    }
    catch{
     Write-Host "Error creating new password-category $new_type : $($_.exception.message). Password will be created without password category"
    }

}

function get_pass_type {

    param(
        [string]$type_name

    )
    try{
        
        $type_url = "https://api.itglue.com/password_categories?filter[name]=$type_name"

        $find_type = Invoke-RestMethod -Uri $type_url -Method 'GET' -Headers $headers
        
        if($($find_type.data) -eq $null){

            Write-Host "No password category found with $type_name. Creating new password category!" -ForegroundColor Yellow

            new_type -new_type "$type_name"
        }
        else {
                return $($find_type.data.id)
              
        }

    }
    catch {
        Write-Host "Error creating new password-folder $new_folder :$($_.exception.message). Password will be created in the root folder" -ForegroundColor Red
        return
    }
}

######################## Create passwords ###############################

function create_password {

    param(
        [int]$password_org_id,
        [string]$password_name,
        [string]$password_username,
        [string]$password_value,
        [string]$password_otp,
        [string]$password_url,
        [string]$password_notes,
        [string]$password_folder_id,
        [string]$password_category_id
    )


$pass_create_body = @"
{
    "data": {
        "type": "passwords",
        "attributes": {
            "organization-id": "$password_org_id",
            "name": "$password_name",
            "username": "$password_username",
            "password": "$password_value",
            "url": "$password_url",
            "notes": "$password_notes",
            "password-category-id": "$password_category_id",
            "password-folder-id": "$password_folder_id",
            "otpSecret": "$password_otp"
        }
    }
}
"@

Write-Host $pass_create_body

    try{

        $new_pass = Invoke-RestMethod "https://api.itglue.com/passwords" -Method 'POST' -Headers $headers -Body $pass_create_body

        Write-Host "Password $password_name created Successfully!" -ForegroundColor Green
    }
    catch{
        
        Write-Error "Error creating password! Please check if the required fields are empty!"
        return
    }
    

}

##################### Extract Data from CSV #####################

function extract_csv {
    
    $path = Read-Host "Enter the CSV file path"

    $CSVData = Import-Csv -Path $path    

    foreach($passwords in $CSVData){

        $pass_org_id = get_org_id -org_name "$($passwords.organization)"

        if ($pass_org_id -ne $null){

            
            if (-not [string]::IsNullOrWhiteSpace($passwords.password_folder)){
            
               $pass_folder_id = get_pass_folder -id "$pass_org_id" -name "$($passwords.organization)" -folder_name "$($passwords.password_folder)"
            }
            else{

                $pass_folder_id = $($passwords.password_folder)
            }

            if (-not [string]::IsNullOrWhiteSpace($passwords.password_category)){

                $pass_type_id = get_pass_type -type_name "$($passwords.password_category)"
            }
            else{
                $pass_type_id = $($passwords.password_category)
            }

        }
        else{

            Write-Host "Unable to create the password record $($passwords.name) due to the missing organization! Moving to the next records" -ForegroundColor Yellow

            return
        }

        Write-Host $pass_org_id $($passwords.name) $($passwords.username) $($passwords.password) $($passwords.otp_secret) $($passwords.url) $pass_folder_id $pass_type_id

        create_password -password_org_id "$pass_org_id" -password_name "$($passwords.name)" -password_username "$($passwords.username)" -password_value "$($passwords.password)" -password_otp "$($passwords.otp_secret)" -password_url "$($passwords.url)" -password_notes "$($passwords.notes)" -password_folder_id "$pass_folder_id" -password_category_id "$pass_type_id"
    
    
    }
}

################### Request Information ##########################

function request_data {

    $subdomain = Read-Host "Enter your IT Glue subdomain"

    if ($email -eq $null) {
        $email = Read-Host "Enter your IT Glue username"
    }

    if ($password -eq $null) {
        $password = Read-Host "Enter your IT Glue password"
    }
    
    $otp = Read-Host "Enter your IT Glue OTP"
    

    authorization_token -email "$email" -password "$password" -otp "$otp" -subdomain "$subdomain"

    extract_csv

}

#################### Headers #########################

if ($access_token -eq $null){
    
    Write-Host "Access token required!" -ForegroundColor Yellow

    $access_token = request_data
    

}
