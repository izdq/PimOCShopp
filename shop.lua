local component = require('component')
local computer = require('computer')
local forms = require("forms") -- подключаем библиотеку форм
local gpu = component.gpu
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

local nickname = ""  -- здесь будет храниться имя игрока (строка)

local timer

-- Функция уведомления
function createNotification(status, text, secondText, callback)
    local notificationForm = forms:addForm() -- создаем основную форму
    notificationForm.border = 2
    notificationForm.W = 31
    notificationForm.H = 10
    notificationForm.left = math.floor((MainForm.W - notificationForm.W) / 2)
    notificationForm.top = math.floor((MainForm.H - notificationForm.H) / 2)
    notificationForm:addLabel(math.floor((notificationForm.W - unicode.len(text)) / 2), 3, text)
    if (secondText) then
        notificationForm:addLabel(math.floor((notificationForm.W - unicode.len(secondText)) / 2), 4, secondText)
    end
    timer = notificationForm:addTimer(3, function()
        callback()
        timer:stop()
    end)
    notificationForm:setActive()
end

-- Функция ввода числа (форма редактирования)
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
    local backButton = itemCounterNumberForm:addButton(3, 8, " Назад ", function()
        form:setActive()
    end)
    local acceptButton = itemCounterNumberForm:addButton(17, 8, buttonText, function()
        callback(itemCountEdit.text and tonumber(itemCountEdit.text) or 0)
    end)
    return itemCounterNumberForm
end

-- Функция авторизации (создает форму авторизации)
function createAutorizationForm()
    local AutorizationForm = forms.addForm() -- создаем основную форму
    AutorizationForm.border = 1
    local autorizationLabel = AutorizationForm:addLabel(23, 14, "Что б авторизоваться, встаньте на PIM");

    local authorLabel = AutorizationForm:addLabel(32, 25, " Автор: Подарок от 3_14:* ")
    authorLabel.fontColor = 0x00FDFF

    local nameLabel1 = AutorizationForm:addLabel(11, 3, " _                               _    _____ _                 ")
    local nameLabel2 = AutorizationForm:addLabel(11, 4, "| |                             | |  / ____| |  ")
    local nameLabel3 = AutorizationForm:addLabel(11, 5, "| |     ___  __ _  ___ _ __   __| | | (___ | |__   ___  _ __  ")
    local nameLabel4 = AutorizationForm:addLabel(11, 6, "| |    / _ \\/ _` |/ _ \\ '_ \\ / _` |  \\___ \\| '_ \\ / _ \\| '_ \\ ")
    local nameLabel5 = AutorizationForm:addLabel(11, 7, "| |___|  __/ (_| |  __/ | | | (_| |  ____) | | | | (_) | |_) |")
    local nameLabel6 = AutorizationForm:addLabel(11, 8, "|______\\___|\\__, |\\___|_| |_|\\__,_| |_____/|_| |_|\\___/| .__/")
    local nameLabel7 = AutorizationForm:addLabel(11, 9, "             __/ |                                     | |")
    local nameLabel8 = AutorizationForm:addLabel(11, 10, "            |___/                                      |_|    ")

    authorLabel.fontColor = 0x00FDFF

    return AutorizationForm
end

-- Пример функции создания главной формы магазина
function createMainForm(nick)
    local MainForm = forms.addForm()
    MainForm.border = 1
    local shopNameLabel = MainForm:addLabel(33, 1, " izd ")  -- магазин теперь называется "izd"
    shopNameLabel.fontColor = 0x00FDFF
    local authorLabel = MainForm:addLabel(32, 25, " Автор: Подарок от 3_14:* ")
    authorLabel.fontColor = 0x00FDFF

    MainForm:addLabel(5, 4, "Ваш ник: ")
    MainForm:addLabel(7, 4, nick)

    MainForm:addLabel(5, 6, "Баланс: ")
    MainForm:addLabel(27, 6, shopService:getBalance(nick))

    local sellButton = MainForm:addButton(60, 5, " Выход ", function()
        AutorizationForm:setActive()
    end)
    sellButton.H = 3
    sellButton.W = 15

    local itemCounterNumberSelectDepositBalanceForm = createNumberEditForm(function(count)
        local _, message = shopService:depositMoney(nick, count)
        if (count % 1 ~= 0) then
            createNotification(nil, "Ввод/вывод осуществляется", "кратно 1", function()
                MainForm = createMainForm(nick)
                MainForm:setActive()
            end)
            return
        end
        createNotification(nil, message, nil, function()
            MainForm = createMainForm(nick)
            MainForm:setActive()
        end)
    end, MainForm, "Пополнить")

    local itemCounterNumberSelectWithdrawBalanceForm = createNumberEditForm(function(count)
        if (count % 1 ~= 0) then
            createNotification(nil, "Ввод/вывод осуществляется", "кратно 1", function()
                MainForm = createMainForm(nick)
                MainForm:setActive()
            end)
            return
        end
        local _, message = shopService:withdrawMoney(nick, count)
        createNotification(nil, message, nil, function()
            MainForm = createMainForm(nick)
            MainForm:setActive()
        end)
    end, MainForm, "Снять")

    local depositButton = MainForm:addButton(36, 4, "Пополнить баланс", function()
        itemCounterNumberSelectDepositBalanceForm:setActive()
    end)
    depositButton.W = 20

    local withdrawButton = MainForm:addButton(36, 6, "Снять с баланса", function()
        itemCounterNumberSelectWithdrawBalanceForm:setActive()
    end)
    withdrawButton.W = 20

    MainForm:addLabel(5, 8, "Количество предметов: ")
    MainForm:addLabel(27, 8, shopService:getItemCount(nick))

    local withdrawButtonItems = MainForm:addButton(36, 8, "Забрать предметы", function()
        createGarbageForm()
    end)
    withdrawButtonItems.W = 20

    local buyButton = MainForm:addButton(8, 17, " Купить ", function()
        createSellShopForm()
    end)
    buyButton.H = 3
    buyButton.W = 21

    local sellButtonShop = MainForm:addButton(30, 17, " Продать ", function()
        createBuyShopForm()
    end)
    sellButtonShop.H = 3
    sellButtonShop.W = 22

    local exchangeButton = MainForm:addButton(53, 17, " Обмен руд", function()
        createOreExchangerForm()
    end)
    exchangeButton.H = 3
    exchangeButton.W = 21

    local buyButtonExchange = MainForm:addButton(8, 21, " Обменик ", function()
        createExchangerForm()
    end)
    buyButtonExchange.H = 3
    buyButtonExchange.W = 21

    local sellButtonRules = MainForm:addButton(30, 21, " Примечание ", function()
        RulesForm:setActive()
    end)
    sellButtonRules.H = 3
    sellButtonRules.W = 44

    return MainForm
end

function createSellShopForm()
    SellShopForm = forms.addForm()
    SellShopForm.border = 1
    local shopNameLabel = SellShopForm:addLabel(33, 1, " izd ")
    shopNameLabel.fontColor = 0x00FDFF
    local authorLabel = SellShopForm:addLabel(32, 25, " Автор: Подарок от: 3_14:* ")
    authorLabel.fontColor = 0x00FDFF

    local buyButton2 = SellShopForm:addLabel(23, 3, " █▀▀█ █▀▀█ █ █ █  █ █▀▀█ █ █ █▀▀█ ")
    local buyButton3 = SellShopForm:addLabel(23, 4, " █  █ █  █ █▀▄ █▄▄█ █  █ █▀▄ █▄▄█ ")
    local buyButton4 = SellShopForm:addLabel(23, 5, " ▀  ▀ ▀▀▀▀ ▀ ▀ ▄▄▄█ ▀  ▀ ▀ ▀ ▀  ▀ ")

    local categoryButton1 = SellShopForm:addButton(5, 9, " Разное ", function()
        createSellShopSpecificForm("Minecraft")
    end)
    categoryButton1.W = 23
    categoryButton1.H = 3
    local categoryButton2 = SellShopForm:addButton(29, 9, " Industrial Craft 2 ", function()
        createSellShopSpecificForm("IC2")
    end)
    categoryButton2.W = 24
    categoryButton2.H = 3
    local categoryButton3 = SellShopForm:addButton(54, 9, " Applied Energistics 2 ", function()
        createSellShopSpecificForm("AE2")
    end)
    categoryButton3.W = 23
    categoryButton3.H = 3

    local categoryButton4 = SellShopForm:addButton(5, 13, " Forestry ", function()
        createSellShopSpecificForm("Forestry")
    end)
    categoryButton4.W = 23
    categoryButton4.H = 3
    local categoryButton5 = SellShopForm:addButton(29, 13, " Зачарованные книги ", function()
        createSellShopSpecificForm("Books")
    end)
    categoryButton5.W = 24
    categoryButton5.H = 3
    local categoryButton6 = SellShopForm:addButton(54, 13, " Draconic Evolution ", function()
        createSellShopSpecificForm("DE")
    end)
    categoryButton6.W = 23
    categoryButton6.H = 3

    local categoryButton7 = SellShopForm:addButton(5, 17, " Thermal Expansion ", function()
        createSellShopSpecificForm("TE")
    end)
    categoryButton7.W = 23
    categoryButton7.H = 3
    local categoryButton8 = SellShopForm:addButton(29, 17, " Скоро ")
    categoryButton8.W = 24
    categoryButton8.H = 3
    categoryButton8.fontColor = 0xaaaaaa
    categoryButton8.color = 0x000000
    local categoryButton9 = SellShopForm:addButton(54, 17, " Скоро ")
    categoryButton9.W = 23
    categoryButton9.H = 3
    categoryButton9.fontColor = 0xaaaaaa
    categoryButton9.color = 0x000000

    local shopBackButton = SellShopForm:addButton(3, 23, " Назад ", function()
        MainForm = createMainForm(nickname)
        MainForm:setActive()
    end)

    SellShopForm:setActive()
end

function createSellShopSpecificForm(category)
    local items = shopService:getSellShopList(category)
    for i = 1, #items do
        local name = items[i].label
        for j = 1, 51 - unicode.len(name) do
            name = name .. ' '
        end
        name = name .. items[i].count

        for j = 1, 62 - unicode.len(name) do
            name = name .. ' '
        end

        name = name .. items[i].price

        items[i].displayName = name
    end

    SellShopSpecificForm = createListForm(" Магазин ",
        " Наименование                                       Количество Цена    ",
        items,
        {
            createButton(" Назад ", 4, 23, function(selectedItem)
                createSellShopForm()
            end),
            createButton(" Купить ", 68, 23, function(selectedItem)
                local itemCounterNumberSelectForm = createNumberEditForm(function(count)
                    local _, message = shopService:sellItem(nickname, selectedItem, count)
                    createNotification(nil, message, nil, function()
                        createSellShopSpecificForm(category)
                    end)
                end, SellShopForm, "Купить")
                if (selectedItem) then
                    itemCounterNumberSelectForm:setActive()
                end
            end)
        })

    SellShopSpecificForm:setActive()
end

function createBuyShopForm()
    local items = shopService:getBuyShopList()
    for i = 1, #items do
        local name = items[i].label
        for j = 1, 51 - unicode.len(name) do
            name = name .. ' '
        end
        name = name .. items[i].count

        for j = 1, 62 - unicode.len(name) do
            name = name .. ' '
        end

        name = name .. items[i].price

        items[i].displayName = name
    end

    BuyShopForm = createListForm(" Скупка ",
        " Наименование                                       Количество Цена    ",
        items,
        {
            createButton(" Назад ", 4, 23, function(selectedItem)
                MainForm = createMainForm(nickname)
                MainForm:setActive()
            end),
            createButton(" Продать ", 68, 23, function(selectedItem)
                if (selectedItem) then
                    local itemCounterNumberSelectForm = createNumberEditForm(function(count)
                        local _, message = shopService:buyItem(nickname, selectedItem, count)
                        createNotification(nil, message, nil, function()
                            createBuyShopForm()
                        end)
                    end, MainForm, "Продать")
                    itemCounterNumberSelectForm:setActive()
                end
            end)
        })

    BuyShopForm:setActive()
end

function createOreExchangerForm()
    local items = shopService:getOreExchangeList()
    for i = 1, #items do
        local name = items[i].fromLabel
        for j = 1, 58 - unicode.len(name) do
            name = name .. ' '
        end
        name = name .. items[i].fromCount .. 'к' .. items[i].toCount

        items[i].displayName = name
    end

    OreExchangerForm = createListForm(" Обмен руд ",
        " Наименование                                              Курс обмена ",
        items,
        {
            createButton(" Назад ", 4, 23, function(selectedItem)
                MainForm = createMainForm(nickname)
                MainForm:setActive()
            end),
            createButton(" Обменять все ", 67, 23, function(selectedItem)
                local _, message = shopService:exchangeAllOres(nickname)
                createNotification(nil, message, nil, function()
                    createOreExchangerForm()
                end)
            end),
            createButton(" Обменять ", 54, 23, function(selectedItem)
                if (selectedItem) then
                    local itemCounterNumberSelectForm = createNumberEditForm(function(count)
                        local _, message, message2 = shopService:exchangeOre(nickname, selectedItem, count)
                        createNotification(nil, message, message2, function()
                            createOreExchangerForm()
                        end)
                    end, OreExchangerForm, "Обменять")
                    itemCounterNumberSelectForm:setActive()
                end
            end)
        })

    OreExchangerForm:setActive()
end

function createExchangerForm()
    local items = shopService:getExchangeList()
    for i = 1, #items do
        local name = items[i].fromLabel
        for j = 1, 25 - unicode.len(name) do
            name = name .. ' '
        end
        name = name .. items[i].fromCount .. 'к' .. items[i].toCount
        for j = 1, 50 - unicode.len(name) do
            name = name .. ' '
        end
        name = name .. items[i].toLabel
        items[i].displayName = name
    end

    ExchangerForm = createListForm(" Обменик ",
        " Наименование             Курс обмена              Наименование       ",
        items,
        {
            createButton(" Назад ", 4, 23, function(selectedItem)
                MainForm = createMainForm(nickname)
                MainForm:setActive()
            end),
            createButton(" Обменять ", 68, 23, function(selectedItem)
                if (selectedItem) then
                    local itemCounterNumberSelectForm = createNumberEditForm(function(count)
                        local _, message, message2 = shopService:exchange(nickname, selectedItem, count)
                        createNotification(nil, message, message2, function()
                            createExchangerForm()
                        end)
                    end, ExchangerForm, "Обменять")
                    itemCounterNumberSelectForm:setActive()
                end
            end)
        })

    ExchangerForm:setActive()
end

function createRulesForm()
    local ShopForm = forms.addForm()
    ShopForm.border = 1
    local shopFrame = ShopForm:addFrame(3, 5, 1)
    shopFrame.W = 76
    shopFrame.H = 18
    local shopNameLabel = ShopForm:addLabel(33, 1, " PI Shop ")
    shopNameLabel.fontColor = 0x00FDFF
    local authorLabel = ShopForm:addLabel(32, 25, " Автор: Подарок от 3_14:* ")
    authorLabel.fontColor = 0x00FDFF

    local shopNameLabel = ShopForm:addLabel(35, 4, " Примечания ")

    local ruleList = ShopForm:addList(5, 6, function() end)
    ruleList:insert("1. Баланс на компьютерах разный, пользуйтесь одним магазином для удобства пользования! ")
    ruleList:insert("2. При возникновении какого либо вопроса, обращайтесь к:")
    ruleList:insert("   3_1415926535")
    ruleList:insert("3. Хорошего дня")

    ruleList.border = 0
    ruleList.W = 73
    ruleList.H = 15
    ruleList.fontColor = 0xFF8F00

    local shopBackButton = ShopForm:addButton(3, 23, " Назад ", function()
        MainForm = createMainForm(nickname)
        MainForm:setActive()
    end)
    shopBackButton.H = 1
    shopBackButton.W = 9
    return ShopForm
end

function autorize(nick)
    MainForm = createMainForm(nick)
    nickname = nick
    MainForm:setActive()
end

-- Создаем формы авторизации и правил
AutorizationForm = createAutorizationForm()
RulesForm = createRulesForm()

-- Регистрируем события для авторизации
local EventOn = AutorizationForm:addEvent("player_on", function(e, p)
    gpu.setResolution(80, 25)
    local playerName = type(p) == "table" and p.name or tostring(p)
    if (playerName and playerName ~= "") then
        computer.addUser(playerName)
        autorize(playerName)
    end
end)

local EventOff = AutorizationForm:addEvent("player_off", function(e, p)
    local playerName = type(p) == "table" and p.name or tostring(p)
    if (playerName ~= '3_1415926535') and (playerName ~= 'izd') then
        computer.removeUser(playerName)
    end
    if (timer) then
        timer:stop()
    end
    AutorizationForm:setActive()
end)

forms.run(AutorizationForm) -- запускаем gui
