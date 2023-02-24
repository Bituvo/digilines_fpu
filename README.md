# digilines_fpu
Simply send a string containing a mathematical expression and get the answer in return.
If the expression is malformed or errors out, no response will be sent back.

Example usage:
```lua
if event.type == "program" then
    digiline_send("fpu", "18 + 3 / (-10 - 8.5)")

elseif event.type == "digiline" then
    digiline_send("<some output device channel>", tostring(event.msg))

end
```
