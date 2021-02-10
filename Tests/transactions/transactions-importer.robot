*** Settings ***
Library     RequestsLibrary
Library     OperatingSystem
Library     ../libraries/UploadFile.py

Resource          transactions.resource  
Resource          ../wallets/wallets.resource  
Resource          ../categories/categories.resource  

Suite Setup       Suite Setup

***Test Cases***
User Can Upload Csv Transactions File
    [Setup]     Create Manual Wallet  
    Upload Csv Transactions
    Transactions Count Should Be N  ${walletId}  count=2
    [Teardown]  Delete Wallet  ${walletId}


User Can Upload Excel Transactions File
    [Setup]     Create Manual Wallet  
    Upload Excel Transactions
    Transactions Count Should Be N  ${walletId}  count=2
    [Teardown]  Delete Wallet  ${walletId}

User Can Upload Excel Transactions Twice But Not Repeated If Modified By User
    [Setup]     Create Manual Wallet  
    Upload Excel Transactions    
    ${id}=  Update First Transaction  pippo
    Upload Excel Transactions
    Transactions Count Should Be N  ${walletId}  count=2
    Transaction Description Sould Be    ${id}    pippo
    [Teardown]  Delete Wallet  ${walletId}

User Cannot Upload Excel Transactions On Account Wallet
    [Setup]     Create Account Wallet  
    Upload Excel Transactions  403
    [Teardown]  Delete Wallet  ${walletId}

User Cannot Upload Csv Transactions On Account Wallet
    [Setup]     Create Account Wallet  
    Upload Csv Transactions  403
    [Teardown]  Delete Wallet  ${walletId}

***Keywords***

Upload Excel Transactions
    [Arguments]     ${status}=200
    Upload Excel   ${TRANSCTIONS_URL}/upload/${walletId}  file_path=${CURDIR}/files/transactions.xlsx  expected_status=${status}

Upload Csv Transactions
    [Arguments]     ${status}=200
    Upload Csv   ${TRANSCTIONS_URL}/upload/${walletId}  file_path=${CURDIR}/files/file.csv  expected_status=${status}

Transaction Description Sould Be
    [Arguments]     ${id}   ${description}
    ${transaction}=  Get Transaction By Id  ${id}
    Should Be Equal As Strings  ${transaction['description']}   ${description}

Update First Transaction
    [Arguments]     ${description}
    ${transactions}=     Get Wallet Transactions   ${walletId}
    ${transaction}=  Set Variable  ${transactions}[0]
    ${id}=  Set Variable    ${transaction}[id]  
    Update Transaction   ${id}  pippo
    [Return]    ${id}

Suite Setup
    Create Session    TRANSACTIONS    ${TRANSCTIONS_URL}
    Create Session    WALLETS         ${WALLET_URL}
