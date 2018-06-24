--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local SpecialCardLayer = class("SpecialCardLayer", cc.Layer)

SpecialCardLayer.BT_OK = 1
SpecialCardLayer.BT_CANCEL = 2
--SpecialCardLayer.BT_SHOW =3
function SpecialCardLayer:ctor( cardtype,parent )
	self.m_parent = parent

--注册触摸事件
    ExternalFun.registerTouchEvent(self, true)

    --加载csb资源
    local csbNode = ExternalFun.loadCSB("game/yule/thirteen/res/specialCard/specialCardLayer.csb", self)

    --按钮事件
    local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end
    self:setColor(cc.BLACK)
    self.btok = csbNode:getChildByName("ok")
    self.btok:setTag(SpecialCardLayer.BT_OK)
    self.btok:addTouchEventListener(btcallback)

    self.btcancel = csbNode:getChildByName("cancel")
    self.btcancel:setTag(SpecialCardLayer.BT_CANCEL)
    self.btcancel:addTouchEventListener(btcallback)

    self.spriteCardType = csbNode:getChildByName("cardType")
    local width = self.spriteCardType:getContentSize().width
    local height = self.spriteCardType:getContentSize().height / 13
    self.spriteCardType:setTextureRect(cc.rect(0,height * (13 - cardtype),width,height))
    self.spriteCardType:setScale(1.5)
	


end

function SpecialCardLayer:onButtonClickedEvent(tag,ref)
    if tag == SpecialCardLayer.BT_OK then
		local index = self.m_parent._scene:GetMeChairID() + 1
		local specail = self.m_parent._scene.cbSpecialCard[index]
		local data = self.m_parent._scene.cbCardData[index]
		self.m_parent:onBtOutCard(data,specail)
		self:setVisible(false)
    elseif tag == SpecialCardLayer.BT_CANCEL then
        self:setVisible(false)
		self.m_parent.btnShow:setVisible(true)
    end
end

function SpecialCardLayer:setType(cardtype)
	local width = self.spriteCardType:getContentSize().width
    local height = self.spriteCardType:getContentSize().height
    self.spriteCardType:setTextureRect(cc.rect(0,height * (13 - cardtype),width,height))
end
function SpecialCardLayer:onTouchBegan(touch, event)
    return self:isVisible()
end
function SpecialCardLayer:onTouchEnded(touch, event)
end
return SpecialCardLayer

--endregion
