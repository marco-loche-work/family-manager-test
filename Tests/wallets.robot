*** Settings ***
Library               RequestsLibrary
Library               Collections  
Suite Setup           Create Session    WALLETS    ${SERVER}

*** Variables ***
${SERVER}                   http://localhost:8082
${URL}                      /api/v1/wallets  
${WALLET_OPENING_BALANCE}   120
${WALLET_TYPE}              MANUAL
${WALLET_NAME}              Wallet di test

*** Test Cases ***
User can create a valid wallet
    Create Valid Wallet
    Wallet Should Be Exist

User cannot create a wallet with wrong type
    Create Wallet With Invalid Type Should Be 400

User can show a wallet
    Create Valid Wallet
    Wallet Should Have All Data

User can modify a wallet
    Create Valid Wallet
    Modify Created Wallet

User cannot modify a wallet with wrong type
    Create Valid Wallet
    Modify Wallet With Invalid Type Should Be 400

User can delete an existing wallet
    Create Valid Wallet
    Delete Wallet

User cannot delete a non existing wallet
    Delete Non Existing Wallet Should Be Not Found


*** Keywords ***
Create Valid Wallet
    &{data}=  Create dictionary  name=${WALLET_NAME}     type=${WALLET_TYPE}   openingBalance=${WALLET_OPENING_BALANCE}
    ${resp}=  POST On Session    WALLETS   ${URL}     json=${data}   expected_status=201
    Set Test Variable   ${response}  ${resp}
    Set Test Variable   ${id}  ${resp.json()['id']}

Create Wallet With Invalid Type Should Be 400
    &{data}=    Create dictionary  name=wallet 1    type=X   openingBalance=100
    ${resp}=    POST On Session    WALLETS   ${URL}     json=${data}     expected_status=400

Get Wallet 
    [Arguments]     ${wallet_id}
    ${resp}=    GET On Session      WALLETS      ${URL}/${id}    expected_status=200
    [return]  ${resp.json()}

Wallet Should Be Exist
    GET On Session      WALLETS      ${URL}/${id}    expected_status=200

Wallet Should Have All Data
    ${wallet}=    Get Wallet   ${id}
    Should Not Be Empty     ${wallet['id']}
    Should Not Be Empty     ${wallet['name']}
    Should Not Be Empty     ${wallet['type']}
    Should Be Equal As Numbers     ${wallet['openingBalance']}     ${WALLET_OPENING_BALANCE}

Modify Created Wallet
    ${wallet}=    Get Wallet   ${id}
    Set To dictionary   ${wallet}     name='modified name'
    PUT On Session  WALLETS  ${URL}/${id}    json=${wallet}    expected_status=204 
    ${wallet}=    Get Wallet   ${id}
    Should Be Equal As Strings      ${wallet['name']}  'modified name'

Modify Wallet With Invalid Type Should Be 400
    ${wallet}=    Get Wallet   ${id}
    Set To dictionary   ${wallet}     type='X'
    PUT On Session  WALLETS  ${URL}/${id}    json=${wallet}    expected_status=400 

Delete Wallet
    [Arguments]     ${wallet_id}=${id}
    DELETE On Session  WALLETS  ${URL}/${wallet_id}  expected_status=204

Delete Non Existing Wallet Should Be Not Found
    DELETE On Session  WALLETS  ${URL}/non_existing_wallet_id  expected_status=404
