<#

EMIE Rollback script

By Steven Wight 01/10/2021

#>

$Errorcount = 0

$WebServers = ("\\EMIEWEBSERVER01.POSHYT.corp\emie$",
               "\\EMIEWEBSERVER02.POSHYT.corp\emie$",
               "\\EMIEWEBSERVER03.POSHYT.corp\emie$",
               "\\EMIEWEBSERVER04.POSHYT.corp\emie$")

#Get version info

[XML]$VersionData = Get-Content "\\EMIEWEBSERVER01.POSHYT.corp\emie$\IE11-EnterpriseMode-SiteList-v2.xml"

$Version = $VersionData."site-list".version

$OldVersion = ($Version - 1)

Foreach($webserver in $webservers){ # loop through webservers and move failed version out the way

    Try{
    #rename existing prod EMIE file to fail
    Rename-Item -Path "$($webserver)\IE11-EnterpriseMode-SiteList-v2.xml" -NewName "IE11-EnterpriseMode-SiteList-v2.xml.v$($Version).FAIL" -ErrorAction Stop
    Write-host -ForegroundColor Green "Failed version moved out $($webserver)"
    }catch{
        $Errorcount++
        $ErrorMessage = $_.Exception.Message
        Write-host -ForegroundColor RED "Issue Moving Failed version out on $($webserver) because $($ErrorMessage)"
    }
}#end of foreach

if($Errorcount -gt 0){ # If there was an error during backup, notify user and come out the script when user is ready
    Write-host -ForegroundColor RED "------------------------------------------"
    Write-host -ForegroundColor RED "There was an issue moving out failed version"
    Write-host -ForegroundColor RED "Please review console output"
    Write-host -ForegroundColor RED "------------------------------------------"
    Read-Host -Prompt "Press any key to continue"
    Exit
} # End of If

     
Foreach($webserver in $webservers){ # loop through webservers and move pilot file into prod

    Try{
    #Copy and rename Previous good version back into Prod
    Get-ChildItem -Path "$($webserver)\IE11-EnterpriseMode-SiteList-v2.xml.v$($OldVersion)" -ErrorAction Stop | Copy-Item -Destination { "$($webserver)\IE11-EnterpriseMode-SiteList-v2.xml" } -ErrorAction Stop
    Write-host -ForegroundColor Green "Rollback to $($oldversion) completed on $($webserver)"
    }catch{
        $Errorcount++
        $ErrorMessage = $_.Exception.Message
        Write-host -ForegroundColor RED "Issue Rolling back to $($oldversion) on $($webserver) because $($ErrorMessage)"
    }
}#end of foreach

Foreach($webserver in $webservers){ # loop through webservers and confirm the existance of the Prod file

    Try{
    #Clear variables, check for file and get file creation date
    $filecheck = $FileDate = $null
    $filecheck = Test-Path -Path "$($webserver)\IE11-EnterpriseMode-SiteList-v2.xml" -ErrorAction Stop
    if($true -eq $filecheck){
        $FileDate = (Get-ChildItem "$($webserver)\IE11-EnterpriseMode-SiteList-v2.xml").CreationTime
        Write-host -ForegroundColor Green "File Check Successful on $($webserver) and file was created on $($FileDate) - CURRENT TIME/DATE $(get-date)"
    }
    if($false -eq $filecheck){
        Write-host -ForegroundColor RED "File Check Un-Successful on $($webserver)"
        $Errorcount++
    }
    }catch{
        $Errorcount++
        $ErrorMessage = $_.Exception.Message
        Write-host -ForegroundColor RED "Issue moving pilot file to Prod on $($webserver) because $($ErrorMessage)"
    }
}#end of foreach

if($Errorcount -gt 0){ # If there was an error during deployment, notify user and come out the script when user is ready
    Write-host -ForegroundColor RED "-------------------------------------------------------"
    Write-host -ForegroundColor RED "There was an issue checking for existance of Prod file"
    Write-host -ForegroundColor RED "Please review console output"
    Write-host -ForegroundColor RED "-------------------------------------------------------"
    Read-Host -Prompt "Press any key to continue"
    Exit
} # End of If

if($Errorcount -gt 0){ # If there was an error during deployment, notify user and come out the script when user is ready
    Write-host -ForegroundColor RED "------------------------------------------"
    Write-host -ForegroundColor RED "There was an issue rolling back"
    Write-host -ForegroundColor RED "Please review console output"
    Write-host -ForegroundColor RED "------------------------------------------"
    Read-Host -Prompt "Press any key to continue"
    Exit
} # End of If

Write-host -ForegroundColor Green "------------------------------------------"
Write-host -ForegroundColor Green "Script executed without error"
Write-host -ForegroundColor Green "Please review console output"
Write-host -ForegroundColor Green "------------------------------------------"
Read-Host -Prompt "Press any key to continue"
