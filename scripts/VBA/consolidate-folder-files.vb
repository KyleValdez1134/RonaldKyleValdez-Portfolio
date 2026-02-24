' ==========================================================
' VBA Automation Tool - Consolidate Files in Folder
' Author: Ronald Kyle J. Valdez
' Purpose: Merge all Excel files in a folder into one sheet
' ==========================================================

Sub ConsolidateFolderFiles()
    Dim wb As Workbook
    Dim ws As Worksheet
    Dim masterWs As Worksheet
    Dim folderPath As String
    Dim fileName As String
    Dim pasteRow As Long
    Dim userChoice As VbMsgBoxResult
    Dim sheetName As String
    
    ' Set folder path (update this to your folder location)
    folderPath = "C:\Users\YourName\Documents\ExcelFiles\"
    
    ' Create or reference MasterData sheet
    On Error Resume Next
    Set masterWs = ThisWorkbook.Sheets("MasterData")
    If masterWs Is Nothing Then
        Set masterWs = ThisWorkbook.Sheets.Add
        masterWs.Name = "MasterData"
    End If
    On Error GoTo 0
    
    ' Ask user whether to overwrite or append
    userChoice = MsgBox("Do you want to overwrite existing data in MasterData?" & vbCrLf & _
                        "Click YES to overwrite, NO to append.", vbYesNoCancel + vbQuestion, "Consolidation Option")
    
    If userChoice = vbCancel Then
        MsgBox "Operation cancelled.", vbExclamation
        Exit Sub
    ElseIf userChoice = vbYes Then
        masterWs.Cells.Clear
        pasteRow = 1
    ElseIf userChoice = vbNo Then
        pasteRow = masterWs.Cells(masterWs.Rows.Count, "A").End(xlUp).Row + 1
    End If
    
    ' Ask user for sheet name (blank = first sheet)
    sheetName = InputBox("Enter the sheet name to consolidate." & vbCrLf & _
                         "Leave blank to use the first sheet of each file.", "Sheet Selection")
    
    ' Loop through all Excel files in folder
    fileName = Dir(folderPath & "*.xlsx")
    Do While fileName <> ""
        Set wb = Workbooks.Open(folderPath & fileName)
        
        ' Select sheet based on user input
        If sheetName = "" Then
            Set ws = wb.Sheets(1)
        Else
            On Error Resume Next
            Set ws = wb.Sheets(sheetName)
            On Error GoTo 0
            If ws Is Nothing Then
                MsgBox "Sheet '" & sheetName & "' not found in " & fileName & ". Skipping file.", vbExclamation
                wb.Close SaveChanges:=False
                fileName = Dir
                GoTo NextFile
            End If
        End If
        
        ' Copy the entire used range
        ws.UsedRange.Copy
        masterWs.Cells(pasteRow, 1).PasteSpecial Paste:=xlPasteValues
        
        ' Update pasteRow for next file
        pasteRow = masterWs.Cells(masterWs.Rows.Count, "A").End(xlUp).Row + 1
        
        wb.Close SaveChanges:=False
NextFile:
        fileName = Dir
    Loop
    
    Application.CutCopyMode = False
    MsgBox "Consolidation complete! Files merged into MasterData.", vbInformation
End Sub
