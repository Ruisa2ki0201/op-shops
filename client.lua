local QBCore = exports['qb-core']:GetCoreObject()

-- サイトのターゲットを設定
for _, shop in pairs(Config.Shops) do
    exports['qb-target']:AddCircleZone("Shop_" .. shop.name, shop.coords, 1.0, {
        name = "Shop_" .. shop.name,
        useZ = true,
        debugPoly = false,
    }, {
        options = {
            {
                event = "shop:openMenu",
                icon = "fas fa-shopping-cart",
                label = "Shop - " .. shop.displayName,  -- displayNameを使用
            },
        },
        distance = 2.5,
    })
end

-- 現在のショップ名を取得
function GetCurrentShopName()
    local playerCoords = GetEntityCoords(PlayerPedId()) -- プレイヤーの位置を取得
    local currentShopName = nil

    for _, shop in pairs(Config.Shops) do
        -- ショップの位置範囲を定義する
        if Vdist(playerCoords, shop.coords.x, shop.coords.y, shop.coords.z) < 10.0 then
            currentShopName = shop.name
            break
        end
    end

    return currentShopName or "Unknown Shop" -- ショップが見つからない場合
end

-- プレイヤーのジョブを取得する関数
function GetPlayerJob()
    local playerData = QBCore.Functions.GetPlayerData()
    if playerData and playerData.job then
        return playerData.job.name
    else
        return nil
    end
end

RegisterNetEvent("shop:openMenu", function()
    local currentShopName = GetCurrentShopName() -- 現在のショップ名を取得
    local currentShop = nil

    -- 現在のショップを取得
    for _, shop in pairs(Config.Shops) do
        if shop.name == currentShopName then
            currentShop = shop
            break
        end
    end

    -- ショップが見つからない場合
    if not currentShop then
        print("Error: Current shop not found.")
        return
    end

    -- プレイヤーのジョブのチェックを削除
    -- if playerJob ~= currentShop.job then
    --     TriggerEvent('notification', 'You do not have permission to access this shop.', 2)
    --     return
    -- end

    local shopItems = {}

    -- ショップのアイテムを取得
    table.insert(shopItems, { header = currentShop.displayName, isMenuHeader = true })
    for _, item in ipairs(currentShop.items) do
        local itemName = Config.ItemNames[item] or item -- アイテムの表示名を取得
        local itemPrice = Config.Prices[item] or 0 -- アイテムの価格
        -- ox_inventoryの画像パスを使用
        local itemImage = "nui://ox_inventory/web/images/" .. item .. ".png" -- アイテムの画像パスを取得

        table.insert(shopItems, {
            header = itemName, -- アイテムの表示名を表示
            txt = "Price: $" .. itemPrice, -- 価格を表示
            icon = itemImage, -- アイテム画像を表示
            params = {
                event = "shop:askQuantity",
                args = item,
            },
        })
    end

    table.insert(shopItems, { header = "Close", params = { event = "qb-menu:closeMenu" } })
    exports['qb-menu']:openMenu(shopItems)
end)




RegisterNetEvent("shop:askQuantity", function(item)
    local input = exports['qb-input']:ShowInput({
        header = "Buy " .. item,
        submitText = "Purchase",
        inputs = {
            {
                text = "Quantity",
                name = "quantity",
                type = "number",
                isRequired = true,
            },
        },
    })

    if input then
        local quantity = tonumber(input.quantity)
        if quantity and quantity > 0 then
            TriggerServerEvent("shop:buyItem", item, quantity)
        else
            TriggerEvent("QBCore:Notify", "Invalid quantity!", "error")
        end
    end
end)







-- アイテム購入
RegisterNetEvent("shop:buyItem", function(item)
    TriggerServerEvent("shop:purchaseItem", item)
end)

-- 現在のショップ名を取得
function GetCurrentShopName()
    local playerCoords = GetEntityCoords(PlayerPedId()) -- プレイヤーの位置を取得
    local currentShopName = nil
    local closestDistance = 10.0  -- 距離の閾値

    for _, shop in pairs(Config.Shops) do
        local shopCoords = shop.coords
        -- プレイヤーとショップの距離を計算
        local distance = Vdist(playerCoords, shopCoords.x, shopCoords.y, shopCoords.z)

        -- 距離が閾値以内であればショップ名を設定
        if distance < closestDistance then
            currentShopName = shop.name
            break -- 最初に見つけたショップでループを終了
        end
    end

    return currentShopName or "Unknown Shop" -- ショップが見つからない場合
end

