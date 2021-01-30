*** Settings ***
Library               RequestsLibrary
Library               Collections  
Suite Setup           Create Session    CATEGORIES    ${URL}

*** Variables ***
${URL}         http://localhost:8082


*** Test Cases ***
User can create a valid category
    Create Valid Category
    Category Should Be Exist

User cannot create a category with wrong type
    Create Category With Invalid Type Should Be 400

User can show a category
    Create Valid Category
    Category Should Have All Data

User can modify a category
    Create Valid Category
    Modify Created Category

User cannot modify a category with wrong type
    Create Valid Category
    Modify Category With Invalid Type Should Be 400

User can delete an existing category
    Create Valid Category
    Delete Category

User cannot delete a non existing category
    Delete Non Existing Category Should Be 404

*** Keywords ***
Create Valid Category
    &{data}=  Create dictionary  name=category 1    type=INBOUND
    ${resp}=  POST On Session    CATEGORIES   /api/v1/categories     json=${data}   expected_status=201
    Set Test Variable   ${response}  ${resp}
    Set Test Variable   ${id}  ${resp.json()['id']}
          

Create Category With Invalid Type Should Be 400
    &{data}=    Create dictionary  name=category 1    type=X
    ${resp}=    POST On Session    CATEGORIES   /api/v1/categories     json=${data}     expected_status=400

Get Category 
    [Arguments]     ${category_id}
    ${resp}=    GET On Session      CATEGORIES      /api/v1/categories/${id}    expected_status=200
    [return]  ${resp.json()}

Category Should Be Exist
    GET On Session      CATEGORIES      /api/v1/categories/${id}    expected_status=200

Category Should Have All Data
    ${category}=    Get Category   ${id}
    Should Not Be Empty     ${category['id']}
    Should Not Be Empty     ${category['name']}
    Should Not Be Empty     ${category['type']}

Modify Created Category
    ${category}=    Get Category   ${id}
    Set To dictionary   ${category}     name='modified name'
    PUT On Session  CATEGORIES  /api/v1/categories/${id}    json=${category}    expected_status=204 
    ${category}=    Get Category   ${id}
    Should Be Equal As Strings      ${category['name']}  'modified name'


Modify Category With Invalid Type Should Be 400
    ${category}=    Get Category   ${id}
    Set To dictionary   ${category}     type='X'
    PUT On Session  CATEGORIES  /api/v1/categories/${id}    json=${category}    expected_status=400 

Delete Category
    [Arguments]     ${category_id}=${id}
    DELETE On Session  CATEGORIES  /api/v1/categories/${category_id}  expected_status=204

Delete Non Existing Category Should Be 404
    DELETE On Session  CATEGORIES  /api/v1/categories/non_existing_category  expected_status=404
