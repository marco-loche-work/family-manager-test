*** Settings ***
Library               RequestsLibrary
Library               Collections  

Resource              wallets.resource  
Resource              ../common.resource 

Suite Setup           Suite Setup

***Variables***
${id}=  ${None}


*** Test Cases ***
User can create a valid wallet
    Create Valid Wallet
    Wallet Should Be Exist  ${id}
    [Teardown]  Delete Wallet  ${id}

User cannot create a wallet with wrong type
    Create Wallet With Invalid Type Should Be 400

User can show a wallet
    [Setup]     Create Valid Wallet
    Wallet Should Have All Data     ${id}
    [Teardown]  Delete Wallet  ${id}

User cannot show a non existing wallet
    Get Wallet Should Be 404

User can show a list of wallets
    [Setup]    Create List Of Wallets
    Wallets Lenght Should Be Greater Than One
    [Teardown]  Delete Wallets  

User can modify a wallet
    [Setup]     Create Valid Wallet
    Modify Created Wallet   ${id}
    [Teardown]  Delete Wallet  ${id}

User cannot modify a wallet with wrong type
    [Setup]     Create Valid Wallet
    Modify Wallet With Invalid Type Should Be 400   ${id}
    [Teardown]  Delete Wallet  ${id}

User cannot modify a non existing wallet
    Modify Non Existing Wallet Should Be 404

User cannot modify a wallet with wrong id
    Modify Wallet With Invalid Id Should Be 400

User can delete an existing wallet
    [Setup]     Create Valid Wallet
    Delete Wallet  ${id}

User cannot delete a non existing wallet
    Delete Non Existing Wallet Should Be Not Found
