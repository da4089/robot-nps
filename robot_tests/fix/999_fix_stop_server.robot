*** Settings ***
Library    Remote    http://localhost:${FIX_PORT}    WITH NAME    FIX

*** Test Cases ***
Stop Fix Simulator
    FIX.Stop Remote server
