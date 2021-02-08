*** Settings ***
Library               RequestsLibrary
Library               Collections  

Resource              categories.resource  

Suite Setup           Create Session    CATEGORIES    ${CATEGORIES_URL}

*** Variables ***
${id}=      ${None}

*** Test Cases ***
User can create a valid category
    Create Valid Category
    Category Should Be Exist  id=${id}
    [Teardown]  Delete Category  id=${id}

User cannot create a category with wrong type
    Create Category With Invalid Type Should Be 400

User can show a category
    [Setup]     Create Valid Category
    Category Should Have All Data
    [Teardown]  Delete Category     ${id}

User cannot show a non existing category
    Get Category Should Be 404

User can show a list of categories
    [Setup]    Create List Of Categories
    Categories Lenght Should Be Greater Than One
    [Teardown]  Delete Categories

User can modify a category
    [Setup]     Create Valid Category
    Modify Created Category
    [Teardown]  Delete Category     ${id}

User cannot modify a category with wrong type
    [Setup]  Create Valid Category
    Modify Category With Invalid Type Should Be 400
    [Teardown]  Delete Category     ${id}

User cannot modify a non existing category
    Modify Non Existing Category Should Be 404

User cannot modify a category with wrong id
    Modify Category With Invalid Id Should Be 400

User can delete an existing category
    [Setup]  Create Valid Category
    Delete Category     ${id}

User cannot delete a non existing category
    Delete Non Existing Category Should Be 404