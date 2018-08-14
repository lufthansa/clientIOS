local GameLogic = {}


--**************    扑克类型    ******************--
--错误类型
GameLogic.CT_INVALID				= 0
--单牌类型
GameLogic.CT_SINGLE			        = 1
--只有一对
GameLogic.CT_ONE_DOUBLE			    = 2
--两对牌型
GameLogic.CT_FIVE_TWO_DOUBLE	    = 3
--三张牌型
GameLogic.CT_THREE	                = 4
--没A杂顺
GameLogic.CT_FIVE_MIXED_FLUSH_NO_A  = 5
--A在前顺子
GameLogic.CT_FIVE_MIXED_FLUSH_FIRST_A   = 6
--A在后顺子
GameLogic.CT_FIVE_MIXED_FLUSH_BACK_A    = 7
--同花五牌
GameLogic.CT_FIVE_FLUSH			        = 8
--三条一对
GameLogic.CT_FIVE_THREE_DEOUBLE			= 9
--四带一张
GameLogic.CT_FIVE_FOUR_ONE			    = 10
--同花顺牌
GameLogic.CT_FIVE_STRAIGHT_FLUSH	    = 12
--A在前同花顺
GameLogic.CT_FIVE_STRAIGHT_FLUSH_FIRST_A = 13
--A在后同花顺
GameLogic.CT_FIVE_STRAIGHT_FLUSH_BACK_A  = 14
--五同
GameLogic.CT_FIVE_FIVE			        = 15


--特殊牌型
--同花十三水
GameLogic.CT_D_JXH_FLUSH			     = 25
--十三水
GameLogic.CT_D_JXH			             = 24
--十二皇族
GameLogic.CT_TWELVE_KING			     = 23
--三同花顺
GameLogic.CT_THREE_STRAIGHTFLUSH		 = 22
--三炸弹
GameLogic.CT_THREE_BOMB			         = 21
--全大
GameLogic.CT_ALL_BIG			         = 20
--全小
GameLogic.CT_ALL_SMALL			         = 19
--凑一色 十三同色
GameLogic.CT_SAME_COLOR			         = 18
--四套冲三	十二同色
GameLogic.CT_FOUR_THREESAME			     = 17
--五对冲三
GameLogic.CT_FIVEPAIR_THREE			     = 16
--六对半
GameLogic.CT_SIXPAIR			         = 15
--三同花
GameLogic.CT_THREE_FLUSH			     = 13
--三顺子
GameLogic.CT_THREE_STRAIGHT			     = 14

--牌库数目
GameLogic.FULL_COUNT			= 52
--正常手牌数目
GameLogic.NORMAL_COUNT			= 13

--排序类型
--降序类型 
GameLogic.enDescend 		    = 0
--升序类型
GameLogic.enAscend 				= 1
--花色类型
GameLogic.enColor				= 2

GameLogic.m_bCardListData=
{
        -- 1 , 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,  --方块 A 
        -- 17,18,19,20,21,22,23,24,25,26,27,28,29,  --梅花 A 
        -- 33,34,35,36,37,38,39,40,41,42,43,44,45,  --红桃 A 
        -- 49,50,51,52,53,54,55,56,57,58,59,60,61,  --黑桃 A 
        -- 65,66,                                   --小王 大王

		0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,	--方块 A - K
		0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,	--梅花 A - K
		0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,	--红桃 A - K
		0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D	--黑桃 A - K
		--0x41,0x42															小王 大王
}

--取模
function GameLogic:mod(a,b)
    return a - math.floor(a/b)*b
end
--获得牌的数值（1 -- 13）
function GameLogic:GetCardValue(cbCardData)
    return self:mod(cbCardData, 16)
end
--逻辑数值
function GameLogic:GetCardLogicValue(cbCardData)
	local bCardValue = self:GetCardValue(cbCardData)
    if bCardValue==1 then
    bCardValue = bCardValue + 13
    end
    return bCardValue
end
--获得牌的颜色（0 -- 4）
function GameLogic:GetCardColor(cbCardData)
    return math.floor(cbCardData/16)
end
--获取类型
function GameLogic:GetCardType(bCardData,bCardCount)
    --数据校验
	assert(bCardCount==3 or bCardCount==5) ;
	if(bCardCount~=3 and bCardCount~=5) then
    return GameLogic.CT_INVALID;
    end

    --初始化结构体
	local AnalyseData = {bOneCount = 0,bTwoCount = 0,bThreeCount = 0,
          bFourCount = 0,bFiveCount=0,bWangCount=0,bOneFirst={},
          bTwoFirst={},bThreeFirst={},bFourFirst={},bFiveFirst={},
          bWangData={},bSameColorData={},bSameColorCount={},
          bAllOne={},bAllOneCount={},bSameColor=0};
	--memset(&AnalyseData , 0 , sizeof(tagAnalyseData)) ;

	assert(3==bCardCount or 5==bCardCount) ;

	--转化分析
	local bTransCardData = {0,0,0,0,0};
    local ttd = {bKingCount=0,bHaveKing=0,transList = {}};
    local ret = self:AnalyseMaxTransform(bCardData, bCardCount, bTransCardData, ttd);
	if (ret ~= 0) then
       return ret;
	end
    self:AnalyseCard(bCardData , bCardCount , AnalyseData) ;
	self:SortCardList(bCardData, bCardCount, self.enDescend);

    --开始分析
    if (bCardCount == 3) then -- 三条类型
            --单牌类型
			if(3==AnalyseData.bOneCount) then
            return GameLogic.CT_SINGLE ;
            end

			--对带一张
			if(1==AnalyseData.bTwoCount and 1==AnalyseData.bOneCount) then
            return GameLogic.CT_ONE_DOUBLE ;
            end

			--三张牌型
			if(1==AnalyseData.bThreeCount) then
            return GameLogic.CT_THREE ;
            end

			--错误类型
			return GameLogic.CT_INVALID ;
    elseif(bCardCount == 5) then -- 五张牌型
            local bFlushNoA	    = false ; 
			local bFlushFirstA	= false ;
			local bFlushBackA	= false ;
            --A连在后
			if(14==self:GetCardLogicValue(bCardData[1]) and 10==self:GetCardLogicValue(bCardData[5])) then
				bFlushBackA = true ;
			else
				bFlushNoA = true ;
            end

            for i=1,4 do
                if(1~=self:GetCardLogicValue(bCardData[i])-self:GetCardLogicValue(bCardData[i+1])) then
                bFlushBackA = false ;
                bFlushNoA   = false ;
                end
            end
            --A连在前
            if(false==bFlushBackA and false==bFlushNoA and 14==self:GetCardLogicValue(bCardData[1])) then
                bFlushFirstA = true ;
                for i=2,4 do
                    if(1~=self:GetCardLogicValue(bCardData[i])-self:GetCardLogicValue(bCardData[i+1])) then
                    bFlushFirstA = false ;
                    end
                end
                if(2~=self:GetCardLogicValue(bCardData[5])) then
                    bFlushFirstA = false ;
                end
            end

            --同花五牌
            if(false==bFlushBackA and false==bFlushNoA and false==bFlushFirstA) then
                if(true==AnalyseData.bSameColor) then
                    return GameLogic.CT_FIVE_FLUSH;
                end
            elseif(true==bFlushNoA) then
                --杂顺类型
                if(false==AnalyseData.bSameColor) then
                        return GameLogic.CT_FIVE_MIXED_FLUSH_NO_A;
                    else     --同花顺牌                         
                        return GameLogic.CT_FIVE_STRAIGHT_FLUSH;
                end
            elseif(true==bFlushFirstA) then
                --杂顺类型
                if(false==AnalyseData.bSameColor) then
                     return GameLogic.CT_FIVE_MIXED_FLUSH_FIRST_A;
                else    --同花顺牌
                     return GameLogic.CT_FIVE_STRAIGHT_FLUSH_FIRST_A;
                end
            elseif(true==bFlushBackA) then
                    --杂顺类型
                    --if(false==AnalyseData.bSameColor) return CT_FIVE_MIXED_FLUSH_NO_A;
                    if(false==AnalyseData.bSameColor) then
                        return GameLogic.CT_FIVE_MIXED_FLUSH_BACK_A;
                    --同花顺牌
                    else
                        return GameLogic.CT_FIVE_STRAIGHT_FLUSH_BACK_A;
                    end
            else
            end
            --五带0张
            if(1==AnalyseData.bFiveCount) then                             return    GameLogic.CT_FIVE_FIVE;
            end

            --四带单张
            if(1==AnalyseData.bFourCount and 1==AnalyseData.bOneCount) then return    GameLogic.CT_FIVE_FOUR_ONE;
            end
            --三条一对
            if(1==AnalyseData.bThreeCount and 1==AnalyseData.bTwoCount) then return    GameLogic.CT_FIVE_THREE_DEOUBLE;
            end
            --三条带单
            if(1==AnalyseData.bThreeCount and 2==AnalyseData.bOneCount) then return    GameLogic.CT_THREE;
            end
            --两对牌型
            if(2==AnalyseData.bTwoCount and 1==AnalyseData.bOneCount) then return    GameLogic.CT_FIVE_TWO_DOUBLE;
            end
            --只有一对
            if(1==AnalyseData.bTwoCount and 3==AnalyseData.bOneCount) then return    GameLogic.CT_ONE_DOUBLE;
            end
            --单牌类型
            if(5==AnalyseData.bOneCount and false==AnalyseData.bSameColor) then return  GameLogic.CT_SINGLE;
            end
            --错误类型
            return GameLogic.CT_INVALID;
            
    else
         return GameLogic.CT_INVALID;
    end
    return GameLogic.CT_INVALID;
end
--最大转化
function GameLogic:AnalyseMaxTransform(cbCardData,cbCardCount,bTransCardData,TransData)
    assert(type(cbCardData) == "table")
    if cbCardCount ~= 3 and cbCardCount ~= 5 then
        return GameLogic.CT_INVALID
    end

    local bKcount = 0
	for i = 1,cbCardCount do
		table.insert(bTransCardData,cbCardData[i])
	end
    local bTempCardData = self:copyTab(cbCardData)

    for i=1, cbCardCount do
        if bTempCardData[i] == 0x41 or bTempCardData[i] == 0x42 then
            if bTempCardData[i]==0x41 then
                TransData.bHaveKing = TransData.bHaveKing + 1
            else
                TransData.bHaveKing = TransData.bHaveKing + 2 
            end
			bTempCardData[i] = 0;
			bKcount = bKcount + 1;
        end
    end
    TransData.bKingCount = bKcount;

    --无王返回
	if (bKcount == 0) then
		return 0
    end
    --有王则分析牌数组
    self:SortCardList(bTempCardData,cbCardCount,self.enDescend)
    --分析数据
    local tad = {bOneCount = 0,bTwoCount = 0,bThreeCount = 0,
          bFourCount = 0,bFiveCount=0,bWangCount=0,bOneFirst={},
          bTwoFirst={},bThreeFirst={},bFourFirst={},bFiveFirst={},
          bWangData={},bSameColorData={},bSameColorCount={},
          bAllOne={},bAllOneCount={},bSameColor=0};
    self:AnalyseCard(bTempCardData,cbCardCount,tad);
    if ( 5 == cbCardCount and tad.bSameColor and 0 == (tad.bTwoCount+tad.bThreeCount+tad.bFourCount) ) then
        --A当1用，有A 且 第二大数字小于等于5, 最小顺子A2345
		if (14 == self:GetCardLogicValue(bTempCardData[1]) and 5 >= self:GetCardLogicValue(bTempCardData[2])) then		
		    self:TransformCard(bTempCardData, cbCardCount, bKcount,
            GameLogic.CT_FIVE_STRAIGHT_FLUSH_FIRST_A, tad, bTransCardData, TransData)
			return GameLogic.CT_FIVE_STRAIGHT_FLUSH_FIRST_A
        end
		if ((not self:IsIncludeA(bTempCardData,5)) and 5 >= self:GetCardLogicValue(bTempCardData[1])) then
		    self:TransformCard(bTempCardData, cbCardCount, bKcount, 
            GameLogic.CT_FIVE_STRAIGHT_FLUSH_FIRST_A, tad, bTransCardData, TransData)
			return GameLogic.CT_FIVE_STRAIGHT_FLUSH_FIRST_A;
        end
		--最大牌减去最小牌小于等于4
		if ( 4 >= self:GetCardLogicValue(bTempCardData[1]) - self:GetCardLogicValue(bTempCardData[5-bKcount]) ) then
		    self:TransformCard(bTempCardData, cbCardCount, bKcount, 
            GameLogic.CT_FIVE_STRAIGHT_FLUSH, tad, bTransCardData, TransData)
			return GameLogic.CT_FIVE_STRAIGHT_FLUSH;
        end
    end
    --五相 (5张牌 且 3张牌带双王或者4张牌带单王)
	if ( 5 == cbCardCount and ((2==bKcount and 1==tad.bThreeCount) or (1==bKcount and 1==tad.bFourCount)) ) then
        self:TransformCard(bTempCardData, cbCardCount, bKcount, 
        GameLogic.CT_FIVE_FIVE, tad, bTransCardData, TransData);
		return GameLogic.CT_FIVE_FIVE;
	end

	--炸弹	(5张牌 且 单王3张数目等于一或者双王2张数目或者3张数目等于一)
	if ( 5 == cbCardCount and  ((1==bKcount and 1==tad.bThreeCount) or (2==bKcount and (1==tad.bThreeCount or 1==tad.bTwoCount))) ) then
	    self:TransformCard(bTempCardData, cbCardCount, bKcount, 
        GameLogic.CT_FIVE_FOUR_ONE, tad, bTransCardData, TransData);
		return GameLogic.CT_FIVE_FOUR_ONE;
    end

	--葫芦  (5张牌 且 单王2张数目等于2）
	if ( 5 == cbCardCount and 1 == bKcount and 2 == tad.bTwoCount ) then
	    self:TransformCard(bTempCardData, cbCardCount, bKcount, 
        GameLogic.CT_FIVE_THREE_DEOUBLE, tad, bTransCardData, TransData);
		return GameLogic.CT_FIVE_THREE_DEOUBLE;
    end

	--同花  (5张牌 且 全部同花）
	if (5 == cbCardCount and tad.bSameColor) then
	    self:TransformCard(bTempCardData, cbCardCount, bKcount, 
        GameLogic.CT_FIVE_FLUSH, tad, bTransCardData, TransData);
		return GameLogic.CT_FIVE_FLUSH;
    end
	--顺子	(5张牌 且 非同花 且 全单牌)
	if ( 5 == cbCardCount and not tad.bSameColor and 0 == (tad.bTwoCount+tad.bThreeCount+tad.bFourCount) ) then				 	
	--A当1用，有A 且 第二大数字小于等于5, 最小顺子A2345
		if (14 == self:GetCardLogicValue(bTempCardData[1]) and 5 >= self:GetCardLogicValue(bTempCardData[2])) then		
		    self:TransformCard(bTempCardData, cbCardCount, bKcount, 
            GameLogic.CT_FIVE_MIXED_FLUSH_FIRST_A, tad, bTransCardData, TransData);
			return GameLogic.CT_FIVE_MIXED_FLUSH_FIRST_A;
        end
        -- 最大牌减去最小牌小于等于4
        if ( 4 >= self:GetCardLogicValue(bTempCardData[1]) - self:GetCardLogicValue(bTempCardData[5- bKcount]) ) then
		    self:TransformCard(bTempCardData, cbCardCount, bKcount, 
            GameLogic.CT_FIVE_MIXED_FLUSH_NO_A, tad, bTransCardData, TransData);
			return GameLogic.CT_FIVE_MIXED_FLUSH_NO_A;
        end
    end

	--三条  (3或5张牌 且 单王2张数目等于1或双王全单牌)
	if ( (1 == bKcount and 1 == tad.bTwoCount) or (2 == bKcount and 0 == (tad.bTwoCount+tad.bThreeCount+tad.bFourCount)) ) then
	    self:TransformCard(bTempCardData, cbCardCount, bKcount, 
        GameLogic.CT_THREE, tad, bTransCardData, TransData);
		return GameLogic.CT_THREE;
    end

	--两对  (不存在)

	--一对  (3或5张牌 且单王全单牌)
	if (1 == bKcount and 0 == (tad.bTwoCount+tad.bThreeCount+tad.bFourCount)) then
	    self:TransformCard(bTempCardData, cbCardCount, bKcount, 
        GameLogic.CT_ONE_DOUBLE, tad, bTransCardData, TransData);
		return GameLogic.CT_ONE_DOUBLE;
    end

    --这里正常来说是不可能到的，到了只能说有Bug。。。
    return GameLogic.CT_SINGLE;
end

function GameLogic:SortCardList(bCardData,bCardCount,SortCardType)
    assert(bCardCount>=1 and bCardCount<=13);
	if(bCardCount<1 or bCardCount>13) then
     return;
    end
    --转换数值
	local bLogicVolue = {}
    for i = 1, bCardCount do
        bLogicVolue[i]=self:GetCardLogicValue(bCardData[i]);
    end   		

	if(self.enDescend==SortCardType) then
	    --排序操作
		local bSorted=true;
		local bTempData = 0;
        local bLast=bCardCount-1;
		local m_bCardCount=1;
        repeat
            bSorted=true;
             for i = 1, bLast do
                if ((bLogicVolue[i]<bLogicVolue[i+1]) or 
					    ((bLogicVolue[i]==bLogicVolue[i+1]) and (bCardData[i]<bCardData[i+1]))) then
				         --交换位置
					    bTempData=bCardData[i];
					    bCardData[i]=bCardData[i+1];
					    bCardData[i+1]=bTempData;
					    bTempData=bLogicVolue[i];
					    bLogicVolue[i]=bLogicVolue[i+1];
					    bLogicVolue[i+1]=bTempData;
					    bSorted=false;  
                 end
            end
			bLast = bLast - 1;
        until (bSorted==true);     
	elseif(self.enAscend==SortCardType) then
	    --排序操作
		local bSorted=true;
		local bTempData = 0;
        local bLast=bCardCount-1;
		local m_bCardCount=1;
        repeat 
            bSorted=true
            for i = 1, bLast do
                if ((bLogicVolue[i]>bLogicVolue[i+1]) or
					((bLogicVolue[i]==bLogicVolue[i+1]) and (bCardData[i]>bCardData[i+1]))) then
                    --交换位置
					bTempData=bCardData[i];
					bCardData[i]=bCardData[i+1];
					bCardData[i+1]=bTempData;
					bTempData=bLogicVolue[i];
					bLogicVolue[i]=bLogicVolue[i+1];
					bLogicVolue[i+1]=bTempData;
					bSorted=false;
				end
            end
            bLast = bLast - 1;
        until(bSorted==true)
	elseif(self.enColor==SortCardType) then
	    --排序操作
		local bSorted=true;
		local bTempData = 0;
        local bLast=bCardCount-1;
		local m_bCardCount=1;
		local bColor = {};
        for i = 1, bCardCount do
            bColor[i]=self:GetCardColor(bCardData[i]);
        end

        repeat
            bSorted = true
            for i = 1, bLast do
                if ((bColor[i]<bColor[i+1]) or
					((bColor[i]==bColor[i+1]) and (self:GetCardLogicValue(bCardData[i])<self:GetCardLogicValue(bCardData[i+1])))) then
				    --交换位置
					bTempData=bCardData[i];
					bCardData[i]=bCardData[i+1];
					bCardData[i+1]=bTempData;
					bTempData=bColor[i];
					bColor[i]=bColor[i+1];
					bColor[i+1]=bTempData;
					bSorted=false;
                end
            end
            bLast = bLast - 1; 
        until (bSorted==true);
	else 
	--MyMsgBox(_T("错误排列类型！")) ;
    end

	return;
end
--分析3-5张的牌数据
function GameLogic:AnalyseCard(bCardDataList,bCardCount,AnalyseData)
    --排列扑克
	local bCardData=self:copyTab(bCardDataList);
    for i = 1,bCardCount do
        if (bCardData[i] == 0x41 or bCardData[i] == 0x42) then
			bCardData[i] = 0;
        end
    end 
	
	self:SortCardList(bCardData , bCardCount , self.enDescend);

	--变量定义
	local bSameCount = 1;
	local bCardValueTemp=0;
	local bSameColorCount = 1;
    --记录下标  
    local bFirstCardIndex = 1 ;	

	local bLogicValue=self:GetCardLogicValue(bCardData[1]);
	local bCardColor = self:GetCardColor(bCardData[1]);

	assert(3==bCardCount or 5==bCardCount) ;

	--设置结果
	--memset(&AnalyseData,0,sizeof(AnalyseData));

	--扑克分析
    for i = 2,bCardCount do
        --获取扑克
        bCardValueTemp=self:GetCardLogicValue(bCardData[i]);
		if (bCardValueTemp==bLogicValue) then
         bSameCount = bSameCount + 1;
        end

		--保存结果
		if ((bCardValueTemp ~= bLogicValue) or (i==(bCardCount)) or bCardData[i]==0) then
            if (bSameCount == 1) then
                --一张
            elseif (bSameCount == 2) then
                --二张
                AnalyseData.bTwoFirst[AnalyseData.bTwoCount + 1]	 = bFirstCardIndex ;
				AnalyseData.bTwoCount = AnalyseData.bTwoCount +1 ;
            elseif (bSameCount == 3) then
                --三张
                AnalyseData.bThreeFirst[AnalyseData.bThreeCount + 1] = bFirstCardIndex ;
				AnalyseData.bThreeCount = AnalyseData.bThreeCount +1 ;
	        elseif (bSameCount == 4) then
                --四张
                AnalyseData.bFourFirst[AnalyseData.bFourCount + 1]   = bFirstCardIndex ;
				AnalyseData.bFourCount = AnalyseData.bFourCount +1 ;
			elseif (bSameCount == 5) then
                --五相
                AnalyseData.bFiveFirst[AnalyseData.bFiveCount + 1]   = bFirstCardIndex ;
				AnalyseData.bFiveCount = AnalyseData.bFiveCount +1 ;
            else
                --MyMsgBox(_T("AnalyseCard：错误扑克！: %d") , bSameCount) ;
			end
		end

		--王牌自动转化同花
		if (bCardData[i] == 0) then	
		    bSameColorCount = bSameColorCount + (bCardCount-i + 1);
			break;
        end
		--设置变量
		if (bCardValueTemp~=bLogicValue) then
            if(bSameCount==1) then
			    if(i~=bCardCount) then
				    AnalyseData.bOneFirst[AnalyseData.bOneCount + 1]	= bFirstCardIndex ;
					AnalyseData.bOneCount = AnalyseData.bOneCount + 1 ;
				else
                    AnalyseData.bOneFirst[AnalyseData.bOneCount + 1]	= bFirstCardIndex ;
					AnalyseData.bOneCount= AnalyseData.bOneCount + 1 ;
					AnalyseData.bOneFirst[AnalyseData.bOneCount + 1]	= i ;
					AnalyseData.bOneCount = AnalyseData.bOneCount + 1 ;		
				end
			else
			    if(i==bCardCount) then
				    AnalyseData.bOneFirst[AnalyseData.bOneCount + 1]	= i ;
					AnalyseData.bOneCount = AnalyseData.bOneCount + 1;
                end 
            end
			bSameCount=1;
			bLogicValue=bCardValueTemp;
			bFirstCardIndex = i ;
		end
		if(self:GetCardColor(bCardData[i])~=bCardColor) then
            bSameColorCount = 1 ;
		else
            bSameColorCount = bSameColorCount + 1 ;
        end									   
    end

	--是否同花
    if (bCardCount==bSameColorCount) then
        AnalyseData.bSameColor = true
    else
         AnalyseData.bSameColor = false
    end
   
end

function GameLogic:TransformCard(cbNkCardData,bCardCount,bKCount,bCardType,tad,bTransCardData,TransData)
    assert( (3==bCardCount or 5==bCardCount) and (1==bKCount or 2==bKCount) );

	--变量定义
	local	cardList = {};			--记录转化后牌数组		
	local bTempCardData = {0,0,0,0,0};

	--初始化
    for i = 1,bCardCount-bKCount do
        bTempCardData[i] = cbNkCardData[i]
    end
    for i = 1,bCardCount-bKCount do
        table.insert(cardList,i,bTempCardData[i]);
    end

	--转化开始
    -- A在前同花顺
    -- 同花顺牌
    -- A在前顺子
    -- 没A杂顺
    if (bCardType == GameLogic.CT_FIVE_STRAIGHT_FLUSH_FIRST_A 
        or bCardType == GameLogic.CT_FIVE_STRAIGHT_FLUSH 
        or bCardType == GameLogic.CT_FIVE_MIXED_FLUSH_FIRST_A
        or bCardType == GameLogic.CT_FIVE_MIXED_FLUSH_NO_A) then
        --顺子的转化算法是从非王最小牌开始,
        --往上增直到非王最大牌发现有空缺先填空缺，没有空缺则根据是否到终点填充两头

        --数据校验
        assert(5==bCardCount);
        --升序排列			(仅顺子使用升序排列)
        self:SortCardList(bTempCardData, 5-bKCount, self.enAscend);
        --清空链表
        cardList = {};
        --定义变量
        local bLogicHeadCard = 0;		--最小牌的逻辑值
		local bTempCount = 1;			--转化进行到的位置
	    local bCardColor = self:GetCardColor(bTempCardData[1]);
        
        --填充首部
        -- A在前同花顺
        -- A在前顺子
        -- A在后同花顺
        if (bCardType == GameLogic.CT_FIVE_STRAIGHT_FLUSH_FIRST_A or 
			bCardType == GameLogic.CT_FIVE_MIXED_FLUSH_FIRST_A or
			bCardType == GameLogic.CT_FIVE_STRAIGHT_FLUSH_BACK_A) then
			    if (self:IsIncludeA(bTempCardData,bCardCount)) then
				    bLogicHeadCard = 1;
                    table.insert(cardList,bTempCardData[5-bKCount]);
					bTempCount = 1;
                 else
					bLogicHeadCard = self:GetCardLogicValue(bTempCardData[1]);
					table.insert(cardList,bTempCardData[1]);
					bTempCount = 2;
				 end
		else 
			    bLogicHeadCard = self:GetCardLogicValue(bTempCardData[1]);
			    table.insert(cardList,bTempCardData[1]);
			    bTempCount = 2;
        end

        --填充剩余
        for i = 2, 5 do
            if (self:GetCardLogicValue(bTempCardData[bTempCount]) ~= bLogicHeadCard+i-1) then	
		        local transCard = 0;
			    if (bCardType == GameLogic.CT_FIVE_STRAIGHT_FLUSH_FIRST_A or 
						    bCardType == GameLogic.CT_FIVE_STRAIGHT_FLUSH or 
						    bCardType == GameLogic.CT_FIVE_STRAIGHT_FLUSH_BACK_A) then
                            --bCardColor<<4
				    transCard = (bCardColor * 16) + bLogicHeadCard + i - 1;
			    else
					transCard = 0x30 + bLogicHeadCard + i - 1;
                end
                -- change by Owen, 2018.5.4, end 要移动到上面去
                table.insert(cardList,transCard);
                table.insert(TransData.transList,transCard);
                -- end
		    else
			    table.insert(cardList,bTempCardData[bTempCount]);
			    bTempCount = bTempCount + 1;
            end
		    if (bTempCount == 5 - bKCount + 1) then
			    break;
            end
        end

        --剩余王牌
		if (table.getn(cardList) ~= 5) then
		    while (table.getn(cardList) < 5) do
                    -- local bLastCard = cardList[1];
					-- local bFirstCard = cardList[table.getn(cardList)];
                    local bLastCard  = cardList[table.getn(cardList)];
                    local bFirstCard = cardList[1];

					local transCard = 0;
					local bMaxEnd = (self:GetCardLogicValue(bLastCard)==14);
					if (self:GetCardLogicValue(bLastCard) == 5) then
                        bMaxEnd = true;
                    end

                    local cbByte1 = 0;
                    if  bMaxEnd == true then
                        cbByte1 = bFirstCard;
                    else
                        cbByte1 = bLastCard;
                    end
                    local cbByte11 = 0;
                    if  bMaxEnd == true then
                        cbByte11 = -1;
                    else
                        cbByte11 = 1;
                    end
					local bExValue = self:GetCardLogicValue(cbByte1) + cbByte11;
					if (bExValue == 14) then
                    	bExValue = 1;
                    end
					if (bCardType == GameLogic.CT_FIVE_STRAIGHT_FLUSH_FIRST_A or 
						bCardType == GameLogic.CT_FIVE_STRAIGHT_FLUSH or
						bCardType == GameLogic.CT_FIVE_STRAIGHT_FLUSH_BACK_A) then
                        --bCardColor<<4
						transCard = (bCardColor * 16) + bExValue;
					else
						transCard = 0x30 + bExValue;
                    end		

					if (bMaxEnd) then
                        table.insert(cardList,1,transCard);
					else
						 table.insert(cardList,transCard);
                    end
                    table.insert(TransData.transList,transCard);
			end
        end
    elseif(bCardType == GameLogic.CT_FIVE_FIVE) then --五相的转化算法是直接找到3张的或者4张的，王变成同值的黑桃牌
        assert(5==bCardCount);
        local bKingValue = TransData.bHaveKing;
		local transCard = 0x30 + self:GetCardValue(bTempCardData[1]);

			if (bKingValue - 2 >= 0) then
                table.insert(cardList,transCard);
                table.insert(TransData.transList,transCard);
				bKingValue = bKingValue - 2;
			end
			if (bKingValue == 1) then
			    table.insert(cardList,transCard);
                table.insert(TransData.transList,transCard);
            end
    elseif(bCardType == GameLogic.CT_FIVE_FOUR_ONE) then--炸弹的转化算法是直接找到3张的或者2张的，王变成同值的黑桃牌
        --数据校验
        assert(5==bCardCount);
        --王牌转化
        if (bKCount == 1) then
            local transCard = 0x30 + self:GetCardValue(bTempCardData[tad.bThreeFirst[1]]);
            table.insert(cardList,transCard);
            table.insert(TransData.transList,transCard);
        else 
            if (tad.bThreeCount == 1) then
                    local transCard = 0x30 + self:GetCardValue(bTempCardData[tad.bThreeFirst[1]]);
                    table.insert(cardList,transCard);
                    table.insert(TransData.transList,transCard);

                    if ( self:GetCardLogicValue(bTempCardData[tad.bThreeFirst[1]]) == 14) then
                        transCard = 0x3D;
                    else
                        transCard = 0x31;
                    end
                    table.insert(cardList,transCard);
                    table.insert(TransData.transList,transCard);
            else 
                    local transCard = 0x30 + self:GetCardValue(bTempCardData[tad.bTwoFirst[1]]);
                    table.insert(cardList,transCard);
                    table.insert(cardList,transCard);
                    table.insert(TransData.transList,transCard);
                    table.insert(TransData.transList,transCard);
            end
        end
    elseif(GameLogic.CT_FIVE_THREE_DEOUBLE == bCardType) then --葫芦的转化算法是直接找到2对2张中大的，王变成同值的黑桃牌
            --数据校验
            assert(5==bCardCount and bKCount==1);

            --王牌转化
            local transCard = 0x30 + self:GetCardValue(bTempCardData[tad.bTwoFirst[1]]);
            table.insert(cardList,transCard);
            table.insert(TransData.transList,transCard);
    elseif(GameLogic.CT_FIVE_FLUSH == bCardType) then--同花的转化算法是王变成同花
            --数据校验
            assert(5==bCardCount);

            local bCardColor = self:GetCardColor(bTempCardData[1]);

            --王牌转化
            while (table.getn(cardList) < 5) do
                --bCardColor<<4
                local transCard = (bCardColor*16) + 0x01;
                table.insert(cardList,transCard);
                table.insert(TransData.transList,transCard);
            end
    elseif(GameLogic.CT_THREE == bCardType) then -- 三条的转化算法是直接找到2张的或者单牌最大的，王变成同值的黑桃牌
            --王牌转化
			if (tad.bTwoCount == 1) then
    			local transCard = 0x30 + self:GetCardValue(bTempCardData[tad.bTwoFirst[1]]);
                table.insert(cardList,transCard);
                table.insert(TransData.transList,transCard);
			else
			    while (table.getn(cardList) < bCardCount) do
                    local transCard = 0x30 + self:GetCardValue(bTempCardData[1]);
                    table.insert(cardList,transCard);
                    table.insert(TransData.transList,transCard);
                end
            end
    elseif(GameLogic.CT_ONE_DOUBLE == bCardType) then -- 一对的转化算法是直接找到单牌最大的，王变成同值的黑桃牌
            --数据校验
            assert(1==bKCount);

            --王牌转化
            local transCard = 0x30 + self:GetCardValue(bTempCardData[1]);
            table.insert(cardList,transCard);
            table.insert(TransData.transList,transCard);
    else
       -- MyMsgBox(_T("CGameLogic::TransFormCard [%d]"), bCardType);
    end 
	
    -- change by Owen, 2018.5.1, 去掉下面这个报错
    for i = 1,bCardCount do
        bTransCardData[i] = cardList[i];
    end

	--填充信息
	-- assert(cardList.GetCount() == 5 or cardList.GetCount() == 3);
 --    for i = 1,bCardCount do
 --        bTransCardData[i] = cardList.GetAt(cardList.FindIndex(i));
 --    end
end

--判断散牌中是否有A
function GameLogic:IsIncludeA(bCardData,bCardCount)
    for i = 1, bCardCount do
	    if self:GetCardLogicValue(bCardData[i]) == 14 then
            return true
		end
	end
    return false
end
--分析13张牌的数据
function GameLogic:AnalyseCardWithoutKing(bCardDataList,bCardCount,AnalyseData)
    --初始化数据
	for i=1,4 do
		AnalyseData.bSameColorData[i] = {}
		for j=1,13 do
			AnalyseData.bSameColorData[i][j] = 0
		end
		table.insert(AnalyseData.bSameColorCount,0)
        --AnalyseData.bSameColorData[i] = {0,0,0,0,0,0,0,0,0,0,0,0,0};
        --AnalyseData.bSameColorCount[i]=0;
    end
    for i=1,13 do
		AnalyseData.bAllOne[i] = {}
		for j=1,4 do
			AnalyseData.bAllOne[i][j] =0
		end
		table.insert(AnalyseData.bAllOneCount,0)
        --AnalyseData.bAllOne[i] = {0,0,0,0};
        --AnalyseData.bAllOneCount[i] = 0;
    end
    --排列扑克
    local bCardData = self:copyTab(bCardDataList);
    --设置结果
    --memset(&AnalyseData,0,sizeof(AnalyseData));
    --CopyMemory(bCardData , bCardDataList , bCardCount) ;

    self:SortCardList(bCardData , bCardCount , self.enDescend) ;

    for i = 1,bCardCount do
        if (bCardData[i] == 0x41 or bCardData[i] == 0x42) then
            bCardData[i] = 0;
        end
    end

    local cbSingleByte = 0xff;
    for i = 1,bCardCount do
        if (bCardData[i] == 0) then
            AnalyseData.bWangCount = AnalyseData.bWangCount + 1;
            AnalyseData.bWangData[AnalyseData.bWangCount] = i;
        else 
            local bCardColor = self:GetCardColor(bCardData[i]);
            bCardColor = bCardColor + 1; -- 数组下标从1开始
            local nCount = AnalyseData.bSameColorCount[bCardColor];
            AnalyseData.bSameColorData[bCardColor][nCount + 1] = bCardData[i];
            AnalyseData.bSameColorCount[bCardColor] = AnalyseData.bSameColorCount[bCardColor] +1;

            if (cbSingleByte ~= self:GetCardLogicValue(bCardData[i])) then
                cbSingleByte = bCardData[i];
                --AnalyseData.bAllOne[AnalyseData.bAllOneCount++] = cbSingleByte;
            end
        end
    end

    --变量定义
    local bSameCount = 1 ;
    local bCardValueTemp=0;
    local bSameColorCount = 1 ;
    local bFirstCardIndex = 1 ;   --记录下标

    local bLogicValue=self:GetCardLogicValue(bCardData[1]);
    local bCardColor =self:GetCardColor(bCardData[1]) ;

    --ASSERT(3==bCardCount || 5==bCardCount) ;

    --扑克分析
    for i = 2,bCardCount do
        --获取扑克
        if (bCardData[i] ~= 0) then

            bCardValueTemp=self:GetCardLogicValue(bCardData[i]);
            if (bCardValueTemp==bLogicValue) then
                bSameCount = bSameCount + 1;
            end

            --保存结果
            if ((bCardValueTemp~=bLogicValue) or (i==(bCardCount))) then
                if(bSameCount == 1) then --一张
                elseif(bSameCount == 2) then --两张
                    AnalyseData.bTwoFirst[AnalyseData.bTwoCount + 1]     = bFirstCardIndex ;
                    AnalyseData.bTwoCount = AnalyseData.bTwoCount + 1;
                elseif(bSameCount == 3) then --三张
                    AnalyseData.bThreeFirst[AnalyseData.bThreeCount + 1] = bFirstCardIndex ;
                    AnalyseData.bThreeCount = AnalyseData.bThreeCount + 1 ;
                elseif(bSameCount == 4) then --四张
                    AnalyseData.bFourFirst[AnalyseData.bFourCount + 1]   = bFirstCardIndex ;
                    AnalyseData.bFourCount =  AnalyseData.bFourCount + 1;
                elseif(bSameCount == 5) then --五相
                    AnalyseData.bFiveFirst[AnalyseData.bFiveCount + 1]   = bFirstCardIndex ;
                    AnalyseData.bFiveCount = AnalyseData.bFiveCount + 1 ;
                else
                    --MyMsgBox(_T("AnalyseCard：错误扑克！: %d") , bSameCount) ;
                end
            end

            --王牌自动转化同花
            if (bCardData[i] == 0) then
                bSameColorCount = bSameColorCount + (bCardCount-i + 1);
                break;
            end

            --设置变量
            if (bCardValueTemp~=bLogicValue) then
                if(bSameCount==1) then
                    if(i~=bCardCount) then
                        AnalyseData.bOneFirst[AnalyseData.bOneCount + 1]    = bFirstCardIndex ;
                        AnalyseData.bOneCount = AnalyseData.bOneCount + 1 ;
                    else
                        AnalyseData.bOneFirst[AnalyseData.bOneCount + 1]    = bFirstCardIndex ;
                        AnalyseData.bOneCount = AnalyseData.bOneCount + 1 ;
                        AnalyseData.bOneFirst[AnalyseData.bOneCount + 1]    = i ;
                        AnalyseData.bOneCount = AnalyseData.bOneCount + 1 ;    
                    end
                else
                    if(i==bCardCount) then
                        AnalyseData.bOneFirst[AnalyseData.bOneCount + 1]    = i ;
                        AnalyseData.bOneCount = AnalyseData.bOneCount + 1 ;
                    end
                end
                bSameCount=1;
                bLogicValue=bCardValueTemp;
                bFirstCardIndex = i ;
            end
            if(self:GetCardColor(bCardData[i])~=bCardColor) then
                bSameColorCount = 1 ;
            else         
                bSameColorCount = bSameColorCount + 1 ;
            end
        elseif i == bCardCount then
            --保存结果
            if(bSameCount == 1) then --一张
            elseif(bSameCount == 2) then --两张
                AnalyseData.bTwoFirst[AnalyseData.bTwoCount + 1]     = bFirstCardIndex ;
                AnalyseData.bTwoCount = AnalyseData.bTwoCount + 1;
            elseif(bSameCount == 3) then --三张
                AnalyseData.bThreeFirst[AnalyseData.bThreeCount + 1] = bFirstCardIndex ;
                AnalyseData.bThreeCount = AnalyseData.bThreeCount + 1 ;
            elseif(bSameCount == 4) then --四张
                AnalyseData.bFourFirst[AnalyseData.bFourCount + 1]   = bFirstCardIndex ;
                AnalyseData.bFourCount =  AnalyseData.bFourCount + 1;
            elseif(bSameCount == 5) then --五相
                AnalyseData.bFiveFirst[AnalyseData.bFiveCount + 1]   = bFirstCardIndex ;
                AnalyseData.bFiveCount = AnalyseData.bFiveCount + 1 ;
            else
                --MyMsgBox(_T("AnalyseCard：错误扑克！: %d") , bSameCount) ;
            end
        end
    end

    --是否同花
    if (5==bSameColorCount) then
        AnalyseData.bSameColor = true;
    else
        AnalyseData.bSameColor = false;
    end
    return;
end
--拷贝表
function GameLogic:copyTab(st)
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

 function GameLogic:RandCardList(bCardBuffer,bBufferCount)
    --混乱准备
    local bTotalCount = #GameLogic.m_bCardListData;
    local bCardData = GameLogic:copyTab(GameLogic.m_bCardListData);
    --CopyMemory(bCardData,m_bCardListData,sizeof(m_bCardListData));

    --srand((unsigned)time(NULL));
    math.randomseed(os.time());

    --混乱扑克
    local bRandCount=0;
    local bPosition=1;
    repeat
        bPosition = math.random(1,bTotalCount-bRandCount);
        bCardBuffer[bRandCount + 1]=bCardData[bPosition];
        bRandCount = bRandCount + 1;
        bCardData[bPosition]=bCardData[bTotalCount-bRandCount + 1];
    until (bRandCount>=bBufferCount)
    return;
 end
function GameLogic:CompareCard(bInFirstList, bInNextList, bFirstCount, bNextCount , bComperWithOther)
	--定义变量
	local bFirstList = {};
	local bNextList = {};
	local FirstAnalyseData = {bOneCount = 0,bTwoCount = 0,bThreeCount = 0,
          bFourCount = 0,bFiveCount=0,bWangCount=0,bOneFirst={},
          bTwoFirst={},bThreeFirst={},bFourFirst={},bFiveFirst={},
          bWangData={},bSameColorData={},bSameColorCount={},
          bAllOne={},bAllOneCount={},bSameColor=0};
	local NextAnalyseData = {bOneCount = 0,bTwoCount = 0,bThreeCount = 0,
          bFourCount = 0,bFiveCount=0,bWangCount=0,bOneFirst={},
          bTwoFirst={},bThreeFirst={},bFourFirst={},bFiveFirst={},
          bWangData={},bSameColorData={},bSameColorCount={},
          bAllOne={},bAllOneCount={},bSameColor=0};
	local ttdFst = {bKingCount=0,bHaveKing=0,transList = {}};
	local ttdNxt = {bKingCount=0,bHaveKing=0,transList = {}};
	--检查转化
	self:AnalyseMaxTransform(bInFirstList, bFirstCount, bFirstList, ttdFst);
	self:AnalyseMaxTransform(bInNextList, bNextCount, bNextList, ttdNxt);
	--排序牌组
	self:SortCardList(bFirstList , bFirstCount , self.enDescend) ;
	self:SortCardList(bNextList , bNextCount , self.enDescend) ;
	--分析牌组
	self:AnalyseCard(bFirstList , bFirstCount , FirstAnalyseData) ;	
	self:AnalyseCard(bNextList  , bNextCount  , NextAnalyseData) ;	
	--数据验证
	assert(bFirstCount==(FirstAnalyseData.bOneCount+FirstAnalyseData.bTwoCount*2+FirstAnalyseData.bThreeCount*3+FirstAnalyseData.bFourCount*4+FirstAnalyseData.bFiveCount*5)) ;
	--assert(bNextCount=(NextAnalyseData.bOneCount+NextAnalyseData.bTwoCount*2+NextAnalyseData.bThreeCount*3+NextAnalyseData.bFourCount*4+NextAnalyseData.bFiveCount*5)) ;
	if(bFirstCount~=(FirstAnalyseData.bOneCount+FirstAnalyseData.bTwoCount*2+FirstAnalyseData.bThreeCount*3+FirstAnalyseData.bFourCount*4+FirstAnalyseData.bFiveCount*5)) then
		return false ;
	end
	if(bNextCount ~= (NextAnalyseData.bOneCount + NextAnalyseData.bTwoCount*2 + NextAnalyseData.bThreeCount*3+NextAnalyseData.bFourCount*4+NextAnalyseData.bFiveCount*5)) then
		return false ;
	end
	if(not ((bFirstCount==bNextCount) or (bFirstCount~=bNextCount and (3==bFirstCount and 5==bNextCount or 5==bFirstCount and 3==bNextCount)))) then
		return false ;
	end
	assert(3==bNextCount or 5==bNextCount) ;
	assert(3==bFirstCount or 5==bFirstCount) ;
	--获取类型
	local bNextType=self:GetCardType(bNextList,bNextCount);
	local bFirstType=self:GetCardType(bFirstList,bFirstCount);

	assert(GameLogic.CT_INVALID~=bNextType and GameLogic.CT_INVALID~=bFirstType) ;
	if(GameLogic.CT_INVALID==bFirstType or GameLogic.CT_INVALID==bNextType) then
		return false ;
	end
	--同段比较
	if(true==bComperWithOther) then
		--开始对比
		if(bNextType==bFirstType) then
			if bFirstType == GameLogic.CT_SINGLE then --单牌类型
				--数据验证
				--assert(bNextList[1]~=bFirstList[1]) ;
				--if(bNextList[1]==bFirstList[1]) then
				--	return false ;
				--end
				local bAllSame=true ;
				for i=1,bFirstCount do
					if(self:GetCardLogicValue(bNextList[i]) ~= self:GetCardLogicValue(bFirstList[i])) then
						bAllSame = false ;
					end
				end
				
				if(true==bAllSame) then
					return 0;			--比较花色
				else
					for i=1,bFirstCount do
						if(self:GetCardLogicValue(bNextList[i]) ~= self:GetCardLogicValue(bFirstList[i])) then
							if self:GetCardLogicValue(bNextList[i]) < self:GetCardLogicValue(bFirstList[i]) then
								return -1;
							else
								return 1;
							end
						end
					end
					return false ;
				end
				return false ;
			elseif bFirstType == GameLogic.CT_ONE_DOUBLE then --对带一张
				if(self:GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[1]])==self:GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[1]])) then
					if(self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[1]]) ~= self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[1]])) then
						if self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[1]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[1]]) then
							return -1
						else
							return 1
						end
					else	
						--不考虑带王情况
						--return CompareOneCardEx(bFirstList[FirstAnalyseData.bTwoFirst[0]], bNextList[NextAnalyseData.bTwoFirst[0]], ttdFst, ttdNxt);
						for i = 1,FirstAnalyseData.bOneCount do
							if (self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[i]]) ~= self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[i]])) then
								if self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[i]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[i]]) then
									return -1
								else
									return 1
								end
							end
						end
						return 0;
					end
				else 
					if self:GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[1]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[1]]) then
						return -1
					else
						return 1
					end
				end
			elseif bFirstType == GameLogic.CT_FIVE_TWO_DOUBLE then --两对牌型
				--数据验证
				assert(bNextList[NextAnalyseData.bTwoFirst[1]]~=bFirstList[FirstAnalyseData.bTwoFirst[1]]);
				assert(ttdFst.bKingCount+ttdNxt.bKingCount==0);
				if(bNextList[NextAnalyseData.bTwoFirst[1]]==bFirstList[FirstAnalyseData.bTwoFirst[1]] or ttdFst.bKingCount+ttdNxt.bKingCount~=0) then
					return false ;
				end
				if(self:GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[1]])==self:GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[1]])) then
					if(self:GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[2]])==self:GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[2]])) then
						if(self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[1]]) ~= self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[1]])) then
							if self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[1]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[1]]) then
								return -1
							else
								return 1
							end
						else
							return 0;
						end
					else 
						if self:GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[2]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[2]]) then
							return -1
						else
							return 1
						end
					end
				else
					--比较数值
					if self:GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[1]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[1]]) then
						return -1
					else
						return 1
					end
				end
			elseif bFirstType == GameLogic.CT_FIVE_THREE_DEOUBLE then --三条一对
				if (self:GetCardLogicValue(bNextList[NextAnalyseData.bThreeFirst[1]]) ~= self:GetCardLogicValue(bFirstList[FirstAnalyseData.bThreeFirst[1]])) then
					if self:GetCardLogicValue(bNextList[NextAnalyseData.bThreeFirst[1]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bThreeFirst[1]]) then
						return -1 
					else
						return 1
					end
				else
					if (self:GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[1]]) == self:GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[1]])) then
						if(ttdFst.bHaveKing and ttdNxt.bHaveKing) then
							return 0;
						elseif (ttdFst.bHaveKing ==0 and ttdNxt.bHaveKing == 0) then
							return 0;
						else
							if (ttdFst.bHaveKing) then
								return 1;
							else
								return -1;
							end
						end
					else
						if self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[1]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[1]]) then
							return -1
						else	
							return 1
						end
					end
				end
			elseif bFirstType == GameLogic.CT_THREE then --三张牌型
				if (bFirstCount == 3)  then
					return self:CompareOneCardEx(bFirstList[FirstAnalyseData.bThreeFirst[1]], bNextList[NextAnalyseData.bThreeFirst[1]], ttdFst, ttdNxt);
				else
					--比较3张中最大一张
					if (self:GetCardLogicValue(bFirstList[FirstAnalyseData.bThreeFirst[1]]) ~=  self:GetCardLogicValue(bNextList[NextAnalyseData.bThreeFirst[1]])) then
						--return GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[1]]) < GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[1]])?-1:1;
						if self:GetCardLogicValue(bNextList[NextAnalyseData.bThreeFirst[1]]) <  self:GetCardLogicValue(bFirstList[FirstAnalyseData.bThreeFirst[1]]) then
							return -1
						else
							return 1
						end
					else
						if (self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[1]]) == self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[1]])) then
							if (self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[2]]) == self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[2]])) then
								return self:CompareOneCardEx(bFirstList[FirstAnalyseData.bThreeFirst[1]], bNextList[NextAnalyseData.bThreeFirst[1]], ttdFst, ttdNxt);
							else
								if self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[2]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[2]]) then
									return -1
								else
									return 1
								end
							end
						else
							if self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[1]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[1]]) then
								return -1
							else
								return 1
							end
						end
					end 
				end
			--A在前顺子  没A杂顺 A在后顺子
			elseif bFirstType == GameLogic.CT_FIVE_MIXED_FLUSH_FIRST_A or bFirstType == GameLogic.CT_FIVE_MIXED_FLUSH_NO_A or bFirstType == GameLogic.CT_FIVE_MIXED_FLUSH_BACK_A then
				--比较最大的一张牌
				if (self:GetCardLogicValue(bFirstList[2]) ~=  self:GetCardLogicValue(bNextList[2])) then
					if self:GetCardLogicValue(bNextList[1]) < self:GetCardLogicValue(bFirstList[1]) then
						return -1
					else
						return 1
					end
				else
					if(ttdFst.bHaveKing and ttdNxt.bHaveKing) then
						return 0;
					elseif(ttdFst.bHaveKing ==0 and ttdNxt.bHaveKing == 0) then
						return 0;
					else
						if (ttdFst.bHaveKing) then
							return 1;
						else
							return -1;
						end
					end
				end
			elseif bFirstType == GameLogic.CT_FIVE_FLUSH then --同花五牌        
                --第一个大于第二个 
                if NextAnalyseData.bTwoCount > FirstAnalyseData.bTwoCount then
                   return 1
                   end
                if NextAnalyseData.bTwoCount < FirstAnalyseData.bTwoCount then 
                   return  -1
                end
					
				if NextAnalyseData.bTwoCount == 2 then
					
						if (self:GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[1]]) == self:GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[1]])) then
						
							if(self:GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[2]]) == self:GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[2]])) then
							
								    if(self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[1]]) ~= self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[1]])) then

									  --  return GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[1]]) < GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[1]]) ? -1:1;
                                        if self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[1]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[1]]) then
                                            return -1;
                                        else
                                            return 1;
                                        end

								     else 
									    return 0;
								    end
							
							else 
								 --return GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[2]]) < GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[2]])?-1:1; 	--//比较数值
							
                               if self:GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[2]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[2]]) then
                                 return -1
                               else
                                 return 1
                               end
                            
                            
                            end
												
						else 
							--return GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[1]]) < GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[1]])?-1:1; 	--//比较数值
						
                                if self:GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[1]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[1]]) then
                                  return -1;
                                else
                                  return 1;
                                end
                        
                        
                        
                        end
				elseif NextAnalyseData.bTwoCount == 1 then
					
						if(self:GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[1]])==self:GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[1]])) then
						
							if(self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[1]]) ~= self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[1]]))  then
								--return GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[1]]) < GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[1]])?-1:1;
							 
                             if self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[1]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[1]]) then
                                return -1;
                             else
                                return 1;
                             end
                             
                             
                             else 
								
								for i = 1,NextAnalyseData.bOneCount do
								
									if (self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[i]]) ~= self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[i]])) then
										--return GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[i]]) < GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[i]])?-1:1;

                                        if self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[i]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[i]]) then
                                          return -1;
                                        else
                                            return 1
                                        end

									end

								end

								return 0;
							end
						
						else 
							--return GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[1]]) < GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[1]])?-1:1;
						
                        if self:GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[1]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[1]]) then
                          return -1;
                        else
                          return 1;
                        end
                        
                        
                        end
			 end

				for i = 1,5 do
					if(self:GetCardLogicValue(bNextList[i]) ~= self:GetCardLogicValue(bFirstList[i])) then
						return self:CompareOneCardEx(bFirstList[i], bNextList[i], ttdFst, ttdNxt);
					end
				end
				--都对比完后仍然没结果					
				return 0;
			elseif bFirstType == GameLogic.CT_FIVE_FOUR_ONE then --四带一张
				return self:CompareOneCardEx(bFirstList[FirstAnalyseData.bFourFirst[1]], bNextList[NextAnalyseData.bFourFirst[1]], ttdFst, ttdNxt);
			elseif bFirstType == GameLogic.CT_FIVE_FIVE then --五相
				return self:CompareOneCardEx(bFirstList[FirstAnalyseData.bFiveFirst[1]], bNextList[NextAnalyseData.bFiveFirst[1]], ttdFst, ttdNxt);
			--A在前同花顺 A在后同花顺 同花顺牌
			elseif bFirstType == GameLogic.CT_FIVE_STRAIGHT_FLUSH_FIRST_A or bFirstType == GameLogic.CT_FIVE_STRAIGHT_FLUSH_BACK_A or bFirstType == GameLogic.CT_FIVE_STRAIGHT_FLUSH then --五相
				--比较首牌
				if (self:GetCardLogicValue(bFirstList[1]) ~=  self:GetCardLogicValue(bNextList[1])) then
					if self:GetCardLogicValue(bNextList[1]) < self:GetCardLogicValue(bFirstList[1]) then
						return -1
					else
						return 1
					end
				else
					if(ttdFst.bHaveKing and ttdNxt.bHaveKing) then
						return 0;
					elseif (ttdFst.bHaveKing ==0 and ttdNxt.bHaveKing == 0) then
						return 0;
					else
						if (ttdFst.bHaveKing) then
							return 1;
						else
							return -1;
						end
					end
				end
			else
				return false
			end
		else
			if (bNextType>bFirstType) then
				return  1;
			else
				return  -1;
			end
		end
	else
		assert(bFirstType==GameLogic.CT_SINGLE or bFirstType==GameLogic.CT_ONE_DOUBLE or bFirstType==GameLogic.CT_THREE);
		if (bFirstType ~= GameLogic.CT_SINGLE and bFirstType~=GameLogic.CT_ONE_DOUBLE and bFirstType~=GameLogic.CT_THREE) then
			return false;
		end
		--开始对比
		if(bNextType==bFirstType) then
			if bFirstType == GameLogic.CT_SINGLE then --单牌类型
				--数据验证
				--assert(bNextList[1]~=bFirstList[1]) ;
				--if(bNextList[1]==bFirstList[1]) then
				--	return false
				--end
				local bAllSame=true;
				for i = 1,3 do
					if(self:GetCardLogicValue(bNextList[i]) ~= self:GetCardLogicValue(bFirstList[i])) then
						bAllSame = false ;
					end
				end
				if(true==bAllSame) then
					return bNextCount > bFirstCount ;
				else
					for i = 1,3 do
						if(self:GetCardLogicValue(bNextList[i]) ~= self:GetCardLogicValue(bFirstList[i])) then
							if self:GetCardLogicValue(bNextList[i]) < self:GetCardLogicValue(bFirstList[i]) then
								return -1
							else
								return 1
							end
						end
					end
					return false ;
				end
				return bNextCount > bFirstCount ;
			elseif bFirstType == GameLogic.CT_ONE_DOUBLE then --对带一张
				if(self:GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[1]])==self:GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[1]])) then
					if(self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[1]]) ~= self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[1]])) then
						if self:GetCardLogicValue(bNextList[NextAnalyseData.bOneFirst[1]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bOneFirst[1]]) then
							return -1
						else
							return 1
						end
					else
						return self:CompareOneCardEx(bFirstList[FirstAnalyseData.bTwoFirst[1]], bNextList[NextAnalyseData.bTwoFirst[1]], ttdFst, ttdNxt);
					end
				else
					if self:GetCardLogicValue(bNextList[NextAnalyseData.bTwoFirst[1]]) < self:GetCardLogicValue(bFirstList[FirstAnalyseData.bTwoFirst[1]]) then
						return -1
					else
						return 1
					end
				end
				return bNextCount > bFirstCount ;
			elseif bFirstType == GameLogic.CT_THREE then --三张牌型
				--比较3张中最大一张
				return self:CompareOneCardEx(bFirstList[FirstAnalyseData.bThreeFirst[1]], bNextList[NextAnalyseData.bThreeFirst[1]], ttdFst, ttdNxt);
			else
				return false ;
			end
		else
			if (bNextType>bFirstType) then
				return  1;
			else
				return -1;
			end
		end
	end
	return 0;
end
function GameLogic:CompareOneCardEx(bFirstCard,bNextCard,ttdFst,ttdNxt)
	--牌值比较
	if (self:GetCardLogicValue(bFirstCard) ~= self:GetCardLogicValue(bNextCard)) then
		if (self:GetCardLogicValue(bFirstCard) < self:GetCardLogicValue(bNextCard)) then
			return 1;
		else
			return -1;
		end
	end
	--转化比较	(由王转化来的牌比普通同值牌大，大王转化来的大于小王转化来的)
	--不比较大小王
	local bFromTransFst = false;
	for i = 1,#ttdFst.transList do
		if bFirstCard == ttdFst.transList[i] then
			bFromTransFst = true
		end
	end
	local bFromTransNxt = false;
	for i = 1,#ttdNxt.transList do
		if bFirstCard == ttdNxt.transList[i] then
			bFromTransNxt = true
		end
	end
	if (bFromTransFst ~= bFromTransNxt) then
		if (bFromTransFst) then
			return 1;
		else
			return -1;
		end
	end
	return 0;
end

-- -- 这个函数只有在点击下面的顺子提示按钮的时候才会调用
-- function GameLogic:AnalysebCardDataDistributing(cbCardData,cbCardCount,Distributing)
-- 	local cbIndexCount = 4
-- 	for i = 1, 14 do
-- 		Distributing.cbCardCount[i] = 0
-- 		Distributing.cbDistributing[i] = {}
-- 		for j = 1,5 do
-- 			Distributing.cbDistributing[i][j] = 0
-- 		end
-- 	end
-- 	for i = 1,cbCardCount do
-- 		if (cbCardData[i]==0x41 or cbCardData[i]==0x42) then
-- 			local nCount = Distributing.cbCardCount[1];
-- 			Distributing.cbDistributing[1][nCount + 1] = cbCardData[i];
-- 			Distributing.cbCardCount[1] = Distributing.cbCardCount[1] + 1
-- 			--continue;
--         -- change by Owen, 2018.5.5, 处理点击顺子提示
-- 		else
--     		local cbCardColor=self:GetCardColor(cbCardData[i]);
--     		local cbCardValue=self:GetCardValue(cbCardData[i]);
--     		local nCount = Distributing.cbCardCount[cbCardValue + 1];
--     		Distributing.cbDistributing[cbCardValue + 1][nCount + 1] = cbCardData[i];
--     		Distributing.cbCardCount[cbCardValue + 1] = Distributing.cbCardCount[cbCardValue + 1] + 1
--         end
-- 	end
-- end

-- 这个函数只有在点击下面的顺子提示按钮的时候才会调用
-- 修改传入的 Distributing table
--[[ 
    表示自己手里有两个A
    Distributing = {
        cbCardCount =    {2,0,..}
        cbDistributing = {{1,17},{},..}
    }
]]
function GameLogic:AnalysebCardDataDistributing(cbCardData,cbCardCount,Distributing)
	local cbIndexCount = 4
	for i = 0, 14 do
		Distributing.cbCardCount[i] = 0
		Distributing.cbDistributing[i] = {}
		for j = 1,5 do
			Distributing.cbDistributing[i][j] = 0
		end
	end
	for i = 1,cbCardCount do
		if (cbCardData[i]==0x41 or cbCardData[i]==0x42) then
			local nCount = Distributing.cbCardCount[0];
			Distributing.cbDistributing[0][nCount + 1] = cbCardData[i];
			Distributing.cbCardCount[0] = Distributing.cbCardCount[0] + 1
			--continue;
        -- change by Owen, 2018.5.5, 处理点击顺子提示
		else
    		local cbCardColor=self:GetCardColor(cbCardData[i]);

            -- 获得牌的数值（1 -- 13）, 大小王就返回14
            local function myGetCardValue(cbCardData)
                -- change by, 2018.7.12, 大小王的时候返回14
                if (cbCardData == 0x41 or cbCardData == 0x42) then
                    return 14
                end
                return (cbCardData - math.floor(cbCardData/16)*16)
            end
    		local cbCardValue = myGetCardValue(cbCardData[i]);

    		local nCount = Distributing.cbCardCount[cbCardValue];
    		Distributing.cbDistributing[cbCardValue][nCount + 1] = cbCardData[i];
    		Distributing.cbCardCount[cbCardValue] = Distributing.cbCardCount[cbCardValue] + 1

            -- A 也可以当14用, 用来组成10JQKA
            if cbCardValue == 1 then
                local nCount = Distributing.cbCardCount[14];
                Distributing.cbDistributing[14][nCount + 1] = cbCardData[i];
                Distributing.cbCardCount[14] = Distributing.cbCardCount[14] + 1
            end
        end
	end
end

-- 这个函数只有在点击下面的同花顺提示按钮的时候才会调用
function GameLogic:AnalysebCardColorDistri(cbCardData,cbCardCount,AnalyseResult)
	
	for i = 1,cbCardCount do
		if (cbCardData[i] == 0x41 or cbCardData[i] == 0x42) then
            -- change by Owen, 2018.5.4, 增加点击同花顺按钮对王的处理
            AnalyseResult.cbKingCount = AnalyseResult.cbKingCount + 1
			AnalyseResult.cbKingData[AnalyseResult.cbKingCount] = cbCardData[i];
			--continue;
		else
    		local cbCardColor = self:GetCardColor(cbCardData[i]) + 1; --数组下标从1开始
    		AnalyseResult.cbDistributing[cbCardColor][AnalyseResult.cbCardCount[cbCardColor] + 1] = cbCardData[i];
    		local temp = AnalyseResult.cbCardCount[cbCardColor]
    		AnalyseResult.cbCardCount[cbCardColor] = temp + 1
    		--AnalyseResult.cbCardCount[cbCardColor] = AnalyseResult.cbCardCount[cbCardColor] +１；
        end
	end
end
function GameLogic:IsIncludeTongHuaShun(cbCardData,cbCardCount,cbOutCardData)
	
end
return GameLogic