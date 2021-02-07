*** Variables ***
${WALLET_URL}               http://localhost:8082/api/v1/wallets  
${WALLET_OPENING_BALANCE}   120
${WALLET_TYPE}              MANUAL
${WALLET_NAME}              Wallet di test

*** Keywords ***
Create Valid Wallet     
    [Arguments]     ${type}=${WALLET_TYPE}
    &{data}=  Create dictionary  name=${WALLET_NAME}     type=${type}   openingBalance=${WALLET_OPENING_BALANCE}
    ${resp}=  POST On Session    WALLETS   /     json=${data}   expected_status=201
    Set Test Variable   ${walletId}  ${resp.json()['id']}
    [Return]    ${walletId}

Create List Of Wallets
    ${id1}=     Create Valid Wallet
    ${id2}=     Create Valid Wallet
    @{x}=       Create List  ${id1}  ${id2}
    Set Test Variable   @{ids}  @{x}

Create Wallet With Invalid Type Should Be 400
    &{data}=    Create dictionary  name=wallet 1    type=X   openingBalance=100
    ${resp}=    POST On Session    WALLETS   /     json=${data}     expected_status=400

Get Wallet 
    [Arguments]     ${id}=${walletId}
    ${resp}=    GET On Session      WALLETS      /${id}    expected_status=200
    [return]  ${resp.json()}

Wallet Should Be Exist
    [Arguments]     ${id}=${walletId}
    GET On Session      WALLETS      /${id}    expected_status=200

Wallet Should Have All Data
    [Arguments]     ${id}=${walletId}
    ${wallet}=    Get Wallet   ${id}
    Should Not Be Empty     ${wallet['id']}
    Should Not Be Empty     ${wallet['name']}
    Should Not Be Empty     ${wallet['type']}
    Should Be Equal As Numbers     ${wallet['openingBalance']}     ${WALLET_OPENING_BALANCE}

Wallets Lenght Should Be Greater Than One
    ${resp}=    GET On Session      WALLETS      /    expected_status=200
    ${count}=   Get length    ${resp.json()}
    Should Be True      ${count}>1

Get Wallet Should Be 404
    GET On Session      WALLETS      /X    expected_status=404

Modify Created Wallet
    [Arguments]     ${id}=${walletId}
    ${wallet}=    Get Wallet   ${id}
    Set To dictionary   ${wallet}     name='modified name'
    PUT On Session  WALLETS  /${id}    json=${wallet}    expected_status=204 
    ${wallet}=    Get Wallet   ${id}
    Should Be Equal As Strings      ${wallet['name']}  'modified name'

Modify Non Existing Wallet Should Be 404
    &{data}=    Create dictionary  id=X  name=wallet 1    type=${WALLET_TYPE}   openingBalance=100
    PUT On Session  WALLETS  /X    json=&{data}    expected_status=404 

Modify Wallet With Invalid Id Should Be 400
    &{data}=    Create dictionary  id=Y  name=wallet 1    type=${WALLET_TYPE}   openingBalance=100
    PUT On Session  WALLETS  /X    json=&{data}   expected_status=400 

Modify Wallet With Invalid Type Should Be 400
    [Arguments]     ${id}=${walletId}
    ${wallet}=    Get Wallet   ${id}
    Set To dictionary   ${wallet}     type='X'
    PUT On Session  WALLETS  /${id}    json=${wallet}    expected_status=400 

Delete Wallet
    [Arguments]     ${id}=${walletId}
    DELETE On Session  WALLETS  /${id}  expected_status=204

Delete Wallets
    [Arguments]     
    DELETE On Session  WALLETS  /${ids[0]}  expected_status=204
    DELETE On Session  WALLETS  /${ids[1]}  expected_status=204

Delete Non Existing Wallet Should Be Not Found
    DELETE On Session  WALLETS  /non_existing_wallet_id  expected_status=404
