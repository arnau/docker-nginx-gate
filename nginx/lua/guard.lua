local jwt = require("resty.jwt")
local validators = require("resty.jwt-validators")
local cjson = require("cjson")
local utils = require("utils")

local secret = utils.consume_secret(os.getenv("JWT_SECRET"))
local M = {}

M.validators = validators

function M.sign()
  ngx.req.read_body()

  local body = cjson.decode(ngx.req.get_body_data())
  body["iat"] = ngx.now()
  body["exp"] = body["iat"] + 60 * 60

  local jwt_token = jwt:sign(secret, {header={typ="JWT", alg="HS256"},
                                      payload=body})

  ngx.say(cjson.encode({token=jwt_token}))
end

function M.auth(claim_spec)
  local token, err = utils.extract_token(ngx.var.http_Authorization)

  if not token then
    ngx.log(ngx.WARN, err)
    ngx.header["WWW-Authenticate"] = "Bearer"
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
  end

  ngx.log(ngx.DEBUG, "Token: " .. token)

  if not claim_spec then
    claim_spec = {
      -- sub = validators.opt_matches("^[a-z]+$"),
      -- iss = validators.equals_any_of({ "local" }),
      exp = validators.opt_is_not_expired(),
      __jwt = validators.require_one_of({ "iat" }),
    }
  end

  local jwt_obj = jwt:verify(secret, token, claim_spec)
  if not jwt_obj.verified then
    ngx.log(ngx.WARN, "Invalid token: " .. jwt_obj.reason)
    ngx.header["WWW-Authenticate"] = 'Bearer error="invalid_token", error="' .. jwt_obj.reason .. '"'
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
  end

  ngx.log(ngx.DEBUG, "JWT: " .. cjson.encode(jwt_obj))

  ngx.header["X-Auth-UserId"] = jwt_obj.payload.sub
end

return M
