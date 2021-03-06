﻿<#
.SYNOPSIS
	Reconfigures the DNS Server(s) on a network interface on specified computers in 
	Microsoft Active Directory.
.DESCRIPTION
	Reconfigures the DNS Server(s) on a network interface on specified computers in 
	Microsoft Active Directory. The computer accounts processed are filtered by IPEnabled 
	and DHCP Disabled. Only computers using a Static IP Address are processed.
	
	Creates a text file named DNSChangeStatus.txt, by default, in the folder where the script 
	is run.
	
	Optionally, can specify the output folder.
	
	The user running the script must be a member of Domain Admins.
	
	The script has been tested with PowerShell versions 3, 4, 5, and 5.1.
	The script has been tested with Microsoft Windows Server 2008 R2 (with PowerShell V3), 
	2012, 2012 R2, 2016, 2019 and Windows 10.
.PARAMETER Dev
	Clears errors at the beginning of the script.
	Outputs all errors to a text file at the end of the script.
	
	This is used when the script developer requests more troubleshooting data.
	The text file is placed in the same folder from where the script is run.
	
	This parameter is disabled by default.
.PARAMETER DNSServer
	One or more DNS Server entries used for updating NIC properties.
	
	DNSServer can be entered as the NetBIOS name, FQDN, or IP Address.

	If entered as a NetBIOS name or FQDN, an attempt is made to determine and 
	use the actual IP address.
.PARAMETER Folder
	Specifies the optional output folder to save the output reports. 
.PARAMETER Log
	Generates a log file for troubleshooting.
.PARAMETER Name
	Specifies the Name of the target computer.
	
	Accepts input from the pipeline.
.PARAMETER ScriptInfo
	Outputs information about the script to a text file.
	The text file is placed in the same folder from where the script is run.
	
	This parameter is disabled by default.
	This parameter has an alias of SI.
.PARAMETER SmtpServer
	Specifies the optional email server to send the output report. 
.PARAMETER SmtpPort
	Specifies the SMTP port. 
	The default is 25.
.PARAMETER UseSSL
	Specifies whether to use SSL for the SmtpServer.
	The default is False.
.PARAMETER From
	Specifies the username for the From email address.
	If SmtpServer is used, this is a required parameter.
.PARAMETER To
	Specifies the username for the To email address.
	If SmtpServer is used, this is a required parameter.
.EXAMPLE
	Get-ADComputer -Filter * | .\Set-DNSInfo.ps1 -DNSServer 192.168.1.1

	Updates the Primary DNS server to 192.168.1.1 on all the computers matching the 
	filter that also have IPEnabled and use a static IP address.
.EXAMPLE
	"Win10_1","Win10_2" | .\Set-DNSInfo.ps1 -DNSServer 192.168.1.1

	Updates the Primary DNS server to 192.168.1.1 on the computers Win10_1 and Win10_2 
	if they have IPEnabled and use a static IP address.
.EXAMPLE
	Get-AdComputer -filter {OperatingSystem -like "*window*"} | 
	.\Set-DNSInfo.ps1 -Folder \\FileServer\ShareName -DNSServer 192.168.1.1
	
	Updates the Primary DNS server to 192.168.1.1 on all the computers matching the 
	filter that also have IPEnabled and use a static IP address.
	
	Output file will be saved in the path \\FileServer\ShareName
.EXAMPLE
	Get-AdComputer -filter {OperatingSystem -like "*window*"} 
	-SearchBase "ou=SQLServers,dc=domain,dc=tld" 
	-SearchScope Subtree 
	-properties Name -EA 0 | 
	Sort Name | 
	.\Set-DNSInfo.ps1 -DNSServer "192.168.20.1","192.168.20.2"
	
	Updates the Primary DNS server to 192.168.20.1 and the Secondary DNS server to 
	192.168.20.2 on all the computers matching the filter that also have IPEnabled 
	and use a static IP address.
.EXAMPLE
	Get-AdComputer -filter {OperatingSystem -like "*window*"} 
	-properties Name -EA 0 | Sort Name | .\Set-DNSInfo.ps1 -DNSServer "DC1","DC2"
	
	Processes only computers with "window" in the OperatingSystem property

	An attempt is made to resolve both DC1 and DC2 to their IP addresses. If successful, 
	updates the Primary DNS server to the IP address of DC1 and the Secondary DNS server 
	to the IP address of DC2 on all the computers matching the filter that also have IPEnabled 
	and use a static IP address.
.EXAMPLE
	Get-AdComputer -filter {OperatingSystem -like "*window*" -and OperatingSystem 
	-like "*server*"} -properties Name -EA 0 | Sort Name | 
	.\Set-DNSInfo.ps1 -DNSServer "dc1.domain.com","dc2.domain.com"
	
	Processes only computers with "window" and "server" in the OperatingSystem property.
	This catches operating systems like Windows 2000 Server and Windows Server 2003.

	An attempt is made to resolve both dc1.domain.com and dc2.domain.com to their IP 
	addresses. If successful, updates the Primary DNS server to the IP address of 
	dc1.domain.com and the Secondary DNS server to the IP address of dc2.domain.com on all 
	the computers matching the filter that also have IPEnabled and use a static IP address.
.EXAMPLE
	Get-AdComputer -filter {OperatingSystem -like "*window*" -and OperatingSystem 
	-like "*server*"} -EA 0 | Where {$_.DistinguishedName -NotLike "*domain controllers*"} | 
	Sort Name | .\Set-DNSInfo.ps1 -DNSServer "dc1.domain.com","dc2.domain.com"
	
	Processes only computers with "window" and "server" in the OperatingSystem property  
	and are not domain controllers. This catches operating systems like Windows 2000 Server 
	and Windows Server 2003.

	An attempt is made to resolve both dc1.domain.com and dc2.domain.com to their IP 
	addresses. If successful, updates the Primary DNS server to the IP address of 
	dc1.domain.com and the Secondary DNS server to the IP address of dc2.domain.com on all 
	the computers matching the filter that also have IPEnabled and use a static IP address.
.EXAMPLE
	Get-Content "C:\webster\computernames.txt" | .\Set-DNSInfo.ps1 -DNSServer 
	"10.100.1.1"
	
	computernames.txt is a plain text file that contains a list of computer names.
	
	For example:
	
	LABCA
	LABDC1
	LABDC2
	LABFS
	LABIGEL
	LABMGMTPC
	LABSQL1

	Updates the Primary DNS server to 10.100.1.1 on the computers contained in 
	computernames.txt Win10_1 and Win10_2 if they have IPEnabled and use a static IP address.
.EXAMPLE
	.\Set-DNSInfo.ps1
	
	You are prompted for a list of computer Names to have the DNS Server(s) changed.
	You are prompted for a list of DNS Server IP addresses.
	
	PS C:\PSScript> .\Set-DNSInfo.ps1                                                                                        
	cmdlet Set-DNSInfo.ps1 at command pipeline position 1
	Supply values for the following parameters:
	Name[0]: LabFS
	Name[1]:
	DNSServer[0]: 192.168.1.202
	DNSServer[1]: 192.168.1.201
	DNSServer[2]:
	VERBOSE: 12/12/2020 12:12:12: Setting up script
	VERBOSE: 12/12/2020 12:12:12: Validating DNSServer entries
	VERBOSE: 12/12/2020 12:12:12:  Processing 192.168.1.202
	VERBOSE: 12/12/2020 12:12:12:  Processing 192.168.1.201
	VERBOSE: 12/12/2020 12:12:12:
	<snip>
	VERBOSE: 12/12/2020 12:12:12:
	VERBOSE: 12/12/2020 12:12:12: Processing computer LabFS
	VERBOSE: 12/12/2020 12:12:12:  Successfully updated the DNS Server(s) on LabFS
	VERBOSE: 12/12/2020 12:12:12: C:\PSScript\DNSChangeStatus.txt is ready for use
	VERBOSE: 12/12/2020 12:12:12: Script has completed
.EXAMPLE
	Get-ADComputer -Filter * | .\Set-DNSInfo.ps1 
	-SmtpServer mail.domain.tld
	-From XDAdmin@domain.tld 
	-To ITGroup@domain.tld	

	The script will use the email server mail.domain.tld, sending from XDAdmin@domain.tld, 
	sending to ITGroup@domain.tld.

	The script will use the default SMTP port 25 and will not use SSL.

	If the current user's credentials are not valid to send email, 
	the user will be prompted to enter valid credentials.
.EXAMPLE
	Get-ADComputer -Filter * | .\Set-DNSInfo.ps1
	-SmtpServer mailrelay.domain.tld
	-From Anonymous@domain.tld 
	-To ITGroup@domain.tld	

	***SENDING UNAUTHENTICATED EMAIL***

	The script will use the email server mailrelay.domain.tld, sending from 
	anonymous@domain.tld, sending to ITGroup@domain.tld.

	To send unauthenticated email using an email relay server requires the From email account 
	to use the name Anonymous.

	The script will use the default SMTP port 25 and will not use SSL.
	
	***GMAIL/G SUITE SMTP RELAY***
	https://support.google.com/a/answer/2956491?hl=en
	https://support.google.com/a/answer/176600?hl=en

	To send email using a Gmail or g-suite account, you may have to turn ON
	the "Less secure app access" option on your account.
	***GMAIL/G SUITE SMTP RELAY***

	The script will generate an anonymous secure password for the anonymous@domain.tld 
	account.
.EXAMPLE
	Get-ADComputer -Filter * | .\Set-DNSInfo.ps1
	-SmtpServer labaddomain-com.mail.protection.outlook.com
	-UseSSL
	-From SomeEmailAddress@labaddomain.com 
	-To ITGroupDL@labaddomain.com	

	***OFFICE 365 Example***

	https://docs.microsoft.com/en-us/exchange/mail-flow-best-practices/how-to-set-up-a-multifunction-device-or-application-to-send-email-using-office-3
	
	This uses Option 2 from the above link.
	
	***OFFICE 365 Example***

	The script will use the email server labaddomain-com.mail.protection.outlook.com, 
	sending from SomeEmailAddress@labaddomain.com, sending to ITGroupDL@labaddomain.com.

	The script will use the default SMTP port 25 and will use SSL.
.EXAMPLE
	Get-ADComputer -Filter * | .\Set-DNSInfo.ps1
	-SmtpServer smtp.office365.com 
	-SmtpPort 587
	-UseSSL 
	-From Webster@CarlWebster.com 
	-To ITGroup@CarlWebster.com	

	The script will use the email server smtp.office365.com on port 587 using SSL, 
	sending from webster@carlwebster.com, sending to ITGroup@carlwebster.com.

	If the current user's credentials are not valid to send email, 
	the user will be prompted to enter valid credentials.
.EXAMPLE
	Get-ADComputer -Filter * | .\Set-DNSInfo.ps1
	-SmtpServer smtp.gmail.com 
	-SmtpPort 587
	-UseSSL 
	-From Webster@CarlWebster.com 
	-To ITGroup@CarlWebster.com	

	*** NOTE ***
	To send email using a Gmail or g-suite account, you may have to turn ON
	the "Less secure app access" option on your account.
	*** NOTE ***
	
	The script will use the email server smtp.gmail.com on port 587 using SSL, 
	sending from webster@gmail.com, sending to ITGroup@carlwebster.com.

	If the current user's credentials are not valid to send email, 
	the user will be prompted to enter valid credentials.
.INPUTS
	Accepts pipeline input with the property Name or a list of computer names.
.OUTPUTS
	No objects are output from this script.  This script creates one text file.
.NOTES
	NAME: Set-DNSInfo.ps1
	VERSION: 1.00
	AUTHOR: Carl Webster and Michael B. Smith
	LASTEDIT: August 6, 2020
#>


#region script change log	
#Created by Carl Webster and Michael B. Smith
#webster@carlwebster.com
#@carlwebster on Twitter
#https://www.CarlWebster.com
#
#michael@smithcons.com
#@essentialexch on Twitter
#https://www.essential.exchange/blog/
#
#Created on April 30, 2020
#
#Version 1.0 released to the community on 11-August-2020
#
#endregion


[CmdletBinding(SupportsShouldProcess = $False, ConfirmImpact = "None", DefaultParameterSetName = "") ]

Param(
	[parameter(
		Mandatory                       = $True,
		ValueFromPipeline               = $True,
		ValueFromPipelineByPropertyName = $True,
		Position                        = 0)] 
	[string[]]$Name,
	
	[parameter(Mandatory=$True)] 
	[Array]$DNSServer,
	
	[parameter(Mandatory=$False)] 
	[Switch]$Dev=$False,
	
	[parameter(Mandatory=$False)] 
	[string]$Folder="",
	
	[parameter(Mandatory=$False)] 
	[Switch]$Log=$False,
	
	[parameter(Mandatory=$False)] 
	[Alias("SI")]
	[Switch]$ScriptInfo=$False,
	
	[parameter(Mandatory=$False)] 
	[string]$SmtpServer="",

	[parameter(Mandatory=$False)] 
	[int]$SmtpPort=25,

	[parameter(Mandatory=$False)] 
	[switch]$UseSSL=$False,

	[parameter(Mandatory=$False)] 
	[string]$From="",

	[parameter(Mandatory=$False)] 
	[string]$To=""

	)

Begin
{
	#region 
	Function UserIsaDomainAdmin
	{
		#function adapted from sample code provided by Thomas Vuylsteke
		$IsDA = $False
		$name = $env:username
		Write-Verbose "$(Get-Date): TokenGroups - Checking groups for $name"

		$root = [ADSI]""
		$filter = "(sAMAccountName=$name)"
		$props = @("distinguishedName")
		$Searcher = new-Object System.DirectoryServices.DirectorySearcher($root,$filter,$props)
		$account = $Searcher.FindOne().properties.distinguishedname

		$user = [ADSI]"LDAP://$Account"
		$user.GetInfoEx(@("tokengroups"),0)
		$groups = $user.Get("tokengroups")

		$grp = [ADSI] ( 'WinNT://' + $env:userdnsdomain + '/Domain Admins,group' )
		$sid = New-Object System.Security.Principal.SecurityIdentifier( $grp.objectSid.Item( 0 ), 0 )
		
		ForEach($group in $groups)
		{     
			$ID = New-Object System.Security.Principal.SecurityIdentifier($group,0)       
			If($ID.Equals($sid))
			{
				$IsDA = $True
				Break
			}     
		}

		Return $IsDA
	}
	
	Function testPort
	{
		Param
		(
		[String] $computer,
		[Int[]]  $ports,
		[Int]    $timeOut,
		[Bool]   $quiet = $false
		)

		If( $result = $computer -as [System.Net.IpAddress] )
		{
			## we got passed an IP address, not a DNS name. Resolve-DnsName doesn't just
			## pass it through, but instead returns a PTR record. I consider it broken,
			## but it is what it is.
			$success = testPortsOnOneIP $computer $ports $timeOut $result.AddressFamily $quiet

			Return $success
		}

		$results = Resolve-DnsName -Name $computer -Type A_AAAA -EA 0 4>$Null

		$success = $false

		ForEach( $result in $results )
		{
			$type = $result.Type.ToString()
			If( $type -ne 'A' -and $type -ne 'AAAA' )
			{
				Continue
			}

			$ip = $result.IPAddress
			If( $type -eq 'AAAA' )
			{
				If( -not ( canRoute $ip ) )
				{
					Continue
				}

				$family = [System.Net.Sockets.AddressFamily]::InterNetworkv6
			}
			Else
			{
				$family = [System.Net.Sockets.AddressFamily]::InterNetwork
			}

			$success = $success -or ( testPortsOnOneIP $ip $ports $timeOut $family $quiet )
		}

		$results = $null

		$success
	}

	Function testPortsOnOneIP
	{
		Param
		(
			[String] $ip,
			[Int[]]  $ports,
			[Int]    $timeOut,
			[System.Net.Sockets.AddressFamily] $family,
			[Bool]   $quiet
		)

		$success = $false

		ForEach( $port in $ports )
		{
			$tcpclient = New-Object System.Net.Sockets.TcpClient( $family )

			$async = $tcpclient.BeginConnect( $ip, $port, $null, $null )
			$wait  = $async.AsyncWaitHandle.WaitOne( $timeOut, $false )
			If( !$wait )
			{
				$tcpclient.Close()
				Continue
			}
			Else
			{
				$error.Clear()
				$null = $tcpclient.EndConnect( $async )
				If( $error -and $error.Count -gt 0 )
				{
				}
				Else
				{
					$success = $true
				}
				$tcpclient.Close()
			}

			$wait      = $null
			$async     = $null
			$tcpclient = $null

			If( $success )
			{
				## break
			}
		}

		$success
	}
	#endregion
	
	Set-StrictMode -Version Latest
	$PSDefaultParameterValues = @{"*:Verbose"=$True}
	
	$AmIReallyDA = UserIsADomainAdmin
	If($AmIReallyDA -eq $False)
	{
		Write-Error "
		`n`n
		`t`t
		$env:username is not a Domain Admin.
		`n`n
		`t`t
		Script cannot continue.
		`n`n"
		Exit
	}
	Else
	{
		Write-Verbose "$(Get-Date): $env:username has Domain Admin rights"
	}
	
	If(![String]::IsNullOrEmpty($SmtpServer) -and [String]::IsNullOrEmpty($From) -and [String]::IsNullOrEmpty($To))
	{
		Write-Error "
		`n`n
		`t`t
		You specified an SmtpServer but did not include a From or To email address.
		`n`n
		`t`t
		Script cannot continue.
		`n`n"
		Exit
	}
	If(![String]::IsNullOrEmpty($SmtpServer) -and [String]::IsNullOrEmpty($From) -and ![String]::IsNullOrEmpty($To))
	{
		Write-Error "
		`n`n
		`t`t
		You specified an SmtpServer and a To email address but did not include a From email address.
		`n`n
		`t`t
		Script cannot continue.
		`n`n"
		Exit
	}
	If(![String]::IsNullOrEmpty($SmtpServer) -and [String]::IsNullOrEmpty($To) -and ![String]::IsNullOrEmpty($From))
	{
		Write-Error "
		`n`n
		`t`t
		You specified an SmtpServer and a From email address but did not include a To email address.
		`n`n
		`t`t
		Script cannot continue.
		`n`n"
		Exit
	}
	If(![String]::IsNullOrEmpty($From) -and ![String]::IsNullOrEmpty($To) -and [String]::IsNullOrEmpty($SmtpServer))
	{
		Write-Error "
		`n`n
		`t`t
		You specified From and To email addresses but did not include the SmtpServer.
		`n`n
		`t`t
		Script cannot continue.
		`n`n"
		Exit
	}
	If(![String]::IsNullOrEmpty($From) -and [String]::IsNullOrEmpty($SmtpServer))
	{
		Write-Error "
		`n`n
		`t`t
		You specified a From email address but did not include the SmtpServer.
		`n`n
		`t`t
		Script cannot continue.
		`n`n"
		Exit
	}
	If(![String]::IsNullOrEmpty($To) -and [String]::IsNullOrEmpty($SmtpServer))
	{
		Write-Error "
		`n`n
		`t`t
		You specified a To email address but did not include the SmtpServer.
		`n`n
		`t`t
		Script cannot continue.
		`n`n"
		Exit
	}
    Write-Verbose "$(Get-Date): Setting up script"

    If($Folder -ne "")
    {
	    Write-Verbose "$(Get-Date): Testing folder path"
	    #does it exist
	    If(Test-Path $Folder -EA 0)
	    {
		    #it exists, now check to see if it is a folder and not a file
		    If(Test-Path $Folder -pathType Container -EA 0)
		    {
			    #it exists and it is a folder
			    Write-Verbose "$(Get-Date): Folder path $Folder exists and is a folder"
		    }
		    Else
		    {
			    #it exists but it is a file not a folder
			    Write-Error "
				`n`n
				`t`t
				Folder $Folder is a file, not a folder.
				`n`n
				`t`t
				Script cannot continue.
				`n`n
				"
			    Exit
		    }
	    }
	    Else
	    {
		    #does not exist
		    Write-Error "
			`n`n
			`t`t
			Folder $Folder does not exist.
			`n`n
			`t`t
			Script cannot continue.
			`n`n
			"
		    Exit
	    }
    }

    If($Folder -eq "")
    {
	    $Script:pwdpath = $pwd.Path
    }
    Else
    {
	    $Script:pwdpath = $Folder
    }

	If($Script:pwdpath.EndsWith("\"))
	{
		#remove the trailing \
		$Script:pwdpath = $Script:pwdpath.SubString(0, ($Script:pwdpath.Length - 1))
	}

	If($Log) 
	{
		#start transcript logging
		$Script:LogPath = "$($Script:pwdpath)\SetDNSInfoScriptTranscript_$(Get-Date -f yyyy-MM-dd_HHmm).txt"
		
		try 
		{
			Start-Transcript -Path $Script:LogPath -Force -Verbose:$false | Out-Null
			Write-Verbose "$(Get-Date): Transcript/log started at $Script:LogPath"
			$Script:StartLog = $true
		} 
		catch 
		{
			Write-Verbose "$(Get-Date): Transcript/log failed at $Script:LogPath"
			$Script:StartLog = $false
		}
	}

	If($Dev)
	{
		$Error.Clear()
		$Script:DevErrorFile = "$($Script:pwdpath)\SetDNSInfoScriptErrors_$(Get-Date -f yyyy-MM-dd_HHmm).txt"
	}

	#validate the DNSServer entry/entries
	Write-Verbose "$(Get-Date): Validating DNSServer entries"
	$NewDNSServers = @()
	$DNSPort = 53
	$DNSTimeout = 300	#milliseconds
	ForEach($Server in $DNSServer)
	{
		Write-Verbose "$(Get-Date): `tProcessing $Server"
		If(TestPort $Server $DNSPort $DNSTimeout)
		{
			#we know that $Server is a valid IP address or name
			
			#now see if $Server is an IP address
			If($Server -as [System.Net.IpAddress])
			{
				#$Server is an IP address, add it to the new array
				$NewDNSServers += $Server
			}
			Else
			{
				#$Server is a name. Get the IP address
				
				$results = Resolve-DnsName -Name $Server -Type A_AAAA -EA 0 4>$Null
			
				If($? -and $Null -ne $results)
				{
					$NewDNSServers += $results.IPAddress
				}
				Else
				{
					Write-Error "
					`n`n
					`t`t
					Unable to get an IP address for $Server.
					`n`n
					`t`t
					Script cannot continue.
					`n`n
					"
					Exit
				}
			}
		}
		Else
		{
			#we know that $Server is NOT a valid IP address or name
		    Write-Error "
			`n`n
			`t`t
			$Server is invalid.
			`n`n
			`t`t
			Script cannot continue.
			`n`n
			"
		    Exit
		}
	}

	#do not sort the array, use the order specified in the parameter
	$DNSServer = $NewDNSServers

    $StatusFile = "$($Script:pwdpath)\DNSChangeStatus.txt"
    Out-File -FilePath $StatusFile -InputObject $Null 4>$Null
	
	[string]$Script:Title = "DNS Change"
	[string]$Script:RunningOS = (Get-WmiObject -class Win32_OperatingSystem -EA 0).Caption

    $startTime = Get-Date

	Write-Verbose "$(Get-Date): "
	Write-Verbose "$(Get-Date): "
	Write-Verbose "$(Get-Date): Dev                : $($Dev)"
	Write-Verbose "$(Get-Date): DNSServer          : $($DNSServer)"
	Write-Verbose "$(Get-Date): Folder             : $($Script:pwdpath)"
	Write-Verbose "$(Get-Date): From               : $($From)"
	Write-Verbose "$(Get-Date): Log                : $($Log)"
	Write-Verbose "$(Get-Date): ScriptInfo         : $($ScriptInfo)"
	Write-Verbose "$(Get-Date): Smtp Port          : $($SmtpPort)"
	Write-Verbose "$(Get-Date): Smtp Server        : $($SmtpServer)"
	Write-Verbose "$(Get-Date): StatusFile         : $($StatusFile)"
	Write-Verbose "$(Get-Date): Title              : $($Script:Title)"
	Write-Verbose "$(Get-Date): To                 : $($To)"
	Write-Verbose "$(Get-Date): Use SSL            : $($UseSSL)"
	Write-Verbose "$(Get-Date): "
	Write-Verbose "$(Get-Date): OS Detected        : $($Script:RunningOS)"
	Write-Verbose "$(Get-Date): PoSH version       : $($Host.Version)"
	Write-Verbose "$(Get-Date): PSCulture          : $($PSCulture)"
	Write-Verbose "$(Get-Date): PSUICulture        : $($PSUICulture)"
	Write-Verbose "$(Get-Date): "
	Write-Verbose "$(Get-Date): Script start       : $($Script:StartTime)"
	Write-Verbose "$(Get-Date): "
	Write-Verbose "$(Get-Date): "

	#region email Function
	Function SendEmail
	{
		Param([array]$Attachments)
		Write-Verbose "$(Get-Date): Prepare to email"

		$emailAttachment = $Attachments
		$emailSubject = $Script:Title
	$emailBody = @"
Hello, <br />
<br />
$Script:Title is attached.

"@ 

		If($Dev)
		{
			Out-File -FilePath $Script:DevErrorFile -InputObject $error 4>$Null
		}

		$error.Clear()
		
		If($From -Like "anonymous@*")
		{
			#https://serverfault.com/questions/543052/sending-unauthenticated-mail-through-ms-exchange-with-powershell-windows-server
			$anonUsername = "anonymous"
			$anonPassword = ConvertTo-SecureString -String "anonymous" -AsPlainText -Force
			$anonCredentials = New-Object System.Management.Automation.PSCredential($anonUsername,$anonPassword)

			If($UseSSL)
			{
				Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
				-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To `
				-UseSSL -credential $anonCredentials *>$Null 
			}
			Else
			{
				Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
				-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To `
				-credential $anonCredentials *>$Null 
			}
			
			If($?)
			{
				Write-Verbose "$(Get-Date): Email successfully sent using anonymous credentials"
			}
			ElseIf(!$?)
			{
				$e = $error[0]

				Write-Verbose "$(Get-Date): Email was not sent:"
				Write-Warning "$(Get-Date): Exception: $e.Exception" 
			}
		}
		Else
		{
			If($UseSSL)
			{
				Write-Verbose "$(Get-Date): Trying to send email using current user's credentials with SSL"
				Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
				-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To `
				-UseSSL *>$Null
			}
			Else
			{
				Write-Verbose "$(Get-Date): Trying to send email using current user's credentials without SSL"
				Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
				-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To *>$Null
			}

			If(!$?)
			{
				$e = $error[0]
				
				#error 5.7.57 is O365 and error 5.7.0 is gmail
				If($null -ne $e.Exception -and $e.Exception.ToString().Contains("5.7"))
				{
					#The server response was: 5.7.xx SMTP; Client was not authenticated to send anonymous mail during MAIL FROM
					Write-Verbose "$(Get-Date): Current user's credentials failed. Ask for usable credentials."

					If($Dev)
					{
						Out-File -FilePath $Script:DevErrorFile -InputObject $error -Append 4>$Null
					}

					$error.Clear()

					$emailCredentials = Get-Credential -UserName $From -Message "Enter the password to send email"

					If($UseSSL)
					{
						Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
						-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To `
						-UseSSL -credential $emailCredentials *>$Null 
					}
					Else
					{
						Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
						-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To `
						-credential $emailCredentials *>$Null 
					}

					If($?)
					{
						Write-Verbose "$(Get-Date): Email successfully sent using new credentials"
					}
					ElseIf(!$?)
					{
						$e = $error[0]

						Write-Verbose "$(Get-Date): Email was not sent:"
						Write-Warning "$(Get-Date): Exception: $e.Exception" 
					}
				}
				Else
				{
					Write-Verbose "$(Get-Date): Email was not sent:"
					Write-Warning "$(Get-Date): Exception: $e.Exception" 
				}
			}
		}
	}
	#endregion

	Function ProcessComputer
	{
		Param(
			[Parameter( Mandatory = $true )]
			[string] $Name,

			[Parameter( Mandatory = $true )]
			[array] $DNSServer
		)

		$ComputerName = $Name.Trim()
		Write-Verbose "$(Get-Date): Processing computer $($ComputerName)"

		$wmi = Get-WmiObject Win32_NetworkAdapterConfiguration -filter "ipenabled = 'true' and dhcpenabled = 'false'" -ComputerName $computerName -EA 0 4>$Null

		If($null -ne $wmi)
		{
			$wmi.SetDNSServerSearchOrder( $DNSServer ) >$Null
			
			If($?)
			{
				Write-Verbose "$(Get-Date): `tSuccessfully updated the DNS Server(s) on $ComputerName"
				Out-File -FilePath $StatusFile -Append -InputObject "Successfully updated the DNS Server(s) on $ComputerName" 4>$Null
			}
			Else
			{
				Write-Verbose "$(Get-Date): `tFailed to update the DNS Server(s) on $ComputerName"
				Out-File -FilePath $StatusFile -Append -InputObject "Failed to update the DNS Server(s) on $ComputerName" 4>$Null
			}
		}
	}
}

Process
{
    If($Name -is [array])
    {
        ForEach($Computer in $Name)
        {
			ProcessComputer $Computer $DNSServer
        }
    }
    Else
    {
		ProcessComputer $Name $DNSServer
    }
}

End
{
	$emailattachments = @()
    If(Test-Path "$($StatusFile)")
    {
	    Write-Verbose "$(Get-Date): $($StatusFile) is ready for use"
		If(![System.String]::IsNullOrEmpty( $SmtpServer ))
		{
			$emailattachments += $StatusFile
		}
	}

	If(![System.String]::IsNullOrEmpty( $SmtpServer ))
	{
		SendEmail $emailattachments
	}
	
	Write-Verbose "$(Get-Date): Script has completed"
	Write-Verbose "$(Get-Date): "

    Write-Verbose "$(Get-Date): Script started: $($StartTime)"
    Write-Verbose "$(Get-Date): Script ended: $(Get-Date)"
    $runtime = $(Get-Date) - $StartTime
    $Str = [string]::format("{0} days, {1} hours, {2} minutes, {3}.{4} seconds", `
	    $runtime.Days, `
	    $runtime.Hours, `
	    $runtime.Minutes, `
	    $runtime.Seconds,
	    $runtime.Milliseconds)
    Write-Verbose "$(Get-Date): Elapsed time: $($Str)"

	If($Dev)
	{
		If($SmtpServer -eq "")
		{
			Out-File -FilePath $Script:DevErrorFile -InputObject $error 4>$Null
		}
		Else
		{
			Out-File -FilePath $Script:DevErrorFile -InputObject $error -Append 4>$Null
		}
	}

	If($ScriptInfo)
	{
		$SIFile = "$Script:pwdpath\SetDNSInfoScriptInfo_$(Get-Date -f yyyy-MM-dd_HHmm).txt"
		Out-File -FilePath $SIFile -InputObject "" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Dev                : $($Dev)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "DNSServer          : $($DNSServer)" 4>$Null
		If($Dev)
		{
			Out-File -FilePath $SIFile -Append -InputObject "DevErrorFile       : $($Script:DevErrorFile)" 4>$Null
		}
		Out-File -FilePath $SIFile -Append -InputObject "Folder             : $($Folder)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "From               : $($From)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Log                : $($Log)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Script Info        : $($ScriptInfo)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Smtp Port          : $($SmtpPort)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Smtp Server        : $($SmtpServer)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "StatusFile         : $($StatusFile)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Title              : $($Script:Title)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "To                 : $($To)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Use SSL            : $($UseSSL)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "OS Detected        : $($Script:RunningOS)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "PoSH version       : $($Host.Version)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "PSCulture          : $($PSCulture)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "PSUICulture        : $($PSUICulture)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Script start       : $($Script:StartTime)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Elapsed time       : $($Str)" 4>$Null
	}

	#stop transcript logging
	If($Log -eq $True) 
	{
		If($Script:StartLog -eq $true) 
		{
			try 
			{
				Stop-Transcript | Out-Null
				Write-Verbose "$(Get-Date): $Script:LogPath is ready for use"
			} 
			catch 
			{
				Write-Verbose "$(Get-Date): Transcript/log stop failed"
			}
		}
	}

	$runtime = $Null
	$Str = $Null
}
