*** Settings ***
Library           Remote    http://localhost:${OUCH_PORT}    WITH NAME    ASX

*** Test Cases ***
Certification Workflow
    [Setup]    ASX.Reset
    ASX.Create Server    server_a    44001    4.2
    ASX.Create Client    client_a    localhost    44001    4.2
    ASX.Server Start Listening    server_a
    ASX.Connect Client    client_a
    Wait Until Keyword Succeeds    5s    1s   ASX.Server Has New Session    server_a
    ASX.Get New Server Session    server_a    session_a



    Comment    Send Login

    ASX.Create Soup Message    c_login_a    L
    ASX.Set Soup Field    c_login_a    username    user01
    ASX.Set Soup Field    c_login_a    password    password
    ASX.Send Client Message    client_a    c_login_a

    Comment    Send LoginRejected

    ASX.Create Soup Message    s_loginrej_a    J
    ASX.Set Soup Field    s_loginrej_a    reject_reason_code    S
    ASX.Send Server Message    session_a    s_loginrej_a



    Comment    Send Login

    ASX.Create Soup Message    c_login_b    L
    ASX.Set Soup Field    c_login_b    username    user01
    ASX.Set Soup Field    c_login_b    password    password
    ASX.Send Client Message    client_a    c_login_b

    Comment    Send LoginAccepted

    ASX.Create Soup Message    s_loginack_b    A
    ASX.Set Soup Field    s_loginack_b    session    SESS0001
    ASX.Set Soup Field    s_loginack_b    sequence_number    0
    ASX.Send Server Message    session_a    s_loginack_b



    Comment    -> Enter Order

    ASX.Create Soup Message    ac_enter    U
    ASX.Set Ouch Type    ac_enter    O
    ASX.Set Ouch Field    ac_enter    order_token    TEST_A1
    ASX.Set Ouch Field    ac_enter    order_book_id    42
    ASX.Set Ouch Field    ac_enter    side    B
    ASX.Set Ouch Field    ac_enter    quantity    1000
    ASX.Set Ouch Field    ac_enter    price    1234
    ASX.Set Ouch Field    ac_enter    time_in_force    0
    ASX.Set Ouch Field    ac_enter    open_close    0
    ASX.Set Ouch Field    ac_enter    client_account    CLIENT_ACCT
    ASX.Set Ouch Field    ac_enter    customer_info    CUST_INFO
    ASX.Set Ouch Field    ac_enter    exchange_info    EXCG_INFO
    ASX.Set Ouch Field    ac_enter    clearing_participant    P
    ASX.Set Ouch Field    ac_enter    crossing_key    1001
    ASX.Set Ouch Field    ac_enter    capacity    A
    ASX.Set Ouch Field    ac_enter    directed_wholesale    N
    ASX.Set Ouch Field    ac_enter    intermediary_id    INTERMED_ID
    ASX.Set Ouch Field    ac_enter    order_origin    ORDER_ORIGIN
    ASX.Set Ouch Field    ac_enter    order_type    A
    ASX.Set Ouch Field    ac_enter    short_sell_quantity    0
    ASX.Set Ouch Field    ac_enter    minimum_acceptable_quantity    0
    ASX.Send Client Message    client_a    ac_enter

    Comment    <- Order Accepted

    ASX.Create Soup Message    as_accepted    S
    ASX.Set Ouch Type    as_accepted    A
    ASX.Set Ouch Field    as_accepted    timestamp    1001
    ASX.Set Ouch Field    as_accepted    order_token    TEST_A1
    ASX.Set Ouch Field    as_accepted    order_book_id    42
    ASX.Set Ouch Field    as_accepted    side    B
    ASX.Set Ouch Field    as_accepted    order_id    421001
    ASX.Set Ouch Field    as_accepted    quantity    1000
    ASX.Set Ouch Field    as_accepted    price    1234
    ASX.Set Ouch Field    as_accepted    time_in_force    0
    ASX.Set Ouch Field    as_accepted    open_close    0
    ASX.Set Ouch Field    as_accepted    client_account    CLIENT_ACCT
    ASX.Set Ouch Field    as_accepted    order_state    1
    ASX.Set Ouch Field    as_accepted    customer_info    CUST_INFO
    ASX.Set Ouch Field    as_accepted    exchange_info    EXCG_INFO
    ASX.Set Ouch Field    as_accepted    clearing_participant    P
    ASX.Set Ouch Field    as_accepted    crossing_key    1001
    ASX.Set Ouch Field    as_accepted    capacity    A
    ASX.Set Ouch Field    as_accepted    directed_wholesale    N
    ASX.Set Ouch Field    as_accepted    intermediary_id    INTERMED_ID
    ASX.Set Ouch Field    as_accepted    order_origin    ORDER_ORIGIN
    ASX.Set Ouch Field    as_accepted    order_type    A
    ASX.Set Ouch Field    as_accepted    short_sell_quantity    0
    ASX.Set Ouch Field    as_accepted    minimum_acceptable_quantity    0
    ASX.Send Server Message    session_a    as_accepted

    Comment    -> Replace Order

    Comment    <- Order Replaced

    Comment    <- Order Executed


    Comment    -> Enter Order

    ASX.Create Soup Message    bc_enter    U
    ASX.Set Ouch Type    bc_enter    O
    ASX.Set Ouch Field    bc_enter    order_token    TEST_B1
    ASX.Set Ouch Field    bc_enter    order_book_id    42
    ASX.Set Ouch Field    bc_enter    side    B
    ASX.Set Ouch Field    bc_enter    quantity    1000
    ASX.Set Ouch Field    bc_enter    price    1234
    ASX.Set Ouch Field    bc_enter    time_in_force    0
    ASX.Set Ouch Field    bc_enter    open_close    0
    ASX.Set Ouch Field    bc_enter    client_account    CLIENT_ACCT
    ASX.Set Ouch Field    bc_enter    customer_info    CUST_INFO
    ASX.Set Ouch Field    bc_enter    exchange_info    EXCG_INFO
    ASX.Set Ouch Field    bc_enter    clearing_participant    P
    ASX.Set Ouch Field    bc_enter    crossing_key    2001
    ASX.Set Ouch Field    bc_enter    capacity    A
    ASX.Set Ouch Field    bc_enter    directed_wholesale    N
    ASX.Set Ouch Field    bc_enter    intermediary_id    INTERMED_ID
    ASX.Set Ouch Field    bc_enter    order_origin    ORDER_ORIGIN
    ASX.Set Ouch Field    bc_enter    order_type    A
    ASX.Set Ouch Field    bc_enter    short_sell_quantity    0
    ASX.Set Ouch Field    bc_enter    minimum_acceptable_quantity    0
    ASX.Send Client Message    client_a    bc_enter

    Comment    <- Order Rejected

    ASX.Create Soup Message    bs_rejected    S
    ASX.Set Ouch Type    bs_rejected    J
    ASX.Set Ouch Field    bs_rejected    timestamp    2001
    ASX.Set Ouch Field    bs_rejected    order_token    TEST_B1
    ASX.Set Ouch Field    bs_rejected    reject_code    42
    ASX.Send Server Message    session_a    bs_rejected
    ASX.Destroy Soup Message    bs_rejected


    Comment    -> Enter Order
    Comment    <- Order Accepted
    Comment    -> Cancel Order
    Comment    <- Order Cancelled

    Comment    -> Enter Order
    Comment    <- Order Accepted
    Comment    -> Cancel By OrderID
    Comment    <- Order Cancelled



    Comment    -> Logout

    ASX.Create Soup Message    tc_logout    O
    ASX.Send Client Message    client_a    tc_logout


    ASX.Disconnect Server Session    session_a
    ASX.Disconnect Client    client_a
    ASX.Destroy Client    client_a
