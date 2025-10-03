local socket = require("socket")

local notes = {}

local function render_html()
    local html = [[
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Lua Notes</title>
  <style>
    body {
      font-family: 'Roboto', sans-serif;
      background: #f4f6f8;
      margin: 0;
      padding: 0;
    }
    header {
      background: #3f51b5;
      color: white;
      padding: 20px;
      text-align: center;
      font-size: 24px;
      font-weight: bold;
    }
    .container {
      max-width: 800px;
      margin: 30px auto;
      background: white;
      padding: 25px;
      border-radius: 12px;
      box-shadow: 0 4px 10px rgba(0,0,0,0.1);
    }
    h2 { color: #333; margin-bottom: 15px; }
    form { margin-bottom: 20px; display: flex; }
    input[type="text"] {
      flex: 1;
      padding: 10px;
      border: 1px solid #ccc;
      border-radius: 8px;
      margin-right: 10px;
      font-size: 14px;
    }
    button {
      padding: 10px 20px;
      background: #3f51b5;
      color: white;
      border: none;
      border-radius: 8px;
      cursor: pointer;
      font-size: 14px;
    }
    button:hover { background: #303f9f; }
    .note {
      background: #fafafa;
      border-left: 5px solid #3f51b5;
      padding: 12px;
      margin-bottom: 12px;
      border-radius: 6px;
    }
    .note img {
      max-width: 100%;
      margin-top: 8px;
      border-radius: 6px;
    }
  </style>
</head>
<body>
  <header>📒 Lua Notes</header>
  <div class="container">
    <h2>Add a Note</h2>
    <form method="POST" action="/">
      <input type="text" name="note" placeholder="Write your note..." required>
      <button type="submit">Add</button>
    </form>
    <h2>All Notes</h2>
]]

    for _, n in ipairs(notes) do
        html = html .. string.format('<div class="note">%s</div>', n)
    end

    html = html .. [[
  </div>
</body>
</html>
]]
    return html
end

local server = assert(socket.bind("*", 8080))
print("Server running on http://localhost:8080")

while true do
    local client = server:accept()
    client:settimeout(1)

    local request = {}
    while true do
        local line, err = client:receive("*l")
        if not line or line == "" then break end
        table.insert(request, line)
    end

    local body = client:receive("*a") or ""

    if request[1] and request[1]:find("POST") then
        local note = body:match("note=([^&]+)")
        if note then
            note = note:gsub("%%(%x%x)", function(h) return string.char(tonumber(h,16)) end)
            note = note:gsub("%+", " ")
            if note:match("^https?://") and (note:match("%.png$") or note:match("%.jpg$") or note:match("%.jpeg$")) then
                table.insert(notes, string.format('<div>%s<br><img src="%s"></div>', note, note))
            else
                table.insert(notes, note)
            end
        end
    end

    local response = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=UTF-8\r\n\r\n" .. render_html()
    client:send(response)
    client:close()
end
