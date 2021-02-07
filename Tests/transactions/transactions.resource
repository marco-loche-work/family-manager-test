*** Variables ***
${TRANSCTIONS_URL}  http://localhost:8082/api/v1/transactions

${TRANSACTION_DATE}         2020-08-18T21:00:00Z
${TRANSACTION_AMOUNT}       200
${TRANSACTION_DESCRIPTION}  fake transaction description
${TRANSACTION_TYPE}         OUTBOUND


*** Keywords ***

Build Manual Transaction 
    [Arguments]       ${id}=${None}  ${walletId}=${None}  ${type}=OUTBOUND   ${categoryId}=${categoryId}
    &{transaction}=   Create dictionary   id=${id}  walletId=${walletId}  transactionDate=${TRANSACTION_DATE}  
    ...               amount=${TRANSACTION_AMOUNT}  description=${TRANSACTION_DESCRIPTION}  type=${type}
    ...               categoryId=${categoryId}  
    [Return]    &{transaction}

Create Manual Wallet
    Create Wallet Of type  MANUAL

Create Account Wallet
    Create Wallet Of type  ACCOUNT

Create Wallet Of Type
    [Arguments]     ${type}
    ${_id}=    Create Valid Wallet   type=${type}
    Set Test Variable  ${walletId}  ${_id}

Create Outbound Category
    ${_id}=  Create Category Of type  OUTBOUND
    [Return]    ${_id}

Create Inbound Category
    ${_id}=  Create Category Of type  INBOUND
    [Return]    ${_id}

Create Category Of type
    [Arguments]     ${type}
    ${_id}=    Create Valid Category     type=${type}
    [Return]    ${_id}

Create Outbound Transaction
    [Arguments]     ${categoryId}=${None}
    ${transactionId}=   Create Transaction  type=OUTBOUND   categoryId=${categoryId}
    [Return]    ${transactionId}

Create Inbound Transaction
    [Arguments]     ${categoryId}=${None}
    ${transactionId}=   Create Transaction  type=INBOUND    categoryId=${categoryId}
    [Return]    ${transactionId}

Create Transaction
    [Arguments]     ${type}     ${categoryId}=${None}
    &{transaction}=  Build Manual Transaction   type=${type}    walletId=${walletId}    categoryId=${categoryId}
    ${resp}=  POST On Session    TRANSACTIONS   /     json=&{transaction}   expected_status=201
    Set Test Variable   ${transactionId}    ${resp.json()['id']}
    [Return]    ${transactionId}

Create List Of Transactions
    ${id1}=     Create Transaction  type=INBOUND
    ${id2}=     Create Transaction  type=OUTBOUND
    @{x}=       Create List  ${id1}  ${id2}
    Set Test Variable   @{ids}  @{x}

Create Transaction With Non Existing Category Should Return Invalid Response
    &{transaction}=  Build Manual Transaction   type=OUTBOUND   walletId=${walletId}    categoryId=X
    ${resp}=  POST On Session    TRANSACTIONS   /     json=&{transaction}   expected_status=400

Create Outbound Transaction With Inbound Category Should Return Invalid Response
    [Arguments]     ${categoryId}
    &{transaction}=  Build Manual Transaction   type=OUTBOUND   walletId=${walletId}    categoryId=${categoryId}
    ${resp}=  POST On Session    TRANSACTIONS   /     json=&{transaction}   expected_status=400

Create Inbound Transaction With Outbound Category Should Return Invalid Response
    [Arguments]     ${categoryId}
    &{transaction}=  Build Manual Transaction   type=INBOUND    walletId=${walletId}    categoryId=${categoryId}
    ${resp}=  POST On Session    TRANSACTIONS   /     json=&{transaction}   expected_status=400

Create Manual Transaction On Account Wallet Should Return Invalid Response
    &{transaction}=  Build Manual Transaction   type=OUTBOUND   walletId=${walletId}
    ${resp}=  POST On Session    TRANSACTIONS   /     json=&{transaction}   expected_status=403

Create Transaction On Non Existing Wallet Should Return Invalid Response
    &{transaction}=  Build Manual Transaction   type=OUTBOUND   walletId=X
    ${resp}=  POST On Session    TRANSACTIONS   /     json=&{transaction}   expected_status=400

Get Transaction By Id   
    [Arguments]     ${transactionId}=${transactionId}
    ${resp}=    GET On Session      TRANSACTIONS      /${transactionId}    expected_status=200
    [return]  ${resp.json()}

Get Transaction By Id Should Return 404
    ${resp}=    GET On Session      TRANSACTIONS      /X    expected_status=404

Transactions Lenght Should Be Greater Than One
    ${resp}=    GET On Session      TRANSACTIONS      /    expected_status=200
    ${count}=   Get length    ${resp.json()}
    Should Be True      ${count}>1

Transactions Count Should Be N
    [Arguments]     ${walletId}=${walletId}     ${count}=0
    ${params}=      Create dictionary   wallet=${walletId}
    ${resp}=    GET On Session      TRANSACTIONS      /search     params=${params}    expected_status=200
    ${transactionsCount}=   Get length    ${resp.json()}
    Should Be Equal As Numbers      ${transactionsCount}    ${count}

Delete Transactions
    [Arguments]     
    DELETE On Session  TRANSACTIONS  /${ids[0]}  expected_status=204
    DELETE On Session  TRANSACTIONS  /${ids[1]}  expected_status=204

Created Transaction Should Be Correct
    [Arguments]     ${type}     ${transactionId}=${transactionId}
    ${transaction}=  Get Transaction By Id  ${transactionId}
    Should Not Be Empty     ${transaction['id']}
    Should Be Equal As Strings     ${transaction['walletId']}    ${walletId}
    Should Be Equal As Strings     ${transaction['description']}    ${TRANSACTION_DESCRIPTION}
    Should Be Equal As Strings     ${transaction['transactionDate']}    ${TRANSACTION_DATE}
    Should Be Equal As Strings     ${transaction['type']}       ${type}
    Should Be Equal As Numbers     ${transaction['amount']}     ${TRANSACTION_AMOUNT}

Delete Transaction
    [Arguments]     ${transactionId}=${transactionId}
    DELETE On Session  TRANSACTIONS  /${transactionId}  expected_status=204

Delete Transaction Should Return 404
    DELETE On Session  TRANSACTIONS  /X  expected_status=404

Update Transaction
    [Arguments]     ${transactionId}=${transactionId}
    ${transaction}=    Get Transaction By Id  ${transactionId}
    Set To dictionary   ${transaction}     description='modified description'
    PUT On Session  TRANSACTIONS  /${transactionId}    json=${transaction}    expected_status=204 
    ${transaction}=    Get Transaction By Id  ${transactionId}
    Should Be Equal As Strings      ${transaction['description']}  'modified description'

Update Transaction Should Return 404 
    [Arguments]     ${transactionId}=${transactionId}
    &{transaction}=  Build Manual Transaction   id=X  type=OUTBOUND   walletId=${walletId}
    PUT On Session  TRANSACTIONS  /X    json=${transaction}    expected_status=404 

Update Transaction Should Return 400 If Category Type Changes
    [Arguments]         ${transactionId}    ${categoryId}
    ${transaction}=     Get Transaction By Id  ${transactionId}
    Set To dictionary   ${transaction}     categoryId=${categoryId}
    PUT On Session  TRANSACTIONS  /${transactionId}    json=${transaction}    expected_status=400 
