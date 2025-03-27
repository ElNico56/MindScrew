-- lua.lua --
-- brainfuck to lua transpiler

for _, file in ipairs{...} do
	local program = assert(io.open(file)):read"a"
	local src = "-- CREATED USING BRAINFUCK TO LUA COMPILER  --\n\nlocal m, p = {}, 0\n"
	local tabs = ""
	for char in program:gmatch"." do
		if char == "+" then
			src = src .. tabs .. "m[p] = ((m[p] or 0) + 1) % 256\n"
		elseif char == "-" then
			src = src .. tabs .. "m[p] = ((m[p] or 0) - 1) % 256\n"
		elseif char == ">" then
			src = src .. tabs .. "p = p + 1\n"
		elseif char == "<" then
			src = src .. tabs .. "p = p - 1\n"
		elseif char == "[" then
			src = src .. tabs .. "while (m[p] or 0) ~= 0 do\n"; tabs = tabs .. "\t"
		elseif char == "]" then
			tabs = tabs:sub(2); src = src .. tabs .. "end\n"
		elseif char == "." then
			src = src .. tabs .. "io.write(string.char(m[p] or 0))\n"
		elseif char == "," then
			src = src .. tabs .. "m[p] = io.read(1):byte() or 0\n"
		end
	end
	assert(io.open(file:gsub(".bf", ".lua"), "w")):write(src .. "\n-- EOF --\n"):close()
end

-- bftolua.lua
for _, file in ipairs{...} do
	local program = assert(io.open(file)):read"a"
	local src = "-- CREATED USING BRAINFUCK TO LUA COMPILER  --\n\nlocal m, p = {}, 0\n"
	local tabs = ""

	local i = 1
	while i <= #program do
		local char = program:sub(i, i)

		if char == "+" or char == "-" or char == ">" or char == "<" then
			-- Count consecutive occurrences of the same character
			local count = 1
			while i + count <= #program and program:sub(i + count, i + count) == char do
				count = count + 1
			end

			if char == "+" then
				src = src .. tabs .. ("m[p] = ((m[p] or 0) + %d) %% 256\n"):format(count)
			elseif char == "-" then
				src = src .. tabs .. ("m[p] = ((m[p] or 0) - %d) %% 256\n"):format(count)
			elseif char == ">" then
				src = src .. tabs .. ("p = p + %d\n"):format(count)
			elseif char == "<" then
				src = src .. tabs .. ("p = p - %d\n"):format(count)
			end

			-- Move the index forward by count
			i = i + count
		elseif char == "[" then
			src = src .. tabs .. "while (m[p] or 0) ~= 0 do\n"
			tabs = tabs .. "\t"
			i = i + 1
		elseif char == "]" then
			tabs = tabs:sub(2)
			src = src .. tabs .. "end\n"
			i = i + 1
		elseif char == "." then
			src = src .. tabs .. "io.write(string.char(m[p] or 0))\n"
			i = i + 1
		elseif char == "," then
			src = src .. tabs .. "m[p] = io.read(1):byte() or 0\n"
			i = i + 1
		else
			-- Ignore any other characters (e.g., comments, whitespace)
			i = i + 1
		end
	end

	assert(io.open(file:gsub(".bf", ".lua"), "w")):write(src .. "\n-- EOF --\n"):close()
end
