*** Settings ***
Library           Remote    http://localhost:${OUCH_PORT}    WITH NAME    OUCH

*** Test Cases ***
Create Soup Message
    [Setup]    OUCH.Reset
    OUCH.Create Soup Message    message_1    U

Create Duplicate Message
    [Setup]    OUCH.Reset
    OUCH.Create Soup Message    message_1    U
    Run Keyword And Expect Error    DuplicateMessageError*    OUCH.Create Soup Message    message_1    U
    OUCH.Create Soup Message    message_2    U

Destroy Non-existent Message
    [Setup]    OUCH.Reset
    Run Keyword And Expect Error    NoSuchMessageError*    OUCH.Destroy Soup Message    bad_name
    OUCH.Create Soup Message    good_name    U
    OUCH.Destroy Soup Message    good_name
    Run Keyword And Expect Error    NoSuchMessageError*    OUCH.Destroy Soup Message    good_name

Legal SOUP Message Types
    [Setup]    OUCH.Reset
    OUCH.Create Soup Message    msg    L
    OUCH.Destroy Soup Message    msg
    OUCH.Create Soup Message    msg    U
    OUCH.Destroy Soup Message    msg
    OUCH.Create Soup Message    msg    O
    OUCH.Destroy Soup Message    msg
    OUCH.Create Soup Message    msg    R
    OUCH.Destroy Soup Message    msg
    OUCH.Create Soup Message    msg    +
    OUCH.Destroy Soup Message    msg
    OUCH.Create Soup Message    msg    A
    OUCH.Destroy Soup Message    msg
    OUCH.Create Soup Message    msg    J
    OUCH.Destroy Soup Message    msg
    OUCH.Create Soup Message    msg    S
    OUCH.Destroy Soup Message    msg
    OUCH.Create Soup Message    msg    H
    OUCH.Destroy Soup Message    msg
    OUCH.Create Soup Message    msg    Z
    OUCH.Destroy Soup Message    msg

Illegal SOUP Message Types
    [Setup]    OUCH.Reset
    Run Keyword And Expect Error    BadMessageTypeError*    OUCH.Create Soup Message    msg    B

Set and Get SOUP Field
    [Documentation]    Test the ability to set and get field values from SOUP messages.
    [Setup]    OUCH.Reset
    OUCH.Create Soup Message    msg    L
    OUCH.Set Soup Field    msg    username    name
    ${value}=    OUCH.Get Soup Field    msg    username
    Should Be Equal As Strings    name    ${value.strip()}

Set Bad SOUP Field
    [Documentation]    Attempt to set a non-existent field name in a message (type).
    [Setup]    OUCH.Reset
    OUCH.Create Soup Message    msg    L
    Run Keyword And Expect Error    BadFieldNameError*    OUCH.Set Soup Field    msg    bad_name    value
    Run Keyword And Expect Error    BadFieldNameError*    OUCH.Get Soup Field    msg    bad_name

Legal OUCH Types
    [Setup]    OUCH.Reset
    OUCH.Create Soup Message    unseq    U
    OUCH.Set Ouch Type    unseq    M
    OUCH.Set Ouch Type    unseq    O
    OUCH.Set Ouch Type    unseq    U
    OUCH.Set Ouch Type    unseq    X
    OUCH.Create Soup Message    seq    S
    OUCH.Set Ouch Type    seq    A
    OUCH.Set Ouch Type    seq    B
    OUCH.Set Ouch Type    seq    C
    OUCH.Set Ouch Type    seq    D
    OUCH.Set Ouch Type    seq    E
    OUCH.Set Ouch Type    seq    F
    OUCH.Set Ouch Type    seq    G
    OUCH.Set Ouch Type    seq    I
    OUCH.Set Ouch Type    seq    J
    OUCH.Set Ouch Type    seq    K
    OUCH.Set Ouch Type    seq    M
    OUCH.Set Ouch Type    seq    P
    OUCH.Set Ouch Type    seq    S
    OUCH.Set Ouch Type    seq    T
    OUCH.Set Ouch Type    seq    U

Illegal OUCH Types
    [Setup]    OUCH.Reset
    OUCH.Create Soup Message    unseq    U
    Run Keyword And Expect Error    Bad*    OUCH.Set Ouch Type    unseq    A
    OUCH.Create Soup Message    seq    S
    Run Keyword And Expect Error    Bad*    OUCH.Set Ouch Type    seq    X

Set and Get OUCH Field
    [Setup]    OUCH.Reset
    OUCH.Create Soup Message    msg    U
    OUCH.Set Ouch Type    msg    O
    OUCH.Set Ouch Field    msg    order_token    order_1
    ${value}=    OUCH.Get Ouch Field    msg    order_token
    Should Be Equal As Strings    order_1    ${value.strip()}

Set Bad OUCH Field
    [Setup]    OUCH.Reset
    OUCH.Create Soup Message    msg    U
    OUCH.Set Ouch Type    msg    O
    Run Keyword And Expect Error    BadFieldNameError*    OUCH.Set Ouch Field    msg    BadName    BadValue
    Run Keyword And Expect Error    BadFieldNameError*    OUCH.Get Soup Field    msg    BadName


*** Keywords ***
