<#
    Script: DWS_General_Server_Reports.ps1
#>

#Var for Server Name
[string]$srvName = (hostname).ToString().ToUpper();

#Var for Report Date
[string]$rptDate = (Get-Date).ToString("yyyy-MM-dd");

#Reporting Array for Processes
$raProcesses = @();

#Reporting Array for Services
$raServices = @();

#Reporting Array for Scheduled Tasks
$raScheduledTasks = @();

#Pull Current TCP Connections
$tcpConnections = Get-NetTCPConnection | Where-Object {$_.State -eq 'Listen'} | Sort-Object -Property LocalPort;

#Pull Current Processes
foreach($crntProcss in (Get-Process -IncludeUserName))
{
    
    #Create Custom Process Object
    $cstProcess = new-object PSObject -Property (@{ Id=""; ProcessName=""; UserName=""; ProductVersion=""; FileVersion=""; FileName=""; Ports=""; });

    #Load Process Information
    $cstProcess.Id = $crntProcss.Id;
    $cstProcess.ProcessName = $crntProcss.ProcessName;
    $cstProcess.UserName = $crntProcss.UserName;

    try
    {
        #Attempt to Pull More File Information About Running Process
        $mfProcessInfo = Get-Process -Id $crntProcss.Id -FileVersionInfo;

        if([string]::IsNullOrEmpty($mfProcessInfo.FileName) -eq $false)
        {
            $cstProcess.FileName = $mfProcessInfo.FileName;
            $cstProcess.ProductVersion = $mfProcessInfo.ProductVersion;
            $cstProcess.FileVersion = $mfProcessInfo.FileVersion; 
        }

    }
    catch
    {
        $cstProcess.FileName = "Could not pull information";
    }


    #Array List for Unique TCP Ports
    [System.Collections.ArrayList]$alTCPPorts= @();

    #Var for Listening Ports
    [string]$lstnPorts = "";

    #Check for Listening Ports
    foreach($lclTCPCon in $tcpConnections)
    {

        if($crntProcss.Id -eq $lclTCPCon.OwningProcess)
        {

            if($alTCPPorts.Contains($lclTCPCon.LocalPort) -eq $false)
            {
                [void]$alTCPPorts.Add($lclTCPCon.LocalPort);
            }
            
        }

    }#End of Check for Listening Ports

    #Check for Ports to Add to Report
    if($alTCPPorts.Count -gt 0)
    {
        foreach($tcpport in $alTCPPorts)
        {
            $lstnPorts += $tcpport.ToString() + ";";
        }

        $cstProcess.Ports = $lstnPorts.TrimEnd(";");

    }#End of $alTCPPorts Count Check

   
    #Add Custom Object to Reporting Array
    $raProcesses += $cstProcess;

}#End of Get-Process Foreach

#Pull Services
foreach($crntServce in (Get-WmiObject -Class Win32_Service -Computer localhost | Select-Object Name,DisplayName,State,StartMode,StartName,PathName))
{

    #Create Custom Service Object
    $cstService = new-object PSObject -Property (@{ Name=""; DisplayName=""; State=""; StartMode=""; StartName=""; PathName=""; });

    #Load Service Information
    $cstService.Name = $crntServce.Name;
    $cstService.DisplayName = $crntServce.DisplayName;
    $cstService.State = $crntServce.State;
    $cstService.StartMode = $crntServce.StartMode;
    $cstService.StartName = $crntServce.StartName;
    $cstService.PathName = $crntServce.PathName;
    
    #Add Custom Object to Reporting Array
    $raServices += $cstService;

}#End of Service Foreach

#Pull Scheduled Tasks
foreach($schdTask in (Get-ScheduledTask))
{
    #Create Custom Scheduled Task Object 
    $cstSchTask = new-object PSObject -Property (@{ TaskName=""; State=""; Author=""; PrincipalUserID=""; RunLevel=""; Executables="" });
    
    #Load Scheduled Task Information
    $cstSchTask.TaskName = $schdTask.TaskName;
    $cstSchTask.State = $schdTask.State;
    $cstSchTask.Author = $schdTask.Author;
    $cstSchTask.PrincipalUserID = $schdTask.Principal.UserID;
    $cstSchTask.RunLevel = $schdTask.Principal.RunLevel;

    #Check for Actions
    if($schdTask.Actions.Count -gt 0)
    {
        #Var for Scheduled Executables 
        [string]$schExecs = "";

        foreach($tskAction in $schdTask.Actions)
        {
            $schExecs += $tskAction.Execute + ";"
        }

        #Load Final Executable Value
        $cstSchTask.Executables = $schExecs.TrimEnd(";");

    }#End of Action Count Check
    
    
    #Add Custom Object to Reporting Array
    $raScheduledTasks += $cstSchTask;

}#End of Scheduled Tasks Foreach

#Var for Processes Report Name
[string]$rptNameProcesses = ".\DWS_Report_GenServer_Processes_on_" + $srvName + "_" + $rptDate + ".csv";

#Var for Services Report Name
[string]$rptNameServices = ".\DWS_Report_GenServer_Services_on_" + $srvName + "_" + $rptDate + ".csv";

#Var for Scheduled Tasks Report Name
[string]$rptNameTasks = ".\DWS_Report_GenServer_ScheduledTasks_on_" + $srvName + "_" + $rptDate + ".csv";

#Export Process Report to CSV
$raProcesses | Sort-Object -Property ProcessName | Select-Object -Property ProcessName,Id,UserName,Ports,FileName | Export-Csv -Path $rptNameProcesses -NoTypeInformation;

#Export Services Report to CSV
$raServices | Sort-Object -Property Name | Select-Object -Property Name,DisplayName,State,StartMode,StartName,PathName | Export-Csv -Path $rptNameServices -NoTypeInformation;

#Export Scheduled Tasks Report to CSV
$raScheduledTasks | Sort-Object -Property TaskName | Select-Object -Property TaskName,State,Author,PrincipalUserID,RunLevel,Executables | Export-Csv -Path $rptNameTasks -NoTypeInformation;

