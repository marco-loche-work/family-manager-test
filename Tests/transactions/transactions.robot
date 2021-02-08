*** Settings ***
Library           RequestsLibrary
Library           Collections  

Resource          transactions.resource  
Resource          ../wallets/wallets.resource  
Resource          ../categories/categories.resource  

Suite Setup       Suite Setup

*** Variables ***
${categoryId}=      ${None}
${walletId}=        ${None}
${transactionId}=   ${None}


*** Test Cases ***

User Can Read A Transaction
    [Setup]    Setup Inbound Transaction
    Get Transaction By Id
    [Teardown]  Run Keywords    Delete Transaction  AND  
    ...         Delete Wallet       ${walletId}  AND 
    ...         Delete Category     ${categoryId}

User Can Read A List Of Transaction
    [Setup]    Create Manual Wallet
    Create List Of Transactions
    Transactions Lenght Should Be Greater Than One
    [Teardown]  Run Keywords     Delete Transactions  AND   Delete Wallet   ${walletId}

User Can Create Outbound Manual Transaction
    [Setup]    Create Manual Wallet
    Create Outbound Category
    Create Outbound Transaction
    Created Transaction Should Be Correct   type=OUTBOUND
    [Teardown]  Run Keywords    Delete Transaction  AND
    ...                         Delete Wallet  ${walletId}  AND
    ...                         Delete Category     ${categoryId}  

User Can Create Inbound Manual Transaction
    [Setup]    Create Manual Wallet
    Create Inbound Category
    Create Inbound Transaction
    Created Transaction Should Be Correct   type=INBOUND
    [Teardown]  Run Keywords    Delete Transaction  AND
    ...                         Delete Wallet  ${walletId}  AND
    ...                         Delete Category  ${categoryId}


User Cannot Create Manual Transaction On Non Existing Wallet
    Create Transaction On Non Existing Wallet Should Return Invalid Response

User Cannot Create Manual Transaction With Non Existing Category
    [Setup]    Create Manual Wallet
    Create Transaction With Non Existing Category Should Return Invalid Response
    [Teardown]  Delete Wallet  ${walletId}

User Cannot Create Outbound Transaction With Inbound Category
    [Setup]    Create Manual Wallet
    ${categoryId}=    Create Inbound Category
    Create Outbound Transaction With Inbound Category Should Return Invalid Response    categoryId=${categoryId}
    [Teardown]  Run Keywords    Delete Wallet  ${walletId}  AND     Delete Category  ${categoryId}

User Cannot Create Inbound Transaction With Outbound Category
    [Setup]    Create Manual Wallet
    ${categoryId}=    Create Outbound Category
    Create Inbound Transaction With Outbound Category Should Return Invalid Response    categoryId=${categoryId}
    [Teardown]  Run Keywords    Delete Wallet  ${walletId}  AND     Delete Category  ${categoryId}

User Cannot Create Manual Transaction On Bank Account
    [Setup]     Create Account Wallet
    Create Manual Transaction On Account Wallet Should Return Invalid Response
    [Teardown]  Delete Wallet  ${walletId}

User Cannot Read Non Existing Transaction
    Get Transaction By Id Should Return 404

User Can Delete Manual Transaction
    [Setup]    Setup Inbound Transaction
    Delete Transaction  transactionId=${transactionId}
    [Teardown]  Run Keywords  Delete Wallet     ${walletId}     AND     Delete Category     ${categoryId}
    
User Cannot Delete Non Existing Manual Transaction
    [Setup]    Create Manual Wallet
    Delete Transaction Should Return 404
    [Teardown]  Delete Wallet     ${walletId}

User Can Modify Manual Transaction
    [Setup]    Setup Inbound Transaction
    Update Transaction      transactionId=${transactionId}
    [Teardown]      Delete All Entities

User Cannot Modify Non Existing Manual Transaction
    [Setup]    Run Keywords     Create Manual Wallet
    Update Transaction Should Return 404 
    [Teardown]  Delete Wallet     ${walletId}

User Cannot Modify Manual Transaction With Non Existing Category
    [Setup]    Setup Inbound Transaction
    Update Transaction Should Return 400 If Category Type Changes   transactionId=${transactionId}     categoryId=X
    [Teardown]  Run Keywords  Delete Transaction    ${transactionId}     AND
    ...                       Delete Wallet     ${walletId}    AND     
    ...                       Delete Category     ${categoryId}

User Cannot Modify Manual Transaction If Category Type Changes
    [Setup]    Setup Inbound Transaction
    ${inboundCategoryId}=   Set Variable    ${categoryId}
    ${outboundCategoryId}=  Create Outbound Category
    Update Transaction Should Return 400 If Category Type Changes   transactionId=${transactionId}     categoryId=${outboundCategoryId}
    [Teardown]  Run Keywords  Delete Wallet     ${walletId}    AND     
    ...                       Delete Category     ${outboundCategoryId}  AND
    ...                       Delete Category     ${inboundCategoryId}

User Can Delete Wallet With Relative Transactions
    [Setup]     Setup Multiple Transactions
    Transactions Count Should Be N      count=3
    Delete Wallet   ${walletId}
    Transactions Count Should Be N      count=0
    [Teardown]  Run Keywords  Delete Category     ${outboundCategoryId}  AND
    ...                       Delete Category     ${inboundCategoryId}

User Can Delete Category Used For Transactions
    [Setup]     Setup Inbound Transaction
    Delete Category     ${categoryId}
    Transaction Category Should Be  ${None}
    [Teardown]  Delete Wallet  ${walletId}

Search Transactions With Date Filter Should Return Expected Result
    [Setup]     Setup Multiple Transactions
    Transactions Count Should Be N  startDate=2020-01-01  endDate=2020-02-01   count=2
    [Teardown]  Run Keywords    Delete Wallet  ${walletId}  AND  
    ...                         Delete Category  ${inboundCategoryId}  AND  
    ...                         Delete Category  ${outboundCategoryId}

Search Transactions With Type Filter Should Return Expected Result
    [Setup]     Setup Multiple Transactions
    Transactions Count Should Be N  type=OUTBOUND   count=2
    [Teardown]  Run Keywords    Delete Wallet  ${walletId}  AND  
    ...                         Delete Category  ${inboundCategoryId}  AND  
    ...                         Delete Category  ${outboundCategoryId}

Search Transactions With Category Filter Should Return Expected Result
    [Setup]     Setup Multiple Transactions
    Transactions Count Should Be N  categoryId=${inboundCategoryId}   count=1
    [Teardown]  Run Keywords    Delete Wallet  ${walletId}  AND  
    ...                         Delete Category  ${inboundCategoryId}  AND  
    ...                         Delete Category  ${outboundCategoryId}

***Keywords***

Setup Multiple Transactions
    Create Manual Wallet    balance=100
    ${inboundCategoryId}=   Create Inbound Category
    Set Test Variable   ${inboundCategoryId}
    ${outboundCategoryId}=   Create Outbound Category
    Set Test Variable   ${outboundCategoryId}
    ${ids}=    Create List
    ${id1}=    Create Outbound Transaction     amount=10    date=2020-01-01     categoryId=${outboundCategoryId}
    Append To List  ${ids}  ${id1}
    ${id2}=    Create Outbound Transaction     amount=20    date=2020-02-01     categoryId=${outboundCategoryId}
    Append To List  ${ids}  ${id2}
    ${id3}=    Create Inbound Transaction      amount=100   date=2020-03-01     categoryId=${inboundCategoryId}
    Append To List  ${ids}  ${id3}
    Set Test Variable   ${ids}
    [Return]    ${ids}

Setup Inbound Transaction
    Create Manual Wallet
    ${categoryId}=   Create Inbound Category
    Set Test Variable   ${categoryId}
    ${transactionId}=   Create Inbound Transaction    categoryId=${categoryId}
    Set Test Variable   ${transactionId}

Setup Outbound Transaction
    Create Manual Wallet
    ${categoryId}=   Create Outbound Category
    Set Test Variable   ${categoryId}
    ${transactionId}=   Create Outbound Transaction    categoryId=${categoryId}
    Set Test Variable   ${transactionId}

Delete All Entities
    Delete Transaction  ${transactionId}
    Delete Wallet  ${walletId}
    Delete Category  ${categoryId}

Suite Setup
    Create Session    TRANSACTIONS    ${TRANSCTIONS_URL}
    Create Session    WALLETS         ${WALLET_URL}
    Create Session    CATEGORIES      ${CATEGORIES_URL}
