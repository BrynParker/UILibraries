VoidUI.Colors = {
	Primary = Color(35, 35, 35),
	Background = Color(20, 20, 20),

	BackgroundTransparent = Color(20, 20, 20, 127),

	InputDark = Color(35, 35, 35),
	InputLight = Color(50, 50, 50),

	Green = Color(66, 170, 70),
	LightGray = Color(126, 126, 126),
	Gray = Color(222, 222, 222),
	GrayTransparent = Color(222, 222, 222, 120),

	GrayText = Color(110,110,110),

	DarkGrayTransparent = Color(52,52,52,200),
	GrayDarker = Color(170, 170, 170),
	GrayOverlay = Color(35, 35, 35, 220),
	White = Color(255,255,255),
	WhiteOff = Color(126, 126, 126),

	GreenTransparent = Color(66, 170, 70, 220),
	
	Hover = Color(45,45,45),
	Black = Color(0,0,0),
	TextGray = Color(77,77,77),
	
	Red = Color(170, 66, 66),
	Blue = Color(66, 104, 170),
	Orange = Color(170, 91, 66),

	BlueGradientStart = Color(66, 104, 170),
	BlueGradientEnd = Color(38, 60, 97),

	BlueLineGradientEnd = Color(33, 52, 85),

	GreenGradientEnd = Color(33, 85, 35),

	Bronze = Color(168, 106, 65),
	Gold = Color(210, 153, 38),
	Silver = Color(222, 222, 222),
}

VoidLib.ImageProvider = "i.imgur.com/"

if (CLIENT) then

	VoidUI.Font = "Rubik"

	VoidUI.Icons = {
		Close = Material("voidui/close.png"),
		CloseX = Material("voidui/close-x.png"),
		Rename = Material("voidui/rename.png"),
		Settings = Material("voidui/settings.png"),
		Profile = Material("voidui/profile.png"),
		RoundedBox = Material("voidui/roundedbox.png", "alphatest smooth"),

		Faction = Material("voidui/faction.png"),
		Board = Material("voidui/board.png"),
		User = Material("voidui/user.png"),

		Add = Material("voidui/add.png"),
		EditCircle = Material("voidui/edit-circle.png"),
		Remove = Material("voidui/remove.png"),
		Move = Material("voidui/move.png"),

		Deposit = Material("voidui/deposit.png"),
		Upgrades = Material("voidui/upgrades.png"),
		Lock = Material("voidui/lock.png"),

		Rewards = Material("voidui/rewards.png"),
		Stats = Material("voidui/stats.png"),

		Trophy = Material("voidui/trophy.png"),
		TrophyHollow = Material("voidui/trophy_hollow.png"),

		Search = Material("voidui/search.png"),
	}

	timer.Simple(1, function ()
		local sc = VoidUI.Scale
		local strFont = VoidUI.Font

		for i = 7,26 do
			local size = i*2
			local rlSize = sc(size)

			surface.CreateFont("VoidUI.R" .. size, {
				font = strFont,
				size = rlSize,
				extended = true
			})

			surface.CreateFont("VoidUI.S" .. size, {
				font = strFont .. " Light",
				size = rlSize,
				weight = 400,
				extended = true
			})

			surface.CreateFont("VoidUI.B" .. size, {
				font = strFont .. " Bold",
				size = rlSize,
				weight = 500,
				extended = true
			})
		end

		VoidLib.FontsLoaded = true
		hook.Run("VoidLib.FontsLoaded")
	end)
end