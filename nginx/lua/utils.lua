local basexx = require("basexx")

local M = {}

-- Extracted from https://github.com/auth0/nginx-jwt/blob/v1.0.1/nginx-jwt.lua
function M.consume_secret(secret)
  assert(secret ~= nil, "Environment variable JWT_SECRET not set")

  if os.getenv("JWT_SECRET_IS_BASE64_ENCODED") == 'true' then
    -- Convert from URL-safe Base64 to Base64
    local r = #secret % 4

    if r == 2 then
        secret = secret .. "=="
    elseif r == 3 then
        secret = secret .. "="
    end

    secret = string.gsub(secret, "-", "+")
    secret = string.gsub(secret, "_", "/")

    -- Convert from Base64 to UTF-8 string
    return basexx.from_base64(secret)
  end

  return secret
end

-- Receives a string with the form `Bearer <token>` where `<token>` is a
-- valid JWT token.
--
-- Returns a pair of `token, err` where one will carry a string and the other
-- will be `nil`.
function M.extract_token(auth_header)
  if not auth_header then
    return auth_header, "No Authorization header"
  end

  local _, _, token = string.find(auth_header, "Bearer%s+(.+)")

  if not token then
    return token, "Missing token"
  end

  return token, nil
end

return M
