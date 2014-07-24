*** Settings ***
Library    Remote    http://localhost:8274    WITH NAME    OUCH

*** Test Cases ***
Stop Ouch Simulator
    OUCH.Stop Remote server
