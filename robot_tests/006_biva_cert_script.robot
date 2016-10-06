*** Settings ***
Library           Remote    http://localhost:${OUCH_PORT}    WITH NAME    BIVA

*** Test Cases ***
Certification Workflow
    [Setup]    BIVA.Reset
    BIVA.Create Server    server_a    44002    1
    BIVA.Create Client    client_a    localhost    44002    1
    BIVA.Server Start Listening    server_a
    BIVA.Connect Client    client_a
    Wait Until Keyword Succeeds    5s    1s   BIVA.Server Has New Session    server_a
    BIVA.Get New Server Session    server_a    session_a



    Comment    Send Login

    BIVA.Create Soup Message    c_login_a    L
    BIVA.Set Soup Field    c_login_a    username    user01
    BIVA.Set Soup Field    c_login_a    password    password
    BIVA.Send Client Message    client_a    c_login_a

    Comment    Send LoginRejected

    BIVA.Create Soup Message    s_loginrej_a    J
    BIVA.Set Soup Field    s_loginrej_a    reject_reason_code    S
    BIVA.Send Server Message    session_a    s_loginrej_a



    Comment    Send Login

    BIVA.Create Soup Message    c_login_b    L
    BIVA.Set Soup Field    c_login_b    username    user01
    BIVA.Set Soup Field    c_login_b    password    password
    BIVA.Send Client Message    client_a    c_login_b

    Comment    Send LoginAccepted

    BIVA.Create Soup Message    s_loginack_b    A
    BIVA.Set Soup Field    s_loginack_b    session    SESS0001
    BIVA.Set Soup Field    s_loginack_b    sequence_number    0
    BIVA.Send Server Message    session_a    s_loginack_b



    Comment    -> Enter Order

    BIVA.Create Soup Message    ac_enter    U
    BIVA.Set Ouch Type    ac_enter    O
    BIVA.Set Ouch Field    ac_enter    order_token    1
    BIVA.Set Ouch Field    ac_enter    account_type    C
    BIVA.Set Ouch Field    ac_enter    account_id    42
    BIVA.Set Ouch Field    ac_enter    order_verb    B
    BIVA.Set Ouch Field    ac_enter    quantity    1000
    BIVA.Set Ouch Field    ac_enter    orderbook    1
    BIVA.Set Ouch Field    ac_enter    price    1234
    BIVA.Set Ouch Field    ac_enter    time_in_force    0
    BIVA.Set Ouch Field    ac_enter    client_id    1
    BIVA.Set Ouch Field    ac_enter    minimum_quantity    0
    BIVA.Send Client Message    client_a    ac_enter
    BIVA.Destroy Soup Message    ac_enter

    Comment    <- Order Accepted

    BIVA.Create Soup Message    as_accepted    S
    BIVA.Set Ouch Type    as_accepted    A
    BIVA.Set Ouch Field    as_accepted    timestamp    1001
    BIVA.Set Ouch Field    as_accepted    order_token    1
    BIVA.Set Ouch Field    as_accepted    account_type    C
    BIVA.Set Ouch Field    as_accepted    account_id    42
    BIVA.Set Ouch Field    as_accepted    order_verb    B
    BIVA.Set Ouch Field    as_accepted    quantity    1000
    BIVA.Set Ouch Field    as_accepted    orderbook    1
    BIVA.Set Ouch Field    as_accepted    price    1234
    BIVA.Set Ouch Field    as_accepted    time_in_force    0
    BIVA.Set Ouch Field    as_accepted    client_id    1
    BIVA.Set Ouch Field    as_accepted    order_reference_number    10001
    BIVA.Set Ouch Field    as_accepted    minimum_quantity    0
    BIVA.Set Ouch Field    as_accepted    order_state    L
    BIVA.Send Server Message    session_a    as_accepted
    BIVA.Destroy Soup Message    as_accepted

    Comment    -> Replace Order

    BIVA.Create Soup Message    ac_replace    U
    BIVA.Set Ouch Type    ac_replace    U
    BIVA.Set Ouch Field    ac_replace    existing_order_token    1
    BIVA.Set Ouch Field    ac_replace    replacement_order_token    2
    BIVA.Set Ouch Field    ac_replace    quantity    2000
    BIVA.Set Ouch Field    ac_replace    price    1234
    BIVA.Send Client Message    client_a    ac_replace
    BIVA.Destroy Soup Message   ac_replace

    Comment    <- Order Replaced

    BIVA.Create Soup Message    as_replaced    S
    BIVA.Set Ouch Type    as_replaced    U
    BIVA.Set Ouch Field    as_replaced    timestamp    1002
    BIVA.Set Ouch Field    as_replaced    replacement_order_token    2
    BIVA.Set Ouch Field    as_replaced    order_verb    B
    BIVA.Set Ouch Field    as_replaced    quantity    2000
    BIVA.Set Ouch Field    as_replaced    orderbook    1
    BIVA.Set Ouch Field    as_replaced    price    1234
    BIVA.Set Ouch Field    as_replaced    order_reference_number    10002
    BIVA.Set Ouch Field    as_replaced    order_state    L
    BIVA.Set Ouch Field    as_replaced    previous_order_token    1
    BIVA.Send Server Message    session_a    as_replaced
    BIVA.Destroy Soup Message    as_replaced

    Comment    <- Order Executed

    BIVA.Create Soup Message    as_executed    S
    BIVA.Set Ouch Type    as_executed    E
    BIVA.Set Ouch Field    as_executed    timestamp    1003
    BIVA.Set Ouch Field    as_executed    order_token    2
    BIVA.Set Ouch Field    as_executed    executed_quantity    1000
    BIVA.Set Ouch Field    as_executed    executed_price    1234
    BIVA.Set Ouch Field    as_executed    liquidity_flag    R
    BIVA.Set Ouch Field    as_executed    match_number    1001
    BIVA.Set Ouch Field    as_executed    counter_party_id    12345
    BIVA.Send Server Message    session_a    as_executed
    BIVA.Destroy Soup Message    as_executed



    Comment    -> Enter Order

    BIVA.Create Soup Message    bc_enter    U
    BIVA.Set Ouch Type    bc_enter    O
    BIVA.Set Ouch Field    bc_enter    order_token    3
    BIVA.Set Ouch Field    bc_enter    account_type    C
    BIVA.Set Ouch Field    bc_enter    account_id    42
    BIVA.Set Ouch Field    bc_enter    order_verb    B
    BIVA.Set Ouch Field    bc_enter    quantity    3000
    BIVA.Set Ouch Field    bc_enter    orderbook    3
    BIVA.Set Ouch Field    bc_enter    price    1234
    BIVA.Set Ouch Field    bc_enter    time_in_force    0
    BIVA.Set Ouch Field    bc_enter    client_id    1
    BIVA.Set Ouch Field    bc_enter    minimum_quantity    500
    BIVA.Send Client Message    client_a    bc_enter
    BIVA.Destroy Soup Message    bc_enter

    Comment    <- Order Rejected

    BIVA.Create Soup Message    bs_rejected    S
    BIVA.Set Ouch Type    bs_rejected    J
    BIVA.Set Ouch Field    bs_rejected    timestamp    2001
    BIVA.Set Ouch Field    bs_rejected    order_token    3
    BIVA.Set Ouch Field    bs_rejected    reason    W
    BIVA.Send Server Message    session_a    bs_rejected
    BIVA.Destroy Soup Message    bs_rejected



    Comment    -> Enter Order

    BIVA.Create Soup Message    cc_enter    U
    BIVA.Set Ouch Type    cc_enter    O
    BIVA.Set Ouch Field    cc_enter    order_token    4
    BIVA.Set Ouch Field    cc_enter    account_type    C
    BIVA.Set Ouch Field    cc_enter    account_id    42
    BIVA.Set Ouch Field    cc_enter    order_verb    B
    BIVA.Set Ouch Field    cc_enter    quantity    4000
    BIVA.Set Ouch Field    cc_enter    orderbook    3
    BIVA.Set Ouch Field    cc_enter    price    1234
    BIVA.Set Ouch Field    cc_enter    time_in_force    0
    BIVA.Set Ouch Field    cc_enter    client_id    1
    BIVA.Set Ouch Field    cc_enter    minimum_quantity    500
    BIVA.Send Client Message    client_a    cc_enter
    BIVA.Destroy Soup Message    cc_enter

    Comment    <- Order Accepted

    BIVA.Create Soup Message    cs_accepted    S
    BIVA.Set Ouch Type    cs_accepted    A
    BIVA.Set Ouch Field    cs_accepted    timestamp    4001
    BIVA.Set Ouch Field    cs_accepted    order_token    4
    BIVA.Set Ouch Field    cs_accepted    account_type    C
    BIVA.Set Ouch Field    cs_accepted    account_id    42
    BIVA.Set Ouch Field    cs_accepted    order_verb    B
    BIVA.Set Ouch Field    cs_accepted    quantity    4000
    BIVA.Set Ouch Field    cs_accepted    orderbook    1
    BIVA.Set Ouch Field    cs_accepted    price    1234
    BIVA.Set Ouch Field    cs_accepted    time_in_force    0
    BIVA.Set Ouch Field    cs_accepted    client_id    1
    BIVA.Set Ouch Field    cs_accepted    order_reference_number    40001
    BIVA.Set Ouch Field    cs_accepted    minimum_quantity    500
    BIVA.Set Ouch Field    cs_accepted    order_state    L
    BIVA.Send Server Message    session_a    cs_accepted
    BIVA.Destroy Soup Message    cs_accepted

    Comment    -> Cancel Order

    BIVA.Create Soup Message    cc_cancel    U
    BIVA.Set Ouch Type    cc_cancel    X
    BIVA.Set Ouch Field    cc_cancel    order_token    4
    BIVA.Send Client Message    client_a    cc_cancel
    BIVA.Destroy Soup Message    cc_cancel

    Comment    <- Order Cancelled

    BIVA.Create Soup Message    cs_canceled    S
    BIVA.Set Ouch Type    cs_canceled    C
    BIVA.Set Ouch Field    cs_canceled    timestamp    4002
    BIVA.Set Ouch Field    cs_canceled    order_token    4
    BIVA.Set Ouch Field    cs_canceled    reason    U
    BIVA.Send Server Message    session_a    cs_canceled
    BIVA.Destroy Soup Message    cs_canceled


    Comment    -> Logout

    BIVA.Create Soup Message    tc_logout    O
    BIVA.Send Client Message    client_a    tc_logout


    BIVA.Disconnect Server Session    session_a
    BIVA.Disconnect Client    client_a
    BIVA.Destroy Client    client_a
