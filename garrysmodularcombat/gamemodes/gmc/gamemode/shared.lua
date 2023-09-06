AddCSLuaFile()

include( "modules.lua" )
include("commands.lua")

GM.Name    = "Garry's Modular Combat"
GM.Author  = "KiddleyWiffers"
GM.Email   = "dahouse5501@gmail.com"
GM.Website = "N/A"

TEAM_RED = 0
TEAM_BLUE = 1
TEAM_GREEN = 2
TEAM_PURPLE = 3
TEAM_COOP = 4
TEAM_FFA = 5
TEAM_MONSTER = 6

team.SetUp ( TEAM_RED, "Red", Color( 200, 0, 0, 255) )
team.SetUp ( TEAM_BLUE, "Blue", Color( 0, 0, 200, 255) )
team.SetUp ( TEAM_GREEN, "Green", Color( 0, 200, 0, 255) )
team.SetUp ( TEAM_PURPLE, "Purple", Color( 200, 0, 200, 255) )
team.SetUp ( TEAM_COOP, "Coop", Color( 255, 255, 255, 255) )
team.SetUp ( TEAM_FFA, "Free For All", Color( 255, 255, 255, 255) )
team.SetUp ( TEAM_MONSTER, "Monster", Color( 0, 255, 0, 255) )