***Settings***
Resource           ../common.resource 


*** Variables ***
${CATEGORY_NAME}   category test         
${CATEGORY_TYPE}   INBOUND


*** Keywords ***
Create Valid Category   
    [Arguments]     ${type}=${CATEGORY_TYPE}
    &{data}=  Create dictionary  name=${CATEGORY_NAME}    type=${type}
    ${resp}=  POST On Session    CATEGORIES   /     json=${data}   expected_status=201
    Set Test Variable   ${id}  ${resp.json()['id']}
    [return]    ${id}

Create List Of Categories
    ${id1}=     Create Valid Category
    ${id2}=     Create Valid Category
    @{x}=     Create List  ${id1}  ${id2}
    Set Test Variable   @{ids}  @{x}
    [Return]    @{ids}

Create Category With Invalid Type Should Be 400
    &{data}=    Create dictionary  name=${CATEGORY_NAME}    type=X
    ${resp}=    POST On Session    CATEGORIES   /     json=${data}     expected_status=400

Get Category 
    [Arguments]     ${category_id}
    ${resp}=    GET On Session      CATEGORIES      /${id}    expected_status=200
    [return]  ${resp.json()}

Category Should Be Exist
    [Arguments]     ${id}
    GET On Session      CATEGORIES      /${id}    expected_status=200

Category Should Have All Data
    ${category}=    Get Category   ${id}
    Should Be Equal As Strings     ${category['name']}  ${CATEGORY_NAME}
    Should Be Equal As Strings     ${category['type']}  ${CATEGORY_TYPE}

Categories Lenght Should Be Greater Than One
    ${resp}=    GET On Session      CATEGORIES      /    expected_status=200
    ${count}=   Get length    ${resp.json()}
    Should Be True      ${count}>1

Get Category Should Be 404
    GET On Session      CATEGORIES      /X    expected_status=404

Modify Created Category
    ${category}=    Get Category   ${id}
    Set To dictionary   ${category}     name='modified name'
    PUT On Session  CATEGORIES  /${id}    json=${category}    expected_status=204 
    ${category}=    Get Category   ${id}
    Should Be Equal As Strings      ${category['name']}  'modified name'

Modify Non Existing Category Should Be 404
    &{data}=  Create dictionary  id=X   name=${CATEGORY_NAME}    type=INBOUND
    PUT On Session  CATEGORIES  /X    json=&{data}    expected_status=404 

Modify Category With Invalid Id Should Be 400
    &{data}=  Create dictionary  id=Y   name=${CATEGORY_NAME}    type=INBOUND
    PUT On Session  CATEGORIES  /X    json=&{data}    expected_status=400 

Modify Category With Invalid Type Should Be 400
    ${category}=    Get Category   ${id}
    Set To dictionary   ${category}     type='X'
    PUT On Session  CATEGORIES  /${id}    json=${category}    expected_status=400 

Delete Category
    [Arguments]     ${id}
    DELETE On Session  CATEGORIES  /${id}  expected_status=204

Delete Categories
    [Arguments]     
    DELETE On Session  CATEGORIES  /${ids[0]}  expected_status=204
    DELETE On Session  CATEGORIES  /${ids[1]}  expected_status=204

Delete Non Existing Category Should Be 404
    DELETE On Session  CATEGORIES  /non_existing_category  expected_status=404
