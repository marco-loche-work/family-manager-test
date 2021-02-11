*** Settings ***
Library              RequestsLibrary


***Variables***
${SERVER}            http://localhost
${TRANSACTIONS_URL}  ${SERVER}:8082/api/v1/transactions
${WALLET_URL}        ${SERVER}:8082/api/v1/wallets  
${CATEGORIES_URL}    ${SERVER}:8082/api/v1/categories


***Keywords***
Suite Setup
    Create Session    TRANSACTIONS    ${TRANSACTIONS_URL}
    Create Session    WALLETS         ${WALLET_URL}
    Create Session    CATEGORIES      ${CATEGORIES_URL}