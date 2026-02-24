' ==========================================================
' VBScript: Upload Files to SharePoint with Custom Naming
' Purpose: Automates uploading files from a local folder
'          to a SharePoint document library with custom names
'          and logs results in Excel
' ==========================================================

Option Explicit

Dim objXMLHTTP, objFSO, objExcel, objWorkbook, objSheet
Dim sharePointURL, localFolder, fileList, fileName, customName, i, counter

' --- CONFIGURATION ---
sharePointURL = "https://sample.sharepoint.com/sites/TestSite/Shared%20Documents/Uploads/"
localFolder   = "C:\Data\ABC123Uploads\"

' --- Create FileSystemObject ---
Set objFSO = CreateObject("Scripting.FileSystemObject")
If Not objFSO.FolderExists(localFolder) Then
    WScript.Echo "Local folder does not exist: " & localFolder
    WScript.Quit
End If

' --- Example file list (replace with actual files in folder) ---
fileList = Array("Report.xlsx", "Document.docx", "Data.csv")

' --- Initialize Excel ---
Set objExcel = CreateObject("Excel.Application")
objExcel.Visible = True
Set objWorkbook = objExcel.Workbooks.Add
Set objSheet = objWorkbook.Sheets(1)

' Write headers
objSheet.Cells(1,1).Value = "OriginalFile"
objSheet.Cells(1,2).Value = "CustomName"
objSheet.Cells(1,3).Value = "LocalPath"
objSheet.Cells(1,4).Value = "Uploaded"

' --- Automated ID counter ---
counter = 1

' --- Loop through files and upload ---
For i = LBound(fileList) To UBound(fileList)
    fileName = fileList(i)
    
    If objFSO.FileExists(localFolder & fileName) Then
        ' Build custom name with counter (e.g., Upload_001_Report.xlsx)
        customName = "Upload_" & Right("000" & counter, 3) & "_" & fileName
        
        ' Upload file
        Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
        objXMLHTTP.Open "PUT", sharePointURL & customName, False
        objXMLHTTP.Send GetBinaryFile(localFolder & fileName)
        
        If objXMLHTTP.Status = 200 Or objXMLHTTP.Status = 201 Then
            objSheet.Cells(i+2,1).Value = fileName
            objSheet.Cells(i+2,2).Value = customName
            objSheet.Cells(i+2,3).Value = localFolder & fileName
            objSheet.Cells(i+2,4).Value = "Yes"
        Else
            objSheet.Cells(i+2,1).Value = fileName
            objSheet.Cells(i+2,2).Value = customName
            objSheet.Cells(i+2,3).Value = localFolder & fileName
            objSheet.Cells(i+2,4).Value = "Failed (" & objXMLHTTP.Status & ")"
        End If
        
        Set objXMLHTTP = Nothing
        counter = counter + 1
    Else
        objSheet.Cells(i+2,1).Value = fileName
        objSheet.Cells(i+2,2).Value = "N/A"
        objSheet.Cells(i+2,3).Value = localFolder & fileName
        objSheet.Cells(i+2,4).Value = "File Not Found"
    End If
Next

' --- Save Excel workbook ---
objWorkbook.SaveAs "C:\Data\ABC123UploadLog_Custom.xlsx"

' Cleanup
objWorkbook.Close False
objExcel.Quit
Set objSheet = Nothing
Set objWorkbook = Nothing
Set objExcel = Nothing
Set objFSO = Nothing

' --- Helper Function: Read file as binary ---
Function GetBinaryFile(path)
    Dim stream
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 1 ' Binary
    stream.Open
    stream.LoadFromFile path
    GetBinaryFile = stream.Read
    stream.Close
    Set stream = Nothing
End Function
