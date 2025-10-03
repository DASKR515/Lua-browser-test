local socket = require("socket")

local server = assert(socket.bind("*", 8080))
print("Server running on http://localhost:8080")

while true do
    local client = server:accept()
    client:settimeout(10)

    local request = client:receive("*l")
    print("Request: ", request)

    local response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nHello from Lua on web!\n"
    client:send(response)
    client:close()
end
