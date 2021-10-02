*** Settings ***
Documentation     Keywords needed to run the robotsparebin tasks
...
Library           RPA.Browser.Playwright  auto_closing_level=SUITE  #timeout=30000
Library           RPA.Excel.Files
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Dialogs
Library           RPA.Robocloud.Secrets
Library           RPA.Desktop.Windows

*** Variables ***
${retries}=    10x
${retry_interval}=    1s

# +
*** Keywords ***

Open RobotSpareBin Site
    ${URL} =  Get Secret    websites
    Log        ${URL}
    Open Browser    ${URL}[RobotSpareBin]
    
    
Close the Popup
    Click    "I guess so..."
    

Ask User for CSV URL
    Add heading    Where's the CSV?
    Add text input    CSV  label=URL  placeholder=Enter the URL here  rows=1
    ${result}=  Run dialog
    Set Global Variable    ${result}
    

Download Orders from CSV
    RPA.HTTP.Download        ${result.CSV}
    ${table}=       Read table from CSV  orders.csv  dialect=excel  header=True
    FOR     ${row}  IN  @{table}
        Log     ${row}
    END
    [Return]    ${table}
    
    
Complete the Form
    ${legs_field}=    RPA.Browser.Playwright.Get Element    xpath=//html/body/div/div/div[1]/div/div[1]/form/div[3]/input
    [Arguments]    ${robot}
    Select Options By    id=head    value    ${robot}[Head]  
        Run Keyword If    '${robot}[Body]' == '1'    Click    id=id-body-1
        Run Keyword If    '${robot}[Body]' == '2'    Click    id=id-body-2
        Run Keyword If    '${robot}[Body]' == '3'    Click    id=id-body-3
        Run Keyword If    '${robot}[Body]' == '4'    Click    id=id-body-5
        Run Keyword If    '${robot}[Body]' == '6'    Click    id=id-body-6
    Fill Text    ${legs_field}    ${robot}[Legs] 
    Fill Text    id=address    ${robot}[Address]
        

Check the Robot
    Click    id=preview
    Wait For Elements State    id=robot-preview  state=visible
    
    
Submit Robot Order
    Click    xpath=//html/body/div/div/div[1]/div/div[1]/form/button[2]
    Wait For Elements State    id=receipt  state=visible
    Wait For Elements State    id=order-completion  state=visible
    
    
Submit and Make Sure it Works
    Wait Until Keyword Succeeds    ${retries}    ${retry_interval}    Submit Robot Order
    

Grab the Receipt as a PDF
    [Arguments]    ${order_number}
    ${receipt_text}=    RPA.Browser.Playwright.Get Text    xpath=//html/body/div/div/div[1]/div/div[1]/div/div    
    ${order_number}=    RPA.Browser.Playwright.Get Text    xpath=//div[@id="receipt"]/p[1]
    Html To Pdf        ${receipt_text}    ${CURDIR}${/}output${/}receipts${/}${order_number}.pdf
    [Return]    ${CURDIR}${/}output${/}receipts${/}${order_number}.pdf
# -


