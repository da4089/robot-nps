*** Settings ***
Library           Remote    http://localhost:${FIX_PORT}    WITH NAME    FIX

*** Test Cases ***
Connect and Disconnect
    [Setup]    FIX.Reset
    FIX.Create Server    server_1    44001    4.2
    FIX.Create Client    client_1    localhost    44001    4.2
    FIX.Server Start Listening    server_1
    FIX.Connect Client    client_1

*** Keywords ***
