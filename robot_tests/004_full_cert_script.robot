*** Settings ***
Library           Remote    http://localhost:${OUCH_PORT}    WITH NAME    OUCH

*** Test Cases ***
Certification Workflow
    [Setup]    OUCH.Reset
    OUCH.Create Server    server_a    44000    4.2
    OUCH.Create Client    client_a    localhost    44000    4.2
    OUCH.Server Start Listening    server_a
    OUCH.Connect Client    client_a
    Wait Until Keyword Succeeds    5s    1s   OUCH.Server Has New Session    server_a
    OUCH.Get New Server Session    server_a    session_a


    Comment    Send Login

    OUCH.Create Soup Message    c_login_a    L
    OUCH.Set Soup Field    c_login_a    username    user01
    OUCH.Set Soup Field    c_login_a    password    password
    OUCH.Send Client Message    client_a    c_login_a

    Wait Until Keyword Succeeds    5s    1s    OUCH.Server Has Received Message    session_a
    OUCH.Get Server Message    session_a    s_login_a
    ${soupType} =    OUCH.Get Soup Type    s_login_a
    Should Be Equal    L    ${soupType}
    ${soupUser} =    OUCH.Get Soup Field    s_login_a    username
    Should Be Equal    user01    ${soupUser}
    ${soupPasswd} =    OUCH.Get Soup Field    s_login_a    password
    Should Be Equal    password    ${soupPasswd}


    Comment    Send LoginRejected

    OUCH.Create Soup Message    s_loginrej_a    J
    OUCH.Set Soup Field    s_loginrej_a    reject_reason_code    S
    OUCH.Send Server Message    session_a    s_loginrej_a

    Wait Until Keyword Succeeds    5s    1s   OUCH.Client Has Received Message    client_a
    OUCH.Get Client Message    client_a    c_loginrej_a
    ${soupType} =    OUCH.Get Soup Type   c_loginrej_a
    Should Be Equal    J    ${soupType}
    ${soupRejectReason} =    OUCH.Get Soup Field    c_loginrej_a    reject_reason_code
    Should Be Equal    S    ${soupRejectReason}


    Comment    Send Login

    OUCH.Create Soup Message    c_login_b    L
    OUCH.Set Soup Field    c_login_b    username    user01
    OUCH.Set Soup Field    c_login_b    password    password
    OUCH.Send Client Message    client_a    c_login_b

    Wait Until Keyword Succeeds    5s    1s    OUCH.Server Has Received Message    session_a
    OUCH.Get Server Message    session_a    s_login_b
    ${soupType} =    OUCH.Get Soup Type    s_login_b
    Should Be Equal    L    ${soupType}
    ${soupUser} =    OUCH.Get Soup Field    s_login_b    username
    Should Be Equal    user01    ${soupUser}
    ${soupPasswd} =    OUCH.Get Soup Field    s_login_b    password
    Should Be Equal    password    ${soupPasswd}


    Comment    Send LoginAccepted

    OUCH.Create Soup Message    s_loginack_b    A
    OUCH.Set Soup Field    s_loginack_b    session    SESS0001
    OUCH.Set Soup Field    s_loginack_b    sequence_number    0
    OUCH.Send Server Message    session_a    s_loginack_b

    Wait Until Keyword Succeeds    5s    1s   OUCH.Client Has Received Message    client_a
    OUCH.Get Client Message    client_a    c_loginack_b
    ${soupType} =    OUCH.Get Soup Type   c_loginack_b
    Should Be Equal    A    ${soupType}


    Comment    Send SystemEvent (start)

    OUCH.Create Soup Message    s_system_c    S
    OUCH.Set Ouch Type    s_system_c    S
    OUCH.Set Ouch Field    s_system_c    timestamp    42
    OUCH.Set Ouch Field    s_system_c    event_code    S
    OUCH.Send Server Message    session_a    s_system_c

    Wait Until Keyword Succeeds    5s    1s    OUCH.Client Has Received message    client_a
    OUCH.Get Client Message    client_a    c_system_c
    ${soupType} =    OUCH.Get Soup Type    c_system_c
    Should Be Equal    S    ${soupType}
    ${ouchType} =    OUCH.Get Ouch Type    c_system_c
    Should Be Equal    S    ${ouchType}
    ${ouchEvent} =    OUCH.Get Ouch Field    c_system_c    event_code
    Should Be Equal    S    ${ouchEvent}



    Comment    -> Enter Order

    OUCH.Create Soup Message    d_c_enter    U
    OUCH.Set Ouch Type    d_c_enter    O
    OUCH.Set Ouch Field    d_c_enter    order_token    TEST_D1
    OUCH.Set Ouch Field    d_c_enter    buy_sell_indicator    B
    OUCH.Set Ouch Field    d_c_enter    shares    1000
    OUCH.Set Ouch Field    d_c_enter    stock    ZVZZT
    OUCH.Set Ouch Field    d_c_enter    price    123456
    OUCH.Set Ouch Field    d_c_enter    time_in_force    86400
    OUCH.Set Ouch Field    d_c_enter    firm    FIRM
    OUCH.Set Ouch Field    d_c_enter    display    A
    OUCH.Set Ouch Field    d_c_enter    capacity    A
    OUCH.Set Ouch Field    d_c_enter    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    d_c_enter    minimum_quantity    100
    OUCH.Set Ouch Field    d_c_enter    cross_type    N
    OUCH.Set Ouch Field    d_c_enter    customer_type    R
    OUCH.Send Client Message    client_a    d_c_enter

    Comment    <- OrderAccepted

    OUCH.Create Soup Message    d_s_accepted    S
    OUCH.Set Ouch Type    d_s_accepted    A
    OUCH.Set Ouch Field    d_s_accepted    timestamp    1001
    OUCH.Set Ouch Field    d_s_accepted    order_token    TEST_D1
    OUCH.Set Ouch Field    d_s_accepted    buy_sell_indicator    B
    OUCH.Set Ouch Field    d_s_accepted    shares    1000
    OUCH.Set Ouch Field    d_s_accepted    stock    ZVZZT
    OUCH.Set Ouch Field    d_s_accepted    price    123456
    OUCH.Set Ouch Field    d_s_accepted    time_in_force    86400
    OUCH.Set Ouch Field    d_s_accepted    firm    FIRM
    OUCH.Set Ouch Field    d_s_accepted    display    A
    OUCH.Set Ouch Field    d_s_accepted    capacity    A
    OUCH.Set Ouch Field    d_s_accepted    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    d_s_accepted    minimum_quantity    100
    OUCH.Set Ouch Field    d_s_accepted    cross_type    N
    OUCH.Set Ouch Field    d_s_accepted    order_state    L
    OUCH.Set Ouch Field    d_s_accepted    bbo_weight_indicator    S
    OUCH.Send Server Message    session_a    d_s_accepted

    Comment    -> CancelOrder

    OUCH.Create Soup Message    d_c_cancel    U
    OUCH.Set Ouch Type    d_c_cancel    X
    OUCH.Set Ouch Field    d_c_cancel    order_token    TEST_D1
    OUCH.Set Ouch Field    d_c_cancel    shares    0
    OUCH.Send Client Message    client_a    d_c_cancel

    Comment    <- OrderCanceled

    OUCH.Create Soup Message    d_s_canceled    S
    OUCH.Set Ouch Type    d_s_canceled    C
    OUCH.Set Ouch Field    d_s_canceled    timestamp    1002
    OUCH.Set Ouch Field    d_s_canceled    order_token    TEST_D1
    OUCH.Set Ouch Field    d_s_canceled    decrement_shares    1000
    OUCH.Set Ouch Field    d_s_canceled    reason    U
    OUCH.Send Server Message    session_a    d_s_canceled



    Comment    -> EnterOrder

    OUCH.Create Soup Message    e_c_enter    U
    OUCH.Set Ouch Type    e_c_enter    O
    OUCH.Set Ouch Field    e_c_enter    order_token    TEST_E1
    OUCH.Set Ouch Field    e_c_enter    buy_sell_indicator    B
    OUCH.Set Ouch Field    e_c_enter    shares    1000
    OUCH.Set Ouch Field    e_c_enter    stock    ZVZZT
    OUCH.Set Ouch Field    e_c_enter    price    123456
    OUCH.Set Ouch Field    e_c_enter    time_in_force    86400
    OUCH.Set Ouch Field    e_c_enter    firm    FIRM
    OUCH.Set Ouch Field    e_c_enter    display    A
    OUCH.Set Ouch Field    e_c_enter    capacity    A
    OUCH.Set Ouch Field    e_c_enter    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    e_c_enter    minimum_quantity    100
    OUCH.Set Ouch Field    e_c_enter    cross_type    N
    OUCH.Set Ouch Field    e_c_enter    customer_type    R
    OUCH.Send Client Message    client_a    e_c_enter

    Comment    <- OrderAccepted

    OUCH.Create Soup Message    e_s_accepted    S
    OUCH.Set Ouch Type    e_s_accepted    A
    OUCH.Set Ouch Field    e_s_accepted    timestamp    2001
    OUCH.Set Ouch Field    e_s_accepted    order_token    TEST_E1
    OUCH.Set Ouch Field    e_s_accepted    buy_sell_indicator    B
    OUCH.Set Ouch Field    e_s_accepted    shares    1000
    OUCH.Set Ouch Field    e_s_accepted    stock    ZVZZT
    OUCH.Set Ouch Field    e_s_accepted    price    123456
    OUCH.Set Ouch Field    e_s_accepted    time_in_force    86400
    OUCH.Set Ouch Field    e_s_accepted    firm    FIRM
    OUCH.Set Ouch Field    e_s_accepted    display    A
    OUCH.Set Ouch Field    e_s_accepted    capacity    A
    OUCH.Set Ouch Field    e_s_accepted    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    e_s_accepted    minimum_quantity    100
    OUCH.Set Ouch Field    e_s_accepted    cross_type    N
    OUCH.Set Ouch Field    e_s_accepted    order_state    L
    OUCH.Set Ouch Field    e_s_accepted    bbo_weight_indicator    S
    OUCH.Send Server Message    session_a    e_s_accepted

    Comment    <- Executed (full)

    OUCH.Create Soup Message    e_s_executed    S
    OUCH.Set Ouch Type    e_s_executed    E
    OUCH.Set Ouch Field    e_s_executed    timestamp    2002
    OUCH.Set Ouch Field    e_s_executed    order_token    TEST_E1
    OUCH.Set Ouch Field    e_s_executed    executed_shares    1000
    OUCH.Set Ouch Field    e_s_executed    execution_price    123456
    OUCH.Set Ouch Field    e_s_executed    liquidity_flag     R
    OUCH.Set Ouch Field    e_s_executed    match_number     1



    Comment    -> EnterOrder

    OUCH.Create Soup Message    f_c_enter    U
    OUCH.Set Ouch Type    f_c_enter    O
    OUCH.Set Ouch Field    f_c_enter    order_token    TEST_F1
    OUCH.Set Ouch Field    f_c_enter    buy_sell_indicator    B
    OUCH.Set Ouch Field    f_c_enter    shares    1000
    OUCH.Set Ouch Field    f_c_enter    stock    ZVZZT
    OUCH.Set Ouch Field    f_c_enter    price    123456
    OUCH.Set Ouch Field    f_c_enter    time_in_force    86400
    OUCH.Set Ouch Field    f_c_enter    firm    FIRM
    OUCH.Set Ouch Field    f_c_enter    display    A
    OUCH.Set Ouch Field    f_c_enter    capacity    A
    OUCH.Set Ouch Field    f_c_enter    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    f_c_enter    minimum_quantity    100
    OUCH.Set Ouch Field    f_c_enter    cross_type    N
    OUCH.Set Ouch Field    f_c_enter    customer_type    R
    OUCH.Send Client Message    client_a    f_c_enter

    Comment    <- OrderAccepted

    OUCH.Create Soup Message    f_s_accepted    S
    OUCH.Set Ouch Type    f_s_accepted    A
    OUCH.Set Ouch Field    f_s_accepted    timestamp    3001
    OUCH.Set Ouch Field    f_s_accepted    order_token    TEST_F1
    OUCH.Set Ouch Field    f_s_accepted    buy_sell_indicator    B
    OUCH.Set Ouch Field    f_s_accepted    shares    1000
    OUCH.Set Ouch Field    f_s_accepted    stock    ZVZZT
    OUCH.Set Ouch Field    f_s_accepted    price    123456
    OUCH.Set Ouch Field    f_s_accepted    time_in_force    86400
    OUCH.Set Ouch Field    f_s_accepted    firm    FIRM
    OUCH.Set Ouch Field    f_s_accepted    display    A
    OUCH.Set Ouch Field    f_s_accepted    capacity    A
    OUCH.Set Ouch Field    f_s_accepted    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    f_s_accepted    minimum_quantity    100
    OUCH.Set Ouch Field    f_s_accepted    cross_type    N
    OUCH.Set Ouch Field    f_s_accepted    order_state    L
    OUCH.Set Ouch Field    f_s_accepted    bbo_weight_indicator    S
    OUCH.Send Server Message    session_a    f_s_accepted

    Comment    <- OrderCanceled

    OUCH.Create Soup Message    f_s_canceled    S
    OUCH.Set Ouch Type    f_s_canceled    C
    OUCH.Set Ouch Field    f_s_canceled    timestamp    3002
    OUCH.Set Ouch Field    f_s_canceled    order_token    TEST_F1
    OUCH.Set Ouch Field    f_s_canceled    decrement_shares    1000
    OUCH.Set Ouch Field    f_s_canceled    reason    S
    OUCH.Send Server Message    session_a    f_s_canceled



    Comment    -> EnterOrder

    OUCH.Create Soup Message    g_c_enter    U
    OUCH.Set Ouch Type    g_c_enter    O
    OUCH.Set Ouch Field    g_c_enter    order_token    TEST_G1
    OUCH.Set Ouch Field    g_c_enter    buy_sell_indicator    B
    OUCH.Set Ouch Field    g_c_enter    shares    1000
    OUCH.Set Ouch Field    g_c_enter    stock    ZVZZT
    OUCH.Set Ouch Field    g_c_enter    price    123456
    OUCH.Set Ouch Field    g_c_enter    time_in_force    86400
    OUCH.Set Ouch Field    g_c_enter    firm    FIRM
    OUCH.Set Ouch Field    g_c_enter    display    A
    OUCH.Set Ouch Field    g_c_enter    capacity    A
    OUCH.Set Ouch Field    g_c_enter    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    g_c_enter    minimum_quantity    100
    OUCH.Set Ouch Field    g_c_enter    cross_type    N
    OUCH.Set Ouch Field    g_c_enter    customer_type    R
    OUCH.Send Client Message    client_a    g_c_enter

    Comment    <- OrderAccepted

    OUCH.Create Soup Message    g_s_accepted    S
    OUCH.Set Ouch Type    g_s_accepted    A
    OUCH.Set Ouch Field    g_s_accepted    timestamp    4001
    OUCH.Set Ouch Field    g_s_accepted    order_token    TEST_G1
    OUCH.Set Ouch Field    g_s_accepted    buy_sell_indicator    B
    OUCH.Set Ouch Field    g_s_accepted    shares    1000
    OUCH.Set Ouch Field    g_s_accepted    stock    ZVZZT
    OUCH.Set Ouch Field    g_s_accepted    price    123456
    OUCH.Set Ouch Field    g_s_accepted    time_in_force    86400
    OUCH.Set Ouch Field    g_s_accepted    firm    FIRM
    OUCH.Set Ouch Field    g_s_accepted    display    A
    OUCH.Set Ouch Field    g_s_accepted    capacity    A
    OUCH.Set Ouch Field    g_s_accepted    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    g_s_accepted    minimum_quantity    100
    OUCH.Set Ouch Field    g_s_accepted    cross_type    N
    OUCH.Set Ouch Field    g_s_accepted    order_state    L
    OUCH.Set Ouch Field    g_s_accepted    bbo_weight_indicator    S
    OUCH.Send Server Message    session_a    g_s_accepted

    Comment    <- AIQCanceled

    OUCH.Create Soup Message    g_s_aiqcanceled    S
    OUCH.Set Ouch Type    g_s_aiqcanceled    D
    OUCH.Set Ouch Field    g_s_aiqcanceled    timestamp    4002
    OUCH.Set Ouch Field    g_s_aiqcanceled    order_token    TEST_G1
    OUCH.Set Ouch Field    g_s_aiqcanceled    decrement_shares    1000
    OUCH.Set Ouch Field    g_s_aiqcanceled    reason    Q
    OUCH.Set Ouch Field    g_s_aiqcanceled    quantity_prevented_from_trading    1000
    OUCH.Set Ouch Field    g_s_aiqcanceled    execution_price    123456
    OUCH.Set Ouch Field    g_s_aiqcanceled    liquidity_flag     R
    OUCH.Send Server Message    session_a    g_s_aiqcanceled



    Comment    -> EnterOrder

    OUCH.Create Soup Message    h_c_enter    U
    OUCH.Set Ouch Type    h_c_enter    O
    OUCH.Set Ouch Field    h_c_enter    order_token    TEST_H1
    OUCH.Set Ouch Field    h_c_enter    buy_sell_indicator    B
    OUCH.Set Ouch Field    h_c_enter    shares    1000
    OUCH.Set Ouch Field    h_c_enter    stock    ZVZZT
    OUCH.Set Ouch Field    h_c_enter    price    123456
    OUCH.Set Ouch Field    h_c_enter    time_in_force    86400
    OUCH.Set Ouch Field    h_c_enter    firm    FIRM
    OUCH.Set Ouch Field    h_c_enter    display    A
    OUCH.Set Ouch Field    h_c_enter    capacity    A
    OUCH.Set Ouch Field    h_c_enter    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    h_c_enter    minimum_quantity    100
    OUCH.Set Ouch Field    h_c_enter    cross_type    N
    OUCH.Set Ouch Field    h_c_enter    customer_type    R
    OUCH.Send Client Message    client_a    h_c_enter

    Comment    <- OrderAccepted

    OUCH.Create Soup Message    h_s_accepted    S
    OUCH.Set Ouch Type    h_s_accepted    A
    OUCH.Set Ouch Field    h_s_accepted    timestamp    5001
    OUCH.Set Ouch Field    h_s_accepted    order_token    TEST_H1
    OUCH.Set Ouch Field    h_s_accepted    buy_sell_indicator    B
    OUCH.Set Ouch Field    h_s_accepted    shares    1000
    OUCH.Set Ouch Field    h_s_accepted    stock    ZVZZT
    OUCH.Set Ouch Field    h_s_accepted    price    123456
    OUCH.Set Ouch Field    h_s_accepted    time_in_force    86400
    OUCH.Set Ouch Field    h_s_accepted    firm    FIRM
    OUCH.Set Ouch Field    h_s_accepted    display    A
    OUCH.Set Ouch Field    h_s_accepted    capacity    A
    OUCH.Set Ouch Field    h_s_accepted    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    h_s_accepted    minimum_quantity    100
    OUCH.Set Ouch Field    h_s_accepted    cross_type    N
    OUCH.Set Ouch Field    h_s_accepted    order_state    L
    OUCH.Set Ouch Field    h_s_accepted    bbo_weight_indicator    S
    OUCH.Send Server Message    session_a    h_s_accepted

    Comment    <- Executed (partial)

    OUCH.Create Soup Message    h_s_executed    S
    OUCH.Set Ouch Type    h_s_executed    E
    OUCH.Set Ouch Field    h_s_executed    timestamp    5002
    OUCH.Set Ouch Field    h_s_executed    order_token    TEST_H1
    OUCH.Set Ouch Field    h_s_executed    executed_shares    500
    OUCH.Set Ouch Field    h_s_executed    execution_price    123456
    OUCH.Set Ouch Field    h_s_executed    liquidity_flag     R
    OUCH.Set Ouch Field    h_s_executed    match_number     51
    OUCH.Send Server Message    session_a    h_s_executed
    OUCH.Destroy Soup Message    h_s_executed

    Comment    <- Executed (partial)

    OUCH.Create Soup Message    h_s_executed    S
    OUCH.Set Ouch Type    h_s_executed    E
    OUCH.Set Ouch Field    h_s_executed    timestamp    5003
    OUCH.Set Ouch Field    h_s_executed    order_token    TEST_H1
    OUCH.Set Ouch Field    h_s_executed    executed_shares    500
    OUCH.Set Ouch Field    h_s_executed    execution_price    123456
    OUCH.Set Ouch Field    h_s_executed    liquidity_flag     R
    OUCH.Set Ouch Field    h_s_executed    match_number     52
    OUCH.Send Server Message    session_a    h_s_executed



    Comment    -> EnterOrder

    OUCH.Create Soup Message    i_c_enter    U
    OUCH.Set Ouch Type    i_c_enter    O
    OUCH.Set Ouch Field    i_c_enter    order_token    TEST_I1
    OUCH.Set Ouch Field    i_c_enter    buy_sell_indicator    B
    OUCH.Set Ouch Field    i_c_enter    shares    1000
    OUCH.Set Ouch Field    i_c_enter    stock    ZVZZT
    OUCH.Set Ouch Field    i_c_enter    price    123456
    OUCH.Set Ouch Field    i_c_enter    time_in_force    86400
    OUCH.Set Ouch Field    i_c_enter    firm    FIRM
    OUCH.Set Ouch Field    i_c_enter    display    A
    OUCH.Set Ouch Field    i_c_enter    capacity    A
    OUCH.Set Ouch Field    i_c_enter    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    i_c_enter    minimum_quantity    100
    OUCH.Set Ouch Field    i_c_enter    cross_type    N
    OUCH.Set Ouch Field    i_c_enter    customer_type    R
    OUCH.Send Client Message    client_a    i_c_enter

    Comment    <- OrderAccepted

    OUCH.Create Soup Message    i_s_accepted    S
    OUCH.Set Ouch Type    i_s_accepted    A
    OUCH.Set Ouch Field    i_s_accepted    timestamp    6001
    OUCH.Set Ouch Field    i_s_accepted    order_token    TEST_I1
    OUCH.Set Ouch Field    i_s_accepted    buy_sell_indicator    B
    OUCH.Set Ouch Field    i_s_accepted    shares    1000
    OUCH.Set Ouch Field    i_s_accepted    stock    ZVZZT
    OUCH.Set Ouch Field    i_s_accepted    price    123456
    OUCH.Set Ouch Field    i_s_accepted    time_in_force    86400
    OUCH.Set Ouch Field    i_s_accepted    firm    FIRM
    OUCH.Set Ouch Field    i_s_accepted    display    A
    OUCH.Set Ouch Field    i_s_accepted    capacity    A
    OUCH.Set Ouch Field    i_s_accepted    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    i_s_accepted    minimum_quantity    100
    OUCH.Set Ouch Field    i_s_accepted    cross_type    N
    OUCH.Set Ouch Field    i_s_accepted    order_state    L
    OUCH.Set Ouch Field    i_s_accepted    bbo_weight_indicator    S
    OUCH.Send Server Message    session_a    i_s_accepted

    Comment    <- ExecutedWithReferencePrice

    OUCH.Create Soup Message    i_s_executed    S
    OUCH.Set Ouch Type    i_s_executed    G
    OUCH.Set Ouch Field    i_s_executed    timestamp    6002
    OUCH.Set Ouch Field    i_s_executed    order_token    TEST_H1
    OUCH.Set Ouch Field    i_s_executed    executed_shares    1000
    OUCH.Set Ouch Field    i_s_executed    execution_price    123456
    OUCH.Set Ouch Field    i_s_executed    liquidity_flag     R
    OUCH.Set Ouch Field    i_s_executed    match_number     61
    OUCH.Set Ouch Field    i_s_executed    reference_price    123456
    OUCH.Set Ouch Field    i_s_executed    reference_price_type    I
    OUCH.Send Server Message    session_a    i_s_executed



    Comment    -> EnterOrder

    OUCH.Create Soup Message    j_c_enter    U
    OUCH.Set Ouch Type    j_c_enter    O
    OUCH.Set Ouch Field    j_c_enter    order_token    TEST_J1
    OUCH.Set Ouch Field    j_c_enter    buy_sell_indicator    B
    OUCH.Set Ouch Field    j_c_enter    shares    1000
    OUCH.Set Ouch Field    j_c_enter    stock    ZVZZT
    OUCH.Set Ouch Field    j_c_enter    price    123456
    OUCH.Set Ouch Field    j_c_enter    time_in_force    86400
    OUCH.Set Ouch Field    j_c_enter    firm    FIRM
    OUCH.Set Ouch Field    j_c_enter    display    A
    OUCH.Set Ouch Field    j_c_enter    capacity    A
    OUCH.Set Ouch Field    j_c_enter    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    j_c_enter    minimum_quantity    100
    OUCH.Set Ouch Field    j_c_enter    cross_type    N
    OUCH.Set Ouch Field    j_c_enter    customer_type    R
    OUCH.Send Client Message    client_a    j_c_enter

    Comment    <- OrderAccepted

    OUCH.Create Soup Message    j_s_accepted    S
    OUCH.Set Ouch Type    j_s_accepted    A
    OUCH.Set Ouch Field    j_s_accepted    timestamp    7001
    OUCH.Set Ouch Field    j_s_accepted    order_token    TEST_J1
    OUCH.Set Ouch Field    j_s_accepted    buy_sell_indicator    B
    OUCH.Set Ouch Field    j_s_accepted    shares    1000
    OUCH.Set Ouch Field    j_s_accepted    stock    ZVZZT
    OUCH.Set Ouch Field    j_s_accepted    price    123456
    OUCH.Set Ouch Field    j_s_accepted    time_in_force    86400
    OUCH.Set Ouch Field    j_s_accepted    firm    FIRM
    OUCH.Set Ouch Field    j_s_accepted    display    A
    OUCH.Set Ouch Field    j_s_accepted    capacity    A
    OUCH.Set Ouch Field    j_s_accepted    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    j_s_accepted    minimum_quantity    100
    OUCH.Set Ouch Field    j_s_accepted    cross_type    N
    OUCH.Set Ouch Field    j_s_accepted    order_state    L
    OUCH.Set Ouch Field    j_s_accepted    bbo_weight_indicator    S
    OUCH.Send Server Message    session_a    j_s_accepted

    Comment    <- Executed (full)

    OUCH.Create Soup Message    j_s_executed    S
    OUCH.Set Ouch Type    j_s_executed    E
    OUCH.Set Ouch Field    j_s_executed    timestamp    7002
    OUCH.Set Ouch Field    j_s_executed    order_token    TEST_J1
    OUCH.Set Ouch Field    j_s_executed    executed_shares    1000
    OUCH.Set Ouch Field    j_s_executed    execution_price    123456
    OUCH.Set Ouch Field    j_s_executed    liquidity_flag     R
    OUCH.Set Ouch Field    j_s_executed    match_number     71
    OUCH.Send Server Message    session_a    j_s_executed

    Comment    <- TradeCorrected

    OUCH.Create Soup Message    j_s_correction    S
    OUCH.Set Ouch Type    j_s_correction    F
    OUCH.Set Ouch Field    j_s_correction    timestamp    7003
    OUCH.Set Ouch Field    j_s_correction    order_token    TEST_J1
    OUCH.Set Ouch Field    j_s_correction    executed_shares    1000
    OUCH.Set Ouch Field    j_s_correction    execution_price    123457
    OUCH.Set Ouch Field    j_s_correction    liquidity_flag     R
    OUCH.Set Ouch Field    j_s_correction    match_number     71
    OUCH.Set Ouch Field    j_s_correction    trade_correction_reason    N
    OUCH.Send Server Message    session_a    j_s_correction



    Comment    -> EnterOrder

    OUCH.Create Soup Message    k_c_enter    U
    OUCH.Set Ouch Type    k_c_enter    O
    OUCH.Set Ouch Field    k_c_enter    order_token    TEST_K1
    OUCH.Set Ouch Field    k_c_enter    buy_sell_indicator    B
    OUCH.Set Ouch Field    k_c_enter    shares    1000
    OUCH.Set Ouch Field    k_c_enter    stock    ZVZZT
    OUCH.Set Ouch Field    k_c_enter    price    123456
    OUCH.Set Ouch Field    k_c_enter    time_in_force    86400
    OUCH.Set Ouch Field    k_c_enter    firm    FIRM
    OUCH.Set Ouch Field    k_c_enter    display    A
    OUCH.Set Ouch Field    k_c_enter    capacity    A
    OUCH.Set Ouch Field    k_c_enter    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    k_c_enter    minimum_quantity    100
    OUCH.Set Ouch Field    k_c_enter    cross_type    N
    OUCH.Set Ouch Field    k_c_enter    customer_type    R
    OUCH.Send Client Message    client_a    k_c_enter

    Comment    <- OrderAccepted

    OUCH.Create Soup Message    k_s_accepted    S
    OUCH.Set Ouch Type    k_s_accepted    A
    OUCH.Set Ouch Field    k_s_accepted    timestamp    8001
    OUCH.Set Ouch Field    k_s_accepted    order_token    TEST_K1
    OUCH.Set Ouch Field    k_s_accepted    buy_sell_indicator    B
    OUCH.Set Ouch Field    k_s_accepted    shares    1000
    OUCH.Set Ouch Field    k_s_accepted    stock    ZVZZT
    OUCH.Set Ouch Field    k_s_accepted    price    123456
    OUCH.Set Ouch Field    k_s_accepted    time_in_force    86400
    OUCH.Set Ouch Field    k_s_accepted    firm    FIRM
    OUCH.Set Ouch Field    k_s_accepted    display    A
    OUCH.Set Ouch Field    k_s_accepted    capacity    A
    OUCH.Set Ouch Field    k_s_accepted    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    k_s_accepted    minimum_quantity    100
    OUCH.Set Ouch Field    k_s_accepted    cross_type    N
    OUCH.Set Ouch Field    k_s_accepted    order_state    L
    OUCH.Set Ouch Field    k_s_accepted    bbo_weight_indicator    S
    OUCH.Send Server Message    session_a    k_s_accepted

    Comment    <- Executed (full)

    OUCH.Create Soup Message    k_s_executed    S
    OUCH.Set Ouch Type    k_s_executed    E
    OUCH.Set Ouch Field    k_s_executed    timestamp    8002
    OUCH.Set Ouch Field    k_s_executed    order_token    TEST_K1
    OUCH.Set Ouch Field    k_s_executed    executed_shares    1000
    OUCH.Set Ouch Field    k_s_executed    execution_price    123456
    OUCH.Set Ouch Field    k_s_executed    liquidity_flag     R
    OUCH.Set Ouch Field    k_s_executed    match_number     81
    OUCH.Send Server Message    session_a    k_s_executed

    Comment    <- BrokenTrade

    OUCH.Create Soup Message    k_s_broken    S
    OUCH.Set Ouch Type    k_s_broken    B
    OUCH.Set Ouch Field    k_s_broken    timestamp    8003
    OUCH.Set Ouch Field    k_s_broken    order_token    TEST_K1
    OUCH.Set Ouch Field    k_s_broken    match_number    81
    OUCH.Set Ouch Field    k_s_broken    reason    E
    OUCH.Send Server Message    session_a    k_s_broken



    Comment    -> EnterOrder

    OUCH.Create Soup Message    l_c_enter    U
    OUCH.Set Ouch Type    l_c_enter    O
    OUCH.Set Ouch Field    l_c_enter    order_token    TEST_L1
    OUCH.Set Ouch Field    l_c_enter    buy_sell_indicator    B
    OUCH.Set Ouch Field    l_c_enter    shares    1000
    OUCH.Set Ouch Field    l_c_enter    stock    ZVZZT
    OUCH.Set Ouch Field    l_c_enter    price    123456
    OUCH.Set Ouch Field    l_c_enter    time_in_force    86400
    OUCH.Set Ouch Field    l_c_enter    firm    FIRM
    OUCH.Set Ouch Field    l_c_enter    display    A
    OUCH.Set Ouch Field    l_c_enter    capacity    A
    OUCH.Set Ouch Field    l_c_enter    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    l_c_enter    minimum_quantity    100
    OUCH.Set Ouch Field    l_c_enter    cross_type    N
    OUCH.Set Ouch Field    l_c_enter    customer_type    R
    OUCH.Send Client Message    client_a    l_c_enter

    Comment    <- OrderAccepted

    OUCH.Create Soup Message    l_s_accepted    S
    OUCH.Set Ouch Type    l_s_accepted    A
    OUCH.Set Ouch Field    l_s_accepted    timestamp    9001
    OUCH.Set Ouch Field    l_s_accepted    order_token    TEST_L1
    OUCH.Set Ouch Field    l_s_accepted    buy_sell_indicator    B
    OUCH.Set Ouch Field    l_s_accepted    shares    1000
    OUCH.Set Ouch Field    l_s_accepted    stock    ZVZZT
    OUCH.Set Ouch Field    l_s_accepted    price    123456
    OUCH.Set Ouch Field    l_s_accepted    time_in_force    86400
    OUCH.Set Ouch Field    l_s_accepted    firm    FIRM
    OUCH.Set Ouch Field    l_s_accepted    display    A
    OUCH.Set Ouch Field    l_s_accepted    order_reference_number    91
    OUCH.Set Ouch Field    l_s_accepted    capacity    A
    OUCH.Set Ouch Field    l_s_accepted    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    l_s_accepted    minimum_quantity    100
    OUCH.Set Ouch Field    l_s_accepted    cross_type    N
    OUCH.Set Ouch Field    l_s_accepted    order_state    L
    OUCH.Set Ouch Field    l_s_accepted    bbo_weight_indicator    S
    OUCH.Send Server Message    session_a    l_s_accepted

    Comment    -> ReplaceOrder

    OUCH.Create Soup Message    l_c_replace    U
    OUCH.Set Ouch Type    l_c_replace    U
    OUCH.Set Ouch Field    l_c_replace    existing_order_token    TEST_L1
    OUCH.Set Ouch Field    l_c_replace    replacement_order_token    TEST_L2
    OUCH.Set Ouch Field    l_c_replace    shares    1000
    OUCH.Set Ouch Field    l_c_replace    price    123456
    OUCH.Set Ouch Field    l_c_replace    time_in_force    86400
    OUCH.Set Ouch Field    l_c_replace    display    A
    OUCH.Set Ouch Field    l_c_replace    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    l_c_replace    minimum_quantity    100
    OUCH.Send Client Message    client_a    l_c_replace

    Comment    <- OrderReplaced

    OUCH.Create Soup Message    l_s_replaced    S
    OUCH.Set Ouch Type    l_s_replaced    U
    OUCH.Set Ouch Field    l_s_replaced    timestamp    9002
    OUCH.Set Ouch Field    l_s_replaced    replacement_order_token    TEST_L2
    OUCH.Set Ouch Field    l_s_replaced    buy_sell_indicator    B
    OUCH.Set Ouch Field    l_s_replaced    shares    1000
    OUCH.Set Ouch Field    l_s_replaced    stock    ZVZZT
    OUCH.Set Ouch Field    l_s_replaced    price    123456
    OUCH.Set Ouch Field    l_s_replaced    time_in_force    86400
    OUCH.Set Ouch Field    l_s_replaced    firm    FIRM
    OUCH.Set Ouch Field    l_s_replaced    display    A
    OUCH.Set Ouch Field    l_s_replaced    order_reference_number    92
    OUCH.Set Ouch Field    l_s_replaced    capacity    A
    OUCH.Set Ouch Field    l_s_replaced    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    l_s_replaced    minimum_quantity    100
    OUCH.Set Ouch Field    l_s_replaced    cross_type    N
    OUCH.Set Ouch Field    l_s_replaced    order_state    L
    OUCH.Set Ouch Field    l_s_replaced    previous_order_token    TEST_L1
    OUCH.Set Ouch Field    l_s_replaced    bbo_weight_indicator    S
    OUCH.Send Server Message    session_a    l_s_replaced

    Comment    <- Executed (full)

    OUCH.Create Soup Message    l_s_executed    S
    OUCH.Set Ouch Type    l_s_executed    E
    OUCH.Set Ouch Field    l_s_executed    timestamp    9003
    OUCH.Set Ouch Field    l_s_executed    order_token    TEST_L2
    OUCH.Set Ouch Field    l_s_executed    executed_shares    1000
    OUCH.Set Ouch Field    l_s_executed    execution_price    123456
    OUCH.Set Ouch Field    l_s_executed    liquidity_flag     R
    OUCH.Set Ouch Field    l_s_executed    match_number     91
    OUCH.Send Server Message    session_a    l_s_executed



    Comment    -> EnterOrder

    OUCH.Create Soup Message    m_c_enter    U
    OUCH.Set Ouch Type    m_c_enter    O
    OUCH.Set Ouch Field    m_c_enter    order_token    TEST_M1
    OUCH.Set Ouch Field    m_c_enter    buy_sell_indicator    B
    OUCH.Set Ouch Field    m_c_enter    shares    1000
    OUCH.Set Ouch Field    m_c_enter    stock    ZVZZT
    OUCH.Set Ouch Field    m_c_enter    price    123456
    OUCH.Set Ouch Field    m_c_enter    time_in_force    86400
    OUCH.Set Ouch Field    m_c_enter    firm    FIRM
    OUCH.Set Ouch Field    m_c_enter    display    A
    OUCH.Set Ouch Field    m_c_enter    capacity    A
    OUCH.Set Ouch Field    m_c_enter    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    m_c_enter    minimum_quantity    100
    OUCH.Set Ouch Field    m_c_enter    cross_type    N
    OUCH.Set Ouch Field    m_c_enter    customer_type    R
    OUCH.Send Client Message    client_a    m_c_enter

    Comment    <- OrderAccepted

    OUCH.Create Soup Message    m_s_accepted    S
    OUCH.Set Ouch Type    m_s_accepted    A
    OUCH.Set Ouch Field    m_s_accepted    timestamp    10001
    OUCH.Set Ouch Field    m_s_accepted    order_token    TEST_M1
    OUCH.Set Ouch Field    m_s_accepted    buy_sell_indicator    B
    OUCH.Set Ouch Field    m_s_accepted    shares    1000
    OUCH.Set Ouch Field    m_s_accepted    stock    ZVZZT
    OUCH.Set Ouch Field    m_s_accepted    price    123456
    OUCH.Set Ouch Field    m_s_accepted    time_in_force    86400
    OUCH.Set Ouch Field    m_s_accepted    firm    FIRM
    OUCH.Set Ouch Field    m_s_accepted    display    A
    OUCH.Set Ouch Field    m_s_accepted    order_reference_number    101
    OUCH.Set Ouch Field    m_s_accepted    capacity    A
    OUCH.Set Ouch Field    m_s_accepted    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    m_s_accepted    minimum_quantity    100
    OUCH.Set Ouch Field    m_s_accepted    cross_type    N
    OUCH.Set Ouch Field    m_s_accepted    order_state    L
    OUCH.Set Ouch Field    m_s_accepted    bbo_weight_indicator    S
    OUCH.Send Server Message    session_a    m_s_accepted

    Comment    -> ReplaceOrder

    OUCH.Create Soup Message    m_c_replace    U
    OUCH.Set Ouch Type    m_c_replace    U
    OUCH.Set Ouch Field    m_c_replace    existing_order_token    TEST_M1
    OUCH.Set Ouch Field    m_c_replace    replacement_order_token    TEST_M2
    OUCH.Set Ouch Field    m_c_replace    shares    1000
    OUCH.Set Ouch Field    m_c_replace    price    123456
    OUCH.Set Ouch Field    m_c_replace    time_in_force    86400
    OUCH.Set Ouch Field    m_c_replace    display    A
    OUCH.Set Ouch Field    m_c_replace    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    m_c_replace    minimum_quantity    100
    OUCH.Send Client Message    client_a    m_c_replace

    Comment    <- OrderReplaced

    OUCH.Create Soup Message    m_s_replaced    S
    OUCH.Set Ouch Type    m_s_replaced    U
    OUCH.Set Ouch Field    m_s_replaced    timestamp    10002
    OUCH.Set Ouch Field    m_s_replaced    replacement_order_token    TEST_M2
    OUCH.Set Ouch Field    m_s_replaced    buy_sell_indicator    B
    OUCH.Set Ouch Field    m_s_replaced    shares    1000
    OUCH.Set Ouch Field    m_s_replaced    stock    ZVZZT
    OUCH.Set Ouch Field    m_s_replaced    price    123456
    OUCH.Set Ouch Field    m_s_replaced    time_in_force    86400
    OUCH.Set Ouch Field    m_s_replaced    firm    FIRM
    OUCH.Set Ouch Field    m_s_replaced    display    A
    OUCH.Set Ouch Field    m_s_replaced    order_reference_number    102
    OUCH.Set Ouch Field    m_s_replaced    capacity    A
    OUCH.Set Ouch Field    m_s_replaced    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    m_s_replaced    minimum_quantity    100
    OUCH.Set Ouch Field    m_s_replaced    cross_type    N
    OUCH.Set Ouch Field    m_s_replaced    order_state    L
    OUCH.Set Ouch Field    m_s_replaced    previous_order_token    TEST_M1
    OUCH.Set Ouch Field    m_s_replaced    bbo_weight_indicator    S
    OUCH.Send Server Message    session_a    m_s_replaced

    Comment    <- OrderCanceled

    OUCH.Create Soup Message    m_s_canceled    S
    OUCH.Set Ouch Type    m_s_canceled    C
    OUCH.Set Ouch Field    m_s_canceled    timestamp    10003
    OUCH.Set Ouch Field    m_s_canceled    order_token    TEST_M2
    OUCH.Set Ouch Field    m_s_canceled    decrement_shares    1000
    OUCH.Set Ouch Field    m_s_canceled    reason    S
    OUCH.Send Server Message    session_a    m_s_canceled



    Comment    -> EnterOrder

    OUCH.Create Soup Message    n_c_enter    U
    OUCH.Set Ouch Type    n_c_enter    O
    OUCH.Set Ouch Field    n_c_enter    order_token    TEST_N1
    OUCH.Set Ouch Field    n_c_enter    buy_sell_indicator    S
    OUCH.Set Ouch Field    n_c_enter    shares    1000
    OUCH.Set Ouch Field    n_c_enter    stock    ZVZZT
    OUCH.Set Ouch Field    n_c_enter    price    123456
    OUCH.Set Ouch Field    n_c_enter    time_in_force    86400
    OUCH.Set Ouch Field    n_c_enter    firm    FIRM
    OUCH.Set Ouch Field    n_c_enter    display    A
    OUCH.Set Ouch Field    n_c_enter    capacity    A
    OUCH.Set Ouch Field    n_c_enter    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    n_c_enter    minimum_quantity    100
    OUCH.Set Ouch Field    n_c_enter    cross_type    N
    OUCH.Set Ouch Field    n_c_enter    customer_type    R
    OUCH.Send Client Message    client_a    n_c_enter

    Comment    <- OrderAccepted

    OUCH.Create Soup Message    n_s_accepted    S
    OUCH.Set Ouch Type    n_s_accepted    A
    OUCH.Set Ouch Field    n_s_accepted    timestamp    11001
    OUCH.Set Ouch Field    n_s_accepted    order_token    TEST_N1
    OUCH.Set Ouch Field    n_s_accepted    buy_sell_indicator    S
    OUCH.Set Ouch Field    n_s_accepted    shares    1000
    OUCH.Set Ouch Field    n_s_accepted    stock    ZVZZT
    OUCH.Set Ouch Field    n_s_accepted    price    123456
    OUCH.Set Ouch Field    n_s_accepted    time_in_force    86400
    OUCH.Set Ouch Field    n_s_accepted    firm    FIRM
    OUCH.Set Ouch Field    n_s_accepted    display    A
    OUCH.Set Ouch Field    n_s_accepted    order_reference_number    111
    OUCH.Set Ouch Field    n_s_accepted    capacity    A
    OUCH.Set Ouch Field    n_s_accepted    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    n_s_accepted    minimum_quantity    100
    OUCH.Set Ouch Field    n_s_accepted    cross_type    N
    OUCH.Set Ouch Field    n_s_accepted    order_state    L
    OUCH.Set Ouch Field    n_s_accepted    bbo_weight_indicator    S
    OUCH.Send Server Message    session_a    n_s_accepted

    Comment    -> ModifyOrder

    OUCH.Create Soup Message    n_c_modify    U
    OUCH.Set Ouch Type    n_c_modify    M
    OUCH.Set Ouch Field    n_c_modify    order_token    TEST_N1
    OUCH.Set Ouch Field    n_c_modify    buy_sell_indicator    E
    OUCH.Set Ouch Field    n_c_modify    shares    1000
    OUCH.Send Client Message    client_a    n_c_modify

    Comment    <- OrderModified

    OUCH.Create Soup Message    n_s_modified    S
    OUCH.Set Ouch Type    n_s_modified    M
    OUCH.Set Ouch Field    n_s_modified    timestamp    11002
    OUCH.Set Ouch Field    n_s_modified    order_token    TEST_N1
    OUCH.Set Ouch Field    n_s_modified    buy_sell_indicator    E
    OUCH.Set Ouch Field    n_s_modified    shares    1000
    OUCH.Send Server Message    session_a    n_s_modified

    Comment    <- Executed (full)

    OUCH.Create Soup Message    n_s_executed    S
    OUCH.Set Ouch Type    n_s_executed    E
    OUCH.Set Ouch Field    n_s_executed    timestamp    11003
    OUCH.Set Ouch Field    n_s_executed    order_token    TEST_N1
    OUCH.Set Ouch Field    n_s_executed    executed_shares    1000
    OUCH.Set Ouch Field    n_s_executed    execution_price    123456
    OUCH.Set Ouch Field    n_s_executed    liquidity_flag     A
    OUCH.Set Ouch Field    n_s_executed    match_number     111
    OUCH.Send Server Message    session_a    n_s_executed



    Comment    -> EnterOrder

    OUCH.Create Soup Message    o_c_enter    U
    OUCH.Set Ouch Type    o_c_enter    O
    OUCH.Set Ouch Field    o_c_enter    order_token    TEST_O1
    OUCH.Set Ouch Field    o_c_enter    buy_sell_indicator    S
    OUCH.Set Ouch Field    o_c_enter    shares    1000
    OUCH.Set Ouch Field    o_c_enter    stock    ZVZZT
    OUCH.Set Ouch Field    o_c_enter    price    123456
    OUCH.Set Ouch Field    o_c_enter    time_in_force    86400
    OUCH.Set Ouch Field    o_c_enter    firm    FIRM
    OUCH.Set Ouch Field    o_c_enter    display    A
    OUCH.Set Ouch Field    o_c_enter    capacity    A
    OUCH.Set Ouch Field    o_c_enter    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    o_c_enter    minimum_quantity    100
    OUCH.Set Ouch Field    o_c_enter    cross_type    N
    OUCH.Set Ouch Field    o_c_enter    customer_type    R
    OUCH.Send Client Message    client_a    o_c_enter

    Comment    <- OrderAccepted

    OUCH.Create Soup Message    o_s_accepted    S
    OUCH.Set Ouch Type    o_s_accepted    A
    OUCH.Set Ouch Field    o_s_accepted    timestamp    12001
    OUCH.Set Ouch Field    o_s_accepted    order_token    TEST_O1
    OUCH.Set Ouch Field    o_s_accepted    buy_sell_indicator    S
    OUCH.Set Ouch Field    o_s_accepted    shares    1000
    OUCH.Set Ouch Field    o_s_accepted    stock    ZVZZT
    OUCH.Set Ouch Field    o_s_accepted    price    123456
    OUCH.Set Ouch Field    o_s_accepted    time_in_force    86400
    OUCH.Set Ouch Field    o_s_accepted    firm    FIRM
    OUCH.Set Ouch Field    o_s_accepted    display    A
    OUCH.Set Ouch Field    o_s_accepted    order_reference_number    121
    OUCH.Set Ouch Field    o_s_accepted    capacity    A
    OUCH.Set Ouch Field    o_s_accepted    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    o_s_accepted    minimum_quantity    100
    OUCH.Set Ouch Field    o_s_accepted    cross_type    N
    OUCH.Set Ouch Field    o_s_accepted    order_state    L
    OUCH.Set Ouch Field    o_s_accepted    bbo_weight_indicator    S
    OUCH.Send Server Message    session_a    o_s_accepted

    Comment    -> ModifyOrder

    OUCH.Create Soup Message    o_c_modify    U
    OUCH.Set Ouch Type    o_c_modify    M
    OUCH.Set Ouch Field    o_c_modify    order_token    TEST_O1
    OUCH.Set Ouch Field    o_c_modify    buy_sell_indicator    E
    OUCH.Set Ouch Field    o_c_modify    shares    1000
    OUCH.Send Client Message    client_a    o_c_modify

    Comment    <- OrderModified

    OUCH.Create Soup Message    o_s_modified    S
    OUCH.Set Ouch Type    o_s_modified    M
    OUCH.Set Ouch Field    o_s_modified    timestamp    12002
    OUCH.Set Ouch Field    o_s_modified    order_token    TEST_O1
    OUCH.Set Ouch Field    o_s_modified    buy_sell_indicator    E
    OUCH.Set Ouch Field    o_s_modified    shares    1000
    OUCH.Send Server Message    session_a    o_s_modified

    Comment    <- OrderCanceled

    OUCH.Create Soup Message    o_s_canceled    S
    OUCH.Set Ouch Type    o_s_canceled    C
    OUCH.Set Ouch Field    o_s_canceled    timestamp    12003
    OUCH.Set Ouch Field    o_s_canceled    order_token    TEST_O1
    OUCH.Set Ouch Field    o_s_canceled    decrement_shares    1000
    OUCH.Set Ouch Field    o_s_canceled    reason    S
    OUCH.Send Server Message    session_a    o_s_canceled



    Comment    -> EnterOrder

    OUCH.Create Soup Message    p_c_enter    U
    OUCH.Set Ouch Type    p_c_enter    O
    OUCH.Set Ouch Field    p_c_enter    order_token    TEST_P1
    OUCH.Set Ouch Field    p_c_enter    buy_sell_indicator    S
    OUCH.Set Ouch Field    p_c_enter    shares    1000
    OUCH.Set Ouch Field    p_c_enter    stock    ZVZZT
    OUCH.Set Ouch Field    p_c_enter    price    123456
    OUCH.Set Ouch Field    p_c_enter    time_in_force    86400
    OUCH.Set Ouch Field    p_c_enter    firm    FIRM
    OUCH.Set Ouch Field    p_c_enter    display    A
    OUCH.Set Ouch Field    p_c_enter    capacity    A
    OUCH.Set Ouch Field    p_c_enter    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    p_c_enter    minimum_quantity    100
    OUCH.Set Ouch Field    p_c_enter    cross_type    N
    OUCH.Set Ouch Field    p_c_enter    customer_type    R
    OUCH.Send Client Message    client_a    p_c_enter

    Comment    <- OrderAccepted

    OUCH.Create Soup Message    p_s_accepted    S
    OUCH.Set Ouch Type    p_s_accepted    A
    OUCH.Set Ouch Field    p_s_accepted    timestamp    13001
    OUCH.Set Ouch Field    p_s_accepted    order_token    TEST_P1
    OUCH.Set Ouch Field    p_s_accepted    buy_sell_indicator    S
    OUCH.Set Ouch Field    p_s_accepted    shares    1000
    OUCH.Set Ouch Field    p_s_accepted    stock    ZVZZT
    OUCH.Set Ouch Field    p_s_accepted    price    123456
    OUCH.Set Ouch Field    p_s_accepted    time_in_force    86400
    OUCH.Set Ouch Field    p_s_accepted    firm    FIRM
    OUCH.Set Ouch Field    p_s_accepted    display    A
    OUCH.Set Ouch Field    p_s_accepted    order_reference_number    131
    OUCH.Set Ouch Field    p_s_accepted    capacity    A
    OUCH.Set Ouch Field    p_s_accepted    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    p_s_accepted    minimum_quantity    100
    OUCH.Set Ouch Field    p_s_accepted    cross_type    N
    OUCH.Set Ouch Field    p_s_accepted    order_state    L
    OUCH.Set Ouch Field    p_s_accepted    bbo_weight_indicator    S
    OUCH.Send Server Message    session_a    p_s_accepted

    Comment    -> CancelOrder

    OUCH.Create Soup Message    p_c_cancel    U
    OUCH.Set Ouch Type    p_c_cancel    X
    OUCH.Set Ouch Field    p_c_cancel    order_token    TEST_P1
    OUCH.Set Ouch Field    p_c_cancel    shares    0
    OUCH.Send Client Message    client_a    p_c_cancel

    Comment    <- CancelPending

    OUCH.Create Soup Message    p_s_pending    S
    OUCH.Set Ouch Type    p_s_pending    P
    OUCH.Set Ouch Field    p_s_pending    timestamp    13002
    OUCH.Set Ouch Field    p_s_pending    order_token    TEST_P1
    OUCH.Send Server Message    session_a    p_s_pending

    Comment    <- OrderCanceled

    OUCH.Create Soup Message    p_s_canceled    S
    OUCH.Set Ouch Type    p_s_canceled    C
    OUCH.Set Ouch Field    p_s_canceled    timestamp    13003
    OUCH.Set Ouch Field    p_s_canceled    order_token    TEST_P1
    OUCH.Set Ouch Field    p_s_canceled    decrement_shares    1000
    OUCH.Set Ouch Field    p_s_canceled    reason    S
    OUCH.Send Server Message    session_a    p_s_canceled



    Comment    -> EnterOrder

    OUCH.Create Soup Message    q_c_enter    U
    OUCH.Set Ouch Type    q_c_enter    O
    OUCH.Set Ouch Field    q_c_enter    order_token    TEST_Q1
    OUCH.Set Ouch Field    q_c_enter    buy_sell_indicator    S
    OUCH.Set Ouch Field    q_c_enter    shares    1000
    OUCH.Set Ouch Field    q_c_enter    stock    ZVZZT
    OUCH.Set Ouch Field    q_c_enter    price    123456
    OUCH.Set Ouch Field    q_c_enter    time_in_force    86400
    OUCH.Set Ouch Field    q_c_enter    firm    FIRM
    OUCH.Set Ouch Field    q_c_enter    display    A
    OUCH.Set Ouch Field    q_c_enter    capacity    A
    OUCH.Set Ouch Field    q_c_enter    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    q_c_enter    minimum_quantity    100
    OUCH.Set Ouch Field    q_c_enter    cross_type    N
    OUCH.Set Ouch Field    q_c_enter    customer_type    R
    OUCH.Send Client Message    client_a    q_c_enter

    Comment    <- OrderAccepted

    OUCH.Create Soup Message    q_s_accepted    S
    OUCH.Set Ouch Type    q_s_accepted    A
    OUCH.Set Ouch Field    q_s_accepted    timestamp    14001
    OUCH.Set Ouch Field    q_s_accepted    order_token    TEST_Q1
    OUCH.Set Ouch Field    q_s_accepted    buy_sell_indicator    S
    OUCH.Set Ouch Field    q_s_accepted    shares    1000
    OUCH.Set Ouch Field    q_s_accepted    stock    ZVZZT
    OUCH.Set Ouch Field    q_s_accepted    price    123456
    OUCH.Set Ouch Field    q_s_accepted    time_in_force    86400
    OUCH.Set Ouch Field    q_s_accepted    firm    FIRM
    OUCH.Set Ouch Field    q_s_accepted    display    A
    OUCH.Set Ouch Field    q_s_accepted    order_reference_number    141
    OUCH.Set Ouch Field    q_s_accepted    capacity    A
    OUCH.Set Ouch Field    q_s_accepted    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    q_s_accepted    minimum_quantity    100
    OUCH.Set Ouch Field    q_s_accepted    cross_type    N
    OUCH.Set Ouch Field    q_s_accepted    order_state    L
    OUCH.Set Ouch Field    q_s_accepted    bbo_weight_indicator    S
    OUCH.Send Server Message    session_a    q_s_accepted

    Comment    -> CancelOrder (partial)

    OUCH.Create Soup Message    q_c_cancel    U
    OUCH.Set Ouch Type    q_c_cancel    X
    OUCH.Set Ouch Field    q_c_cancel    order_token    TEST_Q1
    OUCH.Set Ouch Field    q_c_cancel    shares    500
    OUCH.Send Client Message    client_a    q_c_cancel

    Comment    <- Executed (full)

    OUCH.Create Soup Message    q_s_executed    S
    OUCH.Set Ouch Type    q_s_executed    E
    OUCH.Set Ouch Field    q_s_executed    timestamp    14002
    OUCH.Set Ouch Field    q_s_executed    order_token    TEST_Q1
    OUCH.Set Ouch Field    q_s_executed    executed_shares    1000
    OUCH.Set Ouch Field    q_s_executed    execution_price    123456
    OUCH.Set Ouch Field    q_s_executed    liquidity_flag     A
    OUCH.Set Ouch Field    q_s_executed    match_number     141
    OUCH.Send Server Message    session_a    q_s_executed

    Comment    <- CancelReject

    OUCH.Create Soup Message    q_s_cancelreject    S
    OUCH.Set Ouch Type    q_s_cancelreject    I
    OUCH.Set Ouch Field    q_s_cancelreject    timestamp    14003
    OUCH.Set Ouch Field    q_s_cancelreject    order_token    TEST_Q1
    OUCH.Send Server Message    session_a    q_s_cancelreject



    Comment    -> EnterOrder

    OUCH.Create Soup Message    r_c_enter    U
    OUCH.Set Ouch Type    r_c_enter    O
    OUCH.Set Ouch Field    r_c_enter    order_token    TEST_R1
    OUCH.Set Ouch Field    r_c_enter    buy_sell_indicator    S
    OUCH.Set Ouch Field    r_c_enter    shares    1000
    OUCH.Set Ouch Field    r_c_enter    stock    ZVZZT
    OUCH.Set Ouch Field    r_c_enter    price    123456
    OUCH.Set Ouch Field    r_c_enter    time_in_force    86400
    OUCH.Set Ouch Field    r_c_enter    firm    FIRM
    OUCH.Set Ouch Field    r_c_enter    display    A
    OUCH.Set Ouch Field    r_c_enter    capacity    A
    OUCH.Set Ouch Field    r_c_enter    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    r_c_enter    minimum_quantity    100
    OUCH.Set Ouch Field    r_c_enter    cross_type    N
    OUCH.Set Ouch Field    r_c_enter    customer_type    R
    OUCH.Send Client Message    client_a    r_c_enter

    Comment    <- OrderAccepted

    OUCH.Create Soup Message    r_s_accepted    S
    OUCH.Set Ouch Type    r_s_accepted    A
    OUCH.Set Ouch Field    r_s_accepted    timestamp    15001
    OUCH.Set Ouch Field    r_s_accepted    order_token    TEST_R1
    OUCH.Set Ouch Field    r_s_accepted    buy_sell_indicator    S
    OUCH.Set Ouch Field    r_s_accepted    shares    1000
    OUCH.Set Ouch Field    r_s_accepted    stock    ZVZZT
    OUCH.Set Ouch Field    r_s_accepted    price    123456
    OUCH.Set Ouch Field    r_s_accepted    time_in_force    86400
    OUCH.Set Ouch Field    r_s_accepted    firm    FIRM
    OUCH.Set Ouch Field    r_s_accepted    display    A
    OUCH.Set Ouch Field    r_s_accepted    order_reference_number    151
    OUCH.Set Ouch Field    r_s_accepted    capacity    A
    OUCH.Set Ouch Field    r_s_accepted    intermarket_sweep_eligibility    N
    OUCH.Set Ouch Field    r_s_accepted    minimum_quantity    100
    OUCH.Set Ouch Field    r_s_accepted    cross_type    N
    OUCH.Set Ouch Field    r_s_accepted    order_state    L
    OUCH.Set Ouch Field    r_s_accepted    bbo_weight_indicator    S
    OUCH.Send Server Message    session_a    r_s_accepted

    Comment    <- OrderPriorityUpdate

    OUCH.Create Soup Message    r_s_update    S
    OUCH.Set Ouch Type    r_s_update    T
    OUCH.Set Ouch Field    r_s_update    timestamp    15002
    OUCH.Set Ouch Field    r_s_update    order_token    TEST_R1
    OUCH.Set Ouch Field    r_s_update    price    123456
    OUCH.Set Ouch Field    r_s_update    display    A
    OUCH.Set Ouch Field    r_s_update    order_reference_number    151
    OUCH.Send Server Message    session_a    r_s_update

    Comment    <- Executed (full)

    OUCH.Create Soup Message    r_s_executed    S
    OUCH.Set Ouch Type    r_s_executed    E
    OUCH.Set Ouch Field    r_s_executed    timestamp    15003
    OUCH.Set Ouch Field    r_s_executed    order_token    TEST_R1
    OUCH.Set Ouch Field    r_s_executed    executed_shares    1000
    OUCH.Set Ouch Field    r_s_executed    execution_price    123456
    OUCH.Set Ouch Field    r_s_executed    liquidity_flag     A
    OUCH.Set Ouch Field    r_s_executed    match_number     151
    OUCH.Send Server Message    session_a    r_s_executed



    Comment    <- SystemEvent (end)

    OUCH.Create Soup Message    s_s_system_e    S
    OUCH.Set Ouch Type    s_s_system_e    S
    OUCH.Set Ouch Field    s_s_system_e    timestamp    16001
    OUCH.Set Ouch Field    s_s_system_e    event_code    E
    OUCH.Send Server Message    session_a    s_s_system_e


    Comment    -> Logout

    OUCH.Create Soup Message    t_c_logout    O
    OUCH.Send Client Message    client_a    t_c_logout


    OUCH.Disconnect Server Session    session_a
    OUCH.Disconnect Client    client_a
    OUCH.Destroy Client    client_a
