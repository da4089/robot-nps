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
    ASX.Destroy Soup Message    ac_enter

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
    ASX.Destroy Soup Message    as_accepted

    Comment    -> Replace Order

    ASX.Create Soup Message    ac_replace    U
    ASX.Set Ouch Type    ac_replace    U
    ASX.Set Ouch Field    ac_replace    existing_order_token    TEST_A1
    ASX.Set Ouch Field    ac_replace    replacement_order_token    TEST_A2
    ASX.Set Ouch Field    ac_replace    quantity    1000
    ASX.Set Ouch Field    ac_replace    price    1234
    ASX.Set Ouch Field    ac_replace    open_close    0
    ASX.Set Ouch Field    ac_replace    client_account    CLIENT_ACCT
    ASX.Set Ouch Field    ac_replace    customer_info    CUST_INFO
    ASX.Set Ouch Field    ac_replace    exchange_info    EXCG_INFO
    ASX.Set Ouch Field    ac_replace    capacity    A
    ASX.Set Ouch Field    ac_replace    directed_wholesale    N
    ASX.Set Ouch Field    ac_replace    intermediary_id    INTERMED_ID
    ASX.Set Ouch Field    ac_replace    order_origin    ORDER_ORIGIN
    ASX.Set Ouch Field    ac_replace    short_sell_quantity    0
    ASX.Set Ouch Field    ac_replace    minimum_acceptable_quantity    0
    ASX.Send Client Message    client_a    ac_replace
    ASX.Destroy Soup Message   ac_replace

    Comment    <- Order Replaced

    ASX.Create Soup Message    as_replaced    S
    ASX.Set Ouch Type    as_replaced    U
    ASX.Set Ouch Field    as_replaced    timestamp    1002
    ASX.Set Ouch Field    as_replaced    replacement_order_token    TEST_A2
    ASX.Set Ouch Field    as_replaced    previous_order_token    TEST_A1
    ASX.Set Ouch Field    as_replaced    order_book_id    42
    ASX.Set Ouch Field    as_replaced    side    B
    ASX.Set Ouch Field    as_replaced    order_id    421001
    ASX.Set Ouch Field    as_replaced    quantity    1000
    ASX.Set Ouch Field    as_replaced    price    1234
    ASX.Set Ouch Field    as_replaced    time_in_force    0
    ASX.Set Ouch Field    as_replaced    open_close    0
    ASX.Set Ouch Field    as_replaced    client_account    CLIENT_ACCT
    ASX.Set Ouch Field    as_replaced    order_state    1
    ASX.Set Ouch Field    as_replaced    customer_info    CUST_INFO
    ASX.Set Ouch Field    as_replaced    exchange_info    EXCG_INFO
    ASX.Set Ouch Field    as_replaced    clearing_participant    P
    ASX.Set Ouch Field    as_replaced    crossing_key    1001
    ASX.Set Ouch Field    as_replaced    capacity    A
    ASX.Set Ouch Field    as_replaced    directed_wholesale    N
    ASX.Set Ouch Field    as_replaced    intermediary_id    INTERMED_ID
    ASX.Set Ouch Field    as_replaced    order_origin    ORDER_ORIGIN
    ASX.Set Ouch Field    as_replaced    order_type    A
    ASX.Set Ouch Field    as_replaced    short_sell_quantity    0
    ASX.Set Ouch Field    as_replaced    minimum_acceptable_quantity    0
    ASX.Send Server Message    session_a    as_replaced
    ASX.Destroy Soup Message    as_replaced

    Comment    <- Order Executed

    ASX.Create Soup Message    as_executed    S
    ASX.Set Ouch Type    as_executed    E
    ASX.Set Ouch Field    as_executed    timestamp    1003
    ASX.Set Ouch Field    as_executed    order_token    TEST_A2
    ASX.Set Ouch Field    as_executed    order_book_id    42
    ASX.Set Ouch Field    as_executed    traded_quantity    1000
    ASX.Set Ouch Field    as_executed    trade_price    1234
    ASX.Set Ouch Field    as_executed    match_id    1001
    ASX.Set Ouch Field    as_executed    deal_source    1
    ASX.Set Ouch Field    as_executed    match_attributes    3
    ASX.Send Server Message    session_a    as_executed
    ASX.Destroy Soup Message    as_executed



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
    ASX.Destroy Soup Message    bc_enter

    Comment    <- Order Rejected

    ASX.Create Soup Message    bs_rejected    S
    ASX.Set Ouch Type    bs_rejected    J
    ASX.Set Ouch Field    bs_rejected    timestamp    2001
    ASX.Set Ouch Field    bs_rejected    order_token    TEST_B1
    ASX.Set Ouch Field    bs_rejected    reject_code    42
    ASX.Send Server Message    session_a    bs_rejected
    ASX.Destroy Soup Message    bs_rejected



    Comment    -> Enter Order

    ASX.Create Soup Message    cc_enter    U
    ASX.Set Ouch Type    cc_enter    O
    ASX.Set Ouch Field    cc_enter    order_token    TEST_C1
    ASX.Set Ouch Field    cc_enter    order_book_id    42
    ASX.Set Ouch Field    cc_enter    side    B
    ASX.Set Ouch Field    cc_enter    quantity    1000
    ASX.Set Ouch Field    cc_enter    price    1234
    ASX.Set Ouch Field    cc_enter    time_in_force    0
    ASX.Set Ouch Field    cc_enter    open_close    0
    ASX.Set Ouch Field    cc_enter    client_account    CLIENT_ACCT
    ASX.Set Ouch Field    cc_enter    customer_info    CUST_INFO
    ASX.Set Ouch Field    cc_enter    exchange_info    EXCG_INFO
    ASX.Set Ouch Field    cc_enter    clearing_participant    P
    ASX.Set Ouch Field    cc_enter    crossing_key    3001
    ASX.Set Ouch Field    cc_enter    capacity    A
    ASX.Set Ouch Field    cc_enter    directed_wholesale    N
    ASX.Set Ouch Field    cc_enter    intermediary_id    INTERMED_ID
    ASX.Set Ouch Field    cc_enter    order_origin    ORDER_ORIGIN
    ASX.Set Ouch Field    cc_enter    order_type    A
    ASX.Set Ouch Field    cc_enter    short_sell_quantity    0
    ASX.Set Ouch Field    cc_enter    minimum_acceptable_quantity    0
    ASX.Send Client Message    client_a    cc_enter
    ASX.Destroy Soup Message    cc_enter

    Comment    <- Order Accepted

    ASX.Create Soup Message    cs_accepted    S
    ASX.Set Ouch Type    cs_accepted    A
    ASX.Set Ouch Field    cs_accepted    timestamp    3001
    ASX.Set Ouch Field    cs_accepted    order_token    TEST_C1
    ASX.Set Ouch Field    cs_accepted    order_book_id    42
    ASX.Set Ouch Field    cs_accepted    side    B
    ASX.Set Ouch Field    cs_accepted    order_id    423001
    ASX.Set Ouch Field    cs_accepted    quantity    1000
    ASX.Set Ouch Field    cs_accepted    price    1234
    ASX.Set Ouch Field    cs_accepted    time_in_force    0
    ASX.Set Ouch Field    cs_accepted    open_close    0
    ASX.Set Ouch Field    cs_accepted    client_account    CLIENT_ACCT
    ASX.Set Ouch Field    cs_accepted    order_state    1
    ASX.Set Ouch Field    cs_accepted    customer_info    CUST_INFO
    ASX.Set Ouch Field    cs_accepted    exchange_info    EXCG_INFO
    ASX.Set Ouch Field    cs_accepted    clearing_participant    P
    ASX.Set Ouch Field    cs_accepted    crossing_key    3001
    ASX.Set Ouch Field    cs_accepted    capacity    A
    ASX.Set Ouch Field    cs_accepted    directed_wholesale    N
    ASX.Set Ouch Field    cs_accepted    intermediary_id    INTERMED_ID
    ASX.Set Ouch Field    cs_accepted    order_origin    ORDER_ORIGIN
    ASX.Set Ouch Field    cs_accepted    order_type    A
    ASX.Set Ouch Field    cs_accepted    short_sell_quantity    0
    ASX.Set Ouch Field    cs_accepted    minimum_acceptable_quantity    0
    ASX.Send Server Message    session_a    cs_accepted
    ASX.Destroy Soup Message    cs_accepted

    Comment    -> Cancel Order

    ASX.Create Soup Message    cc_cancel    U
    ASX.Set Ouch Type    cc_cancel    X
    ASX.Set Ouch Field    cc_cancel    order_token    TEST_C1
    ASX.Send Client Message    client_a    cc_cancel
    ASX.Destroy Soup Message    cc_cancel

    Comment    <- Order Cancelled

    ASX.Create Soup Message    cs_canceled    S
    ASX.Set Ouch Type    cs_canceled    C
    ASX.Set Ouch Field    cs_canceled    timestamp    3002
    ASX.Set Ouch Field    cs_canceled    order_token    TEST_C1
    ASX.Set Ouch Field    cs_canceled    order_book_id    42
    ASX.Set Ouch Field    cs_canceled    side    B
    ASX.Set Ouch Field    cs_canceled    order_id    423001
    ASX.Set Ouch Field    cs_canceled    reason    1
    ASX.Send Server Message    session_a    cs_canceled
    ASX.Destroy Soup Message    cs_canceled



    Comment    -> Enter Order

    ASX.Create Soup Message    dc_enter    U
    ASX.Set Ouch Type    dc_enter    O
    ASX.Set Ouch Field    dc_enter    order_token    TEST_D1
    ASX.Set Ouch Field    dc_enter    order_book_id    42
    ASX.Set Ouch Field    dc_enter    side    B
    ASX.Set Ouch Field    dc_enter    quantity    1000
    ASX.Set Ouch Field    dc_enter    price    1234
    ASX.Set Ouch Field    dc_enter    time_in_force    0
    ASX.Set Ouch Field    dc_enter    open_close    0
    ASX.Set Ouch Field    dc_enter    client_account    CLIENT_ACCT
    ASX.Set Ouch Field    dc_enter    customer_info    CUST_INFO
    ASX.Set Ouch Field    dc_enter    exchange_info    EXCG_INFO
    ASX.Set Ouch Field    dc_enter    clearing_participant    P
    ASX.Set Ouch Field    dc_enter    crossing_key    4001
    ASX.Set Ouch Field    dc_enter    capacity    A
    ASX.Set Ouch Field    dc_enter    directed_wholesale    N
    ASX.Set Ouch Field    dc_enter    intermediary_id    INTERMED_ID
    ASX.Set Ouch Field    dc_enter    order_origin    ORDER_ORIGIN
    ASX.Set Ouch Field    dc_enter    order_type    A
    ASX.Set Ouch Field    dc_enter    short_sell_quantity    0
    ASX.Set Ouch Field    dc_enter    minimum_acceptable_quantity    0
    ASX.Send Client Message    client_a    dc_enter
    ASX.Destroy Soup Message    dc_enter

    Comment    <- Order Accepted

    ASX.Create Soup Message    ds_accepted    S
    ASX.Set Ouch Type    ds_accepted    A
    ASX.Set Ouch Field    ds_accepted    timestamp    4001
    ASX.Set Ouch Field    ds_accepted    order_token    TEST_D1
    ASX.Set Ouch Field    ds_accepted    order_book_id    42
    ASX.Set Ouch Field    ds_accepted    side    B
    ASX.Set Ouch Field    ds_accepted    order_id    424001
    ASX.Set Ouch Field    ds_accepted    quantity    1000
    ASX.Set Ouch Field    ds_accepted    price    1234
    ASX.Set Ouch Field    ds_accepted    time_in_force    0
    ASX.Set Ouch Field    ds_accepted    open_close    0
    ASX.Set Ouch Field    ds_accepted    client_account    CLIENT_ACCT
    ASX.Set Ouch Field    ds_accepted    order_state    1
    ASX.Set Ouch Field    ds_accepted    customer_info    CUST_INFO
    ASX.Set Ouch Field    ds_accepted    exchange_info    EXCG_INFO
    ASX.Set Ouch Field    ds_accepted    clearing_participant    P
    ASX.Set Ouch Field    ds_accepted    crossing_key    4001
    ASX.Set Ouch Field    ds_accepted    capacity    A
    ASX.Set Ouch Field    ds_accepted    directed_wholesale    N
    ASX.Set Ouch Field    ds_accepted    intermediary_id    INTERMED_ID
    ASX.Set Ouch Field    ds_accepted    order_origin    ORDER_ORIGIN
    ASX.Set Ouch Field    ds_accepted    order_type    A
    ASX.Set Ouch Field    ds_accepted    short_sell_quantity    0
    ASX.Set Ouch Field    ds_accepted    minimum_acceptable_quantity    0
    ASX.Send Server Message    session_a    ds_accepted
    ASX.Destroy Soup Message    ds_accepted

    Comment    -> Cancel By OrderID

    ASX.Create Soup Message    dc_cancelbyid    U
    ASX.Set Ouch Type    dc_cancelbyid    Y
    ASX.Set Ouch Field    dc_cancelbyid    order_book_id    42
    ASX.Set Ouch Field    dc_cancelbyid    side    B
    ASX.Set Ouch Field    dc_cancelbyid    order_id    424001
    ASX.Send Client Message    client_a    dc_cancelbyid
    ASX.Destroy Soup Message    dc_cancelbyid

    Comment    <- Order Cancelled

    ASX.Create Soup Message    ds_canceled    S
    ASX.Set Ouch Type    ds_canceled    C
    ASX.Set Ouch Field    ds_canceled    timestamp    3002
    ASX.Set Ouch Field    ds_canceled    order_token    TEST_C1
    ASX.Set Ouch Field    ds_canceled    order_book_id    42
    ASX.Set Ouch Field    ds_canceled    side    B
    ASX.Set Ouch Field    ds_canceled    order_id    423001
    ASX.Set Ouch Field    ds_canceled    reason    1
    ASX.Send Server Message    session_a    ds_canceled
    ASX.Destroy Soup Message    ds_canceled



    Comment    -> Logout

    ASX.Create Soup Message    tc_logout    O
    ASX.Send Client Message    client_a    tc_logout


    ASX.Disconnect Server Session    session_a
    ASX.Disconnect Client    client_a
    ASX.Destroy Client    client_a
