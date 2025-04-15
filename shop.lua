local component = require('component')
local computer = require('computer')
local forms = require("forms")
local gpu = component.gpu
local unicode = require('unicode')

-- Устанавливаем разрешение, если у вас есть видеокарта
gpu.setResolution(80, 25)

require("shopService")          -- Предполагается, что ShopService.lua лежит в /home
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

local nickname = ""
local timer

-- Функция для уведомлений (окно на 3 секунды)
function createNotification(status, text, secondText, callback)
    local notificationForm = forms:addForm()
    notificationForm.border = 2
    notificationForm.W = 31
    notificationForm.H = 10

    -- Если уже создана MainForm, то центрируем относительно её
    if MainForm then
      notificationForm.left = math.floor((MainForm.W - notificationForm.W) / 2)
      notificationForm.top = math.floor((MainForm.H - notificationForm.H) / 2)
    else
      -- иначе просто ставим в (1,1)
      notificationForm.left = 1
      notificationForm.top = 1
    end

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

-- Форма ввода числа
function createNumberEditForm(callback, form, buttonText)
    local f = forms:addForm()
    f.border = 2
    f.W = 31
    f.H = 10
    if form then
      f.left = math.floor((form.W - f.W) / 2)
      f.top = math.floor((form.H - f.H) / 2)
    else
      f.left = 1
      f.top = 1
    end

    f:addLabel(8, 3, "Введите количество")
    local itemCountEdit = f:addEdit(8, 4)
    itemCountEdit.W = 18
    itemCountEdit.validator = function(value)
        return tonumber(value) ~= nil
    end

    f:addButton(3, 8, " Назад ", function()
        form:setActive()
    end)
    f:addButton(17, 8, buttonText, function()
        local val = itemCountEdit.text and tonumber(itemCountEdit.text) or 0
        callback(val)
    end)

    return f
end

-- Авт. форма
function createAutorizationForm()
    local f = forms.addForm()
    f.border = 1
    f:addLabel(23, 14, "Чтобы авторизоваться, встаньте на PIM")

    local authorLabel = f:addLabel(32, 25, " Автор: Подарок от 3_14:* ")
    authorLabel.fontColor = 0x00FDFF

    f:addLabel(11, 3, " _                               _    _____ _                 ")
    f:addLabel(11, 4, "| |                             | |  / ____| |  ")
    f:addLabel(11, 5, "| |     ___  __ _  ___ _ __   __| | | (___ | |__   ___  _ __  ")
    f:addLabel(11, 6, "| |    / _ \\/ _` |/ _ \\ '_ \\ / _` |  \\___ \\| '_ \\ / _ \\| '_ \\ ")
    f:addLabel(11, 7, "| |___|  __/ (_| |  __/ | | | (_| |  ____) | | | | (_) | |_) |")
    f:addLabel(11, 8, "|______\\___|\\__, |\\___|_| |_|\\__,_| |_____/|_| |_|\\___/| .__/")
    f:addLabel(11, 9, "             __/ |                                     | |")
    f:addLabel(11, 10,"            |___/                                      |_|    ")

    return f
end

-- Главная форма
function createMainForm(nick)
    local mf = forms.addForm()
    mf.border = 1
    mf:addLabel(33, 1, " izd ").fontColor = 0x00FDFF
    local authorLabel = mf:addLabel(32, 25, " Автор: Подарок от 3_14:* ")
    authorLabel.fontColor = 0x00FDFF

    mf:addLabel(5, 4, "Ваш ник: ")
    mf:addLabel(7, 4, nick)

    mf:addLabel(5, 6, "Баланс: ")
    local balance = shopService:getBalance(nick)
    mf:addLabel(27, 6, tostring(balance))

    mf:addButton(60, 5, " Выход ", function()
        AutorizationForm:setActive()
    end).W = 15

    local depositForm = createNumberEditForm(function(count)
        local _, message = shopService:depositMoney(nick, count)
        createNotification(nil, message, nil, function()
            MainForm = createMainForm(nick)
            MainForm:setActive()
        end)
    end, mf, "Пополнить")

    local withdrawForm = createNumberEditForm(function(count)
        local _, message = shopService:withdrawMoney(nick, count)
        createNotification(nil, message, nil, function()
            MainForm = createMainForm(nick)
            MainForm:setActive()
        end)
    end, mf, "Снять")

    mf:addButton(36, 4, "Пополнить баланс", function()
        depositForm:setActive()
    end).W = 20

    mf:addButton(36, 6, "Снять с баланса", function()
        withdrawForm:setActive()
    end).W = 20

    mf:addLabel(5, 8, "Количество предметов: ")
    mf:addLabel(27, 8, tostring(shopService:getItemCount(nick)))

    mf:addButton(36, 8, "Забрать предметы", function()
        createGarbageForm()
    end).W = 20

    mf:addButton(8, 17, " Купить ", function()
        createSellShopForm()
    end).W = 21

    mf:addButton(30, 17, " Продать ", function()
        createBuyShopForm()
    end).W = 22

    mf:addButton(53, 17, " Обмен руд", function()
        createOreExchangerForm()
    end).W = 21

    mf:addButton(8, 21, " Обменик ", function()
        createExchangerForm()
    end).W = 21

    mf:addButton(30, 21, " Примечание ", function()
        RulesForm:setActive()
    end).W = 44

    return mf
end

-- Остальные формы (createGarbageForm, createSellShopForm и т.д.) аналогично
-- (здесь оставлены заглушки, вставьте ваш код)

function createGarbageForm()
    local items = shopService:getItems(nickname)
    -- ...
    -- вставьте ваш код
end

function createSellShopForm()
    -- ...
end

function createSellShopSpecificForm(category)
    -- ...
end

function createBuyShopForm()
    -- ...
end

function createOreExchangerForm()
    -- ...
end

function createExchangerForm()
    -- ...
end

function createRulesForm()
    -- ...
end

function autorize(nick)
    nickname = nick
    MainForm = createMainForm(nick)
    MainForm:setActive()
end

AutorizationForm = createAutorizationForm()
RulesForm = createRulesForm()

-- Подписка на события
AutorizationForm:addEvent("player_on", function(e, p)
    gpu.setResolution(80, 25)
    local playerName = (type(p) == "table" and p.name) or p
    if playerName and playerName ~= "" then
        computer.addUser(playerName)
        autorize(playerName)
    end
end)

AutorizationForm:addEvent("player_off", function(e, p)
    local playerName = (type(p) == "table" and p.name) or p
    if playerName ~= '3_1415926535' and playerName ~= 'izd' then
        computer.removeUser(playerName)
    end
    if timer then timer:stop() end
    AutorizationForm:setActive()
end)

forms.run(AutorizationForm)
