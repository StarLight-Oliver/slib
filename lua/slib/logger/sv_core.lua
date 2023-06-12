


MODULE.Loggers = {}

function MODULE:New(name)

	if self.Loggers[name] then
		return self.Loggers[name]
	end

	local logger = {}
	logger.name = name
	logger._logs = {}
	logger.Log = function(self, ...)
		local log = {...}
		table.insert(self._logs, log)
		print("[" .. self.name .. "]", ...)
	end
	logger.Error = function(self, ...)
		local log = {...}
		log[#log + 1] = debug.traceback("", 2)
		table.insert(self._logs, log)
		ErrorNoHaltWithStack("[" .. self.name .. "]", ...)
	end
	logger.GetLogs = function(self)
		return self._logs
	end
	logger.CanAccess = function(self, ply)
		return ply:IsSuperAdmin()
	end

	self.Loggers[name] = logger

	return logger
end
