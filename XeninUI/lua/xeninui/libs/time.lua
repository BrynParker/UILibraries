function XeninUI:GetUTCTime()

	return os.time()
end

function XeninUI:SecondsToTimeString(s, _format, as_tbl)
	local d = (s / 86400)
	local h = math.floor(math.fmod(s, 86400) / 3600)
	local m = math.floor(math.fmod(s, 3600) / 60)
	local s = math.floor(math.fmod(s, 60))

	if as_tbl then
		return {
			d = d,
			h = h,
			m = m,
			s = s
		}
	end

	return string.format(_format or "%d:%02d:%02d:%02d", d, h, m, s)
end

function XeninUI:SecondsToSmallTime(s, _format, as_tbl)
	local m = math.floor(math.fmod(s, 3600) / 60)
	local s = math.floor(math.fmod(s, 60))

	if as_tbl then
		return {
			d = d,
			h = h,
			m = m,
			s = s
		}
	end

	return string.format(_format or "%02d:%02d", m, s)
end
