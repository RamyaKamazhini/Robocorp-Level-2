*** Settings ***
Documentation       Download the order file from website.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.Archive
Library             RPA.PDF
Library             RPA.Email.ImapSmtp
Library             RPA.FileSystem


*** Variables ***
${status}       0


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Download Order excel file
    Open web application
    Read excel file and create order for each row


*** Keywords ***
Download Order excel file
    Download    https://robotsparebinindustries.com/orders.csv    C:\\Users\\mahalir1\\Desktop\\Visual Studio Code

Open web application
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Sleep    5s
    Click Button    OK

Read excel file and create order for each row
    ${order_table}    Read table from CSV    orders.csv    header=True
    FOR    ${order_row}    IN    @{order_table}
        WHILE    True
            ${status}    Set Variable    True
            TRY
                Select From List By Index    head    ${order_row}[Head]
                Select Radio Button    body    ${order_row}[Body]
                Input Text    xpath=//input[@placeholder="Enter the part number for the legs"]    ${order_row}[Legs]
                Input Text    address    ${order_row}[Address]
                Click Button    Order
                Wait Until Element Is Visible    order-another    5s
                ${status}    Set Variable    False
                Log    ${status}
            EXCEPT
                Close Browser
                Open web application
            END

            IF    "${status}" == "False"                BREAK
        END

        ${receipt_html}    Get Element Attribute    id:receipt    outerHTML
        Html To Pdf    ${receipt_html}    ReceiptPdf${/}${order_row}[Order number].pdf    overwrite=True
        Screenshot    id:receipt    Screenshot${/}${order_row}[Order number].png
        ${imgfile}    Create List    Screenshot${/}${order_row}[Order number].png
        Add Files To Pdf
        ...    ${imgfile}
        ...    ReceiptPdf${/}${order_row}[Order number].pdf    append=True
        Click Button    order-another
        Click Button    OK
        Wait Until Page Contains Element    head    10s
    END

    Archive Folder With Zip    C:\\Users\\mahalir1\\Desktop\\Visual Studio Code\\ReceiptPdf    Receipts.zip
    Close All Browsers
