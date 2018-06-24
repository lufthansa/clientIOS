--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local cmd = appdf.req(appdf.GAME_SRC.."yule.thirteen.src.models.CMD_Game")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.thirteen.src.models.GameLogic")

local GameEndLayer = class("GameEndLayer", cc.Layer)

GameEndLayer.BT_SHARE = 1
GameEndLayer.BT_START = 2
GameEndLayer.BT_HIDE = 3
GameEndLayer.BT_LOOK = 4

GameEndLayer.RES_PATH 				= "game/yule/thirteen/res/"

--构造
function GameEndLayer:ctor( parent)

    self.m_parent = parent
    --注册触摸事件
    ExternalFun.registerTouchEvent(self, true)

    --加载csb资源
    local csbNode = ExternalFun.loadCSB(GameEndLayer.RES_PATH.."gameend.csb", self)

    --按钮事件
    local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

    self.btShare = csbNode:getChildByName("Button_1")
    self.btShare:setTag(GameEndLayer.BT_SHARE)
    self.btShare:addTouchEventListener(btcallback)

    self.btStart = csbNode:getChildByName("Button_2")
    self.btStart:setTag(GameEndLayer.BT_START)
    self.btStart:addTouchEventListener(btcallback)
	
	self.btHide = csbNode:getChildByName("Button_3")
    self.btHide:setTag(GameEndLayer.BT_HIDE)
    self.btHide:addTouchEventListener(btcallback)
	
	self.btLookResult = csbNode:getChildByName("Button_4")
    self.btLookResult:setTag(GameEndLayer.BT_LOOK)
    self.btLookResult:addTouchEventListener(btcallback)
	self.btLookResult:setVisible(false)

    self.GameEndSome = {}
    self.GameEndNobody = {}
    for i = 1,cmd.GAME_PLAYER do
		self.GameEndSome[i] = csbNode:getChildByName("GameEndSome_"..i)
		self.GameEndNobody[i] = csbNode:getChildByName("GameEndNobody_"..i)
    end

	self:setUserInfo()
    
    local temp = display.newSprite(GameEndLayer.RES_PATH.."SoSmallCard.png")
	local cardWidth = temp:getContentSize().width/13
	local cardHeight = temp:getContentSize().height/5
    --绘制扑克
    --[[local tempdata = {};
    GameLogic:RandCardList(tempdata,52);
    local cbCardData = {}
	for i = 1,cmd.GAME_PLAYER do
		cbCardData[i] = {}
	end
    for i = 1,cmd.GAME_PLAYER do
        for j = 1,13 do
            table.insert(cbCardData[i],tempdata[(i - 1) + j])
        end
    end
    --]]
    local cbCardData = self.m_parent._scene.cbCardData
    local posTop = self.GameEndSome[1]:getContentSize().height - 90
    local posLeft = self.GameEndSome[1]:getContentSize().width/2 - 2*cardWidth
    for i = 1,cmd.GAME_PLAYER do
        -- change by Owen, 2018.4.26, 所有的结算节点都要摆上手牌, 不然金币场换了个人进来玩就崩了
        -- if self.m_parent._scene.cbPlayStatus[i] == 1 then --玩家游戏中
        --if self.m_parent._scene.cbPlayStatus[i] == 0 then --玩家游戏中
            for j = 1,13 do
                local card = display.newSprite(GameEndLayer.RES_PATH.."SoSmallCard.png")
                local data = cbCardData[i][j]
                local value = GameLogic:GetCardValue(data)
                local color = GameLogic:GetCardColor(data)
                local rectCard = card:getTextureRect()
                rectCard.x = cardWidth * (value - 1)
                rectCard.y = cardHeight * color
                rectCard.width = cardWidth
                rectCard.height = cardHeight
                card:setTextureRect(rectCard)
				card:setTag(j)
                if j <= 3 then
                    local x = posLeft + cardWidth
                    card:move(cc.p(x + (j - 1) * cardWidth,posTop))
                elseif j <= 8 then
                    card:move(cc.p(posLeft + (j - 1 - 3) * cardWidth,posTop - cardHeight))
                else
                    card:move(cc.p(posLeft + (j - 1 - 8) * cardWidth,posTop - 2*cardHeight))
                end
                card:addTo(self.GameEndSome[i])
            end
        -- end
    end

end
function GameEndLayer:onButtonClickedEvent(tag,ref)
    if tag == GameEndLayer.BT_SHARE then
		self:shareCallBack()
    elseif tag == GameEndLayer.BT_START then
		self.m_parent:onResetView()
		self.m_parent._scene:onStartGame()
        self:setVisible(false)
		self:setBtnVisible(false)
	elseif tag == GameEndLayer.BT_HIDE then
		self:setVisible(false)
		self.m_parent.btShowEnd:setVisible(true)
	elseif tag == GameEndLayer.BT_LOOK then
		--显示约战结果
		--私人房
		if PriRoom and GlobalUserItem.bPrivateRoom then
			if nil ~= self.m_parent._scene._gameView._priView and nil ~= self.m_parent._scene._gameView._priView.setZanLiBtnVisible then
				self.m_parent._scene._gameView._priView:setResultLayerVisible(true)
			end
		end
    end
end
function GameEndLayer:onTouchBegan(touch, event)
    return self:isVisible()
end
function GameEndLayer:onTouchEnded(touch, event)
end
function GameEndLayer:shareCallBack()
	GlobalUserItem.bAutoConnect = false
	self.m_parent:getParentNode():getParentNode():popTargetShare(function(target, bMyFriend)
		bMyFriend = bMyFriend or false
		local function sharecall( isok )
			if type(isok) == "string" and isok == "true" then
				--showToast(self, "分享成功", 2)
			end
			GlobalUserItem.bAutoConnect = true
		end
		local shareTxt = "凌竹十三水游戏精彩刺激, 一起来玩吧! "
		local url = GlobalUserItem.szSpreaderURL or yl.HTTP_URL
		if bMyFriend then
			PriRoom:getInstance():getTagLayer(PriRoom.LAYTAG.LAYER_FRIENDLIST, function( frienddata )
				dump(frienddata)
			end)
		elseif nil ~= target then
			MultiPlatform:getInstance():shareToTarget(target, sharecall, "凌竹十三水游戏邀请", shareTxt, url, "")
		end
	end) 
end
function GameEndLayer:setUserInfo()
	for i = 1,cmd.GAME_PLAYER do
        if self.m_parent._scene.cbPlayStatus[i] == 1 then --玩家游戏中
        --if self.m_parent._scene.cbPlayStatus[i] == 0 then --玩家游戏中
            self.GameEndSome[i]:setVisible(true)
            self.GameEndNobody[i]:setVisible(false)
            self.GameEndSome[i]:getChildByName("Text"):setString(""..self.m_parent.finalResult[i])
            self.GameEndSome[i]:getChildByName("Name"):setString(self.m_parent.userName[i])
        else
            self.GameEndSome[i]:setVisible(false)
            self.GameEndNobody[i]:setVisible(true)
        end
    end
end
function GameEndLayer:updateCardInfo()
	local cbCardData = self.m_parent._scene.cbCardData
	for i = 1,cmd.GAME_PLAYER do
        if self.m_parent._scene.cbPlayStatus[i] == 1 then --玩家游戏中
			for j = 1,13 do
				local card = self.GameEndSome[i]:getChildByTag(j)
				local data = cbCardData[i][j]
                local value = GameLogic:GetCardValue(data)
                local color = GameLogic:GetCardColor(data)
                local rectCard = card:getTextureRect()
                rectCard.x = rectCard.width * (value - 1)
                rectCard.y = rectCard.height * color
                card:setTextureRect(rectCard)
			end
		end
	end
end
function GameEndLayer:setBtnVisible(bVisible)
	self.btShare:setVisible(bVisible)
	self.btStart:setVisible(bVisible)
end
return GameEndLayer
--endregion
