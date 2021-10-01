<#

EMIE Go LIVE script

By Steven Wight 24/09/2021

#>

$Errorcount = 0

$WebServers = ("\\EMIEWEBSERVER01.POSHYT.corp\emie$",
               "\\EMIEWEBSERVER02.POSHYT.corp\emie$",
               "\\EMIEWEBSERVER03.POSHYT.corp\emie$",
               "\\EMIEWEBSERVER04.POSHYT.corp\emie$")

#Get version info

[XML]$VersionData = Get-Content "EMIEWEBSERVER01.POSHYT.corp\emie$\IE11-EnterpriseMode-SiteList-v2.xml"

$OldVersion = $VersionData."site-list".version

Foreach($webserver in $webservers){ # loop through webservers and backup existing EMIE file

    Try{
    #rename existing prod EMIE file to back it up
    Rename-Item -Path "$($webserver)\IE11-EnterpriseMode-SiteList-v2.xml" -NewName "IE11-EnterpriseMode-SiteList-v2.xml.v$($OldVersion)" -ErrorAction Stop -whatif
    Write-host -ForegroundColor Green "Backup created on $($webserver)"
    }catch{
        $Errorcount++
        $ErrorMessage = $_.Exception.Message
        Write-host -ForegroundColor RED "Issue creating backup on $($webserver) because $($ErrorMessage)"
    }
}#end of foreach

if($Errorcount -gt 0){ # If there was an error during backup, notify user and come out the script when user is ready
    Write-host -ForegroundColor RED "------------------------------------------"
    Write-host -ForegroundColor RED "There was an issue backing up old version"
    Write-host -ForegroundColor RED "Please review console output"
    Write-host -ForegroundColor RED "------------------------------------------"
    Read-Host -Prompt "Press any key to continue"
    Exit
} # End of If

     
Foreach($webserver in $webservers){ # loop through webservers and move pilot file into prod

    Try{
    #Copy and rename Pilot file to Prod
    Get-ChildItem -Path "$($webserver)\IE11-EnterpriseMode-SiteList-v2_pilot.xml" -ErrorAction Stop | Copy-Item -Destination { "$($webserver)\IE11-EnterpriseMode-SiteList-v2.xml" } -ErrorAction Stop -whatif
    Write-host -ForegroundColor Green "Deployment completed on $($webserver)"
    }catch{
        $Errorcount++
        $ErrorMessage = $_.Exception.Message
        Write-host -ForegroundColor RED "Issue moving pilot file to Prod on $($webserver) because $($ErrorMessage)"
    }
}#end of foreach

if($Errorcount -gt 0){ # If there was an error during deployment, notify user and come out the script when user is ready
    Write-host -ForegroundColor RED "------------------------------------------"
    Write-host -ForegroundColor RED "There was an issue moving Pilot to Prod"
    Write-host -ForegroundColor RED "Please review console output"
    Write-host -ForegroundColor RED "------------------------------------------"
    Read-Host -Prompt "Press any key to continue"
    Exit
} # End of If

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

Write-host -ForegroundColor Green "------------------------------------------"
Write-host -ForegroundColor Green "Script executed without error"
Write-host -ForegroundColor Green "Please review console output"
Write-host -ForegroundColor Green "------------------------------------------"
Read-Host -Prompt "Press any key to continue"
