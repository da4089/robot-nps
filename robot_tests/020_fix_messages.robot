*** Settings ***
Library           Remote    http://localhost:${FIX_PORT}    WITH NAME    FIX

*** Test Cases ***
Create Fix Message
    [Setup]    FIX.Reset
    FIX.Create Message    message_1

Create Integer Message Field
    [Setup]    FIX.Reset
    FIX.Create Message    message_1
    FIX.Set Integer Field    message_1    29    1


*** Keywords ***
