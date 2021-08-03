--[=[
	TextBox Plus
	by boatbomber

	A module to extend the features and functionality of Roblox TextBoxes

	- Ctrl-D word select
	- ~Up/Down arrow navigation~ (Edit: Feature has since been added natively by Roblox)
	- Undo/Redo with Ctrl-Z Ctrl-Y or TB:Undo()/TB:Redo()
	- Automatically sized scrolling frame
	- :Write(Text, i, j) to insert text into the middle of the box

	MIT License

	Copyright (c) 2021 boatbomber

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

--]=]

local UserInputService = game:GetService("UserInputService")
local Textboxes = {}
local TextBoxPlus = {}

UserInputService.InputBegan:Connect(function(Input, GP)
	if not GP then return end -- We only want GP input, since we want input in TextBoxes

	local RealTextbox = UserInputService:GetFocusedTextBox()
	if not RealTextbox then return end

	local Textbox = Textboxes[RealTextbox]
	if not Textbox then return end

	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		if Input.KeyCode == Enum.KeyCode.D then
			-- Select current block
			local CursorPosition = RealTextbox.CursorPosition

			local LeftText, RightText = string.sub(RealTextbox.Text, 1, CursorPosition-1), string.sub(RealTextbox.Text, CursorPosition)
			local WordLeft = string.find(LeftText, "%w+$")
			local _,WordRight = string.find(RightText, "^%w+")

			if WordLeft or WordRight then
				RealTextbox.SelectionStart = WordLeft or CursorPosition
				RealTextbox.CursorPosition = CursorPosition + (WordRight or 0)
			end
		elseif Input.KeyCode == Enum.KeyCode.Z then
			-- Undo
			Textbox:Undo()
		elseif Input.KeyCode == Enum.KeyCode.Y then
			-- Redo
			Textbox:Redo()
		end
	end
end)

function TextBoxPlus.new(options: {[string]: any}?)
	local RealTextbox = Instance.new("TextBox")
	RealTextbox.Text = "TextBox Plus"
	RealTextbox.MultiLine = true
	RealTextbox.TextWrapped = false
	RealTextbox.ClearTextOnFocus = false
	RealTextbox.TextSize = 15
	RealTextbox.Font = Enum.Font.SourceSans
	RealTextbox.BackgroundTransparency = 1
	RealTextbox.Size = UDim2.new(1,-4,1,-4)
	RealTextbox.Position = UDim2.fromOffset(2,2)
	RealTextbox.TextXAlignment = Enum.TextXAlignment.Left
	RealTextbox.TextYAlignment = Enum.TextYAlignment.Top

	local ScrollingFrame = Instance.new("ScrollingFrame")
	ScrollingFrame.Size = UDim2.fromOffset(200,50)
	ScrollingFrame.Position = UDim2.fromOffset(0,0)
	ScrollingFrame.BorderSizePixel = 0
	ScrollingFrame.BorderColor3 = Color3.new()
	ScrollingFrame.BackgroundColor3 = Color3.fromRGB(226, 226, 226)
	ScrollingFrame.TopImage = ScrollingFrame.MidImage
	ScrollingFrame.BottomImage = ScrollingFrame.MidImage
	ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(148, 148, 148)

	RealTextbox.Parent = ScrollingFrame

	local function ResizeCanvas()
		ScrollingFrame.CanvasSize = UDim2.fromOffset(
			RealTextbox.TextBounds.X,
			RealTextbox.TextBounds.Y + (options.ScrollPastLastLine and ScrollingFrame.AbsoluteSize.Y - RealTextbox.TextSize or 0)
		)
	end

	RealTextbox:GetPropertyChangedSignal("Text"):Connect(ResizeCanvas)
	RealTextbox:GetPropertyChangedSignal("TextSize"):Connect(ResizeCanvas)
	RealTextbox:GetPropertyChangedSignal("Font"):Connect(ResizeCanvas)
	ScrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeCanvas)

	local Textbox = {}

	function Textbox:Set(Text: string?)
		RealTextbox.Text = Text or ""
	end

	function Textbox:Write(Text: string, i: number, j: number?)
		assert(type(Text)=="string", "`Text` must be a string, got " .. type(Text))
		assert(type(i)=="number", "`i` must be a number, got " .. type(i))

		RealTextbox.Text = string.sub(RealTextbox.Text, 1, i) .. Text .. string.sub(RealTextbox.Text,(j or i)+1)
	end

	function Textbox:Undo()

	end

	function Textbox:Redo()

	end

	local Meta = {
		__index = function(_, Key)
			if ScrollingFrame[Key] ~= nil then
				return ScrollingFrame[Key]
			elseif RealTextbox[Key] ~= nil then
				return RealTextbox[Key]
			else
				warn("Attempt to read unknown value Textbox."..tostring(Key))
				return nil
			end
		end,
		__newindex = function(_, Key, Value)
			-- Parent needs special casing since it can be nil
			if Key == "Parent" then
				ScrollingFrame[Key] = Value
				return
			end

			if ScrollingFrame[Key] ~= nil then
				ScrollingFrame[Key] = Value
			elseif RealTextbox[Key] ~= nil then
				RealTextbox[Key] = Value
			else
				Textbox[Key] = Value
			end
		end,
	}

	Textboxes[RealTextbox] = Textbox

	return setmetatable(Textbox, Meta)
end

return TextBoxPlus