$password = Read-Host "Enter password" -AsSecureString

New-Mailbox -UserPrincipalName username@example.com -Alias anash -Database "DBNAME" -Name "FirstName LastName" -OrganizationalUnit "the OU" -Password $password -DisplayName "FirstName LastName" -ResetPasswordOnNextLogon $false

Add-ADGroupMember CloudSignatures username

## Then go migrate mailbox using the 365 portal GUI (or exchange online powershell)

# $Credentials = Get-Credential
# $MigrationEndpointOnPrem = New-MigrationEndpoint -ExchangeRemoteMove -Name OnpremEndpoint -Autodiscover -EmailAddress administrator@onprem.contoso.com -Credentials $Credentials
# if you already have a migraiton endpoint you can just go $migrationEndpointOnPrem = get-migrationendpoint instead of creating a new one.
$OnboardingBatch = New-MigrationBatch -Name RemoteOnBoarding1 -SourceEndpoint $MigrationEndpointOnprem.Identity -TargetDeliveryDomain contoso.mail.onmicrosoft.com -CSVData ([System.IO.File]::ReadAllBytes("C:\Users\Administrator\Desktop\RemoteOnBoarding1.csv"))
Start-MigrationBatch -Identity $OnboardingBatch.Identity -AutoComplete -AutoStart

## Note the -CSVDATA file should be in the format:
## EMAILADDRESS
## user1@example.com
## user2@example.com 
## ...
## usern@@example.com

Get-MigrationBatch # to monitor progress if you want to

### After Migration of mailbox

### Assisng Licensing
Connect-MSOL
Get-MsolAccountSku
Set-MsolUser -UserPrincipalName user@example.com -UsageLocation AU
Set-MsolUserLicense -UserPrincipalName user@example.com -AddLicenses organisationame:SPB # SPD is Microsoft 365 Business Premium


# Set ACLs on mailboxes in Exchange Online - resoles some cross permissions issues between Exchange 2010 and EXO in a hybrid configuration
Get-RemoteMailbox -ResultSize unlimited | where {$_.RecipientTypeDetails -eq "RemoteUserMailbox"} | foreach {Get-AdUser -Identity $_.Guid | Set-ADObject -Replace @{msExchRecipientDisplayType=-1073741818}}

# Manual setting of delegation permissions - run these on EXO and On-Prem.
# On-Prem
Add-ADPermission -Identity EXO1 -User ONPREM1 -AccessRights ExtendedRight -ExtendedRights "Send As"
# Exchange Online
Add-RecipientPermission -Identity EXO1 -Trustee ONPREM1 -AccessRights SendAs


### Then sync data in Exclimaer cloud and do a policy test for the new users
