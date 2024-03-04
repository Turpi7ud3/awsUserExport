#!/bin/bash

# Output CSV file
output_file="user_info.csv"

# Header for CSV
echo "User,Groups,MFA Enabled,Console Access" > $output_file

# List all IAM users
users=$(aws iam list-users --output json | jq -r '.Users[].UserName')

# Loop through each user
for user in $users; do
    # Get groups for each user
    groups=$(aws iam list-groups-for-user --user-name $user --output json | jq -r '.Groups[].GroupName' | tr '\n' ',' | sed 's/,$//')  # Convert groups to CSV format

    # Check if MFA is enabled for the user
    mfa_enabled=$(aws iam list-mfa-devices --user-name $user --output json | jq -r '.MFADevices | length')

    # Check if the user has console access
    console_access=$(aws iam get-user --user-name $user --output json | jq -r '.User.PasswordLastUsed')

    # Format MFA and console access status 
    mfa_status="Disabled"
    if [ $mfa_enabled -gt 0 ]; then
        mfa_status="Enabled"
    fi

    access_status="No"
    if [ "$console_access" != "null" ]; then
        access_status="Yes"
    fi

    # Print the information to CSV
    echo "$user,$groups,$mfa_status,$access_status" >> $output_file
done

echo "User information exported to $output_file"

