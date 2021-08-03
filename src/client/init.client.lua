-- Create a UI with a textbox with which to test TextBoxPlus

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local TextBoxPlus = require(ReplicatedStorage:WaitForChild("TextBoxPlus"))

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")

local Textbox = TextBoxPlus.new({
	ScrollPastLastLine =  true,
})

Textbox.Size = UDim2.new(0.5,0,0.5,0)
Textbox.Parent = ScreenGui

ScreenGui.Parent = PlayerGui