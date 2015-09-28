*** Settings ***
Documentation    Suite description
Library           Remote    http://localhost:${OUCH_PORT}    WITH NAME    OUCH

*** Test Cases ***
Reuse Server Ports
    OUCH.Reset
    OUCH.Create Client    client_a    localhost    44000    4.2
    OUCH.Create Server    server_a    44000    4.2
    OUCH.Server Start Listening    server_a
    OUCH.Connect Client    client_a
    Wait Until Keyword Succeeds    5s    1s    OUCH.Server Has New Session     server_a
    OUCH.Disconnect Client    client_a
    OUCH.Destroy Server    server_a
    OUCH.Create Server     server_b    44000    4.2
    OUCH.Server Start Listening    server_b
    OUCH.Connect Client    client_a
    Wait Until Keyword Succeeds    5s    1s    OUCH.Server has New Session     server_b
    OUCH.Disconnect Client    client_a
    OUCH.Destroy Server    server_b
    OUCH.Destroy Client    client_a

Reuse Automagic Client Ports
    OUCH.Reset
    OUCH.Create Server    server_a    44000    4.2
    OUCH.Server Start Listening    server_a

    OUCH.Create Client    client_a    localhost    44000    4.2
    OUCH.Connect Client    client_a
    Wait Until Keyword Succeeds    5s    1s    OUCH.Server Has New Session    server_a
    OUCH.Disconnect Client    client_a

    OUCH.Create Client    client_b    localhot    44000    4.2
    OUCH.Connect Client    client_b
    Wait Until Keyword Succeeds    5s    1s    OUCH.Server Has New Session    server_a
    OUCH.Disconnect Client  client_b

Reuse Fixed Client Ports
    OUCH.Reset
    OUCH.Create Server    server_a    44000    4.2
    OUCH.Server Start Listening    server_a

    OUCH.Create Client    client_a    localhost    44000    4.2    43999
    OUCH.Connect Client    client_a
    Wait Until Keyword Succeeds    5s    1s    OUCH.Server Has New Session    server_a
    OUCH.Disconnect Client    client_a
    OUCH.Destroy Client    client_a

    OUCH.Create Client    client_b    localhot    44000    4.2    43999
    OUCH.Connect Client    client_b
    Wait Until Keyword Succeeds    5s    1s    OUCH.Server Has New Session    server_a
    OUCH.Disconnect Client  client_b
    OUCH.Destroy Client    client_b

