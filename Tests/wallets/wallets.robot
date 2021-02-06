*** Settings ***
Library               RequestsLibrary
Library               Collections  

Resource              wallets.resource  

Suite Setup           Create Session    WALLETS    ${WALLET_URL}


*** Test Cases ***
User can create a valid wallet
    Create Valid Wallet
    Wallet Should Be Exist
    [Teardown]  Delete Wallet

User cannot create a wallet with wrong type
    Create Wallet With Invalid Type Should Be 400

User can show a wallet
    [Setup]     Create Valid Wallet
    Wallet Should Have All Data
    [Teardown]  Delete Wallet  

User cannot show a non existing wallet
    Get Wallet Should Be 404

User can show a list of wallets
    [Setup]    Create List Of Wallets
    Wallets Lenght Should Be Greater Than One
    [Teardown]  Delete Wallets  

User can modify a wallet
    [Setup]     Create Valid Wallet
    Modify Created Wallet
    [Teardown]  Delete Wallet

User cannot modify a wallet with wrong type
    [Setup]     Create Valid Wallet
    Modify Wallet With Invalid Type Should Be 400
    [Teardown]  Delete Wallet

User cannot modify a non existing wallet
    Modify Non Existing Wallet Should Be 404

User cannot modify a wallet with wrong id
    Modify Wallet With Invalid Id Should Be 400

User can delete an existing wallet
    [Setup]     Create Valid Wallet
    Delete Wallet

User cannot delete a non existing wallet
    Delete Non Existing Wallet Should Be Not Found


