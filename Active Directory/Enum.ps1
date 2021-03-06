#Note during testing , was only able to have this work on a DC, workstations would not give results.
#Builds the LDAP search string 
$domainObj = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$PDC = ($domainObj.PdcRoleOwner).Name
$SearchString = "LDAP://"
$SearchString += $PDC + "/"
$DistinguishedName = "DC=$($domainObj.Name.Replace('.', ',DC='))"
$SearchString += $DistinguishedName
#Should look similar to LDAP://DC01.corp.com/DC=corp,DC=com
#Can now instantiate the DirectorySearcher class with the LDAP provider path. To use the DirectorySearcher class, we have to specify a SearchRoot
#which is the node in the Active Directory hierarchy where searches start.
#The search root takes the form of an object instantiated from the DirectoryEntry class.
#When no arguments are passed to the constructor, the SearchRoot will indicate that every search should return results from the entire Active Directory.

$Searcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]$SearchString)
$objDomain = New-Object System.DirectoryServices.DirectoryEntry
$Searcher.SearchRoot = $objDomain
#DirectorySearcher objct is ready, but require filters through the samAccountType
#According to notes 805306368 is decimal for hex 0x30000000

#To search for all users
$Searcher.filter="samAccountType=805306368"
#Replace to search for specific users
#$Searcher.filter="name=Admin"
#Replace to search for SPNs https://adsecurity.org/?page_id=183
#$Searcher.filter="serviceprincipalname=*http*"
$Result = $Searcher.FindAll()
Foreach($obj in $Result)
{
Foreach($prop in $obj.Properties)
{
$prop
}
Write-Host "------------------------"
}

#To search for all groups does not show what group is nested inside other groups 
#$Searcher.filter="(objectClass=Group)"
#$Result = $Searcher.FindAll()
#Foreach($obj in $Result)
#{
#$obj.Properties.name
#}

#Take a nested group from previous search and search inside it 
#$Searcher.filter="(name=Secret_Group)"
#$Result = $Searcher.FindAll()
#Foreach($obj in $Result)
#{
#$obj.Properties.member
#}

#Results will dump names of the DistinguishedName groups members
#Take the CN out of these results and replace Secret_Group from the previous search to enumerate its members.
#You may encounter more groups nested within, keep replacing the group name.

















