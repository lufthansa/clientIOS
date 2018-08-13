--
-- Author: zhong
-- Date: 2016-07-25 15:19:39
--
--[[
* 通用带弹窗显示个人信息的头像类
]]

local PopupInfoHead = class("PopupInfoHead", cc.Node)
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local HeadSprite = require(appdf.EXTERNAL_SRC .. "HeadSprite")
local PopupInfoLayer = require(appdf.EXTERNAL_SRC .. "PopupInfoLayer")

local POP_LAYERNAME = "pop_headinfo_layer"
local POP_LAYERNAME_GAME = "pop_headinfo_layer_game"
function PopupInfoHead:ctor( )
	ExternalFun.registerNodeEvent(self)
	self.m_head = nil
	self.m_bIsGamePop = true
	self.m_bChudian = true

end

function PopupInfoHead:createNormal( useritem ,headSize)
	local sf = PopupInfoHead.new()
	local head = HeadSprite:createNormal(useritem, headSize)
	sf.m_useritem = useritem
	sf.m_head = head
	if nil ~= head then
		sf:addChild(head)
	end
	return sf, head
end

function PopupInfoHead:createClipHead( useritem, headSize, clippingfile )
	local sf = PopupInfoHead.new()
	local head = HeadSprite:createClipHead(useritem, headSize, clippingfile)
	sf.m_useritem = useritem
	sf.m_head = head
	if nil ~= head then
		sf:addChild(head)
	end
	return sf, head
end

--设置是否是游戏界面弹窗
function PopupInfoHead:setIsGamePop( var )
	self.m_bIsGamePop = var
end

function PopupInfoHead:setshowHead( bool )
	self.m_bChudian = bool
end

--更新头像
function PopupInfoHead:updateHead(useritem, scene)
	self.m_useritem = useritem
	if nil ~= self.m_head then
		self.m_head:updateHead(useritem)
	end
	print("PopupInfoHead:updateHead self._scene = scene	")
	self._scene = scene
end

--[[
* 是否设置游戏头像点击显示详细信息
* [bEnable] 是否设置
* [popPos] 弹窗位置,以锚点为(0,0)计算而来的位置
* [anr] 弹窗锚点,默认为(0,0)
]]
function PopupInfoHead:enableInfoPop( bEnable, popPos, anr)
	local function funCall( )
		self:onTouchHead()
	end
	self.m_popPos = popPos or self:getInfoLayerPos()
	self.m_popAnchor = anr or self:getInfoLayerAnchor()

	if nil ~= self.m_head then
		self.m_head:registerInfoPop(bEnable, funCall)
	end

	if bEnable then

	else
		local infoLayer = nil
		if self.m_bIsGamePop then
			infoLayer = cc.Director:getInstance():getRunningScene():getChildByName(POP_LAYERNAME_GAME)
		else
			infoLayer = cc.Director:getInstance():getRunningScene():getChildByName(POP_LAYERNAME)
		end
		if nil ~= infoLayer then
			infoLayer:removeFromParent()
		end
	end
end

--头像框
function PopupInfoHead:enableHeadFrame( bEnable, frameparam )
	if nil ~= self.m_head then
		self.m_head:enableHeadFrame(bEnable, frameparam)
	end
end

function PopupInfoHead:onTouchHead(  )
	if self.m_bChudian == false then
		return
	end

	local infoLayer = nil
	local name = ""
	if self.m_bIsGamePop then
		name = POP_LAYERNAME_GAME
		infoLayer = cc.Director:getInstance():getRunningScene():getChildByName(POP_LAYERNAME_GAME)
	else
		name = POP_LAYERNAME
		infoLayer = cc.Director:getInstance():getRunningScene():getChildByName(POP_LAYERNAME)
	end
	if nil == infoLayer then
		infoLayer = PopupInfoLayer:create(self, self.m_bIsGamePop)
		local runningScene = cc.Director:getInstance():getRunningScene()
		if nil ~= runningScene then
			runningScene:addChild(infoLayer)
			infoLayer:setName(name)
		end
	end

	if nil ~= infoLayer and nil ~= self.m_useritem then
		infoLayer:showLayer(true)
		infoLayer:refresh(self.m_useritem, self.m_popPos, self.m_popAnchor)

		-- add by Owen, 如果自己有权限作弊, 则每个玩家头像面板都加一个特殊牌按钮
		if GLobal_I_Can_Cheat then
			local giveMeBigCard = infoLayer:getChildByName("giveMeBigCard")
			if giveMeBigCard then
				giveMeBigCard:removeFromParent()
			end
			giveMeBigCard = ccui.Button:create("game/btn_Show.png")
						:setVisible(true)
						:setScale(0.8)
						:addTo(infoLayer)

			giveMeBigCard:setName("giveMeBigCard")

			giveMeBigCard:addTouchEventListener(function(ref, type)
		        if type == ccui.TouchEventType.ended then
		         	local numid = self.m_useritem.dwGameID or ""
					print("self.m_useritem.dwGameID = "..tostring(self.m_useritem.dwGameID))
					self._scene:onGiveMeBigCard(numid)
		        end
		    end)

		    giveMeBigCard:setPosition(self.m_popPos.x + 220, self.m_popPos.y + 90)
		end




	end
end

function PopupInfoHead:getInfoLayerPos(  )
	local size = cc.Director:getInstance():getWinSize()
	return cc.p(size.width * 0.11, size.height * 0.26)
end

function PopupInfoHead:getInfoLayerAnchor(  )
	return cc.p(0, 0)
end

function PopupInfoHead:onExit()
	--强行移除layer，在关闭程序的时候会异常
	local infoLayer = nil
	if self.m_bIsGamePop then
		name = POP_LAYERNAME_GAME
		infoLayer = cc.Director:getInstance():getRunningScene():getChildByName(POP_LAYERNAME_GAME)
	else
		name = POP_LAYERNAME
		infoLayer = cc.Director:getInstance():getRunningScene():getChildByName(POP_LAYERNAME)
	end
	if nil ~= infoLayer and nil ~= infoLayer.hide then
		infoLayer:hide()
	end
end
return PopupInfoHead