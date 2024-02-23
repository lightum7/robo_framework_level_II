*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.Desktop
Library    RPA.Tables
Library    RPA.HTTP
Library    RPA.PDF
Library    RPA.Archive
Library    RPA.FileSystem


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download the orders file
    Get orders
    Create ZIP package from PDF files
    Delete All Pdfs and Images
    Log out and close the browser

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com    
    Input Text    username    maria
    Input Password    password    thoushallnotpass
    Submit Form
    Wait Until Page Contains Element    id:sales-form
    Go To   https://robotsparebinindustries.com/#/robot-order

Download the orders file
        Download    https://robotsparebinindustries.com/orders.csv   overwrite=True

Close the annoying modal
    #click element and close modal via class btn btn-dark
    Wait Until Element Is Visible     css:.modal-dialog
    Click Element    css:.modal-dialog .btn-dark

Order a robot
    [Arguments]  ${order}
    Select From List By Index   id:head    ${order}[Head]
    Click Element    id:id-body-${order}[Body]
    Input Text    css:.form-control[type='number']  ${order}[Legs]
    Input Text    id:address    ${order}[Address]
    Scroll Element Into View    id:preview
    Click Element    id:preview
    Wait Until Element Is Visible    id:order
    Scroll Element Into View    id:order
    Click Element    id:order
    Wait Until Page Contains Element    id:receipt
    Save the order receipt as a PDF
    Wait Until Element Is Visible     id:order-another
    Scroll Element Into View    id:order-another
    Click Element    id:order-another

Get orders 
    ${orders}=    Read Table From Csv   orders.csv
    FOR    ${order}    IN    @{orders}
        Close the annoying modal
        Wait Until Keyword Succeeds   5x    1s     Order a robot   ${order}
    END

Save the order receipt as a PDF
    ${receipt}=    Get Text    css:.badge
    Wait Until Element Is Visible    css:.col-sm-7
    ${receipt_results_html}=    Get Element Attribute    css:.col-sm-7   outerHTML
    ${path}=    Set Variable    ${OUTPUT_DIR}${/}
    Html To Pdf    ${receipt_results_html}    ${path}${receipt}.pdf
    Screenshot    id:robot-preview-image    ${path}${receipt}.png
    Add Image To Pdf    ${path}${receipt}.png    ${path}${receipt}.pdf


Add Image To Pdf
    [Arguments]    ${image}    ${pdf}
     ${files}=    Create List
     ...    ${pdf}
     ...    ${image}:x=0,y=0
    Add Files To Pdf    ${files}   ${pdf}
    Close All Pdfs

Create ZIP package from PDF files
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip   
    ...    ${OUTPUT_DIR}    
    ...    ${zip_file_name}    
    ...    false
    ...    *.pdf

Delete All Pdfs and Images
    @{files}    List Files In Directory    ${OUTPUT_DIR}
    FOR    ${file}    IN    @{files}
        ${extension}    Get File Extension    ${file}
        Run Keyword If   '${extension}' == '.pdf'    Remove File    ${file}    
        Run Keyword If   '${extension}' == '.png'    Remove File    ${file} 
    END

Log out and close the browser
    Go To   https://robotsparebinindustries.com/
    Click Button    Log out
    Close Browser