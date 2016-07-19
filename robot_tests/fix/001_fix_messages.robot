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

Create UTC Timestamp Message FIeld
    [Setup]    FIX.Reset
    FIX.Create Message    message_1
    FIX.Set UTC Timestamp Field    message_1    42    20160101-12:34:56.789
    FIX.Set UTC Timestamp Field    message_1    43    20160101-12:34:56
    Run Keyword and Expect Error    BadUTCTimestampError*    FIX.Set UTC Timestamp Field    message_1    44    20160101
    Run Keyword and Expect Error    BadUTCTimestampError*    FIX.Set UTC Timestamp Field    message_1    44    20161301-12:34:56
    Run Keyword and Expect Error    BadUTCTimestampError*    FIX.Set UTC Timestamp Field    message_1    44    20160132-12:34:56
    Run Keyword and Expect Error    BadUTCTimestampError*    FIX.Set UTC Timestamp Field    message_1    44    20160101Z12:34:56
    Run Keyword and Expect Error    BadUTCTimestampError*    FIX.Set UTC Timestamp Field    message_1    44    20160101-24:34:56
    Run Keyword and Expect Error    BadUTCTimestampError*    FIX.Set UTC Timestamp Field    message_1    44    20160101-12:60:56
    Run Keyword and Expect Error    BadUTCTimestampError*    FIX.Set UTC Timestamp Field    message_1    44    20160101-12:34:61
    Run Keyword and Expect Error    BadUTCTimestampError*    FIX.Set UTC Timestamp Field    message_1    44    20160101-12/34/56
    Run Keyword and Expect Error    BadUTCTimestampError*    FIX.Set UTC Timestamp Field    message_1    44    20160101-12:34:56,789
    Run Keyword and Expect Error    BadUTCTimestampError*    FIX.Set UTC Timestamp Field    message_1    44    20160101-12:34:56.78
    Run Keyword and Expect Error    BadUTCTimestampError*    FIX.Set UTC Timestamp Field    message_1    44    20160101-12:34:56.7890




*** Keywords ***
