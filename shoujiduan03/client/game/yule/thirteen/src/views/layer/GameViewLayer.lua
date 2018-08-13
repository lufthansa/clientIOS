local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)

require("client/src/plaza/models/yl")
local cmd = appdf.req(appdf.GAME_SRC.."yule.thirteen.src.models.CMD_Game")
local PopupInfoHead = appdf.req("client.src.external.PopupInfoHead")
local GameChatLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.game.GameChatLayer")
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.thirteen.src.models.GameLogic")
local GameEndLayer = appdf.req(appdf.GAME_SRC.."yule.thirteen.src.views.layer.GameEndLayer")
local SpecialCardLayer = appdf.req(appdf.GAME_SRC.."yule.thirteen.src.views.layer.SpecialCardLayer")

local m_bGameEnd = false

local m_bTach = true

GameViewLayer.BT_PROMPT 			= 2
GameViewLayer.BT_OPENCARD 			= 3
GameViewLayer.BT_START 				= 4
GameViewLayer.BT_CALLBANKER 		= 5
GameViewLayer.BT_CANCEL 			= 6
GameViewLayer.BT_CHIP 				= 7
GameViewLayer.BT_CHIP1 				= 8
GameViewLayer.BT_CHIP2 				= 9
GameViewLayer.BT_CHIP3 				= 10
GameViewLayer.BT_CHIP4 				= 11

GameViewLayer.BT_SWITCH 			= 12
GameViewLayer.BT_EXIT 				= 13
GameViewLayer.BT_SOUND 		        = 14
GameViewLayer.BT_SOUND_EFFECT 		= 15
GameViewLayer.BT_TwoPair			= 16
GameViewLayer.BT_Three  			= 17
GameViewLayer.BT_OnePair  			= 18
GameViewLayer.BT_Junko  			= 19
GameViewLayer.BT_Gourd  			= 20
GameViewLayer.BT_FourPlum  			= 21
GameViewLayer.BT_Flush01  			= 22
GameViewLayer.BT_Flush1  			= 23
GameViewLayer.BT_X1  			 	= 24
GameViewLayer.BT_X2  			 	= 25
GameViewLayer.BT_X3  			 	= 26
GameViewLayer.BT_OutCard			= 27
GameViewLayer.BT_Recover			= 28
GameViewLayer.BT_FiveWith  			= 29
GameViewLayer.BT_SHOWEND				= 30

GameViewLayer.BT_TAKEBACK 			= 31

GameViewLayer.BT_SHOW				= 32

GameViewLayer.FRAME 				= 1
GameViewLayer.NICKNAME 				= 2
GameViewLayer.SCORE 				= 3
GameViewLayer.FACE 					= 7

GameViewLayer.TIMENUM   			= 1
GameViewLayer.CHIPNUM 				= 1
GameViewLayer.SIGN_MINUS            = 35
GameViewLayer.BT_CHAT               =36
GameViewLayer.OFF_LINE              =37
GameViewLayer.PLACE_CARD            = 38

--牌间距
GameViewLayer.CARDSPACING 			= 80

GameViewLayer.VIEWID_CENTER 		= 5

GameViewLayer.RES_PATH 				= "game/yule/thirteen/res/"



 ---1  右上  2  左下  3 中   4  右下  5  左上
GameViewLayer.R_Up		 =1
GameViewLayer.L_Down 	=2
GameViewLayer.C_C 		=3
GameViewLayer.R_Down	 =4
GameViewLayer.L_Up		 =5
-------------播放 方向
GameViewLayer.play_L_Up		 =7  --需要翻转
GameViewLayer.play_L_Down 	 =5  --需要翻转

GameViewLayer.play_R_Down	 =5
GameViewLayer.play_R_Up		 =7
GameViewLayer.play_Up		 =1
GameViewLayer.play_Down		 =3
GameViewLayer.play_L	 	 =1
GameViewLayer.play_R	 	 =2

--拉牌音效
GameViewLayer.moveCard		= 1
GameViewLayer.notMoveCard	= 2

local pointPlayer = {cc.p(847, 625), cc.p(88, 410), cc.p(70, 165), cc.p(1238, 410),cc.p(460, 625)}
local pointCard = {cc.p(667, 617), cc.p(298, 402), cc.p(667, 170), cc.p(1028, 402),cc.p(200, 617)}
local pointClock = {cc.p(1017, 640), cc.p(88, 560), cc.p(157, 255), cc.p(1238, 560),cc.p(200, 640)}
local pointOpenCard = {cc.p(437, 625), cc.p(288, 285), cc.p(917, 115), cc.p(1038, 285),cc.p(200, 625)}
local pointTableScore = {cc.p(667, 505), cc.p(491, 410), cc.p(667, 342), cc.p(835, 410),cc.p(200, 505)}
local pointBankerFlag = {cc.p(948, 714), cc.p(159, 499), cc.p(228, 204), cc.p(1168, 495),cc.p(200, 200)}
local pointChat = {cc.p(767, 690), cc.p(160, 525), cc.p(230, 250), cc.p(1173, 525),cc.p(460, 690)}
local pointUserInfo = {cc.p(445, 240), cc.p(182, 305), cc.p(205, 170), cc.p(750, 305),cc.p(200, 240)}
local anchorPoint = {cc.p(1, 1), cc.p(0, 0.5), cc.p(0, 0), cc.p(1, 0.5),cc.p(1, 1)}
local pointArrangeCardFrame = cc.p(667,714)
--local rectClick3Row = {cc.rect(208,20,254,81),cc.rect(114,104,411,73),cc.rect(121,183,426,159)} -- 相对于左上角，用于可以点击的范围
local rectClick3Row = {cc.rect(180,10,320,100),cc.rect(90,100,600,90),cc.rect(100,170,600,210)} -- 相对于左上角，用于可以点击的范围
--rectClick3Row:setColor(cc.c4b(0, 0, 255, 255))
local pointAnimalCard = {cc.p(1070, 630), cc.p(320, 405), cc.p(700, 250), cc.p(1070, 405),cc.p(320, 630)} -- 动画墩牌显示的位置,中间的位置


local pointdaqiangAni_Dangkong = {cc.p(35, 90), cc.p(-10, -10), cc.p(15, 20)} -- 枪孔位置1


local AnimationRes = 
{
	{name = "banker", file = GameViewLayer.RES_PATH.."animation_banker/banker_", nCount = 11, fInterval = 0.2, nLoops = 1},
	{name = "faceFlash", file = GameViewLayer.RES_PATH.."animation_faceFlash/faceFlash_", nCount = 2, fInterval = 0.6, nLoops = 3},
	{name = "lose", file = GameViewLayer.RES_PATH.."animation_lose/lose_", nCount = 17, fInterval = 0.1, nLoops = 1},
	{name = "start", file = GameViewLayer.RES_PATH.."animation_start/start_", nCount = 11, fInterval = 0.15, nLoops = 1},
	{name = "victory", file = GameViewLayer.RES_PATH.."animation_victory/victory_", nCount = 17, fInterval = 0.13, nLoops = 1},
	{name = "yellow", file = GameViewLayer.RES_PATH.."animation_yellow/yellow_", nCount = 5, fInterval = 0.2, nLoops = 1},
	{name = "blue", file = GameViewLayer.RES_PATH.."animation_blue/blue_", nCount = 5, fInterval = 0.2, nLoops = 1}
}

function GameViewLayer:onInitData()
	self.bCardOut = {false, false, false, false, false,
    false, false, false, false, false,false, false,false}
	self.lUserMaxScore = {0, 0, 0, 0}
	self.chatDetails = {}
	self.bCanMoveCard = false
    --玩家手中的牌，是数据，不是绘画的牌
    self.handCard = {}
    --牌墩上的牌
    self.arrangeCard = {{},{},{}}
	self.m_cbCardType = -1
	self.m_cbIndex = 0;
	self.m_cbIndexHelp = 0
	self.m_cbIndexColor = 0
	--用于顺子的数据
	self.Distributing = {cbCardCount = {},cbDistributing = {}}
	self.cbShunZiBegin = 2
	self.cbShnuZiEnd = 1
	self.cbStraightCount = 0
	self.cbKingLeftCount = 0
	self.bSetShunZiBegin = false
	
	self.daqian_Node={{},{},{}}
	
	self._daqian_sp=nil
    ---牌坐标
    self._playCardPoin={{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}
    ---显示结算按钮
    self.showEndBut_bool =false
    ---是否结算播放完毕
    self.playAniEnd_bool =false


    self.TeshupaiNode = {}

   self.m_head ={}
	------至此

	-- 记录每个玩家这一大局的总输赢
	self.allWinLost = {}
	for i = 1,cmd.GAME_PLAYER do
		self.allWinLost[i] = 0
    end
end

function GameViewLayer:onExit()
	print("GameViewLayer onExit")
	cc.Director:getInstance():getTextureCache():removeTextureForKey(GameViewLayer.RES_PATH.."card.png")
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(GameViewLayer.RES_PATH.."game_oxnew_res.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey(GameViewLayer.RES_PATH.."game_oxnew_res.png")
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
	self.m_tabUserItem = {}
	self:deleteDaqian_plist()
end

local this
local MenuBg

function GameViewLayer:ctor(scene)
	this = self
	self._scene = scene
	self:onInitData()
	self:preloadUI()
    
	print("进入游戏 打印自己的id GameViewLayer:ctor GlobalUserItem.dwUserID = "..tostring(GlobalUserItem.dwUserID))

	--节点事件
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExit()
		end
	end
	self:registerScriptHandler(onNodeEvent)

	display.newSprite(GameViewLayer.RES_PATH.."background.png")
		:move(display.center)
		:setLocalZOrder(-100)
		:addTo(self)

	local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end

    --特殊牌按钮
	self.giveMeBigCard=ccui.Button:create("game/yule/thirteen/res/btn_Show.png")
				:setVisible(false)
				:setTag(GameViewLayer.BT_SHOW)
				:setPosition(yl.WIDTH-80,280)
				:setScale(0.8)
				:addTo(self)
	if GLobal_I_Can_Cheat then
		-- self.giveMeBigCard:setVisible(true)
	end
	self.giveMeBigCard:addTouchEventListener(function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedGiveMeBigCard()
        end
    end)


    --test
      self._data1 = {0x0A,0x0B,0x0C,0x0D,0x01,
         0x16,0x13,0x31,0x04,0x22,0x36,0x17,0x05};
      local tempdata = {};
      GameLogic:RandCardList(tempdata,52);
      for i = 1,13 do
      self._data1[i] = tempdata[i];
      end
      GameLogic:SortCardList(self._data1,#self._data1,GameLogic.enDescend);
    --特殊按钮
	 self.btTakeBack = ccui.Button:create(
                                        --"bt_takeBack_0.png", "bt_takeBack_1.png", "", ccui.TextureResType.plistType)
                                            GameViewLayer.RES_PATH.."bt_takeBack_0.png", GameViewLayer.RES_PATH.."bt_takeBack_1.png")
	 	:move(yl.WIDTH - 90, yl.HEIGHT - 25.5)
	 	:setTag(GameViewLayer.BT_TAKEBACK)
	 	:setTouchEnabled(true)
		:setVisible(fasle)
	 	:addTo(self)
	 self.btTakeBack:addTouchEventListener(btcallback)

	local bAble = GlobalUserItem.bVoiceAble--GlobalUserItem.bSoundAble or GlobalUserItem.bVoiceAble			--声音
	local bSoud = GlobalUserItem.bSoundAble
	if GlobalUserItem.bVoiceAble then
		AudioEngine.playMusic(GameViewLayer.RES_PATH.."sound/backMusic.mp3", true)
	end
	
	MenuBg = display.newSprite(GameViewLayer.RES_PATH.."bg.png")
	                :setVisible(false)
		            :setAnchorPoint(0.5,1)
		            :move(yl.WIDTH - 100, yl.HEIGHT - 60)
		            :setScaleY(0.8)
		            :addTo(self)
	self.btSound = ccui.CheckBox:create(GameViewLayer.RES_PATH.."bt_sound_0.png", 
                                        GameViewLayer.RES_PATH.."bt_sound_0.png",
                                        GameViewLayer.RES_PATH.."bt_sound_1.png",
                                        GameViewLayer.RES_PATH.."bt_sound_1.png",
                                        GameViewLayer.RES_PATH.."bt_sound_1.png")
                                      --"bt_sound_0.png", "bt_sound_1.png", 
                                       --"bt_soundOff_0.png", "bt_soundOff_1.png", 
                                       --"bt_soundOff_1.png", ccui.TextureResType.plistType)
		:move(90, 120)
		:setTag(GameViewLayer.BT_SOUND)
		:setTouchEnabled(true)
		:setSelected(not bAble)
		:addTo(MenuBg)
	self.btSound:addTouchEventListener(btcallback)
	
	self.btSoundEffect =ccui.CheckBox:create(GameViewLayer.RES_PATH.."bt_sound_effect.png", 
                                             GameViewLayer.RES_PATH.."bt_sound_effect.png",
                                             GameViewLayer.RES_PATH.."bt_sound_effect_off.png",
                                             GameViewLayer.RES_PATH.."bt_sound_effect_off.png",
                                             GameViewLayer.RES_PATH.."bt_sound_effect_off.png")
	    :move(93, 40)
		:setTag(GameViewLayer.BT_SOUND_EFFECT )
		:setTouchEnabled(true)
		:setSelected(not bSoud)
		:addTo(MenuBg)
	self.btSoundEffect:addTouchEventListener(btcallback)

	self.btChat = ccui.Button:create(GameViewLayer.RES_PATH.."bt_chat_0.png", GameViewLayer.RES_PATH.."bt_chat_0.png")
		:move(yl.WIDTH - 70, yl.HEIGHT - 630)
		:setTag(GameViewLayer.BT_CHAT)
		:setTouchEnabled(true)
		:addTo(self)
	self.btChat:addTouchEventListener(btcallback)

	self.btExit = ccui.Button:create(GameViewLayer.RES_PATH.."bt_exit_0.png", GameViewLayer.RES_PATH.."bt_exit_0.png")
		:move(90, 200)
		:setTag(GameViewLayer.BT_EXIT)
		:setTouchEnabled(true)
		:addTo(MenuBg)
	self.btExit:addTouchEventListener(btcallback)

	self.btSwitch = ccui.Button:create(--"bt_switch_0.png", "bt_switch_1.png", "", ccui.TextureResType.plistType)
                                        GameViewLayer.RES_PATH.."bt_switch_0.png", GameViewLayer.RES_PATH.."bt_switch_1.png")
		:move(yl.WIDTH - 90, yl.HEIGHT - 25.5)
		:setTag(GameViewLayer.BT_SWITCH)
		:setVisible(true)
		:addTo(self)
	self.btSwitch:addTouchEventListener(btcallback)
	
	--特殊牌按钮
	self.btnShow=ccui.Button:create("game/yule/thirteen/res/btn_Show.png")
				:setVisible(false)
				:setTag(GameViewLayer.BT_SHOW)
				:setPosition(yl.WIDTH-80,280)
				:setScale(0.8)
				:addTo(self)
	self.btnShow:addTouchEventListener(btcallback)

	--普通按钮
	 self.btPrompt = ccui.Button:create("bt_prompt_0.png", "bt_prompt_1.png", "", ccui.TextureResType.plistType)
	 	:move(yl.WIDTH - 163, 60)
	 	:setTag(GameViewLayer.BT_PROMPT)
		:setVisible(false)
	 	:addTo(self)
	 self.btPrompt:addTouchEventListener(btcallback)

	self.btOpenCard = ccui.Button:create("bt_showCard_0.png", "bt_showCard_1.png", "", ccui.TextureResType.plistType)
		:move(yl.WIDTH - 163, 112)
		:setTag(GameViewLayer.BT_OPENCARD)
		:setVisible(false)
		:addTo(self)
	self.btOpenCard:addTouchEventListener(btcallback)

	self.btStart = ccui.Button:create(GameViewLayer.RES_PATH.."bt_start_0.png", GameViewLayer.RES_PATH.."bt_start_1.png")
		:move(yl.WIDTH/2, yl.HEIGHT/2 - 99)
		:setVisible(false)
		:setTag(GameViewLayer.BT_START)
		:addTo(self)
	self.btStart:addTouchEventListener(btcallback)
	
	
	
	self.btShowEnd = ccui.Button:create(GameViewLayer.RES_PATH.."show.png")
		:move(239.13, 103.68)
		:setVisible(false)
		:setScaleX(0.78)
		:setTag(GameViewLayer.BT_SHOWEND)
		:addTo(self)
	self.btShowEnd:addTouchEventListener(btcallback)

	self.btCallBanker = ccui.Button:create("bt_callBanker_0.png", "bt_callBanker_1.png", "", ccui.TextureResType.plistType)
		:move(display.cx - 150, 300)
		:setTag(GameViewLayer.BT_CALLBANKER)
		:setVisible(false)
		:addTo(self)
	self.btCallBanker:addTouchEventListener(btcallback)

	self.btCancel = ccui.Button:create("bt_cancel_0.png", "bt_cancel_1.png", "", ccui.TextureResType.plistType)
		:move(display.cx + 150, 300)
		:setTag(GameViewLayer.BT_CANCEL)
		:setVisible(false)
		:addTo(self)
	self.btCancel:addTouchEventListener(btcallback)

    -- 语音按钮
    self:getParentNode():getParentNode():createVoiceBtn(cc.p(1270, 200), 0, top)	

	--四个下注的筹码按钮
	self.btChip = {}
	for i = 1, 4 do
		self.btChip[i] = ccui.Button:create("bt_chip_0.png", "bt_chip_1.png", "", ccui.TextureResType.plistType)
			:move(420 + 165*(i - 1), 253)
			:setTag(GameViewLayer.BT_CHIP + i)
			:setVisible(false)
			:addTo(self)
		self.btChip[i]:addTouchEventListener(btcallback)
		cc.LabelAtlas:_create("123456", GameViewLayer.RES_PATH.."num_chip.png", 17, 24, string.byte("0"))
			:move(self.btChip[i]:getContentSize().width/2, self.btChip[i]:getContentSize().height/2 + 5)
			:setAnchorPoint(cc.p(0.5, 0.5))
			:setTag(GameViewLayer.CHIPNUM)
			:addTo(self.btChip[i])
	end

	self.txt_CellScore = cc.Label:createWithTTF("底注：250","fonts/round_body.ttf",24)
		:move(1000, yl.HEIGHT - 20)
		:setVisible(false)
		:addTo(self)
	self.txt_TableID = cc.Label:createWithTTF("桌号：38","fonts/round_body.ttf",24)
		:move(333, yl.HEIGHT-20)
		:setVisible(false)
		:addTo(self)
		
	--牌提示背景
	self.spritePrompt = display.newSprite("#prompt.png")
		:move(display.cx, display.cy - 108)
		:setVisible(false)
		:addTo(self)
	--牌值
	self.labAtCardPrompt = {}
	for i = 1, 3 do
		self.labAtCardPrompt[i] = cc.LabelAtlas:_create("", GameViewLayer.RES_PATH.."num_prompt.png", 39, 38, string.byte("0"))
			:move(72 + 162*(i - 1), 25)
			:setAnchorPoint(cc.p(0.5, 0.5))
			:addTo(self.spritePrompt)
	end
	self.labCardType = cc.Label:createWithTTF("", "fonts/round_body.ttf", 34)
		:move(568, 25)
		:addTo(self.spritePrompt)

	--时钟
	self.spriteClock = display.newSprite("game/clockBk.png")
		:move(display.cx - 600, display.cy - 100)
		--:setVisible(false)
		:addTo(self)
	local labAtTime = cc.LabelAtlas:_create("", "game/clockNum.png", 17, 22, string.byte("0"))--("", GameViewLayer.RES_PATH.."num_time.png", 17, 22, string.byte("0"))
		:move(self.spriteClock:getContentSize().width/2, self.spriteClock:getContentSize().height/2)
		:setAnchorPoint(cc.p(0.5, 0.5))
		:setScale(0.7)
		:setTag(GameViewLayer.TIMENUM)
		:addTo(self.spriteClock)
	--用于发牌动作的那张牌
	self.animateCard = display.newSprite(GameViewLayer.RES_PATH.."card.png")
		:move(display.center)
		:setVisible(false)
		:setLocalZOrder(-1000)
		:addTo(self)
	local cardWidth = self.animateCard:getContentSize().width/13
	local cardHeight = self.animateCard:getContentSize().height/5
	self.animateCard:setTextureRect(cc.rect(cardWidth*2, cardHeight*4, cardWidth, cardHeight))

	--四个玩家
	self.nodePlayer = {}
	self.OffLine = {}
	self.PlaceCard = {}
	self.BgCard = {}
	for i = 1 ,cmd.GAME_PLAYER do
		--玩家结点
		self.nodePlayer[i] = cc.Node:create()
			:move(pointPlayer[i])
			:setVisible(false)
			:addTo(self)
		--人物框
		local spriteFrame = display.newSprite(GameViewLayer.RES_PATH.."oxnew_frame.png")
			:setTag(GameViewLayer.FRAME)
			:setVisible(false)
			:addTo(self.nodePlayer[i])
		--昵称
		--self.nicknameConfig = string.getConfig("fonts/round_body.ttf", 18)
		--cc.Label:createWithTTF("小白狼大白兔", "fonts/round_body.ttf", 18)
		local nickName = cc.Label:createWithSystemFont("nickName","Arial", 25) 
			:move(3, -35)
			:setScaleX(0.8)
			:setColor(cc.c3b(255,255,0))
			:setTag(GameViewLayer.NICKNAME)
			:addTo(self.nodePlayer[i])
		--金币
		--cc.LabelAtlas:_create("123456", GameViewLayer.RES_PATH.."num_room.png", 35, 37, string.byte("0"))
		local labelNum = cc.Label:createWithSystemFont("123456789", "Arial", 20) 
			:setColor(cc.c3b(255, 255, 255))  
			:move(3, -64)
			:setAnchorPoint(cc.p(0.5, 0.5))
			:setTag(GameViewLayer.SCORE)
			--:setScale(1.5)
			:addTo(self.nodePlayer[i])
			
		local labelSign = cc.Label:createWithSystemFont("-", "Arial", 20)
			:setColor(cc.c3b(255, 255, 255))
			:move(-15,-63)
			:setVisible(false)
			:setAnchorPoint(cc.p(1,0.5))
			:setTag(GameViewLayer.SIGN_MINUS)
            :addTo(self.nodePlayer[i])
			
		--[[local sign = display.newSprite(GameViewLayer.RES_PATH.."sign_minus.png")
		   :move(-15,-63)
            :setVisible(false)
			:setAnchorPoint(cc.p(1,0.5))
			:setTag(GameViewLayer.SIGN_MINUS)
			:setScale(1.5)
            :addTo(self.nodePlayer[i])]]
		--离线提示
		self.OffLine[i] = display.newSprite(GameViewLayer.RES_PATH.."off_line_sign.png")
		    :setTag(GameViewLayer.OFF_LINE)
			:setVisible(false)
			:setAnchorPoint(0.5,0)
			:move(pointPlayer[i])
			:addTo(self)
		--摆牌提示
		self.PlaceCard[i] = display.newSprite(GameViewLayer.RES_PATH.."place_card_sign.png")
		    :setVisible(false)
			:move(pointPlayer[i].x,pointPlayer[i].y)
			:setAnchorPoint(0.5,0.2)
			:setTag(GameViewLayer.PLACE_CARD)
			:addTo(self)
		self.BgCard[i] = display.newSprite(GameViewLayer.RES_PATH.."bg_card.png")
			:setVisible(false)
			:setAnchorPoint(0,0.5)
			:move(pointCard[i])
			:addTo(self)
		if i == 4 then
			self.BgCard[i]:setFlipX(true)
           self.BgCard[i]:setAnchorPoint(1,0.5)
		   self.BgCard[i]:move(pointCard[i].x+100,pointCard[i].y)
		elseif i == 1 then
			self.BgCard[i]:setAnchorPoint(1,0.5)
		   self.BgCard[i]:move(pointCard[i].x+580,pointCard[i].y)
		else
			self.BgCard[i]:setAnchorPoint(0,0.5)
			self.BgCard[i]:move(pointCard[i].x-100,pointCard[i].y)
		end
			
		
	end

	--自己方牌框
	-- self.cardFrame = {}
	-- for i = 1, 13 do
	-- 	self.cardFrame[i] = ccui.CheckBox:create("cardFrame_0.png",
	-- 											"cardFrame_1.png",
	-- 											"cardFrame_0.png",
	-- 											"cardFrame_0.png",
	-- 											"cardFrame_0.png", ccui.TextureResType.plistType)
	-- 		:move(335 + 166*(i - 1), 110)
	-- 		:setTouchEnabled(false)
	-- 		:setVisible(true)
	-- 		:addTo(self)
	-- end

	--牌节点
	self.nodeCard = {}
	--牌的类型
	self.cardType = {}
	--桌面金币
	self.tableScore = {}
	--准备标志
	self.flag_ready = {}
	--摊牌标志
	self.flag_openCard = {}
	for i = 1, cmd.GAME_PLAYER do
		--牌
		self.nodeCard[i] = cc.Node:create()
			:move(pointCard[i])
			:setAnchorPoint(cc.p(0.5, 0.5))
			:addTo(self,60)
		for j = 1, 13 do
			local card = display.newSprite(GameViewLayer.RES_PATH.."card.png")
				:setTag(j)
				:setVisible(true)
				:setTextureRect(cc.rect(cardWidth*2, cardHeight*4, cardWidth, cardHeight))
                :setAnchorPoint(cc.p(1, 0.6))
				:addTo(self.nodeCard[i])
		end

		--牌型
		self.cardType[i] = display.newSprite("#ox_10.png")
			:move(pointOpenCard[i])
			:setVisible(true)
			:addTo(self)
		--桌面金币
		self.tableScore[i] = ccui.Button:create(GameViewLayer.RES_PATH.."score_bg.png")
			:move(pointTableScore[i])
			:setEnabled(false)
			:setBright(true)
			:setVisible(false)
			:setTitleText("0")
			:setTitleColor(cc.c3b(0, 0, 0))
			:setTitleFontSize(22)
			:addTo(self)
		--准备
		self.flag_ready[i] = display.newSprite(GameViewLayer.RES_PATH.."areadly_ready.png")
			:move(pointCard[i])
			:setVisible(false)
			:addTo(self)
		if i == 5 then
			self.flag_ready[i]:move(pointCard[i].x+100 ,pointCard[i].y)
		elseif i == 1 then
			self.flag_ready[i]:move(pointCard[i].x+330 ,pointCard[i].y)
		end
		--摊牌
		self.flag_openCard[i] = display.newSprite("#sprite_openCard.png")
			:move(pointOpenCard[i])
			:setVisible(false)
			:addTo(self)
		
	end

	self.nodeLeaveCard = cc.Node:create():addTo(self)

	self.spriteBankerFlag = display.newSprite()
		:setVisible(false)
		:setLocalZOrder(2)
		:addTo(self)

	--聊天框
    self._chatLayer = GameChatLayer:create(self._scene._gameFrame)
    self._chatLayer:addTo(self,60)
	--聊天泡泡
	self.chatBubble = {}
	for i = 1 , cmd.GAME_PLAYER do
		if (i == 2) or (i == 3) or ( i==5 )then
			self.chatBubble[i] = display.newSprite(GameViewLayer.RES_PATH.."game_chat_lbg.png"	,{scale9 = true ,capInsets=cc.rect(0, 0, 180, 110)})
				:setAnchorPoint(cc.p(0,0.5))
				:move(pointChat[i])
				:setVisible(false)
				:addTo(self, 2)
		else
			self.chatBubble[i] = display.newSprite(GameViewLayer.RES_PATH.."game_chat_rbg.png",{scale9 = true ,capInsets=cc.rect(0, 0, 180, 110)})
				:setAnchorPoint(cc.p(1,0.5))
				:move(pointChat[i])
				:setVisible(false)
				:addTo(self, 2)
		end
		
		
	end

    self:createCardButton(btcallback)
    self:createOpenCardAniamal() --初始化 桌面 牌的数据
    self:createArrangeCardFrame()
    self:createOtherButton(btcallback)
    self:createWinLostScore()
    self.userName = {}
    for i = 1 , cmd.GAME_PLAYER do
        self.userName[i] = ""
    end
	-- 用户信息
    self.m_tabUserItem = {}
	self:createSpecialCard()
	
	--播放声音用的
	self.m_sound = cc.Label:createWithTTF("","fonts/round_body.ttf",24)
	self.m_sound:setVisible(false)
	self.m_sound:addTo(self)
	
	--播放特殊牌声音
	self.m_specialSound = {}
	for i = 1,cmd.GAME_PLAYER do
		self.m_specialSound[i] = cc.Label:createWithTTF("","fonts/round_body.ttf",24)
		self.m_specialSound[i]:setVisible(false)
		self.m_specialSound[i]:addTo(self)
	end
	
	--特殊牌界面
	self.m_specialCardLayer = nil
	
	--拉牌功能
	self.m_bRunClick = false
	--当前牌move到的索引
	self.m_curMoveClick = 0
	--点击事件
	self:setTouchEnabled(true)
	self:registerScriptTouchHandler(function(eventType, x, y)
		return self:onEventTouchCallback(eventType, x, y)
	end)
      ---导入打枪数据
	self:ImportDaqian_plist()

    --创建特殊牌显示
    self:newSpriteTeshupai()
end

    
function GameViewLayer:onResetView()
	self.nodeLeaveCard:removeAllChildren()
	self.spriteBankerFlag:setVisible(false)
	self.spritePrompt:setVisible(false)
	--重排列牌
	local cardWidth = self.animateCard:getContentSize().width
	local cardHeight = self.animateCard:getContentSize().height
	for i = 1, cmd.GAME_PLAYER do
		local fSpacing		--牌间距
		local fX 			--起点
		local fWidth 		--宽度
		--以上三个数据是保证牌节点的坐标位置位于其下五张牌的正中心
		--[[if i == cmd.MY_VIEWID then
			fSpacing = 166
			fX = fSpacing/2
			fWidth = fSpacing*5
		else
			fSpacing = GameViewLayer.CARDSPACING
			fX = cardWidth/2
			fWidth = cardWidth + fSpacing*4
		end
        --]]
        fSpacing = GameViewLayer.CARDSPACING
		fX = 0
		fWidth = fSpacing * (13 - 1) + cardWidth
		self.nodeCard[i]:setContentSize(cc.size(fWidth, cardHeight))
        self.nodeCard[i]:move(pointCard[i])
		for j = 1, 13 do
			local card = self.nodeCard[i]:getChildByTag(j)
				:move(fX + (fSpacing+20)*(j - 1), cardHeight/2 + 20)
				:setTextureRect(cc.rect(cardWidth*2, cardHeight*4, cardWidth, cardHeight))
				:setVisible(false)
				:setLocalZOrder(35)
                self._playCardPoin[j] = cc.p(fX + (fSpacing+20)*(j - 1), cardHeight/2 + 20)
		end
		self.tableScore[i]:setVisible(false)
		self.cardType[i]:setVisible(false)
	end
	self.bCardOut = {false, false, false, false, false,
    false, false, false, false, false,false, false,false}
	self.handCard = {}
	for i = 1,cmd.GAME_PLAYER do
		local wViewChairId = self._scene:SwitchViewChairID(i - 1)
		self:setAniCardFontVisible(wViewChairId,false)
		self:setAniCardBackVisible(wViewChairId,false)
	end
	for i=1,cmd.GAME_PLAYER do
		for j = 1,3 do --3墩
			self.nodeScore[i][j]:setVisible(false)
		end
	end
	for i=1,cmd.GAME_PLAYER do
		for j = 1,3 do --3墩
			self.nodeScore[i][j]:setVisible(false)
			self.nodeNumJn[i][j]:setVisible(false)
			self.nodeNumPlus[i][j]:setVisible(false)
		end
	end
	--清理墩牌
	for index = 1, 3 do
		self.arrangeCard[index] = {}
	end
	for index = 1, cmd.GAME_PLAYER do
		self.m_specialCard[index]:setVisible(false)
	end
    self:ShowAllTeshupai(false)
end

--更新用户显示
function GameViewLayer:OnUpdateUser(viewId, userItem)
	if not viewId or viewId == yl.INVALID_CHAIR then
		print("OnUpdateUser viewId is nil")
		return
	end

    
    
	local head = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.FACE)
	if not userItem then
		self.nodePlayer[viewId]:setVisible(false)
		self.flag_ready[viewId]:setVisible(false)
		
		if head then
			head:setVisible(false)
		end
	else
		self.nodePlayer[viewId]:setVisible(true)
		self.m_tabUserItem[viewId] = userItem
        self.userName[userItem.wChairID + 1] = userItem.szNickName
		self:setNickname(viewId, userItem.szNickName)
		self:setScore(viewId, userItem.lScore)

		-- change by, 2018.7.8, 玩家头像下面显示这一局的总输赢
	    local tableId = self._scene._gameFrame:GetTableID()
	    --self._gameView:setTableID(tableId)
	    for i = 1, cmd.GAME_PLAYER do
	        local userItem1 = self._scene._gameFrame:getTableUserItem(tableId, i-1)
	        if nil ~= userItem1 then
	            local wViewChairId = self._scene:SwitchViewChairID(i-1)
	            self:setScore(wViewChairId, self.allWinLost[i])
	        end
	    end


		self.flag_ready[viewId]:setVisible(yl.US_READY == userItem.cbUserStatus)
		self.OffLine[viewId]:setVisible(userItem.cbUserStatus == yl.US_OFFLINE)
		
		
		
		
		if userItem.cbUserStatus == yl.US_OFFLINE then
		    self.PlaceCard[viewId]:setVisible(false)
		    self.BgCard[viewId]:setVisible(false)
		elseif userItem.cbUserStatus == yl.US_PLAYING then
			for i = 1 ,#self.aniCardBack[viewId] do
			    if self.aniCardBack[viewId][i]:isVisible() or self.btStart:isVisible() then --and  self.playAniEnd_bool == true then
			       self.PlaceCard[viewId]:setVisible(false)
		           self.BgCard[viewId]:setVisible(false)
				else	
					if  viewId ~= 3 then
				        self.PlaceCard[viewId]:setVisible(true)
		                self.BgCard[viewId]:setVisible(true)
					end
				end
			end
		end
     
		if not head then

			head = PopupInfoHead:createNormal(userItem, 85)
			head:setPosition(3, 24)
			head:enableHeadFrame(false)
			head:enableInfoPop(true, pointUserInfo[viewId], anchorPoint[viewId])
			head:setTag(GameViewLayer.FACE)
			self.nodePlayer[viewId]:addChild(head)
			self.m_head[viewId] = head;

			--遮盖层，美化头像
			display.newSprite(GameViewLayer.RES_PATH.."oxnew_frameTop.png")
				--:move(1, 1)
				:addTo(head)
		else
			head:updateHead(userItem, self._scene)
		end
		-- head:setVisible(true)
	end
end

--****************************      计时器        *****************************--
function GameViewLayer:OnUpdataClockView(viewId, time)
	if not viewId or viewId == yl.INVALID_CHAIR or not time then
		self.spriteClock:getChildByTag(GameViewLayer.TIMENUM):setString("")
		self.spriteClock:setVisible(false)
	else
		self.spriteClock:getChildByTag(GameViewLayer.TIMENUM):setString(time)
	end
end

function GameViewLayer:setClockPosition(viewId)
	if viewId then
		self.spriteClock:move(pointClock[viewId])
	else
		self.spriteClock:move(display.cx, display.cy + 50)
	end
    self.spriteClock:setVisible(true)
end

--**************************      点击事件        ****************************--
--点击事件
local num = 0
function GameViewLayer:onEventTouchCallback(eventType, x, y)
	if m_bGameEnd == false then
		
		if eventType == "began" then 
	num = 1
	if self.bBtnInOutside then
		self:onButtonSwitchAnimate(true)
		return false
	end
	if self.bCanMoveCard ~= true then
		return false
	end
	elseif eventType == "moved" then
	if self.bCanMoveCard ~= true then
		return false
	end
	local upIndex = self:getMoveIndex(x,y)
	if upIndex == 0 then
		return false
	end
	if self.m_curMoveClick ~= upIndex then
		self.m_curMoveClick = upIndex
		print("upIndex = "..upIndex)
		local card = self.nodeCard[cmd.MY_VIEWID]:getChildByTag(upIndex)
		local x2, y2 = card:getPosition()
		if false == self.bCardOut[upIndex] then
			card:move(x2, y2 + 30)
			num=num + 1
			m_bTach = false
			if num == 2 then
				self:playCardSound(GameViewLayer.moveCard)
				num = 0
			end

		elseif true == self.bCardOut[upIndex] then
			card:move(x2, y2 - 30)
		end
		self.bCardOut[upIndex] = not self.bCardOut[upIndex]
		self.m_bRunClick = true
		return false
	end
elseif eventType == "ended" then
	
	--bMoveUp = true
	--用于触发手牌
	if self.bCanMoveCard ~= true then
		return false
	end
	self.m_curMoveClick = 0
	if self.m_bRunClick then
		self.m_bRunClick = false
		return false
	end
	--底下部分自己的手牌
	local upIndex = self:getMoveIndex(x,y)
	if upIndex > 0 then
		local card = self.nodeCard[cmd.MY_VIEWID]:getChildByTag(upIndex)
		local x2, y2 = card:getPosition()
		if false == self.bCardOut[upIndex] then
			card:move(x2, y2 + 30)
			self:playCardSound(GameViewLayer.moveCard)
			m_bTach = false
		elseif true == self.bCardOut[upIndex] then
			card:move(x2, y2 - 30)
			self:playCardSound(GameViewLayer.moveCard)
		end
		self.bCardOut[upIndex] = not self.bCardOut[upIndex]
		return true
		
	end

	
	
	--三墩牌的区域点击响应
	--print("x = "..x..",y = "..y)
	for i = 1, 3 do
		local rect = self:copyTab(rectClick3Row[i])
		local Left = pointArrangeCardFrame.x - self.spriteArrange:getContentSize().width/2
		local top = pointArrangeCardFrame.y
		rect.x = Left + rectClick3Row[i].x
		rect.y = top - rectClick3Row[i].y - rectClick3Row[i].height
		--appdf.printTable(rect)
		if cc.rectContainsPoint(rect, cc.p(x, y)) then
			--print("===="..i)
			self:clickArrangeRow(i)
			self.m_cbCardType = 0
			self:setBtnVisible()

			self:playCardSound(GameViewLayer.moveCard)

			return true
		end
	end
end

return true
		
	end
	

end
local m_nNum=0
--按钮点击事件
function GameViewLayer:onButtonClickedEvent(tag,ref)

	if tag == GameViewLayer.BT_EXIT then


      --for i =1,cmd.GAME_PLAYER  do
        --  if self.m_tabUserItem[i] ~=nil and self.m_tabUserItem[i].cbUserStatus ==yl.US_PLAYING then
        --    showToast(self, "游戏中。。请在结算完操作离开请求", 2, cc.c4b(250,0,0,255),100)
       --     return
       --   end
     --  end
       
		self._scene:onQueryExitGame()
	elseif tag == GameViewLayer.BT_OutCard then
		--判断是否倒水
		if self.arrangeCard[1] == nil or #self.arrangeCard[1] ~= 3 then
			return
		end
		if self.arrangeCard[2] == nil or #self.arrangeCard[2] ~= 5 then
			return
		end
		if self.arrangeCard[3] == nil or #self.arrangeCard[3] ~= 5 then
			return
		end
		--[[local card = {0x13,0x23,0x33}
		local card1 = {0x14,0x16,0x18,0x24,0x12}
		local ret = GameLogic:CompareCard(card,card1,3,5,false)--]]
		local ret = GameLogic:CompareCard(self.arrangeCard[1],self.arrangeCard[2],3,5,false)
		local ret1 = GameLogic:CompareCard(self.arrangeCard[2],self.arrangeCard[3],5,5,true)
		if -1 ~= ret and -1 ~= ret1 then
			local cbCardData = {}
			for i = 1,3 do
				for j = 1,#self.arrangeCard[i] do
					table.insert(cbCardData,self.arrangeCard[i][j])
				end
			end
			self:onBtOutCard(cbCardData,0)
			self._scene:KillGameClock()
		else
			local sprite = display.newSprite(GameViewLayer.RES_PATH.."cardArrange/DragonCard.png")
				sprite:move(cc.p(display.cx,display.cy - 150))
				sprite:setScale(1.5)
				sprite:addTo(self)
				sprite:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(
                function(ref)
					ref:removeFromParent()
                end
                )))
		end
	elseif tag == GameViewLayer.BT_PROMPT then
		--self:promptOx()
	elseif tag == GameViewLayer.BT_START then
		self.btStart:setVisible(false)
		
		self._scene:onStartGame()

		--local cescard={0x31, 0x1D, 0x0D, 0x2B, 0x1A, 0x28, 0x26, 0x25, 0x27, 0x15, 0x14, 0x23, 0x24}
        --self:gameStartStart(cescard,13)
		
		
        --local cescard={0x07,0x0B,0x0B,0x0C,0x0C, 0x16,0x19,0x19,0x1C,0x1C, 0x22, 0x23, 0x24}

        --self:gameStartStart(cescard,0)

		--self:ShowAllTeshupai(false)
       -- self:showTeshupai(1,GameLogic.CT_D_JXH_FLUSH)
		--self:Qainleida_plist()
		--self:setAniCardBackVisible(1,true)
		--self:setAniCardBackVisible(2,true)
		--self:setAniCardBackVisible(3,true)
		--self:setAniCardBackVisible(4,true)
		--self:setAniCardBackVisible(5,true)
		--测试打枪
		--self:addDaqian_Animation(self,1,5)
		--self:hideAllQiangKong(false)
		--self:ShowPlayQiangKong(5)		
		
		
		
        --[[display.newSprite()
			:move(display.center)
			:addTo(self)
			:runAction(self:getAnimate("mygod", true))--]]
        --[[local layerEnd = GameEndLayer:create(self)
            layerEnd:addTo(self)--]]
        -- 测试用随机牌
        -- local tempdata = {};
        -- GameLogic:RandCardList(tempdata,52);
        -- local card = {}
        -- for i = 1,4 do
        --     card[i] = {}
        -- end
        -- for j = 1,4 do
        --     for i = 1,13 do
        -- 	    table.insert(card[j],tempdata[j*13+i])
        --     end
        -- end
        -- --for i = 1,13 do
        -- --	self._data1[i] = tempdata[i];
        -- --end
        -- self._scene.cbPlayStatus[1] = 1
        -- self._scene.cbPlayStatus[3] = 1
        do
            --self:gameEnd(card)
            return
        end
        local ONE_ROW = 3 -- 第一墩牌
        local TWO_ROW = 8 -- 第二墩牌
        local time = 0.6  --翻一张牌要时间
        local timeSum = 1 --总时间
        cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)--cocos2d::DisplayLinkDirector::Projection::_2D
        for i = 1,cmd.GAME_PLAYER do
            for j = 1,13 do
                if j <= ONE_ROW then
                    timeSum = (i - 1) * time
                elseif j <= TWO_ROW then
                    timeSum = cmd.GAME_PLAYER*time + time*(i - 1)
                else
                    timeSum = cmd.GAME_PLAYER*time * 2 + time*(i - 1)
                end
                self.aniCardBack[i][j]:runAction(cc.Sequence:create(cc.DelayTime:create(timeSum),cc.OrbitCamera:create(time/2,1,0,0,90,0,0),cc.Hide:create(),
                cc.CallFunc:create(
                function()--开始角度设置为0，旋转90度
                    self.aniCardFont[i][j]:runAction(cc.Sequence:create(cc.Show:create(),
                    cc.OrbitCamera:create(time/2,1,0,270,90,0,0)))--开始角度是270，旋转90度
                end
                )))
            end
        end
	elseif tag == GameViewLayer.BT_CALLBANKER then
		self.btCallBanker:setVisible(false)
		self.btCancel:setVisible(false)
		--self._scene:onBanker(1)
	elseif tag == GameViewLayer.BT_CANCEL then
		self.btCallBanker:setVisible(false)
		self.btCancel:setVisible(false)
		self._scene:onBanker(0)
	elseif tag - GameViewLayer.BT_CHIP == 1 or
			tag - GameViewLayer.BT_CHIP == 2 or
			tag - GameViewLayer.BT_CHIP == 3 or
			tag - GameViewLayer.BT_CHIP == 4 then
		for i = 1, 4 do
			self.btChip[i]:setVisible(false)
		end
		local index = tag - GameViewLayer.BT_CHIP
		self._scene:onAddScore(self.lUserMaxScore[index])
	elseif tag == GameViewLayer.BT_CHAT then
		if m_bTach then 
			self._chatLayer:showGameChat(true)
		end
	elseif tag == GameViewLayer.BT_SWITCH then
		--self:onButtonSwitchAnimate()
		self.btTakeBack:setVisible(true)
		self.btSwitch:setVisible(false)
		MenuBg:setVisible(true)
	elseif tag == GameViewLayer.BT_SHOW then
		self.m_specialCardLayer:setVisible(true)
		self.btnShow:setVisible(false)
	elseif tag == GameViewLayer.BT_SOUND then
		local effect = not GlobalUserItem.bVoiceAble--(GlobalUserItem.bSoundAble or GlobalUserItem.bVoiceAble)
		--GlobalUserItem.setSoundAble(effect)
		GlobalUserItem.setVoiceAble(effect)
		if effect == true then
			AudioEngine.playMusic(GameViewLayer.RES_PATH.."sound/backMusic.mp3", true)
		end
		print("BT_SOUND", effect)
	elseif tag == GameViewLayer.BT_SOUND_EFFECT then
		local effect = not GlobalUserItem.bSoundAble
		GlobalUserItem.setSoundAble(effect)
		if effect == false then
			--GlobalUserItem.nSound = cc.UserDefault:getInstance():getIntegerForKey("soundvalue",0)
			AudioEngine.setEffectsVolume(0)
			AudioEngine.stopAllEffects()--暂停所有音效
		else 
			AudioEngine.resumeAllEffects()
		end
	elseif tag == GameViewLayer.BT_TAKEBACK then
	 	--self:onButtonSwitchAnimate(true)
		self.btTakeBack:setVisible(false)
		self.btSwitch:setVisible(true)
		MenuBg:setVisible(false)
    elseif tag == GameViewLayer.BT_OnePair then
		local cbOutIndex = {}
		GameLogic:SortCardList(self.handCard, #self.handCard , GameLogic.enDescend)
		local cbSingleCount = self:OneDouble(self.handCard , #self.handCard,cbOutIndex);
		self:resetCardOut()
		self:setMyCardArrayUp(cbOutIndex)
		self:playCardSound(GameViewLayer.moveCard)
    elseif tag == GameViewLayer.BT_TwoPair then
		local cbOutIndex = {}
		GameLogic:SortCardList(self.handCard, #self.handCard , GameLogic.enDescend)
		local cbSingleCount = self:TwoDouble(self.handCard , #self.handCard,cbOutIndex);
		self:resetCardOut()
		self:setMyCardArrayUp(cbOutIndex)
		self:playCardSound(GameViewLayer.moveCard)
	elseif tag == GameViewLayer.BT_Three then
		local cbOutIndex = {}
		GameLogic:SortCardList(self.handCard, #self.handCard , GameLogic.enDescend)
		local cbSingleCount = self:ThreeSame(self.handCard , #self.handCard,cbOutIndex);
		self:resetCardOut()
		self:setMyCardArrayUp(cbOutIndex)
		self:playCardSound(GameViewLayer.moveCard)
	elseif tag == GameViewLayer.BT_FourPlum then
		local cbOutIndex = {}
		GameLogic:SortCardList(self.handCard, #self.handCard , GameLogic.enDescend)
		local cbSingleCount = self:TieZi(self.handCard , #self.handCard,cbOutIndex);
		self:resetCardOut()
		self:setMyCardArrayUp(cbOutIndex)
		self:playCardSound(GameViewLayer.moveCard)
	elseif tag == GameViewLayer.BT_FiveWith then
		local cbOutIndex = {}
		GameLogic:SortCardList(self.handCard, #self.handCard , GameLogic.enDescend)
		local cbSingleCount = self:WuTong(self.handCard , #self.handCard,cbOutIndex);
		self:resetCardOut()
		self:setMyCardArrayUp(cbOutIndex[self.m_cbIndex])
		self:playCardSound(GameViewLayer.moveCard)
	elseif tag == GameViewLayer.BT_Gourd then
		local cbOutIndex = {}
		GameLogic:SortCardList(self.handCard, #self.handCard , GameLogic.enDescend)
		local cbSingleCount = self:Hulu(self.handCard , #self.handCard,cbOutIndex);
		self:resetCardOut()
		self:setMyCardArrayUp(cbOutIndex)
		self:playCardSound(GameViewLayer.moveCard)	
	elseif tag == GameViewLayer.BT_Junko then
		local cbOutCardData = {}
		local count = self:ShunZi(self.handCard , #self.handCard,cbOutCardData)
		if count > 0 then
			local cbOutIndex = {}
			local cbReadyhave = {}
			--将牌的值转换为牌索引
			for i = 1,#cbOutCardData do
				for j = 1,#self.handCard do
					if cbOutCardData[i] == self.handCard[j] then
						local bFind = false
						for k = 1, #cbReadyhave do
							if (cbOutCardData[i] == cbReadyhave[k]) then
								bFind = true
								break
							end
						end
						if not bFind then
							table.insert(cbOutIndex,j)
							table.insert(cbReadyhave,cbOutCardData[i])
						end
					end
				end
			end
			if #cbOutCardData > 0 then
				self:resetCardOut()
				self:setMyCardArrayUp(cbOutIndex)
				self:playCardSound(GameViewLayer.moveCard)	
			end
		end
	elseif tag == GameViewLayer.BT_Flush1 then
		local cbOutIndex = {}
		GameLogic:SortCardList(self.handCard, #self.handCard , GameLogic.enDescend)
		local cbSingleCount = self:TongHua(self.handCard , #self.handCard,cbOutIndex);
		self:resetCardOut()
		self:setMyCardArrayUp(cbOutIndex)	
		self:playCardSound(GameViewLayer.moveCard)
	elseif tag == GameViewLayer.BT_Flush01 then
		local cbOutCardData = {}
		local count = self:TongHuaShun(self.handCard , #self.handCard,cbOutCardData)
		if count > 0 then
			local cbOutIndex = {}
			local cbReadyhave = {}
			--将牌的值转换为牌索引
			for i = 1,#cbOutCardData do
				for j = 1,#self.handCard do
					if cbOutCardData[i] == self.handCard[j] then
						local bFind = false
						for k = 1, #cbReadyhave do
							if (cbOutCardData[i] == cbReadyhave[k]) then
								bFind = true
								break
							end
						end
						if not bFind then
							table.insert(cbOutIndex,j)
							table.insert(cbReadyhave,cbOutCardData[i])
						end
					end
				end
			end
			if #cbOutCardData > 0 then
				self:resetCardOut()
				self:setMyCardArrayUp(cbOutIndex)	
				self:playCardSound(GameViewLayer.moveCard)
			end
		end
    elseif tag == GameViewLayer.BT_X1 then
        self:clickXButton(1)
		self:setBtnVisible()
    elseif tag == GameViewLayer.BT_X2 then
        self:clickXButton(2)
		self:setBtnVisible()
    elseif tag == GameViewLayer.BT_X3 then
        self:clickXButton(3)
		self:setBtnVisible()
    elseif tag == GameViewLayer.BT_Recover then
        self:clickRecoverButton()
		self:setBtnVisible()
	elseif tag == GameViewLayer.BT_SHOWEND then
		if self.m_layerEnd ~= nil then
			self.m_layerEnd:setVisible(true)
			self.btShowEnd:setVisible(false)
		end
    else
		showToast(self,"功能尚未开放！",1)
	end
end

function GameViewLayer:onButtonSwitchAnimate(bTakeBack)
	local fInterval = 0.2
	local spacing = 60
	local originX, originY = self.btSwitch:getPosition()
	for i = GameViewLayer.BT_EXIT, GameViewLayer.BT_SOUND_EFFECT do
		local nCount = i - GameViewLayer.BT_EXIT + 1
		local button = self:getChildByTag(i)
		button:setTouchEnabled(false)
		--算时间和距离
		local time
		local pointTarget
		--if i <= GameViewLayer.BT_SOUND_EFFECT then
		time = fInterval*(nCount - 1)
		pointTarget = cc.p(0, spacing*(nCount))
		--else
			--time = fInterval*(nCount-2)
			--pointTarget = cc.p(spacing*(nCount-2), 0)
		--end

		local fRotate = 360
		if not bTakeBack then 			--滚出
			fRotate = -fRotate
			pointTarget = cc.p(-pointTarget.x, -pointTarget.y)
		end

		button:runAction(cc.Sequence:create(
			cc.Spawn:create(cc.MoveBy:create(time, pointTarget), cc.RotateBy:create(time, fRotate)),
			cc.CallFunc:create(function()
				if not bTakeBack then
					button:setTouchEnabled(true)
					self.bBtnInOutside =  true
				else
					self.bBtnInOutside =  false
				end
			end)))
	end
	if not bTakeBack then
		self.btSwitch:setTouchEnabled(false)
		self.btSwitch:setVisible(false)
		self.btTakeBack:setVisible(true)
	else
		self.btSwitch:setTouchEnabled(true)
		self.btSwitch:setVisible(true)
		self.btTakeBack:setVisible(false)
	end
end

function GameViewLayer:gameCallBanker(callBankerViewId, bFirstTimes)
	if callBankerViewId == cmd.MY_VIEWID then
		if self._scene.cbDynamicJoin == 0 then
        	self.btCallBanker:setVisible(true)
        	self.btCancel:setVisible(true)
        end
    end

    if bFirstTimes then
		display.newSprite()
			:move(display.center)
			:addTo(self)
			:runAction(self:getAnimate("start", true))
    end
end
--开始游戏初始化所有数据
function GameViewLayer:gameStartStart(cbCardData,specialType)
	self:getParentNode():getParentNode():setButVisible(false)
--游戏开始，头像不能点击
	for i=1,5 do
		if self.m_head[i]  then
			self.m_head[i]:setshowHead(false)
		end
	
	end
	

	m_bGameEnd = false

	m_bTach = false
	if specialType ~= nil and specialType >= 13 and specialType <= 25 then
		if self.m_specialCardLayer == nil then
			self.m_specialCardLayer = SpecialCardLayer:create(specialType - 13 + 1,self)
			--self.m_specialCardLayer:setLocalZOrder(60)
			self.m_specialCardLayer:setScale(0.8)
			self.m_specialCardLayer:addTo(self,62)
				--if self.m_specialCardLayer:isVisible()==false then
			--self.btnShow:setVisible(true)
		--end
		else
			self.m_specialCardLayer:setType(specialType - 13 + 1)
			self.m_specialCardLayer:setScale(0.8)
			self.m_specialCardLayer:setVisible(true)
		end
	end
	
	
	
	
	GameLogic:SortCardList(cbCardData,#cbCardData,GameLogic.enDescend);
    self:setEnableCardButton(false)
    self:setVisbileCardButton(true)
    self:resetCardOut()
    self.handCard = self:copyTab(cbCardData)


    -- change by Owen, 2018.5.1, 前两张牌改为大王和小王
    local bHasJoker = false
    for k,v in pairs(self.handCard) do
	    if v == 65 or v == 66 then
	    	bHasJoker = true
	    end
	end
	-- if not bHasJoker then
		-- self.handCard[1] = 6
	 --    self.handCard[2] = 1
	 --    self.handCard[3] = 23
	 --    self.handCard[4] = 33
	 --    self.handCard[5] = 4
	 --    self.handCard[6] = 5

	 --    self.handCard[7] = 7
	 --    self.handCard[8] = 28
	 --    self.handCard[9] = 9
	 --    self.handCard[10] = 10
	 --    self.handCard[11] = 11
	 --    self.handCard[12] = 12
	 --    self.handCard[13] = 13

	-- end


    self:hideAllMyCard(cmd.MY_VIEWID)
    self:showMyCard(self.handCard)
    self:setCardButtonEnable()
    --显示牌墩背景
    self.spriteArrange:setVisible(true)
    self.btX1:setVisible(true)
    self.btX2:setVisible(true)
    self.btX3:setVisible(true)
    --显示2个按钮
	self.btOutCard:setVisible(false)
	self.btRecover:setVisible(false)

    
	--隐藏枪孔
	self:hideAllQiangKong(false)
    ---清除特殊牌显示
    self:ShowAllTeshupai(false)

end


function GameViewLayer:gameStart()
    self.bCanMoveCard = true
    local index = self._scene:GetMeChairID() + 1
	--特殊牌型的值在13-15之间
	
    for i = 1,cmd.GAME_PLAYER do
        local wViewChairId = self._scene:SwitchViewChairID(i - 1)
	    if self.nodePlayer[wViewChairId]:isVisible() then
		    if 3 == wViewChairId then
			self.PlaceCard[wViewChairId]:setVisible(false)
			self.BgCard[wViewChairId]:setVisible(false)
			else
			self.PlaceCard[wViewChairId]:setVisible(true)
			self.BgCard[wViewChairId]:setVisible(true)
		    end
		end
	end
			
	assert(self._scene.cbSpecialCard[index] == 0 or 
	(self._scene.cbSpecialCard[index] >= 13 and self._scene.cbSpecialCard[index] <= 25) )
	local specialType = nil
	if self._scene.cbSpecialCard[index] ~= 0 then
		specialType = self._scene.cbSpecialCard[index]
	end
    self:gameStartStart(self._scene.cbCardData[index],specialType)
	AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/PleaseOutCard_Nan.mp3")
end

function GameViewLayer:gameAddScore(viewId, score)
	self.tableScore[viewId]:setTitleText(score)
	self.tableScore[viewId]:setVisible(true)
    local labelScore = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SCORE)
    local lScore = tonumber(labelScore:getString())
	local mScore = (lScore - score)
	if mScore >= 0 then
		mScore = mScore
		self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SIGN_MINUS):setVisible(false)	
    else 
		mScore = 0-mScore
		self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SIGN_MINUS):setVisible(true)	
	end
    self:setScore(viewId, mScore)
	
end

function GameViewLayer:gameSendCard()
	--开始发牌
	--self:runSendCardAnimate(firstViewId, totalCount)
    self.bCanMoveCard = true
end

--开牌
function GameViewLayer:gameOpenCard(wViewChairId,cbCardData,cbSpecial)
	--设置13墩牌背可见
    --assert(#cbCardData == cmd.HAND_CARD_COUNT and wViewChairId >= 1 and wViewChairId <= cmd.GAME_PLAYER)
	self:setAniCardBackVisible(wViewChairId,true)
	
	if cbCardData == nil then
		return
	end
    for i = 1,#cbCardData do
			local data = cbCardData[i]
	        local value = GameLogic:GetCardValue(data)
	        local color = GameLogic:GetCardColor(data)
			local card = self.aniCardFont[wViewChairId][i]
			local rectCard = card:getTextureRect()
			rectCard.x = rectCard.width*(value - 1)
			rectCard.y = rectCard.height*color
			card:setTextureRect(rectCard)
	end
	
end

---比牌
function GameViewLayer:gameEnd(cbArrangeCard,everyDunAmount,final,gunUser,bSpecialCardType,wAllKillChairId,cb_Dpai)

    --开始播放 初始化
    self.playAniEnd_bool =false
    self:showEndBut(false)
	self:getParentNode():getParentNode():setButVisible(true)
	m_bTach = true
	--出牌后，头像能点击
	for i=1,5 do
		if self.m_head[i] then
			self.m_head[i]:setshowHead(true)
		end
	end
    --强制比牌时不显示手牌和牌敦等
-----------------------------------------------------------------------------------------
	self.spriteArrange:setVisible(false)
	self.btX1:setVisible(false)
	self.btX2:setVisible(false)
	self.btX3:setVisible(false)
	self:hideAllMyCard(cmd.MY_VIEWID)
	self:setNodeRowCard(false)
	m_bGameEnd = true
-----------------------------------------------------------------------------------------
	self.btOutCard:setVisible(false)
	self.btRecover:setVisible(false)
    self:setVisbileCardButton(false)
    self.finalResult = self:copyTab(final)
	local bHadCard = false
	for i = 1,cmd.GAME_PLAYER do
		if cbArrangeCard[i][1] ~= nil and cbArrangeCard[i][1] > 0  then
			bHadCard = true

			-- change by, 2018.7.8, 更新显示每个玩家下面的总输赢
			self.allWinLost[i] = self.allWinLost[i] + self.finalResult[i]

		    local tableId = self._scene._gameFrame:GetTableID()
	        local userItem = self._scene._gameFrame:getTableUserItem(tableId, i-1)
	        if nil ~= userItem then
	            local wViewChairId = self._scene:SwitchViewChairID(i-1)
	            self:setScore(wViewChairId, self.allWinLost[i])
	        end
		end
	end
	if bHadCard then
		AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/StartCompearCard_Nan.mp3")
		local actionsound = cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function(ref)
							self:showCompareAnimation(cbArrangeCard,everyDunAmount,final,gunUser,bSpecialCardType,wAllKillChairId,cb_Dpai)
						end))
		self.m_sound:runAction(actionsound)
	else
		self:showGameEndLayer()
	end
	
    if self.m_layerEnd == nil then
		self.m_layerEnd = GameEndLayer:create(self)
		self.m_layerEnd:setBtnVisible(false)
		self.m_layerEnd:addTo(self,65)
        self.m_layerEnd:setVisible(false)
    end
    
	
end
function GameViewLayer:gameScenePlaying()
	if self._scene.cbDynamicJoin == 0 then
	    self.btOpenCard:setVisible(true)
	    --self.btPrompt:setVisible(true)
	    self.spritePrompt:setVisible(true)
	    for i = 1, 5 do
	    	--self.cardFrame[i]:setVisible(true)
	    end
	end
end

function GameViewLayer:setCellScore(cellscore)
	if not cellscore then
		self.txt_CellScore:setString("底注：")
	else
		self.txt_CellScore:setString("底注："..cellscore)
	end
end
---牌显示
function GameViewLayer:setCardTextureRect(viewId, tag, cardValue, cardColor,spW)
	if viewId < 1 or viewId > cmd.GAME_PLAYER or tag < 1 or tag > 13 then
		print("card texture rect error!")
		return
	end
	
	local card = self.nodeCard[viewId]:getChildByTag(tag)
	local rectCard = card:getTextureRect()
	rectCard.x = rectCard.width*(cardValue - 1)
	rectCard.y = rectCard.height*cardColor
	card:setTextureRect(rectCard)
    local cardpoint = self._playCardPoin[tag];
    card:move(cardpoint.x + spW,cardpoint.y)
end

function GameViewLayer:setNickname(viewId, strName)
	local name = string.EllipsisByConfig(strName, 156, self.nicknameConfig)
	local labelNickname = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.NICKNAME)
	labelNickname:setString(name)

	-- local labelWidth = labelNickname:getContentSize().width
	-- if labelWidth > 136 then
	-- 	labelNickname:setScaleX(136/labelWidth)
	-- elseif labelNickname:getScaleX() ~= 1 then
	-- 	labelNickname:setScaleX(1)
	-- end
end

function GameViewLayer:setScore(viewId, lScore)
	local labelScore = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SCORE)
	if lScore >= 0 then
		local minus = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SIGN_MINUS)
		minus:setVisible(false)
		labelScore:setString(lScore)
		
	else
		local minus = self.nodePlayer[viewId]:getChildByTag(GameViewLayer.SIGN_MINUS)
		minus:setVisible(true)
		labelScore:setString(-lScore)
		local x,y = minus:getPosition()
		local x1,y1 = labelScore:getPosition()
		local width = labelScore:getContentSize().width
		if width > 96 then
			width = 96
		end
		local posX = x1 - width/2
		minus:setPosition(posX,y)
	end
	

	local labelWidth = labelScore:getContentSize().width
	if labelWidth > 96 then
		labelScore:setScaleX(96/labelWidth)
	elseif labelScore:getScaleX() ~= 1 then
		labelScore:setScaleX(1)
	end
end

function GameViewLayer:setTableID(id)
	if not id or id == yl.INVALID_TABLE then
		self.txt_TableID:setString("桌号：")
	else
		self.txt_TableID:setString("桌号："..(id + 1))
	end
end

function GameViewLayer:setUserScore(wViewChairId, lScore)
	self.nodePlayer[wViewChairId]:getChildByTag(GameViewLayer.SCORE):setString(lScore)
	                             
end

function GameViewLayer:setReadyVisible(wViewChairId, isVisible)
	self.flag_ready[wViewChairId]:setVisible(isVisible)
end

function GameViewLayer:setOpenCardVisible(wViewChairId, isVisible)
	self.flag_openCard[wViewChairId]:setVisible(isVisible)
end

function GameViewLayer:setTurnMaxScore(lTurnMaxScore)
	for i = 1, 4 do
		self.lUserMaxScore[i] = math.max(lTurnMaxScore, 1)
		self.btChip[i]:getChildByTag(GameViewLayer.CHIPNUM):setString(self.lUserMaxScore[i])
		lTurnMaxScore = math.floor(lTurnMaxScore/2)
	end
end

function GameViewLayer:setBankerUser(wViewChairId)
	self.spriteBankerFlag:move(pointBankerFlag[wViewChairId])
	self.spriteBankerFlag:setVisible(true)
	self.spriteBankerFlag:runAction(self:getAnimate("banker"))
	--闪烁动画
	display.newSprite()
		:move(pointPlayer[wViewChairId].x + 2, pointPlayer[wViewChairId].y - 12)
		:addTo(self)
		:runAction(self:getAnimate("faceFlash", true))
end

function GameViewLayer:setUserTableScore(wViewChairId, lScore)
	if lScore == 0 then
		return
	end

	self.tableScore[wViewChairId]:setTitleText(lScore)
	self.tableScore[wViewChairId]:setVisible(true)
end


--发牌动作
function GameViewLayer:runSendCardAnimate(wViewChairId, nCount)
	print(nCount)
	local nPlayerNum = self._scene:getPlayNum()
	if nCount == nPlayerNum*5 then
		self.animateCard:setVisible(true)
    	AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/SEND_CARD.wav")
	elseif nCount < 1 then
		self.animateCard:setVisible(false)

		if self._scene.cbDynamicJoin == 0 then
			self.btOpenCard:setVisible(true)
			--self.btPrompt:setVisible(true)
			self.spritePrompt:setVisible(true)
		end
		self._scene:sendCardFinish()
		self.bCanMoveCard = true
		return
	end

	local pointMove = {cc.p(0, 250), cc.p(-310, 0), cc.p(0, -180), cc.p(310, 0)}
	self.animateCard:runAction(cc.Sequence:create(
			cc.MoveBy:create(0.15, pointMove[wViewChairId]),
			cc.CallFunc:create(function(ref)
				ref:move(display.center)
				--显示一张牌
				local nTag = math.floor(5 - nCount/nPlayerNum) + 1
				if wViewChairId == 1 then 		--1号位发牌时牌居中对齐
					local size = self.nodeCard[1]:getContentSize()
					if nTag == 1 then
						size.width = size.width - 120
					else
						size.width = size.width + GameViewLayer.CARDSPACING
					end
					--self.nodeCard[1]:setContentSize(size)
				elseif wViewChairId == 3 then
					--self.cardFrame[nTag]:setVisible(true)
				elseif wViewChairId == 4 then 		--4号位发牌时牌居右对齐
					nTag = math.ceil(nCount/nPlayerNum)
				end
				local card = self.nodeCard[wViewChairId]:getChildByTag(nTag)
				if not card then return end
				card:setVisible(true)
				--开始下一个人的发牌
				wViewChairId = wViewChairId + 1
				if wViewChairId > 4 then
					wViewChairId = 1
				end
				while not self._scene:isPlayerPlaying(wViewChairId) do
					wViewChairId = wViewChairId + 1
					if wViewChairId > 4 then
						wViewChairId = 1
					end
				end
				self:runSendCardAnimate(wViewChairId, nCount - 1)
			end)))
end

--检查牌类型
function GameViewLayer:updateCardPrompt()
	--弹出牌显示，统计和
	
end

function GameViewLayer:preloadUI()
	display.loadSpriteFrames(GameViewLayer.RES_PATH.."game_oxnew_res.plist",
							GameViewLayer.RES_PATH.."game_oxnew_res.png")

	for i = 1, #AnimationRes do
		local animation = cc.Animation:create()
		animation:setDelayPerUnit(AnimationRes[i].fInterval)
		animation:setLoops(AnimationRes[i].nLoops)

		for j = 1, AnimationRes[i].nCount do
			local strFile = AnimationRes[i].file..string.format("%d.png", j)
			animation:addSpriteFrameWithFile(strFile)
		end

		cc.AnimationCache:getInstance():addAnimation(animation, AnimationRes[i].name)
	end

    -- 加载动画纹理
    display.loadSpriteFrames(GameViewLayer.RES_PATH.."Animation/FireGun/Plist3.plist",GameViewLayer.RES_PATH.."Animation/FireGun/Plist3.png")
    local animation = cc.Animation:create()
    animation:setDelayPerUnit(0.2)
    animation:setLoops(10)
    for j = 1, 10 do
		local strName = string.format("%d.png", j - 1)
        local sprite = cc.SpriteFrameCache:getInstance():getSpriteFrame(strName)
    	animation:addSpriteFrame(sprite)
	end
    cc.AnimationCache:getInstance():addAnimation(animation, "mygod")
end

function GameViewLayer:getAnimate(name, bEndRemove)
	local animation = cc.AnimationCache:getInstance():getAnimation(name)
	local animate = cc.Animate:create(animation)

	if bEndRemove then
		animate = cc.Sequence:create(animate, cc.CallFunc:create(function(ref)
			ref:removeFromParent()
		end))
	end

	return animate
end

function GameViewLayer:promptOx()
	--首先将牌复位
	for i = 1, 13 do
		if self.bCardOut[i] == true then
			local card = self.nodeCard[cmd.MY_VIEWID]:getChildByTag(i)
			local x, y = card:getPosition()
			y = y - 30
			card:move(x, y)
			self.bCardOut[i] = false
		end
	end
	--将牛牌弹出
	local index = self._scene:GetMeChairID() + 1
	local cbDataTemp = self:copyTab(self._scene.cbCardData[index])
	if self._scene:getOxCard(cbDataTemp) then
		for i = 1, 5 do
			for j = 1, 3 do
				if self._scene.cbCardData[index][i] == cbDataTemp[j] then
					local card = self.nodeCard[cmd.MY_VIEWID]:getChildByTag(i)
					local x, y = card:getPosition()
					y = y + 30
					card:move(x, y)
					self.bCardOut[i] = true
				end
			end
		end
	end
	self:updateCardPrompt()
end

function GameViewLayer:getParentNode()
    return self._scene
end



--用户聊天
function GameViewLayer:userChat(wViewChairId, chatString)
	if chatString and #chatString > 0 then
		self._chatLayer:showGameChat(false)
		--取消上次
		if self.chatDetails[wViewChairId] then
			self.chatDetails[wViewChairId]:stopAllActions()
			self.chatDetails[wViewChairId]:removeFromParent()
			self.chatDetails[wViewChairId] = nil
		end

		--创建label
		local limWidth = 24*12
		local labCountLength = cc.Label:createWithSystemFont(chatString,"Arial", 24)  
		if labCountLength:getContentSize().width > limWidth then
			self.chatDetails[wViewChairId] = cc.Label:createWithSystemFont(chatString,"Arial", 24, cc.size(limWidth, 0))
		else
			self.chatDetails[wViewChairId] = cc.Label:createWithSystemFont(chatString,"Arial", 24)
		end
		if (wViewChairId ==2) or (wViewChairId == 3) or (wViewChairId == 5)then
			self.chatDetails[wViewChairId]:move(pointChat[wViewChairId].x + 24 , pointChat[wViewChairId].y + 9)
				:setAnchorPoint( cc.p(0, 0.5) )
		else
			self.chatDetails[wViewChairId]:move(pointChat[wViewChairId].x - 24 , pointChat[wViewChairId].y + 9)
				:setAnchorPoint(cc.p(1, 0.5))
		end
		self.chatDetails[wViewChairId]:addTo(self, 2)

	    --改变气泡大小
		self.chatBubble[wViewChairId]:setContentSize(self.chatDetails[wViewChairId]:getContentSize().width+48, self.chatDetails[wViewChairId]:getContentSize().height + 40)
			:setVisible(true)
		--动作
	    self.chatDetails[wViewChairId]:runAction(cc.Sequence:create(
	    	cc.DelayTime:create(3),
	    	cc.CallFunc:create(function(ref)
	    		self.chatDetails[wViewChairId]:removeFromParent()
				self.chatDetails[wViewChairId] = nil
				self.chatBubble[wViewChairId]:setVisible(false)
	    	end)))
    end
end

--用户表情
function GameViewLayer:userExpression(wViewChairId, wItemIndex)
	if wItemIndex and wItemIndex >= 0 then
		self._chatLayer:showGameChat(false)
		--取消上次
		if self.chatDetails[wViewChairId] then
			self.chatDetails[wViewChairId]:stopAllActions()
			self.chatDetails[wViewChairId]:removeFromParent()
			self.chatDetails[wViewChairId] = nil
		end

	    local strName = string.format("e(%d).png", wItemIndex)
	    self.chatDetails[wViewChairId] = cc.Sprite:createWithSpriteFrameName(strName)
	        :addTo(self, 2)
	    if wViewChairId ==2 or wViewChairId == 3 then
			self.chatDetails[wViewChairId]:move(pointChat[wViewChairId].x + 45 , pointChat[wViewChairId].y + 5)
		else
			self.chatDetails[wViewChairId]:move(pointChat[wViewChairId].x - 45 , pointChat[wViewChairId].y + 5)
		end

	    --改变气泡大小
		self.chatBubble[wViewChairId]:setContentSize(90,80)
			:setVisible(true)

	    self.chatDetails[wViewChairId]:runAction(cc.Sequence:create(
	    	cc.DelayTime:create(3),
	    	cc.CallFunc:create(function(ref)
	    		self.chatDetails[wViewChairId]:removeFromParent()
				self.chatDetails[wViewChairId] = nil
				self.chatBubble[wViewChairId]:setVisible(false)
	    	end)))
    end
end

--拷贝表
function GameViewLayer:copyTab(st)
    local tab = {}
    for k, v in pairs(st) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = self:copyTab(v)
        end
    end
    return tab
 end

--取模
function GameViewLayer:mod(a,b)
    return a - math.floor(a/b)*b
end

--运行输赢动画
function GameViewLayer:runWinLoseAnimate(viewid, score)
	local ptWinLoseAnimate = {cc.p(727, 500), cc.p(238, 300), cc.p(307, 50), cc.p(1088, 300)}
	local strAnimate
	local strSymbol
	local strNum
	if score > 0 then
		strAnimate = "yellow"
		strSymbol = GameViewLayer.RES_PATH.."symbol_add.png"
		strNum = GameViewLayer.RES_PATH.."num_add.png"
	else
		score = -score
		strAnimate = "blue"
		strSymbol = GameViewLayer.RES_PATH.."symbol_reduce.png"
		strNum = GameViewLayer.RES_PATH.."num_reduce.png"
	end

	--加减
	local node = cc.Node:create()
		:move(ptWinLoseAnimate[viewid])
		:setAnchorPoint(cc.p(0.5, 0.5))
		:setOpacity(0)
		:setCascadeOpacityEnabled(true)
		:addTo(self, 4)

	local spriteSymbol = display.newSprite(strSymbol)		--符号
		:addTo(node)
	local sizeSymbol = spriteSymbol:getContentSize()
	spriteSymbol:move(sizeSymbol.width/2, sizeSymbol.height/2)

	local labAtNum = cc.LabelAtlas:_create(score, strNum, 40, 35, string.byte("0"))		--数字
		:setAnchorPoint(cc.p(0.5, 0.5))
		:addTo(node)
	local sizeNum = labAtNum:getContentSize()
	labAtNum:move(sizeSymbol.width + sizeNum.width/2, sizeNum.height/2)

	node:setContentSize(sizeSymbol.width + sizeNum.width, sizeSymbol.height)

	--底部动画
	local nTime = 1.5
	local spriteAnimate = display.newSprite()
		:move(ptWinLoseAnimate[viewid])
		:addTo(self, 3)
	spriteAnimate:runAction(cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveBy:create(nTime, cc.p(0, 200)),
			self:getAnimate(strAnimate)
		),
		cc.DelayTime:create(2),
		cc.CallFunc:create(function(ref)
			ref:removeFromParent()
		end)
	))

	node:runAction(cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveBy:create(nTime, cc.p(0, 200)), 
			cc.FadeIn:create(nTime)
		),
		cc.DelayTime:create(2),
		cc.CallFunc:create(function(ref)
			ref:removeFromParent()
		end)
	))
end
--创建牌型按钮
function GameViewLayer:createCardButton(btcallback)
    local width = 0
    --牌型按钮
    self.btOnePair = ccui.Button:create(GameViewLayer.RES_PATH.."cardtypebtn/OnePair1.png",
    GameViewLayer.RES_PATH.."cardtypebtn/OnePair1.png", GameViewLayer.RES_PATH.."cardtypebtn/OnePair2.png")
	self.btOnePair:setTag(GameViewLayer.BT_OnePair)
	self.btOnePair:setVisible(false)
    self.btOnePair:setEnabled(false)
	self.btOnePair:setScale(1.2)
	self.btOnePair:addTo(self)
	self.btOnePair:addTouchEventListener(btcallback)

    width = self.btOnePair:getContentSize().width*1.1
    local Center = yl.WIDTH / 2
    local OFFX = 10
    local AllWitdh = (width + OFFX) * 9
    local Left = Center - AllWitdh/2 + width/2
    self.btOnePair:move(Left,35)

    self.btTwoPair = ccui.Button:create(GameViewLayer.RES_PATH.."cardtypebtn/TwoPair1.png",
    GameViewLayer.RES_PATH.."cardtypebtn/TwoPair1.png", GameViewLayer.RES_PATH.."cardtypebtn/TwoPair2.png")
    self.btTwoPair:move(Left + (OFFX + width),35)
	self.btTwoPair:setTag(GameViewLayer.BT_TwoPair)
	self.btTwoPair:setVisible(false)
    self.btTwoPair:setEnabled(false)
	self.btTwoPair:setScale(1.2)
	self.btTwoPair:addTo(self)
	self.btTwoPair:addTouchEventListener(btcallback)

    self.btThree = ccui.Button:create(GameViewLayer.RES_PATH.."cardtypebtn/Three1.png",
    GameViewLayer.RES_PATH.."cardtypebtn/Three1.png", GameViewLayer.RES_PATH.."cardtypebtn/Three2.png")
    self.btThree:move(Left + 2*(OFFX + width),35)
	self.btThree:setTag(GameViewLayer.BT_Three)
	self.btThree:setVisible(false)
    self.btThree:setEnabled(false)
	self.btThree:setScale(1.2)
	self.btThree:addTo(self)
	self.btThree:addTouchEventListener(btcallback)

    --顺子
    self.btJunko = ccui.Button:create(GameViewLayer.RES_PATH.."cardtypebtn/Junko1.png",
    GameViewLayer.RES_PATH.."cardtypebtn/Junko1.png", GameViewLayer.RES_PATH.."cardtypebtn/Junko2.png")
	self.btJunko:move(Left + 3*(OFFX + width),35)
	self.btJunko:setTag(GameViewLayer.BT_Junko)
	self.btJunko:setVisible(false)
    self.btJunko:setEnabled(false)
	self.btJunko:setScale(1.2)
	self.btJunko:addTo(self)
	self.btJunko:addTouchEventListener(btcallback)

    --同花
    self.btFlush1 = ccui.Button:create(GameViewLayer.RES_PATH.."cardtypebtn/Flush1.png",
    GameViewLayer.RES_PATH.."cardtypebtn/Flush1.png", GameViewLayer.RES_PATH.."cardtypebtn/Flush2.png")
	self.btFlush1:move(Left + 4*(OFFX + width),35)
	self.btFlush1:setTag(GameViewLayer.BT_Flush1)
	self.btFlush1:setVisible(false)
    self.btFlush1:setEnabled(false)
	self.btFlush1:setScale(1.2)
	self.btFlush1:addTo(self)
	self.btFlush1:addTouchEventListener(btcallback)

    --葫芦
    self.btGourd = ccui.Button:create(GameViewLayer.RES_PATH.."cardtypebtn/Gourd1.png",
    GameViewLayer.RES_PATH.."cardtypebtn/Gourd1.png", GameViewLayer.RES_PATH.."cardtypebtn/Gourd2.png")
	self.btGourd:move(Left + 5*(OFFX + width),35)
	self.btGourd:setTag(GameViewLayer.BT_Gourd)
	self.btGourd:setVisible(false)
    self.btGourd:setEnabled(false)
	self.btGourd:setScale(1.2)
	self.btGourd:addTo(self)
	self.btGourd:addTouchEventListener(btcallback)

    --铁支
    self.btFourPlum = ccui.Button:create(GameViewLayer.RES_PATH.."cardtypebtn/FourPlum1.png",
    GameViewLayer.RES_PATH.."cardtypebtn/FourPlum1.png", GameViewLayer.RES_PATH.."cardtypebtn/FourPlum2.png")
	self.btFourPlum:move(Left + 6*(OFFX + width),35)
	self.btFourPlum:setTag(GameViewLayer.BT_FourPlum)
	self.btFourPlum:setVisible(false)
    self.btFourPlum:setEnabled(false)
	self.btFourPlum:setScale(1.2)
	self.btFourPlum:addTo(self)
	self.btFourPlum:addTouchEventListener(btcallback)

    --同花顺
    self.btFlush01 = ccui.Button:create(GameViewLayer.RES_PATH.."cardtypebtn/Flush01.png",
    GameViewLayer.RES_PATH.."cardtypebtn/Flush01.png", GameViewLayer.RES_PATH.."cardtypebtn/Flush02.png")
	self.btFlush01:move(Left + 7*(OFFX + width),35)
	self.btFlush01:setTag(GameViewLayer.BT_Flush01)
	self.btFlush01:setVisible(false)
    self.btFlush01:setEnabled(false)
	self.btFlush01:setScale(1.2)
	self.btFlush01:addTo(self)
	self.btFlush01:addTouchEventListener(btcallback)

    --五同
    self.btFiveWith = ccui.Button:create(GameViewLayer.RES_PATH.."cardtypebtn/FiveWith1.png",
    GameViewLayer.RES_PATH.."cardtypebtn/FiveWith1.png", GameViewLayer.RES_PATH.."cardtypebtn/FiveWith2.png")
	self.btFiveWith:move(Left + 8*(OFFX + width),35)
	self.btFiveWith:setTag(GameViewLayer.BT_FiveWith)
	self.btFiveWith:setVisible(false)
    self.btFiveWith:setEnabled(false)
	self.btFiveWith:setScale(1.2)
	self.btFiveWith:addTo(self)
	self.btFiveWith:addTouchEventListener(btcallback)

    

end
---显示按钮
function GameViewLayer:setCardButtonEnable()
    if #self.handCard== 0 then
        self:setEnableCardButton(false)
        return
    end
    local AnalyseData = {bOneCount = 0,bTwoCount = 0,bThreeCount = 0,
          bFourCount = 0,bFiveCount=0,bWangCount=0,bOneFirst={},
          bTwoFirst={},bThreeFirst={},bFourFirst={},bFiveFirst={},
          bWangData={},bSameColorData={},bSameColorCount={},
          bAllOne={},bAllOneCount={},bSameColor=0};
    GameLogic:AnalyseCardWithoutKing(self.handCard,#self.handCard,AnalyseData)
    --一对
    if (AnalyseData.bTwoCount > 0)then
         self.btOnePair:setEnabled(true)
    end
    --2对
    if(AnalyseData.bTwoCount > 1) then
        self.btTwoPair:setEnabled(true)
    end
    --两张王+单张构成三条不考虑
	if (AnalyseData.bThreeCount > 0 or
		(AnalyseData.bTwoCount > 0 and AnalyseData.bWangCount >= 1)) then
	    self.btThree:setEnabled(true)
    end
    --葫芦
    if ((AnalyseData.bThreeCount > 0 and AnalyseData.bTwoCount > 0) or
		(AnalyseData.bTwoCount >= 2 and AnalyseData.bWangCount >= 1 or
		AnalyseData.bThreeCount > 1)) then
        self.btGourd:setEnabled(true)
	end
    --铁支
    if (AnalyseData.bFourCount > 0 or
		(AnalyseData.bThreeCount > 0 and AnalyseData.bWangCount > 0 ) or
		AnalyseData.bTwoCount > 0 and AnalyseData.bWangCount == 2 ) then
        self.btFourPlum:setEnabled(true)
	end

	--五同
    if ((AnalyseData.bFourCount > 0 and AnalyseData.bWangCount >=1) or AnalyseData.bFiveCount > 0 or
		(AnalyseData.bThreeCount > 0 and AnalyseData.bWangCount == 2)) then
        self.btFiveWith:setEnabled(true)
	end

    --同花
    for i=1,4 do
        if (AnalyseData.bSameColorCount[i] + AnalyseData.bWangCount >= 5) then
            self.btFlush1:setEnabled(true)
			break;
		end
    end

    --同花顺
    self:EnableTonghuaShunButton(self.handCard)

    --顺子
    self:EnableShunZilButton(self.handCard);
end
--顺子
function GameViewLayer:EnableShunZilButton(cbInCardData)
	 --定义变量
	local bKCount = 0;
	local evCardList = {};	--0位存王牌,1位保留,其他位按逻辑值存放，15个链表
    for i = 1, 15 do
        evCardList[i] = {};
    end
	local evColorList = {};	--方梅红黑， 4个链表
	-- change by Owen, 2018.5.1, 有王的时候要存5个
    for i = 1, 5 do
        evColorList[i] = {};
    end 
	local bCardArray = {}; --size = 13
	local bNeedCCount = 5;
	local bMaxCardData = {};--5
	local bMaxCardCount = 0;
	--local cbInCardData = {};--size = 13
	local bCardCount = #cbInCardData;
	--memcpy(bCardArray, cbInCardData, sizeof(BYTE)*bCardCount);
    for i = 1,bCardCount do
        table.insert(bCardArray,i,cbInCardData[i]);
    end
	GameLogic:SortCardList(bCardArray, bCardCount, GameLogic.enDescend);

	--分析扑克
	for i = 1,bCardCount do
		-- change by Owen, 2018.5.3, 王牌保存到 evCardList[1]
		--保存王牌
		if (bCardArray[i] == 0x41 or bCardArray[i] == 0x42) then
			--evCardList[0].AddTail(bCardArray[i]);
			table.insert(evCardList[1], bCardArray[i])
			--continue;
		else

			--保存其他
			local bLogicNum = GameLogic:GetCardLogicValue(bCardArray[i]);
			local bColor = GameLogic:GetCardColor(bCardArray[i]);

			assert(bLogicNum>1 and bLogicNum<15 and bColor>=0 and bColor<=4);
			--assert(evCardList[bLogicNum].Find(bCardArray[i]) == NULL);

			table.insert(evCardList[bLogicNum + 1],bCardArray[i]);
	        table.insert(evColorList[bColor + 1],bCardArray[i]);
	    end
	end

	assert(#evCardList[1] <= 2);

	--寻找顺子
	if (bNeedCCount == 5) then
		for i=15,6,-1 do
			local bHaveCard = {};
			for k = 1,4 do
				bHaveCard[k] = (#evCardList[i-k + 1]>0);
			end
            local temp11 = 0;
            if i == 6 then
                temp11 = #evCardList[15];
            else    
                temp11 = #evCardList[i-4];
            end
            bHaveCard[5] = (temp11 > 0);
            if bHaveCard[1] == true then
                temp11 = 1;
            else
                temp11 = 0;
            end
            local temp22 = 0;
            if bHaveCard[2] == true then
                temp22 = 1;
            else
                temp22 = 0;
            end
            local temp33 = 0;
            if bHaveCard[3] == true then
                temp33 = 1;
            else
                temp33 = 0;
            end
            local temp44 = 0;
            if bHaveCard[4] == true then
                temp44 = 1;
            else
                temp44 = 0;
            end
            local temp55 = 0;
            if bHaveCard[5] == true then
                temp55 = 1;
            else
                temp55 = 0;
            end
			local bCount = temp11 + temp22 + temp33 + temp44+ temp55;
			if (bCount + #evCardList[1] >= 5) then
                assert(bCount>=3 and bCount<=5);
                local index = 5 - bCount;
                for j = 1, 5 - bCount do
                    bMaxCardData[j] = evCardList[1][j];
                end
                for k = 1,4 do
                    if (bHaveCard[k]) then
						bMaxCardData[index] = evCardList[i-k + 1][1];
                        index = index + 1;
                    end
                end
                local bFirstCardNum = 0;
                if (i == 6) then
                    bFirstCardNum = 15;
                else
                    bFirstCardNum = i-4;
                end
				if (bHaveCard[5]) then
					bMaxCardData[5] = evCardList[bFirstCardNum][1];
                end

				bMaxCardCount = 5;
				--m_btShunZi.EnableWindow(true);
                self.btJunko:setEnabled(true);
				return;
			end
		end
	end
end
--同花顺
--[[
function GameViewLayer:EnableTonghuaShunButton(cbInCardData)
    --定义变量
	local bKCount = 0;
	local evCardList = {};	--0位存王牌,1位保留,其他位按逻辑值存放，15个链表
    for i = 1, 15 do
        evCardList[i] = {};
    end
	local evColorList = {};	--方梅红黑， 4个链表
	-- change by Owen, 2018.4.30, 有王的话下面这个循环会到5
    -- for i = 1, 4 do
    for i = 1, 5 do
        evColorList[i] = {};
    end
	local bCardArray = {}; --size = 13
	local bNeedCCount = 5;
	local bMaxCardData = {};--5
	local bMaxCardCount = 0;
	--local cbInCardData = {};--size = 13
	local bCardCount = #cbInCardData;
	--memcpy(bCardArray, cbInCardData, sizeof(BYTE)*bCardCount);
    for i = 1,bCardCount do
        table.insert(bCardArray,i,cbInCardData[i]);
    end
	GameLogic:SortCardList(bCardArray, bCardCount, GameLogic.enDescend);

	--分析扑克
    for i = 1,bCardCount do
        --保存王牌
		if (bCardArray[i] == 0x41 or bCardArray[i] == 0x42) then
            --没王暂时不处理
			--evCardList[1].AddTail(bCardArray[i]);
			--continue;
			
			-- change by Owen, 2018.5.2, 把王牌的插入移到这里
        	table.insert(evCardList[1],bCardArray[i]);
        else
			

			--保存其他
			local bLogicNum = GameLogic:GetCardLogicValue(bCardArray[i]);
			local bColor = GameLogic:GetCardColor(bCardArray[i]);
			print ("bLogicNum="..bLogicNum)
			assert(bLogicNum>1 and bLogicNum<15 and bColor>=0 and bColor<=4);
			--assert(evCardList[bLogicNum + 1].Find(bCardArray[i]) == NULL);

			-- -- change by Owen, 2018.5.2, 把王牌的插入移到上面去
	  --       table.insert(evCardList[bLogicNum + 1],bCardArray[i]);

	        -----------过滤相同的牌
	        local n1 = #evColorList[bColor+1]
	        local b1= false
	        for j=1, n1 do
	            if bCardArray[i] == evColorList[bColor+1][j] then
	               b1 = true
	            end
	        end

	        if b1 ==false then
	            table.insert(evColorList[bColor + 1],bCardArray[i]);
	        end
	    end

    end


	assert(#evCardList[1] <= 2);

	--寻找同顺
	if (bNeedCCount == 5) then
        for i = 1 ,4 do
            if (#evColorList[i]+#evCardList[1] >= 5) then	--同花+王牌数大于等于5
            	local bCount = 0;
            	-- change by Owen, 2018.5.2, 修改不带王的处理
				-- if (#evCardList[1] >= 0 and #evColorList[i] >= 5) then		--不带王
				if (#evCardList[1] == 0 and #evColorList[i] >= 5) then		--不带王
					for j = 1,#evColorList[i]-4 do      -----判断花色数量超过5张
						local bFstCard = evColorList[i][j];
						local bLstCard = evColorList[i][j + 4];

						if (GameLogic:GetCardLogicValue(bFstCard) -  GameLogic:GetCardLogicValue(bLstCard) == 4) then
							for k = 1, 5 do
								bMaxCardData[k] = evColorList[i][j+k];
							end
							bMaxCardCount = 5;
                            self.btFlush01:setEnabled(true)
							--m_btTongHuaShun.EnableWindow(true);
							return;
						end
					end
				
					if (GameLogic:GetCardValue(evColorList[i][1]) == 1 and						--检查A2345顺
						GameLogic:GetCardValue(evColorList[i][#evColorList[i]-4]) == 5) then	
						bMaxCardData[1] = evColorList[i][1];
						for k = 2,5 do
							bMaxCardData[k] = evColorList[i][#evColorList[i]-k];
						end
						bMaxCardCount = 5;
                        self.btFlush01:setEnabled(true)
						--m_btTongHuaShun.EnableWindow(true);
						return;
					end
				end
				-- change by Owen, 2018.5.2, 修改不带王的处理
				-- if (#evCardList[1] >= 1 and #evColorList[i] >= 4) then		--带单王
				if (#evCardList[1] == 1 and #evColorList[i] >= 4) then		--带单王
					for j = 1,#evColorList[i] - 3 do
						local bFstCard = evColorList[i][j];
						local bLstCard = evColorList[i][j+3];

						if ( (GameLogic:GetCardLogicValue(bFstCard) -  GameLogic:GetCardLogicValue(bLstCard) == 3) or 
							(GameLogic:GetCardLogicValue(bFstCard) -  GameLogic:GetCardLogicValue(bLstCard) == 4) ) then
							bMaxCardData[1] = evCardList[1][1];
							for k = 1,4 do
								bMaxCardData[k+1] = evColorList[i][(j+k)];
							end
							bMaxCardCount = 5;
                            self.btFlush01:setEnabled(true)
							--m_btTongHuaShun.EnableWindow(true);
							return ;
						end
					end 

					if (GameLogic:GetCardValue(evColorList[i][1]) == 1 and						--检查A2345顺
						GameLogic:GetCardValue(evColorList[i][(#evColorList[i]-3)]) <= 5)	then
						bMaxCardData[1] = evCardList[1][1];
						bMaxCardData[2] = evColorList[i][1];
						for k = 2,4 do
							bMaxCardData[k+1] = evColorList[i][(#evColorList[i]-k)];
						end
						bMaxCardCount = 5;
                        self.btFlush01:setEnabled(true)
						--m_btTongHuaShun.EnableWindow(true);
						return;
					end
				end
				if (#evCardList[1] == 2 and #evColorList[i] >= 3) then		--带双王
					for j =1,#evColorList[i]-2 do
						local bFstCard = evColorList[i][j];
						local bLstCard = evColorList[i][j+2];

						if ( (GameLogic:GetCardLogicValue(bFstCard) -  GameLogic:GetCardLogicValue(bLstCard) == 2) or
							(GameLogic:GetCardLogicValue(bFstCard) -  GameLogic:GetCardLogicValue(bLstCard) == 3) or 
							(GameLogic:GetCardLogicValue(bFstCard) -  GameLogic:GetCardLogicValue(bLstCard) == 4)) then
							bMaxCardData[1] = evCardList[1][1];
							bMaxCardData[2] = evCardList[1][(#evCardList[1])];
							for k = 1,3 do
								bMaxCardData[k+2] = evColorList[i][(j+k)];
							end
								
							bMaxCardCount = 5;
                            self.btFlush01:setEnabled(true)
							--m_btTongHuaShun.EnableWindow(true);
							return;
						end
					end
					if (GameLogic:GetCardValue(evColorList[i][1]) == 1 and						--检查A2345顺
						GameLogic:GetCardValue(evColorList[i][(#evColorList[i]-2)]) <= 5) then	
						bMaxCardData[1] = evCardList[1][1];
						bMaxCardData[2] = evCardList[1][(#evCardList[1])];
						bMaxCardData[3] = evColorList[i][1];
						for k = 2, 3 do
							bMaxCardData[k+2] = evColorList[i][(#evColorList[i]-k)];
						end
						bMaxCardCount = 5;
                        self.btFlush01:setEnabled(true)
						--m_btTongHuaShun.EnableWindow(true);
						return;
					end
				end
			end
        end
		
	end
end
]]

-- --同花顺
function GameViewLayer:EnableTonghuaShunButton(cbInCardData)
	local count = self:TongHuaShun(cbInCardData, #cbInCardData, {})
	if count > 0 then
		self.btFlush01:setEnabled(true)
	else
		self.btFlush01:setEnabled(false)
	end
end


function GameViewLayer:hideAllMyCard(viewID)
      assert(viewID >= 1 and viewID <= cmd.GAME_PLAYER)
      for i = 1, 13 do
          local card = self.nodeCard[viewID]:getChildByTag(i)
          card:setVisible(false)  --修改
      end
end
function GameViewLayer:showMyCard(cbCardData)
	if #cbCardData == 0 then
		return
	end
    GameLogic:SortCardList(cbCardData,#cbCardData,GameLogic.enDescend);

    local spW = (13-#cbCardData) * (GameViewLayer.CARDSPACING/2)

    for i = 1, #cbCardData do
          --local index = self._scene:GetMeChairID() + 1
          --local data = self.cbCardData[index][i]
          local data = cbCardData[i]
          local value = GameLogic:GetCardValue(data)
          local color = GameLogic:GetCardColor(data)
          local card = self.nodeCard[cmd.MY_VIEWID]:getChildByTag(i)
          card:setVisible(true)
          self:setCardTextureRect(cmd.MY_VIEWID, i, value, color,spW)
          self.bCanMoveCard = true
    end
end
function  GameViewLayer:setEnableCardButton(Enabled)
      self.btOnePair:setEnabled(Enabled)
      self.btTwoPair:setEnabled(Enabled)
      self.btThree:setEnabled(Enabled)
      self.btJunko:setEnabled(Enabled)
      self.btFlush1:setEnabled(Enabled)
      self.btGourd:setEnabled(Enabled)
      self.btFourPlum:setEnabled(Enabled)
      self.btFlush01:setEnabled(Enabled)
      self.btFiveWith:setEnabled(Enabled)
end
function  GameViewLayer:setVisbileCardButton(bVisible)
      self.btOnePair:setVisible(bVisible)
      self.btTwoPair:setVisible(bVisible)
      self.btThree:setVisible(bVisible)
      self.btJunko:setVisible(bVisible)
      self.btFlush1:setVisible(bVisible)
      self.btGourd:setVisible(bVisible)
      self.btFourPlum:setVisible(bVisible)
      self.btFlush01:setVisible(bVisible)
      self.btFiveWith:setVisible(bVisible)
end
function GameViewLayer:resetCardOut()
      for i = 1,#self.bCardOut do
        if true == self.bCardOut[i] then
           local card = self.nodeCard[cmd.MY_VIEWID]:getChildByTag(i)
           local x, y = card:getPosition()
           card:move(x, y - 30)
        end
        self.bCardOut[i] = false
      end
end
function  GameViewLayer:createArrangeCardFrame()
	--创建墩牌背景
    self.spriteArrange = display.newSprite(GameViewLayer.RES_PATH.."cardArrange/ArrangeCardFrame.png")
	self.spriteArrange:move(pointArrangeCardFrame)
    self.spriteArrange:setAnchorPoint(cc.p(0.5,0.95))
	self.spriteArrange:setScaleY(1.3)
	self.spriteArrange:setScaleX(1.5)
    self.spriteArrange:setVisible(false)
	
	--self.spriteArrange:setLocalZOrder(50)
	self.spriteArrange:addTo(self,50)
	--创建显示的大墩牌精灵
	--三墩
	self.nodeRowCard = {}
	for i = 1,3 do
		self.nodeRowCard[i] = {}
	end

	local rect = self:copyTab(rectClick3Row[1])
    local Left = pointArrangeCardFrame.x - self.spriteArrange:getContentSize().width/2
    local top = pointArrangeCardFrame.y
    rect.x = Left + rectClick3Row[1].x
    rect.y = top - rectClick3Row[1].y - rectClick3Row[1].height

    local COSNT_WIDTH = 70
    local COSNT_HEIGHT = 63
    local cardWidth = 0
	local cardHeight = 0
	--第一墩3张牌
	for i = 1,3 do
		self.nodeRowCard[1][i] = display.newSprite(GameViewLayer.RES_PATH.."cardArrange/SoBigCard.png")
		cardWidth = self.nodeRowCard[1][i]:getContentSize().width/13
		cardHeight = self.nodeRowCard[1][i]:getContentSize().height/5
		self.nodeRowCard[1][i]:setAnchorPoint(cc.p(0,0.5))
		self.nodeRowCard[1][i]:setTextureRect(cc.rect(cardWidth*2, cardHeight*4, cardWidth, cardHeight))
		self.nodeRowCard[1][i]:move(cc.p(rect.x - 3 - 35 + (COSNT_WIDTH + 33)*(i -1),rect.y))
		--self.nodeRowCard[1][i]:setLocalZOrder(51)
		self.nodeRowCard[1][i]:setScaleY(1.3)
		self.nodeRowCard[1][i]:setScaleX(1.5)
        self.nodeRowCard[1][i]:setVisible(false)
		self.nodeRowCard[1][i]:addTo(self,51)
	end
	--第二、三墩5张牌
	for i = 1,5 do
		self.nodeRowCard[2][i] = display.newSprite(GameViewLayer.RES_PATH.."cardArrange/SoBigCard.png")
		:setTextureRect(cc.rect(cardWidth*2, cardHeight*4, cardWidth, cardHeight))
		:move(cc.p(rect.x - COSNT_WIDTH - 65 + (COSNT_WIDTH + 37)*(i -1),rect.y - COSNT_HEIGHT - 45))
		:setAnchorPoint(cc.p(0,0.5))
		--:setLocalZOrder(52)
		:setScaleY(1.3)
		:setScaleX(1.3)
        :setVisible(false)
		:addTo(self,52)
		self.nodeRowCard[3][i] = display.newSprite(GameViewLayer.RES_PATH.."cardArrange/SoBigCard.png")
		:setTextureRect(cc.rect(cardWidth*2, cardHeight*4, cardWidth, cardHeight))
		:move(cc.p(rect.x - COSNT_WIDTH - 20-80 + (COSNT_WIDTH + 9 + 45)*(i -1),rect.y - 2 * COSNT_HEIGHT - 35 - 45))
		:setAnchorPoint(cc.p(0,0.5))
		--:setLocalZOrder(53)
		:setScaleY(1.3)
		:setScaleX(1.3)
        :setVisible(false)
		:addTo(self,53)
	end
end
--一些相关按钮创建
function GameViewLayer:createOtherButton(btcallback)
	-- body
    local x = pointArrangeCardFrame.x + self.spriteArrange:getContentSize().width/2 - 60  
    local y = pointArrangeCardFrame.y;
	self.btX1 = ccui.Button:create(GameViewLayer.RES_PATH.."cardArrange/XButton1.png",
	    GameViewLayer.RES_PATH.."cardArrange/XButton2.png")
    self.btX1:setTag(GameViewLayer.BT_X1)
    self.btX1:setVisible(false)
	self.btX1:move(x - 20,y - 49)
	self.btX1:setScale(1.3)
	self.btX1:addTo(self,51)
	self.btX1:addTouchEventListener(btcallback)

	self.btX2 = ccui.Button:create(GameViewLayer.RES_PATH.."cardArrange/XButton1.png",
	    GameViewLayer.RES_PATH.."cardArrange/XButton2.png")
    self.btX2:setTag(GameViewLayer.BT_X2)
    self.btX2:setVisible(false)
    self.btX2:move(x + 70,y - 150)
	self.btX2:setScale(1.3)
	self.btX2:addTo(self,51)
	self.btX2:addTouchEventListener(btcallback)

	self.btX3 = ccui.Button:create(GameViewLayer.RES_PATH.."cardArrange/XButton1.png",
	    GameViewLayer.RES_PATH.."cardArrange/XButton2.png")
	self.btX3:setTag(GameViewLayer.BT_X3)
    self.btX3:setVisible(false)
    self.btX3:move(x + 100,y - 250 )
	self.btX3:setScale(1.3)
	self.btX3:addTo(self,51)
	self.btX3:addTouchEventListener(btcallback)

    self.btOutCard = ccui.Button:create(GameViewLayer.RES_PATH.."cardArrange/OutCard1.png",
	    GameViewLayer.RES_PATH.."cardArrange/OutCard2.png")
	self.btOutCard:setTag(GameViewLayer.BT_OutCard)
    self.btOutCard:setVisible(false)
    self.btOutCard:setAnchorPoint(cc.p(0.5,1))
    self.btOutCard:move(pointArrangeCardFrame.x + 100 ,y - 450 )
	self.btOutCard:addTo(self)
	self.btOutCard:addTouchEventListener(btcallback)

    self.btRecover = ccui.Button:create(GameViewLayer.RES_PATH.."cardArrange/Recover1.png",
	    GameViewLayer.RES_PATH.."cardArrange/Recover2.png")
	self.btRecover:setTag(GameViewLayer.BT_Recover)
    self.btRecover:setVisible(false)
    self.btRecover:setAnchorPoint(cc.p(0.5,1))
    self.btRecover:move(pointArrangeCardFrame.x - 100,y - 450 )
	self.btRecover:addTo(self)
	self.btRecover:addTouchEventListener(btcallback)
	
end
--点击墩牌区域回调
function GameViewLayer:clickArrangeRow(rowIndex)
		--显示3墩牌
	    assert(rowIndex >= 1 and rowIndex <= 3)
	    local count = 5
	    if rowIndex == 1 then
	    	count = 3
	    end

	    --遍历选择的牌有多少张，顺便保存数组下标
	    local tempCount = 0
	    local arrayIndex = {};
	    for i = 1,#self.bCardOut do
	        if true == self.bCardOut[i] then
                 assert(i >= 1 and i <= 13)
	            tempCount = tempCount + 1
	            table.insert(arrayIndex,i)
	            if tempCount >= count then
	               break
	            end
	        end
	    end

	    if tempCount == 0 then
	    	return
	    end
      	--选择的牌的数量大于显示的数量
      	if tempCount >= count then
      	 	--要把数据插回到下方的牌的数组里
      	 	for i = 1,#self.arrangeCard[rowIndex] do
      	 	table.insert(self.handCard,self.arrangeCard[rowIndex][i])
      	 	end
         	self.arrangeCard[rowIndex] = {}
         	for i = 1,count do
         		table.insert(self.arrangeCard[rowIndex],self.handCard[arrayIndex[i]])
         	end
            --这里要从后面开始删除，不然索引对不上
            for i = count,1,-1 do
                table.remove(self.handCard,arrayIndex[i])
            end
            
     	elseif tempCount + #self.arrangeCard[rowIndex] > count then -- 选择的牌的数量与已经选择的牌的数量会大于显示的数量
     		--要把数据插回到下方的牌的数组里
	      	for i = 1,#self.arrangeCard[rowIndex] do
	      		table.insert(self.handCard,self.arrangeCard[rowIndex][i])
	      	end
         	self.arrangeCard[rowIndex] = {}
       		for i = 1,tempCount do
         		table.insert(self.arrangeCard[rowIndex],self.handCard[arrayIndex[i]])
        	end
            --这里要从后面开始删除，不然索引对不上
            for i = tempCount,1,-1 do
                table.remove(self.handCard,arrayIndex[i])
            end
      	else
            --appdf.printTable(self.arrangeCard)
            --appdf.printTable(self.handCard)
            appdf.printTable(arrayIndex)
        	for i = 1,tempCount do
         		table.insert(self.arrangeCard[rowIndex],self.handCard[arrayIndex[i]])
        	end
            --这里要从后面开始删除，不然索引对不上
            for i = tempCount,1,-1 do
                table.remove(self.handCard,arrayIndex[i])
            end
      	end

        local d3 = #self.arrangeCard[1]
        local m5 = #self.arrangeCard[2]
        local d5 = #self.arrangeCard[3]

        local hcardnum = #self.handCard

        --说明剩余3 张或者5张
        if hcardnum ==3 or hcardnum ==5 then
           if hcardnum ==3 then
            if m5 == 5 and d5 ==5 then -- 判断只剩下3张 在一个墩
                self.arrangeCard[1] = {}
       		    for i = 1,hcardnum do
         		    table.insert(self.arrangeCard[1],self.handCard[i])
        	    end

                for i = hcardnum,1,-1 do
                    table.remove(self.handCard,i)
                end
                --显示墩牌	    
                self:showAnrrageRow(1)
            end
           elseif hcardnum ==5 then
             if d3==3 and d5 ==5 then
                  self.arrangeCard[2] = {}
       		        for i = 1,hcardnum do
         		        table.insert(self.arrangeCard[2],self.handCard[i])
        	        end

                    for i = hcardnum,1,-1 do
                        table.remove(self.handCard,i)
                    end
                    --显示墩牌	    
                    self:showAnrrageRow(2)
               elseif d3==3 and m5 ==5 then
                    self.arrangeCard[3] = {}
       		        for i = 1,hcardnum do
         		        table.insert(self.arrangeCard[3],self.handCard[i])
        	        end

                    for i = hcardnum,1,-1 do
                        table.remove(self.handCard,i)
                    end
                    --显示墩牌	    
                    self:showAnrrageRow(3)
                end

           end

        end


	    self:resetCardOut()
	    self:setEnableCardButton(false)
	    self:hideAllMyCard(cmd.MY_VIEWID)
	    self:showMyCard(self.handCard)
	    self:setCardButtonEnable()
        --显示墩牌	    
        self:showAnrrageRow(rowIndex)
        
end
--显示墩牌
function GameViewLayer:showAnrrageRow(rowIndex)
	-- body
	assert(rowIndex >= 1 and rowIndex <= 3)
	local count = 0
	if rowIndex == 1 then
		count = 3
	else
		count = 5
	end
	
	for i = 1,count do
		self.nodeRowCard[rowIndex][i]:setVisible(false)
	end

    --appdf.printTable(self.arrangeCard[rowIndex])
	for i = 1,#self.arrangeCard[rowIndex] do
			local data = self.arrangeCard[rowIndex][i]
	        local value = GameLogic:GetCardValue(data)
	        local color = GameLogic:GetCardColor(data)
			local card = self.nodeRowCard[rowIndex][i]
			local rectCard = card:getTextureRect()
			rectCard.x = rectCard.width*(value - 1)
			rectCard.y = rectCard.height*color
			card:setTextureRect(rectCard)
			card:setVisible(true)
	end
	
end
--撤回墩上的牌
function GameViewLayer:clickXButton(index)
	-- body
	--要把数据插回到下方的牌的数组里
    if(#self.arrangeCard[index] == 0) then
        return
    end
	for i = 1,#self.arrangeCard[index] do
  		table.insert(self.handCard,self.arrangeCard[index][i])
	end
    self.arrangeCard[index] = {}
    local count = 0
	if index == 1 then
		count = 3
	else
		count = 5
	end
    for i = 1,count do
		self.nodeRowCard[index][i]:setVisible(false)
	end

    self:resetCardOut()
	self:setEnableCardButton(false)
	self:hideAllMyCard(cmd.MY_VIEWID)
	self:showMyCard(self.handCard)
	self:setCardButtonEnable()

end
--撤回墩上的牌
function GameViewLayer:clickRecoverButton()
	-- body
	--要把数据插回到下方的牌的数组里
	for index = 1, 3 do
		if #self.arrangeCard[index] > 0 then
			for i = 1,#self.arrangeCard[index] do
  				table.insert(self.handCard,self.arrangeCard[index][i])
  				self.nodeRowCard[index][i]:setVisible(false)
  			end
            self.arrangeCard[index] = {}
		end
	end
    
    self:resetCardOut()
	self:setEnableCardButton(false)
	self:hideAllMyCard(cmd.MY_VIEWID)
	self:showMyCard(self.handCard)
	self:setCardButtonEnable()

end
function GameViewLayer:createOpenCardAniamal()
	-- body
	--牌背
    self.aniCardBack = {}
	self.daqian_Node ={}
    for i = 1, cmd.GAME_PLAYER do
        self.aniCardBack[i] = {}
		self.daqian_Node[i] = {}
    end
    for j = 1,cmd.GAME_PLAYER do
        local cardWidth = 0
        local cardHeight = 0
        local count = 3
        local left = 0
        local top = pointAnimalCard[j].y
        local OFFWIDTH = 40
	    for i = 1, count do
		    self.aniCardBack[j][i] = display.newSprite(GameViewLayer.RES_PATH.."cardArrange/SmallCard.png")
		    cardWidth = self.aniCardBack[j][i]:getContentSize().width/13
		    cardHeight = self.aniCardBack[j][i]:getContentSize().height/5
		    self.aniCardBack[j][i]:setTextureRect(cc.rect(cardWidth*2, cardHeight*4, cardWidth, cardHeight))
		    self.aniCardBack[j][i]:setVisible(false) ---测试 改false
            left = pointAnimalCard[j].x - ((count - 1) * OFFWIDTH + cardWidth) /2
		    self.aniCardBack[j][i]:move(left + OFFWIDTH * (i - 1),top)
			--self.aniCardBack[j][i]:setLocalZOrder(20)
		    self.aniCardBack[j][i]:addTo(self,20)
	    end
   		
		
        count = 5
        for i = 1, count do
            self.aniCardBack[j][i + 3] = display.newSprite(GameViewLayer.RES_PATH.."cardArrange/SmallCard.png")
		    self.aniCardBack[j][i + 3]:setTextureRect(cc.rect(cardWidth*2, cardHeight*4, cardWidth, cardHeight))
		    self.aniCardBack[j][i + 3]:setVisible(false)
            left = pointAnimalCard[j].x - ((count - 1) * OFFWIDTH + cardWidth) /2
		    self.aniCardBack[j][i + 3]:move(left + OFFWIDTH * (i - 1),top - cardHeight/2)
			--self.aniCardBack[j][i]:setLocalZOrder(21 + i)
		    self.aniCardBack[j][i + 3]:addTo(self,21 + i)
        end
        for i = 1, count do
            self.aniCardBack[j][i + 8] = display.newSprite(GameViewLayer.RES_PATH.."cardArrange/SmallCard.png")
		    self.aniCardBack[j][i + 8]:setTextureRect(cc.rect(cardWidth*2, cardHeight*4, cardWidth, cardHeight))
		    self.aniCardBack[j][i + 8]:setVisible(true)
            left = pointAnimalCard[j].x - ((count - 1) * OFFWIDTH + cardWidth) /2
		    self.aniCardBack[j][i + 8]:move(left + OFFWIDTH * (i - 1),top - cardHeight)
			--self.aniCardBack[j][i]:setLocalZOrder(26 + i)
		    self.aniCardBack[j][i + 8]:addTo(self,26 + i)
        end
	    for i=1 , 3 do  --打枪图片
		  self.daqian_Node[j][i] = display.newSprite(GameViewLayer.RES_PATH.."BulletHoles.png")
		  self.daqian_Node[j][i]:move(pointAnimalCard[j].x-pointdaqiangAni_Dangkong[i].x,pointAnimalCard[j].y-pointdaqiangAni_Dangkong[i].y)
		  self.daqian_Node[j][i]:setVisible(false) --隐藏 
		  self.daqian_Node[j][i]:addTo(self,35)
		
		end			
		
		
    end
    --牌前花色
    self.aniCardFont = {}
    for i = 1, cmd.GAME_PLAYER do
        self.aniCardFont[i] = {}
    end
    for j = 1,cmd.GAME_PLAYER do
        local cardWidth = 0
        local cardHeight = 0
        local count = 3
        local left = 0
        local top = pointAnimalCard[j].y
        local OFFWIDTH = 40
	    for i = 1, count do
		    self.aniCardFont[j][i] = display.newSprite(GameViewLayer.RES_PATH.."cardArrange/SmallCard.png")
		    cardWidth = self.aniCardFont[j][i]:getContentSize().width/13
		    cardHeight = self.aniCardFont[j][i]:getContentSize().height/5
		    self.aniCardFont[j][i]:setTextureRect(cc.rect(0, 0, cardWidth, cardHeight))
		    self.aniCardFont[j][i]:setVisible(false)
            left = pointAnimalCard[j].x - ((count - 1) * OFFWIDTH + cardWidth) /2
		    self.aniCardFont[j][i]:move(left + OFFWIDTH * (i - 1),top)
			--self.aniCardFont[j][i]:setLocalZOrder(30)
		    self.aniCardFont[j][i]:addTo(self,30)
	    end
        count = 5
        for i = 1, count do
            self.aniCardFont[j][i + 3] = display.newSprite(GameViewLayer.RES_PATH.."cardArrange/SmallCard.png")
		    self.aniCardFont[j][i + 3]:setTextureRect(cc.rect(0,0, cardWidth, cardHeight))
		    self.aniCardFont[j][i + 3]:setVisible(false)
            left = pointAnimalCard[j].x - ((count - 1) * OFFWIDTH + cardWidth) /2
		    self.aniCardFont[j][i + 3]:move(left + OFFWIDTH * (i - 1),top - cardHeight/2)
			--self.aniCardFont[j][i]:setLocalZOrder(31)
		    self.aniCardFont[j][i + 3]:addTo(self,31)
        end
        for i = 1, count do
            self.aniCardFont[j][i + 8] = display.newSprite(GameViewLayer.RES_PATH.."cardArrange/SmallCard.png")
		    self.aniCardFont[j][i + 8]:setTextureRect(cc.rect(0,0, cardWidth, cardHeight))
		    self.aniCardFont[j][i + 8]:setVisible(false)
            left = pointAnimalCard[j].x - ((count - 1) * OFFWIDTH + cardWidth) /2
		    self.aniCardFont[j][i + 8]:move(left + OFFWIDTH * (i - 1),top - cardHeight)
			--self.aniCardFont[j][i]:setLocalZOrder(32)
		    self.aniCardFont[j][i + 8]:addTo(self,32)
        end
    end
	
end
function GameViewLayer:setAniCardFontVisible( viewID,bVisible )
	-- body
	assert(viewID >= 1 and viewID <= cmd.GAME_PLAYER)
	for i = 1,#self.aniCardFont[viewID] do
		self.aniCardFont[viewID][i]:setVisible(bVisible)
	end
end
function GameViewLayer:setAniCardBackVisible( viewID,bVisible )
	-- body

	   --self.PlaceCard[viewID]:setVisible(false)
	   --self.BgCard[viewID]:setVisible(false)
	
	assert(viewID >= 1 and viewID <= cmd.GAME_PLAYER)
	for i = 1,#self.aniCardBack[viewID] do
		self.aniCardBack[viewID][i]:setVisible(bVisible)
	end
end
function GameViewLayer:setNodeRowCard(bVisible)
    for i = 1,3 do
        self.nodeRowCard[1][i]:setVisible(bVisible)
    end
    for i = 1,5 do
        self.nodeRowCard[2][i]:setVisible(bVisible)
        self.nodeRowCard[3][i]:setVisible(bVisible)
    end
    
end
--创建输赢分数
function GameViewLayer:createWinLostScore()
	--local sizeNum = labAtNum:getContentSize()
	--labAtNum:move(sizeSymbol.width + sizeNum.width/2, sizeNum.height/2)
    self.nodeScore = {}
    for i = 1, cmd.GAME_PLAYER do
        self.nodeScore[i] = {}
    end
    local indexArray = {3,8,13} --取第3,8,13墩牌的位置，偏移牌的分数位置
    local width = 0
    local height = 0
    for i=1,cmd.GAME_PLAYER do
       for j = 1,3 do --3墩
        self.nodeScore[i][j] = cc.LabelAtlas:_create(11, GameViewLayer.RES_PATH.."cardArrange/CompareCardNumPlus.png", 17, 28, string.byte("0"))		--数字
        self.nodeScore[i][j]:setVisible(false)
        self.nodeScore[i][j]:setAnchorPoint(cc.p(0, 0.5))
       	local x2, y2 = self.aniCardFont[i][indexArray[j]]:getPosition()
        self.nodeScore[i][j]:move(cc.p(x2 + 70,y2 + 30))
		self.nodeScore[i][j]:addTo(self)
       end
    end

    self.nodeNumPlus = {}
    for i = 1, cmd.GAME_PLAYER do
        self.nodeNumPlus[i] = {}
    end
    for i=1,cmd.GAME_PLAYER do
       for j = 1,3 do --3墩
        self.nodeNumPlus[i][j] = display.newSprite(GameViewLayer.RES_PATH.."cardArrange/CompareCardNumPlusJa.png")
        self.nodeNumPlus[i][j]:setVisible(false)
        self.nodeNumPlus[i][j]:setAnchorPoint(cc.p(1, 0.5))
       	local x2, y2 = self.aniCardFont[i][indexArray[j]]:getPosition()
        self.nodeNumPlus[i][j]:move(cc.p(x2 + 70,y2 + 30))
		self.nodeNumPlus[i][j]:addTo(self)
       end
    end

    self.nodeNumJn = {}
    for i = 1, cmd.GAME_PLAYER do
        self.nodeNumJn[i] = {}
    end
    for i=1,cmd.GAME_PLAYER do
       for j = 1,3 do --3墩
        self.nodeNumJn[i][j] = display.newSprite(GameViewLayer.RES_PATH.."cardArrange/CompareCardNumPlusJn.png")
        self.nodeNumJn[i][j]:setVisible(false)
        self.nodeNumJn[i][j]:setAnchorPoint(cc.p(1, 0.5))
       		local x2, y2 = self.aniCardFont[i][indexArray[j]]:getPosition()
        self.nodeNumJn[i][j]:move(cc.p(x2 + 70,y2 + 30))
		self.nodeNumJn[i][j]:addTo(self)
       end
    end
    
end
--点击出牌
function GameViewLayer:onBtOutCard(cbCardData,special)
	if cbCardData == nil or #cbCardData ~= cmd.HAND_CARD_COUNT then
--[[		for i =1, #cbCardData do
			print("card = "..GameLogic:getCardData(cbCardData[i]))
		end--]]
		return
    end
	self.bCanMoveCard = false
	self.btOutCard:setVisible(false)
	self.btRecover:setVisible(false)
	self.btX1:setVisible(false)
	self.btX2:setVisible(false)
	self.btX3:setVisible(false)
	self:setVisbileCardButton(false)
	self:setEnableCardButton(false)
	self.spriteArrange:setVisible(false)
	self:setNodeRowCard(false)
	self:hideAllMyCard(cmd.MY_VIEWID)
	self:setAniCardBackVisible(cmd.MY_VIEWID,true)
	self._scene:onOpenCard(cbCardData,special)
end
--特殊牌型
function GameViewLayer:createSpecialCard()
	self.m_specialCard = {}
	local cardWidth = 0
	local spriteHeight = 0
	local cardHeight = 0
	for i = 1,cmd.GAME_PLAYER do
		self.m_specialCard[i] = display.newSprite(GameViewLayer.RES_PATH.."specialCard/SpecialTypeBig.png")
		cardWidth = self.m_specialCard[i]:getContentSize().width
		spriteHeight = self.m_specialCard[i]:getContentSize().height
		cardHeight = spriteHeight/13
		self.m_specialCard[i]:setTextureRect(cc.rect(0,0, cardWidth, cardHeight))
		self.m_specialCard[i]:move(cc.p(pointAnimalCard[i].x - cardWidth/4,pointAnimalCard[i].y - cardHeight))
		self.m_specialCard[i]:setAnchorPoint(cc.p(0.5,0.5))
		self.m_specialCard[i]:setVisible(false)
		self.m_specialCard[i]:addTo(self)
	end
end
--特殊牌型
function GameViewLayer:setSpecialCard(viewID,type)
	assert(viewID >= 1 and viewID <= cmd.GAME_PLAYER and type >= 13 and type <= 25 )

    local t = CCTextureCache:sharedTextureCache():addImage(GameViewLayer.RES_PATH.."specialCard/SpecialTypeBig.png")

    self.m_specialCard[viewID]:setTexture(t)
	local cardWidth = self.m_specialCard[viewID]:getContentSize().width
	local cardHeight = self.m_specialCard[viewID]:getContentSize().height
	self.m_specialCard[viewID]:setTextureRect(cc.rect(0,(type - 13) * cardHeight, cardWidth, cardHeight))
	self.m_specialCard[viewID]:setVisible(true)
end
--设置多张牌向上
function GameViewLayer:setMyCardArrayUp(IndexArray)
	if nil == IndexArray or #IndexArray == 0 then
		return
	end
	for i = 1,#IndexArray do
		self:setMyCardUp(IndexArray[i])
	end
end
--设置单牌向上
function GameViewLayer:setMyCardUp(index)
	assert(index >= 1 and index <= #self.handCard)
	local card = self.nodeCard[cmd.MY_VIEWID]:getChildByTag(index)
	local x2, y2 = card:getPosition()
	if false == self.bCardOut[index] then
		card:move(x2, y2 + 30)
		self.bCardOut[index] = not self.bCardOut[index]
	end
end
--一对
function GameViewLayer:OneDouble(cbInCardData,bCardCount,cbOutCardIndex)
	if (self.m_cbCardType ~= GameLogic.CT_ONE_DOUBLE) then
		self.m_cbIndex = 1;
	end
	self.m_cbCardType = GameLogic.CT_ONE_DOUBLE;
	local AnalyseData = {bOneCount = 0,bTwoCount = 0,bThreeCount = 0,
	  bFourCount = 0,bFiveCount=0,bWangCount=0,bOneFirst={},
	  bTwoFirst={},bThreeFirst={},bFourFirst={},bFiveFirst={},
	  bWangData={},bSameColorData={},bSameColorCount={},
	  bAllOne={},bAllOneCount={},bSameColor=0};
	GameLogic:AnalyseCardWithoutKing(cbInCardData,bCardCount,AnalyseData)
	if ( AnalyseData.bTwoCount <= 0) then
		return 0;
	end
	for i = 1,2 do
		local index = AnalyseData.bTwoFirst[self.m_cbIndex]
		index = index + i - 1
		table.insert(cbOutCardIndex,index)
	end
	self.m_cbIndex = self.m_cbIndex + 1
	if self.m_cbIndex > AnalyseData.bTwoCount then
		self.m_cbIndex = 1
	end
	return 2;
end
--两对
function GameViewLayer:TwoDouble(cbInCardData,bCardCount,cbOutCardIndex)
	if (self.m_cbCardType ~= GameLogic.CT_FIVE_TWO_DOUBLE) then
		self.m_cbIndex = 1;
		self.m_cbIndexHelp = 2;
	end
	self.m_cbCardType = GameLogic.CT_FIVE_TWO_DOUBLE;
	local AnalyseData = {bOneCount = 0,bTwoCount = 0,bThreeCount = 0,
	  bFourCount = 0,bFiveCount=0,bWangCount=0,bOneFirst={},
	  bTwoFirst={},bThreeFirst={},bFourFirst={},bFiveFirst={},
	  bWangData={},bSameColorData={},bSameColorCount={},
	  bAllOne={},bAllOneCount={},bSameColor=0};
	GameLogic:AnalyseCardWithoutKing(cbInCardData,bCardCount,AnalyseData)
	if ( AnalyseData.bTwoCount < 1) then
		return 0;
	end
	for i = 1,2 do
		local index = AnalyseData.bTwoFirst[self.m_cbIndex]
		index = index + i - 1
		table.insert(cbOutCardIndex,index)
	end
	for i = 1,2 do
		local index = AnalyseData.bTwoFirst[self.m_cbIndexHelp]
		index = index + i - 1
		table.insert(cbOutCardIndex,index)
	end
	self.m_cbIndexHelp = self.m_cbIndexHelp + 1
	if self.m_cbIndexHelp > AnalyseData.bTwoCount then
		self.m_cbIndexHelp = 1
	end
	if (self.m_cbIndexHelp == 1) then
		self.m_cbIndex = self.m_cbIndex + 1
		if self.m_cbIndex > AnalyseData.bTwoCount then
			self.m_cbIndex = 1
		end
		local next1 = self.m_cbIndex + 1
		if next1 > AnalyseData.bTwoCount then
			next1 = 1
		end
		self.m_cbIndexHelp = next1
	end
	return 4;	
end
function GameViewLayer:ThreeSame(cbInCardData,bCardCount,cbOutCardIndex)
	if (self.m_cbCardType ~= GameLogic.CT_THREE) then
		self.m_cbIndex = 1;
	end
	self.m_cbCardType = GameLogic.CT_THREE;
	local AnalyseData = {bOneCount = 0,bTwoCount = 0,bThreeCount = 0,
	  bFourCount = 0,bFiveCount=0,bWangCount=0,bOneFirst={},
	  bTwoFirst={},bThreeFirst={},bFourFirst={},bFiveFirst={},
	  bWangData={},bSameColorData={},bSameColorCount={},
	  bAllOne={},bAllOneCount={},bSameColor=0};
	GameLogic:AnalyseCardWithoutKing(cbInCardData,bCardCount,AnalyseData)
	if ( AnalyseData.bThreeCount < 1) then
		return 0;
	end
	for i = 1,3 do
		local index = AnalyseData.bThreeFirst[self.m_cbIndex]
		index = index + i - 1
		table.insert(cbOutCardIndex,index)
	end
	self.m_cbIndex = self.m_cbIndex + 1
	if self.m_cbIndex > AnalyseData.bThreeCount then
		self.m_cbIndex = 1
	end
	return 3;
end

-- 铁支提示, 点击之后只会弹出4张一样的牌, 不会自动组成5张牌来啊弹出
function GameViewLayer:TieZi(cbInCardData,bCardCount,cbOutCardIndex)
	if (self.m_cbCardType ~= GameLogic.CT_FIVE_FOUR_ONE) then
		self.m_cbIndex = 1;
	end
	self.m_cbCardType = GameLogic.CT_FIVE_FOUR_ONE;
	local AnalyseData = {bOneCount = 0,bTwoCount = 0,bThreeCount = 0,
	  bFourCount = 0,bFiveCount=0,bWangCount=0,bOneFirst={},
	  bTwoFirst={},bThreeFirst={},bFourFirst={},bFiveFirst={},
	  bWangData={},bSameColorData={},bSameColorCount={},
	  bAllOne={},bAllOneCount={},bSameColor=0};
	GameLogic:AnalyseCardWithoutKing(cbInCardData,bCardCount,AnalyseData)

	-- change by Owen, 2018.5.6, 修复有王的铁支
	if ( AnalyseData.bFourCount >= 1) 
		or (AnalyseData.bThreeCount >= 1 and AnalyseData.bWangCount >= 1)
		or (AnalyseData.bTwoCount >= 1 and AnalyseData.bWangCount == 2) then
		
	else
		return 0;
	end

	-- 记录总共有几个铁支提示
	local allTieziCount = 0

	-- 插入4同张
	if ( AnalyseData.bFourCount >= 1) then
		for j = 1, AnalyseData.bFourCount do
			allTieziCount = allTieziCount + 1
			for i = 1,4 do
				local index = AnalyseData.bFourFirst[allTieziCount]
				index = index + i - 1
				table.insert(cbOutCardIndex,index)
			end
		end
	end
	
	-- 插入3同张和1张王
	if (AnalyseData.bThreeCount >= 1 and AnalyseData.bWangCount >= 1) then
		for j = 1, AnalyseData.bThreeCount do
			allTieziCount = allTieziCount + 1
			for i = 1,3 do
				local index = AnalyseData.bThreeFirst[allTieziCount]
				index = index + i - 1
				table.insert(cbOutCardIndex,index)
			end
			-- 插入王
			for i = 1,bCardCount do
				-- change by Owen, 2018.5.2, 查找同化的时候, 要把大小王单独插入进去
				if cbInCardData[i] == 0x41 or cbInCardData[i] == 0x42 then
					table.insert(cbOutCardIndex,i)
					break
				end
			end
		end
	end

	-- 插入2同张和2张王
	if (AnalyseData.bTwoCount >= 1 and AnalyseData.bWangCount == 2) then
		for j = 1, AnalyseData.bTwoCount do
			allTieziCount = allTieziCount + 1
			for i = 1,2 do
				local index = AnalyseData.bTwoFirst[allTieziCount]
				index = index + i - 1
				table.insert(cbOutCardIndex,index)
			end
			-- 插入王
			for i = 1,bCardCount do
				-- change by Owen, 2018.5.2, 查找同化的时候, 要把大小王单独插入进去
				if cbInCardData[i] == 0x41 or cbInCardData[i] == 0x42 then
					table.insert(cbOutCardIndex,i)
				end
			end
		end
	end

	self.m_cbIndex = self.m_cbIndex + 1
	-- if self.m_cbIndex > AnalyseData.bFourCount then
	if self.m_cbIndex > allTieziCount then
		self.m_cbIndex = 1
	end
	return 4;
end
function GameViewLayer:WuTong(cbInCardData,bCardCount,cbOutCardIndex)
	if (self.m_cbCardType ~= GameLogic.CT_WU_TONG) then
		self.m_cbIndex = 1;
	end
	self.m_cbCardType = GameLogic.CT_WU_TONG;
	local AnalyseData = {bOneCount = 0,bTwoCount = 0,bThreeCount = 0,
	  bFourCount = 0,bFiveCount=0,bWangCount=0,bOneFirst={},
	  bTwoFirst={},bThreeFirst={},bFourFirst={},bFiveFirst={},
	  bWangData={},bSameColorData={},bSameColorCount={},
	  bAllOne={},bAllOneCount={},bSameColor=0};
	GameLogic:AnalyseCardWithoutKing(cbInCardData,bCardCount,AnalyseData)


	if ((AnalyseData.bFourCount > 0 and AnalyseData.bWangCount >=1) 
		or AnalyseData.bFiveCount > 0 
		or (AnalyseData.bThreeCount > 0 and AnalyseData.bWangCount == 2)) then
    
    else
    	return 0;
	end

	local wuTongCnt = 0    -- 记录总共有几种五同组合
	for i = 1, AnalyseData.bFiveCount do
		wuTongCnt = wuTongCnt + 1
		cbOutCardIndex[wuTongCnt] = {}
		for j = 1,5 do
			local index = AnalyseData.bFiveFirst[i]
			index = index + j - 1
			table.insert(cbOutCardIndex[wuTongCnt],index)
		end
	end

	-- 1个王和4同张
	if AnalyseData.bWangCount >= 1 then
		for i = 1, AnalyseData.bFourCount do
			wuTongCnt = wuTongCnt + 1
			cbOutCardIndex[wuTongCnt] = {}
			for j = 1,4 do
				local index = AnalyseData.bFourFirst[i]
				index = index + j - 1
				table.insert(cbOutCardIndex[wuTongCnt],index)
			end

			-- 前面插入了4张一样的牌, 这里插入1个王
			for i1 = 1,bCardCount do
				-- change by Owen, 2018.5.2, 查找同化的时候, 要把大小王单独插入进去
				if (cbInCardData[i1] == 0x41 or cbInCardData[i1] == 0x42)
					and #cbOutCardIndex[wuTongCnt] < 5 then
					table.insert(cbOutCardIndex[wuTongCnt], i1)
				end
			end
		end
	end

	-- 2个王和3同张
	if AnalyseData.bWangCount >= 2 then
		for i = 1, AnalyseData.bThreeCount do
			wuTongCnt = wuTongCnt + 1
			cbOutCardIndex[wuTongCnt] = {}
			for j = 1,3 do
				local index = AnalyseData.bThreeFirst[i]
				index = index + j - 1
				table.insert(cbOutCardIndex[wuTongCnt],index)
			end

			-- 前面插入了3张一样的牌, 这里插入2个王
			for i1 = 1,bCardCount do
				-- change by Owen, 2018.5.2, 查找同化的时候, 要把大小王单独插入进去
				if (cbInCardData[i1] == 0x41 or cbInCardData[i1] == 0x42) then
					table.insert(cbOutCardIndex[wuTongCnt], i1)
				end
			end
		end
	end

	self.m_cbIndex = self.m_cbIndex + 1

	if self.m_cbIndex > wuTongCnt then
		self.m_cbIndex = 1
	end


	-- for i = 1,5 do
	-- 	local index = AnalyseData.bFiveFirst[self.m_cbIndex]
	-- 	index = index + i - 1
	-- 	table.insert(cbOutCardIndex,index)
	-- end
	-- self.m_cbIndex = self.m_cbIndex + 1
	-- if self.m_cbIndex > AnalyseData.bFiveCount then
	-- 	self.m_cbIndex = 1
	-- end

	return wuTongCnt;
end
function GameViewLayer:Hulu(cbInCardData,bCardCount,cbOutCardIndex)
	if (self.m_cbCardType ~= GameLogic.CT_FIVE_THREE_DEOUBLE) then
		self.m_cbIndex = 1;
		self.m_cbIndexHelp = 1;
		-- change by Owen, 2018.5.8, 记录有王的葫芦提示了几遍
		self.m_huluWithWangIndex = 1;
	end
	self.m_cbCardType = GameLogic.CT_FIVE_THREE_DEOUBLE;
	local AnalyseData = {bOneCount = 0,bTwoCount = 0,bThreeCount = 0,
	  bFourCount = 0,bFiveCount=0,bWangCount=0,bOneFirst={},
	  bTwoFirst={},bThreeFirst={},bFourFirst={},bFiveFirst={},
	  bWangData={},bSameColorData={},bSameColorCount={},
	  bAllOne={},bAllOneCount={},bSameColor=0};
	GameLogic:AnalyseCardWithoutKing(cbInCardData,bCardCount,AnalyseData)
	local bFound = false;
	if (AnalyseData.bThreeCount > 0) then
		if (AnalyseData.bTwoCount > 0) then
			for i = self.m_cbIndex,AnalyseData.bThreeCount do
				--拷贝索引
				for k = 1,3 do
					local index = AnalyseData.bThreeFirst[i]
					index = index + k - 1
					cbOutCardIndex[k] = index
				end
				for j = self.m_cbIndexHelp,AnalyseData.bTwoCount do
					--拷贝索引
					for m = 1,2 do
						local index = AnalyseData.bTwoFirst[j]
						index = index + m - 1
						table.insert(cbOutCardIndex,index)
					end
					bFound = true;
					self.m_cbIndexHelp = self.m_cbIndexHelp + 1
					self.m_cbIndex = i;
					break;
				end
				if (not bFound) then
					self.m_cbIndexHelp = 1;
				else
					break;
				end
			end
			if (not bFound) then
				self.m_cbIndex = 1;
			end
		elseif (AnalyseData.bThreeCount > 1) then
			for i = 1,AnalyseData.bThreeCount do
				local nIndex = i + self.m_cbIndex - 1
				if nIndex > AnalyseData.bThreeCount then
					nIndex = 1
				end
				--拷贝索引
				for k = 1,3 do
					local index = AnalyseData.bThreeFirst[nIndex]
					index = index + k - 1
					cbOutCardIndex[k] = index
				end
				for j = self.m_cbIndexHelp,AnalyseData.bThreeCount do
					if nIndex ~= j then
						--拷贝索引
						for m = 1,2 do
							local index = AnalyseData.bThreeFirst[j]
							index = index + m - 1
							table.insert(cbOutCardIndex,index)
						end
						bFound = true;
						self.m_cbIndexHelp = j + 1;
						self.m_cbIndex = nIndex;
						break;
					end
				end
				if (not bFound) then
					-- self.m_cbIndexHelp = 1;
				else
					break;
				end
			end
			if (not bFound) then
				-- self.m_cbIndex = 1;
			end
		end
	end

	-- change by Owen, 2018.5.7, 添加有王的处理
	if not bFound then
		if AnalyseData.bTwoCount >= 2 and AnalyseData.bWangCount >= 1 then
			local bFoundWithWang = false
			for i = self.m_huluWithWangIndex, AnalyseData.bTwoCount do
				--拷贝索引
				for k = 1,2 do
					local index = AnalyseData.bTwoFirst[i]
					index = index + k - 1
					cbOutCardIndex[k] = index
				end
				-- 插入一个王
				for i = 1,bCardCount do
					-- change by Owen, 2018.5.7, 查找铁支的时候, 要把大小王单独插入进去
					if cbInCardData[i] == 0x41 or cbInCardData[i] == 0x42 then
						table.insert(cbOutCardIndex,i)
						break
					end
				end

				for j = i,AnalyseData.bTwoCount do
					if (j ~= i) then
						--拷贝索引
						for m = 1,2 do
							local index = AnalyseData.bTwoFirst[j]
							index = index + m - 1
							table.insert(cbOutCardIndex,index)
						end
						bFound = true;
						self.m_cbIndexHelp = self.m_cbIndexHelp + 1
						break;
					end
				end
				self.m_cbIndex = self.m_cbIndex + 1;
				self.m_huluWithWangIndex = self.m_huluWithWangIndex + 1;
				bFoundWithWang = true
				break;
			end
			if not bFoundWithWang then
				self.m_cbIndexHelp = 1;
				self.m_cbIndex = 1;
				self.m_huluWithWangIndex = 1;
			end
		else
			-- change by Owen, 2018.5.8, 如果算上王的时候也不符合, 那么要还原这两个参数
			self.m_cbIndexHelp = 1;
			self.m_cbIndex = 1;
		end
	end

	if bFound then
		return 5;
	else
		return 0;
	end
	return 0;
end
function GameViewLayer:TongHua(cbInCardData,bCardCount,cbOutCardIndex)
	if (self.m_cbCardType ~= GameLogic.CT_FIVE_FLUSH) then
		self.m_cbIndex = 1;
		self.m_cbIndexHelp = 1;
		self.m_cbIndexColor = 1
	end
	self.m_cbCardType = GameLogic.CT_FIVE_FLUSH;
	local AnalyseData = {bOneCount = 0,bTwoCount = 0,bThreeCount = 0,
	  bFourCount = 0,bFiveCount=0,bWangCount=0,bOneFirst={},
	  bTwoFirst={},bThreeFirst={},bFourFirst={},bFiveFirst={},
	  bWangData={},bSameColorData={},bSameColorCount={},
	  bAllOne={},bAllOneCount={},bSameColor=0};
	GameLogic:AnalyseCardWithoutKing(cbInCardData,bCardCount,AnalyseData)
	local index = 1
	for i=0,3 do
		index = self.m_cbIndexColor + i
		if index > 4 then
			index = index - 4
		end
        if (AnalyseData.bSameColorCount[index] + AnalyseData.bWangCount >= 5) then
			self.m_cbIndexColor = index
			break
		end
    end
	local ArrayIndex = {}
	for i = 1,bCardCount do
		-- change by Owen, 2018.5.2, 查找同化的时候, 要把大小王单独插入进去
		if cbInCardData[i] == 0x41 or cbInCardData[i] == 0x42 then
			table.insert(ArrayIndex,i)
		elseif GameLogic:GetCardColor(cbInCardData[i]) + 1 == self.m_cbIndexColor then
			table.insert(ArrayIndex,i)
		end
	end


	local count = #ArrayIndex - 4
	local AllZuHe = {} --所有组合
	for i = 1,count do
		AllZuHe[i] = {}
		for j = 1,5 do
			table.insert(AllZuHe[i],ArrayIndex[i+j-1])
		end
	end
	local tempIndex = self.m_cbIndex
	if self.m_cbIndex > count then
		self.m_cbIndex = 1
		self.m_cbIndexColor = self.m_cbIndexColor + 1
		if self.m_cbIndexColor > 4 then
			self.m_cbIndexColor = 1
		end
		for i=0,3 do
			index = self.m_cbIndexColor + i
			if index > 4 then
				index = index - 4
			end
			if (AnalyseData.bSameColorCount[index] + AnalyseData.bWangCount >= 5) then
				self.m_cbIndexColor = index
				break
			end
		end
		ArrayIndex = {}
		for i = 1,bCardCount do
			-- change by Owen, 2018.5.2, 查找同化的时候, 要把大小王单独插入进去
			if cbInCardData[i] == 0x41 or cbInCardData[i] == 0x42 then
				table.insert(ArrayIndex,i)
			elseif GameLogic:GetCardColor(cbInCardData[i]) + 1 == self.m_cbIndexColor then
				table.insert(ArrayIndex,i)
			end
		end
		local count = #ArrayIndex - 4
		AllZuHe = {} --所有组合
		for i = 1,count do
			AllZuHe[i] = {}
			for j = 1,5 do
				table.insert(AllZuHe[i],ArrayIndex[i+j-1])
			end
		end
	end
	for i = 1,#AllZuHe[self.m_cbIndex] do
		table.insert(cbOutCardIndex,AllZuHe[self.m_cbIndex][i])
	end
	self.m_cbIndex = self.m_cbIndex + 1
	
	return 0
end
-- function GameViewLayer:ShunZi(cbInCardData,bCardCount,cbOutCardData)
-- 	if (self.m_cbCardType ~= GameLogic.CT_FIVE_MIXED_FLUSH_NO_A) then
-- 		self.cbShunZiBegin = 2;
-- 		self.cbShnuZiEnd = 1;
-- 		self.cbStraightCount = 0;
-- 		self.bSetShunZiBegin = false;
-- 		self.cbKingLeftCount = 0;
-- 		self.m_cbCardType = GameLogic.CT_FIVE_MIXED_FLUSH_NO_A;
-- 		GameLogic:AnalysebCardDataDistributing(cbInCardData,bCardCount,self.Distributing)
-- 	end
-- 	self.cbStraightCount = 0;
-- 	--获取最大顺子的头跟尾
-- 	self.cbKingLeftCount = self.Distributing.cbCardCount[1];
-- 	local bFound = false;
-- 	self.bSetShunZiBegin = false;
-- 	local temppp = self.Distributing
	
-- 	for i = self.cbShunZiBegin, 14 do
-- 		if self.Distributing.cbCardCount[i] > 0 and not self.bSetShunZiBegin then
-- 			self.cbShunZiBegin = i;
-- 			self.bSetShunZiBegin = true;
-- 			cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[i][1];
-- 			self.cbStraightCount = self.cbStraightCount + 1
-- 		elseif (self.Distributing.cbCardCount[i] > 0) then
-- 			self.cbShnuZiEnd = i
-- 			cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[i][1];
-- 			self.cbStraightCount = self.cbStraightCount + 1
-- 			if (self.cbShnuZiEnd - self.cbShunZiBegin >= 4) then
-- 				bFound = true;
-- 				break;
-- 			elseif (self.cbShnuZiEnd >= 0x0d) then
-- 				if (self.cbShnuZiEnd == 0x0e and self.cbShunZiBegin == 11 and self.Distributing.cbCardCount[2] > 0) then
-- 					cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[2][1];
-- 					self.cbStraightCount = self.cbStraightCount + 1
-- 					if (self.cbStraightCount == 5) then
-- 						bFound = true;
-- 						break;
-- 					end
-- 				elseif (self.cbShunZiBegin == 0x0c and cbShnuZiEnd == 0x0e and Distributing.cbCardCount[2] > 0) then
-- 					if (self.cbKingLeftCount >= 1)  then
-- 						local nKingTotalCount = self.Distributing.cbCardCount[1];
-- 						cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[2][1];
-- 						self.cbStraightCount = self.cbStraightCount + 1
-- 						cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[1][nKingTotalCount - nKingTotalCount + 1];
-- 						self.cbStraightCount = self.cbStraightCount + 1
-- 						self.cbKingLeftCount = self.cbKingLeftCount - 1
-- 						if (cbStraightCount == 5) then
-- 							bFound = true;
-- 							break;
-- 						end
-- 					end
-- 				elseif (self.cbShunZiBegin == 0x0b and self.cbShnuZiEnd == 0x0d and self.Distributing.cbCardCount[2] > 0) then
-- 					if (self.cbKingLeftCount >= 1) then
-- 						local nKingTotalCount = self.Distributing.cbCardCount[1];
-- 						cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[2][1];
-- 						self.cbStraightCount = self.cbStraightCount + 1
-- 						cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[1][nKingTotalCount - nKingTotalCount + 1];
-- 						self.cbStraightCount = self.cbStraightCount + 1
-- 						self.cbKingLeftCount = self.cbKingLeftCount - 1
-- 						if (self.cbStraightCount == 5) then
-- 							bFound = true;
-- 							break;
-- 						end
-- 					end
-- 				elseif (self.cbShunZiBegin == 0x0b and self.cbShnuZiEnd == 0x0e and self.Distributing.cbCardCount[2] > 0) then
-- 					if (self.cbKingLeftCount >= 1) then
-- 						local nKingTotalCount = self.Distributing.cbCardCount[1];
-- 						cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[2][1];
-- 						self.cbStraightCount = self.cbStraightCount + 1
-- 						cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[1][nKingTotalCount - nKingTotalCount + 1];
-- 						self.cbStraightCount = self.cbStraightCount + 1
-- 						self.cbKingLeftCount = self.cbKingLeftCount - 1 ;
-- 						if (self.cbStraightCount == 5) then
-- 							bFound = true;
-- 							break;
-- 						end
-- 					end
-- 				elseif (self.cbKingLeftCount >= 1) then
-- 					if(self.cbShunZiBegin == 0x0b and self.cbShnuZiEnd == 0x0e) then
-- 						local nKingTotalCount = self.Distributing.cbCardCount[1];
-- 						cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[1][nKingTotalCount - nKingTotalCount + 1];
-- 						self.cbStraightCount = self.cbStraightCount + 1
-- 						self.cbKingLeftCount = self.cbKingLeftCount - 1;
-- 						if (self.cbStraightCount == 5) then
-- 							bFound = true;
-- 							break;
-- 						end
-- 					end
-- 				end
-- 			end
-- 		elseif (self.Distributing.cbCardCount[i] == 0 and self.bSetShunZiBegin ~= 0) then
-- 			if (self.cbKingLeftCount > 0) then
-- 				self.cbShnuZiEnd = i;
-- 				self.cbKingLeftCount = self.cbKingLeftCount - 1;
-- 				cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[1][self.cbKingLeftCount + 1];
-- 				self.cbStraightCount = self.cbStraightCount + 1
-- 				if (self.cbStraightCount >= 5) then
-- 					bFound = true;
-- 					break;
-- 				end
-- 			else
-- 				if (self.cbStraightCount >= 5) then
-- 					bFound = true;
-- 					break;
-- 				else
-- 					self.bSetShunZiBegin = false;
-- 					if (self.cbStraightCount == 2) then
-- 						if (cbOutCardData[2] ~= 0x41 and cbOutCardData[2] ~= 0x42) then
-- 							self.cbShunZiBegin = GameLogic:GetCardValue(cbOutCardData[2]) + 1;
-- 							local cbTemp = {};
-- 							for j = 1,self.cbStraightCount - 1 do
-- 								cbTemp[j] = cbOutCardData[j]
-- 							end
-- 							for j = 1,#cbOutCardData do
-- 								cbOutCardData[j] = 0
-- 							end
-- 							for j = 1,self.cbStraightCount - 1 do
-- 								cbOutCardData[j + 1] =cbTemp[j] 
-- 							end
-- 							--CopyMemory(cbTemp,cbOutCardData,cbStraightCount - 1);
-- 							--ZeroMemory(cbOutCardData,sizeof(cbOutCardData));
-- 							--CopyMemory(cbOutCardData + 1,cbTemp,cbStraightCount - 1);
-- 							self.cbStraightCount = self.cbStraightCount - 1;
-- 							self.cbShnuZiEnd = 1;
-- 							self.bSetShunZiBegin = false;
-- 							i = i - 1;
-- 						else
-- 							self.bSetShunZiBegin = false;
-- 							self.cbShunZiBegin = 2;
-- 							self.cbShnuZiEnd = 1;
-- 							self.cbStraightCount = 0;
-- 							self.cbKingLeftCount = self.Distributing.cbCardCount[1];
-- 							self.cbKingLeftCount = self.Distributing.cbCardCount[1];
-- 							for j = 1,#cbOutCardData do
-- 								cbOutCardData[j] = 0
-- 							end
-- 							--ZeroMemory(cbOutCardData,MAX_CARD_COUNT);
-- 						end
-- 					elseif (self.cbStraightCount > 2) then
-- 						if ((cbOutCardData[2] == 0x41 or cbOutCardData[2] == 0x42) and
-- 							(cbOutCardData[3] == 0x41 or cbOutCardData[3] == 0x42)) then
-- 							self.cbShunZiBegin = GameLogic:GetCardValue(cbOutCardData[2]) + 1;
-- 							self.bSetShunZiBegin = false;
-- 							self.cbShunZiBegin = 2;
-- 							self.cbShnuZiEnd = 1;
-- 							self.cbStraightCount = 0;
-- 							self.cbKingLeftCount = self.cbKingLeftCount + 2;
-- 							i = i - 1;
-- 							for j = 1,#cbOutCardData do
-- 								cbOutCardData[j] = 0
-- 							end
-- 							--ZeroMemory(cbOutCardData,MAX_CARD_COUNT);
-- 						elseif (cbOutCardData[2] == 0x41 or cbOutCardData[2] == 0x42) then
-- 							--[[cbShunZiBegin = m_gameLogic.GetCardValue(cbOutCardData[2]);
-- 							BYTE cbTemp[MAX_COUNT] = { 0 };
-- 							CopyMemory(cbTemp,cbOutCardData + 2,cbStraightCount - 2);
-- 							ZeroMemory(cbOutCardData,sizeof(cbOutCardData));
-- 							CopyMemory(cbOutCardData,cbTemp,cbStraightCount - 2);
-- 							cbStraightCount -= 2;
-- 							++cbKingLeftCount;
-- 							cbShnuZiEnd = 0;
-- 							--i;
-- 							bSetShunZiBegin = true;--]]
-- 						else
-- 							self.cbShunZiBegin = GameLogic:GetCardValue(cbOutCardData[2]) + 1;
-- 							local cbTemp = { };
-- 							--CopyMemory(cbTemp,cbOutCardData + 1,cbStraightCount - 1);
-- 							for j = 1,self.cbStraightCount - 1 do
-- 								cbTemp[j] = cbOutCardData[j + 1]
-- 							end
-- 							--ZeroMemory(cbOutCardData,sizeof(cbOutCardData));
-- 							for j = 1,#cbOutCardData do
-- 								cbOutCardData[j] = 0
-- 							end
-- 							i = i - (self.cbStraightCount - 1);
-- 							--CopyMemory(cbOutCardData,cbTemp,cbStraightCount - 1);
-- 							for j = 1,self.cbStraightCount - 1 do
-- 								cbOutCardData[j] =cbTemp[j] 
-- 							end
-- 							self.cbStraightCount = 0;
-- 							self.cbShnuZiEnd = 1;
-- 							self.bSetShunZiBegin = false;
-- 							self.cbKingLeftCount = self.Distributing.cbCardCount[1];
-- 						end
-- 					else
-- 						self.bSetShunZiBegin = false;
-- 						self.cbShunZiBegin = 2;
-- 						self.cbShnuZiEnd = 1;
-- 						self.cbStraightCount = 0;
-- 						self.cbKingLeftCount = self.Distributing.cbCardCount[1];
-- 						self.cbKingLeftCount = self.Distributing.cbCardCount[1];
-- 						--ZeroMemory(cbOutCardData,MAX_CARD_COUNT);
-- 						for j = 1,#cbOutCardData do
-- 							cbOutCardData[j] = 0
-- 						end
-- 					end
-- 				end				
				
-- 			end
-- 		else
-- 			print("--------")	
-- 		end
-- 	end
--     local n1=0
--     for j = 1,#cbOutCardData do
-- 		if cbOutCardData[j] >0 then
--         n1=n1+1
--         end
-- 	end
--      if n1>=5 then
--         bFound=true
--      end
-- 	if (bFound) then
-- 		if(self.cbShunZiBegin >= 11) then
-- 			self.cbShunZiBegin = 2;
-- 		else
-- 			self.cbShunZiBegin = self.cbShunZiBegin + 1
-- 		end
-- 		return self.cbStraightCount;
-- 	else
-- 		self.cbShunZiBegin = 2;
-- 		self.cbShnuZiEnd = 1;
-- 		self.cbStraightCount = 0;
-- 		self.bSetShunZiBegin = false;
-- 		self.cbKingLeftCount = 0;
-- 		return 0;
-- 	end
-- end

-- 最终找出来的顺子数据是放到 cbOutCardData 里面
-- self.Distributing.cbCardCount[i]          这张牌有几张
-- self.Distributing.cbDistributing[i][1]    获得2这张牌的第一张
function GameViewLayer:ShunZi(cbInCardData,bCardCount,cbOutCardData)
	if (self.m_cbCardType ~= GameLogic.CT_FIVE_MIXED_FLUSH_NO_A) then
		self.cbShunZiBegin = 1;
		self.cbShnuZiEnd = 1;
		self.cbStraightCount = 0;
		self.bSetShunZiBegin = false;
		self.cbKingLeftCount = 0;
		self.m_cbCardType = GameLogic.CT_FIVE_MIXED_FLUSH_NO_A;
		GameLogic:AnalysebCardDataDistributing(cbInCardData,bCardCount,self.Distributing)
	end

	--[[ 
	    表示自己手里有两个A, 一个K
	    self.Distributing = {
	        cbCardCount =    {2,0,..,{1}}
	        cbDistributing = {{1,17},{},..,{13}}
	    }
	]]

	-- 找到的所有顺子存到这个表里面
	local allShunZi = {}

	local kingCount = self.Distributing.cbCardCount[0]

	local bFound = false
	local beginIndex = self.cbShunZiBegin
	for i = beginIndex, 10 do
		-- 拿出从i开始往后的5个数的组合, 如A2345这五张牌, 自己手里有几张
		local haveCount = 0
		for k = 0,4 do
			if self.Distributing.cbCardCount[i+k] > 0 then
				haveCount = haveCount + 1
			end
		end

		
		if haveCount == 5 then
			-- 有五张不需要王的顺子
			for j = 0,4 do
				cbOutCardData[j+1] = self.Distributing.cbDistributing[i+j][1]
			end
			self.cbShunZiBegin = i + 1
			bFound = true
		elseif haveCount == 4 and kingCount >= 1 then
			-- 插入4张牌
			for j1 = 0,4 do
				if self.Distributing.cbCardCount[i+j1] > 0 then
					cbOutCardData[#cbOutCardData+1] = self.Distributing.cbDistributing[i+j1][1]
				end
			end
			-- 插入一个王
			cbOutCardData[5] = self.Distributing.cbDistributing[0][1]
			self.cbShunZiBegin = i + 1
			bFound = true
		elseif haveCount == 3 and kingCount >= 2 then
			-- 插入3张牌
			for j1 = 0,4 do
				if self.Distributing.cbCardCount[i+j1] > 0 then
					cbOutCardData[#cbOutCardData+1] = self.Distributing.cbDistributing[i+j1][1]
				end
			end
			-- 插入2个王
			cbOutCardData[4] = self.Distributing.cbDistributing[0][1]
			cbOutCardData[5] = self.Distributing.cbDistributing[0][2]
			self.cbShunZiBegin = i + 1
			bFound = true
		end

		-- 如果找到了则跳出这个循环
		if bFound then
			break
		end
	end

	if (bFound) then
		if(self.cbShunZiBegin > 10) then
			self.cbShunZiBegin = 1;
		else
			-- self.cbShunZiBegin = self.cbShunZiBegin + 1
		end
		return 1;
	else
		self.cbShunZiBegin = 1;
		self.cbShnuZiEnd = 1;
		self.cbStraightCount = 0;
		self.bSetShunZiBegin = false;
		self.cbKingLeftCount = 0;
		return 0;
	end


	--[[
		self.cbStraightCount = 0;
		--获取最大顺子的头跟尾
		self.cbKingLeftCount = self.Distributing.cbCardCount[1];
		local bFound = false;
		self.bSetShunZiBegin = false;
		local temppp = self.Distributing
		
		for i = self.cbShunZiBegin, 14 do
			if self.Distributing.cbCardCount[i] > 0 and not self.bSetShunZiBegin then
				self.cbShunZiBegin = i;
				self.bSetShunZiBegin = true;
				cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[i][1];
				self.cbStraightCount = self.cbStraightCount + 1
			elseif (self.Distributing.cbCardCount[i] > 0) then
				self.cbShnuZiEnd = i
				cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[i][1];
				self.cbStraightCount = self.cbStraightCount + 1
				if (self.cbShnuZiEnd - self.cbShunZiBegin >= 4) then
					bFound = true;
					break;
				elseif (self.cbShnuZiEnd >= 0x0d) then
					if (self.cbShnuZiEnd == 0x0e and self.cbShunZiBegin == 11 and self.Distributing.cbCardCount[2] > 0) then
						cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[2][1];
						self.cbStraightCount = self.cbStraightCount + 1
						if (self.cbStraightCount == 5) then
							bFound = true;
							break;
						end
					elseif (self.cbShunZiBegin == 0x0c and cbShnuZiEnd == 0x0e and Distributing.cbCardCount[2] > 0) then
						if (self.cbKingLeftCount >= 1)  then
							local nKingTotalCount = self.Distributing.cbCardCount[1];
							cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[2][1];
							self.cbStraightCount = self.cbStraightCount + 1
							cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[1][nKingTotalCount - nKingTotalCount + 1];
							self.cbStraightCount = self.cbStraightCount + 1
							self.cbKingLeftCount = self.cbKingLeftCount - 1
							if (cbStraightCount == 5) then
								bFound = true;
								break;
							end
						end
					elseif (self.cbShunZiBegin == 0x0b and self.cbShnuZiEnd == 0x0d and self.Distributing.cbCardCount[2] > 0) then
						if (self.cbKingLeftCount >= 1) then
							local nKingTotalCount = self.Distributing.cbCardCount[1];
							cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[2][1];
							self.cbStraightCount = self.cbStraightCount + 1
							cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[1][nKingTotalCount - nKingTotalCount + 1];
							self.cbStraightCount = self.cbStraightCount + 1
							self.cbKingLeftCount = self.cbKingLeftCount - 1
							if (self.cbStraightCount == 5) then
								bFound = true;
								break;
							end
						end
					elseif (self.cbShunZiBegin == 0x0b and self.cbShnuZiEnd == 0x0e and self.Distributing.cbCardCount[2] > 0) then
						if (self.cbKingLeftCount >= 1) then
							local nKingTotalCount = self.Distributing.cbCardCount[1];
							cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[2][1];
							self.cbStraightCount = self.cbStraightCount + 1
							cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[1][nKingTotalCount - nKingTotalCount + 1];
							self.cbStraightCount = self.cbStraightCount + 1
							self.cbKingLeftCount = self.cbKingLeftCount - 1 ;
							if (self.cbStraightCount == 5) then
								bFound = true;
								break;
							end
						end
					elseif (self.cbKingLeftCount >= 1) then
						if(self.cbShunZiBegin == 0x0b and self.cbShnuZiEnd == 0x0e) then
							local nKingTotalCount = self.Distributing.cbCardCount[1];
							cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[1][nKingTotalCount - nKingTotalCount + 1];
							self.cbStraightCount = self.cbStraightCount + 1
							self.cbKingLeftCount = self.cbKingLeftCount - 1;
							if (self.cbStraightCount == 5) then
								bFound = true;
								break;
							end
						end
					end
				end
			elseif (self.Distributing.cbCardCount[i] == 0 and self.bSetShunZiBegin ~= 0) then
				if (self.cbKingLeftCount > 0) then
					self.cbShnuZiEnd = i;
					self.cbKingLeftCount = self.cbKingLeftCount - 1;
					cbOutCardData[self.cbStraightCount + 1] = self.Distributing.cbDistributing[1][self.cbKingLeftCount + 1];
					self.cbStraightCount = self.cbStraightCount + 1
					if (self.cbStraightCount >= 5) then
						bFound = true;
						break;
					end
				else
					if (self.cbStraightCount >= 5) then
						bFound = true;
						break;
					else
						self.bSetShunZiBegin = false;
						if (self.cbStraightCount == 2) then
							if (cbOutCardData[2] ~= 0x41 and cbOutCardData[2] ~= 0x42) then
								self.cbShunZiBegin = GameLogic:GetCardValue(cbOutCardData[2]) + 1;
								local cbTemp = {};
								for j = 1,self.cbStraightCount - 1 do
									cbTemp[j] = cbOutCardData[j]
								end
								for j = 1,#cbOutCardData do
									cbOutCardData[j] = 0
								end
								for j = 1,self.cbStraightCount - 1 do
									cbOutCardData[j + 1] =cbTemp[j] 
								end
								--CopyMemory(cbTemp,cbOutCardData,cbStraightCount - 1);
								--ZeroMemory(cbOutCardData,sizeof(cbOutCardData));
								--CopyMemory(cbOutCardData + 1,cbTemp,cbStraightCount - 1);
								self.cbStraightCount = self.cbStraightCount - 1;
								self.cbShnuZiEnd = 1;
								self.bSetShunZiBegin = false;
								i = i - 1;
							else
								self.bSetShunZiBegin = false;
								self.cbShunZiBegin = 2;
								self.cbShnuZiEnd = 1;
								self.cbStraightCount = 0;
								self.cbKingLeftCount = self.Distributing.cbCardCount[1];
								self.cbKingLeftCount = self.Distributing.cbCardCount[1];
								for j = 1,#cbOutCardData do
									cbOutCardData[j] = 0
								end
								--ZeroMemory(cbOutCardData,MAX_CARD_COUNT);
							end
						elseif (self.cbStraightCount > 2) then
							if ((cbOutCardData[2] == 0x41 or cbOutCardData[2] == 0x42) and
								(cbOutCardData[3] == 0x41 or cbOutCardData[3] == 0x42)) then
								self.cbShunZiBegin = GameLogic:GetCardValue(cbOutCardData[2]) + 1;
								self.bSetShunZiBegin = false;
								self.cbShunZiBegin = 2;
								self.cbShnuZiEnd = 1;
								self.cbStraightCount = 0;
								self.cbKingLeftCount = self.cbKingLeftCount + 2;
								i = i - 1;
								for j = 1,#cbOutCardData do
									cbOutCardData[j] = 0
								end
								--ZeroMemory(cbOutCardData,MAX_CARD_COUNT);
							elseif (cbOutCardData[2] == 0x41 or cbOutCardData[2] == 0x42) then
								-- cbShunZiBegin = m_gameLogic.GetCardValue(cbOutCardData[2]);
								-- BYTE cbTemp[MAX_COUNT] = { 0 };
								-- CopyMemory(cbTemp,cbOutCardData + 2,cbStraightCount - 2);
								-- ZeroMemory(cbOutCardData,sizeof(cbOutCardData));
								-- CopyMemory(cbOutCardData,cbTemp,cbStraightCount - 2);
								-- cbStraightCount -= 2;
								-- ++cbKingLeftCount;
								-- cbShnuZiEnd = 0;
								-- --i;
								-- bSetShunZiBegin = true;
							else
								self.cbShunZiBegin = GameLogic:GetCardValue(cbOutCardData[2]) + 1;
								local cbTemp = { };
								--CopyMemory(cbTemp,cbOutCardData + 1,cbStraightCount - 1);
								for j = 1,self.cbStraightCount - 1 do
									cbTemp[j] = cbOutCardData[j + 1]
								end
								--ZeroMemory(cbOutCardData,sizeof(cbOutCardData));
								for j = 1,#cbOutCardData do
									cbOutCardData[j] = 0
								end
								i = i - (self.cbStraightCount - 1);
								--CopyMemory(cbOutCardData,cbTemp,cbStraightCount - 1);
								for j = 1,self.cbStraightCount - 1 do
									cbOutCardData[j] =cbTemp[j] 
								end
								self.cbStraightCount = 0;
								self.cbShnuZiEnd = 1;
								self.bSetShunZiBegin = false;
								self.cbKingLeftCount = self.Distributing.cbCardCount[1];
							end
						else
							self.bSetShunZiBegin = false;
							self.cbShunZiBegin = 2;
							self.cbShnuZiEnd = 1;
							self.cbStraightCount = 0;
							self.cbKingLeftCount = self.Distributing.cbCardCount[1];
							self.cbKingLeftCount = self.Distributing.cbCardCount[1];
							--ZeroMemory(cbOutCardData,MAX_CARD_COUNT);
							for j = 1,#cbOutCardData do
								cbOutCardData[j] = 0
							end
						end
					end				
					
				end
			else
				print("--------")	
			end
		end
	    local n1=0
	    for j = 1,#cbOutCardData do
			if cbOutCardData[j] >0 then
	        n1=n1+1
	        end
		end
	     if n1>=5 then
	        bFound=true
	     end

		if (bFound) then
			if(self.cbShunZiBegin >= 11) then
				self.cbShunZiBegin = 1;
			else
				self.cbShunZiBegin = self.cbShunZiBegin + 1
			end
			return self.cbStraightCount;
		else
			self.cbShunZiBegin = 1;
			self.cbShnuZiEnd = 1;
			self.cbStraightCount = 0;
			self.bSetShunZiBegin = false;
			self.cbKingLeftCount = 0;
			return 0;
		end
	]]

end


function GameViewLayer:TongHuaShun(cbInCardData,bCardCount,cbOutCardData)
	if (self.m_cbCardType ~= GameLogic.CT_FIVE_STRAIGHT_FLUSH) then
		self.m_cbIndex = 1;
	end
	self.m_cbCardType = GameLogic.CT_FIVE_STRAIGHT_FLUSH;
	-- change by Owen, 2018.5.4, 添加王的处理
	local AnalyseResult = {cbCardCount = {},cbDistributing = {}, cbKingData = {}}
	AnalyseResult.cbKingCount = 0
	
	for i =1 ,4 do
		AnalyseResult.cbCardCount[i] = 0
		AnalyseResult.cbDistributing[i] = {}
		for j = 1,cmd.HAND_CARD_COUNT do
			AnalyseResult.cbDistributing[i][j] = 0
		end
	end
	GameLogic:AnalysebCardColorDistri(cbInCardData,bCardCount,AnalyseResult)
	--存放大于5张的牌数据
	local cccount = 0
	-- cardData 存放的是这个花色的扑克牌有几张
	local cardData = {}
	for i = 1, 4 do
		cardData[i] = {}
		if AnalyseResult.cbCardCount[i] >= 3 then
			for j = 1,AnalyseResult.cbCardCount[i] do
				local temp = AnalyseResult.cbDistributing[i][j]
				if not self:FindValue(cardData[i],temp) then
					table.insert(cardData[i],temp)
				end
			end
			cccount = cccount + 1
		end
	end
	-- if cccount == 0 then
	-- 	return 0
	-- end
	local AllCardData = {}

	
	for i = 1,4 do
		if #cardData[i] >= 5 then
			-- 处理没有王的时候, 获得5张同花顺
			for j = 1,#cardData[i] - 4 do --循环次数=牌数减去4
				local temp1 = GameLogic:GetCardLogicValue(cardData[i][j])
				local temp2 = GameLogic:GetCardLogicValue(cardData[i][1 + j])
				local temp3 = GameLogic:GetCardLogicValue(cardData[i][2 + j])
				local temp4 = GameLogic:GetCardLogicValue(cardData[i][3 + j])
				local temp5 = GameLogic:GetCardLogicValue(cardData[i][4 + j])
				if temp1 ~= 14 then
					-- 处理没有A的情况
					-- 下面的这个判定逻辑是基于 cardData 是有序的, 从AKQ-32这样排列
					if temp1 == (temp2 + 1) and temp1 == (temp3 + 2) and
					temp1 == (temp4 + 3) and temp1 == (temp5 + 4)
					then
						for k = 1,5 do
							table.insert(AllCardData,cardData[i][j + k - 1])
						end
					end
				else
					if (temp2 == 5 and temp3 == 4 and temp4 == 3 and temp5 == 2)
						or (temp2 == 13 and temp3 == 12 and temp4 == 11 and temp5 == 10) then
						for k = 1,5 do
							table.insert(AllCardData,cardData[i][j + k - 1])
						end
					end
				end
			end
		end

		if #cardData[i] + AnalyseResult.cbKingCount >= 5 then
			-- 考虑只插入一个王的情况
			for j = 1,#cardData[i] - 3 do --循环次数=牌数减去4
				local temp1 = GameLogic:GetCardLogicValue(cardData[i][j])
				local temp2 = GameLogic:GetCardLogicValue(cardData[i][1 + j])
				local temp3 = GameLogic:GetCardLogicValue(cardData[i][2 + j])
				local temp4 = GameLogic:GetCardLogicValue(cardData[i][3 + j])

				if AnalyseResult.cbKingCount >= 1 then
					if temp1 ~= 14 then
						-- 处理没有A的情况
						if temp1 ~= temp2 and temp1 ~= temp3 and temp1 ~= temp4
							and temp2 ~= temp3 and temp2 ~= temp4
							and temp3 ~= temp4
							and temp1 - temp4 <= 4
						then
							for k = 1,4 do
								table.insert(AllCardData,cardData[i][j + k - 1])
							end
							-- 插入一个王
							table.insert(AllCardData,AnalyseResult.cbKingData[1])
						end
					else
						if (temp1 ~= temp2 and temp1 ~= temp3 and temp1 ~= temp4
							and temp2 ~= temp3 and temp2 ~= temp4
							and temp3 ~= temp4)
							and (temp2 <= 5 or temp4 >= 10)
						then
							for k = 1,4 do
								table.insert(AllCardData,cardData[i][j + k - 1])
							end
							-- 插入一个王
							table.insert(AllCardData,AnalyseResult.cbKingData[1])
						end
					end
				end
			end

			-- 考虑插入两个王的情况
			if AnalyseResult.cbKingCount == 2 then
				for j = 1,#cardData[i] - 2 do --循环次数=牌数减去4
					local temp1 = GameLogic:GetCardLogicValue(cardData[i][j])
					local temp2 = GameLogic:GetCardLogicValue(cardData[i][1 + j])
					local temp3 = GameLogic:GetCardLogicValue(cardData[i][2 + j])

					if temp1 ~= 14 then
						-- 处理没有A的情况
						if temp1 ~= temp2 and temp1 ~= temp3
							and temp2 ~= temp3
							and temp1 - temp3 <= 4
						then
							for k = 1,3 do
								table.insert(AllCardData,cardData[i][j + k - 1])
							end
							-- 插入2个王
							table.insert(AllCardData,AnalyseResult.cbKingData[1])
							table.insert(AllCardData,AnalyseResult.cbKingData[2])
						end
					else
						-- 处理没有A的情况
						if (temp1 ~= temp2 and temp1 ~= temp3
								and temp2 ~= temp3)
							and (temp2 <= 5 or temp3 >= 10)
						then
							for k = 1,3 do
								table.insert(AllCardData,cardData[i][j + k - 1])
							end
							-- 插入2个王
							table.insert(AllCardData,AnalyseResult.cbKingData[1])
							table.insert(AllCardData,AnalyseResult.cbKingData[2])
						end
					end
				end
			end
		end
	end

		
	local count = #AllCardData / 5 --有多少种可能
	local index = self.m_cbIndex
	if index > count then
		index = 1
	end
	for j = 1,5 do
		cbOutCardData[j] = AllCardData[(index - 1) * 5 + j]
	end
		
	self.m_cbIndex = self.m_cbIndex + 1
	if self.m_cbIndex > count then
		self.m_cbIndex = 1
	end
	return count
end


--[[
-- 这一次点击同花顺按钮, 取得的提示5张牌数据放到 cbOutCardData 里面
function GameViewLayer:TongHuaShun(cbInCardData,bCardCount,cbOutCardData)

	if (self.m_cbCardType ~= GameLogic.CT_FIVE_STRAIGHT_FLUSH) then
		self.m_cbIndex = 1;
	end
	self.m_cbCardType = GameLogic.CT_FIVE_STRAIGHT_FLUSH;
	-- change by Owen, 2018.5.4, 添加王的处理
	local AnalyseResult = {cbCardCount = {},cbDistributing = {}, cbKingData = {}}
	AnalyseResult.cbKingCount = 0
	
	for i =1 ,4 do
		AnalyseResult.cbCardCount[i] = 0
		AnalyseResult.cbDistributing[i] = {}
		for j = 1,cmd.HAND_CARD_COUNT do
			AnalyseResult.cbDistributing[i][j] = 0
		end
	end
	GameLogic:AnalysebCardColorDistri(cbInCardData,bCardCount,AnalyseResult)
	--存放大于5张的牌数据
	local cccount = 0
	-- cardData 存放的是这个花色的扑克牌有几张
	-- cardData[1/2/3/4] 表示4种不同花色的牌, 分别有几张
	local cardData = {}
	for i = 1, 4 do
		cardData[i] = {}
		if AnalyseResult.cbCardCount[i] + AnalyseResult.cbKingCount >= 5 then
			for j = 1,AnalyseResult.cbCardCount[i] do
				local temp = AnalyseResult.cbDistributing[i][j]
				if not self:FindValue(cardData[i],temp) then
					table.insert(cardData[i],temp)
				end
			end
			cccount = cccount + 1
		end
	end
	if cccount == 0 then
		return 0
	end

	-- you
	local bFound = false
	local foundCrads = {}

	-- 从1开始往后遍历
	local beginIndex = self.m_cbIndex
	for i = beginIndex, 10 do
		-- 遍历4个花色牌数组里面有没有这张牌
		for j = 1, 4 do
			for i1,v1 in ipairs(cardData[j]) do
				-- 获得牌的数值（1 -- 13）, 大小王就返回14
	            local function myGetCardValue(cbCardData)
	                return (cbCardData - math.floor(cbCardData/16)*16)
	            end
	            -- 这个花色的数组里面有这一张牌
	    		local cbCardValue = myGetCardValue(v1);
	    		if i == cbCardValue then
	    			-- 这个花色里面有这张牌
	    			foundCrads = {}
	    			foundCrads[#foundCrads + 1] = v1
	    			-- 拿出从i开始往后的5个数的组合, 如A2345这五张牌, 
	    			-- 这个花色的牌数组里面有几张
					local haveCount = 0
					for i2 = 1,4 do
						for i3,v3 in ipairs(cardData[j]) do
							-- 把1改成A
							local function myGetCardValue1(cbCardData)
				                local middleData = (cbCardData - math.floor(cbCardData/16)*16)
				                if middleData == 1 then
				                	middleData = 14
				                end
				                return middleData
				            end
							if (i + i2) == myGetCardValue(v3) do
								haveCount = haveCount + 1
								foundCrads[#foundCrads + 1] = v3
							end
						end
					end
					if haveCount + AnalyseResult.cbKingCount >= 5 then
						bFound = true
						cbOutCardData = foundCrads
						if #foundCrads == 3 then
							cbOutCardData[4] = AnalyseResult.cbKingData[1]
							cbOutCardData[5] = AnalyseResult.cbKingData[2]
						elseif #foundCrads == 4 then
							cbOutCardData[5] = AnalyseResult.cbKingData[1]
						end
						self.m_cbIndex = self.m_cbIndex + i - beginIndex + 1
						return
					end
	    		end
			end
		end
	end

	-- 如果没找到的话则下次从1开始查找
	self.m_cbIndex = 1
	return 0




	if (self.m_cbCardType ~= GameLogic.CT_FIVE_STRAIGHT_FLUSH) then
		self.m_cbIndex = 1;
	end
	self.m_cbCardType = GameLogic.CT_FIVE_STRAIGHT_FLUSH;


	local AllCardData = {}
	GameLogic:AnalysebCardDataDistributing(cbInCardData,bCardCount,AllCardData)


	    -- 表示自己手里有两个A, 一个K
	    -- AllCardData = {
	    --     cbCardCount =    {2,0,..,{1}}
	    --     cbDistributing = {{1,17},{},..,{13}}
	    -- }
	

	-- 找到的所有顺子存到这个表里面
	local allShunZi = {}
	local thisShunZi = {}

	local kingCount = AllCardData.cbCardCount[0]

	local bFound = false
	local beginIndex = self.cbShunZiBegin
	for i = beginIndex, 13 do
		-- 拿出从i开始往后的5个数的组合, 如A2345这五张牌, 自己手里有几张
		local haveCount = 0
		for k = 0,4 do
			if AllCardData.cbCardCount[i+k] > 0 then
				haveCount = haveCount + 1
			end
		end

		
		if haveCount == 5 then
			-- 有五张不需要王的顺子
			for j = 0,4 do
				for j1,v1 in ipairs(AllCardData.cbDistributing[i+j])
					allShunZi[#allShunZi+1] = {v1, AllCardData.cbDistributing[i+j]
				end

			end
			self.cbShunZiBegin = i + 1
			bFound = true
		elseif haveCount == 4 and kingCount >= 1 then
			-- 插入4张牌
			for j1 = 0,4 do
				if AllCardData.cbCardCount[i+j1] > 0 then
					thisShunZi[j] = AllCardData.cbDistributing[i+j1][1]
				end
			end
			-- 插入一个王
			thisShunZi[5] = AllCardData.cbDistributing[0][1]
			self.cbShunZiBegin = i + 1
			bFound = true
		elseif haveCount == 3 and kingCount >= 2 then
			-- 插入3张牌
			for j1 = 0,4 do
				if AllCardData.cbCardCount[i+j1] > 0 then
					thisShunZi[j] = AllCardData.cbDistributing[i+j1][1]
				end
			end
			-- 插入2个王
			thisShunZi[4] = AllCardData.cbDistributing[0][1]
			thisShunZi[5] = AllCardData.cbDistributing[0][2]
			self.cbShunZiBegin = i + 1
			bFound = true
		end

		-- 如果找到了则跳出这个循环
		if bFound then
			break
		end
	end


		
	local count = #AllCardData / 5 --有多少种可能
	local index = self.m_cbIndex
	if index > count then
		index = 1
	end
	for j = 1,5 do
		cbOutCardData[j] = AllCardData[(index - 1) * 5 + j]
	end
		
	self.m_cbIndex = self.m_cbIndex + 1
	if self.m_cbIndex > count then
		self.m_cbIndex = 1
	end
	return 5
end
]]

function GameViewLayer:FindValue(cardData,value)
	for i = 1,#cardData do
		if cardData[i] == value then
			return true
		end
	end
	return false
end

function GameViewLayer:setBtnVisible()
	local sum = 0
	for i = 1,3 do
		sum = sum + #self.arrangeCard[i]
	end
	if sum == cmd.HAND_CARD_COUNT then
		self.btOutCard:setVisible(true)
		self.btRecover:setVisible(true)
	else
		self.btOutCard:setVisible(false)
		self.btRecover:setVisible(false)
	end
end


---播放比牌信息
function GameViewLayer:showCompareAnimation(cbArrangeCard,everyDunAmount,final,gunUser,bSpecialCardType,wAllKillChairId,cb_Dpai)
	local AllPlayerCount = 0
    --设置牌型
    for i = 1, cmd.GAME_PLAYER do
        if self._scene.cbPlayStatus[i] == 1 and bSpecialCardType[i] == 0 then --玩家游戏中
            local wViewChairId = self._scene:SwitchViewChairID(i - 1)
            self:gameOpenCard(wViewChairId,cbArrangeCard[i])
            AllPlayerCount = AllPlayerCount + 1
        end
    end

    ----牌大小播放顺序
    local cbFirstPos =  cb_Dpai["FirstPos"]
    local cbSecondPos = cb_Dpai["SecondPos"]
    local cbThirdPos =  cb_Dpai["ThirdPos"]


    local cbFirstPosindex={0,0,0,0,0}
    local cbSecondPosindex={0,0,0,0,0}
    local cbThirdPosindex={0,0,0,0,0}

    --播放每一墩
    local ONE_ROW = 3 -- 第一墩牌
    local TWO_ROW = 8 -- 第二墩牌
    local time = 0.7  --翻一张牌要时间
    local timeSum = 1 --总时间
    local playCount = 0 --当前播放玩家数量
    cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION2_D)--cocos2d::DisplayLinkDirector::Projection::_2D
    for i = 1,cmd.GAME_PLAYER do
        if self._scene.cbPlayStatus[i] == 1 and bSpecialCardType[i] == 0 then --玩家游戏中
            local wViewChairId = self._scene:SwitchViewChairID(i - 1)
            ------------------------
           local FirstPos_index =  0 --第一墩
           local FirstPos2_index =  0 --第二墩
           local FirstPos3_index =  0 --第三墩

           local curfpos = i-1

           for k=1, cmd.GAME_PLAYER do
             local fpos =  cbFirstPos[k]
               if fpos == curfpos then
                   FirstPos_index = k-1
               end
           end
           cbFirstPosindex[i]=FirstPos_index
           for k=1, cmd.GAME_PLAYER do
             local fpos =  cbSecondPos[k]
               if fpos == curfpos then
                   FirstPos2_index = k-1
               end
           end
           cbSecondPosindex[i]=FirstPos2_index
           for k=1, cmd.GAME_PLAYER do
             local fpos =  cbThirdPos[k]
               if fpos == curfpos then
                   FirstPos3_index = k-1
               end
           end
           cbThirdPosindex[i] = FirstPos3_index

           local SecondPos_index = cbSecondPos[i]--第二墩

           local ThirdPos_index =  cbThirdPos[i]--第三墩

            for j = 1,13 do
	            if j <= ONE_ROW then  --第一墩
	                timeSum = FirstPos_index * time
	            elseif j <= TWO_ROW then --第二墩
	                timeSum = AllPlayerCount * time + time * FirstPos2_index
	            else --第三墩
	                timeSum = AllPlayerCount * time * 2 + time * FirstPos3_index
	            end
                --开始角度设置为0，旋转90度
	            self.aniCardBack[wViewChairId][j]:runAction(cc.Sequence:create(cc.DelayTime:create(timeSum),cc.OrbitCamera:create(time/2,1,0,0,90,0,0),cc.Hide:create(),
	            cc.CallFunc:create(
	            function()--开始角度是270，旋转90度
	                self.aniCardFont[wViewChairId][j]:runAction(cc.Sequence:create(cc.Show:create(),
	                cc.OrbitCamera:create(time/2,1,0,270,90,0,0)))
					self.aniCardBack[wViewChairId][j]:runAction(cc.OrbitCamera:create(0.5,1,0,0,0,0,0))
	            end
	            )))

        	end
            --------------------
        	playCount = playCount + 1
        end
        
    end
    local playerCount = playCount
    --播放分数显示
    playCount = 0
    for i = 1,cmd.GAME_PLAYER do
        if self._scene.cbPlayStatus[i] == 1 and bSpecialCardType[i] == 0 then --玩家游戏中
            local wViewChairId = self._scene:SwitchViewChairID(i - 1)
            for j = 1,3 do
				local action = nil
                     local ctime= playCount
                     if j == 1 then
                          ctime = cbFirstPosindex[i]
                     elseif j == 2 then
                          ctime = cbSecondPosindex[i]
                     else
                          ctime = cbThirdPosindex[i]
                     end
                if (playerCount - 1) == playCount and j == 3 then  ---3张牌墩
					action = cc.Sequence:create(cc.DelayTime:create(AllPlayerCount*time*(j - 1) + ctime * time),cc.Show:create(),--cc.DelayTime:create(time),
					cc.CallFunc:create(function(ref)
						local tempcard = {}
						for k = 1,5 do
							table.insert(tempcard,cbArrangeCard[i][k+8])
						end
						local type = GameLogic:GetCardType(tempcard,#tempcard)
						local path = self:getSoundByCardType(type)
							if path ~= "" then
								AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/"..path)
							end
						local actionsound1 = cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function(ref)
							
						end))
						--self.m_sound:stopAllActions()
						--self.m_sound:runAction(actionsound1)
						self:showSpecailAnimal(cbArrangeCard,bSpecialCardType,gunUser,wAllKillChairId)
                        
                    end))
				else  ------5张牌墩
					action = cc.Sequence:create(cc.DelayTime:create(AllPlayerCount*time*(j - 1) + ctime*time),cc.Show:create(),
					cc.CallFunc:create( function()
						local tempcard = {}
						if j == 1 then
							for k = 1,3 do
								table.insert(tempcard,cbArrangeCard[i][k])
							end
						elseif j == 2 then
							for k = 1,5 do
								table.insert(tempcard,cbArrangeCard[i][k+3])
							end
						else
							for k = 1,5 do
								table.insert(tempcard,cbArrangeCard[i][k+8])
							end
						end
						local type = GameLogic:GetCardType(tempcard,#tempcard)
						local path = self:getSoundByCardType(type)
						if path ~= "" then
							AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/"..path)
						end
						
					end
							)
					)
                end
                self.nodeScore[wViewChairId][j]:setString(""..math.abs(everyDunAmount[i][j]))
                self.nodeScore[wViewChairId][j]:runAction(action)
                if everyDunAmount[i][j] < 0 then
                    self.nodeNumJn[wViewChairId][j]:runAction(cc.Sequence:create(
                     cc.DelayTime:create(AllPlayerCount*time*(j - 1) + ctime*time),cc.Show:create()))
                else
                    self.nodeNumPlus[wViewChairId][j]:runAction(cc.Sequence:create(
                     cc.DelayTime:create(AllPlayerCount*time*(j - 1) + ctime*time),cc.Show:create()))
                end
            end
            playCount = playCount + 1
        end
    end
end
--获得声音资源
function GameViewLayer:getSoundByCardType(CardType)
	if CardType == GameLogic.CT_SINGLE then
		return "WuLong_Nan.mp3"
	elseif CardType == GameLogic.CT_ONE_DOUBLE then
		return "DuiZi_Nan.mp3"
	elseif CardType == GameLogic.CT_FIVE_TWO_DOUBLE then
		return "LiangDui_Nan.mp3"
	elseif CardType == GameLogic.CT_THREE then
		return "SanTiao_Nan.mp3"
	elseif CardType == GameLogic.CT_FIVE_MIXED_FLUSH_NO_A or 
		CardType == GameLogic.CT_FIVE_MIXED_FLUSH_FIRST_A or 
		CardType == GameLogic.CT_FIVE_MIXED_FLUSH_BACK_A then
		return "ShunZi_Nan.mp3"
	elseif CardType == GameLogic.CT_FIVE_FLUSH then
		return "TongHua_Nan.mp3"
	elseif CardType == GameLogic.CT_FIVE_THREE_DEOUBLE then
		return "HuLu_Nan.mp3"
	elseif CardType == GameLogic.CT_FIVE_FOUR_ONE then
		return "TieZhi_Nan.mp3"
	elseif CardType == GameLogic.CT_FIVE_STRAIGHT_FLUSH
		or CardType == GameLogic.CT_FIVE_STRAIGHT_FLUSH_FIRST_A
		or CardType == GameLogic.CT_FIVE_STRAIGHT_FLUSH_BACK_A then
		return "TongHuaShun_Nan.mp3"
	elseif CardType == GameLogic.CT_FIVE_FIVE then
		return "WuTong_Nan.mp3"
	end
	return ""
end

function GameViewLayer:getSpecialSoundByCardType(CardType)
	if CardType == GameLogic.CT_THREE_FLUSH then
		return "SanTongHua_Nan.mp3"
	elseif CardType == GameLogic.CT_THREE_STRAIGHT then
		return "SanShunZi_Nan.mp3"	
	elseif CardType == GameLogic.CT_SIXPAIR then
		return "LiuDuiBan_Nan.mp3"	
	elseif CardType == GameLogic.CT_FIVEPAIR_THREE then
		return "WuDuiSanTiao_Nan.mp3"
	elseif CardType == GameLogic.CT_FOUR_THREESAME then
		return "ChongSan_Nan.mp3"
	elseif CardType == GameLogic.CT_SAME_COLOR then
		return "CouYiSe_Nan.mp3"
	elseif CardType == GameLogic.CT_ALL_SMALL then
		return "QuanXiao_Nan.mp3"		
	elseif CardType == GameLogic.CT_ALL_BIG then
		return "QuanDa_Nan.mp3"	
	elseif CardType == GameLogic.CT_THREE_BOMB then
		return "SanFenTianXia_Nan.mp3"	
	elseif CardType == GameLogic.CT_THREE_STRAIGHTFLUSH then
		return "SanTongHuaShun_Nan.mp3"	
	elseif CardType == GameLogic.CT_TWELVE_KING then
		return "ShiErHuangZu_Nan.mp3"
	elseif CardType == GameLogic.CT_D_JXH then
		return "YiTiaoLong_Nan.mp3"	
	elseif CardType == GameLogic.CT_D_JXH_FLUSH then
		return "ZhiZunQingLong_Nan.mp3"	
	end
	return ""
end

--特殊牌处理
function GameViewLayer:showSpecailAnimal(cbArrangeCard,bSpecialCardType,gunUser,wAllKillChairId)
	--直接显示特殊牌型的玩家
	local time = 0.7
	local allTime = 0
	local allPlayer = 0
	local curCount = 0
	for i = 1,cmd.GAME_PLAYER do
		if bSpecialCardType[i] > 0 then
			allPlayer = allPlayer + 1
		end
	end
	for i = 1,cmd.GAME_PLAYER do
		if bSpecialCardType[i] > 0 then
			local wViewChairId = self._scene:SwitchViewChairID(i - 1)
            self:gameOpenCard(wViewChairId,cbArrangeCard[i])
			local action = nil
			if (allPlayer - 1) == curCount then
				action = cc.Sequence:create(cc.DelayTime:create(time*(curCount + 1)),cc.CallFunc:create(function(ref)
							self:setAniCardBackVisible(wViewChairId,false)
							self:setAniCardFontVisible(wViewChairId,true)
							self:setSpecialCard(wViewChairId,bSpecialCardType[i])
							local path = self:getSpecialSoundByCardType(bSpecialCardType[i])
							if path ~= "" then
								AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/"..path)
							end
                            --特殊牌显示
                            self:showTeshupai(wViewChairId,bSpecialCardType[i])
							self:showGunAnimation(gunUser,bSpecialCardType,wAllKillChairId)	
						end))
			else
				action = cc.Sequence:create(cc.DelayTime:create(time*(curCount + 1)),cc.CallFunc:create(function(ref)
							self:setAniCardBackVisible(wViewChairId,false)
							self:setAniCardFontVisible(wViewChairId,true)
							self:setSpecialCard(wViewChairId,bSpecialCardType[i])
							local path = self:getSpecialSoundByCardType(bSpecialCardType[i])
							if path ~= "" then
								AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/"..path)
							end	
                             --特殊牌显示
                            self:showTeshupai(wViewChairId,bSpecialCardType[i])
						end))
			end
			self.m_specialSound[i]:runAction(action)
			curCount = curCount + 1
		end
	end
	if allPlayer == 0 then
		self:showGunAnimation(gunUser,bSpecialCardType,wAllKillChairId)
	end
	
	
end
--打枪动画
function GameViewLayer:showGunAnimation(gunUser,bSpecialCardType,wAllKillChairId)
	
	local actionend = cc.Sequence:create(cc.DelayTime:create(0.7),cc.CallFunc:create(function(ref)
						self:showDaqianAnimation(gunUser,bSpecialCardType,wAllKillChairId)
               end))
	self.m_sound:stopAllActions()
	self.m_sound:runAction(actionend)
end


function GameViewLayer:showDaqianAnimation(gunUser,bSpecialCardType,wAllKillChairId)
	 --先清除弹孔
	self:hideAllQiangKong(false)
	local isDaQiang=false
	 for i = 1,cmd.GAME_PLAYER do	
		 -- 打枪的人
		local wViewChairId = self._scene:SwitchViewChairID(i - 1)		
        for j=1,cmd.GAME_PLAYER do
		  local bdaqiang = gunUser[i][j]
		
		    --发现有打枪
		    if bdaqiang == 1  then
				gunUser[i][j] = 0
				local bdaqianViewChairId = self._scene:SwitchViewChairID(j - 1)	
          		self:addDaqian_Animation(self,wViewChairId,bdaqianViewChairId)
				self:ShowPlayQiangKong(bdaqianViewChairId)
				    isDaQiang=true
					local actionend = cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function(ref)
						self:showDaqianAnimation(gunUser,bSpecialCardType,wAllKillChairId)
                    end))				
					self.m_sound:stopAllActions()
					self.m_sound:runAction(actionend)
				return
			end
		end		
		
					
	end
	
	--没有打枪 结算界面
	if isDaQiang ==false then

          if wAllKillChairId >= 0 and wAllKillChairId < cmd.GAME_PLAYER  then --有全垒打

 			 local actionend = cc.Sequence:create(cc.DelayTime:create(0.7),cc.CallFunc:create(function(ref)
						    --self:showGameEndLayer()
                            self:Qainleida_plist(wAllKillChairId)
                        end))		
		    self.m_sound:stopAllActions()
		    self.m_sound:runAction(actionend)
          else  --结束显示结算
			    local actionend = cc.Sequence:create(cc.DelayTime:create(0.7),cc.CallFunc:create(function(ref)
						    self:showGameEndLayer()
                        end))		
		    self.m_sound:stopAllActions()
		    self.m_sound:runAction(actionend)
        end
	end
end

--显示结算界面
function GameViewLayer:showGameEndLayer()
	if self.m_layerEnd == nil then
		self.m_layerEnd = GameEndLayer:create(self)
		self.m_layerEnd:setBtnVisible(false)
		self.m_layerEnd:addTo(self,65)
	else
		self.m_layerEnd:setUserInfo()
		self.m_layerEnd:updateCardInfo()
		self.m_layerEnd:setVisible(true)
	end
    -----延迟显示
    if self.showEndBut_bool == true then
   	    self.m_layerEnd.btStart:setVisible(false)
	    self.m_layerEnd.btLookResult:setVisible(true)
	    self.m_layerEnd:setVisible(true)
	    self.btShowEnd:setVisible(false)
    end
    self.playAniEnd_bool = true
end

function GameViewLayer:showEndBut(showbool)
        self.showEndBut_bool=showbool
end

---获得播放状态
function GameViewLayer:getPlayEndBool()
    return  self.playAniEnd_bool
end

function GameViewLayer:getMoveIndex(x,y)
	local size1 = self.nodeCard[cmd.MY_VIEWID]:getContentSize()
	local x1, y1 = self.nodeCard[cmd.MY_VIEWID]:getPosition()
	for i = 1, cmd.HAND_CARD_COUNT do
		local card = self.nodeCard[cmd.MY_VIEWID]:getChildByTag(i)
		local x2, y2 = card:getPosition()
		local size2 = card:getContentSize()
		local rect = card:getTextureRect()
		rect.x = x2 + x1 - size1.width/1.69
		rect.width = GameViewLayer.CARDSPACING
		if i == #self.handCard then
			rect.width = size2.width
		end
		rect.y = y1 - size1.height/2 + y2 - size2.height/2
		if cc.rectContainsPoint(rect, cc.p(x, y)) then
			return i
		end
	end
	return 0
end



function GameViewLayer:ImportDaqian_plist()
	--初始化 打枪plsit  加载
    local daqianplstName={"daqian_l","daqian_r","daqian_up","daqian_up"}	
	local allframe={10,10,10,6,7,7,7,6,22,15}
	for k=1,10 do
		display.loadSpriteFrames(GameViewLayer.RES_PATH.."Animation/Plist"..k..".plist",
								GameViewLayer.RES_PATH.."Animation/Plist"..k..".png")
		local animation = cc.Animation:create()
		animation:setDelayPerUnit(0.06)
		animation:setLoops(2)
		for j = 1, allframe[k] do
			local strName = "plist"..k.."_"..(j-1)..".png"   --string.format("%d.png", j - 1)
			local sprite = cc.SpriteFrameCache:getInstance():getSpriteFrame(strName)
			animation:addSpriteFrame(sprite)
		end
		cc.AnimationCache:getInstance():addAnimation(animation, "daqian_"..k)
    end

end

--添加打枪动画  addNode 添加到节点   dir 开枪方向  actionType 动作
function GameViewLayer:addDaqian_Animation(addNode,dir,TodaqiangIndex)
	
	if not addNode  then
		return
	end	
	
	---打枪人   1  右上  2  左下  3 中   4  右下  5  左上
	
	local point = pointAnimalCard[dir];
	local b_point = pointAnimalCard[TodaqiangIndex];
	
	--GameViewLayer.R_Up		 =1
	--GameViewLayer.L_Down 	=2
	--GameViewLayer.C_C 		=3
	--GameViewLayer.R_Down	 =4
	--GameViewLayer.L_Up		 =5	
	
-------------播放 方向
--GameViewLayer.play_L_Up		 =7  --需要翻转
--GameViewLayer.play_L_Down 	 =5  --需要翻转

--GameViewLayer.play_R_Down	 =5
--GameViewLayer.play_R_Up		 =7
--GameViewLayer.play_Up		 =1
---GameViewLayer.play_Down		 =3
--GameViewLayer.play_L	 	 =1 --需要翻转
--GameViewLayer.play_R	 	 =2	
	
	
	
	
	local play_index = GameViewLayer.play_Down
	local playdir = false
	
	if dir == GameViewLayer.R_Up  then   -----右上角
			
		if 	TodaqiangIndex ==	GameViewLayer.L_Down then
			playdir = true
			play_index = GameViewLayer.play_L_Down
			
		elseif TodaqiangIndex == GameViewLayer.C_C   then
			playdir = true
			play_index = GameViewLayer.play_L_Down
			
		elseif TodaqiangIndex == GameViewLayer.R_Down  then

			play_index = GameViewLayer.play_Down
		elseif TodaqiangIndex == GameViewLayer.L_Up  then
			playdir = true
			play_index = GameViewLayer.play_R
		end
		
	elseif dir == GameViewLayer.L_Down  then  ----左上角
		
		if 	TodaqiangIndex ==	GameViewLayer.R_Up then

			play_index = GameViewLayer.play_R
		elseif TodaqiangIndex == GameViewLayer.C_C   then

			play_index = GameViewLayer.play_R
			
		elseif TodaqiangIndex == GameViewLayer.R_Down  then

			play_index = GameViewLayer.play_R
		elseif TodaqiangIndex == GameViewLayer.L_Up  then

			play_index = GameViewLayer.play_Up	
		end
	elseif dir == GameViewLayer.C_C   then
				
		if 	TodaqiangIndex ==	GameViewLayer.R_Up then

			play_index = GameViewLayer.play_Up	
		elseif TodaqiangIndex == GameViewLayer.L_Down   then

			play_index = GameViewLayer.play_Up	
		elseif TodaqiangIndex == GameViewLayer.R_Down  then

			play_index = GameViewLayer.play_Up	
		elseif TodaqiangIndex == GameViewLayer.L_Up  then

			play_index = GameViewLayer.play_Up	
		end
	elseif dir == GameViewLayer.R_Down  then
		
		if 	TodaqiangIndex ==	GameViewLayer.R_Up then

			play_index = GameViewLayer.play_Up	
		elseif TodaqiangIndex == GameViewLayer.L_Down   then
			playdir = true
			play_index = GameViewLayer.play_R
		elseif TodaqiangIndex == GameViewLayer.C_C  then
			playdir = true
			play_index = GameViewLayer.play_R
		elseif TodaqiangIndex == GameViewLayer.L_Up  then
			playdir = true
			play_index = GameViewLayer.play_R
		end
	elseif dir == GameViewLayer.L_Up  then
		
		if 	TodaqiangIndex ==	GameViewLayer.R_Up then
			play_index = GameViewLayer.play_R
		elseif TodaqiangIndex == GameViewLayer.L_Down   then
			play_index = GameViewLayer.play_Down
		elseif TodaqiangIndex == GameViewLayer.C_C  then
			play_index = GameViewLayer.play_R
		elseif TodaqiangIndex == GameViewLayer.R_Down  then
			play_index = GameViewLayer.play_R
		end
	end
		display.newSprite()
			:move(point)
			:addTo(addNode,50)
            :setFlipX(playdir)
			:runAction(self:getAnimate("daqian_"..play_index, true))

	AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/GAME_GUNREADY.mp3")
end


--隐藏枪孔
function GameViewLayer:hideAllQiangKong(qk_bool)
	for j = 1,cmd.GAME_PLAYER do
		for i=1 , 3 do  --打枪图片
			self.daqian_Node[j][i]:setVisible(qk_bool)
		end	
	end
end	


---单孔 效果
function GameViewLayer:ShowPlayQiangKong(playindex)
	
	 if (not playindex) or (playindex <0 or playindex >cmd.GAME_PLAYER) then
		return
	end
	
	local daqoangNode = self.daqian_Node[playindex]
	
	daqoangNode[1]:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(
                function(ref)
					ref:setVisible(true)
					AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/FireGun_Nan.mp3")
					AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/GAME_GUN.mp3")
                end
    )))
	daqoangNode[2]:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.CallFunc:create(
                function(ref)
					ref:setVisible(true)
					AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/GAME_GUN.mp3")
                end
    )))
	daqoangNode[3]:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(
                function(ref)
					ref:setVisible(true)
					AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/GAME_GUN.mp3")
                end
    )))
	
end


--清除打枪资源
function GameViewLayer:deleteDaqian_plist()
	
	for i=1,10 do
		cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(GameViewLayer.RES_PATH.."Animation/Plist"..i..".plist")
		cc.Director:getInstance():getTextureCache():removeTextureForKey(GameViewLayer.RES_PATH.."Animation/Plist"..i..".png")
	end
end

--手牌音效
function GameViewLayer:playCardSound(cardType)

	if cardType == GameViewLayer.moveCard then
		AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/GAME_CARD.mp3")
	end
end


--播放全垒打
function GameViewLayer:Qainleida_plist(wAllKillChairId)
        AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/QuanLeiDa_Nan.mp3")
		display.newSprite()
			:move(appdf.WIDTH-230,270)
			:addTo(self,50)
            :setFlipX(playdir)
			:runAction(self:getAnimate("daqian_9", true))
            AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/JiQiRen.mp3")

         local action_play =  cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(
                function(ref)
					AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/GAME_SHUFFLE.mp3")
                end),cc.DelayTime:create(0.3),cc.CallFunc:create(
                function(ref)
					AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/JiQiRen.mp3")
                end),cc.DelayTime:create(0.8),cc.CallFunc:create(
                function(ref)
					AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/GAME_SHUFFLE.mp3")
                     -----播放爆炸效果  获得 时间 显示结算界面
                    local qianleidatime = self:Qainleida_baozha_plist(wAllKillChairId)+1.2
                    local action_play2 =  cc.Sequence:create(cc.DelayTime:create(qianleidatime),cc.CallFunc:create(
                        function(ref)
                        self:showGameEndLayer()
                     end))

                    self.spritePrompt:stopAllActions()
                    self.spritePrompt:runAction(action_play2)
                end)
                
                
                )

        self.m_sound:stopAllActions()
		self.m_sound:runAction(action_play)
end


--播放全垒打 爆炸
function GameViewLayer:Qainleida_baozha_plist(quanleidaChairId)
    
        if not quanleidaChairId then 

            return 
        end
         local wViewChairId2 = self._scene:SwitchViewChairID(quanleidaChairId)
         local time =0.1
        for i =1,cmd.GAME_PLAYER  do

            local wViewChairId = self._scene:SwitchViewChairID(i - 1)

                 if self.userName[i]~= ""  and wViewChairId2 ~= wViewChairId then --玩家游戏中

                       -- local wViewChairId = self._scene:SwitchViewChairID(i - 1)

                        self.nodePlayer[wViewChairId]:stopAllActions()

                        local point = pointAnimalCard[wViewChairId];

                        local action_play =  cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(
                        function(ref)
                        display.newSprite()
			                :move(point)
			                :addTo(self,50)
                            :setFlipX(playdir)
			                :runAction(self:getAnimate("daqian_10", true))
                            AudioEngine.playEffect(GameViewLayer.RES_PATH.."sound/BaoZha.mp3")
                        end))

                       self.nodePlayer[wViewChairId]:runAction(action_play)

                       time= time + 1.2
              
                 end

        end
        return time
end

function GameViewLayer:PlaceCardOff(viewID)
	self.PlaceCard[viewID]:setVisible(false)
	self.BgCard[viewID]:setVisible(false)
	
end

--初始化
function GameViewLayer:GameEngine()
	
	self:hideAllQiangKong(false)
end


--特殊牌显示
function GameViewLayer:showTeshupai(chair_index,cardType)
		--准备

        local wViewChairId = self._scene:SwitchViewChairID(chair_index - 1)

        if wViewChairId >0 and wViewChairId <=cmd.GAME_PLAYER and self.TeshupaiNode[wViewChairId]~=nil then

           -- local t = display.getImage(GameViewLayer.RES_PATH.."specialCard/SpecialTypeBig.png")

            self.TeshupaiNode[wViewChairId]:setTexture(GameViewLayer.RES_PATH.."specialCard/SpecialTypeBig.png")

            local width = self.TeshupaiNode[wViewChairId]:getContentSize().width
            local height = self.TeshupaiNode[wViewChairId]:getContentSize().height / 13

		    self.TeshupaiNode[wViewChairId]:setTextureRect(cc.rect(0,height*(cardType-13) ,width,height))
											:setVisible(true)
        end


end


--特殊牌创建显示
function GameViewLayer:newSpriteTeshupai()
		
		
        self.TeshupaiNode = {}
        for i = 1 , cmd.GAME_PLAYER do
			 local wViewChairId = self._scene:SwitchViewChairID(i - 1)
            local point = pointAnimalCard[i];
        	self.TeshupaiNode[wViewChairId] = display.newSprite(GameViewLayer.RES_PATH.."specialCard/SpecialTypeBig.png")
			:move(point)
			:setAnchorPoint(0.7,1)
			:setVisible(false)
			:addTo(self,60)    

            local width = self.TeshupaiNode[wViewChairId]:getContentSize().width
            local height = self.TeshupaiNode[wViewChairId]:getContentSize().height / 13

            self.TeshupaiNode[wViewChairId]:setTextureRect(cc.rect(0,height,width,height))
        end
        
end

--特殊牌创建显示
function GameViewLayer:ShowAllTeshupai(bool)

  for i=1 , cmd.GAME_PLAYER do
     --if not self.TeshupaiNode[i] then
         self.TeshupaiNode[i]:setVisible(bool)
     -- end
  end

end

-- add by Owen, 2018.5.19, 点击给我大牌按钮
function GameViewLayer:onButtonClickedGiveMeBigCard( ... )
	local numid = GlobalUserItem.dwGameID or ""
	print("GlobalUserItem.dwGameID = "..tostring(GlobalUserItem.dwGameID))
	self._scene:onGiveMeBigCard(numid)
end

return GameViewLayer