Button = {}
Button.__index = Button

function Button.new(label, description, onClick)
    local self = setmetatable({}, Button)
    self.label = label
    self.description = description
    self.onClick = onClick
    self.icon = nil
    self.options = nil
    self.onCheck = nil
    self.onSelect = nil
    self.onSideScroll = nil
    return self
end

function Button:setIcon(icon)
    self.icon = icon
    return self
end

function Button:setOptions(options)
    self.options = options
    return self
end

function Button:setOnCheck(onCheck)
    self.onCheck = onCheck
    return self
end

function Button:setOnScroll(onSideScroll)
    self.onSideScroll = onSideScroll
    return self
end

function Button:setOnClick(onSelect)
    self.onSelect = onSelect
    return self
end

function Button:setOnSelect(onSelect)
    self.onSelect = onSelect
    return self
end

function Button:setDescription(description)
    self.description = description
    return self
end

-- Menu class
Menu = {}
Menu.__index = Menu

function Menu.new(title, bla, position)
    local self = setmetatable({}, Menu)
    self.title = title
    self.position = position
    self.options = {}
    self.onCloseCallback = nil
    self.menuId = nil
    return self
end

function Menu:add(button)
    table.insert(self.options, button)
    return button
end

function Menu:addButton(label, description, onClick)
    local button = Button.new(label, description, onClick)
    table.insert(self.options, button)
    return button
end

function Menu:addItem(label, onClick)
    local button = Button.new(label, "", onClick)
    table.insert(self.options, button)
    return button
end

function Menu:addCheckbox(label, description, onCheck)
    local button = Button.new(label, description)
    button:setOnCheck(onCheck)
    table.insert(self.options, button)
    return button
end

function Menu:addListButton(label, description, options, onSelect)
    local button = Button.new(label, description)
    button:setIcon(icon)
    button:setOptions(options)
    button:setOnSelect(onSelect)
    table.insert(self.options, button)
    return button
end

function Menu:onClose(callback)
    self.onCloseCallback = callback
end

function Menu:show()
    self:open()
end

function Menu:open()
    local data = {
        id = 'menu' .. math.random(1, 100000),
        title = self.title,
        position = self.position,
        options = self:generateOptions(),

        onCheck = function(checked, selected)
            if self.options[checked].onCheck then
                self.options[checked].onCheck(selected)
            end
        end,

        onClose = function(keyPressed)
            if self.onCloseCallback then
                self.onCloseCallback(keyPressed)
            end
        end,

        onSideScroll = function(selected, scrollIndex, args)
            if self.options[selected].onSideScroll then
                self.options[selected].onSideScroll(scrollIndex, args)
            end
        end,

        onSelected = function(selected, secondary, args)
            if self.options[selected].onSelect then
                self.options[selected].onSelect(args)
            end
        end

    }

    self.menuId = data.id

    lib.registerMenu(data, function(selected, scrollIndex, args)
        if self.menuId == data.id then
            if self.options[selected].onClick then
                self.options[selected].onClick()
            elseif self.options[selected].onCheck then
                self.options[selected].onCheck(args.checked)
            elseif self.options[selected].onSelect then
                self.options[selected].onSelect(args)
            end
        end
    end)

    lib.showMenu(self.menuId)
end

function Menu:generateOptions()
    local options = {}

    for _, button in ipairs(self.options) do
        local option = {
            label = button.label,
            description = button.description,
            icon = button.icon
        }

        if button.options then
            option.values = button.options
            option.isScroll = true
            option.onSelect = button.onSelect
            option.onSideScroll = button.onSideScroll
        elseif button.onCheck then
            option.checked = false
            option.isCheck = true
            option.onCheck = button.onCheck
        elseif button.onClick then
            option.onClick = button.onClick
        end

        table.insert(options, option)
    end

    return options
end
