-- bf.ua --

local function mindscrew(code, tape_length, flags)
	local subroutines, jump_table = {}, {}
	local tape = {}
	for i = 1, tape_length do
		tape[i] = 0
	end

	-- Builds the jump and subroutine maps from the given code
	do
		local stack = {}
		local subroutine = 0 -- subroutine index
		for index, char in code:gmatch"()(.)" do
			if char == "{" or char == "[" or char == "(" then
				if char == "{" then
					subroutines[subroutine] = index
					subroutine = subroutine + 1
				end
				stack[#stack+1] = index
			elseif char == "}" or char == "]" or char == ")" then
				local start = table.remove(stack)
				jump_table[start] = index
				jump_table[index] = start
			end
		end
	end

	local counter = 1    -- program counter
	local ptr = 1        -- reading head
	local acc = 0        -- accumulator
	local stack = {}     -- call stack
	local trace = "trace:" -- call stack trace

	while counter <= #code do
		local command = code:sub(counter, counter)
		if command == ">" then -- move ptr right
			ptr = ptr < #tape and ptr + 1 or 1
		elseif command == "<" then -- move ptr left
			ptr = ptr > 1 and ptr - 1 or #tape
		elseif command == "+" then -- increment tape[ptr]
			tape[ptr] = (tape[ptr] + 1) % 256
		elseif command == "-" then -- decrement tape[ptr]
			tape[ptr] = (tape[ptr] - 1) % 256
		elseif command == "." then -- output tape[ptr]
			io.write(string.char(tape[ptr]))
		elseif command == "," then -- input to tape[ptr]
			tape[ptr] = string.byte(io.read(1) or "\0")
		elseif
			 command == "[" and tape[ptr] == 0 -- jump to matching ] if tape[ptr] == 0
			 or command == "]" and tape[ptr] ~= 0 -- jump to matching [ if tape[ptr] ~= 0
			 or command == "(" and acc == 0    -- jump to matching ) if acc == 0
			 or command == ")" and acc ~= 0    -- jump to matching ( if acc ~= 0
			 or command == "{"
		then                                  -- subroutine
			counter = jump_table[counter]
		elseif command == "}" and #stack > 0 then -- return from subroutine
			counter = table.remove(stack)
			trace = trace .. ("\n ret %i"):format(counter)
		elseif command == ":" then                     -- swap acc and tape[ptr]
			acc, tape[ptr] = tape[ptr], acc
		elseif command == "!" and subroutines[acc] then -- call subroutine
			if code:sub(counter + 1, counter + 1) ~= "}" then -- tco, neat :3
				stack[#stack+1] = counter
				trace = trace .. ("\n push %i"):format(counter)
			end
			counter = subroutines[acc]
			trace = trace .. ("\n call %i @ %i"):format(acc, subroutines[acc])
		end
		counter = counter + 1
	end
	if flags then
		print"\n-= DEBUG INFO =-"
		local str = ""
		for i, v in ipairs(tape) do
			str = str .. ("%02X "):format(v):gsub("00", "--")
			if i % 32 == 0 then
				str = str .. "\n"
			end
		end
		if flags.c then
			print(code)
		end
		if flags.t then
			print(trace)
		end
		if flags.i then
			print(("acc:\n %i\ntape:\n%s"):format(acc, str))
		end
	end
	return tape
end

local function main()
	if #arg == 0 then
		print"usage: bf.lua FILE/SCRIPT [TAPE_SIZE]"
		os.exit()
	end

	local code = arg[1]
	local file = io.open(code, "r")
	if file then
		code = file:read"a"
		file:close()
	end

	local tape = {}
	for i = 1, tonumber(arg[2]) or 512 do
		tape[i] = 0
	end

	mindscrew(code, tonumber(arg[2]) or 512)
end

main()
