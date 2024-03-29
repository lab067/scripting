$password = Read-Host "Enter password" -AsSecureString

New-Mailbox -UserPrincipalName username@example.com -Alias alias -Database "DBNAME" -Name "FirstName LastName" -OrganizationalUnit "the OU" -Password $password -DisplayName "FirstName LastName" -ResetPasswordOnNextLogon $false

# Add Title
Import-Module ActiveDirectory
Set-ADUser -Identity username -Title "Job Title"
# Add to relevent group memberships
Add-ADGroupMember CloudSignatures username
#use this one liner to copy another users group memberships wholesale
Get-ADUser -Identity existinguser01 -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members newuser01
# you can add mailbox delegation to on-prem mailboxes at this point - EO mailboxes later
Add-MailboxPermission -Identity "OnPremMailbox" -User "new user" -AccessRights FullAccess -InheritanceType All

# then sync
repadmin /syncall /APeD

# then adsync and wait a couple of minutes for it to run through to sync process
start-AdsyncSyncCycle -PolicyType Delta

## Then go migrate mailbox using the 365 portal GUI (or exchange online powershell)

# $Credentials = Get-Credential
# $MigrationEndpointOnPrem = New-MigrationEndpoint -ExchangeRemoteMove -Name OnpremEndpoint -Autodiscover -EmailAddress administrator@onprem.contoso.com -Credentials $Credentials
# if you already have a migraiton endpoint you can just go 
$migrationEndpointOnPrem = get-migrationendpoint # instead of creating a new one.

#Creation the batch and autostart and autocomplete it
$OnboardingBatch = New-MigrationBatch -Name RemoteOnBoarding1 -SourceEndpoint $MigrationEndpointOnprem.Identity -TargetDeliveryDomain contoso.mail.onmicrosoft.com -CSVData ([System.IO.File]::ReadAllBytes("C:\onboarding.txt"))  -AutoComplete -AutoStart -NotificationEmails user@user.com
Start-MigrationBatch -Identity $OnboardingBatch.Identity # only needed if autstart not specified in New-MigraitonBatch

## Note the -CSVDATA file should be in the format:
## EMAILADDRESS
## user1@example.com
## user2@example.com 
## ...
## usern@@example.com

# Monitor how your migration batch(s) are going.
Get-MigrationBatch | Select-Object Identity,TotalCount,SyncedCount,FailedCount,FinalizedCount,State,WorkflowStage,DataConsistencyScore

### After Migration of mailbox

### Assigning Licensing
Connect-MsolService
Get-MsolAccountSku
Set-MsolUser -UserPrincipalName user@example.com -UsageLocation AU
Set-MsolUserLicense -UserPrincipalName user@example.com -AddLicenses organisationame:SPB # SPD is Microsoft 365 Business Premium


# Set ACLs on mailboxes in Exchange Online - resolves some cross permissions issues between Exchange 2010 and EXO in a hybrid configuration
# This command is performed on the on-prem server's exchange shell and you will most likely need to import-module activedirectory
Get-RemoteMailbox -ResultSize unlimited | where {$_.RecipientTypeDetails -eq "RemoteUserMailbox"} | foreach {Get-AdUser -Identity $_.Guid | Set-ADObject -Replace @{msExchRecipientDisplayType=-1073741818}}

# Manual setting of delegation permissions - run these on EXO and On-Prem.
# On-Prem
Add-ADPermission -Identity OnPremUser -User EXOUser -AccessRights ExtendedRight -ExtendedRights "Send As"
# Exchange Online
Add-RecipientPermission -Identity OnPremUser -Trustee EXOUser -AccessRights SendAs


### Then sync data in Exclimaer cloud and do a policy test for the new users
