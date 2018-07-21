--
-- Author: wang
-- Date: 2017-2-8 
--
----
 -- _ooOoo_
 -- o8888888o
 -- 88" . "88
 -- (| -_- |)
 --  O\ = /O
 -- ___/`---'\____
 -- .   ' \\| |// `.
 -- / \\||| : |||// \
 -- / _||||| -:- |||||- \
 -- | | \\\ - /// | |
 -- | \_| ''\---/'' | |
 -- \ .-\__ `-` ___/-. /
 -- ___`. .' /--.--\ `. . __
 -- ."" '< `.___\_<|>_/___.' >'"".
 -- | | : `- \`.;`\ _ /`;.`/ - ` : | |
 -- \ \ `-. \_ __\ /__ _/ .-` / /
 -- ======`-.____`-.___\_____/___.-`____.-'======
 -- `=---='
 --          .............................................
 --           佛曰：bug泛滥，我已瘫痪！
 --/


-- 斗地主私人房创建界面
local CreateLayerModel = appdf.req(PriRoom.MODULE.PLAZAMODULE .."models.CreateLayerModel")

local PriRoomCreateLayer = class("PriRoomCreateLayer", CreateLayerModel)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local Shop = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ShopLayer")

local ClipText = appdf.req(appdf.EXTERNAL_SRC .. "ClipText")

local BTN_HELP = 1
local BTN_CHARGE = 2
local BTN_MYROOM = 3
local BTN_CREATE = 4
local CBT_BEGIN = 300
local CBT_PLAYERNUM_BEGIN = 400 --玩家人数设置checkbox TAG 

function PriRoomCreateLayer:ctor( scene )
    PriRoomCreateLayer.super.ctor(self, scene)
    -- 加载csb资源
    local rootLayer, csbNode = ExternalFun.loadRootCSB("room/PrivateRoomCreateLayer.csb", self )
    self.m_csbNode = csbNode

    local function btncallback(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end
    -- 帮助按钮
    local btn = csbNode:getChildByName("btn_help")
    btn:setTag(BTN_HELP)
    btn:addTouchEventListener(btncallback)
    btn:setVisible(false)

    numbg = csbNode:getChildByName("pri_sp_numbg")
    numbg:setVisible(false)
    cardbg_3 = csbNode:getChildByName("pri_sp_cardbg_3")
    cardbg_3:setVisible(false)
    

    -- 充值按钮
    btn = csbNode:getChildByName("btn_cardcharge")
    btn:setTag(BTN_CHARGE)
    btn:addTouchEventListener(btncallback)    
    btn:setVisible(false)

    -- 房卡数
    self.m_txtCardNum = csbNode:getChildByName("txt_cardnum")
    self.m_txtCardNum:setString(GlobalUserItem.lRoomCard .. "")
    self.m_txtCardNum:setVisible(false)

    -- 我的房间
    btn = csbNode:getChildByName("btn_myroom")
    btn:setTag(BTN_MYROOM)
    btn:addTouchEventListener(btncallback)

    -- 人数选项
    local cbtPlayerNumlistener = function (sender,eventType)
        self:onPlayerNumSelectedEvent(sender:getTag(),sender)
    end
    self.m_tabPlayerNumCheckBox = {}

    for i=1,5 do
        local checkbx = csbNode:getChildByName("check_" .. i)
        if nil ~= checkbx then
            checkbx:setVisible(true)
            checkbx:setTag(CBT_PLAYERNUM_BEGIN + i)
            checkbx:addEventListener(cbtPlayerNumlistener)
            checkbx:setSelected(false)
            self.m_tabPlayerNumCheckBox[CBT_PLAYERNUM_BEGIN + i] = checkbx
        end
    end
   -- 选择的人数，默认为第3个    
    self.m_nPlayerNumSelectIdx = CBT_PLAYERNUM_BEGIN + 3
    self.m_tabPlayNumSelect = {2, 3, 4, 5, 0}
    self.m_tabPlayerNumCheckBox[self.m_nPlayerNumSelectIdx]:setSelected(true)

    local cbtlistener = function (sender,eventType)
        self:onSelectedEvent(sender:getTag(),sender)
    end
    self.m_tabCheckBox = {}

    -- 玩法选项，默认为第3个   
    for i = 1, #PriRoom:getInstance().m_tabFeeConfigList do
        local config = PriRoom:getInstance().m_tabFeeConfigList[i]
        local checkbx = csbNode:getChildByName("check_" .. i .. "_0")
        print("局数选项".."check_" .. i .. "_0")
        if nil ~= checkbx then
            checkbx:setVisible(true)
            checkbx:setTag(CBT_BEGIN + i)
            checkbx:addEventListener(cbtlistener)
            checkbx:setSelected(false)
            self.m_tabCheckBox[CBT_BEGIN + i] = checkbx
        end

        local txtcount = csbNode:getChildByName("count_" .. i .. "_0")
        if nil ~= txtcount then
            txtcount:setString(config.dwDrawCountLimit .. "局")
        end
    end
    -- 选择的玩法    
    self.m_nSelectIdx = CBT_BEGIN + 3
    self.m_tabSelectConfig = PriRoom:getInstance().m_tabFeeConfigList[self.m_nSelectIdx - CBT_BEGIN]
    self.m_tabCheckBox[self.m_nSelectIdx]:setSelected(true)

    self.m_bLow = false
    -- 创建费用
    self.m_txtFee = csbNode:getChildByName("txt_fee")
    self.m_txtFee:setString("")
    if GlobalUserItem.lRoomCard < self.m_tabSelectConfig.lFeeScore then
        self.m_bLow = true
    end
    local feeType = "房卡"
    if nil ~= self.m_tabSelectConfig then        
        if PriRoom:getInstance().m_tabRoomOption.cbCardOrBean == 0 then
            feeType = "游戏豆"
            self.m_bLow = false
            if GlobalUserItem.dUserBeans < self.m_tabSelectConfig.lFeeScore then
                self.m_bLow = true
            end
        end
        self.m_txtFee:setString(self.m_tabSelectConfig.lFeeScore .. feeType)
    end

    -- 提示
    self.m_spTips = csbNode:getChildByName("priland_sp_card_tips")
    self.m_spTips:setVisible(self.m_bLow)
    if PriRoom:getInstance().m_tabRoomOption.cbCardOrBean == 0 then

        -- change by Owen, 2018.6.23, 豆子不足的提示往下移动
        self.m_spTips:setPosition(self.m_spTips:getPositionX() - 240,
        self.m_spTips:getPositionY() - 50)

        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("priland_sp_card_tips_bean.png")
        if nil ~= frame then
            self.m_spTips:setSpriteFrame(frame)
        end
    end

    

    local puTonglistener = function (sender,eventType)
        self:onSelectedPuTongEvent(sender:getTag(),sender)
    end
    local wanglistener = function (sender,eventType)
        self:onSelectedWangEvent(sender:getTag(),sender)
    end
    local checkbx = csbNode:getChildByName("check_" .. 1)

    -- 普通玩法
    self.m_clipPuTong = ClipText:createClipText(cc.size(240, 80),"玩法选项： 普通玩法")
    self.m_clipPuTong:setPosition(self.m_txtFee:getPositionX() + 180, self.m_txtFee:getPositionY())
    checkbx:getParent():addChild(self.m_clipPuTong)
    self.m_clipPuTong:setAnchorPoint(cc.p(0.0,0.5))
    self.m_clipPuTong:setTextFontSize(26)
    self.m_clipPuTong:setTextColor(cc.c4b(255,232,170,255))
    -- 克隆一个check用来做有没有王的配置
    local puTongCheckBx = checkbx:clone()
    checkbx:getParent():addChild(puTongCheckBx)
    puTongCheckBx:setTag(500)
    puTongCheckBx:setPosition(self.m_txtFee:getPositionX() + 460, self.m_txtFee:getPositionY())
    puTongCheckBx:addEventListener(puTonglistener)
    puTongCheckBx:setSelected(true)
    self._puTongSelected = true
    self._puTongCheckBx = puTongCheckBx

    -- 百变玩法
    self.m_clipBaiBian = ClipText:createClipText(cc.size(200, 80),"百变玩法")
    self.m_clipBaiBian:setPosition(self.m_txtFee:getPositionX() + 520, self.m_txtFee:getPositionY())
    checkbx:getParent():addChild(self.m_clipBaiBian)
    self.m_clipBaiBian:setAnchorPoint(cc.p(0.0,0.5))
    self.m_clipBaiBian:setTextFontSize(26)
    self.m_clipBaiBian:setTextColor(cc.c4b(255,232,170,255))
    -- 克隆一个check用来做有没有王的配置
    local wangCheckBx = checkbx:clone()
    checkbx:getParent():addChild(wangCheckBx)
    wangCheckBx:setTag(500)
    wangCheckBx:setPosition(self.m_txtFee:getPositionX() + 660, self.m_txtFee:getPositionY())
    wangCheckBx:addEventListener(wanglistener)
    wangCheckBx:setSelected(false)
    self._wangSelected = false
    self._wangCheckBx = wangCheckBx


    -- 创建按钮
    btn = csbNode:getChildByName("btn_createroom")
    btn:setTag(BTN_CREATE)
    btn:addTouchEventListener(btncallback)
end

------
-- 继承/覆盖
------
-- 刷新界面
function PriRoomCreateLayer:onRefreshInfo()
    -- 房卡数更新
    self.m_txtCardNum:setString(GlobalUserItem.lRoomCard .. "")
end

function PriRoomCreateLayer:onLoginPriRoomFinish()
    local meUser = PriRoom:getInstance():getMeUserItem()
    if nil == meUser then
        return false
    end
    -- 发送创建桌子
    if ((meUser.cbUserStatus == yl.US_FREE or meUser.cbUserStatus == yl.US_NULL or meUser.cbUserStatus == yl.US_PLAYING)) then
        if PriRoom:getInstance().m_nLoginAction == PriRoom.L_ACTION.ACT_CREATEROOM then
            -- 创建登陆
            print("发送创建桌子")
            local buffer = CCmd_Data:create(188)
            buffer:setcmdinfo(self._cmd_pri_game.MDM_GR_PERSONAL_TABLE,self._cmd_pri_game.SUB_GR_CREATE_TABLE)
            buffer:pushscore(self.m_nSelectScore)
            buffer:pushdword(self.m_tabSelectConfig.dwDrawCountLimit)
            buffer:pushdword(self.m_tabSelectConfig.dwDrawTimeLimit)
            buffer:pushword(3)
            buffer:pushdword(0)
            buffer:pushstring("", yl.LEN_PASSWORD)

            --单个游戏规则(额外规则)
            buffer:pushbyte(1)
            buffer:pushbyte(self.m_tabPlayNumSelect[self.m_nPlayerNumSelectIdx -CBT_PLAYERNUM_BEGIN])
            print("人数", self.m_tabPlayNumSelect[self.m_nPlayerNumSelectIdx -CBT_PLAYERNUM_BEGIN])
            print("有没有选中有王 self._wangCheckBx:getSelected() = "..tostring(self._wangSelected))
            for i = 1, 100 - 2 do
                if i == 5 and self._wangSelected then
                    buffer:pushbyte(1)
                else
                    buffer:pushbyte(0)
                end
            end
            PriRoom:getInstance():getNetFrame():sendGameServerMsg(buffer)
            return true
        end        
    end
    return false
end

function PriRoomCreateLayer:getInviteShareMsg( roomDetailInfo )
    local shareTxt = "十三水约战 房间ID:" .. roomDetailInfo.szRoomID .. " 局数:" .. roomDetailInfo.dwPlayTurnCount
    shareTxt = shareTxt .. " 十三水游戏精彩刺激, 一起来玩吧! "
    local friendC = "十三水约战 房间ID:" .. roomDetailInfo.szRoomID .. " 局数:" .. roomDetailInfo.dwPlayTurnCount
    return {title = "十三水约战", content = shareTxt, friendContent = friendC}
end

function PriRoomCreateLayer:onExit()
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("room/Zhajinhua_room.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("room/Zhajinhua_room.png")
end

------
-- 继承/覆盖
------

function PriRoomCreateLayer:onButtonClickedEvent( tag, sender)
    if BTN_HELP == tag then
        --self._scene:popHelpLayer(yl.HTTP_URL .. "/Mobile/Introduce.aspx?kindid=6&typeid=1")
        self._scene:popHelpLayer2(6, 1)
    elseif BTN_CHARGE == tag then
        local feeType = "房卡"
        if PriRoom:getInstance().m_tabRoomOption.cbCardOrBean == 0 then
            feeType = "游戏豆"
        end
        if feeType == "游戏豆" then
            self._scene:onChangeShowMode(yl.SCENE_SHOP, Shop.CBT_BEAN)
        else
            self._scene:onChangeShowMode(yl.SCENE_SHOP, Shop.CBT_PROPERTY)
        end
    elseif BTN_MYROOM == tag then
        self._scene:onChangeShowMode(PriRoom.LAYTAG.LAYER_MYROOMRECORD)
    elseif BTN_CREATE == tag then 
        if self.m_bLow then
            local feeType = "房卡"
            if PriRoom:getInstance().m_tabRoomOption.cbCardOrBean == 0 then
                feeType = "游戏豆"
            end

            local QueryDialog = appdf.req("app.views.layer.other.QueryDialog")
            local query = QueryDialog:create("您的" .. feeType .. "数量不足，是否前往商城充值！", function(ok)
                if ok == true then
                    if feeType == "游戏豆" then
                        self._scene:onChangeShowMode(yl.SCENE_SHOP, Shop.CBT_BEAN)
                    else
                        self._scene:onChangeShowMode(yl.SCENE_SHOP, Shop.CBT_PROPERTY)
                    end                    
                end
                query = nil
            end):setCanTouchOutside(false)
                :addTo(self._scene)
            return
        end
        if nil == self.m_tabSelectConfig or table.nums(self.m_tabSelectConfig) == 0 then
            showToast(self, "未选择玩法配置!", 2)
            return
        end
        PriRoom:getInstance():showPopWait()
        PriRoom:getInstance():getNetFrame():onCreateRoom()
    end
end

function PriRoomCreateLayer:onPlayerNumSelectedEvent(tag, sender)
    if self.m_nPlayerNumSelectIdx == tag then
        sender:setSelected(true)
        return
    end
    self.m_nPlayerNumSelectIdx = tag
    for k,v in pairs(self.m_tabPlayerNumCheckBox) do
        if k ~= tag then
            v:setSelected(false)
        end
    end
    --self.m_tabPlayNumSelect = tag - CBT_PLAYERNUM_BEGIN
end

function PriRoomCreateLayer:onSelectedEvent(tag, sender)
    if self.m_nSelectIdx == tag then
        sender:setSelected(true)
        return
    end
    self.m_nSelectIdx = tag
    for k,v in pairs(self.m_tabCheckBox) do
        if k ~= tag then
            v:setSelected(false)
        end
    end
    self.m_tabSelectConfig = PriRoom:getInstance().m_tabFeeConfigList[tag - CBT_BEGIN]
    if nil == self.m_tabSelectConfig then
        return
    end

    self.m_bLow = false
    if GlobalUserItem.lRoomCard < self.m_tabSelectConfig.lFeeScore then
        self.m_bLow = true
    end
    local feeType = "房卡"
    if PriRoom:getInstance().m_tabRoomOption.cbCardOrBean == 0 then
        feeType = "游戏豆"
        self.m_bLow = false
        if GlobalUserItem.dUserBeans < self.m_tabSelectConfig.lFeeScore then
            self.m_bLow = true
        end
    end
    self.m_txtFee:setString(self.m_tabSelectConfig.lFeeScore .. feeType)
    self.m_spTips:setVisible(self.m_bLow)
    if self.m_bLow then
        local frame = nil
        if PriRoom:getInstance().m_tabRoomOption.cbCardOrBean == 0 then
            frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("priland_sp_card_tips_bean.png")   
        else
            frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("priland_sp_card_tips.png")   
        end
        if nil ~= frame then
            self.m_spTips:setSpriteFrame(frame)
        end
    end
end

function PriRoomCreateLayer:onSelectedPuTongEvent(tag, sender)

    if self._puTongSelected then
        -- self._puTongSelected = false
        -- self._wangSelected = true
        -- sender:setSelected(false)
        -- self._wangCheckBx:setSelected(true)
    else
        self._puTongSelected = true
        sender:setSelected(true)
        self._wangSelected = false
        self._wangCheckBx:setSelected(false)
    end
end

function PriRoomCreateLayer:onSelectedWangEvent(tag, sender)

    if self._wangSelected then
        -- self._wangSelected = false
        -- sender:setSelected(false)
    else
        self._wangSelected = true
        sender:setSelected(true)
        self._puTongSelected = false
        self._puTongCheckBx:setSelected(false)
    end
end



return PriRoomCreateLayer