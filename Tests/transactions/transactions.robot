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


*** Test Cases ***

User Can Read A Transaction
    [Setup]    Setup Inbound Transaction
    Get Transaction By Id
    [Teardown]  Run Keywords    Delete Transaction  ${transactionId}  AND  
    ...         Delete Wallet       ${walletId}  AND 
    ...         Delete Category     ${categoryId}

User Can Read A List Of Transaction
    [Setup]    Create Manual Wallet
    Create List Of Transactions
    Transactions Lenght Should Be Greater Than One
    [Teardown]  Run Keywords     Delete Transactions  AND   Delete Wallet   ${walletId}

User Can Create Outbound Manual Transaction
    [Setup]    Create Manual Wallet
    ${category}=    Create Outbound Category
    Create Outbound Transaction     categoryId=${category}
    Created Transaction Should Be Correct   type=OUTBOUND
    [Teardown]  Run Keywords    Delete Transaction  AND
    ...                         Delete Wallet  ${walletId}  AND
    ...                         Delete Category  category_id=${category}

User Can Create Inbound Manual Transaction
    [Setup]    Create Manual Wallet
    ${category}=    Create Inbound Category
    Create Inbound Transaction      categoryId=${category}
    Created Transaction Should Be Correct   type=INBOUND
    [Teardown]  Run Keywords    Delete Transaction  AND
    ...                         Delete Wallet  ${walletId}  AND
    ...                         Delete Category  category_id=${category}


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
    ${outboundCategoryId}=  Create Outbound Category
    Update Transaction Should Return 400 If Category Type Changes   transactionId=${transactionId}     categoryId=${outboundCategoryId}
    [Teardown]  Run Keywords  Delete Transaction    ${transactionId}     AND
    ...                       Delete Wallet     ${walletId}    AND     
    ...                       Delete Category     ${outboundCategoryId}  AND
    ...                       Delete Category     ${categoryId}

***Keywords***

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
    Delete Transaction
    Delete Wallet  ${walletId}
    Delete Category  ${categoryId}

Suite Setup
    Create Session    TRANSACTIONS    ${TRANSCTIONS_URL}
    Create Session    WALLETS         ${WALLET_URL}
    Create Session    CATEGORIES      ${CATEGORIES_URL}
