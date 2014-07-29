*** Settings ***
Library    Remote    http://localhost:${OUCH_PORT}    WITH NAME    OUCH

*** Test Cases ***
Stop Ouch Simulator
    OUCH.Stop Remote server
