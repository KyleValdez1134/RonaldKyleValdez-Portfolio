' ==========================================================
' VBScript: Folder Report to Excel
' Author: Ronald Kyle J. Valdez
' Purpose: Creates a report of files in a folder with metadata
' ==========================================================

Option Explicit

Dim objFSO, objFolder, objFile, objExcel, objWorkbook, objSheet
Dim folderPath, row

' --- CONFIGURATION ---
folderPath = "C:\Data\ABC123Reports\"   ' Replace with target folder path

' --- Create FileSystemObject ---
Set objFSO = CreateObject("Scripting.FileSystemObject")

If Not objFSO.FolderExists(folderPath) Then
    WScript.Echo "Folder does not exist: " & folderPath
    WScript.Quit
End If

Set objFolder = objFSO.GetFolder(folderPath)

' --- Initialize Excel ---
Set objExcel = CreateObject("Excel.Application")
objExcel.Visible = True
Set objWorkbook = objExcel.Workbooks.Add
Set objSheet = objWorkbook.Sheets(1)

' Write headers
objSheet.Cells(1,1).Value = "FileName"
objSheet.Cells(1,2).Value = "Path"
objSheet.Cells(1,3).Value = "CreatedDate"
objSheet.Cells(1,4).Value = "LastModifiedDate"
objSheet.Cells(1,5).Value = "LastAccessedDate"
objSheet.Cells(1,6).Value = "LastModifiedBy"

row = 2

' --- Loop through files in folder ---
For Each objFile In objFolder.Files
    objSheet.Cells(row,1).Value = objFile.Name
    objSheet.Cells(row,2).Value = objFile.Path
    objSheet.Cells(row,3).Value = objFile.DateCreated
    objSheet.Cells(row,4).Value = objFile.DateLastModified
    objSheet.Cells(row,5).Value = objFile.DateLastAccessed
    
    ' Last modified by (using Shell object for extended property)
    objSheet.Cells(row,6).Value = GetFileOwner(objFile.Path)
    
    row = row + 1
Next

' --- Save Excel workbook ---
objWorkbook.SaveAs "C:\Data\ABC123FolderReport.xlsx"

' Cleanup
objWorkbook.Close False
objExcel.Quit
Set objSheet = Nothing
Set objWorkbook = Nothing
Set objExcel = Nothing
Set objFolder = Nothing
Set objFSO = Nothing

' --- Helper Function: Get File Owner ---
Function GetFileOwner(filePath)
    Dim objShell, objFolderItem
    Set objShell = CreateObject("Shell.Application")
    Set objFolderItem = objShell.Namespace(objFSO.GetParentFolderName(filePath)).ParseName(objFSO.GetFileName(filePath))
    GetFileOwner = objFolderItem.ExtendedProperty("Owner")
    Set objFolderItem = Nothing
    Set objShell = Nothing
End Function
