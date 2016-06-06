# Nginx Gate

Docker image with Nginx with Lua enabled on Alpine to guard endpoints using
[JWT](https://jwt.io/).

## Credits

This is a mix of ideas and code coming from [Auth0's nginx-jwt](https://github.com/auth0/nginx-jwt/blob/v1.0.1/)
and [SkyLothar's lua-resty-jwt](https://github.com/SkyLothar/lua-resty-jwt/)
so, many thanks to them for all the work done.

## Usage

```sh
docker run -d --name gate \
           --env JWT_SECRET=$(JWT_SECRET) \
           --env JWT_SECRET_IS_BASE64_ENCODED=true \
           -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf \
           -p 1080:80 \
           arnau/gate
```

## Development

To build and install the Gate:

```sh
make && make install
```

In summary, the above compiles the Docker image and starts it running on
port 1080.

To test it, create a token and run try the secure endpoint:

```sh
make token # => eyJh...
make test-secure TOKEN=eyJh...
```
