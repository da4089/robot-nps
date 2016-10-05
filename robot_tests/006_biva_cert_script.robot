*** Settings ***
Library           Remote    http://localhost:${OUCH_PORT}    WITH NAME    BIVA

*** Test Cases ***
Certification Workflow
    [Setup]    BIVA.Reset
    BIVA.Create Server    server_a    44002    x
    BIVA.Create Client    client_a    localhost    44002    x
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
    BIVA.Set Ouch Field    as_accepted    order_token    TEST_A1
    BIVA.Set Ouch Field    as_accepted    order_book_id    42
    BIVA.Set Ouch Field    as_accepted    side    B
    BIVA.Set Ouch Field    as_accepted    order_id    421001
    BIVA.Set Ouch Field    as_accepted    quantity    1000
    BIVA.Set Ouch Field    as_accepted    price    1234
    BIVA.Set Ouch Field    as_accepted    time_in_force    0
    BIVA.Set Ouch Field    as_accepted    open_close    0
    BIVA.Set Ouch Field    as_accepted    client_account    CLIENT_ACCT
    BIVA.Set Ouch Field    as_accepted    order_state    1
    BIVA.Set Ouch Field    as_accepted    customer_info    CUST_INFO
    BIVA.Set Ouch Field    as_accepted    exchange_info    EXCG_INFO
    BIVA.Set Ouch Field    as_accepted    clearing_participant    P
    BIVA.Set Ouch Field    as_accepted    crossing_key    1001
    BIVA.Set Ouch Field    as_accepted    capacity    A
    BIVA.Set Ouch Field    as_accepted    directed_wholesale    N
    BIVA.Set Ouch Field    as_accepted    intermediary_id    INTERMED_ID
    BIVA.Set Ouch Field    as_accepted    order_origin    ORDER_ORIGIN
    BIVA.Set Ouch Field    as_accepted    order_type    A
    BIVA.Set Ouch Field    as_accepted    short_sell_quantity    0
    BIVA.Set Ouch Field    as_accepted    minimum_acceptable_quantity    0
    BIVA.Send Server Message    session_a    as_accepted
    BIVA.Destroy Soup Message    as_accepted

    Comment    -> Replace Order

    BIVA.Create Soup Message    ac_replace    U
    BIVA.Set Ouch Type    ac_replace    U
    BIVA.Set Ouch Field    ac_replace    existing_order_token    TEST_A1
    BIVA.Set Ouch Field    ac_replace    replacement_order_token    TEST_A2
    BIVA.Set Ouch Field    ac_replace    quantity    1000
    BIVA.Set Ouch Field    ac_replace    price    1234
    BIVA.Set Ouch Field    ac_replace    open_close    0
    BIVA.Set Ouch Field    ac_replace    client_account    CLIENT_ACCT
    BIVA.Set Ouch Field    ac_replace    customer_info    CUST_INFO
    BIVA.Set Ouch Field    ac_replace    exchange_info    EXCG_INFO
    BIVA.Set Ouch Field    ac_replace    capacity    A
    BIVA.Set Ouch Field    ac_replace    directed_wholesale    N
    BIVA.Set Ouch Field    ac_replace    intermediary_id    INTERMED_ID
    BIVA.Set Ouch Field    ac_replace    order_origin    ORDER_ORIGIN
    BIVA.Set Ouch Field    ac_replace    short_sell_quantity    0
    BIVA.Set Ouch Field    ac_replace    minimum_acceptable_quantity    0
    BIVA.Send Client Message    client_a    ac_replace
    BIVA.Destroy Soup Message   ac_replace

    Comment    <- Order Replaced

    BIVA.Create Soup Message    as_replaced    S
    BIVA.Set Ouch Type    as_replaced    U
    BIVA.Set Ouch Field    as_replaced    timestamp    1002
    BIVA.Set Ouch Field    as_replaced    replacement_order_token    TEST_A2
    BIVA.Set Ouch Field    as_replaced    previous_order_token    TEST_A1
    BIVA.Set Ouch Field    as_replaced    order_book_id    42
    BIVA.Set Ouch Field    as_replaced    side    B
    BIVA.Set Ouch Field    as_replaced    order_id    421001
    BIVA.Set Ouch Field    as_replaced    quantity    1000
    BIVA.Set Ouch Field    as_replaced    price    1234
    BIVA.Set Ouch Field    as_replaced    time_in_force    0
    BIVA.Set Ouch Field    as_replaced    open_close    0
    BIVA.Set Ouch Field    as_replaced    client_account    CLIENT_ACCT
    BIVA.Set Ouch Field    as_replaced    order_state    1
    BIVA.Set Ouch Field    as_replaced    customer_info    CUST_INFO
    BIVA.Set Ouch Field    as_replaced    exchange_info    EXCG_INFO
    BIVA.Set Ouch Field    as_replaced    clearing_participant    P
    BIVA.Set Ouch Field    as_replaced    crossing_key    1001
    BIVA.Set Ouch Field    as_replaced    capacity    A
    BIVA.Set Ouch Field    as_replaced    directed_wholesale    N
    BIVA.Set Ouch Field    as_replaced    intermediary_id    INTERMED_ID
    BIVA.Set Ouch Field    as_replaced    order_origin    ORDER_ORIGIN
    BIVA.Set Ouch Field    as_replaced    order_type    A
    BIVA.Set Ouch Field    as_replaced    short_sell_quantity    0
    BIVA.Set Ouch Field    as_replaced    minimum_acceptable_quantity    0
    BIVA.Send Server Message    session_a    as_replaced
    BIVA.Destroy Soup Message    as_replaced

    Comment    <- Order Executed

    BIVA.Create Soup Message    as_executed    S
    BIVA.Set Ouch Type    as_executed    E
    BIVA.Set Ouch Field    as_executed    timestamp    1003
    BIVA.Set Ouch Field    as_executed    order_token    TEST_A2
    BIVA.Set Ouch Field    as_executed    order_book_id    42
    BIVA.Set Ouch Field    as_executed    traded_quantity    1000
    BIVA.Set Ouch Field    as_executed    trade_price    1234
    BIVA.Set Ouch Field    as_executed    match_id    1001
    BIVA.Set Ouch Field    as_executed    deal_source    1
    BIVA.Set Ouch Field    as_executed    match_attributes    3
    BIVA.Send Server Message    session_a    as_executed
    BIVA.Destroy Soup Message    as_executed



    Comment    -> Enter Order

    BIVA.Create Soup Message    bc_enter    U
    BIVA.Set Ouch Type    bc_enter    O
    BIVA.Set Ouch Field    bc_enter    order_token    TEST_B1
    BIVA.Set Ouch Field    bc_enter    order_book_id    42
    BIVA.Set Ouch Field    bc_enter    side    B
    BIVA.Set Ouch Field    bc_enter    quantity    1000
    BIVA.Set Ouch Field    bc_enter    price    1234
    BIVA.Set Ouch Field    bc_enter    time_in_force    0
    BIVA.Set Ouch Field    bc_enter    open_close    0
    BIVA.Set Ouch Field    bc_enter    client_account    CLIENT_ACCT
    BIVA.Set Ouch Field    bc_enter    customer_info    CUST_INFO
    BIVA.Set Ouch Field    bc_enter    exchange_info    EXCG_INFO
    BIVA.Set Ouch Field    bc_enter    clearing_participant    P
    BIVA.Set Ouch Field    bc_enter    crossing_key    2001
    BIVA.Set Ouch Field    bc_enter    capacity    A
    BIVA.Set Ouch Field    bc_enter    directed_wholesale    N
    BIVA.Set Ouch Field    bc_enter    intermediary_id    INTERMED_ID
    BIVA.Set Ouch Field    bc_enter    order_origin    ORDER_ORIGIN
    BIVA.Set Ouch Field    bc_enter    order_type    A
    BIVA.Set Ouch Field    bc_enter    short_sell_quantity    0
    BIVA.Set Ouch Field    bc_enter    minimum_acceptable_quantity    0
    BIVA.Send Client Message    client_a    bc_enter
    BIVA.Destroy Soup Message    bc_enter

    Comment    <- Order Rejected

    BIVA.Create Soup Message    bs_rejected    S
    BIVA.Set Ouch Type    bs_rejected    J
    BIVA.Set Ouch Field    bs_rejected    timestamp    2001
    BIVA.Set Ouch Field    bs_rejected    order_token    TEST_B1
    BIVA.Set Ouch Field    bs_rejected    reject_code    42
    BIVA.Send Server Message    session_a    bs_rejected
    BIVA.Destroy Soup Message    bs_rejected



    Comment    -> Enter Order

    BIVA.Create Soup Message    cc_enter    U
    BIVA.Set Ouch Type    cc_enter    O
    BIVA.Set Ouch Field    cc_enter    order_token    TEST_C1
    BIVA.Set Ouch Field    cc_enter    order_book_id    42
    BIVA.Set Ouch Field    cc_enter    side    B
    BIVA.Set Ouch Field    cc_enter    quantity    1000
    BIVA.Set Ouch Field    cc_enter    price    1234
    BIVA.Set Ouch Field    cc_enter    time_in_force    0
    BIVA.Set Ouch Field    cc_enter    open_close    0
    BIVA.Set Ouch Field    cc_enter    client_account    CLIENT_ACCT
    BIVA.Set Ouch Field    cc_enter    customer_info    CUST_INFO
    BIVA.Set Ouch Field    cc_enter    exchange_info    EXCG_INFO
    BIVA.Set Ouch Field    cc_enter    clearing_participant    P
    BIVA.Set Ouch Field    cc_enter    crossing_key    3001
    BIVA.Set Ouch Field    cc_enter    capacity    A
    BIVA.Set Ouch Field    cc_enter    directed_wholesale    N
    BIVA.Set Ouch Field    cc_enter    intermediary_id    INTERMED_ID
    BIVA.Set Ouch Field    cc_enter    order_origin    ORDER_ORIGIN
    BIVA.Set Ouch Field    cc_enter    order_type    A
    BIVA.Set Ouch Field    cc_enter    short_sell_quantity    0
    BIVA.Set Ouch Field    cc_enter    minimum_acceptable_quantity    0
    BIVA.Send Client Message    client_a    cc_enter
    BIVA.Destroy Soup Message    cc_enter

    Comment    <- Order Accepted

    BIVA.Create Soup Message    cs_accepted    S
    BIVA.Set Ouch Type    cs_accepted    A
    BIVA.Set Ouch Field    cs_accepted    timestamp    3001
    BIVA.Set Ouch Field    cs_accepted    order_token    TEST_C1
    BIVA.Set Ouch Field    cs_accepted    order_book_id    42
    BIVA.Set Ouch Field    cs_accepted    side    B
    BIVA.Set Ouch Field    cs_accepted    order_id    423001
    BIVA.Set Ouch Field    cs_accepted    quantity    1000
    BIVA.Set Ouch Field    cs_accepted    price    1234
    BIVA.Set Ouch Field    cs_accepted    time_in_force    0
    BIVA.Set Ouch Field    cs_accepted    open_close    0
    BIVA.Set Ouch Field    cs_accepted    client_account    CLIENT_ACCT
    BIVA.Set Ouch Field    cs_accepted    order_state    1
    BIVA.Set Ouch Field    cs_accepted    customer_info    CUST_INFO
    BIVA.Set Ouch Field    cs_accepted    exchange_info    EXCG_INFO
    BIVA.Set Ouch Field    cs_accepted    clearing_participant    P
    BIVA.Set Ouch Field    cs_accepted    crossing_key    3001
    BIVA.Set Ouch Field    cs_accepted    capacity    A
    BIVA.Set Ouch Field    cs_accepted    directed_wholesale    N
    BIVA.Set Ouch Field    cs_accepted    intermediary_id    INTERMED_ID
    BIVA.Set Ouch Field    cs_accepted    order_origin    ORDER_ORIGIN
    BIVA.Set Ouch Field    cs_accepted    order_type    A
    BIVA.Set Ouch Field    cs_accepted    short_sell_quantity    0
    BIVA.Set Ouch Field    cs_accepted    minimum_acceptable_quantity    0
    BIVA.Send Server Message    session_a    cs_accepted
    BIVA.Destroy Soup Message    cs_accepted

    Comment    -> Cancel Order

    BIVA.Create Soup Message    cc_cancel    U
    BIVA.Set Ouch Type    cc_cancel    X
    BIVA.Set Ouch Field    cc_cancel    order_token    TEST_C1
    BIVA.Send Client Message    client_a    cc_cancel
    BIVA.Destroy Soup Message    cc_cancel

    Comment    <- Order Cancelled

    BIVA.Create Soup Message    cs_canceled    S
    BIVA.Set Ouch Type    cs_canceled    C
    BIVA.Set Ouch Field    cs_canceled    timestamp    3002
    BIVA.Set Ouch Field    cs_canceled    order_token    TEST_C1
    BIVA.Set Ouch Field    cs_canceled    order_book_id    42
    BIVA.Set Ouch Field    cs_canceled    side    B
    BIVA.Set Ouch Field    cs_canceled    order_id    423001
    BIVA.Set Ouch Field    cs_canceled    reason    1
    BIVA.Send Server Message    session_a    cs_canceled
    BIVA.Destroy Soup Message    cs_canceled



    Comment    -> Enter Order

    BIVA.Create Soup Message    dc_enter    U
    BIVA.Set Ouch Type    dc_enter    O
    BIVA.Set Ouch Field    dc_enter    order_token    TEST_D1
    BIVA.Set Ouch Field    dc_enter    order_book_id    42
    BIVA.Set Ouch Field    dc_enter    side    B
    BIVA.Set Ouch Field    dc_enter    quantity    1000
    BIVA.Set Ouch Field    dc_enter    price    1234
    BIVA.Set Ouch Field    dc_enter    time_in_force    0
    BIVA.Set Ouch Field    dc_enter    open_close    0
    BIVA.Set Ouch Field    dc_enter    client_account    CLIENT_ACCT
    BIVA.Set Ouch Field    dc_enter    customer_info    CUST_INFO
    BIVA.Set Ouch Field    dc_enter    exchange_info    EXCG_INFO
    BIVA.Set Ouch Field    dc_enter    clearing_participant    P
    BIVA.Set Ouch Field    dc_enter    crossing_key    4001
    BIVA.Set Ouch Field    dc_enter    capacity    A
    BIVA.Set Ouch Field    dc_enter    directed_wholesale    N
    BIVA.Set Ouch Field    dc_enter    intermediary_id    INTERMED_ID
    BIVA.Set Ouch Field    dc_enter    order_origin    ORDER_ORIGIN
    BIVA.Set Ouch Field    dc_enter    order_type    A
    BIVA.Set Ouch Field    dc_enter    short_sell_quantity    0
    BIVA.Set Ouch Field    dc_enter    minimum_acceptable_quantity    0
    BIVA.Send Client Message    client_a    dc_enter
    BIVA.Destroy Soup Message    dc_enter

    Comment    <- Order Accepted

    BIVA.Create Soup Message    ds_accepted    S
    BIVA.Set Ouch Type    ds_accepted    A
    BIVA.Set Ouch Field    ds_accepted    timestamp    4001
    BIVA.Set Ouch Field    ds_accepted    order_token    TEST_D1
    BIVA.Set Ouch Field    ds_accepted    order_book_id    42
    BIVA.Set Ouch Field    ds_accepted    side    B
    BIVA.Set Ouch Field    ds_accepted    order_id    424001
    BIVA.Set Ouch Field    ds_accepted    quantity    1000
    BIVA.Set Ouch Field    ds_accepted    price    1234
    BIVA.Set Ouch Field    ds_accepted    time_in_force    0
    BIVA.Set Ouch Field    ds_accepted    open_close    0
    BIVA.Set Ouch Field    ds_accepted    client_account    CLIENT_ACCT
    BIVA.Set Ouch Field    ds_accepted    order_state    1
    BIVA.Set Ouch Field    ds_accepted    customer_info    CUST_INFO
    BIVA.Set Ouch Field    ds_accepted    exchange_info    EXCG_INFO
    BIVA.Set Ouch Field    ds_accepted    clearing_participant    P
    BIVA.Set Ouch Field    ds_accepted    crossing_key    4001
    BIVA.Set Ouch Field    ds_accepted    capacity    A
    BIVA.Set Ouch Field    ds_accepted    directed_wholesale    N
    BIVA.Set Ouch Field    ds_accepted    intermediary_id    INTERMED_ID
    BIVA.Set Ouch Field    ds_accepted    order_origin    ORDER_ORIGIN
    BIVA.Set Ouch Field    ds_accepted    order_type    A
    BIVA.Set Ouch Field    ds_accepted    short_sell_quantity    0
    BIVA.Set Ouch Field    ds_accepted    minimum_acceptable_quantity    0
    BIVA.Send Server Message    session_a    ds_accepted
    BIVA.Destroy Soup Message    ds_accepted

    Comment    -> Cancel By OrderID

    BIVA.Create Soup Message    dc_cancelbyid    U
    BIVA.Set Ouch Type    dc_cancelbyid    Y
    BIVA.Set Ouch Field    dc_cancelbyid    order_book_id    42
    BIVA.Set Ouch Field    dc_cancelbyid    side    B
    BIVA.Set Ouch Field    dc_cancelbyid    order_id    424001
    BIVA.Send Client Message    client_a    dc_cancelbyid
    BIVA.Destroy Soup Message    dc_cancelbyid

    Comment    <- Order Cancelled

    BIVA.Create Soup Message    ds_canceled    S
    BIVA.Set Ouch Type    ds_canceled    C
    BIVA.Set Ouch Field    ds_canceled    timestamp    3002
    BIVA.Set Ouch Field    ds_canceled    order_token    TEST_C1
    BIVA.Set Ouch Field    ds_canceled    order_book_id    42
    BIVA.Set Ouch Field    ds_canceled    side    B
    BIVA.Set Ouch Field    ds_canceled    order_id    423001
    BIVA.Set Ouch Field    ds_canceled    reason    1
    BIVA.Send Server Message    session_a    ds_canceled
    BIVA.Destroy Soup Message    ds_canceled



    Comment    -> Logout

    BIVA.Create Soup Message    tc_logout    O
    BIVA.Send Client Message    client_a    tc_logout


    BIVA.Disconnect Server Session    session_a
    BIVA.Disconnect Client    client_a
    BIVA.Destroy Client    client_a
