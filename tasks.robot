*** Settings ***
Resource          keywords.robot 
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.


# +
*** Tasks ***

Open Up
    Open RobotSpareBin Site
    Ask User for CSV URL
    

Submit the Orders
    ${robots}=    Download Orders from CSV
    FOR  ${robot}  IN  @{robots}
      Close the Popup
      Complete the Form  ${robot}
      Check the Robot
      Submit and Make Sure it Works
      ${PDF}=    Grab the Receipt as a PDF    ${robot}[Order number]
      ${screenshot}=    Save a Screenshot    ${robot}[Order number]
      Embed the Screenshot    ${screenshot}    ${PDF}
      Go Again
    END
    Spin Up a ZIP
    
    
