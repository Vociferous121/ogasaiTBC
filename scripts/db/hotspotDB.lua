hotspotDB = {
	hotspotList = {},
	selectionList = {},
	numHotspots = 0,
	isSetup = false	
}

function hotspotDB:addHotspot(name, race, minLevel, maxLevel, posX, posY, posZ)

	self.hotspotList[self.numHotspots] = {};
	self.hotspotList[self.numHotspots]['name'] = name;
	self.hotspotList[self.numHotspots]['race'] = race;
	self.hotspotList[self.numHotspots]['faction'] = faction;
	self.hotspotList[self.numHotspots]['minLevel'] = minLevel;
	self.hotspotList[self.numHotspots]['maxLevel'] = maxLevel;
	self.hotspotList[self.numHotspots]['pos'] = {};
	self.hotspotList[self.numHotspots]['pos']['x'] = posX;
	self.hotspotList[self.numHotspots]['pos']['y'] = posY;
	self.hotspotList[self.numHotspots]['pos']['z'] = posZ;

	self.selectionList[self.numHotspots] = name;

	self.numHotspots = self.numHotspots + 1;
end


function hotspotDB:setup()

	-- You can set a hotspot for All races by setting the race to 'All'
	-- You can set a hotspot to only Horde or Alliance by setting race to "Horde" or "Alliance"
	--CAN SEPARATE INTO 2 SCRIPTS EASILY HORDE/ALLIANCE
-- AllIANCE
	-- elwynn forest
	hotspotDB:addHotspot("Northshire VAlley 1 - 3", "Alliance", 1, 3, -8810.1, -67.76, 90.12);
	hotspotDB:addHotspot("Northshire VAlley 3 - 5", "Alliance", 3, 5, -8741.81, -166.16, 85.14);
	hotspotDB:addHotspot("Northshire VAlley 5 - 7", "Alliance", 5, 7, -8853.23, -381.68, 71.37);
	hotspotDB:addHotspot("Elwynn Forest 6 - 8", "Alliance", 6, 8, -9589.03, 43.72, 59.9);
	hotspotDB:addHotspot("Elwynn Forest 8 - 10", "Alliance", 8, 10, -9744.87, -627.86, 42.77);
	hotspotDB:addHotspot("Eastvale Logging Camp 10 - 12", "Alliance", 10, 12, -9395.78, -1116.57, 60.82);
	-- teldrassil
	hotspotDB:addHotspot("Shadowglen 1 - 3", "Alliance", 1, 3, 10305.2, 915.61, 1333.71);
	hotspotDB:addHotspot("Shadowglen 3 - 5", "Alliance", 3, 5, 10519.33, 967.11, 1317.89);
	hotspotDB:addHotspot("Shadowglen 5 - 7", "Alliance", 5, 7, 10721.09, 838.87, 1325.58);
	hotspotDB:addHotspot("Teldrassil 6 - 9", "Alliance", 7, 9, 9821.07, 804.47, 1303.89);
	hotspotDB:addHotspot("Teldrassil 9 - 11", "Alliance", 9, 11, 10375.58, 1473.05, 1328.85);
	-- dun morogh
	hotspotDB:addHotspot("Coldridge VAlley 1 - 3", "Alliance", 1, 3, -6311.98, 391.19, 380.59);
	hotspotDB:addHotspot("Coldridge VAlley 3 - 5", "Alliance", 3, 5, -6228.51, 724.46, 388.01);
	hotspotDB:addHotspot("Coldridge VAlley 5 - 7", "Alliance", 5, 7, -6448.49, 690.33, 387.82);
	hotspotDB:addHotspot("The Grizzled Den 6 - 8", "Alliance", 6, 8, -5763.67, -419.41, 365.27);
	hotspotDB:addHotspot("Dun Morogh 8 - 12", "Alliance", 8, 10, -5612.69, 384.63, 382.27);
	-- azurmyst
	hotspotDB:addHotspot("Ammen Vale 1 - 3", "Alliance", 1, 3, -3977.78, -13553.76, 53.33);
	hotspotDB:addHotspot("Ammen Vale 2 - 4", "Alliance", 2, 4, -4295.84, -13414.05, 45.63);
	hotspotDB:addHotspot("Nestlewood Thicket 4 - 6", "Alliance", 4, 6, -4438.07, -13706.2, 50.28);
	hotspotDB:addHotspot("Moongraze Woods 6 - 8", "Alliance", 6, 8, -4025.95, -12602.45, 51.9);
	hotspotDB:addHotspot("Azuremyst Isle 8 - 10", "Alliance", 8, 10, -3425.16, -12052.89, 24.08);
	-- bloodmyst
	hotspotDB:addHotspot("Wrathscale Point 9 - 11", "Alliance", 9, 11, -4838.6, -12134.05, 26);
	hotspotDB:addHotspot("Bloodmyst Isle 11 - 13", "Alliance", 11, 13, -2255.8, -11874.4, 27.93);
	hotspotDB:addHotspot("Ragefeather Ridge 13 - 15", "Alliance", 13, 15, -1460.5, -11782.87, 23.54);
	hotspotDB:addHotspot("Bloodmyst Isle 15 - 17", "Alliance", 15, 17, -2038.73, -11439.54, 59.66);
	hotspotDB:addHotspot("Bloodmyst Isle 17 - 20", "Alliance", 17, 19, -1656.02, -11187.87, 72.83);
	-- westfall
	hotspotDB:addHotspot("Sentinel Hill 10 - 12", "Alliance", 10, 12, -10469.88, 1104.33, 41.04);
	hotspotDB:addHotspot("WestfAll 12 - 14", "Alliance", 12, 14, -10028.81, 846.21, 33.32);
	hotspotDB:addHotspot("Saldean's Farm 14 - 16", "Alliance", 14, 16, -10111.29, 1172.89, 36.28);
	hotspotDB:addHotspot("WestfAll 16 - 18", "Alliance", 16, 18, -10562.59, 1585.87, 46.57);
	hotspotDB:addHotspot("The Dagger Hills 18 - 20", "Alliance", 18, 20, -11191.37, 1315.84, 88.81);
	-- loch modan
	hotspotDB:addHotspot("Loch Modan 10 - 13", "Alliance", 10, 12, -5176.94, -2949.85, 338.2);
	hotspotDB:addHotspot("Loch Modan 13 - 16", "Alliance", 13, 15, -5677.36, -3546.46, 303.79);
	hotspotDB:addHotspot("Loch Modan 16 - 19", "Alliance", 16, 18, -5266.34, -3714.35, 306.25);
	hotspotDB:addHotspot("Stonewrought Dam 18 - 20", "Alliance", 18, 20, -4814.93, -3554.6, 305.15);
	-- red ridge
	hotspotDB:addHotspot("Three Corners 16 - 18", "Alliance", 16, 18, -9716.14, -1871.72, 49.09);
	hotspotDB:addHotspot("Redridge Mountains 18 - 20", "Alliance", 18, 20, -9500.39, -2290.99, 74.43);
	hotspotDB:addHotspot("Alther's Mill 20 - 22", "Alliance", 20, 22, -9171.55, -2734.76, 89.59);
	-- darkshore
	hotspotDB:addHotspot("The Long Wash 10 - 12", "Alliance", 10, 12, 6222.69, 489.16, 16.5);
	hotspotDB:addHotspot("Darkshore 12 - 14", "Alliance", 12, 14, 6782.16, 297.3, 22.89);
	hotspotDB:addHotspot("Darkshore 14 - 16", "Alliance", 14, 16, 6949.08, -260.58, 38.12);
	hotspotDB:addHotspot("Twilight Vale 16 - 18", "Alliance", 16, 18, 5307.34, 306.23, 33.01);
	hotspotDB:addHotspot("Twilight Vale 18 - 20", "Alliance", 18, 20, 4815.17, 283.91, 51.12);
	-- duskwood
	hotspotDB:addHotspot("Duskwood 20 - 22", "Alliance", 20, 22, -10836.06, 561.83, 34.84);
	hotspotDB:addHotspot("The Darkened Bank 22 - 24", "Alliance", 22, 24, -10152.74, 260.59, 21.35);
	hotspotDB:addHotspot("The Darkened Bank 24 - 26", "Alliance", 24, 26, -10062.55, -655.37, 42.28);
	hotspotDB:addHotspot("Brightwood Grove 26 - 28", "Alliance", 26, 28, -10257.95, -909.95, 42.21);
	hotspotDB:addHotspot("The Yorgen Farmstead 28 - 30", "Alliance", 28, 30, -11047.12, -598.75, 28.95);
-- HORDE
	-- mulgore
	hotspotDB:addHotspot("Red Cloud Mesa 1 - 3", "Horde", 1, 3, -2896.23, -504.51, 44.65);
	hotspotDB:addHotspot("Red Cloud Mesa 3 - 5", "Horde", 3, 5, -3356.86, -588.72, 62.19);
	hotspotDB:addHotspot("Red Cloud Mesa 5 - 7", "Horde", 5, 7, -3247.84, -1075.21, 103.66);
	hotspotDB:addHotspot("Mulgore 6 - 8", "Horde", 6, 8, -2647.51, -805.26, -5.43);
	hotspotDB:addHotspot("Mulgore 8 - 10", "Horde", 8, 10, -2064.08, 132.7, 55.29);
	hotspotDB:addHotspot("The Golden Plains 9 - 11", "Horde", 9, 11, -1284.24, -498.82, -59.24);
	hotspotDB:addHotspot("Mulgore 10 - 12", "Horde", 10, 12, -764.77, -501.57, -28.77);
	-- durotar
	hotspotDB:addHotspot("Valley of Trials 1 - 3", "Horde", 1, 3, -685.02, -4323.04, 46.95);
	hotspotDB:addHotspot("Valley of Trials 3 - 5", "Horde", 3, 5, -406.87, -4066.95, 51.89);
	hotspotDB:addHotspot("Valley of Trials 5 - 7", "Horde", 5, 7, -208.23, -4304.31, 63.65);
	hotspotDB:addHotspot("Durotar 6 - 8", "Horde", 6, 8, -729.17, -4638.46, 40.65);
	hotspotDB:addHotspot("Tiragarde Keep 8 - 10", "Horde", 8, 10, -218.26, -4991.64, 21.52);
	hotspotDB:addHotspot("Durotar 10 - 12", "Horde", 10, 12, 532.67, -4006.96, 19.19);
	-- eversong woods
	hotspotDB:addHotspot("Sunstrider Isle 1 - 3", "Horde", 1, 3, 10291.8, -6326.69, 25.65);
	hotspotDB:addHotspot("Sunstrider Isle 3 - 5", "Horde", 3, 5, 10349.52, -6042.54, 26.62);
	hotspotDB:addHotspot("Sunstrider Isle 5 - 7", "Horde", 5, 7, 10119.06, -6262.33, 16.25);
	hotspotDB:addHotspot("Ruins of Silvermoon 6 - 8", "Horde", 6, 8, 9622.2, -6734.54, -3.83);
	hotspotDB:addHotspot("The Dead Scar 7 - 9", "Horde", 8, 10, 9085.52, -6908.14, 20);
	hotspotDB:addHotspot("Duskwither Grounds 9 - 11", "Horde", 9, 11, 9393.27, -7813.54, 53.14);
	-- tirisfal
	hotspotDB:addHotspot("Deathknell 1 - 3", "Horde", 1, 3, 1934.61, 1634.51, 80.26);
	hotspotDB:addHotspot("Deathknell 3 - 5", "Horde", 3, 5, 2136.77, 1643.39, 78.25);
	hotspotDB:addHotspot("Deathknell 5 - 7", "Horde", 5, 7, 1877.66, 1337.51, 74.03);
	hotspotDB:addHotspot("Tirisfal Glades 6 - 8", "Horde", 6, 8, 2074.74, 341.65, 54.57);
	hotspotDB:addHotspot("Tirisfal Glades 8 - 10", "Horde", 8, 10, 2185.95, 5, 39.85);
	hotspotDB:addHotspot("Balnir Farmstead 10 - 12", "Horde", 10, 12, 1880.38, -560.59, 41.29);
	-- barrens
	hotspotDB:addHotspot("The Barrens 10 - 12", "Horde", 10, 12, -440.34, -2406.51, 91.91);
	hotspotDB:addHotspot("The Barrens 12 - 14", "Horde", 12, 14, 91.77, -2595.21, 92.47);
	hotspotDB:addHotspot("The Barrens 14 - 16", "Horde", 14, 16, -283.55, -3712.69, 27.18);
	hotspotDB:addHotspot("Southern Barrens 16 - 18", "Horde", 16, 18, -1743.69, -2880.56, 92.18);
	hotspotDB:addHotspot("Agama'gor 18 - 20", "Horde", 18, 20, -2187.57, -2011.59, 94.35);
	hotspotDB:addHotspot("Bramblescar 20 - 22", "Horde", 20, 22, -2195.25, -2653.28, 91.68);
	-- silverpine
	hotspotDB:addHotspot("Silverpine Forest 10 - 12", "Horde", 10, 12, 1452.33, 688.53, 46.38);
	hotspotDB:addHotspot("Silverpine Forest 12 - 14", "Horde", 12, 14, 372.77, 1268.07, 78.43);
	hotspotDB:addHotspot("Silverpine Forest 14 - 16", "Horde", 14, 16, -280.09, 1231.51, 46.07);
	hotspotDB:addHotspot("Silverpine Forest 16 - 18", "Horde", 16, 18, -516.85, 1574.21, 10);
	-- ghostlands
	hotspotDB:addHotspot("Ghostlands 10 - 12", "Horde", 10, 12, 7897.04, -7073.45, 113.67);
	hotspotDB:addHotspot("Ghostlands 12 - 14", "Horde", 12, 14, 7642.81, -6449.86, 14.05);
	hotspotDB:addHotspot("The Dead Scar 14 - 16", "Horde", 14, 16, 7355.93, -6487.56, 22.21);
	hotspotDB:addHotspot("The Dead Scar 16 - 18", "Horde", 16, 18, 7030.67, -6485.83, 19.1);
	hotspotDB:addHotspot("Zeb'Nowa 18 - 20", "Horde", 18, 20, 6842.18, -7346.31, 47.07);
--BOTH
	-- stonetalon
	hotspotDB:addHotspot("Windshear Crag 19 - 21", "All", 19, 21, 940.43, 279.94, 20.89);
	hotspotDB:addHotspot("Windshear Crag 20 - 22", "All", 20, 22, 1079.03, -122.04, 5.97);
	hotspotDB:addHotspot("MirkfAllon Lake 22 - 24", "All", 22, 24, 1684.82, 762.82, 135.24);
	hotspotDB:addHotspot("Stonetalon Peak 24 - 26", "All", 24, 26, 2364.51, 1383, 276.04);
	hotspotDB:addHotspot("The Charred Vale 27 - 29", "All", 27, 29, 496.19, 1627.43, 1.69);
	hotspotDB:addHotspot("The Charred Vale 29 - 31", "All", 29, 31, 826.01, 1847.12, -3.82);
	-- ashenvale
	hotspotDB:addHotspot("Ashenvale 19 - 21", "All", 19, 21, 3508.05, 435.71, -0.49);
	hotspotDB:addHotspot("Lake Falathim 21 - 23", "All", 21, 23, 3218.79, 547.04, -1.42);
	hotspotDB:addHotspot("Ashenvale 23 - 25", "All", 23, 25, 2421.93, 12.24, 90.88);
	hotspotDB:addHotspot("Ashenvale 24 - 26", "All", 24, 26, 2215.25, -554.21, 102.82);
	hotspotDB:addHotspot("Ashenvale 25 - 27", "All", 25, 27, 2070.12, -1647.48, 65.05);
	hotspotDB:addHotspot("Nightsong Woods 27 - 29", "All", 27, 29, 2183.07, -2276.27, 98.5);
	hotspotDB:addHotspot("Felfire Hill 29 - 31", "All", 29, 31, 2040.05, -2978.58, 105.84);
	-- wetlands
	hotspotDB:addHotspot("Black Channel Marsh 22 - 24", "All", 22, 24, -3488.57, -1323.95, 10.54);
	hotspotDB:addHotspot("Sundown Marsh 24 - 26", "All", 24, 26, -2955.3, -1421.3, 9.14);
	hotspotDB:addHotspot("The Green Belt 26 - 28", "All", 26, 28, -3223.04, -2928.75, 17.76);
	-- hillsbrad
	hotspotDB:addHotspot("Hillsbrad Foothills 22 - 24", "All", 22, 24, -579.14, -507.49, 36.25);
	hotspotDB:addHotspot("Hillsbrad Fields 24 - 26", "All", 24, 26, -274.19, -157.8, 73.1);
	hotspotDB:addHotspot("Hillsbrad Foothills 26 - 28", "All", 26, 28, -820.78, -1249.19, 52.33);
	hotspotDB:addHotspot("Dun Garok 28 - 30", "All", 28, 30, -1160.79, -1051.7, 44.79);
	-- thousand needles
	hotspotDB:addHotspot("The Shimmering Flats 30 - 32", "All", 30, 32, -5683.24, -3568.06, -58.75);
	hotspotDB:addHotspot("Mirage Raceway 32 - 34", "All", 32, 34, -5842, -4098.4, -58.76);
	hotspotDB:addHotspot("Mirage Raceway 34 - 36", "All", 34, 36, -6423.57, -3877.99, -58.75);
	-- stranglethorn vale
	hotspotDB:addHotspot("Nesingwary's Expedition 30 - 32", "All", 30, 32, -11682, 35.75, 13.75);
	hotspotDB:addHotspot("Stranglethorn Vale 32 - 34", "All", 32, 34, -11615.68, 373.04, 44.84);
	hotspotDB:addHotspot("Stranglethorn Vale 34 - 36", "All", 34, 36, -11892.25, -179.95, 16.99);
	hotspotDB:addHotspot("Stranglethorn Vale 36 - 38", "All", 36, 38, -12224.08, 95.33, 23.31);
	hotspotDB:addHotspot("Stranglethorn Vale 38 - 40", "All", 38, 40, -12752.71, -110.81, 4.75);
	hotspotDB:addHotspot("Mistvale Valley 40 - 42", "All", 40, 42, -13938.78, 87.15, 15.82);
	-- arathi
	hotspotDB:addHotspot("Arathi Highlands 30 - 32", "All", 30, 32, -1147.07, -3282.01, 44.69);
	hotspotDB:addHotspot("Arathi Highlands 32 - 34", "All", 32, 34, -1415.59, -3284.61, 46.3);
	hotspotDB:addHotspot("Arathi Highlands 35 - 37", "All", 35, 37, -1879.69, -2654.24, 60.89);
	hotspotDB:addHotspot("Arathi Highlands 38 - 40", "All", 38, 40, -860.8, -2330.77, 56.82);
	-- badlands
	hotspotDB:addHotspot("Angor Fortress 35 - 37", "All", 35, 37, -6436.68, -3283.98, 241.66);
	hotspotDB:addHotspot("Badlands 37 - 39", "All", 37, 39, -6696.7, -3549.21, 242.66);
	hotspotDB:addHotspot("Mirage Flats 39 - 41", "All", 39, 41, -6904.85, -3052.91, 241.91);
	hotspotDB:addHotspot("Apocryphan's Rest 41 - 43", "All", 41, 43, -6954.38, -2524.1, 241.67);
	-- dustwallow marsh
	hotspotDB:addHotspot("Dustwallow Marsh 35 - 37", "All", 35, 37, -2661.36, -3482.03, 32.45);
	hotspotDB:addHotspot("Dustwallow Marsh 37 - 39", "All", 37, 39, -3526.47, -3109.49, 35.33);
	-- desolace
	hotspotDB:addHotspot("Desolace 30 - 32", "All", 30, 32, -338.95, 1223.99, 90.9);
	hotspotDB:addHotspot("Desolace 32 - 34", "All", 32, 34, -726.89, 1760.75, 92.13);
	hotspotDB:addHotspot("Desolace 34 - 36", "All", 34, 36, -1209.08, 1617.15, 64.38);
	hotspotDB:addHotspot("Kodo Graveyard 36 - 38", "All", 36, 38, -1361.31, 1818.34, 51.57);
	-- swamp of sorrows
	hotspotDB:addHotspot("Swamp of Sorrows 35 - 37", "All", 35, 37, -10387.74, -2836.76, 23.28);
	hotspotDB:addHotspot("Swamp of Sorrows 37 - 39", "All", 37, 39, -10303.4, -3522.38, 22.56);
	--hotspotDB:addHotspot("Sorrowmurk 39 - 41", "All", 39, 41, -10162.36, -4195.34, 22.13);
	-- feralas
	hotspotDB:addHotspot("Feralas 40 - 42", "All", 40, 42, -4363, 390.07, 48.25);
	hotspotDB:addHotspot("High Wilderness 42 - 44", "All", 42, 44, -5227.1, 1453.46, 43.51);
	hotspotDB:addHotspot("Frayfeather Highlands 44 - 46", "All", 44, 46, -5522.31, 1708, 66.75);
	hotspotDB:addHotspot("Ruins of Isildien 46 - 48", "All", 46, 48, -5782.34, 1543.56, 70.59);
	-- tanaris
	hotspotDB:addHotspot("Abyssal Sands 42 - 44", "All", 42, 44, -7444.86, -3518.9, 9.87);
	hotspotDB:addHotspot("Tanaris 44 - 46", "All", 44, 46, -8241.34, -3780.48, 8.94);
	hotspotDB:addHotspot("Tanaris 46 - 48", "All", 46, 48, -8778.18, -3648.27, 19.15);
	hotspotDB:addHotspot("Southmoon Ruins 48 - 50", "All", 48, 50, -9006.25, -2959.49, 55.34);
	-- azshara
	hotspotDB:addHotspot("Ruins of Eldarath  48 - 50", "All", 48, 50, 3520.3, -4769.18, 109.42);
	-- searing gorge
	hotspotDB:addHotspot("Searing Gorge 49 - 51", "All", 49, 51, -6992.04, -1012.68, 242.61);
	hotspotDB:addHotspot("The Sea of Cinders 47 - 49", "All", 47, 49, -7045.69, -1512.69, 242.69);
	-- blasted lands
	hotspotDB:addHotspot("Dreadmaul Hold 45 - 47", "All", 45, 47, -11056.48, -2796.31, 7.92);
	hotspotDB:addHotspot("Blasted Lands 50 - 52", "All", 50, 52, -11447.87, -3050.66, 0.26);
	hotspotDB:addHotspot("Blasted Lands 54 - 56", "All", 54, 56, -11468.45, -2756.82, 1.25);
	-- felwood
	hotspotDB:addHotspot("Felwood 50 - 52", "All", 50, 52, 4598.16, -852.83, 305.58);
	hotspotDB:addHotspot("Shatter Scar Vale 54 - 56", "All", 54, 56, 5589.22, -703.6, 341.23);
	-- un'goro
	hotspotDB:addHotspot("The Marshlands 50 - 52", "All", 50, 52, -7882.59, -1850.1, -274.95);
	hotspotDB:addHotspot("Un'Goro Crater 52 - 54", "All", 52, 54, -7633.1, -1374.95, -270.89);
	hotspotDB:addHotspot("Lakkari Tar Pits 54 - 56", "All", 54, 56, -6686.56, -1403.99, -269.75);
	-- winterspring
	hotspotDB:addHotspot("Lake Kel'Theril 54 - 56", "All", 54, 56, 6724.11, -4301.73, 713.34);
	hotspotDB:addHotspot("Winterspring 58 - 60", "All", 58, 60, 7436.18, -4508.73, 602.45);
	hotspotDB:addHotspot("Winterspring 59 - 61", "All", 59, 61, 7872.48, -4533.01, 691.56);
	-- western plaguelands
	hotspotDB:addHotspot("The Bulwark 52 - 54", "All", 52, 54, 1746.12, -1012.53, 72.63);
	hotspotDB:addHotspot("Western Plaguelands 54 - 56", "All", 54, 56, 1851.55, -1996.39, 79.15);
	-- eastern plaguelands
	hotspotDB:addHotspot("Eastern Plaguelands 55 - 57", "All", 55, 57, 2051.69, -3069.62, 78.31);
	hotspotDB:addHotspot("Eastern Plaguelands 57 - 59", "All", 57, 59, 2341.19, -4335.53, 75.12);
	hotspotDB:addHotspot("Plaguewood 59 - 61", "All", 59, 61, 2714.9, -3419.12, 98.67);
	-- silithus
	hotspotDB:addHotspot("Southwind Village 56 - 58", "All", 56, 58, -6988.54, 374.43, 2.76);
	hotspotDB:addHotspot("Silithus 58 - 60", "All", 58, 60, -7528.82, 930.64, 4.45);
	hotspotDB:addHotspot("Silithus 60 - 62", "All", 60, 62, -7914.6, 1390.48, 0.29);

-- outlands
	-- hellfire penninsula
	hotspotDB:addHotspot("Hellfire Peninsula 60 - 62", "All", 60, 62, -861.38, 2864.91, 9.99);
	hotspotDB:addHotspot("The Warp Fields 61 - 63", "All", 61, 63, -1311.32, 3080.05, 25.86);
	hotspotDB:addHotspot("Broken Hill 61 - 63", "All", 61, 63, -576.48, 3328.39, 23.24);
	hotspotDB:addHotspot("The Great Fissure 62 - 64", "All", 62, 64, -487.57, 3720.61, 28.99);
	hotspotDB:addHotspot("Hellfire Peninsula 63 - 65", "All", 63, 65, -23.66, 3428.45, 68.27);
	--zangarmarsh
	hotspotDB:addHotspot("Zangarmarsh 60 - 62", "All", 60, 62, -77.11, 5926.93, 22.73);
	hotspotDB:addHotspot("Zangarmarsh 61 - 63", "All", 61, 63, 487.76, 5867.91, 21.64);
	hotspotDB:addHotspot("Hewn Bog 62 - 64", "All", 62, 64, 743.52, 7589.05, 22.5);
	hotspotDB:addHotspot("Zangarmarsh 63 - 65", "All", 63, 65, -153.96, 8193.19, 19.89);
	hotspotDB:addHotspot("The Spawning Glen 64 - 66", "All", 64, 66, -5.11, 8839.77, 19.34);
	-- nagrand
	hotspotDB:addHotspot("Nagrand 65 - 67", "All", 65, 67, -1086.38, 7638.49, 24.21);
	hotspotDB:addHotspot("Nagrand 65 - 67", "All", 65, 67, -1663.2, 7287.07, -2.61);
	hotspotDB:addHotspot("Nagrand 66 - 68", "All", 66, 68, -2180.94, 7467.8, -34.61);
	hotspotDB:addHotspot("Spirit Fields 67 - 69", "All", 67, 69, -2565.76, 7895.41, -55.79);
	hotspotDB:addHotspot("Nagrand 67 - 69", "All", 67, 69, -2862.21, 7089.73, -12.63);
	hotspotDB:addHotspot("Nagrand 65 - 67", "All", 65, 67, -2307.13, 6493.68, 13.74);
	hotspotDB:addHotspot("Nesingwary Safari 64 - 66", "All", 64, 66, -1429.34, 6365.72, 35.7);
	-- terrokar forest
	hotspotDB:addHotspot("Terokkar Forest 62 - 64", "All", 62, 64, -1992.43, 4720.72, -1.62);
	hotspotDB:addHotspot("Terokkar Forest 64 - 66", "All", 64, 66, -2230.9, 4912, -0.87);
	hotspotDB:addHotspot("The Bone Wastes 66 - 68", "All", 66, 68, -2797.88, 4899.54, -13.71);
	hotspotDB:addHotspot("The Bone Wastes 67 - 69", "All", 67, 69, -3525, 4475.8, -19.3);
	hotspotDB:addHotspot("Terokkar Forest 62 - 64", "All", 62, 64, -2459.2, 3642.92, -3.51);
	hotspotDB:addHotspot("Shadowmoon Valley 65 - 67", "All", 65, 67, -2977.66, 3142.72, 40.46);
	-- shadowmoon valley
	hotspotDB:addHotspot("Shadowmoon Valley 68 - 70", "All", 68, 70, -3439.68, 2603.56, 60.18);
	hotspotDB:addHotspot("The Fel Pits 69 - 71", "All", 69, 71, -3757.76, 1559.7, 44.64);
	hotspotDB:addHotspot("Shadowmoon Valley 69 - 71", "All", 69, 71, -3985.29, 1078.97, 28.32);
	hotspotDB:addHotspot("Ruins of Baa'ri 69 - 71", "All", 69, 71, -3345.77, 839.19, -21.2);
	-- blade's edge mountain
	hotspotDB:addHotspot("Bladespire Hold 67 - 69", "All", 67, 69, 2459.13, 6594.92, 0.72);
	hotspotDB:addHotspot("Boulder'mok 67 - 69", "All", 67, 69, 3670.95, 7162.77, 141.86);
	-- netherstorm
	hotspotDB:addHotspot("Forge Base: Oblivion 69 - 71", "All", 69, 71, 4415.06, 3242.81, 140.95);
	hotspotDB:addHotspot("Voidwind Plateau 69 - 71", "All", 69, 71, 4311.4, 2029.63, 129.11);
	hotspotDB:addHotspot("The Vortex Fields 69 - 71", "All", 69, 71, 3258.77, 2035.27, 132.12);
	hotspotDB:addHotspot("Netherstorm 69 - 71", "All", 69, 71, 2293.31, 2473.65, 108.47);
	hotspotDB:addHotspot("Netherstorm 69 - 71", "All", 69, 71, 2859.98, 3460.57, 138.89);
	-- isle of quel'danas
	hotspotDB:addHotspot("Isle of Quel'Danas 70 - 72", "All", 70, 72, 12924.89, -6643.08, 12.23);
	hotspotDB:addHotspot("Isle of Quel'Danas 70 - 72", "All", 70, 72, 12481.08, -6545, 8.95);

	DEFAULT_CHAT_FRAME:AddMessage('hotspotDB: loaded...');
	self.isSetup = true;
end

function hotspotDB:getHotSpotByID(id)

	return self.hotspotList[id];
end

function hotspotDB:getHotspotID(race, level)
	local bestDist = 10000;
	local bestIndex = -1;

	for i=0, self.numHotspots - 1 do
		if (level >= self.hotspotList[i]['minLevel'] and level <= self.hotspotList[i]['maxLevel']) then
			
			-- Race specific or All races or faction
			if (self.hotspotList[i]['race'] == race or 
				self.hotspotList[i]['race'] == 'All' or
				self.hotspotList[i]['race'] == UnitFactionGroup("player") ) then
				local myX, myY, myZ = GetPosition(GetLocalPlayer());
				local _dist = GetDistance3D(myX, myY, myZ, self.hotspotList[i]['pos']['x'], self.hotspotList[i]['pos']['y'], self.hotspotList[i]['pos']['z']);
				if(_dist < bestDist) then
					bestDist = _dist;
					bestIndex = i;
				end
			end
		end
	end

	return bestIndex;
end