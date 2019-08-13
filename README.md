# Linux x86_64 http server written in nasm

## Usage
Server servers files requested with http.
<br />
Http request length should be under 2048 bytes.
<br />
Currently server can only server files under 2048 bytes

## Example

```
git clone https://github.com/Nykseli/http-x86_64-linux
cd http-x86_64-linux
make
./httpserver.out

then open this link with your favourite browser
http://localhost:8888/html/index.html
```
