' ==========================================================
' VBA: Automate Emails with Options (Draft or Delayed Send)
' Purpose: Reads recipient, subject, body, and attachment
'          from Excel range and automates Outlook emails
' ==========================================================

Sub SendEmailsWithOptions()
    Dim OutlookApp As Object
    Dim OutlookMail As Object
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim i As Long
    Dim userChoice As VbMsgBoxResult
    
    ' Ask user: Draft or Send with Delay
    userChoice = MsgBox("Do you want to create drafts (Yes) or send with 30-min delay (No)?", vbYesNoCancel + vbQuestion, "Email Options")
    
    If userChoice = vbCancel Then
        MsgBox "Operation cancelled.", vbInformation
        Exit Sub
    End If
    
    ' Initialize Outlook
    Set OutlookApp = CreateObject("Outlook.Application")
    Set ws = ThisWorkbook.Sheets("EmailData")  ' Sheet with email info
    
    ' Find last row of data
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    ' Loop through rows
    For i = 2 To lastRow   ' Assuming row 1 has headers
        ' Create new mail item
        Set OutlookMail = OutlookApp.CreateItem(0)
        
        With OutlookMail
            .To = ws.Cells(i, 1).Value          ' Column A: Recipient
            .Subject = ws.Cells(i, 2).Value     ' Column B: Subject
            .Body = ws.Cells(i, 3).Value        ' Column C: Body
            
            ' Column D: Attachment (optional)
            If ws.Cells(i, 4).Value <> "" Then
                If Dir(ws.Cells(i, 4).Value) <> "" Then
                    .Attachments.Add ws.Cells(i, 4).Value
                End If
            End If
            
            ' Handle user choice
            If userChoice = vbYes Then
                .Display   ' Show draft window
            ElseIf userChoice = vbNo Then
                ' Send with 30-min delay
                .DeferredDeliveryTime = Now + TimeSerial(0, 30, 0)
                .Send
            End If
        End With
    Next i
    
    ' Cleanup
    Set OutlookMail = Nothing
    Set OutlookApp = Nothing
    
    MsgBox "Email process completed.", vbInformation
End Sub
