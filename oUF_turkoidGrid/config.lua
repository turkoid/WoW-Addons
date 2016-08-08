local parent = ...
local global = GetAddOnMetadata(parent, 'X-oUF')
local oUF = _G[global]
local config = turkoid.config
config.readycheck = {
	["notready"] = READY_CHECK_NOT_READY_TEXTURE,
	["ready"] = READY_CHECK_READY_TEXTURE,
	["waiting"] = READY_CHECK_WAITING_TEXTURE,
	["afk"] = READY_CHECK_AFK_TEXTURE,
}
--make sure healthbar and powerbar heights add up to the frame height
config.raid = {
	["height"] = 55,
	["width"] = 55,
	["spacing"] = 1,
	["healthbar"] = {
		["height"] = 47,
		["orientation"] = "vertical",
	},
	["powerbar"] = {
		["height"] = 8,
		["manaonly"] = true,
	},
	["debuffhighlight"] = true,
	["rangecheck"] = true,
	["vehicleswap"] = true,
	["texts"] = {
		["centertexts"] = {
			"[centertext1]",
			"[centertext2]",
		}
	},
	["border"] = {
		["statuses"] = {
			"target",
			"lowhp",
			"lowmana",
		},
	},				
}
config.raidpet = {
	["height"] = 55,
	["width"] = 55,
	["spacing"] = 1,
	["healthbar"] = {
		["height"] = 47,
		["orientation"] = "vertical",
	},
	["powerbar"] = {
		["height"] = 8,
		["manaonly"] = true,
	},
	["debuffhighlight"] = true,
	["rangecheck"] = true,
	["texts"] = {
		["centertexts"] = {
			"[centertext1]",
			"[centertext2]",
		}
	},
	["border"] = {
		["statuses"] = {
			"target",
			"lowhp",
			"lowmana",
		},
	},				
}
config.raidvehicle = {
	["height"] = 55,
	["width"] = 55,
	["spacing"] = 1,
	["healthbar"] = {
		["height"] = 47,
		["orientation"] = "vertical",
	},
	["powerbar"] = {
		["height"] = 8,
		["manaonly"] = true,
	},
	["debuffhighlight"] = true,
	["rangecheck"] = true,
	["texts"] = {
		["centertexts"] = {
			"[centertext1]",
			"[centertext2]",
		}
	},
	["border"] = {
		["statuses"] = {
			"target",
			"lowhp",
		},
	},				
}

config.layouts = {
	["arena"] = {
		["groups"] = 1,
		["petConfig"] = "raidpet",
	},
	["default"] = {
		["groups"] = 8,
	},
}
		

--I do this so i dont have to manually change the raidunits healthbar and powerbar heights when i change the border size
local fixUnits = {"raid", "raidpet", "raidvehicle"}
for _, unit in ipairs(fixUnits) do
	if config[unit] then
		config[unit].healthbar.height = config[unit].healthbar.height - (config.border.size + 1)
		config[unit].powerbar.height = config[unit].powerbar.height - (config.border.size + 1)
	end
end

local pName = UnitName('player')
--Yattay Indicators
if pName == 'Yattay' or pName == 'Bryz' then
	config.raid.indicators = {
		["center"] = {
			["size"] = 24,
			["statuses"] = {
				"readycheck",
				"buff:angel",
				"buff:di",
				"raiddebuff",
				"debuff:deepfreeze",
				"debuff:poly",
				"debuff:hammer",
				"debuff:fear",
				"debuff:priestfear",
				"debuff:howlofterror",
				"debuff:horror",
				"debuff:deathcoil",
				"debuff:huntertrap",
				"debuff:dktrap",
				"debuff:justice",
				"debuff:repentance",
				"debuff:nova",
				"debuff:roots",	
				"debuff:chains",
				"debuff:immolate",
				"debuff:flameshock",				
			},
		},
		['top'] = {
			['size'] = 14,
			['statuses'] = {
				"debuff:unstableaffliction",
			},
		},
		['left'] = {
			['size'] = 8,
			['statuses'] = {
				"buff:pom",
			},
		},
		["topleft"] = {
			["size"] = 8,
			["statuses"] = {
				"buff:renew",
			},
		},
		["topright"] = {
			["size"] = 14,
			["statuses"] = {
				"debuff:weakenedsoul",
			},
		},
		["bottomleft"] = {
			["size"] = 12,
			["statuses"] = {
				"buff:shield",
			},
		},
		["bottom"] = {
			["size"] = 14,
			["statuses"] = {
				"buff:innervate",				
				"missingbuff",
			},
		},
		["bottomright"] = {
			["size"] = 14,
			["statuses"] = {
				"plague_sickness",
				"healingprevented",
				"healingreduced",
			},
		},
	}
	config.raidpet.indicators = {
		["center"] = {
			["size"] = 24,
			["statuses"] = {
				"readycheck",
				"raiddebuff",
				"debuff:deepfreeze",
				"debuff:poly",
				"debuff:hammer",
				"debuff:fear",
				"debuff:priestfear",
				"debuff:howlofterror",
				"debuff:horror",
				"debuff:deathcoil",
				"debuff:huntertrap",
				"debuff:dktrap",
				"debuff:justice",
				"debuff:repentance",
				"debuff:nova",
				"debuff:roots",	
				"debuff:chains",
				"debuff:immolate",
				"debuff:flameshock",				
			},
		},
		['top'] = {
			['size'] = 14,
			['statuses'] = {
				"debuff:unstableaffliction",
			},
		},
		['left'] = {
			['size'] = 8,
			['statuses'] = {
				"buff:pom",
			},
		},
		["topleft"] = {
			["size"] = 8,
			["statuses"] = {
				"buff:renew",	
			},
		},
		["topright"] = {
			["size"] = 8,
			["statuses"] = {
				"debuff:weakenedsoul",
			},
		},
		["bottomleft"] = {
			["size"] = 12,
			["statuses"] = {
				"buff:shield",
			},
		},
		["bottom"] = {
			["size"] = 14,
			["statuses"] = {
				"buff:innervate",				
				"missingbuff",	
			},
		},
		["bottomright"] = {
			["size"] = 10,
			["statuses"] = {
				"plague_sickness",
				"healingprevented",
				"healingreduced",
			},
		},
	}
	config.raidvehicle.indicators = {
		["center"] = {
			["size"] = 24,
			["statuses"] = {
				"readycheck",
				"raiddebuff",
			},
		},
		["bottomright"] = {
			["size"] = 8,
			["statuses"] = {
				"healingprevented",
				"healingreduced",
			},
		},
	}
elseif pName == 'Yatta' then
	config.raid.indicators = {
		["center"] = {
			["size"] = 24,
			["statuses"] = {
				"readycheck",
				"buff:angel",
				"buff:di",
				"raiddebuff",
				"debuff:hex",
				"debuff:cot",
				"debuff:wound",
				"debuff:viper",
				"debuff:crippling",
			},
		},
		["left"] = {
			["size"] = 12,
			["statuses"] = {
				"debuff:choking",
			},
		},
		["topleft"] = {
			["size"] = 8,
			["statuses"] = {
				"buff:lifebloom",
			},
		},
		["topright"] = {
			["size"] = 8,
			["statuses"] = {
				"buff:rejuv",
				"buff:regrowth",
			},
		},
		["bottomleft"] = {
			["size"] = 8,
			["statuses"] = {
				"buff:wildgrowth",
			},
		},
		["bottom"] = {
			["size"] = 14,
			["statuses"] = {
				"buff:innervate",
				"missingbuff",
			},
		},
		["right"] = {
			["size"] = 14,
			["statuses"] = {
				"plague_sickness",
			},
		},
		["bottomright"] = {
			["size"] = 8,
			["statuses"] = {
				"healingprevented",
				"healingreduced",
			},
		},
	}
	config.raidpet.indicators = {
		["center"] = {
			["size"] = 24,
			["statuses"] = {
				"raiddebuff",
				"debuff:hex",
				"debuff:cot",
				"debuff:wound",
				"debuff:viper",
				"debuff:crippling",
			},
		},
		["topleft"] = {
			["size"] = 8,
			["statuses"] = {
				"buff:lifebloom",
			},
		},
		["topright"] = {
			["size"] = 8,
			["statuses"] = {
				"buff:rejuv",
				"buff:regrowth",
			},
		},
		["bottomleft"] = {
			["size"] = 8,
			["statuses"] = {
				"buff:wildgrowth",
			},
		},
		["bottom"] = {
			["size"] = 14,
			["statuses"] = {
				"missingbuff",
			},
		},
		["bottomright"] = {
			["size"] = 8,
			["statuses"] = {
				"healingprevented",
				"healingreduced",
			},
		},
	}
	config.raidvehicle.indicators = {
		["center"] = {
			["size"] = 24,
			["statuses"] = {
				"readycheck",
				"raiddebuff",
			},
		},
		["topleft"] = {
			["size"] = 8,
			["statuses"] = {
				"buff:lifebloom",
			},
		},
		["topright"] = {
			["size"] = 8,
			["statuses"] = {
				"buff:rejuv",
				"buff:regrowth",
			},
		},
		["bottomleft"] = {
			["size"] = 8,
			["statuses"] = {
				"buff:wildgrowth",
			},
		},
		["bottomright"] = {
			["size"] = 8,
			["statuses"] = {
				"healingprevented",
				"healingreduced",
			},
		},
	}
else
	config.raid.indicators = {
		["center"] = {
			["size"] = 24,
			["statuses"] = {
				"readycheck",
				"raiddebuff",
			},
		},
		["bottom"] = {
			["size"] = 14,
			["statuses"] = {
				"missingbuff",
			},
		},
		["bottomright"] = {
			["size"] = 8,
			["statuses"] = {
				"healingprevented",
				"healingreduced",
			},
		},
	}
	config.raidpet.indicators = {
		["center"] = {
			["size"] = 24,
			["statuses"] = {
				"raiddebuff",
			},
		},
		["bottom"] = {
			["size"] = 14,
			["statuses"] = {
				"missingbuff",
			},
		},
		["bottomright"] = {
			["size"] = 8,
			["statuses"] = {
				"healingprevented",
				"healingreduced",
			},
		},
	}
	config.raidvehicle.indicators = {
		["center"] = {
			["size"] = 24,
			["statuses"] = {
				"readycheck",
				"raiddebuff",
			},
		},
		["bottomright"] = {
			["size"] = 8,
			["statuses"] = {
				"healingprevented",
				"healingreduced",
			},
		},
	}
end