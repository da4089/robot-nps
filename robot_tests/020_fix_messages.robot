*** Settings ***
Library           Remote    http://localhost:${FIX_PORT}    WITH NAME    FIX

*** Test Cases ***
Create Message
    [Setup]    FIX.Reset
    FIX.Create Message    message_1

Create Duplicate Message
    [Setup]    FIX.Reset
    FIX.Create Message    message_1
    Run Keyword and Expect Error    DuplicateMessageError*    FIX.CreateMessage    message_1
    FIX.Create Message    message_2

Destroy Message
    [Setup]    FIX.Reset
    FIX.Create Message    message_1
    FIX.Destroy Message    message_1

Destroy Non-existent Message
    [Setup]    FIX.Reset
    Run Keyword And Expect Error    NoSuchMessageError*    FIX.Destroy Message    message_1
    FIX.Create Message    message_1
    FIX.Destroy Message    message_1
    Run Keyword And Expect Error    NoSuchMessageError*    FIX.Destroy Message    message_1

Create Integer Message Field
    [Setup]    FIX.Reset
    FIX.Create Message    message_1
    FIX.Set Integer Field    message_1    42    1

Create Float Message Field
    [Setup]    FIX.Reset
    FIX.Create Message    message_1
    FIX.Set Float Field    message_1    42    3.1416

Create Boolean Message Field
    [Setup]    FIX.Reset
    FIX.Create Message    message_1
    FIX.Set Boolean Field    message_1    42    Y

Create String Message Field
    [Setup]    FIX.Reset
    FIX.Create Message     message_1
    FIX.Set String Field    message_1    42    string value with spaces



*** Keywords ***
