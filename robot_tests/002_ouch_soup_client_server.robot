*** Settings ***
Library           Remote    http://localhost:${OUCH_PORT}    WITH NAME    OUCH

*** Test Cases ***
Connect and Disconnect
    [Setup]    OUCH.Reset
    OUCH.Create Server    server_a    44000    4.2
    OUCH.Create Client    client_a    localhost    44000    4.2
    OUCH.Server Start Listening    server_a
    OUCH.Connect Client    client_a
    Wait Until Keyword Succeeds    5s    1s   OUCH.Server Has New Session    server_a
    OUCH.Disconnect Client    client_a
    OUCH.Destroy Client    client_a

Multiple Connections
    [Setup]    OUCH.Reset
    OUCH.Create Server    server_a    44000    4.2
    OUCH.Server Start Listening     server_a
    OUCH.Create Client    client_a    localhost    44000    4.2
    OUCH.Create Client    client_b    localhost    44000    4.2
    OUCH.Create Client    client_c    localhost    44000    4.2
    OUCH.Connect Client    client_a
    OUCH.Connect Client    client_b
    OUCH.Connect Client    client_c
    OUCH.Get New Server Session    server_a    session_a
    OUCH.Get New Server Session    server_a    session_b
    OUCH.Get New Server Session    server_a    session_c
    OUCH.Disconnect Client    client_a
    OUCH.Disconnect Client    client_b
    OUCH.Disconnect Client    client_c
    OUCH.Destroy Client    client_a
    OUCH.Destroy Client    client_b
    OUCH.Destroy Client    client_c
    OUCH.Destroy Server    server_a

