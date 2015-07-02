$UPT_USERNAME = Get-ChildItem Env:UPTIME_USERNAME | select -expand value;
$UPT_PASSWORD = Get-ChildItem Env:UPTIME_PASSWORD | select -expand value;
$UPT_HOSTNAME = Get-ChildItem Env:UPTIME_HOSTNAME | select -expand value;
$UPT_AUTHENTICATE = Get-ChildItem Env:UPTIME_AUTHENTICATE | select -expand value;
$UPT_WQL = Get-ChildItem Env:UPTIME_WQL | select -expand value;
If($UPT_AUTHENTICATE -eq "true") {$credential = New-Object System.Management.Automation.PsCredential($UPT_USERNAME, (ConvertTo-SecureString $UPT_PASSWORD -AsPlainText -Force))}

#Retrieve data from user supplied query using authentication or not depending on choice
If($UPT_AUTHENTICATE -eq "true")
{
	$collitems = Get-WMIObject -Credential $credential -Query $UPT_WQL -ComputerName $UPT_HOSTNAME
}
ELSE 
{
	$collitems = Get-WMIObject -Query $UPT_WQL -ComputerName $UPT_HOSTNAME	
}
#list the member properties and filter out the junk
$collitems_members = $collitems | gm -membertype properties | select -expand Name | ?{@("Name","PSComputerNAme","__Class","__DERIVATION","__DYNASTY","__GENUS","__NAMESPACE","__PATH","__PROPERTY_COUNT","__RELPATH","__SERVER","__SUPERCLASS","Description","Caption","Timestamp_Object","Timestamp_PerfTime","Timestamp_Sys100NS","Frequency_Object","Frequency_PerfTime","Frequency_Sys100NS") -notcontains $_}
#run through each object and their properties
foreach ($objitem in $collitems) {
	foreach ($objmember in $collitems_members) {
		#Write-Host ("{0}{1}{2}{3}{4}{5}" -f $objitem.__CLASS, $objitem.Name,'.',$objmember,'.WMI_value ',$objitem.$objmember)
		Write-Host ("{0}({1}){2}{3}" -f $objmember,$objitem.Name,'.WMI_value ',$objitem.$objmember)
	}
}