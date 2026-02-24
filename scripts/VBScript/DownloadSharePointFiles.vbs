' ==========================================================
' VBScript: Download Files from SharePoint and Log to Excel
' Purpose: Automates downloading all files from a SharePoint folder
'          and writes metadata into an Excel workbook
' ==========================================================

Option Explicit

Dim objXMLHTTP, objADOStream, objFSO, objExcel, objWorkbook, objSheet
Dim sharePointURL, localFolder, fileList, fileName, i

' --- CONFIGURATION ---
sharePointURL = "https://sample.sharepoint.com/sites/TestSite/Shared%20Documents/Reports/"
localFolder   = "C:\Data\ABC123Downloads\"

' --- Create FileSystemObject ---
Set objFSO = CreateObject("Scripting.FileSystemObject")
If Not objFSO.FolderExists(localFolder) Then
    objFSO.CreateFolder(localFolder)
End If

' --- Example file list (replace with actual SharePoint files or manifest) ---
fileList = Array("Report1.xlsx", "Report2.xlsx", "Report3.csv")

' --- Initialize Excel ---
Set objExcel = CreateObject("Excel.Application")
objExcel.Visible = True
Set objWorkbook = objExcel.Workbooks.Add
Set objSheet = objWorkbook.Sheets(1)

' Write headers
objSheet.Cells(1,1).Value = "FileName"
objSheet.Cells(1,2).Value = "LocalPath"
objSheet.Cells(1,3).Value = "Downloaded"

' --- Loop through files and download ---
For i = LBound(fileList) To UBound(fileList)
    fileName = fileList(i)
    
    ' Download file
    Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
    objXMLHTTP.Open "GET", sharePointURL & fileName, False
    objXMLHTTP.Send
    
    If objXMLHTTP.Status = 200 Then
        Set objADOStream = CreateObject("ADODB.Stream")
        objADOStream.Type = 1 ' Binary
        objADOStream.Open
        objADOStream.Write objXMLHTTP.ResponseBody
        objADOStream.SaveToFile localFolder & fileName, 2 ' Overwrite
        objADOStream.Close
        
        ' Log success in Excel
        objSheet.Cells(i+2,1).Value = fileName
        objSheet.Cells(i+2,2).Value = localFolder & fileName
        objSheet.Cells(i+2,3).Value = "Yes"
    Else
        ' Log failure
        objSheet.Cells(i+2,1).Value = fileName
        objSheet.Cells(i+2,2).Value = localFolder & fileName
        objSheet.Cells(i+2,3).Value = "Failed"
    End If
    
    ' Cleanup
    Set objADOStream = Nothing
    Set objXMLHTTP = Nothing
Next

' --- Save Excel workbook ---
objWorkbook.SaveAs "C:\Data\ABC123DownloadLog.xlsx"

' Cleanup
objWorkbook.Close False
objExcel.Quit
Set objSheet = Nothing
Set objWorkbook = Nothing
Set objExcel = Nothing
Set objFSO = Nothing
