<#
    Script: DWS_Print_Server_Reports.ps1
#>

#Var for Server Name
[string]$srvName = (hostname).ToString().ToUpper();

#Var for Report Date
[string]$rptDate = (Get-Date).ToString("yyyy-MM-dd");

#Reporting Array for Shared Printers
$raPrinters = @();


foreach($crntPrinter in (Get-Printer))
{
     
    #Create Custom Printer Object
    $cstPrinter = new-object PSObject -Property (@{ Name=""; ShareName=""; PortName=""; Location=""; DriverName=""; Comment=""; PrintProcessor=""; PrinterStatus=""; });

    #Load Printer Information
    $cstPrinter.Name = $crntPrinter.Name;
    $cstPrinter.ShareName = $crntPrinter.ShareName;
    $cstPrinter.PortName = $crntPrinter.PortName;
    $cstPrinter.Location = $crntPrinter.Location;
    $cstPrinter.DriverName = $crntPrinter.DriverName;
    $cstPrinter.Comment = $crntPrinter.Comment;
    $cstPrinter.PrintProcessor = $crntPrinter.PrintProcessor;
    $cstPrinter.PrinterStatus = $crntPrinter.PrinterStatus;
    
    #Add Custom Object to Reporting Array
    $raPrinters += $cstPrinter;

}#End of Get-Printer Foreach


#Var for Printers Report Name
[string]$rptNamePrinters = ".\DWS_Report_PrintServer_on_" + $srvName + "_" + $rptDate + ".csv";

#Export Printers Report to CSV
$raPrinters | Sort-Object -Property Name | Select-Object -Property Name,PrinterStatus,ShareName,PortName,Location,PrintProcessor,DriverName,Comment | Export-Csv -Path $rptNamePrinters -NoTypeInformation;


