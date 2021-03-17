***Settings***
Library           Collections 

Resource          ../common.resource 


*** Variables ***
${TRANSACTION_DATE}         2020-08-18T21:00:00Z
${TRANSACTION_AMOUNT}       200
${TRANSACTION_DESCRIPTION}  fake transaction description
${TRANSACTION_TYPE}         OUTBOUND
${walletIds}                


*** Keywords ***

Build Manual Transaction 
    [Arguments]       ${id}=${None}  ${walletId}=${None}  ${type}=OUTBOUND   ${categoryId}=${categoryId}    
    ...               ${amount}=${TRANSACTION_AMOUNT}   ${date}=${TRANSACTION_DATE}
    &{transaction}=   Create dictionary   id=${id}  walletId=${walletId}  transactionDate=${date}  
    ...               amount=${amount}  description=${TRANSACTION_DESCRIPTION}  type=${type}    
    ...               categoryId=${categoryId}  
    [Return]    &{transaction}

Create Manual Wallet
    [Arguments]     ${balance}=${WALLET_OPENING_BALANCE}
    ${id}=  Create Wallet Of type  MANUAL   balance=${balance}
    [Return]    ${id}

Create Account Wallet
    [Arguments]     ${balance}=${WALLET_OPENING_BALANCE}
    ${id}=  Create Wallet Of type  ACCOUNT  balance=${balance}
    [Return]    ${id}

Create Wallet Of Type
    [Arguments]     ${type}   ${balance}=${WALLET_OPENING_BALANCE}
    ${_id}=    Create Valid Wallet   type=${type}   balance=${balance}
    Set Test Variable  ${walletId}  ${_id}
    [Return]    ${walletId}

Create Outbound Category
    ${_id}=  Create Category Of type  OUTBOUND
    [Return]    ${_id}

Create Inbound Category
    ${_id}=  Create Category Of type  INBOUND
    [Return]    ${_id}

Create Category Of type
    [Arguments]     ${type}
    ${_id}=    Create Valid Category     type=${type}
    Set Test Variable  ${categoryId}    ${_id}
    [Return]    ${_id}

Create Outbound Transaction
    [Arguments]     ${walletId}=${walletId}  ${categoryId}=${categoryId}  ${amount}=${TRANSACTION_AMOUNT}     
    ...             ${date}=${TRANSACTION_DATE}
    ${transactionId}=   Create Transaction  walletId=${walletId}  type=OUTBOUND  categoryId=${categoryId}
    ...                                     amount=${amount}    date=${date}
    [Return]    ${transactionId}

Create Inbound Transaction
    [Arguments]     ${walletId}=${walletId}  ${categoryId}=${categoryId}     ${amount}=${TRANSACTION_AMOUNT}    
    ...             ${date}=${TRANSACTION_DATE}
    ${transactionId}=   Create Transaction  walletId=${walletId}  type=INBOUND    categoryId=${categoryId}    
    ...                                     amount=${amount}    date=${date}
    [Return]    ${transactionId}

Create Transaction
    [Arguments]     ${walletId}=${walletId}  ${type}=${TRANSACTION_TYPE}  ${categoryId}=${None}
    ...             ${amount}=${TRANSACTION_AMOUNT}  ${date}=${TRANSACTION_DATE}
    &{transaction}=  Build Manual Transaction   type=${type}    walletId=${walletId}    
    ...                                         categoryId=${categoryId}    amount=${amount}
    ...                                         date=${date}
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

Get Wallet Transactions 
    [Arguments]     ${walletId}
    ${resp}=    GET On Session      TRANSACTIONS      /  params=wallet=${walletId}    expected_status=200
    [return]  ${resp.json()}

Get Transaction By Id Should Return 404
    ${resp}=    GET On Session      TRANSACTIONS      /X    expected_status=404

Transactions Lenght Should Be Greater Than One
    ${resp}=    GET On Session      TRANSACTIONS      /    expected_status=200
    ${count}=   Get length    ${resp.json()}
    Should Be True      ${count}>1

Get Params
    [Arguments]     ${walletIds}=${walletIds}  ${startDate}=${Empty}  ${endDate}=${Empty}  
    ...             ${type}=${Empty}  ${categoryId}=${Empty}
    ${params}=      Create dictionary   wallet=${walletIds}  
    Run Keyword If      '${startDate}' != '${Empty}'    Set To Dictionary   ${params}   startDate=${startDate}
    Run Keyword If      '${endDate}' != '${Empty}'   Set To Dictionary   ${params}   endDate=${endDate}
    Run Keyword If      '${type}' != '${Empty}'   Set To Dictionary   ${params}   type=${type}
    Run Keyword If      '${categoryId}' != '${Empty}'   Set To Dictionary   ${params}   category=${categoryId}
    [Return]    ${params}

Transactions Count Should Be N
    [Arguments]     ${walletIds}=${walletIds}  ${startDate}=${Empty}  
    ...             ${endDate}=${Empty}  ${type}=${Empty}  ${categoryId}=${Empty}
    ...             ${count}=0
    ${params}=      Get Params   walletIds=${walletIds}  startDate=${startDate}  endDate=${endDate}  
    ...                          type=${type}  categoryId=${categoryId}
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
    [Arguments]     ${transactionId}=${transactionId}   ${description}=modified description
    ${transaction}=    Get Transaction By Id  ${transactionId}
    Set To dictionary   ${transaction}     description=${description}
    PUT On Session  TRANSACTIONS  /${transactionId}    json=${transaction}    expected_status=204 
    ${transaction}=    Get Transaction By Id  ${transactionId}
    Should Be Equal As Strings      ${transaction['description']}  ${description}

Update Transaction Should Return 404 
    [Arguments]     ${transactionId}=${transactionId}
    &{transaction}=  Build Manual Transaction   id=X  type=OUTBOUND   walletId=${walletId}
    PUT On Session  TRANSACTIONS  /X    json=${transaction}    expected_status=404 

Update Transaction Should Return 400 If Category Type Changes
    [Arguments]         ${transactionId}    ${categoryId}
    ${transaction}=     Get Transaction By Id  ${transactionId}
    Set To dictionary   ${transaction}     categoryId=${categoryId}
    PUT On Session  TRANSACTIONS  /${transactionId}    json=${transaction}    expected_status=400 

Transaction Category Should Be
    [Arguments]     ${categoryId}   ${transactionId}=${transactionId}
    ${transaction}=     Get Transaction By Id  
    ${id}=  Get From Dictionary     ${transaction}     key=categoryId
    Should Be Equal As Strings  ${categoryId}   ${id}

Check Balance Template
    [Arguments]     ${walletId}=${walletId}  ${limitDate}=${Empty}  ${balance}=0
    ${params}=      Create dictionary   wallet=${walletId}
    Run Keyword If      '${limitDate}' != '${Empty}'    Set To Dictionary   ${params}   limitDate=${limitDate}
    ${resp}=    GET On Session      TRANSACTIONS      /balance     params=${params}    expected_status=200
    Should Be Equal As Numbers  ${balance}  ${resp.json()['balance']}

Check Balance For Each Wallet Template
    [Arguments]     ${walletIds}=${walletIds}  ${limitDate}=${Empty}  ${balance0}=0  ${balance1}=0
    ${params}=      Create dictionary   wallet=${walletIds}
    Run Keyword If      '${limitDate}' != '${Empty}'    Set To Dictionary   ${params}   end-date=${limitDate}
    ${resp}=    GET On Session      TRANSACTIONS      /wallet-balance     params=${params}    expected_status=200
    Should Be Equal As Numbers  ${balance0}  ${resp.json()[0]['balance']}
    Should Be Equal As Numbers  ${balance1}  ${resp.json()[1]['balance']}

Check Totals 
    [Arguments]     ${walletIds}=${walletIds}  ${startDate}=${Empty}  ${endDate}=${Equal}  
    ...             ${inbound}=0  ${outbound}=0  ${balance}=0  ${difference}=0
    ${params}=      Create dictionary   wallet=${walletIds}
    Run Keyword If      '${startDate}' != '${Empty}'    Set To Dictionary   ${params}   start-date=${startDate}
    Run Keyword If      '${endDate}' != '${Empty}'    Set To Dictionary   ${params}   end-date=${endDate}
    ${resp}=    GET On Session      TRANSACTIONS      /totals     params=${params}    expected_status=200
    Should Be Equal As Numbers  ${inbound}  ${resp.json()['inbound']}
    Should Be Equal As Numbers  ${outbound}  ${resp.json()['outbound']}
    Should Be Equal As Numbers  ${balance}  ${resp.json()['balance']}
    Should Be Equal As Numbers  ${difference}  ${resp.json()['difference']}
    
Upload Excel Transactions
    [Arguments]     ${status}=200
    Upload Excel   ${TRANSACTIONS_URL}/upload/${walletId}  file_path=${CURDIR}/files/transactions.xlsx  expected_status=${status}

Upload Csv Transactions
    [Arguments]     ${status}=200
    Upload Csv   ${TRANSACTIONS_URL}/upload/${walletId}  file_path=${CURDIR}/files/file.csv  expected_status=${status}
