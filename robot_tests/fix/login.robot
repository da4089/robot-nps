*** Settings ***
Library           Remote    http://localhost:${FIX_PORT}    WITH NAME    FIX

*** Test Cases ***
Send Logon
    [Setup]    FIX.Reset
    FIX.Create Message    logon_req
    FIX.Set Session Version    logon_req    FIXT.1.1
    FIX.Set Message Type    logon_req    A
    FIX.Set String Field    logon_req    49    VALBURY.dropcopy
    FIX.Set String Field    logon_req    56    AXICORP.dropcopy
    FIX.Set Timestamp Field    logon_req    52    20160101-10:00:00.000
    FIX.Set String Field    logon_req    98    0
    FIX.Set Integer Field    logon_req    108    60
    FIX.Set Integer Field    logon_req    34    1
    FIX.Set Integer Field    logon_req    141    Y
    FIX.Set String Field    logon_req    1137    9
    FIX.Set String Field    logon_req    553     valbury
    FIX.Set String Field    logon_req    554     fre3HUj2guHu

    FIX.Create Client    client    ${SERVER_HOST}    ${SERVER_PORT}    5.0
    FIX.Connect Client    client
    FIX.Set Client Flushing    client    yes
    FIX.Send Client Message    client    logon_req

    Wait Until Keyword Succeeds    30s    1s    FIX.Client Has Received Message    client


*** Keywords ***

