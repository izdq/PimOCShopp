
local unicode = require('unicode')
gpu.setResolution(80, 25)
require("shopService")
local shopName = "Shop1"
local shopService = ShopService:new(shopName)
local GarbageForm
local MainForm
local AutorizationForm
local SellShopForm
local ExchangerForm
local OreExchangerForm
local SellShopSpecificForm
local BuyShopForm
local RulesForm

local nickname = ""  -- Чтобы хранить имя игрока (строка)

local timer

function createNotification(status, text, secondText, callback)
    local notificationForm = forms:addForm()
    notificationForm.border = 2
    notificationForm.W = 31
    notificationForm.H = 10
    notificationForm.left = math.floor((MainForm.W - notificationForm.W) / 2)
    notificationForm.top = math.floor((MainForm.H - notificationForm.H) / 2)
    notificationForm:addLabel(math.floor((notificationForm.W - unicode.len(text)) / 2), 3, text)
    if secondText then
        notificationForm:addLabel(math.floor((notificationForm.W - unicode.len(secondText)) / 2), 4, secondText)
    end
    timer = notificationForm:addTimer(3, function()
        if callback then callback() end
        timer:stop()
    end)
    notificationForm:setActive()
end

function createNumberEditForm(callback, form, buttonText)
    local itemCounterNumberForm = forms:addForm()
    itemCounterNumberForm.border = 2
    itemCounterNumberForm.W = 31
    itemCounterNumberForm.H = 10
    itemCounterNumberForm.left = math.floor((form.W - itemCounterNumberForm.W) / 2)
    itemCounterNumberForm.top = math.floor((form.H - itemCounterNumberForm.H) / 2)
    itemCounterNumberForm:addLabel(8, 3, "Введите количество")
    local itemCountEdit = itemCounterNumberForm:addEdit(8, 4)
    itemCountEdit.W = 18
    itemCountEdit.validator = function(value)
        return tonumber(value) ~= nil
    end
    itemCounterNumberForm:addButton(3, 8, " Назад ", function()
        form:setActive()
    end)
    itemCounterNumberForm:addButton(17, 8, buttonText, function()
        callback(itemCountEdit.text and tonumber(itemCountEdit.text) or 0)
    end)
    return itemCounterNumberForm
end

function createAutorizationForm()
    local AutorizationForm = forms.addForm()
    AutorizationForm.border = 1
    AutorizationForm:addLabel(23, 14, "Что б авторизаваться, встаньте на PIM")

    local authorLabel = AutorizationForm:addLabel(32, 25, " Автор: Подарок от 3_14:* ")
    authorLabel.fontColor = 0x00FDFF

    AutorizationForm:addLabel(11, 3, " _                               _    _____ _                 ")
    AutorizationForm:addLabel(11, 4, "| |                             | |  / ____| |  ")
    AutorizationForm:addLabel(11, 5, "| |     ___  __ _  ___ _ __   __| | | (___ | |__   ___  _ __  ")
    AutorizationForm:addLabel(11, 6, "| |    / _ \\/ _` |/ _ \\ '_ \\ / _` |  \\___ \\| '_ \\ / _ \\| '_ \\ ")
    AutorizationForm:addLabel(11, 7, "| |___|  __/ (_| |  __/ | | | (_| |  ____) | | | | (_) | |_) |")
    AutorizationForm:addLabel(11, 8, "|______\\___|\\__, |\\___|_| |_|\\__,_| |_____/|_| |_|\\___/| .__/")
    AutorizationForm:addLabel(11, 9, "             __/ |                                     | |")
    AutorizationForm:addLabel(11, 10,"            |___/                                      |_|    ")

    return AutorizationForm
end

function createMainForm(nick)
    local MainForm = forms.addForm()
    MainForm.border = 1
    local shopNameLabel = MainForm:addLabel(33, 1, " izd ")
    shopNameLabel.fontColor = 0x00FDFF
    local authorLabel = MainForm:addLabel(32, 25, " Автор: Подарок от 3_14:* ")
    authorLabel.fontColor = 0x00FDFF

    MainForm:addLabel(5, 4, "Ваш ник: ")
    MainForm:addLabel(7, 4, nick)

    MainForm:addLabel(5, 6, "Баланс: ")
    local balance = shopService:getBalance(nick)
    MainForm:addLabel(27, 6, tostring(balance))

    MainForm:addButton(60, 5, " Выход ", function()
        AutorizationForm:setActive()
    end).W = 15

    local depositForm = createNumberEditForm(function(count)
        local _, message = shopService:depositMoney(nick, count)
        -- убираем проверку на кратность 1, если не нужно:
        createNotification(nil, message, nil, function()
            MainForm = createMainForm(nick)
            MainForm:setActive()
        end)
    end, MainForm, "Пополнить")

    local withdrawForm = createNumberEditForm(function(count)
        local _, message = shopService:withdrawMoney(nick, count)
        createNotification(nil, message, nil, function()
            MainForm = createMainForm(nick)
            MainForm:setActive()
        end)
    end, MainForm, "Снять")

    MainForm:addButton(36, 4, "Пополнить баланс", function()
        depositForm:setActive()
    end).W = 20

    MainForm:addButton(36, 6, "Снять с баланса", function()
        withdrawForm:setActive()
    end).W = 20

    MainForm:addLabel(5, 8, "Количество предметов: ")
    MainForm:addLabel(27, 8, tostring(shopService:getItemCount(nick)))

    MainForm:addButton(36, 8, "Забрать предметы", function()
        createGarbageForm()
    end).W = 20

    MainForm:addButton(8, 17, " Купить ", function()
        createSellShopForm()
    end).W = 21

    MainForm:addButton(30, 17, " Продать ", function()
        createBuyShopForm()
    end).W = 22

    MainForm:addButton(53, 17, " Обмен руд", function()
        createOreExchangerForm()
    end).W = 21

    MainForm:addButton(8, 21, " Обменик ", function()
        createExchangerForm()
    end).W = 21

    MainForm:addButton(30, 21, " Примечание ", function()
        RulesForm:setActive()
    end).W = 44

    return MainForm
end

function createGarbageForm()
    local items = shopService:getItems(nickname)
    for i = 1, #items do
        local name = items[i].label
        for j = 1, 60 - unicode.len(name) do
            name = name .. ' '
        end
        name = name .. items[i].count .. " шт"
        items[i].displayName = name
    end

    GarbageForm = createListForm(" Корзина ",
        " Наименование                                                Количество",
        items,
        {
            createButton(" Назад ", 4, 23, function(selectedItem)
                MainForm = createMainForm(nickname)
                MainForm:setActive()
            end),
            createButton(" Забрать все ", 68, 23, function(selectedItem)
                local count, message = shopService:withdrawAll(nickname)
                createNotification(count, message, nil, function()
                    createGarbageForm()
                end)
            end),
            createButton(" Забрать ", 55, 23, function(selectedItem)
                if selectedItem then
                    local NumberForm = createNumberEditForm(function(count)
                        local c, msg = shopService:withdrawItem(nickname, selectedItem.id, selectedItem.dmg, count)
                        createNotification(c, msg, nil, function()
                            createGarbageForm()
                        end)
                    end, GarbageForm, "Забрать")
                    NumberForm:setActive()
                end
            end)
        })

    GarbageForm:setActive()
end

-- Функции createSellShopForm, createSellShopSpecificForm, createBuyShopForm,
-- createOreExchangerForm, createExchangerForm, createRulesForm,
-- createListForm, createButton -- (оставьте как у вас)

-- Функция autorize устанавливает MainForm
function autorize(nick)
    print("Авторизация игрока: " .. tostring(nick))
    nickname = nick
    MainForm = createMainForm(nick)
    MainForm:setActive()
end

AutorizationForm = createAutorizationForm()
RulesForm = createRulesForm()

-- Событие player_on
AutorizationForm:addEvent("player_on", function(e, p)
    gpu.setResolution(80, 25)
    local playerName = ""
    if type(p) == "table" then
        playerName = p.name or "" -- извлекаем поле name
    else
        playerName = tostring(p)
    end
    print("player_on event, playerName=", playerName)
    if playerName ~= "" then
        computer.addUser(playerName)
        autorize(playerName)
    end
end)

-- Событие player_off
AutorizationForm:addEvent("player_off", function(e, p)
    local playerName = ""
    if type(p) == "table" then
        playerName = p.name or ""
    else
        playerName = tostring(p)
    end
    print("player_off event, playerName=", playerName)

    if (playerName ~= '3_1415926535') and (playerName ~= 'izd') then
        computer.removeUser(playerName)
    end
    if timer then timer:stop() end
    AutorizationForm:setActive()
end)

forms.run(AutorizationForm)
