

local Callbacks = MODULE

local meta = {
	OnSuccess = function() end,
	OnError = function(err)
		ErrorNoHaltWithStack(err)
	end,
	Defer = function(self, str, ...)
		local args = {...}
		timer.Simple(0, function()
			self[str]( unpack(args))
		end)

		return self
	end,
}
meta.__index = meta

function MODULE.New()

	local callback = setmetatable({}, meta)

	return callback
end

function MODULE.Await(...)

	local args = {...}
	local callback = Callbacks.New()

	local maxCount = #args
	local count = 0

	local fatalError = false

	for i,v in pairs(args) do
		local oldSuccess = v.OnSuccess
		local oldError = v.OnError

		v.OnSuccess = function(...)
			oldSuccess(...)
			count = count + 1

			if count == maxCount and not fatalError then
				callback.OnSuccess()
			end
		end

		v.OnError = function(err)
			oldError(err)
			fatalError = true
			callback.OnError( string.format("Callback(%s) errored await broke out: %s ", i, err))
		end
	end

	return callback
end