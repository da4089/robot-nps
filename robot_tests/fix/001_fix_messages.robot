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

Create UTC Timestamp Message Field
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
    FIX.Destroy Message    message_1

Create UTC Time Only Message Field
    [Setup]    FIX.Reset
    FIX.Create Message    message_1
    FIX.Set UTC Time Only Field    message_1    42    12:34:56.789
    FIX.Set UTC Time Only Field    message_1    42    12:34:56
    Run Keyword and Expect Error    BadUTCTimeOnlyError*    FIX.Set UTC Time Only Field    message_1    44    12:34:56.
    Run Keyword and Expect Error    BadUTCTimeOnlyError*    FIX.Set UTC Time Only Field    message_1    44    12:34
    Run Keyword and Expect Error    BadUTCTimeOnlyError*    FIX.Set UTC Time Only Field    message_1    44    12:34:56.7
    Run Keyword and Expect Error    BadUTCTimeOnlyError*    FIX.Set UTC Time Only Field    message_1    44    12:34:56.7890
    Run Keyword and Expect Error    BadUTCTimeOnlyError*    FIX.Set UTC Time Only Field    message_1    44    24:34:56
    Run Keyword and Expect Error    BadUTCTimeOnlyError*    FIX.Set UTC Time Only Field    message_1    44    12:60:56
    Run Keyword and Expect Error    BadUTCTimeOnlyError*    FIX.Set UTC Time Only Field    message_1    44    12:34:61
    Run Keyword and Expect Error    BadUTCTimeOnlyError*    FIX.Set UTC Time Only Field    message_1    44    12.34.56
    Run Keyword and Expect Error    BadUTCTimeOnlyError*    FIX.Set UTC Time Only Field    message_1    44    12:34:56,789

Create UTC Date Only Message Field
    [Setup]    FIX.Reset
    FIX.Create Message    message_1
    FIX.Set UTC Date Only Field    message_1    42    20160101

    Run Keyword and Expect Error    BadUTCDateOnlyError*    FIX.Set UTC Date Only Field    message_1    44    20161301
    Run Keyword and Expect Error    BadUTCDateOnlyError*    FIX.Set UTC Date Only Field    message_1    44    20160132


Create TZ Timestamp Field
    [Setup]    FIX.Reset
    FIX.Create Message    message_1
    FIX.Destroy Message    message_1

Create TZ Time Only Field
    [Setup]    FIX.Reset
    FIX.Create Message    message_1
    FIX.Set TZ Time Only Field    message_1    42    12:34
    FIX.Set TZ Time Only Field    message_1    42    12:34Z
    FIX.Set TZ Time Only Field    message_1    42    12:34+01
    FIX.Set TZ Time Only Field    message_1    42    12:34+12
    FIX.Set TZ Time Only Field    message_1    42    12:34-01
    FIX.Set TZ Time Only Field    message_1    42    12:34-12
    FIX.Set TZ Time Only Field    message_1    42    12:34+12:34
    FIX.Set TZ Time Only Field    message_1    42    12:34-12:34
    FIX.Set TZ Time Only Field    message_1    42    12:34:56
    FIX.Set TZ Time Only Field    message_1    42    12:34:56Z
    FIX.Set TZ Time Only Field    message_1    42    12:34:56+01
    FIX.Set TZ Time Only Field    message_1    42    12:34:56+12
    FIX.Set TZ Time Only Field    message_1    42    12:34:56-01
    FIX.Set TZ Time Only Field    message_1    42    12:34:56-12
    FIX.Set TZ Time Only Field    message_1    42    12:34:56+12:34
    FIX.Set TZ Time Only Field    message_1    42    12:34:56-12:34
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:3
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12.34
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:5
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12.34.56
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34z
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34+1
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34-1
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34+123
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34-123
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34+1234
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34-1234
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34+12345
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34-123456
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34+1301
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34-1301
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34+1260
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34-1260
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34+12:
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34-12:
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34+12:3
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34-12:3
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34+12.3
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34-12.3
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34/12
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34/1234
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34/12:34
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34+12.34
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34-12.34
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34+12:34:56
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34-12:34:56
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56+1
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56-1
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56+123
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56-123
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56+1234
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56-1234
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56+12345
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56-123456
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56+1301
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56-1301
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56+1260
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56-1260
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56+12:
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56-12:
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56+12:3
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56-12:3
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56+12.3
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56-12.3
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56/12
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56/1234
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56/12:34
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56+12.34
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56-12.34
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56+12:34:56
    Run Keyword and Expect Error    BadTZTimeOnlyError*    FIX.Set TZ Time Only Field    message_1    44    12:34:56-12:34:56
    FIX.Destroy Message    message_1

Create Local Market Date Field
    [Setup]    FIX.Reset
    FIX.Create Message    message_1
    FIX.Set Local Market Date Field    message_1    42    20160101

    Run Keyword and Expect Error    BadLocalMarketDateError*    FIX.Set Local Market Date Field    message_1    44    20161301
    Run Keyword and Expect Error    BadLocalMarketDateError*    FIX.Set Local Market Date Field    message_1    44    20160132


Create Nested Repeating Fields
    [Setup]    FIX.Reset
    FIX.Create Message    message_1
    FIX.Set Integer Field    message_1    73    2
    FIX.Set String Field    message_1    11    ORD#1
    FIX.Set Integer Field    message_1    67    1
    FIX.Set Integer Field    message_1    78    2
    FIX.Set String Field    message_1    79    ACCT#1
    FIX.Set Float Field    message_1    80    100
    FIX.Set String Field    message_1    79    ACCT#2
    FIX.Set Float Field    message_1    80    200
    FIX.Set String Field    message_1    11    ORD#2
    FIX.Set Integer Field    message_1    67    2
    FIX.Set Integer Field    message_1    78    2
    FIX.Set String Field    message_1    79    ACCT#3
    FIX.Set Float Field    message_1    80    1000
    FIX.Set String Field    message_1    79    ACCT#4
    FIX.Set Float Field    message_1    80    2000

    ${noAllocs}=    FIX.Get Field    message_1    73
    Should Be Equal    2    ${noAllocs}

    ${acct}=    FIX.GetField    message_1    79    4
    Should Be Equal    ACCT#4    ${acct}

*** Keywords ***
