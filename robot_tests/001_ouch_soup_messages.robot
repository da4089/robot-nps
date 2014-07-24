*** Settings ***
Library    Remote    http://localhost:8274    WITH NAME    OUCH

*** Test Cases ***
Create Soup Message
    OUCH.Reset
    OUCH.Create Soup Message    message_1    U

Create Duplicate Message
    OUCH.Reset
    OUCH.Create Soup Message    message_1    U
    Run Keyword And Expect Error    DuplicateMessageError*    OUCH.Create Soup Message    message_1    U
    OUCH.Create Soup Message    message_2    U


*** Keywords ***
