# Exhcnage Online: approves migration mailboxes stuck on investigate faster thant the GUI. Review the mailbox first before using!
Get-MigrationUser -BatchID "Batch" | where dataconsistencyscore -eq Investigate | where status -eq Synced | Set-MigrationUser -ApproveSkippedItems

# Exchange CSR example
New-ExchangeCertificate -GenerateRequest -KeySize 4096 -SubjectName "C=AU, O=YourCompanyInc, cn=YourFirstDomain.com" -DomainName YourSecondDomain.com, YourThirdDomain.com -PrivateKeyExportable:$true
Import-ExchangeCertificate -FileData ([System.IO.File]::ReadAllBytes('C:\Users\SysAdmin\Desktop\certName.crt'))
Enable-ExchangeCertificate -Thumbprint XXXXXXXXXXXXXXXXXXXXXXXX -Services POP,IMAP,IIS,SMTP

# Cleans out moved/deleted mailboxes in database QFSDB2
# Note: replace "SofteDeleted" with "Disabled" for mailboxes that have not yet been deleted but you want to clear out as well.
Get-MailboxStatistics -Database "QFSDB2" -OutBuffer 1000 | ? {$_.DisconnectReason -eq "SoftDeleted"} | foreach {Remove-StoreMailbox -Database $_.database -Identity $_.mailboxguid -MailboxState SoftDeleted -Confirm}

# Show move requests progress
Get-MoveRequest -ResultSize Unlimited | Get-MoveRequestStatistics

# Show the available whitespace on the databases
Get-MailboxDatabase -Status | select Name,DatabaseSize,AvailableNewMailboxSpace

# Get Mailbox statistics
Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | Sort-Object TotalItemSize -Descending | Select-Object DisplayName,TotalItemSize,Database

# Get Mailbox statistics and export to a csv file
Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | Sort-Object TotalItemSize -Descending | Select-Object DisplayName,TotalItemSize,Database | Export-Csv c:\mailboxstats.csv

#Add mailbox permissions for Calendar access with group selection and object iteration loop
$mailboxes = @(Get-ADGroupMember "Executive" | ForEach-Object { get-mailbox $_.distinguishedname }) foreach ($mbx in $mailboxes) { Add-MailboxFolderPermission -Identity "$($mbx.Alias):\Calendar" -User omorgan -AccessRights Reviewer}

# Get a list of all the mailboxes that forward to a particular user (johndoe).
$RecipientCN = (get-recipient johndoe).Identity
Get-Mailbox -ResultSize Unlimited -Filter "ForwardingAddress -eq '$RecipientCN'"

# Message tracing with export in Exchange 2010 shell example
get-messagetrackinglog -Start "6/11/2021 12:00:00 AM" -End "7/11/2021 11:59:59 PM" | select timestemp, eventid, source, sourcetext, messageid, messagesubject, sender, {$recipients}, internalmessageid, clientip, clienthostname, serverip, serverhostname, connectorid, {$_.recipientstatus}, totalbytes, recipiencount, relatedrecipientaddress, reference, returnpath, messageinfo | export-csv c:\exportfile.csv

# Mailbox Recipient Permissions with hybrid exchange run in exchange online
Add-RecipientPermission -Identity EXO1USER -Trustee ONPREM1USER -AccessRights SendAs

# New-Mailbox and User creation one liner.
<# NAME
    New-Mailbox
SYNOPSIS
    Use the New-Mailbox cmdlet to create a user in Active Directory and mailbox-enable this new user.
    -------------------------- EXAMPLE 1 -------------------------
    This example creates a user Chris Ashton in Active Directory and creates a mailbox for the user. The mailbox is loc
    ated on Mailbox Database 1. The password must be reset at the next logon. To set the initial value of the password,
     this example creates a variable ($password), prompts you to enter a password, and assigns that password to the var
    iable as a SecureString object.
#>
    $password = Read-Host "Enter password" -AsSecureString
    New-Mailbox -UserPrincipalName user01@contoso.com -Alias chris -Database "Mailbox Database 1" -Name User01 -OrganizationalUnit Users -Password $password -FirstName User -LastName 01 -DisplayName "User01" -ResetPasswordOnNextLogon $false
  
# Add a user to a distribution group and bypass manager check
Add-DistributionGroupMember -Identity "DL Name" -Member "user name" -BypassSecurityGroupManager

# Add the exchange console to a session
Add-PSsnapin Microsoft.Exchange.Management.PowerShell.E2010

