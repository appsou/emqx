%%--------------------------------------------------------------------
%% Copyright (c) 2021 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(emqx_gateway_conf_SUITE).

-compile(export_all).
-compile(nowarn_export_all).

-import(emqx_gateway_test_utils,
        [ assert_confs/2
        , maybe_unconvert_listeners/1
        ]).

-include_lib("eunit/include/eunit.hrl").

%%--------------------------------------------------------------------
%% Setups
%%--------------------------------------------------------------------

all() ->
    emqx_common_test_helpers:all(?MODULE).

init_per_suite(Conf) ->
    emqx_config:init_load(emqx_gateway_schema, <<"gateway {}">>),
    emqx_common_test_helpers:start_apps([emqx_conf, emqx_authn, emqx_gateway]),
    Conf.

end_per_suite(_Conf) ->
    emqx_common_test_helpers:stop_apps([emqx_gateway, emqx_authn, emqx_conf]).

init_per_testcase(_CaseName, Conf) ->
    _ = emqx_gateway_conf:unload_gateway(stomp),
    Conf.

%%--------------------------------------------------------------------
%% Cases
%%--------------------------------------------------------------------

-define(SVR_CA,
<<"-----BEGIN CERTIFICATE-----
MIIDUTCCAjmgAwIBAgIJAPPYCjTmxdt/MA0GCSqGSIb3DQEBCwUAMD8xCzAJBgNV
BAYTAkNOMREwDwYDVQQIDAhoYW5nemhvdTEMMAoGA1UECgwDRU1RMQ8wDQYDVQQD
DAZSb290Q0EwHhcNMjAwNTA4MDgwNjUyWhcNMzAwNTA2MDgwNjUyWjA/MQswCQYD
VQQGEwJDTjERMA8GA1UECAwIaGFuZ3pob3UxDDAKBgNVBAoMA0VNUTEPMA0GA1UE
AwwGUm9vdENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzcgVLex1
EZ9ON64EX8v+wcSjzOZpiEOsAOuSXOEN3wb8FKUxCdsGrsJYB7a5VM/Jot25Mod2
juS3OBMg6r85k2TWjdxUoUs+HiUB/pP/ARaaW6VntpAEokpij/przWMPgJnBF3Ur
MjtbLayH9hGmpQrI5c2vmHQ2reRZnSFbY+2b8SXZ+3lZZgz9+BaQYWdQWfaUWEHZ
uDaNiViVO0OT8DRjCuiDp3yYDj3iLWbTA/gDL6Tf5XuHuEwcOQUrd+h0hyIphO8D
tsrsHZ14j4AWYLk1CPA6pq1HIUvEl2rANx2lVUNv+nt64K/Mr3RnVQd9s8bK+TXQ
KGHd2Lv/PALYuwIDAQABo1AwTjAdBgNVHQ4EFgQUGBmW+iDzxctWAWxmhgdlE8Pj
EbQwHwYDVR0jBBgwFoAUGBmW+iDzxctWAWxmhgdlE8PjEbQwDAYDVR0TBAUwAwEB
/zANBgkqhkiG9w0BAQsFAAOCAQEAGbhRUjpIred4cFAFJ7bbYD9hKu/yzWPWkMRa
ErlCKHmuYsYk+5d16JQhJaFy6MGXfLgo3KV2itl0d+OWNH0U9ULXcglTxy6+njo5
CFqdUBPwN1jxhzo9yteDMKF4+AHIxbvCAJa17qcwUKR5MKNvv09C6pvQDJLzid7y
E2dkgSuggik3oa0427KvctFf8uhOV94RvEDyqvT5+pgNYZ2Yfga9pD/jjpoHEUlo
88IGU8/wJCx3Ds2yc8+oBg/ynxG8f/HmCC1ET6EHHoe2jlo8FpU/SgGtghS1YL30
IWxNsPrUP+XsZpBJy/mvOhE5QXo6Y35zDqqj8tI7AGmAWu22jg==
-----END CERTIFICATE-----
">>).

-define(SVR_CERT,
<<"-----BEGIN CERTIFICATE-----
MIIDEzCCAfugAwIBAgIBAjANBgkqhkiG9w0BAQsFADA/MQswCQYDVQQGEwJDTjER
MA8GA1UECAwIaGFuZ3pob3UxDDAKBgNVBAoMA0VNUTEPMA0GA1UEAwwGUm9vdENB
MB4XDTIwMDUwODA4MDcwNVoXDTMwMDUwNjA4MDcwNVowPzELMAkGA1UEBhMCQ04x
ETAPBgNVBAgMCGhhbmd6aG91MQwwCgYDVQQKDANFTVExDzANBgNVBAMMBlNlcnZl
cjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALNeWT3pE+QFfiRJzKmn
AMUrWo3K2j/Tm3+Xnl6WLz67/0rcYrJbbKvS3uyRP/stXyXEKw9CepyQ1ViBVFkW
Aoy8qQEOWFDsZc/5UzhXUnb6LXr3qTkFEjNmhj+7uzv/lbBxlUG1NlYzSeOB6/RT
8zH/lhOeKhLnWYPXdXKsa1FL6ij4X8DeDO1kY7fvAGmBn/THh1uTpDizM4YmeI+7
4dmayA5xXvARte5h4Vu5SIze7iC057N+vymToMk2Jgk+ZZFpyXrnq+yo6RaD3ANc
lrc4FbeUQZ5a5s5Sxgs9a0Y3WMG+7c5VnVXcbjBRz/aq2NtOnQQjikKKQA8GF080
BQkCAwEAAaMaMBgwCQYDVR0TBAIwADALBgNVHQ8EBAMCBeAwDQYJKoZIhvcNAQEL
BQADggEBAJefnMZpaRDHQSNUIEL3iwGXE9c6PmIsQVE2ustr+CakBp3TZ4l0enLt
iGMfEVFju69cO4oyokWv+hl5eCMkHBf14Kv51vj448jowYnF1zmzn7SEzm5Uzlsa
sqjtAprnLyof69WtLU1j5rYWBuFX86yOTwRAFNjm9fvhAcrEONBsQtqipBWkMROp
iUYMkRqbKcQMdwxov+lHBYKq9zbWRoqLROAn54SRqgQk6c15JdEfgOOjShbsOkIH
UhqcwRkQic7n1zwHVGVDgNIZVgmJ2IdIWBlPEC7oLrRrBD/X1iEEXtKab6p5o22n
KB5mN+iQaE+Oe2cpGKZJiJRdM+IqDDQ=
-----END CERTIFICATE-----
">>).

-define(SVR_KEY,
<<"-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAs15ZPekT5AV+JEnMqacAxStajcraP9Obf5eeXpYvPrv/Stxi
sltsq9Le7JE/+y1fJcQrD0J6nJDVWIFUWRYCjLypAQ5YUOxlz/lTOFdSdvotevep
OQUSM2aGP7u7O/+VsHGVQbU2VjNJ44Hr9FPzMf+WE54qEudZg9d1cqxrUUvqKPhf
wN4M7WRjt+8AaYGf9MeHW5OkOLMzhiZ4j7vh2ZrIDnFe8BG17mHhW7lIjN7uILTn
s36/KZOgyTYmCT5lkWnJeuer7KjpFoPcA1yWtzgVt5RBnlrmzlLGCz1rRjdYwb7t
zlWdVdxuMFHP9qrY206dBCOKQopADwYXTzQFCQIDAQABAoIBAQCuvCbr7Pd3lvI/
n7VFQG+7pHRe1VKwAxDkx2t8cYos7y/QWcm8Ptwqtw58HzPZGWYrgGMCRpzzkRSF
V9g3wP1S5Scu5C6dBu5YIGc157tqNGXB+SpdZddJQ4Nc6yGHXYERllT04ffBGc3N
WG/oYS/1cSteiSIrsDy/91FvGRCi7FPxH3wIgHssY/tw69s1Cfvaq5lr2NTFzxIG
xCvpJKEdSfVfS9I7LYiymVjst3IOR/w76/ZFY9cRa8ZtmQSWWsm0TUpRC1jdcbkm
ZoJptYWlP+gSwx/fpMYftrkJFGOJhHJHQhwxT5X/ajAISeqjjwkWSEJLwnHQd11C
Zy2+29lBAoGBANlEAIK4VxCqyPXNKfoOOi5dS64NfvyH4A1v2+KaHWc7lqaqPN49
ezfN2n3X+KWx4cviDD914Yc2JQ1vVJjSaHci7yivocDo2OfZDmjBqzaMp/y+rX1R
/f3MmiTqMa468rjaxI9RRZu7vDgpTR+za1+OBCgMzjvAng8dJuN/5gjlAoGBANNY
uYPKtearBmkqdrSV7eTUe49Nhr0XotLaVBH37TCW0Xv9wjO2xmbm5Ga/DCtPIsBb
yPeYwX9FjoasuadUD7hRvbFu6dBa0HGLmkXRJZTcD7MEX2Lhu4BuC72yDLLFd0r+
Ep9WP7F5iJyagYqIZtz+4uf7gBvUDdmvXz3sGr1VAoGAdXTD6eeKeiI6PlhKBztF
zOb3EQOO0SsLv3fnodu7ZaHbUgLaoTMPuB17r2jgrYM7FKQCBxTNdfGZmmfDjlLB
0xZ5wL8ibU30ZXL8zTlWPElST9sto4B+FYVVF/vcG9sWeUUb2ncPcJ/Po3UAktDG
jYQTTyuNGtSJHpad/YOZctkCgYBtWRaC7bq3of0rJGFOhdQT9SwItN/lrfj8hyHA
OjpqTV4NfPmhsAtu6j96OZaeQc+FHvgXwt06cE6Rt4RG4uNPRluTFgO7XYFDfitP
vCppnoIw6S5BBvHwPP+uIhUX2bsi/dm8vu8tb+gSvo4PkwtFhEr6I9HglBKmcmog
q6waEQKBgHyecFBeM6Ls11Cd64vborwJPAuxIW7HBAFj/BS99oeG4TjBx4Sz2dFd
rzUibJt4ndnHIvCN8JQkjNG14i9hJln+H3mRss8fbZ9vQdqG+2vOWADYSzzsNI55
RFY7JjluKcVkp/zCDeUxTU3O6sS+v6/3VE11Cob6OYQx3lN5wrZ3
-----END RSA PRIVATE KEY-----
">>).

-define(SVR_CERT2,
<<"-----BEGIN CERTIFICATE-----
MIIDEzCCAfugAwIBAgIBATANBgkqhkiG9w0BAQsFADA/MQswCQYDVQQGEwJDTjER
MA8GA1UECAwIaGFuZ3pob3UxDDAKBgNVBAoMA0VNUTEPMA0GA1UEAwwGUm9vdENB
MB4XDTIwMDUwODA4MDY1N1oXDTMwMDUwNjA4MDY1N1owPzELMAkGA1UEBhMCQ04x
ETAPBgNVBAgMCGhhbmd6aG91MQwwCgYDVQQKDANFTVExDzANBgNVBAMMBkNsaWVu
dDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMy4hoksKcZBDbY680u6
TS25U51nuB1FBcGMlF9B/t057wPOlxF/OcmbxY5MwepS41JDGPgulE1V7fpsXkiW
1LUimYV/tsqBfymIe0mlY7oORahKji7zKQ2UBIVFhdlvQxunlIDnw6F9popUgyHt
dMhtlgZK8oqRwHxO5dbfoukYd6J/r+etS5q26sgVkf3C6dt0Td7B25H9qW+f7oLV
PbcHYCa+i73u9670nrpXsC+Qc7Mygwa2Kq/jwU+ftyLQnOeW07DuzOwsziC/fQZa
nbxR+8U9FNftgRcC3uP/JMKYUqsiRAuaDokARZxVTV5hUElfpO6z6/NItSDvvh3i
eikCAwEAAaMaMBgwCQYDVR0TBAIwADALBgNVHQ8EBAMCBeAwDQYJKoZIhvcNAQEL
BQADggEBABchYxKo0YMma7g1qDswJXsR5s56Czx/I+B41YcpMBMTrRqpUC0nHtLk
M7/tZp592u/tT8gzEnQjZLKBAhFeZaR3aaKyknLqwiPqJIgg0pgsBGITrAK3Pv4z
5/YvAJJKgTe5UdeTz6U4lvNEux/4juZ4pmqH4qSFJTOzQS7LmgSmNIdd072rwXBd
UzcSHzsJgEMb88u/LDLjj1pQ7AtZ4Tta8JZTvcgBFmjB0QUi6fgkHY6oGat/W4kR
jSRUBlMUbM/drr2PVzRc2dwbFIl3X+ZE6n5Sl3ZwRAC/s92JU6CPMRW02muVu6xl
goraNgPISnrbpR6KjxLZkVembXzjNNc=
-----END CERTIFICATE-----
">>).

-define(SVR_KEY2,
<<"-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAzLiGiSwpxkENtjrzS7pNLblTnWe4HUUFwYyUX0H+3TnvA86X
EX85yZvFjkzB6lLjUkMY+C6UTVXt+mxeSJbUtSKZhX+2yoF/KYh7SaVjug5FqEqO
LvMpDZQEhUWF2W9DG6eUgOfDoX2milSDIe10yG2WBkryipHAfE7l1t+i6Rh3on+v
561LmrbqyBWR/cLp23RN3sHbkf2pb5/ugtU9twdgJr6Lve73rvSeulewL5BzszKD
BrYqr+PBT5+3ItCc55bTsO7M7CzOIL99BlqdvFH7xT0U1+2BFwLe4/8kwphSqyJE
C5oOiQBFnFVNXmFQSV+k7rPr80i1IO++HeJ6KQIDAQABAoIBAGWgvPjfuaU3qizq
uti/FY07USz0zkuJdkANH6LiSjlchzDmn8wJ0pApCjuIE0PV/g9aS8z4opp5q/gD
UBLM/a8mC/xf2EhTXOMrY7i9p/I3H5FZ4ZehEqIw9sWKK9YzC6dw26HabB2BGOnW
5nozPSQ6cp2RGzJ7BIkxSZwPzPnVTgy3OAuPOiJytvK+hGLhsNaT+Y9bNDvplVT2
ZwYTV8GlHZC+4b2wNROILm0O86v96O+Qd8nn3fXjGHbMsAnONBq10bZS16L4fvkH
5G+W/1PeSXmtZFppdRRDxIW+DWcXK0D48WRliuxcV4eOOxI+a9N2ZJZZiNLQZGwg
w3A8+mECgYEA8HuJFrlRvdoBe2U/EwUtG74dcyy30L4yEBnN5QscXmEEikhaQCfX
Wm6EieMcIB/5I5TQmSw0cmBMeZjSXYoFdoI16/X6yMMuATdxpvhOZGdUGXxhAH+x
xoTUavWZnEqW3fkUU71kT5E2f2i+0zoatFESXHeslJyz85aAYpP92H0CgYEA2e5A
Yozt5eaA1Gyhd8SeptkEU4xPirNUnVQHStpMWUb1kzTNXrPmNWccQ7JpfpG6DcYl
zUF6p6mlzY+zkMiyPQjwEJlhiHM2NlL1QS7td0R8ewgsFoyn8WsBI4RejWrEG9td
EDniuIw+pBFkcWthnTLHwECHdzgquToyTMjrBB0CgYEA28tdGbrZXhcyAZEhHAZA
Gzog+pKlkpEzeonLKIuGKzCrEKRecIK5jrqyQsCjhS0T7ZRnL4g6i0s+umiV5M5w
fcc292pEA1h45L3DD6OlKplSQVTv55/OYS4oY3YEJtf5mfm8vWi9lQeY8sxOlQpn
O+VZTdBHmTC8PGeTAgZXHZUCgYA6Tyv88lYowB7SN2qQgBQu8jvdGtqhcs/99GCr
H3N0I69LPsKAR0QeH8OJPXBKhDUywESXAaEOwS5yrLNP1tMRz5Vj65YUCzeDG3kx
gpvY4IMp7ArX0bSRvJ6mYSFnVxy3k174G3TVCfksrtagHioVBGQ7xUg5ltafjrms
n8l55QKBgQDVzU8tQvBVqY8/1lnw11Vj4fkE/drZHJ5UkdC1eenOfSWhlSLfUJ8j
ds7vEWpRPPoVuPZYeR1y78cyxKe1GBx6Wa2lF5c7xjmiu0xbRnrxYeLolce9/ntp
asClqpnHT8/VJYTD7Kqj0fouTTZf0zkig/y+2XERppd8k+pSKjUCPQ==
-----END RSA PRIVATE KEY-----
">>).

-define(CONF_STOMP_BAISC_1,
        #{ <<"idle_timeout">> => <<"10s">>,
           <<"mountpoint">> => <<"t/">>,
           <<"frame">> =>
           #{ <<"max_headers">> => 20,
              <<"max_headers_length">> => 2000,
              <<"max_body_length">> => 2000
            }
         }).
-define(CONF_STOMP_BAISC_2,
        #{ <<"idle_timeout">> => <<"20s">>,
           <<"mountpoint">> => <<"t2/">>,
           <<"frame">> =>
           #{ <<"max_headers">> => 30,
              <<"max_headers_length">> => 3000,
              <<"max_body_length">> => 3000
            }
         }).
-define(CONF_STOMP_LISTENER_1,
        #{ <<"bind">> => <<"61613">>
         }).
-define(CONF_STOMP_LISTENER_2,
        #{ <<"bind">> => <<"61614">>
         }).
-define(CONF_STOMP_LISTENER_SSL,
        #{ <<"bind">> => <<"61614">>,
           <<"ssl">> =>
           #{ <<"cacertfile">> => ?SVR_CA,
              <<"certfile">> => ?SVR_CERT,
              <<"keyfile">> => ?SVR_KEY
            }
         }).
-define(CONF_STOMP_LISTENER_SSL_2,
        #{ <<"bind">> => <<"61614">>,
           <<"ssl">> =>
           #{ <<"cacertfile">> => ?SVR_CA,
              <<"certfile">> => ?SVR_CERT2,
              <<"keyfile">> => ?SVR_KEY2
            }
         }).
-define(CERTS_PATH(CertName), filename:join(["../../lib/emqx/etc/certs/", CertName])).
-define(CONF_STOMP_LISTENER_SSL_PATH,
        #{ <<"bind">> => <<"61614">>,
           <<"ssl">> =>
           #{ <<"cacertfile">> => ?CERTS_PATH("cacert.pem"),
              <<"certfile">> => ?CERTS_PATH("cert.pem"),
              <<"keyfile">> => ?CERTS_PATH("key.pem")
            }
         }).
-define(CONF_STOMP_AUTHN_1,
        #{ <<"mechanism">> => <<"password-based">>,
           <<"backend">> => <<"built-in-database">>,
           <<"user_id_type">> => <<"clientid">>
         }).
-define(CONF_STOMP_AUTHN_2,
        #{ <<"mechanism">> => <<"password-based">>,
           <<"backend">> => <<"built-in-database">>,
           <<"user_id_type">> => <<"username">>
         }).

t_load_unload_gateway(_) ->
    StompConf1 = compose(?CONF_STOMP_BAISC_1,
                         ?CONF_STOMP_AUTHN_1,
                         ?CONF_STOMP_LISTENER_1
                        ),
    StompConf2 = compose(?CONF_STOMP_BAISC_2,
                         ?CONF_STOMP_AUTHN_1,
                         ?CONF_STOMP_LISTENER_1),
    {ok, _} = emqx_gateway_conf:load_gateway(stomp, StompConf1),
    ?assertMatch(
       {error, {badres, #{reason := already_exist}}},
       emqx_gateway_conf:load_gateway(stomp, StompConf1)),
    assert_confs(StompConf1, emqx:get_raw_config([gateway, stomp])),

    {ok, _} = emqx_gateway_conf:update_gateway(stomp, StompConf2),
    assert_confs(StompConf2, emqx:get_raw_config([gateway, stomp])),

    ok = emqx_gateway_conf:unload_gateway(stomp),
    ok = emqx_gateway_conf:unload_gateway(stomp),

    ?assertMatch(
       {error, {badres, #{reason := not_found}}},
       emqx_gateway_conf:update_gateway(stomp, StompConf2)),

    ?assertException(error, {config_not_found, [gateway, stomp]},
                     emqx:get_raw_config([gateway, stomp])),
    ok.

t_load_remove_authn(_) ->
    StompConf = compose_listener(?CONF_STOMP_BAISC_1, ?CONF_STOMP_LISTENER_1),

    {ok, _} = emqx_gateway_conf:load_gateway(<<"stomp">>, StompConf),
    assert_confs(StompConf, emqx:get_raw_config([gateway, stomp])),

    {ok, _} = emqx_gateway_conf:add_authn(<<"stomp">>, ?CONF_STOMP_AUTHN_1),
    assert_confs(
      maps:put(<<"authentication">>, ?CONF_STOMP_AUTHN_1, StompConf),
      emqx:get_raw_config([gateway, stomp])),

    {ok, _} = emqx_gateway_conf:update_authn(<<"stomp">>, ?CONF_STOMP_AUTHN_2),
    assert_confs(
      maps:put(<<"authentication">>, ?CONF_STOMP_AUTHN_2, StompConf),
      emqx:get_raw_config([gateway, stomp])),

    ok = emqx_gateway_conf:remove_authn(<<"stomp">>),

    ?assertMatch(
       {error, {badres, #{reason := not_found}}},
       emqx_gateway_conf:update_authn(<<"stomp">>, ?CONF_STOMP_AUTHN_2)),

    ?assertException(
       error, {config_not_found, [gateway, stomp, authentication]},
       emqx:get_raw_config([gateway, stomp, authentication])
      ),
    ok.

t_load_remove_listeners(_) ->
    StompConf = compose_authn(?CONF_STOMP_BAISC_1, ?CONF_STOMP_AUTHN_1),

    {ok, _} = emqx_gateway_conf:load_gateway(<<"stomp">>, StompConf),
    assert_confs(StompConf, emqx:get_raw_config([gateway, stomp])),

    {ok, _} = emqx_gateway_conf:add_listener(
                <<"stomp">>, {<<"tcp">>, <<"default">>},
                ?CONF_STOMP_LISTENER_1),
    assert_confs(
      maps:merge(StompConf, listener(?CONF_STOMP_LISTENER_1)),
      emqx:get_raw_config([gateway, stomp])),

    {ok, _} = emqx_gateway_conf:update_listener(
                <<"stomp">>, {<<"tcp">>, <<"default">>},
                ?CONF_STOMP_LISTENER_2),
    assert_confs(
      maps:merge(StompConf, listener(?CONF_STOMP_LISTENER_2)),
      emqx:get_raw_config([gateway, stomp])),

    ok = emqx_gateway_conf:remove_listener(
           <<"stomp">>, {<<"tcp">>, <<"default">>}),

    ?assertMatch(
       {error, {badres, #{reason := not_found}}},
       emqx_gateway_conf:update_listener(
         <<"stomp">>, {<<"tcp">>, <<"default">>}, ?CONF_STOMP_LISTENER_2)),

    ?assertException(
       error, {config_not_found, [gateway, stomp, listeners, tcp, default]},
       emqx:get_raw_config([gateway, stomp, listeners, tcp, default])
      ),
    ok.

t_load_remove_listener_authn(_) ->
    StompConf  = compose_listener(
                   ?CONF_STOMP_BAISC_1,
                   ?CONF_STOMP_LISTENER_1
                  ),
    StompConf1 = compose_listener_authn(
                   ?CONF_STOMP_BAISC_1,
                   ?CONF_STOMP_LISTENER_1,
                   ?CONF_STOMP_AUTHN_1
                  ),
    StompConf2 = compose_listener_authn(
                   ?CONF_STOMP_BAISC_1,
                   ?CONF_STOMP_LISTENER_1,
                   ?CONF_STOMP_AUTHN_2
                 ),

    {ok, _} = emqx_gateway_conf:load_gateway(<<"stomp">>, StompConf),
    assert_confs(StompConf, emqx:get_raw_config([gateway, stomp])),

    {ok, _} = emqx_gateway_conf:add_authn(
                <<"stomp">>, {<<"tcp">>, <<"default">>}, ?CONF_STOMP_AUTHN_1),
    assert_confs(StompConf1, emqx:get_raw_config([gateway, stomp])),

    {ok, _} = emqx_gateway_conf:update_authn(
                <<"stomp">>, {<<"tcp">>, <<"default">>}, ?CONF_STOMP_AUTHN_2),
    assert_confs(StompConf2, emqx:get_raw_config([gateway, stomp])),

    ok = emqx_gateway_conf:remove_authn(
           <<"stomp">>, {<<"tcp">>, <<"default">>}),

    ?assertMatch(
       {error, {badres, #{reason := not_found}}},
       emqx_gateway_conf:update_authn(
         <<"stomp">>, {<<"tcp">>, <<"default">>}, ?CONF_STOMP_AUTHN_2)),

    Path = [gateway, stomp, listeners, tcp, default, authentication],
    ?assertException(
       error, {config_not_found, Path},
       emqx:get_raw_config(Path)
      ),
    ok.

t_load_gateway_with_certs_content(_) ->
    StompConf = compose_ssl_listener(
                  ?CONF_STOMP_BAISC_1,
                  ?CONF_STOMP_LISTENER_SSL
                 ),
    {ok, _} = emqx_gateway_conf:load_gateway(<<"stomp">>, StompConf),
    assert_confs(StompConf, emqx:get_raw_config([gateway, stomp])),
    SslConf = emqx_map_lib:deep_get(
                [<<"listeners">>, <<"ssl">>, <<"default">>, <<"ssl">>],
                emqx:get_raw_config([gateway, stomp])
               ),
    ok = emqx_gateway_conf:unload_gateway(<<"stomp">>),
    assert_ssl_confs_files_deleted(SslConf),
    ?assertException(error, {config_not_found, [gateway, stomp]},
                     emqx:get_raw_config([gateway, stomp])),
    ok.

%% TODO: Comment out this test case for now, because emqx_tls_lib
%% will delete the configured certificate file.

%t_load_gateway_with_certs_path(_) ->
%    StompConf = compose_ssl_listener(
%                  ?CONF_STOMP_BAISC_1,
%                  ?CONF_STOMP_LISTENER_SSL_PATH
%                 ),
%    {ok, _} = emqx_gateway_conf:load_gateway(<<"stomp">>, StompConf),
%    assert_confs(StompConf, emqx:get_raw_config([gateway, stomp])),
%    SslConf = emqx_map_lib:deep_get(
%                [<<"listeners">>, <<"ssl">>, <<"default">>, <<"ssl">>],
%                emqx:get_raw_config([gateway, stomp])
%               ),
%    ok = emqx_gateway_conf:unload_gateway(<<"stomp">>),
%    assert_ssl_confs_files_deleted(SslConf),
%    ?assertException(error, {config_not_found, [gateway, stomp]},
%                     emqx:get_raw_config([gateway, stomp])),
%    ok.

t_add_listener_with_certs_content(_) ->
    StompConf = ?CONF_STOMP_BAISC_1,
    {ok, _} = emqx_gateway_conf:load_gateway(<<"stomp">>, StompConf),
    assert_confs(StompConf, emqx:get_raw_config([gateway, stomp])),

    {ok, _} = emqx_gateway_conf:add_listener(
                <<"stomp">>, {<<"ssl">>, <<"default">>},
                ?CONF_STOMP_LISTENER_SSL),
    assert_confs(
      maps:merge(StompConf, ssl_listener(?CONF_STOMP_LISTENER_SSL)),
      emqx:get_raw_config([gateway, stomp])),

    {ok, _} = emqx_gateway_conf:update_listener(
                <<"stomp">>, {<<"ssl">>, <<"default">>},
                ?CONF_STOMP_LISTENER_SSL_2),
    assert_confs(
      maps:merge(StompConf, ssl_listener(?CONF_STOMP_LISTENER_SSL_2)),
      emqx:get_raw_config([gateway, stomp])),

    SslConf = emqx_map_lib:deep_get(
                [<<"listeners">>, <<"ssl">>, <<"default">>, <<"ssl">>],
                emqx:get_raw_config([gateway, stomp])
               ),
    ok = emqx_gateway_conf:remove_listener(
           <<"stomp">>, {<<"ssl">>, <<"default">>}),
    assert_ssl_confs_files_deleted(SslConf),

    ?assertMatch(
       {error, {badres, #{reason := not_found}}},
       emqx_gateway_conf:update_listener(
         <<"stomp">>, {<<"ssl">>, <<"default">>}, ?CONF_STOMP_LISTENER_SSL_2)),

    ?assertException(
       error, {config_not_found, [gateway, stomp, listeners, ssl, default]},
       emqx:get_raw_config([gateway, stomp, listeners, ssl, default])
      ),
    ok.

assert_ssl_confs_files_deleted(SslConf) when is_map(SslConf) ->
    Ks = [<<"cacertfile">>, <<"certfile">>, <<"keyfile">>],
    lists:foreach(fun(K) ->
        Path = maps:get(K, SslConf),
        {error, enoent} = file:read_file(Path)
    end, Ks).

%%--------------------------------------------------------------------
%% Utils

compose(Basic, Authn, Listener) ->
    maps:merge(
      maps:merge(Basic, #{<<"authentication">> => Authn}),
      listener(Listener)).

compose_listener(Basic, Listener) ->
    maps:merge(Basic, listener(Listener)).

compose_ssl_listener(Basic, Listener) ->
    maps:merge(Basic, ssl_listener(Listener)).

compose_authn(Basic, Authn) ->
    maps:merge(Basic, #{<<"authentication">> => Authn}).

compose_listener_authn(Basic, Listener, Authn) ->
    maps:merge(
      Basic,
      listener(maps:put(<<"authentication">>, Authn, Listener))).

listener(L) ->
    #{<<"listeners">> => [L#{<<"type">> => <<"tcp">>,
                             <<"name">> => <<"default">>}]}.

ssl_listener(L) ->
    #{<<"listeners">> => [L#{<<"type">> => <<"ssl">>,
                             <<"name">> => <<"default">>}]}.
