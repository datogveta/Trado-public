//+------------------------------------------------------------------+
//|                                                   Hedging_V5.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Giorgi Gachechiladze"
#property link      "https://www.upwork.com/freelancers/~01e6281fb21a4a3862"
#property version   "5.3"
#property strict

#include <Trade/Trade.mqh>
#include <Trade/SymbolInfo.mqh>
enum EnumDirection{BUY,SELL,BUY_SELL};
enum EnumAmountType1{OFF,Equity_Percentage,Amount,Distance};
enum EnumAmountType2{OFF,Amount,Equity_Percentage};
enum EnumTrigger{Amount,Equity_Percentage};
enum EnumGridType{OFF,Refill,Normal};
enum EnumReopen{From_Last_Trade,From_Extremum_Price};
enum OnOff{OFF,ON};
enum EnumFilterType{Fill_Ignored,Just_Ignore};
enum EnumIncreaseType{Multiply,Add};
enum EnumOpenSide{BUY,SELL,BUY_SELL};
enum EnumDistType{Points,Pct,ATR};
enum EnumLotType{Pct,Fixed};
enum EnumSecondaryMRTInTP{OFF,All_Together,One_By_One,ODD_EVEN};
enum EnumMATrigger{OFF,MA_MID,MA_SLOW};
enum EnumMATrigger1{MA_MID,MA_SLOW};
enum EnumDontReOpenType{OFF,Self_Pct,Min_Lot};
enum EnumUseProfitFrom{Its_Own,Global};
input group "~~!~~ GLOBAL ~~!~~"
input double InitialBalance = 50000;//Initial Balance
input EnumAmountType2 CloseAfterEquityIncrease = 1;//Close After Equity Increase
input double IncreaseAmount = 500;//Increase Amount

input EnumAmountType2 CloseAfterEquityIncreaseBuy = 1;//Close After Equity Increase Buy
input double IncreaseAmountBuy = 500;//Increase Amount Buy
input EnumAmountType2 CloseAfterEquityIncreaseSell = 1;//Close After Equity Increase Sell
input double IncreaseAmountSell = 500;//Increase Amount Buy

input int DistTypeATRPeriod = 14;//Dist Type ATR Period
input ENUM_TIMEFRAMES DistTypeATRTF = PERIOD_M1;//Dist Type ATR TF
input double MaxLotSize = 100;//Max Lot Size
input double LotSizeCalculationBalance = 100000;//Lot Size Calculation Balance
input double CommissionPct = 0.0015;//Commission %



input group "~~!~~ Close Losing Trades By Price From Balance ~~!~~"
input OnOff UsesCloseLosingTradesByPriceFromBalance = 0;//Close Losing Trades By Price FRom Balance
input EnumDistType DistanceFromCurrentToCloseTradesDistType = 0;//Distance From Current To Close Trades Dist Type
input double DistanceFromCurrentToCloseTrades = 0;//Distance From Current To Close Trades
input OnOff CloseSecondaryByPrice = 0;//Close Secondary
input OnOff CloseThirdByPrice = 0;//Close Third
input OnOff CloseOnlyMRT = 0;//Close Only MRT
input group "~~!~~  Close Losing Trades By Price FRom Balance ~~!~~"
input OnOff UseMinSizeForFirstTrade = 0;//Use Min Size For First Trade
input group "~~!~~ MRT SYSTEM ~~!~~"
input int MagicMRT = 111;//MRT Magic
input EnumOpenSide OpenSide = 0;//Open Direction
input EnumDistType MRTTPAmountDistType = 1;//TP Amount Dist Type
input double MRTTPAmount = 100;//TP Amount

input EnumSecondaryMRTInTP UseSecondaryMRTInTP = 0;//Use Secondary MRT In TP
input EnumLotType StartLotType = 0;//Start Lot Type
input double StartLot = 0.1;//Start Lot Size
input EnumIncreaseType LotIncreaseType = 0;//Lot Increase Type
input double LotIncrementValue = 1.5;//Lot Increment Value
input EnumIncreaseType DistanceIncreaseType = 0;//Distance Increase Type
input EnumDistType StartDistanceDistType = 0;//Start Distance Dist Type
input double StartDistance = 100;//Start Distance
input EnumDistType DistanceIncrementValueDistType = 0;//Distance Increment Dist Type If (Add)
input double DistanceIncrementValue = 1.5;//Distance Increment Value
input int MaxLevelAmount = 30;//Max Level Amount 
input int MaxLotStartAtLevel = 25;//Max Lot Start from Level
input EnumLotType MaxLotAtLevelType = 0;//Max Lot Type
input double MaxLotAtLevel = 0.1;//Max Lot 

input OnOff AddThirdTrade = 0;//Add Third Trade
input double ThirdTradePct = 30;//Third Trade %
input OnOff AddSecondaryTrade = 0;//Add Secondary Trade
input EnumDistType SecondaryTPAmountDistType = 0;//Secondary TP Amount Dist Type
input double SecondaryTPAmount = 100;//Secondary TP Amount
input double SecondaryOrderPct = 70;//Secondary Order %
input EnumDistType SecondaryOrderMaxDistDistType = 0;//Secondary Order Max Dist Dist Type
input double SecondaryOrderMaxDist = 30;//Secondary Order Max Dist

input EnumUseProfitFrom UseSavedProfitFrom = 0;//Use Saved Profit From
input EnumLotType SaveAmountType = 1;//Save Amount In Balance Type
input double SaveAmount = 500;//Save Amount In Balance
input double StartUsingProfitAfterPct = 5;//Start Using Profit After %
input OnOff SaveProfitForCapsule = 0;//Save Profit For Capsule
input OnOff IncludeOddCapsuleInProfitCalculation = 0;//Include Capsule In Profit Calculation



input group "~~!~~ Nth Trade Close Settings ~~!~~"
input OnOff CloseNthTrade = 0;//Close N'th Trade From Below
input OnOff CloseSecondary = 0;//Close Secondary
input OnOff CloseThird = 0;//Close Third

input int FromLastN = 2;//From Last N
input OnOff CloseNthTradeFromAbove = 0;//Close N'th Trade from Above
input int AfterNthTradeOpened = 0;//After N'th Trade Opened
input OnOff CloseSecondaryFromAbove = 0;//Close Secondary
input OnOff CloseThirdFromAbove = 0;//Close Third
input int FromAboveN = 2;//From Above N'th
input int ToFromLastN = 2;//Last Lines out of close 
input group "~~!~~ Nth Trade Close Settings ~~!~~"

input group "~~!~~ MRT Positive Side Settings ~~!~~"
input int ClosePositiveAfter = 5;//Close Positive Side After
input int PullBackAmount = 2;//Pull Back Amount 
input EnumIncreaseType LotIncreaseType_PS = 0;//Lot Increase Type 
input double LotIncrementValue_PS = 1.5;//Lot Increment Value
input EnumIncreaseType DistanceIncreaseType_PS = 0;//Distance Increase Type
input EnumDistType StartDistance_PSDistType = 0;//Start Distance Dist Type
input double StartDistance_PS = 100;//Start Distance
input EnumDistType DistanceIncrementValue_PSDistType = 0;//Distance Increment Value Dist Type If (Add)
input double DistanceIncrementValue_PS = 1.5;//Distance Increment Value
input OnOff StopOpenAfterAVGOP = 0;//Stop Open After AVG OP (Used By Secondary MRT Too)

input int MaxLevelAmount_PS = 30;//Max Level Amount 
input int MaxLotStartAtLevel_PS = 25;//Max Lot Start from Level
input EnumLotType MaxLotAtLevelType_PS = 0;//Max Lot Type
input double MaxLotAtLevel_PS = 0.1;//Max Lot 
input group "~~~~~ Filters ~~~~~"
input OnOff FilterEffect = 0;//Filter Effect
input OnOff UseRSIFilter = 0;//Use RSI Filter
input OnOff UseMACDFilter = 0;//Use MACD Filter
input OnOff UseMAFilter = 0;//Use MA Filter
input OnOff UseLotSizeFilterAccordingToMA = 0;//Use Lot Size Filter According To MA
input double LotSizeMultiplierWhenFilteredByMA = 0.5;//Lot Size Multiplier When Filtered By MA
input EnumMATrigger1 LockTriggerType = 1;//Lock Trigger Type
input EnumMATrigger1 EndAddTrades = 1;//End Add Trades
input group "~~~~~ MRT Lock SETTINGS ~~~~~"
input OnOff UseLockAfterFilter = 1;//Use Lock
input OnOff UseCapsulingAfterReturnTradeZone = 0;//Use Capsuling After Return Trade Zone
input EnumAmountType2 UseLockAfterFilterDDTrigger = 0;//Use Draw Down Trigger
input double LockAfterFilterDDTriggerAmount = 0;//Draw Down Amount
input double LockAfterFilterDDTriggerAmountStep = 10;//Draw Down Step
input OnOff CloseMRTTradesInProfitAfterFilter = 0;//Close MRT Trades In Profit Before Lock

input OnOff UseDecreaseLotAmountInMRTCapsule = 0;//Decrease Lot Amoint In Capsule By Lock
input EnumDistType MinDecreaseLotAmountMRTDistType = 0;//Min Dist To Close Dist Type
input double MinDecreaseLotAmountMRT= 0;//Min Dist To Close

input OnOff UseDecreaseLotAmountInMRTCapsuleByMRT = 0;//Decrease Lot Amoint In Capsule By MRT
input OnOff UseBE_LockAfterFilter = 0;;//Use Break Even
input EnumDistType BEAfter_LockAfterFilterDistType = 0;//Break Even After Dist Type
input double BEAfter_LockAfterFilter = 100;//Break Even After
input EnumDistType BEAt_LockAfterFilterDistType = 0;//Break Even At Dist Type
input double BEAt_LockAfterFilter = 10;//Break Even At
input EnumAmountType2 CloseLockAfterFilterInProfit = 0;//Close Lock After Filter In Profit
input double LockAfterFilterProfitAmount = 100;//Lock After Filter Amount
input EnumDistType LockAfterFilterReOpenAmountDistType = 0;//Lock After Filter ReOpen Amount After BE Dist Type
input double LockAfterFilterReOpenAmount = 0;//Lock After Filter ReOpen Amount After BE
input OnOff UseLockAfterFilterCapsule = 0 ;//Use Lock After Filter Capsule After AVG TP



input group "~~~~~ MRT After Filter ~~~~~"
input OnOff UseMRT_AfterFilter = 1;//Use MRT After Filter
input int MagicMRT_AfterFilter = 222;//Magic
input EnumDistType MRTTPAmount_AfterFilterDistType = 0;//TP Amount Dist Type
input double MRTTPAmount_AfterFilter = 100;//TP Amount
input EnumLotType StartLotType_AfterFilter = 0;//Start Lot Type
input double StartLot_AfterFilter = 0.1;//Start Lot Size
input EnumIncreaseType LotIncreaseType_AfterFilter = 0;//Lot Increase Type
input double LotIncrementValue_AfterFilter = 1.5;//Lot Increment Value
input EnumIncreaseType DistanceIncreaseType_AfterFilter = 0;//Distance Increase Type
input EnumDistType StartDistance_AfterFilterDistType = 0;//Start Distance Dist Type
input double StartDistance_AfterFilter = 100;//Start Distance
input EnumDistType DistanceIncrementValue_AfterFilterDistType = 0;//Distance Increment Value Dist Type If(Add)
input double DistanceIncrementValue_AfterFilter = 1.5;//Distance Increment Value
input int MaxLevelAmount_AfterFilter = 30;//Max Level Amount 
input int MaxLotStartAtLevel_AfterFilter = 25;//Max Lot Start from Level
input EnumLotType MaxLotAtLevelType_AfterFilter = 0;//Max Lot Type
input double MaxLotAtLevel_AfterFilter = 0.1;//Max Lot 


input OnOff AddThirdTrade_AfterFilter = 0;//Add Third Trade
input double ThirdTradePct_AfterFilter = 30;//Third Trade %
input OnOff AddSecondaryTrade_AfterFilter = 0;//Add Secondary Trade
input EnumDistType SecondaryTPAmount_AfterFilterDistType = 0;//Secondary TP Amount Dist Type
input double SecondaryTPAmount_AfterFilter = 100;//Secondary TP Amount
input double SecondaryOrderPct_AfterFilter = 70;//Secondary Order %
input EnumDistType SecondaryOrderMaxDist_AfterFilterDistType = 0;//Secondary Order Max Dist Dist Type
input double SecondaryOrderMaxDist_AfterFilter = 30;//Secondary Order Max Dist
input int ActiveOnlyLastCycles = 30;//Active Only Last Cycles
input int StopWhenNCapsuleOpened = 3;//Stop New Cycle When N Capsule Opened
input EnumIncreaseType CycleLotIncrementType = 0;//Cycle Lot Increase Type
input double CycleLotIncrementValue = 1.5;//Cycle Lot Increase Value

input group "~~!~~ MRT Positive Side Settings ~~!~~"
input int ClosePositiveAfter_AfterFilter = 5;//Close Positive Side After
input int PullBackAmount_AfterFilter = 2;//Pull Back Amount 
input EnumIncreaseType LotIncreaseType_PS_AfterFilter = 0;//Lot Increase Type 
input double LotIncrementValue_PS_AfterFilter = 1.5;//Lot Increment Value
input EnumIncreaseType DistanceIncreaseType_PS_AfterFilter = 0;//Distance Increase Type
input EnumDistType StartDistance_PSDistType_AfterFilter = 0;//Start Distance Dist Type
input double StartDistance_PS_AfterFilter = 100;//Start Distance
input EnumDistType DistanceIncrementValue_PSDistType_AfterFilter = 0;//Distance Increment Value Dist Type If (Add)
input double DistanceIncrementValue_PS_AfterFilter = 1.5;//Distance Increment Value

input int MaxLevelAmount_PS_AfterFilter = 30;//Max Level Amount 
input int MaxLotStartAtLevel_PS_AfterFilter = 25;//Max Lot Start from Level
input EnumLotType MaxLotAtLevelType_PS_AfterFilter = 0;//Max Lot Type
input double MaxLotAtLevel_PS_AfterFilter = 0.1;//Max Lot 

input group "~~!~~ MRT After Filter Lock Settings ~~!~~"
input OnOff Use_LockMRTAfterFilter = 0;//Use Lock
input OnOff UseCapsulingAfterReturnTradeZone_MRTAfterFilter = 0;//Use Capsuling After Return Trade Zone
input EnumAmountType2 UseLockAfterFilterDDTrigger_MRTAfterFilter = 0;//Use Draw Down Trigger
input double LockAfterFilterDDTriggerAmount_MRTAfterFilter = 0;//Draw Down Amount
input double LockAfterFilterDDTriggerAmountStep_MRTAfterFilter = 0;//Draw Down Amount Step
input OnOff CloseMRTTradesInProfitAfterFilter_MRTAfterFilter = 0;//Close MRT Trades In Profit Before Lock
input EnumTrigger CloseLockMRTAfterFilterBelowType = 1;//Close Lock MRT After Filter Below Type
input double CloseLockMRTAfterFilterBelowAmount = 10;//Close Lock MRT After Filter Below Amount

input OnOff UseDecreaseLotAmountInMRTCapsule_MRTAfterFilter = 0;//Decrease Lot Amoint In Capsule By Lock
input EnumDistType MinDecreaseLotAmountMRTDistType_MRTAfterFilter= 0;//Min Dist To Close Dist Type
input double MinDecreaseLotAmountMRT_MRTAfterFilter= 0;//Min Dist To Close

input OnOff UseDecreaseLotAmountInMRTCapsuleByMRT_MRTAfterFilter = 0;//Decrease Lot Amoint In Capsule By MRT
input EnumAmountType2 CloseLockAfterFilterInProfit_MRTAfterFilter = 0;//Close Lock After Filter In Profit
input double LockAfterFilterProfitAmount_MRTAfterFilter = 100;//Lock After Filter Amount
input EnumDistType LockAfterFilterReOpenAmountDistType_MRTAfterFilter = 0;//Lock After Filter ReOpen Amount After BE Dist Type
input double LockAfterFilterReOpenAmount_MRTAfterFilter = 0;//Lock After Filter ReOpen Amount After BE
input OnOff UseBE_LockMRTAfterFilter = 0;;//Use Break Even
input EnumDistType BEAfter_LockMRTAfterFilterDistType = 0;//Break Even After Dist Type
input double BEAfter_LockMRTAfterFilter = 100;//Break Even After
input EnumDistType BEAt_LockMRTAfterFilterDistType = 0;//Break Even At Dist Type
input double BEAt_LockMRTAfterFilter = 10;//Break Even At
input OnOff UseLockAfterFilterCapsule_MRTAfterFilter = 0 ;//Use MRT After Filter Lock Capsule After AVG TP

input OnOff UseBalanceToCloseCycle_MRTAfterFilter = 0;//Use Balance To Close Cycle
input EnumAmountType2 CloseBelowPreviousBalance_MRTAfterFilter  = 0;//Close Below Previous Balance
input double BelowPreviousBalanceAmount = 0;//Below Previous Balance Amount 
input group "~~!~~ Nth Trade Close Settings ~~!~~"
input OnOff CloseNthTrade_MRTAfterFilter = 0;//Close N'th Trade From Below
input OnOff CloseSecondary_MRTAfterFilter = 0;//Close Secondary
input OnOff CloseThird_MRTAfterFilter = 0;//Close Third

input int FromLastN_MRTAfterFilter = 2;//From Last N
input OnOff CloseNthTradeFromAbove_MRTAfterFilter = 0;//Close N'th Trade from Above
input int AfterNthTradeOpened_MRTAfterFilter = 0;//After N'th Trade Opened
input OnOff CloseSecondaryFromAbove_MRTAfterFilter = 0;//Close Secondary
input OnOff CloseThirdFromAbove_MRTAfterFilter = 0;//Close Third
input int FromAboveN_MRTAfterFilter = 2;//From Above N'th
input int ToFromLastN_MRTAfterFilter = 2;//Last Lines out of close 
input group "~~!~~ Nth Trade Close Settings ~~!~~"

input group "~~~~~ CAPSULE SETTINGS ~~~~~"
input OnOff UseDecreaseLotAmountInCapsule = 0;//Decrease Lot Amoint In Capsule
input EnumDistType MinDecreaseLotAmountInCapsuleDistType = 0;//Min Dist To Close Dist Type
input double MinDecreaseLotAmountInCapsule= 0;//Min Dist To Close
input OnOff UseBE_Capsule = 0;;//Use Break Even
input EnumDistType BEAfter_CapsuleDistType = 0;//Break Even After Dist Type
input double BEAfter_Capsule = 100;//Break Even After
input EnumDistType BEAt_CapsuleDistType = 0;//Break Even At Dist Type
input double BEAt_Capsule = 10;//Break Even At
input EnumDistType TP_CapsuleDistType = 1;//TP Amount Dist Type
input double TP_Capsule = 100;//TP Amount

input group "~~!~~ GLOBAL CAPSULE SETTINGS ~~!~~"
input OnOff CloseCapsuleFromBalance = 0;//Close Capsule From Balance
input OnOff CloseCapsulesWithMRT = 0;//Close Capsules With MRT
input OnOff OnlyCloseWhenBalanceEarned = 0;//Only Close When Balance Earned
input OnOff UseCapsuleTwoSideReOpen = 0;//Use Capsule Two Side ReOpen
input EnumDistType ReOpenDistAfterSelfDecreaseDistType = 0;//ReOpen Dist After Self Decrease Dist Type
input double ReOpenDistAfterSelfDecrease = 0;//ReOpen Dist After Self Decrease
input EnumDontReOpenType DontReOpenAfterSelfDecrease = 0;//Dont ReOpen After Self Decrease
input double DontReOpenTriggerPct = 30;//Dont ReOpen Trigger Self Lot Pct
input EnumLotType DontReOpenTriggerMinLotType = 0;//Dont ReOpen Trigger Min Lot Hit Type
input double DontReOpenTriggerMinLot = 0.1;//Dont ReOpen Trigger Min Lot Hit Amount

input OnOff OpenOppositeInsteadLock = 0;//Open Opposite Instead Lock
input OnOff ReOpenAlwaysTrendSide = 0;//Always ReOpen Trend Side
input OnOff CloseCapsulesAfterEquityClose = 0;//Close Capsules After Equity Close
input group "~~~~~ HEDGE SYSTEM ~~~~~"
input OnOff UseHedge = 1;//Use Hedge System
input int Magic = 333;//Hedge Magic
input EnumDirection Direction = 2;//Hedging Direction
input OnOff StopOpenNewTradesAfterHedge = 0;//Stop Open New Trades After Hedge
input group "~~~~~ Main Hedge Trades Settings ~~~~~"

input double MainLockPct = 120;//Percentage of hedge for lock
input EnumTrigger MainTriggerType =0;//Trigger Hedge Type
input double MainTriggerAmount = 300;//Trigger Amount
input double MainTriggerAddAfterCapsule = 300;//Trigger Add Aftere Capsule

input group "~~~~~ With Main Hedge Close Nth Trades ~~~~~"
input OnOff UseWithMainHedgeCloseNthTrade = 0;//Use With Main Hedge Close N'th Trade
input EnumDistType MinDistToCloseDistType = 1;//Dist Type
input double MinDistToClose = 200;//Min Dist To Close
input int FromNth = 2;//From N'th
input group "~~~~~ Main Hedge Capsule Settings ~~~~~"
input OnOff UseGlobalCapsuleInsteadLock = 0;//Use Global Capsule Instead Lock
input OnOff LockHedgeAtAVGTP = 0;//Lock Hedge At AVG TP 
input OnOff UseDecreaseLotAmountInCapsule_MainHedge = 0;//Decrease Lot Amoint In Capsule
input EnumDistType DeacreaseHedgeCapsuleAfterDistType = 0;//Min Dist To Close Dist Type
input double DeacreaseHedgeCapsuleAfter= 0;//Min Dist To Close

input EnumDistType ReFillMaxDistDistType = 0;//ReFill Max Dist Dist Type
input double ReFillMaxDist = 30;//ReFill Max Dist
input OnOff LockHedgeAfterPullBack = 0;//Lock Hedge After Pull Back
input EnumDistType LockPullBackStartDistType = 0;//Lock Pull Back Start Dist Type
input double LockPullBackStart = 0;//Lock Pull Back Start
input OnOff UseMainHedgeCapsuleSL = 0;//Use Main Hedge Capsule SL
input EnumDistType MainHedgeCapsuleSLDistType = 0;//Main Hedge Capsule SL Dist Type
input double MainHedgeCapsuleSL = 700;//Main Hedge Capsule SL
input EnumDistType MainHedgeCapsuleSL2DistType = 0;//Main Hedge Capsule SL 2 Dist Type
input double MainHedgeCapsuleSL2 = 1400;//Main Hedge Capsule SL 2
input OnOff UseMarginLevelFromAccount = 0;//Use Margin Level From Account
input OnOff CloseOnLowMargin = 0;//Close On Low Margin
input double CloseBySLMarginLevel = 50;//Close By SL Margin Level
input double CloseAnyWayMarginLevel = 70;//Close Any Way Margin Level
input OnOff UseLockBreakEven = 0;//Lock Break Even Type
input EnumDistType LockBreakEvenAfterDistType = 0;//Lock Break Even After Dist Type
input double LockBreakEvenAfter = 100;//Lock Break Even After
input EnumDistType LockBreakEvenAtDistType = 0;//Lock Break Even At Dist Type
input double LockBreakEvenAt = 10;//Lock Break Even At
input OnOff CloseMainHedgeCapsuleFromBalance = 0;//Close Hedge Capsule From Balance
input group "&&&&& Main Hedge Capsule Settings &&&&&"
input EnumAmountType1 MainBreakEvenType = 3;//Break Even Type
input EnumDistType MainBreakEvenAfterDistType = 0;//Break Even After Dist Type If(Distance)
input double MainBreakEvenAfter = 400;//Break Even After
input EnumDistType MainBreakEvenAtDistType = 0;//Break Even At Dist Type If(Distance)
input double MainBreakEvenAt = 100;//Break Even At


input EnumAmountType1 MainTPType = 3;//Take Profit Type
input EnumDistType MainTPAmountDistType = 0;//Take Profit Amount Dist Type If(Distance)
input double MainTPAmount = 900;//Take Profit Amount

input EnumAmountType1 MainSLType = 3;//Stop Loss Type
input EnumDistType MainSLAmountDistType = 0;//Stop Loss Amount Dist Type If(Distance)
input double MainSLAmount = 500;//Stop Loss Amount


input EnumAmountType1 MainTSType = 3;//Trailing Stop Type
input EnumDistType MainTSAfterDistType = 0;//Trailing Stop After Dist Type If(Distance)
input double MainTSAfter = 500;//Trailing Stop After
input EnumDistType MainTSStepDistType = 0;//Trailing Stop Step Dist Type If(Distance)
input double MainTSStep = 500;//Trailing Stop Step
input EnumDistType MainTSDistanceDistType = 0;//Trailing Stop Dist Type If(Distance)
input double MainTSDistance = 500;//Trailing Stop
input EnumDistType MainTSBlockDistType = 0;//Trailing Block After Dist Type If(Distance)
input double MainTSBlock = 300;//Trailing Block After


input OnOff MainUseReOpen = 1;//Use Reopen
input EnumDistType MainReOpenDistanceDistType = 0;//Reopen Distance Dist Type
input double MainReOpenDistance = 100;//Reopen Distance

input EnumGridType MainGridType = 0;//Grid Type

input EnumDistType MainGridDistanceDistType = 0;//Main Grid Distance Dist Type
input double MainGridPct_1 = 12;//Grid % 1
input double MainGridDistance_1 = 100;//Grid Distance 1
input double MainGridPct_2 = 12;//Grid % 2
input double MainGridDistance_2 = 150;//Grid Distance 2
input double MainGridPct_3 = 12;//Grid % 3
input double MainGridDistance_3 = 175;//Grid Distance 3
input double MainGridPct_4 = 12;//Grid % 4
input double MainGridDistance_4 = 200;//Grid Distance 4
input double MainGridPct_5 = 12;//Grid % 5
input double MainGridDistance_5 = 100;//Grid Distance 5
input double MainGridPct_6 = 0;//Grid % 6
input double MainGridDistance_6 = 100;//Grid Distance 6
input double MainGridPct_7 = 0;//Grid % 7
input double MainGridDistance_7 = 100;//Grid Distance 7
input double MainGridPct_8 = 0;//Grid % 8
input double MainGridDistance_8 = 100;//Grid Distance 8
input double MainGridPct_9 = 0;//Grid % 9
input double MainGridDistance_9 = 100;//Grid Distance 9
input double MainGridPct_10 = 0;//Grid % 10
input double MainGridDistance_10 = 100;//Grid Distance 10
input double MainGridPct_11 = 0;//Grid % 11
input double MainGridDistance_11 = 100;//Grid Distance 11
input double MainGridPct_12 = 0;//Grid % 12
input double MainGridDistance_12 = 100;//Grid Distance 12
input double MainGridPct_13 = 0;//Grid % 13
input double MainGridDistance_13 = 100;//Grid Distance 13
input double MainGridPct_14 = 0;//Grid % 14
input double MainGridDistance_14 = 100;//Grid Distance 14
input double MainGridPct_15 = 0;//Grid % 15
input double MainGridDistance_15 = 100;//Grid Distance 15
input double MainGridPct_16 = 0;//Grid % 16
input double MainGridDistance_16 = 100;//Grid Distance 16
input double MainGridPct_17 = 0;//Grid % 17
input double MainGridDistance_17 = 100;//Grid Distance 17
input double MainGridPct_18 = 0;//Grid % 18
input double MainGridDistance_18 = 100;//Grid Distance 18
input double MainGridPct_19 = 0;//Grid % 19
input double MainGridDistance_19 = 100;//Grid Distance 19
input double MainGridPct_20 = 0;//Grid % 20
input double MainGridDistance_20 = 100;//Grid Distance 20


input group "~~~~~ Equity CLOSE FEATURES ~~~~~"

input EnumAmountType2 CloseAllOn_DD=0;//Close All On On DrawDown
input double CloseAllOnAmount_DD = 0;//Close All On On DrawDown Amount 
input OnOff DisableAutoTradeOn_DD = 0;//Disable Auto Trade After

input EnumAmountType2 CloseAllOn_P=0;//Close All On On Profit
input double CloseAllOnAmount_P = 0;//Close All On On Profit Amount 
input OnOff DisableAutoTradeOn_P = 0;//Disable Auto Trade After

input group "~~~~~ Pause Trading Setting ~~~~~"
input OnOff UsePauseTradingByDD = 0;//Use Pause Trading By DD
input string UpdateTime = "17:00";//Update Time
input double ContinueTradeAfterHour = 30;//Continue Trade After Hour

input group "~~!~~ Level 1 Triggers ~~!~~"
input OnOff UseBasicDrawDown = 0;//Use Basic Draw Down
input double BasicDrawDownPct = 2;//Basic Draw Down Pct
input OnOff UseFromBalance = 0;//Use From Balance
input double FromBalancePct = 2;//From Balance %
input OnOff UseFromEquity = 0;//Use From Equity
input double FromEquityPct = 2;//From Equity %
input OnOff UseFromAVG = 0;//Use From Balance/Equity AVG
input double FromAVGPct = 2;//From Balance/Equity AVG %
input EnumAmountType2 UseSLAfterBigDD = 0;//Use SL Afer Big Draw Down
input double BigDDValue = 1000;//Big Draw Down value
input double SLAferBigDDValue = 200;//SL After Big DD Value

input group "~~!~~ Level 2 Triggers ~~!~~"
input OnOff UseLevel2Triggers = 0;//Use Level 2 Triggers
input OnOff UseMarginTrigger = 0;//Use Margin Trigger
input double MarginTriggerPctAmount = 30;//Margin Trigger % Amount
input OnOff UseLockTrigger = 0;//Use Lock Trigger
input OnOff UseLockCapsuleTrigger = 0;//Use Lock Capsule Trigger
input OnOff UseMinTradeAmountTrigger = 0;//Use Min Trade Amount Trigger
input int MinTradeAmountTrigger =0;//Min Trade Amount Trigger
input EnumMATrigger UseMATrigger = 0;//Use MA Trigger

input OnOff UseBasicDrawDown_LVL2 = 0;//Use Basic Draw Down
input double BasicDrawDownPct_LVL2 = 2;//Basic Draw Down Pct
input OnOff UseFromBalance_LVL2 = 0;//Use From Balance
input double FromBalancePct_LVL2 = 2;//From Balance %
input OnOff UseFromEquity_LVL2 = 0;//Use From Equity
input double FromEquityPct_LVL2 = 2;//From Equity %
input OnOff UseFromAVG_LVL2 = 0;//Use From Balance/Equity AVG
input double FromAVGPct_LVL2 = 2;//From Balance/Equity AVG %

input OnOff UseFilterToContinue = 0;//Use Filter To Continue
input ENUM_TIMEFRAMES FilterToContinue_MA_TF = 0;//Filter MA TF
input ENUM_TIMEFRAMES FilterToContinue_RSI_TF = 0;//Filter RSI TF
input ENUM_TIMEFRAMES FilterToContinue_MACD_TF = 0;//Filter MACD TF

input group "~~!~~ RSI Settings ~~!~~"
input ENUM_TIMEFRAMES RSI_TF = 0;//RSI Timeframe
input int RSIPeriod = 14;//RSI Period
input ENUM_APPLIED_PRICE RSIAppliedPrice = PRICE_CLOSE;//RSI Applied Price
input double RSISellLevel = 70;//RSI Sell Level
input double RSIBuyLevel = 30;//RSI Buy Level


input group "~~!~~ MACD Settings ~~!~~"
input ENUM_TIMEFRAMES MACD_TF = 0;//MACD Timeframe
input int MACDFastPeriod = 20;//MACD Fast Period
input int MACDSlowPeriod = 50;//MACD Slow Period
input int MACDPeriod = 14;//MACD Period
input ENUM_APPLIED_PRICE MACDAppliedPrice = PRICE_CLOSE;//MACD Applied Price
input double MACDSellLevel = 70;//MACD Sell Level
input double MACDBuyLevel = 30;//MACD Buy Level


input group "~~!~~ MA Settings ~~!~~"
input ENUM_TIMEFRAMES MA_TF = 0;//MA Timeframe


input group "~~~~~ SLOW MA Settings ~~~~~"
input int MAPeriod_Slow = 200;//MA Period
input int MAShift_Slow = 0;//MA Shift
input ENUM_MA_METHOD MAMethod_Slow = MODE_SMA;//MA Method
input ENUM_APPLIED_PRICE MAAppliedPrice_Slow = PRICE_CLOSE;//MA Applied Price


input group "~~~~~ MID MA Settings ~~~~~"
input int MAPeriod_Mid = 200;//MA Period
input int MAShift_Mid = 0;//MA Shift
input ENUM_MA_METHOD MAMethod_Mid = MODE_SMA;//MA Method
input ENUM_APPLIED_PRICE MAAppliedPrice_Mid = PRICE_CLOSE;//MA Applied Price

input group "~~~~~ FAST MA Settings ~~~~~"
input int MAPeriod_Fast = 200;//MA Period
input int MAShift_Fast = 0;//MA Shift
input ENUM_MA_METHOD MAMethod_Fast = MODE_SMA;//MA Method
input ENUM_APPLIED_PRICE MAAppliedPrice_Fast = PRICE_CLOSE;//MA Applied Price


input group "~~~~~ LotSize MA Settings ~~~~~"
input ENUM_TIMEFRAMES MA_TF_LotSize = 0;//MA TF 
input int MAPeriod_LotSize = 200;//MA Period
input int MAShift_LotSize = 0;//MA Shift
input ENUM_MA_METHOD MAMethod_LotSize = MODE_SMA;//MA Method
input ENUM_APPLIED_PRICE MAAppliedPrice_LotSize = PRICE_CLOSE;//MA Applied Price

input group "~~~~~ Line Settings ~~~~~"
input OnOff ShowLines = 1;//Show Lines
input color BuyTPLineColor = clrGreen;//Buy TP Line Color
input int BuyTPLineWidth = 1;//Buy TP Line Width
input ENUM_LINE_STYLE BuyTPLineStyle = STYLE_SOLID;//Buy TP Line Style

input color BuyAVGLineColor = clrLightGreen;//Buy AVG Line Color
input int BuyAVGLineWidth = 1;//Buy AVG Line Width
input ENUM_LINE_STYLE BuyAVGLineStyle = STYLE_DASHDOT;//Buy AVG Line Style


input color SellTPLineColor = clrRed;//Sell TP Line Color
input int SellTPLineWidth = 1;//Sell TP Line Width
input ENUM_LINE_STYLE SellTPLineStyle = STYLE_SOLID;//Sell TP Line Style

input color SellAVGLineColor = clrLightCoral;//Sell AVG Line Color
input int SellAVGLineWidth = 1;//Sell AVG Line Width
input ENUM_LINE_STYLE SellAVGLineStyle = STYLE_DASHDOT;//Sell AVG Line Style


input EnumDistType IgnorePriceDistType = 0;//Ignore Price Dist Type
input double IgnorePrice = 0;//Ignore Price
input OnOff UsePauseTesting = 1;//Use Pause Testing
input bool Logs = true;//Print Logs
input OnOff OncePerCandle = 0;//Once Per Candle
input ENUM_TIMEFRAMES OncePerCandleTF = PERIOD_M1;//Once Per Candle TimeFrame

///////////////////// POSITION CLASSS /////////////////////////////////

  
/////////// DISABLE AUTO TRADE /////////////////
#define MT_WMCMD_EXPERTS   32851
#define WM_COMMAND 0x0111
#define GA_ROOT    2
#include <WinAPI\winapi.mqh>
void AlgoTradingStatus(bool Enable)
{
   bool Status = (bool) TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
   
   if(Enable != Status)
   {
   HANDLE hChart = (HANDLE) ChartGetInteger(ChartID(), CHART_WINDOW_HANDLE);
   PostMessageW(GetAncestor(hChart, GA_ROOT), WM_COMMAND, MT_WMCMD_EXPERTS, 0);
   }
}  

/////////// DISABLE AUTO TRADE /////////////////


/////////// Pause Testing /////////////////
#import "user32.dll"
    void keybd_event(int bVk, int bScan, int dwFlags,int dwExtraInfo);
#import
#define VK_SPACE 0x20 //Space
#define VK_RETURN 0x0D //Return - Enter Key
#define KEYEVENTF_KEYUP 0x0002  //Key up

void PauseTesting(string line)
{
   if(!UsePauseTesting)
      return;
   Print(line);
   if(MQLInfoInteger(MQL_TESTER) && MQLInfoInteger(MQL_VISUAL_MODE))
   {
      keybd_event(VK_SPACE, 0, 0, 0);
      keybd_event(VK_SPACE, 0, KEYEVENTF_KEYUP , 0);
   }        
}
/////////// Pause Testing /////////////////
CTrade myTrade;
string prefix = Magic+Symbol();
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

void PrintLogs(string txt)
{
   if(Logs)
      Print(txt);
}


ENUM_TIMEFRAMES TF = 0;
double MainGridPct[21];
double MainGridDistance[21];

double m_StartDistance;
double m_MRTTPAmount;
double m_DistanceIncrementValue;
double m_SecondaryTPAmount;
double m_SecondaryOrderMaxDist;
double m_StartDistance_PS;
double m_DistanceIncrementValue_PS;
double m_MRTTPAmount_AfterFilter;
double m_StartDistance_AfterFilter;
double m_DistanceIncrementValue_AfterFilter;
double m_BEAfter_LockMRTAfterFilter;
double m_BEAt_LockMRTAfterFilter;
double m_SecondaryTPAmount_AfterFilter;
double m_SecondaryOrderMaxDist_AfterFilter;
double m_BEAt_LockAfterFilter;
double m_BEAfter_LockAfterFilter;
double m_ReFillMaxDist;
double m_LockPullBackStart;
double m_LockBreakEvenAfter;
double m_LockBreakEvenAt;
double m_MainTSAfter;
double m_MainTSStep;
double m_MainTSDistance;
double m_MainTSBlock;
double m_MainReOpenDistance;
double m_MainBreakEvenAfter;
double m_MainBreakEvenAt;
double m_MainTPAmount;
double m_MainSLAmount;
double m_MainHedgeCapsuleSL2;
double m_MainHedgeCapsuleSL;
double m_LockAfterFilterReOpenAmount;
double m_MinDistToClose;
double m_IgnorePrice;
double m_StartDistance_PS_AfterFilter;
double m_DistanceIncrementValue_PS_AfterFilter;
double m_ReOpenDistAfterSelfDecrease;
double m_ReOpenDistAfterSelfDecrease_MRTAfterFilter;
double m_LockAfterFilterReOpenAmount_MRTAfterFilter;
double m_BEAfter_Capsule = 100;
double m_BEAt_Capsule = 10;
double m_TP_Capsule = 100;

double m_MinDecreaseLotAmountMRT;
double m_MinDecreaseLotAmountMRT_MRTAfterFilter;
double m_MinDecreaseLotAmountInCapsule;
double m_DeacreaseHedgeCapsuleAfter;
double m_DistanceFromCurrentToCloseTrades;

struct EnumCapsuleInfo
{
	int tradeAmount;
	int index;
   int type;
   int magic;
   double profit[1000];
   double lotSize[1000];
   string comment[1000];
   int dist[1000];
   int tkt[1000];
   
   EnumCapsuleInfo()
   {
   	tradeAmount=1;
   	type=-1;
   	magic=-1;
   	index=-1;
   }
};

struct EnumMyHedgeInfo
{
	double allLotSum;
	double allProfitSum;
   double op;
	bool locked;
	int hedgeType;
	int capsuleAmount;
	double profit;
 	ulong tkt;
	int lastMRT;
	double lotSum;
	ulong lastHedgePositionID;
	datetime lastHedgeDT;
	bool reOpen;
	int index;
	int lastHedegeIndex;
};

struct EnumMyMRTInfo
{
	double isOpen1[1000];
	double isOpen2[1000];
	double isOpen3[1000];
	bool isAction;
	
   double oppositeLot;
   double positiveLot;
   
   double oppositeOP;
   double positiveOP;
   
   int oppositeN;
   int positiveN;
   
   double avgPrice;
   double lotSum;
   double profit;
   double firstOP;
   int nthTrade;
   ulong nthTkt;
   int nthTradeFromAbove;
   ulong nthTktFromAbove;
   int lockLastNType;
   ulong lockTkt;
   double lockLot;
   double lockProfit;
   int isHedged;
   
   datetime lastOpenedT;
   int lastOpenedN;
   int lastN;
   double avgOP;
   double lotSumMRTAfterFilter;
   double avgMRTAfterFilter;
   double profitMRTAfterFilter;
   
   
   datetime lastLockOT;
   ulong lastLockPositionID;
   bool lockReOpen;
	int filterCrossOverIndex;
	
	int lockCloseReason;
	double lockStartLotAmount;
	double lastDDTrigger;
	EnumMyMRTInfo()
	{
		
   	lastLockOT=0;
   	lastLockPositionID=0;
	}
	
};
struct EnumMyMRT_AfterFilterInfo
{
	int lastIndex;
   int mrtCycle[1000];
   int lastN[1000];
   datetime activeAfter;
   datetime firstOT[1000];
   datetime lastOpenedT[1000];
   int lastOpenedN[1000];
   int positiveOP[1000];
   int positiveLastN[1000];
   double opSum[1000];
   double lotSum[1000];
   double lastOP[1000];
   double lockProfit[1000];
   double lockLot[1000];
   double profit[1000];
   ulong lockTkt[1000];
   bool typeConfirmed[1000];
   
   datetime lastLockOT[1000];
   ulong lastLockPositionID[1000];
   bool lockReOpen[1000];
	
   double isOpen1[1000][1000];
   double isOpen2[1000][1000];
   double isOpen3[1000][1000];
   datetime lastOT;
   EnumMyMRT_AfterFilterInfo()
   {
   	ArrayFill(lastLockOT,0,1000,0);
   	ArrayFill(lastLockPositionID,0,1000,0);
   }
};
struct EnumMainCapsuleInfo
{
	int index;
	bool lock;
	bool main;
	bool lockFound;
	bool mainFound;
	ulong lockTkt;
	ulong mainTkt;
	double lockLot;
	double mainLot;
	double lockProfit;
	double mainProfit;
	double lockOP;
	double mainOP;
	double lockCP;
	double mainCP;
	datetime lockCT;
	datetime mainCT;
	int mainType;
	int lockType;
	int type;
	bool both;
	EnumMainCapsuleInfo()
	{
		lock=false;
		main=false;
		both =false;
		lockProfit = 0;
		mainProfit = 0;
		lockCT = 0;
		mainCT = 0;
	}
};
struct EnumMyInfo
{
	EnumMyMRT_AfterFilterInfo buyMRT_AfterFilter;
	EnumMyMRT_AfterFilterInfo sellMRT_AfterFilter;
	
	EnumMyHedgeInfo buyHedge;
	EnumMyHedgeInfo sellHedge;
	
	EnumMyMRTInfo buyMRT;
	EnumMyMRTInfo sellMRT;
	
	
	double maxEquity;
	double maxEquityBuy;
	double maxEquitySell;
	
	datetime lastHistoryRun;
	ulong historyLastCheckedTkt;
	
	double previousEquity;
	datetime startTime;
	double maxProfit;
	double previousEquityBuy;
	datetime startTimeBuy;
	double maxProfitBuy;
	double previousEquitySell;
	datetime startTimeSell;
	double maxProfitSell;
	int pauseTrading;
	datetime pauseTime;
	datetime lastUpdate;
	double pauseBalance;
	double pauseEquity;
	double pauseAVG;
	
	double savedProfit;
	double savedProfitBuy;
   double savedProfitSell;
   
	
	int trailingMainBuy;
	int trailingMainValueBuy;
	int beStartedMainBuy;
	int trailingMainSell;
	int trailingMainValueSell;
	int beStartedMainSell;
	int filterOutBuy;
	double lotBuy;
	int filterOutSell;
	double lotSell;
	int filterIndexBuy;
	int filterIndexSell;
	
	double historySavedProfitBuy;
	double historySavedProfitSell;
	
	double wholeClosedProfitBuy;
	double wholeOpenProfitBuy;
	double cycleClosedProfitBuy;
	double wholeClosedProfitSell;
	double wholeOpenProfitSell;
	double cycleClosedProfitSell;
	double equityBuy;
	double equitySell;
	double balance;
	double equity;
	double wholeOpenProfit;
	double wholeClosedProfit;
	double cycleClosedProfit;
	
	double commissionBuy;
	double commissionSell;
	double spread;
	double maxspread;
	double marginUsed;
	
	
	
	
	int hedgeCapsuleAmount;
   int mrtCapsuleAmount;
   int mrtAfterFilterCapsuleAmount;
   int capsuleAmount;
   
   EnumCapsuleInfo hedgeCapsuleInfo[1000];
   EnumCapsuleInfo mrtCapsuleInfo[1000];
   EnumCapsuleInfo mrtAfterFilterCapsuleInfo[1000];
   EnumCapsuleInfo capsuleInfo[1000];
   
   
   bool isAction;
   
	
	int MainGridLastIndex;
	int filterValue;
	bool filterValueSell;
	bool filterValueBuy;
	bool filterLockTriggerSell;
	bool filterLockTriggerBuy;
	bool filterLockExitTriggerSell;
	bool filterLockExitTriggerBuy;
	int lockCapsuleIndex;
	
	bool haveLock;
	bool haveLockCapsule;
	
	
	int mainCapsuleAmount;
	EnumMainCapsuleInfo mainCapsuleInfo[1000];
	EnumMainCapsuleInfo mainCapsuleInfoHistory[1000];
	
	bool MATrigger;
	bool bigDDTriggered;
	
	bool endAddTradesBuy;
	bool endAddTradesSell;
	
	
	EnumMyInfo()
	{	
		historyLastCheckedTkt=0;
		cycleClosedProfitBuy =0;
		cycleClosedProfitSell=0;
	}
};

struct EnumPositionInfo
{
	ulong tkt;
	int magic;
   int orderType;
   string comment;
   datetime ot;
   datetime ct;
   double orderProfit;
   double op;
   double cp;
   double sl;
   double lotSize;
   int type;
   bool isMRT;
   bool isMRT_AfterFilter;
   bool isHedge;
   int n;
   int nType;
   int index;
   bool isLock;
   ulong positionID;
   bool isHistory;
   ENUM_DEAL_ENTRY entry;
	bool isCapsule;
	double commission;
   void SetValues()
   {
		type = IsTypeConfirmed(1,orderType,magic,comment);
      
		isMRT = magic == MagicMRT;
		isMRT_AfterFilter = magic == MagicMRT_AfterFilter;
		isHedge = magic == Magic;
      isCapsule = (StringFind(comment,"#")!=-1);
      
		n = GetMRTN(comment);
		nType = GetMRTType(comment);
		index = GetMRTIndex(comment);
      if(isMRT_AfterFilter)	
      {
			n = GetMRTAfterFilterN(comment);
			nType = GetMRTAfterFilterType(comment);
			index = GetMRTAfterFilterIndex(comment);
      }
      if(isHedge)	
      {
			n = GetHedgeN(comment);
			nType = GetHedgeTkt(comment);
			index = GetHedgeIndex(comment);
      }
      if(isCapsule)	
      {
			n = GetCapsuleN(comment);
			nType = GetCapsuleTkt(comment);
			index = GetCapsuleIndex(comment);
			type = ((index % 2 == 1)?1:0);
			isMRT = false;
			isMRT_AfterFilter = false;
			isHedge = false;
      }
		isLock = (n == 0);
   }
};
EnumMyInfo MyInfo;
EnumPositionInfo MyPositionInfo;
void SetDistanceValue(double &var,double value,EnumDistType distType)
{
	var = value*Point();
	if(distType == 1)
		var = SymbolInfoDouble(Symbol(),SYMBOL_BID)*value/100;
	if(distType == 2)
		var = ATR()*value;
}
void SetDistanceValues()
{
	SetDistanceValue(m_StartDistance,StartDistance,StartDistanceDistType);
	SetDistanceValue(m_MRTTPAmount,MRTTPAmount,MRTTPAmountDistType);
	SetDistanceValue(m_DistanceIncrementValue,DistanceIncrementValue,DistanceIncrementValueDistType);
	SetDistanceValue(m_SecondaryTPAmount,SecondaryTPAmount,SecondaryTPAmountDistType);
	SetDistanceValue(m_SecondaryOrderMaxDist,SecondaryOrderMaxDist,SecondaryOrderMaxDistDistType);
	SetDistanceValue(m_StartDistance_PS,StartDistance_PS,StartDistance_PSDistType);
	SetDistanceValue(m_DistanceIncrementValue_PS,DistanceIncrementValue_PS,DistanceIncrementValue_PSDistType);
	SetDistanceValue(m_MRTTPAmount_AfterFilter,MRTTPAmount_AfterFilter,MRTTPAmount_AfterFilterDistType);
	SetDistanceValue(m_StartDistance_AfterFilter,StartDistance_AfterFilter,StartDistance_AfterFilterDistType);
	SetDistanceValue(m_DistanceIncrementValue_AfterFilter,DistanceIncrementValue_AfterFilter,DistanceIncrementValue_AfterFilterDistType);
	SetDistanceValue(m_BEAfter_LockMRTAfterFilter,BEAfter_LockMRTAfterFilter,BEAfter_LockMRTAfterFilterDistType);
	SetDistanceValue(m_BEAt_LockMRTAfterFilter,BEAt_LockMRTAfterFilter,BEAt_LockMRTAfterFilterDistType);
	SetDistanceValue(m_SecondaryTPAmount_AfterFilter,SecondaryTPAmount_AfterFilter,SecondaryTPAmount_AfterFilterDistType);
	SetDistanceValue(m_SecondaryOrderMaxDist_AfterFilter,SecondaryOrderMaxDist_AfterFilter,SecondaryOrderMaxDist_AfterFilterDistType);
	SetDistanceValue(m_BEAt_LockAfterFilter,BEAt_LockAfterFilter,BEAt_LockAfterFilterDistType);
	SetDistanceValue(m_BEAfter_LockAfterFilter,BEAfter_LockAfterFilter,BEAfter_LockAfterFilterDistType);
	SetDistanceValue(m_ReFillMaxDist,ReFillMaxDist,ReFillMaxDistDistType);
	SetDistanceValue(m_LockPullBackStart,LockPullBackStart,LockPullBackStartDistType);
	SetDistanceValue(m_LockBreakEvenAfter,LockBreakEvenAfter,LockBreakEvenAfterDistType);
	SetDistanceValue(m_LockBreakEvenAt,LockBreakEvenAt,LockBreakEvenAtDistType);
	SetDistanceValue(m_MainTSAfter,MainTSAfter,MainTSAfterDistType);
	SetDistanceValue(m_MainTSStep,MainTSStep,MainTSStepDistType);
	SetDistanceValue(m_MainTSDistance,MainTSDistance,MainTSDistanceDistType);
	SetDistanceValue(m_MainTSBlock,MainTSBlock,MainTSBlockDistType);
	SetDistanceValue(m_MainReOpenDistance,MainReOpenDistance,MainReOpenDistanceDistType);
	SetDistanceValue(m_MainBreakEvenAfter,MainBreakEvenAfter,MainBreakEvenAfterDistType);
	SetDistanceValue(m_MainBreakEvenAt,MainBreakEvenAt,MainBreakEvenAtDistType);
	SetDistanceValue(m_MainTPAmount,MainTPAmount,MainTPAmountDistType);
	SetDistanceValue(m_MainSLAmount,MainSLAmount,MainSLAmountDistType);
	SetDistanceValue(m_MainHedgeCapsuleSL2,MainHedgeCapsuleSL2,MainHedgeCapsuleSL2DistType);
	SetDistanceValue(m_MainHedgeCapsuleSL,MainHedgeCapsuleSL,MainHedgeCapsuleSLDistType);
	SetDistanceValue(m_LockAfterFilterReOpenAmount,LockAfterFilterReOpenAmount,LockAfterFilterReOpenAmountDistType);
	SetDistanceValue(m_MinDistToClose,MinDistToClose,MinDistToCloseDistType);
	SetDistanceValue(m_StartDistance_PS_AfterFilter,StartDistance_PS_AfterFilter,StartDistance_PSDistType_AfterFilter);
	SetDistanceValue(m_DistanceIncrementValue_PS_AfterFilter,DistanceIncrementValue_PS_AfterFilter,DistanceIncrementValue_PSDistType_AfterFilter);
	SetDistanceValue(m_ReOpenDistAfterSelfDecrease,ReOpenDistAfterSelfDecrease,ReOpenDistAfterSelfDecreaseDistType);
	SetDistanceValue(m_LockAfterFilterReOpenAmount_MRTAfterFilter,LockAfterFilterReOpenAmount_MRTAfterFilter,LockAfterFilterReOpenAmountDistType_MRTAfterFilter);
	SetDistanceValue(m_BEAfter_Capsule,BEAfter_Capsule,BEAfter_CapsuleDistType);
	SetDistanceValue(m_BEAt_Capsule,BEAt_Capsule,BEAt_CapsuleDistType);
	SetDistanceValue(m_TP_Capsule,TP_Capsule,TP_CapsuleDistType);

	SetDistanceValue(m_MinDecreaseLotAmountMRT,MinDecreaseLotAmountMRT,MinDecreaseLotAmountMRTDistType);
	SetDistanceValue(m_MinDecreaseLotAmountMRT_MRTAfterFilter,MinDecreaseLotAmountMRT_MRTAfterFilter,MinDecreaseLotAmountMRTDistType_MRTAfterFilter);
	SetDistanceValue(m_MinDecreaseLotAmountInCapsule,MinDecreaseLotAmountInCapsule,MinDecreaseLotAmountInCapsuleDistType);
	SetDistanceValue(m_DeacreaseHedgeCapsuleAfter,DeacreaseHedgeCapsuleAfter,DeacreaseHedgeCapsuleAfterDistType);
	SetDistanceValue(m_DistanceFromCurrentToCloseTrades,DistanceFromCurrentToCloseTrades,DistanceFromCurrentToCloseTradesDistType);


	for(int i=1;i<21;i++)
	{
		SetDistanceValue(MainGridDistance[i],MainGridDistance[i],MainGridDistanceDistType);
	}


}

void SaveData()
{
	GlobalVariableSet(prefix+"hedgeIndexBuy",MyInfo.buyHedge.index);
	GlobalVariableSet(prefix+"hedgeIndexSell",MyInfo.sellHedge.index);
	GlobalVariableSet(prefix+"previousEquity",MyInfo.previousEquity);
	GlobalVariableSet(prefix+"equity",MyInfo.equity);
	GlobalVariableSet(prefix+"equityBuy",MyInfo.equityBuy);
	GlobalVariableSet(prefix+"equitySell",MyInfo.equitySell);
	GlobalVariableSet(prefix+"startTime",MyInfo.startTime);
	GlobalVariableSet(prefix+"maxProfit",MyInfo.maxProfit);
	GlobalVariableSet(prefix+"previousEquityBuy",MyInfo.previousEquityBuy);
	GlobalVariableSet(prefix+"startTimeBuy",MyInfo.startTimeBuy);
	GlobalVariableSet(prefix+"maxProfitBuy",MyInfo.maxProfitBuy);
	GlobalVariableSet(prefix+"previousEquitySell",MyInfo.previousEquitySell);
	GlobalVariableSet(prefix+"startTimeSell",MyInfo.startTimeSell);
	GlobalVariableSet(prefix+"maxProfitSell",MyInfo.maxProfitSell);
	GlobalVariableSet(prefix+"pauseTrading",MyInfo.pauseTrading);
	GlobalVariableSet(prefix+"pauseTime",MyInfo.pauseTime);
	GlobalVariableSet(prefix+"lastUpdate",MyInfo.lastUpdate);
	GlobalVariableSet(prefix+"pauseBalance",MyInfo.pauseBalance);
	GlobalVariableSet(prefix+"pauseEquity",MyInfo.pauseEquity);
	GlobalVariableSet(prefix+"pauseAVG",MyInfo.pauseAVG);
	GlobalVariableSet(prefix+"trailingMainBuy",MyInfo.trailingMainBuy);
	GlobalVariableSet(prefix+"trailingMainValueBuy",MyInfo.trailingMainValueBuy);
	GlobalVariableSet(prefix+"beStartedMainBuy",MyInfo.beStartedMainBuy);
	GlobalVariableSet(prefix+"trailingMainSell",MyInfo.trailingMainSell);
	GlobalVariableSet(prefix+"trailingMainValueSell",MyInfo.trailingMainValueSell);
	GlobalVariableSet(prefix+"beStartedMainSell",MyInfo.beStartedMainSell);
	GlobalVariableSet(prefix+"filterOutBuy",MyInfo.filterOutBuy);
	GlobalVariableSet(prefix+"lotBuy",MyInfo.lotBuy);
	GlobalVariableSet(prefix+"filterOutSell",MyInfo.filterOutSell);
	GlobalVariableSet(prefix+"lotSell",MyInfo.lotSell);
	GlobalVariableSet(prefix+"filterIndexBuy",MyInfo.filterIndexBuy);
	GlobalVariableSet(prefix+"filterIndexSell",MyInfo.filterIndexSell);

	GlobalVariableSet(prefix+"buyMRT.lockCloseReason",MyInfo.buyMRT.lockCloseReason);
	GlobalVariableSet(prefix+"buyMRT.lockStartLotAmount",MyInfo.buyMRT.lockStartLotAmount);
	GlobalVariableSet(prefix+"sellMRT.lockCloseReason",MyInfo.sellMRT.lockCloseReason);
	GlobalVariableSet(prefix+"sellMRT.lockStartLotAmount",MyInfo.sellMRT.lockStartLotAmount);

	
	GlobalVariableSet(prefix+"bigDDTriggered",MyInfo.bigDDTriggered);
	GlobalVariableSet(prefix+"bigDDTriggered",MyInfo.lockCapsuleIndex);
	GlobalVariableSet(prefix+"historySavedProfitBuy",MyInfo.historySavedProfitBuy);
	GlobalVariableSet(prefix+"historySavedProfitSell",MyInfo.historySavedProfitSell);
	
	
	GlobalVariableSet(prefix+"maxEquity",MyInfo.maxEquity);
	GlobalVariableSet(prefix+"maxEquityBuy",MyInfo.maxEquityBuy);
	GlobalVariableSet(prefix+"maxEquitySell",MyInfo.maxEquitySell);
	
}
void ReadData()
{
	if(MQLInfoInteger(MQL_TESTER))
      GlobalVariablesDeleteAll(prefix);
      
   if(!GlobalVariableCheck(prefix+"hedgeIndexBuy"))
   	MyInfo.buyHedge.index = 0;
   else
      MyInfo.buyHedge.index = GlobalVariableGet(prefix+"hedgeIndexBuy");
      
   if(!GlobalVariableCheck(prefix+"hedgeIndexSell"))
   	MyInfo.sellHedge.index = 0;
   else
      MyInfo.sellHedge.index = GlobalVariableGet(prefix+"hedgeIndexSell");
      
   if(!GlobalVariableCheck(prefix+"equity"))
   {
   	MyInfo.equity = InitialBalance;
   	MyInfo.previousEquity = InitialBalance;
   	MyInfo.startTime = 0;
   	MyInfo.maxProfit = 0;
   }
   else
   {
      MyInfo.equity = GlobalVariableGet(prefix+"equity");
      MyInfo.previousEquity = GlobalVariableGet(prefix+"previousEquity");
      MyInfo.startTime = GlobalVariableGet(prefix+"startTime");
      MyInfo.maxProfit = GlobalVariableGet(prefix+"maxProfit");
   }
   
   if(!GlobalVariableCheck(prefix+"equityBuy"))
   {
   	MyInfo.equityBuy = InitialBalance;
   	MyInfo.previousEquityBuy = InitialBalance;
   	MyInfo.startTimeBuy = 0;
   	MyInfo.maxProfitBuy = 0;
   }
   else
   {
      MyInfo.equityBuy = GlobalVariableGet(prefix+"equityBuy");
      MyInfo.previousEquityBuy = GlobalVariableGet(prefix+"previousEquityBuy");
      MyInfo.startTimeBuy = GlobalVariableGet(prefix+"startTimeBuy");
      MyInfo.maxProfitBuy = GlobalVariableGet(prefix+"maxProfitBuy");
   }
   
   if(!GlobalVariableCheck(prefix+"equitySell"))
   {
   	MyInfo.equitySell = InitialBalance;
   	MyInfo.previousEquitySell = InitialBalance;
   	MyInfo.startTimeSell = 0;
   	MyInfo.maxProfitSell = 0;
   }
   else
   {
      MyInfo.equitySell = GlobalVariableGet(prefix+"equitySell");
      MyInfo.previousEquitySell = GlobalVariableGet(prefix+"previousEquitySell");
      MyInfo.startTimeSell = GlobalVariableGet(prefix+"startTimeSell");
      MyInfo.maxProfitSell = GlobalVariableGet(prefix+"maxProfitSell");
   }
   
   if(!GlobalVariableCheck(prefix+"pauseTrading"))
   	MyInfo.pauseTrading = 0;
   else
      MyInfo.pauseTrading = GlobalVariableGet(prefix+"pauseTrading");
   if(!GlobalVariableCheck(prefix+"pauseTime"))
   	MyInfo.pauseTime = 0;
   else
      MyInfo.pauseTime = GlobalVariableGet(prefix+"pauseTime");
      
   if(!GlobalVariableCheck(prefix+"lastUpdate"))
   	MyInfo.lastUpdate = 0;
   else
      MyInfo.lastUpdate = GlobalVariableGet(prefix+"lastUpdate");
   
   if(!GlobalVariableCheck(prefix+"pauseBalance"))
   	MyInfo.pauseBalance = 0;
   else
      MyInfo.pauseBalance = GlobalVariableGet(prefix+"pauseBalance");
      
   if(!GlobalVariableCheck(prefix+"pauseEquity"))
   	MyInfo.pauseEquity = 0;
   else
      MyInfo.pauseEquity = GlobalVariableGet(prefix+"pauseEquity");
      
   if(!GlobalVariableCheck(prefix+"pauseAVG"))
   	MyInfo.pauseAVG = 0;
   else
      MyInfo.pauseAVG = GlobalVariableGet(prefix+"pauseAVG");
      
   if(!GlobalVariableCheck(prefix+"trailingMainBuy"))
   	MyInfo.trailingMainBuy = 0;
   else
      MyInfo.trailingMainBuy = GlobalVariableGet(prefix+"trailingMainBuy");
      
   if(!GlobalVariableCheck(prefix+"trailingMainValueBuy"))
   	MyInfo.trailingMainValueBuy = 0;
   else
      MyInfo.trailingMainValueBuy = GlobalVariableGet(prefix+"trailingMainValueBuy");
      
   if(!GlobalVariableCheck(prefix+"beStartedMainBuy"))
   	MyInfo.beStartedMainBuy = 0;
   else
      MyInfo.beStartedMainBuy = GlobalVariableGet(prefix+"beStartedMainBuy"); 
   
   if(!GlobalVariableCheck(prefix+"trailingMainSell"))
   	MyInfo.trailingMainSell = 0;
   else
      MyInfo.trailingMainSell = GlobalVariableGet(prefix+"trailingMainSell");
      
   if(!GlobalVariableCheck(prefix+"trailingMainValueSell"))
   	MyInfo.trailingMainValueSell = 0;
   else
      MyInfo.trailingMainValueSell = GlobalVariableGet(prefix+"trailingMainValueSell");
      
   if(!GlobalVariableCheck(prefix+"beStartedMainSell"))
   	MyInfo.beStartedMainSell = 0;
   else
      MyInfo.beStartedMainSell = GlobalVariableGet(prefix+"beStartedMainSell");  
   
   if(!GlobalVariableCheck(prefix+"filterOutBuy"))
   	MyInfo.filterOutBuy = 0;
   else
      MyInfo.filterOutBuy = GlobalVariableGet(prefix+"filterOutBuy");
      
   if(!GlobalVariableCheck(prefix+"lotBuy"))
   	MyInfo.lotBuy = 0;
   else
      MyInfo.lotBuy = GlobalVariableGet(prefix+"lotBuy"); 
   
   if(!GlobalVariableCheck(prefix+"filterOutSell"))
   	MyInfo.filterOutSell = 0;
   else
      MyInfo.filterOutSell = GlobalVariableGet(prefix+"filterOutSell");
      
   if(!GlobalVariableCheck(prefix+"lotSell"))
   	MyInfo.lotSell = 0;
   else
      MyInfo.lotSell = GlobalVariableGet(prefix+"lotSell");  
      
   
   if(!GlobalVariableCheck(prefix+"filterIndexBuy"))
   	MyInfo.filterIndexBuy = 0;
   else
      MyInfo.filterIndexBuy = GlobalVariableGet(prefix+"filterIndexBuy");  
   
   if(!GlobalVariableCheck(prefix+"filterIndexSell"))
   	MyInfo.filterIndexSell = 0;
   else
      MyInfo.filterIndexSell = GlobalVariableGet(prefix+"filterIndexSell");   
   
   
   
   if(!GlobalVariableCheck(prefix+"buyMRT.lockCloseReason"))
   	MyInfo.buyMRT.lockCloseReason = 0;
   else
      MyInfo.buyMRT.lockCloseReason = GlobalVariableGet(prefix+"buyMRT.lockCloseReason"); 
      
   if(!GlobalVariableCheck(prefix+"buyMRT.lockStartLotAmount"))
   	MyInfo.buyMRT.lockStartLotAmount = 0;
   else
      MyInfo.buyMRT.lockStartLotAmount = GlobalVariableGet(prefix+"buyMRT.lockStartLotAmount"); 
      
   if(!GlobalVariableCheck(prefix+"sellMRT.lockCloseReason"))
   	MyInfo.sellMRT.lockCloseReason = 0;
   else
      MyInfo.sellMRT.lockCloseReason = GlobalVariableGet(prefix+"sellMRT.lockCloseReason"); 
      
   if(!GlobalVariableCheck(prefix+"sellMRT.lockStartLotAmount"))
   	MyInfo.sellMRT.lockStartLotAmount = 0;
   else
      MyInfo.sellMRT.lockStartLotAmount = GlobalVariableGet(prefix+"sellMRT.lockStartLotAmount");
       
   if(!GlobalVariableCheck(prefix+"buyMRT.lastDDTrigger"))
   	MyInfo.buyMRT.lastDDTrigger = 0;
   else
      MyInfo.buyMRT.lastDDTrigger = GlobalVariableGet(prefix+"buyMRT.lastDDTrigger");  
        
   if(!GlobalVariableCheck(prefix+"sellMRT.lastDDTrigger"))
   	MyInfo.sellMRT.lastDDTrigger = 0;
   else
      MyInfo.sellMRT.lastDDTrigger = GlobalVariableGet(prefix+"sellMRT.lastDDTrigger");    
	  
	
   if(!GlobalVariableCheck(prefix+"bigDDTriggered"))
   	MyInfo.bigDDTriggered = 0;
   else
      MyInfo.bigDDTriggered = GlobalVariableGet(prefix+"bigDDTriggered");   
      
    
   if(!GlobalVariableCheck(prefix+"lockCapsuleIndex"))
   	MyInfo.lockCapsuleIndex = 0;
   else
      MyInfo.lockCapsuleIndex = GlobalVariableGet(prefix+"lockCapsuleIndex");  
      
   if(!GlobalVariableCheck(prefix+"historySavedProfitBuy"))
   	MyInfo.historySavedProfitBuy = 0;
   else
      MyInfo.historySavedProfitBuy = GlobalVariableGet(prefix+"historySavedProfitBuy"); 
   if(!GlobalVariableCheck(prefix+"historySavedProfitSell"))
   	MyInfo.historySavedProfitSell = 0;
   else
      MyInfo.historySavedProfitSell = GlobalVariableGet(prefix+"historySavedProfitSell"); 
      
      
      
   if(!GlobalVariableCheck(prefix+"maxEquity"))
   	MyInfo.maxEquity = InitialBalance;
   else
      MyInfo.maxEquity = GlobalVariableGet(prefix+"maxEquity"); 
   if(!GlobalVariableCheck(prefix+"maxEquityBuy"))
   	MyInfo.maxEquityBuy = InitialBalance;
   else
      MyInfo.maxEquityBuy = GlobalVariableGet(prefix+"maxEquityBuy"); 
   if(!GlobalVariableCheck(prefix+"maxEquitySell"))
   	MyInfo.maxEquitySell = InitialBalance;
   else
      MyInfo.maxEquitySell = GlobalVariableGet(prefix+"maxEquitySell"); 
}

datetime newBarDT = 0;
bool IsNewBar()
{
	if(iBarShift(Symbol(),PERIOD_M15,newBarDT)!=iBarShift(Symbol(),PERIOD_M15,TimeCurrent()))
	{
		newBarDT = TimeCurrent();
		return true;
	}
	return false;
}
int OnInit()
  {   
   TesterHideIndicators(true);
   string ExpirationTime = "2026.09.01 00:00:00";
   if (TimeCurrent()>=StringToTime(ExpirationTime))
   {
      MessageBox("EA is expired contact with admin","ERROR",1);
      return INIT_FAILED;
   }
   
//---
   
   
   MainGridPct[1] = MainGridPct_1;
   MainGridPct[2] = MainGridPct_2;
   MainGridPct[3] = MainGridPct_3;
   MainGridPct[4] = MainGridPct_4;
   MainGridPct[5] = MainGridPct_5;
   MainGridPct[6] = MainGridPct_6;
   MainGridPct[7] = MainGridPct_7;
   MainGridPct[8] = MainGridPct_8;
   MainGridPct[9] = MainGridPct_9;
   MainGridPct[10] = MainGridPct_10;
   MainGridPct[11] = MainGridPct_11;
   MainGridPct[12] = MainGridPct_12;
   MainGridPct[13] = MainGridPct_13;
   MainGridPct[14] = MainGridPct_14;
   MainGridPct[15] = MainGridPct_15;
   MainGridPct[16] = MainGridPct_16;
   MainGridPct[17] = MainGridPct_17;
   MainGridPct[18] = MainGridPct_18;
   MainGridPct[19] = MainGridPct_19;
   MainGridPct[20] = MainGridPct_20;
   
   MainGridDistance[0]=0;
   MainGridDistance[1] = MainGridDistance_1;
   MainGridDistance[2] = MainGridDistance_2;
   MainGridDistance[3] = MainGridDistance_3;
   MainGridDistance[4] = MainGridDistance_4;
   MainGridDistance[5] = MainGridDistance_5;
   MainGridDistance[6] = MainGridDistance_6;
   MainGridDistance[7] = MainGridDistance_7;
   MainGridDistance[8] = MainGridDistance_8;
   MainGridDistance[9] = MainGridDistance_9;
   MainGridDistance[10] = MainGridDistance_10;
   MainGridDistance[11] = MainGridDistance_11;
   MainGridDistance[12] = MainGridDistance_12;
   MainGridDistance[13] = MainGridDistance_13;
   MainGridDistance[14] = MainGridDistance_14;
   MainGridDistance[15] = MainGridDistance_15;
   MainGridDistance[16] = MainGridDistance_16;
   MainGridDistance[17] = MainGridDistance_17;
   MainGridDistance[18] = MainGridDistance_18;
   MainGridDistance[19] = MainGridDistance_19;
   MainGridDistance[20] = MainGridDistance_20;
   
   if(UseFilterToContinue)
   {
      if(UseMAFilter)
      {
      	midH[1] = iMA(Symbol(),FilterToContinue_MA_TF,MAPeriod_Mid,MAShift_Mid,MAMethod_Mid,MAAppliedPrice_Mid);
         slowH[1] = iMA(Symbol(),FilterToContinue_MA_TF,MAPeriod_Slow,MAShift_Slow,MAMethod_Slow,MAAppliedPrice_Slow);
         fastH[1] = iMA(Symbol(),FilterToContinue_MA_TF,MAPeriod_Fast,MAShift_Fast,MAMethod_Fast,MAAppliedPrice_Fast);
      }
      if(UseRSIFilter)
      {
         rsiH[1] = iRSI(Symbol(),FilterToContinue_RSI_TF,RSIPeriod,RSIAppliedPrice);
      }
      if(UseMACDFilter)
      {
         macdH[1] = iMACD(Symbol(),FilterToContinue_MACD_TF,MACDFastPeriod,MACDSlowPeriod,MACDPeriod,MACDAppliedPrice);
      }
   }

   if(UseMAFilter)
   {
		midH[0] = iMA(Symbol(),MA_TF,MAPeriod_Mid,MAShift_Mid,MAMethod_Mid,MAAppliedPrice_Mid);
      slowH[0] = iMA(Symbol(),MA_TF,MAPeriod_Slow,MAShift_Slow,MAMethod_Slow,MAAppliedPrice_Slow);
      fastH[0] = iMA(Symbol(),MA_TF,MAPeriod_Fast,MAShift_Fast,MAMethod_Fast,MAAppliedPrice_Fast);
   }
   if(UseRSIFilter)
   {
      rsiH[0] = iRSI(Symbol(),RSI_TF,RSIPeriod,RSIAppliedPrice);
   }
   if(UseMACDFilter)
   {
      macdH[0] = iMACD(Symbol(),MACD_TF,MACDFastPeriod,MACDSlowPeriod,MACDPeriod,MACDAppliedPrice);
   }
   if(UseLotSizeFilterAccordingToMA)
      maLotSizeH = iMA(Symbol(),MA_TF_LotSize,MAPeriod_LotSize,MAShift_LotSize,MAMethod_LotSize,MAAppliedPrice_LotSize);
      
   atrH = iATR(Symbol(),DistTypeATRTF,DistTypeATRPeriod);
   TF = MA_TF;
   if(TF>MACD_TF)	
   	TF=MACD_TF;
  	if(TF>RSI_TF)
  		TF=RSI_TF;
  	SetDistanceValues();
  	ReadData();
  	
  	
   MyInfo.MainGridLastIndex=1;
   if(MainGridType)
   {
	   for(int i=1;i<21;i++)
	   {
	      if(MainGridPct[i] == 0)
	      {
	         MyInfo.MainGridLastIndex=i-1;
	         break;
	      }
	   }
   }
   
   
   MyInfo.wholeClosedProfitBuy = MyInfo.historySavedProfitBuy;
   MyInfo.wholeClosedProfitSell = MyInfo.historySavedProfitSell;
//---
   return(INIT_SUCCEEDED);
  }

int atrH;
int midH[2],slowH[2],fastH[2],macdH[2],rsiH[2];
int maLotSizeH;
double ATR(int index=1)
{
   double v[];
   ArraySetAsSeries(v,true);
   CopyBuffer(atrH,0,0,index+1,v);
   return v[index];
} 
double MASlow(int index=1,int handler=0)
{
	index = MathMax(1,iBarShift(Symbol(),MA_TF,iTime(Symbol(),TF,index)));
   double v[];
   ArraySetAsSeries(v,true);
   CopyBuffer(slowH[handler],0,0,index+1,v);
   return v[index];
} 
double MAFast(int index=1,int handler=0)
{
	index = MathMax(1,iBarShift(Symbol(),MA_TF,iTime(Symbol(),TF,index)));
   double v[];
   ArraySetAsSeries(v,true);
   CopyBuffer(fastH[handler],0,0,index+1,v);
   return v[index];
} 
double MAMid(int index=1,int handler=0)
{
	index = MathMax(1,iBarShift(Symbol(),MA_TF,iTime(Symbol(),TF,index)));
   double v[];
   ArraySetAsSeries(v,true);
   CopyBuffer(midH[handler],0,0,index+1,v);
   return v[index];
} 

double MALotSize(int index=1)
{
   double v[];
   ArraySetAsSeries(v,true);
   CopyBuffer(maLotSizeH,0,0,index+1,v);
   return v[index];
} 

double MACD(int index=1,int handler=0)
{
	index = MathMax(1,iBarShift(Symbol(),MACD_TF,iTime(Symbol(),TF,index)));
   double v[];
   ArraySetAsSeries(v,true);
   CopyBuffer(macdH[handler],0,0,index+1,v);
   return v[index];
} 
double RSI(int index=1,int handler=0)
{
	index = MathMax(1,iBarShift(Symbol(),RSI_TF,iTime(Symbol(),TF,index)));
   double v[];
   ArraySetAsSeries(v,true);
   CopyBuffer(rsiH[handler],0,0,index+1,v);
   return v[index];
} 


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
	SaveData();
   if(MQLInfoInteger(MQL_TESTER))
      GlobalVariablesDeleteAll(prefix);
   ObjectsDeleteAll(0,prefix);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
double lastBid = 0;
bool updateHedgeIndex = false;
void OnTick()
  {
//---
   updateHedgeIndex = true;
	if(OncePerCandle)
	{
		if(!Once())
			return;
	}
	if(MathAbs(lastBid-SymbolInfoDouble(Symbol(),SYMBOL_BID))<m_IgnorePrice)
	{
		lastBid = SymbolInfoDouble(Symbol(),SYMBOL_BID);
		return;
   }
   if(UsePauseTradingByDD)
   {
      if(MyInfo.pauseTrading == 1)
      {
         if(TimeCurrent()>MyInfo.pauseTime)
         {
            
   			
   			bool buy = (MAFast(1,1)>MAMid(1,1) && MAMid(1,1)>MASlow(1,1));
   			bool sell = (MAFast(1,1)<MAMid(1,1) && MAMid(1,1)<MAFast(1,1));
   			
            bool filter = (!UseMAFilter || buy && (OpenSide == 0 || OpenSide == 2) || sell && (OpenSide == 1 || OpenSide == 2));
            filter = filter && (!UseRSIFilter || RSI(1,1)<RSIBuyLevel && (OpenSide == 0 || OpenSide == 2) || RSI(1,1)>RSISellLevel && (OpenSide == 1 || OpenSide == 2));
            filter = filter && (!UseMACDFilter || MACD(1,1)<MACDBuyLevel && (OpenSide == 0 || OpenSide == 2) || MACD(1,1)>MACDSellLevel && (OpenSide == 1 || OpenSide == 2));
            filter = filter || (!UseFilterToContinue);
            if(!filter)
            {
            	MyInfo.pauseTrading = 2;
            }
            else
            {
               MyInfo.pauseTrading = 0;
            }
            return;
         }
         return;
      }
      if(MyInfo.pauseTrading == 2)
      {
      	
			bool buy = (MAFast(1,1)>MAMid(1,1) && MAMid(1,1)>MASlow(1,1));
			bool sell = (MAFast(1,1)<MAMid(1,1) && MAMid(1,1)<MAFast(1,1));
         bool filter = (!UseMAFilter || buy && (OpenSide == 0 || OpenSide == 2)|| sell && (OpenSide == 1 || OpenSide == 2));
         filter = filter && (!UseRSIFilter || RSI(1,1)<RSIBuyLevel && (OpenSide == 0 || OpenSide == 2) || RSI(1,1)>RSISellLevel && (OpenSide == 1 || OpenSide == 2));
         filter = filter && (!UseMACDFilter || MACD(1,1)<MACDBuyLevel && (OpenSide == 0 || OpenSide == 2) || MACD(1,1)>MACDSellLevel && (OpenSide == 1 || OpenSide == 2));
         filter = filter || (!UseFilterToContinue);
         if(filter)
         {
            MyInfo.pauseTrading = 0;
         }
         return;
      }
   }
   
   
   FindFilterCrossOver();
   
   FirstRun();
   if(!MyInfo.isAction)
   {
   	MyInfo.startTime = TimeCurrent();
   	MyInfo.previousEquity = MyInfo.equity;
   	MyInfo.startTimeSell = TimeCurrent();
   	MyInfo.previousEquitySell = MathMax(MyInfo.previousEquitySell,MyInfo.equitySell);
   	MyInfo.startTimeBuy = TimeCurrent();
   	MyInfo.previousEquityBuy = MathMax(MyInfo.previousEquityBuy,MyInfo.equityBuy);
   	MyInfo.cycleClosedProfitBuy = 0;
   	MyInfo.cycleClosedProfitSell = 0;
   	MyInfo.historySavedProfitBuy = MyInfo.wholeClosedProfitBuy;
   	MyInfo.historySavedProfitSell = MyInfo.wholeClosedProfitSell;
   }
   if(!MyInfo.buyMRT.isAction)
   {
   	MyInfo.startTimeBuy = TimeCurrent();
   	MyInfo.cycleClosedProfitBuy = 0;
   	MyInfo.previousEquityBuy = MathMax(MyInfo.previousEquityBuy,MyInfo.equityBuy);
   }
   if(!MyInfo.sellMRT.isAction)
   {
   	MyInfo.startTimeSell = TimeCurrent();
   	MyInfo.cycleClosedProfitSell = 0;
   	MyInfo.previousEquitySell = MathMax(MyInfo.previousEquitySell,MyInfo.equitySell);
  	}
   
   if(CheckCloseBySymbol())
   	return;
   
   
   
   SecondRun();
   
   CheckForOpenMRT();
      
   if(UseHedge)
   {
      CheckForOpenHedge(0,MyInfo.buyHedge);
      CheckForOpenHedge(1,MyInfo.sellHedge);
   }
   
   if(UseDecreaseLotAmountInCapsule_MainHedge
   || UseDecreaseLotAmountInMRTCapsule_MRTAfterFilter
   || UseDecreaseLotAmountInMRTCapsule)
      RunForSelfDecrease();
      
   
   
   
   if(MyInfo.isAction
   && CloseAfterEquityIncrease)
   {
		CheckForEquityClose();
   }  
   ThirdRun();
   
   if(UseHedge && updateHedgeIndex)//Change Index by lower one
   {
		MyInfo.buyHedge.index = MathMax(0,MyInfo.buyHedge.lastHedegeIndex);
		MyInfo.sellHedge.index = MathMax(0,MyInfo.sellHedge.lastHedegeIndex);
  	}
  	
  	
   
  }
//+------------------------------------------------------------------+



int capsuleAmountBuy;
bool capsuledBuy[];
int capsuleIndexBuy[];
double capsuleProfitBuy[];

int capsuleAmountSell;
bool capsuledSell[];
int capsuleIndexSell[];
double capsuleProfitSell[];
void FirstRun()
{
	
	MyInfo.marginUsed=0;
	
	MyInfo.wholeOpenProfit =0;
   MyInfo.wholeOpenProfitBuy = 0;
   MyInfo.wholeOpenProfitSell = 0;
   
   MyInfo.commissionBuy = 0;
   MyInfo.commissionSell = 0;
   
   MyInfo.hedgeCapsuleAmount = 0;
   MyInfo.mrtCapsuleAmount = 0;
   MyInfo.mrtAfterFilterCapsuleAmount = 0;
   
   
   MyInfo.hedgeCapsuleAmount = 0;
   MyInfo.mrtCapsuleAmount = 0 ;
   MyInfo.mrtAfterFilterCapsuleAmount = 0;
   MyInfo.capsuleAmount = 0;
   MyInfo.isAction = false;
   
   
   MyInfo.haveLock = false;
   MyInfo.haveLockCapsule = false;
   
   MyInfo.buyHedge.op = 0;
   MyInfo.buyHedge.locked = false;
   MyInfo.buyHedge.allLotSum = 0;
   MyInfo.buyHedge.allProfitSum = 0;
   MyInfo.buyHedge.capsuleAmount = 0;
   MyInfo.buyHedge.profit = 0;
   MyInfo.buyHedge.tkt = 0;
   MyInfo.buyHedge.lastMRT = 0;
   MyInfo.buyHedge.lastHedgeDT = 0;
   MyInfo.buyHedge.lastHedgePositionID = 0;
   MyInfo.buyHedge.lastHedegeIndex = 0;
   
   MyInfo.sellHedge.op = 0;
   MyInfo.sellHedge.locked = false;
   MyInfo.sellHedge.allLotSum = 0;
   MyInfo.sellHedge.allProfitSum = 0;
   MyInfo.sellHedge.capsuleAmount = 0;
   MyInfo.sellHedge.profit = 0;
   MyInfo.sellHedge.tkt= 0;
   MyInfo.sellHedge.lastMRT = 0;
   MyInfo.sellHedge.lastHedgeDT = 0;
   MyInfo.sellHedge.lastHedgePositionID = 0;
   MyInfo.sellHedge.lastHedegeIndex = 0;
   
   
   
   MyInfo.buyHedge.reOpen = true;
   MyInfo.sellHedge.reOpen = true;
   
   MyInfo.buyMRT.isAction = false;
   MyInfo.sellMRT.isAction = false;
   
   MyInfo.buyMRT.oppositeLot=0;
   MyInfo.buyMRT.positiveLot=0;
   MyInfo.buyMRT.oppositeOP=0;
   MyInfo.buyMRT.positiveOP=0;
   MyInfo.buyMRT.oppositeN=0;
   MyInfo.buyMRT.positiveN=1;
   MyInfo.buyMRT.avgPrice=0;
   MyInfo.buyMRT.lotSum =0;
   MyInfo.buyMRT.profit=0;
   MyInfo.buyMRT.firstOP = 0;
   MyInfo.buyMRT.nthTrade=-1;
   MyInfo.buyMRT.nthTradeFromAbove=-1;
   MyInfo.buyMRT.lockTkt=0;
   MyInfo.buyMRT.lockLot = 0;
   MyInfo.buyMRT.lockProfit = 0;
   MyInfo.buyMRT.isHedged = 0;
   MyInfo.buyMRT.lastN = 0;
   MyInfo.buyMRT.avgOP = 0;
   MyInfo.buyMRT.lotSumMRTAfterFilter = 0;
   MyInfo.buyMRT.avgMRTAfterFilter = 0;
   MyInfo.buyMRT.profitMRTAfterFilter = 0;
	MyInfo.buyMRT.lockLastNType = 0;
   MyInfo.buyMRT.lastOpenedN = 0;
   MyInfo.buyMRT.lastOpenedT = 0;
	
   
   MyInfo.sellMRT.oppositeLot=0;
   MyInfo.sellMRT.positiveLot=0;
   MyInfo.sellMRT.oppositeOP=0;
   MyInfo.sellMRT.positiveOP=0;
   MyInfo.sellMRT.oppositeN=0;
   MyInfo.sellMRT.positiveN=1;
   MyInfo.sellMRT.avgPrice=0;
   MyInfo.sellMRT.lotSum =0;
   MyInfo.sellMRT.profit=0;
   MyInfo.sellMRT.firstOP = 0;
   MyInfo.sellMRT.nthTrade=-1;
   MyInfo.sellMRT.nthTradeFromAbove=-1;
   MyInfo.sellMRT.lockTkt=0;
   MyInfo.sellMRT.lockLot = 0;
   MyInfo.sellMRT.lockProfit = 0;
   MyInfo.sellMRT.isHedged = 0;
   MyInfo.sellMRT.lastN = 0;
   MyInfo.sellMRT.avgOP = 0;
   MyInfo.sellMRT.lotSumMRTAfterFilter = 0;
   MyInfo.sellMRT.avgMRTAfterFilter = 0;
   MyInfo.sellMRT.profitMRTAfterFilter = 0;
	MyInfo.sellMRT.lockLastNType = 0;
   MyInfo.sellMRT.lastOpenedN = 0;
   MyInfo.sellMRT.lastOpenedT = 0;
	
	
	MyInfo.buyMRT_AfterFilter.lastIndex=0;
	MyInfo.sellMRT_AfterFilter.lastIndex=0;
   MyInfo.buyMRT_AfterFilter.lastOT = 0;
   MyInfo.sellMRT_AfterFilter.lastOT = 0;
   
   ArrayFill(MyInfo.buyMRT_AfterFilter.lockReOpen,0,1000,1);
	ArrayFill(MyInfo.buyMRT_AfterFilter.mrtCycle,0,1000,0);
	ArrayFill(MyInfo.buyMRT_AfterFilter.lastN,0,1000,0);
	ArrayFill(MyInfo.buyMRT_AfterFilter.lockTkt,0,1000,0);
	ArrayFill(MyInfo.buyMRT_AfterFilter.lotSum,0,1000,0);
	ArrayFill(MyInfo.buyMRT_AfterFilter.opSum,0,1000,0);
	ArrayFill(MyInfo.buyMRT_AfterFilter.profit,0,1000,0);
	ArrayFill(MyInfo.buyMRT_AfterFilter.lockProfit,0,1000,0);
	ArrayFill(MyInfo.buyMRT_AfterFilter.typeConfirmed,0,1000,0);
	ArrayFill(MyInfo.buyMRT_AfterFilter.positiveLastN,0,1000,0);
	ArrayFill(MyInfo.buyMRT_AfterFilter.lastOpenedN,0,1000,0);
	ArrayFill(MyInfo.buyMRT_AfterFilter.lastOpenedT,0,1000,0);
	
	
   ArrayFill(MyInfo.sellMRT_AfterFilter.lockReOpen,0,1000,1);
	ArrayFill(MyInfo.sellMRT_AfterFilter.mrtCycle,0,1000,0);
	ArrayFill(MyInfo.sellMRT_AfterFilter.lastN,0,1000,0);
	ArrayFill(MyInfo.sellMRT_AfterFilter.lockTkt,0,1000,0);
	ArrayFill(MyInfo.sellMRT_AfterFilter.lotSum,0,1000,0);
	ArrayFill(MyInfo.sellMRT_AfterFilter.opSum,0,1000,0);
	ArrayFill(MyInfo.sellMRT_AfterFilter.profit,0,1000,0);
	ArrayFill(MyInfo.sellMRT_AfterFilter.lockProfit,0,1000,0);
	ArrayFill(MyInfo.sellMRT_AfterFilter.typeConfirmed,0,1000,0);
	ArrayFill(MyInfo.sellMRT_AfterFilter.positiveLastN,0,1000,0);
	ArrayFill(MyInfo.sellMRT_AfterFilter.lastOpenedN,0,1000,0);
	ArrayFill(MyInfo.sellMRT_AfterFilter.lastOpenedT,0,1000,0);
	
	
	ArrayFill(MyInfo.buyMRT_AfterFilter.isOpen1,0,1000,0);
	ArrayFill(MyInfo.buyMRT_AfterFilter.isOpen2,0,1000,0);
	ArrayFill(MyInfo.buyMRT_AfterFilter.isOpen3,0,1000,0);
	
	ArrayFill(MyInfo.buyMRT_AfterFilter.isOpen1,0,1000,0);
	ArrayFill(MyInfo.buyMRT_AfterFilter.isOpen2,0,1000,0);
	ArrayFill(MyInfo.buyMRT_AfterFilter.isOpen3,0,1000,0);
	
	ArrayFill(MyInfo.buyMRT.isOpen1,0,1000,0);
	ArrayFill(MyInfo.buyMRT.isOpen2,0,1000,0);
	ArrayFill(MyInfo.buyMRT.isOpen3,0,1000,0);
	
	ArrayFill(MyInfo.sellMRT.isOpen1,0,1000,0);
	ArrayFill(MyInfo.sellMRT.isOpen2,0,1000,0);
	ArrayFill(MyInfo.sellMRT.isOpen3,0,1000,0);
	
	
	ArrayFill(MyInfo.buyMRT_AfterFilter.lockReOpen,0,1000,1);
	ArrayFill(MyInfo.buyMRT_AfterFilter.lockLot,0,1000,0);
	
	ArrayFill(MyInfo.sellMRT_AfterFilter.lockReOpen,0,1000,1);
	ArrayFill(MyInfo.sellMRT_AfterFilter.lockLot,0,1000,0);
	
		
   capsuleAmountBuy=0;
	capsuleAmountSell=0;
	
	ArrayResize(capsuledBuy,MyInfo.buyHedge.index);
	ArrayResize(capsuleIndexBuy,MyInfo.buyHedge.index);
	ArrayResize(capsuleProfitBuy,MyInfo.buyHedge.index);
	
	ArrayResize(capsuleIndexSell,MyInfo.sellHedge.index);
	ArrayResize(capsuleProfitSell,MyInfo.sellHedge.index);
	ArrayResize(capsuledSell,MyInfo.sellHedge.index);
	
	ArrayFill(capsuledBuy,0,MyInfo.buyHedge.index,0);
	ArrayFill(capsuleIndexBuy,0,MyInfo.buyHedge.index,0);
	ArrayFill(capsuleProfitBuy,0,MyInfo.buyHedge.index,0);
	
	ArrayFill(capsuledSell,0,MyInfo.sellHedge.index,0);
	ArrayFill(capsuleIndexSell,0,MyInfo.sellHedge.index,0);
	ArrayFill(capsuleProfitSell,0,MyInfo.sellHedge.index,0);
	
	ZeroMemory(MyInfo.mainCapsuleInfo);
	
	MyInfo.mainCapsuleAmount=0;
	for(int i=PositionsTotal()-1;i>=0;i--)
	{
		if(!PositionSelectByTicket(PositionGetTicket(i)))continue;
		if(PositionGetString(POSITION_SYMBOL)!=Symbol()) continue;
		MyPositionInfo.magic = PositionGetInteger(POSITION_MAGIC);
      MyPositionInfo.orderType = PositionGetInteger(POSITION_TYPE);
      MyPositionInfo.comment = PositionGetString(POSITION_COMMENT);
      MyPositionInfo.ot = PositionGetInteger(POSITION_TIME);
      MyPositionInfo.orderProfit=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
      MyPositionInfo.tkt = PositionGetInteger(POSITION_TICKET);
		MyPositionInfo.lotSize = PositionGetDouble(POSITION_VOLUME);
		MyPositionInfo.op = PositionGetDouble(POSITION_PRICE_OPEN);
		MyPositionInfo.sl = PositionGetDouble(POSITION_SL);
      MyPositionInfo.isHistory = false;
      
      HistorySelectByPosition(MyPositionInfo.tkt);
   	int total2 = HistoryDealsTotal()-1;
   	for(int j=total2;j>=0;j--)
	   {
	      ulong tkt2 = HistoryDealGetTicket(j);
	      if(tkt2<1)continue;
	      if(HistoryDealGetInteger(tkt2,DEAL_ENTRY) == DEAL_ENTRY_IN)
	      {	
				MyPositionInfo.commission=HistoryDealGetDouble(tkt2,DEAL_COMMISSION);
	   	}
	   }
		if(MyPositionInfo.magic != MagicMRT
      && MyPositionInfo.magic != Magic
      && MyPositionInfo.magic != MagicMRT_AfterFilter)continue;
      
      MyPositionInfo.SetValues();
      
      
      
      // // /// /// //// /// //// /// // / / / // / /
		
		if(UseLockAfterFilter
		&& CloseMRTTradesInProfitAfterFilter
      && MyPositionInfo.isMRT
		&&!MyPositionInfo.isLock
		&& MyPositionInfo.n != 1
		&& MyPositionInfo.orderProfit>0)
		{
			if(!MyInfo.filterValueBuy
			&& MyPositionInfo.type == 0
			&& MyInfo.filterLockTriggerBuy)
			{
				MyPositionClose(MyPositionInfo.tkt);
				PrintLogs(__LINE__+" Close Trade AFter Filter if in profit");
				continue;
			}
			if(!MyInfo.filterValueSell
			&& MyPositionInfo.type == 1
			&& MyInfo.filterLockTriggerSell)
			{
				MyPositionClose(MyPositionInfo.tkt);
				PrintLogs(__LINE__+" Close Trade AFter Filter if in profit");
				continue;
			}
		}
		if(Use_LockMRTAfterFilter
		&& CloseMRTTradesInProfitAfterFilter_MRTAfterFilter
      && MyPositionInfo.isMRT_AfterFilter
		&&!MyPositionInfo.isLock
		&& MyPositionInfo.n != 1
		&& MyPositionInfo.orderProfit>0)
		{
			if(!MyInfo.filterValueBuy
			&& MyPositionInfo.type == 0
			&& MyInfo.filterLockTriggerBuy)
			{
				MyPositionClose(MyPositionInfo.tkt);
				PrintLogs(__LINE__+" Close Trade AFter Filter if in profit");
				continue;
			}
			if(!MyInfo.filterValueSell
			&& MyPositionInfo.type == 1
			&& MyInfo.filterLockTriggerSell)
			{
				MyPositionClose(MyPositionInfo.tkt);
				PrintLogs(__LINE__+" Close Trade AFter Filter if in profit");
				continue;
			}
		}
		
		if(!MyPositionInfo.isLock
		&& MyPositionInfo.isMRT_AfterFilter
		&&(CloseNthTradeFromAbove || CloseNthTrade))
		{
			if(MyPositionInfo.type == 0)
			{
		      if(MyPositionInfo.ot>MyInfo.buyMRT_AfterFilter.lastOpenedT[MyPositionInfo.index])
	         {
	         	MyInfo.buyMRT_AfterFilter.lastOpenedN[MyPositionInfo.index] = MyPositionInfo.n;	
	         	MyInfo.buyMRT_AfterFilter.lastOpenedT[MyPositionInfo.index] = MyPositionInfo.ot;
	      	}
	      	if(MyInfo.buyMRT_AfterFilter.lastN[MyPositionInfo.index] < MyPositionInfo.n)
		      {
		      	MyInfo.buyMRT_AfterFilter.lastOP[MyPositionInfo.index] = MyPositionInfo.op;
		         MyInfo.buyMRT_AfterFilter.lastN[MyPositionInfo.index] = MyPositionInfo.n;
		      }	
      		MyInfo.buyMRT_AfterFilter.lastIndex = MathMax(MyPositionInfo.index,MyInfo.buyMRT_AfterFilter.lastIndex);
      	}
      	else
			{
		      if(MyPositionInfo.ot>MyInfo.sellMRT_AfterFilter.lastOpenedT[MyPositionInfo.index])
	         {
	         	MyInfo.sellMRT_AfterFilter.lastOpenedN[MyPositionInfo.index] = MyPositionInfo.n;	
	         	MyInfo.sellMRT_AfterFilter.lastOpenedT[MyPositionInfo.index] = MyPositionInfo.ot;
	      	}
	      	if(MyInfo.sellMRT_AfterFilter.lastN[MyPositionInfo.index] < MyPositionInfo.n)
		      {
		      	MyInfo.sellMRT_AfterFilter.lastOP[MyPositionInfo.index] = MyPositionInfo.op;
		         MyInfo.sellMRT_AfterFilter.lastN[MyPositionInfo.index] = MyPositionInfo.n;
		      }	
      		MyInfo.sellMRT_AfterFilter.lastIndex = MathMax(MyPositionInfo.index,MyInfo.sellMRT_AfterFilter.lastIndex);
      	}
		}
      if(MyPositionInfo.isLock)
      {
      	FillInfoForCapsule();
      	MyInfo.haveLock = true;
      }
      if(!MyInfo.isAction)
      	MyInfo.isAction = true;
      
   	CalculateProfit();
		if(MyPositionInfo.isCapsule)
		{
			CheckForFeaturesCapsule();
			MyInfo.haveLockCapsule = true;
			continue;
		}
      
		
      if(!MyInfo.buyMRT.isAction)
      	MyInfo.buyMRT.isAction = MyPositionInfo.isMRT && MyPositionInfo.type == 0;
      if(!MyInfo.sellMRT.isAction)
      	MyInfo.sellMRT.isAction = MyPositionInfo.isMRT && MyPositionInfo.type == 1;
      
	   
      GetMRTInfo();
      CountProfitForMain();
      
	}
   
	double profit = 0;
   HistorySelect(MathMax(MyInfo.startTime,MyInfo.lastHistoryRun),TimeCurrent());
   ulong maxTkt = MyInfo.historyLastCheckedTkt;
	bool update= false;
   for(int i=HistoryDealsTotal()-1;i>=0;i--)
   {
      ulong tkt = HistoryDealGetTicket(i);
      if(tkt<1)continue;
      if(HistoryDealGetString(tkt,DEAL_SYMBOL) != Symbol())continue;
      if(HistoryDealGetInteger(tkt,DEAL_ENTRY) != DEAL_ENTRY_OUT)continue;
      if(tkt<=MyInfo.historyLastCheckedTkt)continue;
      
      maxTkt = MathMax(maxTkt,tkt);
 		MyPositionInfo.isHistory = true;
   	MyPositionInfo.ct = HistoryDealGetInteger(tkt,DEAL_TIME);
   	MyPositionInfo.cp = HistoryDealGetDouble(tkt,DEAL_PRICE);
		MyPositionInfo.tkt = tkt;
		MyPositionInfo.orderProfit=HistoryDealGetDouble(tkt,DEAL_PROFIT)+HistoryDealGetDouble(tkt,DEAL_SWAP)+HistoryDealGetDouble(tkt,DEAL_COMMISSION)+HistoryDealGetDouble(tkt,DEAL_FEE);
      
		MyPositionInfo.positionID = HistoryDealGetInteger(tkt,DEAL_POSITION_ID);
		MyPositionInfo.comment = HistoryDealGetString(tkt,DEAL_COMMENT);
   	HistorySelectByPosition(MyPositionInfo.positionID);
   	int total2 = HistoryDealsTotal()-1;
   	for(int j=total2;j>=0;j--)
	   {
	      ulong tkt2 = HistoryDealGetTicket(j);
	      if(tkt2<1)continue;
	      if(HistoryDealGetInteger(tkt2,DEAL_ENTRY) == DEAL_ENTRY_IN)
	      {	
	      	MyPositionInfo.magic = HistoryDealGetInteger(tkt2,DEAL_MAGIC);
		      MyPositionInfo.orderType = HistoryDealGetInteger(tkt2,DEAL_TYPE);
		      if(StringFind(MyPositionInfo.comment,"^")==-1)
		      	MyPositionInfo.comment = HistoryDealGetString(tkt2,DEAL_COMMENT);
		      MyPositionInfo.ot = HistoryDealGetInteger(tkt2,DEAL_TIME);
				MyPositionInfo.lotSize = HistoryDealGetDouble(tkt2,DEAL_VOLUME);
				MyPositionInfo.op = HistoryDealGetDouble(tkt2,DEAL_PRICE);
				MyPositionInfo.sl = HistoryDealGetDouble(tkt2,DEAL_SL);
				MyPositionInfo.orderProfit+=HistoryDealGetDouble(tkt2,DEAL_COMMISSION);
	   	}
	   }
	   
      
		if(MyPositionInfo.magic != MagicMRT
      && MyPositionInfo.magic != Magic
      && MyPositionInfo.magic != MagicMRT_AfterFilter)continue;
	   HistorySelect(MathMax(MyInfo.startTime,MyInfo.lastHistoryRun),TimeCurrent());
		if(!MyPositionInfo.isHistory)
			continue;	
		update = true;   
      MyPositionInfo.SetValues();
      
      
      // // /// /// //// /// //// /// // / / / // / /
      
      CalculateProfit();
      if(MyPositionInfo.isCapsule)
      {
			CheckForFeaturesCapsule();
			HistorySelect(MathMax(MyInfo.startTime,MyInfo.lastHistoryRun),TimeCurrent());
			continue;
      }  
      
      	
   	if(UseHedge
   	&& MyPositionInfo.isHedge
   	&& MyPositionInfo.ot > (MyPositionInfo.type?MyInfo.startTimeSell:MyInfo.startTimeBuy))
   		ReOpenHedge();
   		
	   if(MyPositionInfo.isMRT
	   && MyPositionInfo.isLock
	   && MyPositionInfo.ot>(MyPositionInfo.type?MyInfo.startTimeSell:MyInfo.startTimeBuy))
	   	ReOpenMRTLock();
	   if(MyPositionInfo.isMRT_AfterFilter
	   && MyPositionInfo.isLock
	   && MyPositionInfo.ot>(MyPositionInfo.type?MyInfo.startTimeSell:MyInfo.startTimeBuy))
	   	ReOpenMRTLock_MRTAfterFilter();
	   HistorySelect(MathMax(MyInfo.startTime,MyInfo.lastHistoryRun),TimeCurrent());
   }
   if(update)
   {
   	MyInfo.lastHistoryRun = TimeCurrent();
      MyInfo.historyLastCheckedTkt=MathMax(maxTkt,MyInfo.historyLastCheckedTkt);
   }
   CheckForFeaturesCapsule(2);
   
   CalculateProfit(false);
   CheckForFeaturesCapsule(3);
	ReOpenMRTLock(false);
	ReOpenMRTLock_MRTAfterFilter(false);
   
   GetMRTInfo(false);
	ReOpenMRTTrades();
   if(UseHedge)
   	ReOpenHedge(false);
   	
   
	
	if(CloseMainHedgeCapsuleFromBalance)
		CheckForHedgeCapsuleClose();
}

void SecondRun()
{
	closeAmountBuy = 0;
	closeAmountSell = 0;
	leftAmountBuy = MyInfo.buyHedge.profit;
	leftAmountSell = MyInfo.sellHedge.profit;
	
	MyInfo.buyHedge.lotSum=0;
	MyInfo.sellHedge.lotSum=0;
	
	listBuyFromAbove.Clear();
	listSellFromAbove.Clear();
	listBuy.Clear();
	listSell.Clear();
	listPriceBuy.Clear();
	listPriceSell.Clear();
	
   mrtAfterFilterOTListBuy.Clear();
   mrtAfterFilterOTListSell.Clear();
	for(int i=PositionsTotal()-1;i>=0;i--)
	{
		if(!PositionSelectByTicket(PositionGetTicket(i)))continue;
		if(PositionGetString(POSITION_SYMBOL)!=Symbol()) continue;
		
		MyPositionInfo.magic = PositionGetInteger(POSITION_MAGIC);
      MyPositionInfo.orderType = PositionGetInteger(POSITION_TYPE);
      MyPositionInfo.comment = PositionGetString(POSITION_COMMENT);
      MyPositionInfo.ot = PositionGetInteger(POSITION_TIME);
      MyPositionInfo.orderProfit=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
      MyPositionInfo.tkt = PositionGetInteger(POSITION_TICKET);
		MyPositionInfo.lotSize = PositionGetDouble(POSITION_VOLUME);
		MyPositionInfo.op = PositionGetDouble(POSITION_PRICE_OPEN);
		MyPositionInfo.sl = PositionGetDouble(POSITION_SL);
      MyPositionInfo.isHistory = false;
      
		if(MyPositionInfo.magic != MagicMRT
		&& MyPositionInfo.magic != Magic
		&& MyPositionInfo.magic != MagicMRT_AfterFilter)continue;
		
		MyPositionInfo.SetValues();
		
		
		FillInfoForSelfDecrease();
		
		

		if(UsesCloseLosingTradesByPriceFromBalance
		&&!MyPositionInfo.isLock
		&&(MyPositionInfo.isMRT || MyPositionInfo.isMRT_AfterFilter || !CloseOnlyMRT)
		&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
		{
			CloseLosingTradesByPriceFromBalance();
		}
		if(CloseNthTradeFromAbove
		&& MyPositionInfo.isMRT
		&&!MyPositionInfo.isLock
		&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
		{
			CheckForCloseNthTradeFromAbove();
		}
		if(CloseNthTrade
		&& MyPositionInfo.isMRT
		&&!MyPositionInfo.isLock
		&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
		{
			CheckForCloseNthTrade();
		}
		if(CloseNthTradeFromAbove_MRTAfterFilter
		&& MyPositionInfo.isMRT_AfterFilter
		&&!MyPositionInfo.isLock
		&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
		{
			CheckForCloseNthTradeFromAbove_MRTAfterFilter();
		}
		if(CloseNthTrade_MRTAfterFilter
		&& MyPositionInfo.isMRT_AfterFilter
		&&!MyPositionInfo.isLock
		&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
		{
			CheckForCloseNthTrade_MRTAfterFilter();
		}
		if(MyPositionInfo.isMRT_AfterFilter)
	   {
	      CheckForOpenFilterMRT();
	   }
		if(UseHedge)
		{
			if(MyPositionInfo.isHedge)
			{
				if(CheckForFeaturesHedge())
					continue;
			}
			if(UseWithMainHedgeCloseNthTrade
			&&(MyPositionInfo.isMRT || MyPositionInfo.isMRT_AfterFilter)
			&&(MyInfo.buyHedge.op-m_MinDistToClose>SymbolInfoDouble(Symbol(),SYMBOL_BID)
			|| MyInfo.sellHedge.op+m_MinDistToClose<SymbolInfoDouble(Symbol(),SYMBOL_ASK)))
				CheckNthTradeWithHedge();
	   }
	}  
	if(MyInfo.endAddTradesBuy)
	{
	
   	if(UsesCloseLosingTradesByPriceFromBalance
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CloseLosingTradesByPriceFromBalanceBuy();
   	}
   	if(CloseNthTradeFromAbove_MRTAfterFilter
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CheckForCloseNthTradeFromAbove_MRTAfterFilterBuy();
   	}
   	if(CloseNthTrade_MRTAfterFilter
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CheckForCloseNthTrade_MRTAfterFilterBuy();
   	}
   	if(CloseNthTradeFromAbove
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CheckForCloseNthTradeFromAboveBuy();
   	}
   	if(CloseNthTrade
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CheckForCloseNthTradeBuy();
   	}
   	
   	
   	
   	if(UsesCloseLosingTradesByPriceFromBalance
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CloseLosingTradesByPriceFromBalanceSell();
   	}
   	if(CloseNthTradeFromAbove_MRTAfterFilter
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CheckForCloseNthTradeFromAbove_MRTAfterFilterSell();
   	}
   	if(CloseNthTrade_MRTAfterFilter
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CheckForCloseNthTrade_MRTAfterFilterSell();
   	}
   	if(CloseNthTradeFromAbove
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CheckForCloseNthTradeFromAboveSell();
   	}
   	if(CloseNthTrade
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CheckForCloseNthTradeSell();
   	}
	}
	else
	{
	   
   	if(UsesCloseLosingTradesByPriceFromBalance
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CloseLosingTradesByPriceFromBalanceSell();
   	}
   	if(CloseNthTradeFromAbove_MRTAfterFilter
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CheckForCloseNthTradeFromAbove_MRTAfterFilterSell();
   	}
   	if(CloseNthTrade_MRTAfterFilter
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CheckForCloseNthTrade_MRTAfterFilterSell();
   	}
   	if(CloseNthTradeFromAbove
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CheckForCloseNthTradeFromAboveSell();
   	}
   	if(CloseNthTrade
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CheckForCloseNthTradeSell();
   	}
   	
   	
   	if(UsesCloseLosingTradesByPriceFromBalance
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CloseLosingTradesByPriceFromBalanceBuy();
   	}
   	if(CloseNthTradeFromAbove_MRTAfterFilter
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CheckForCloseNthTradeFromAbove_MRTAfterFilterBuy();
   	}
   	if(CloseNthTrade_MRTAfterFilter
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CheckForCloseNthTrade_MRTAfterFilterBuy();
   	}
   	if(CloseNthTradeFromAbove
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CheckForCloseNthTradeFromAboveBuy();
   	}
   	if(CloseNthTrade
   	&&(!SaveProfitForCapsule || MyInfo.mainCapsuleAmount == 0))
   	{
   		CheckForCloseNthTradeBuy();
   	}
	}
	
	if(UseHedge)
	{
		if(UseWithMainHedgeCloseNthTrade)
		{
			CloseNthTradeWithHedge();
		} 
	   if(LockHedgeAfterPullBack)
	   {
	   	if(MyInfo.buyHedge.lotSum>SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN)
	   	&& !MyInfo.buyHedge.locked)
	   	{
	   		if(UseGlobalCapsuleInsteadLock)
	   		{
			      MakeLockCapsule(0,MyInfo.buyHedge.tkt);
				}
				else
	   		{
			      MyPositionOpen(Symbol(),ORDER_TYPE_BUY,MyInfo.buyHedge.lotSum,SymbolInfoDouble(Symbol(),SYMBOL_ASK),0,0,"0-0^"+MyInfo.buyHedge.index,Magic);
					PrintLogs(__LINE__+" Lock Hedge type = BUY");
				}
	   	}
		   if(MyInfo.sellHedge.lotSum>SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN)
	   	&& !MyInfo.sellHedge.locked)
	   	{
	   		if(UseGlobalCapsuleInsteadLock)
	   		{
			      MakeLockCapsule(1,MyInfo.sellHedge.tkt);
				}
				else
	   		{
			      MyPositionOpen(Symbol(),ORDER_TYPE_SELL,MyInfo.sellHedge.lotSum,SymbolInfoDouble(Symbol(),SYMBOL_BID),0,0,"0-0^"+MyInfo.sellHedge.index,Magic);
					PrintLogs(__LINE__+" Lock Hedge type = SELL");
				}
	   	}
	   }
   }
	CheckForOpenFilterMRT(false);
}

void ThirdRun()
{
	
}
void CalculateProfit(bool count=true)
{
	
	if(count)
	{
		if(!MyPositionInfo.isHistory)
		{
			if(MyPositionInfo.type == 0)
	      {
	      	MyInfo.wholeOpenProfitBuy+=MyPositionInfo.orderProfit;
		   	MyInfo.commissionBuy+=MyPositionInfo.commission;
	      }
	      else
	      {
	      	MyInfo.wholeOpenProfitSell+=MyPositionInfo.orderProfit;
		   	MyInfo.commissionSell+=MyPositionInfo.commission;
	      }
		}
		else
		{
			if(MyPositionInfo.type == 0)
		   {
		   	MyInfo.wholeClosedProfitBuy+=MyPositionInfo.orderProfit;
		   	if(MyPositionInfo.ot>=MyInfo.startTimeBuy)
		   	{
		   		MyInfo.cycleClosedProfitBuy+=MyPositionInfo.orderProfit;
		   	}
		   }
		   else
		   {
		   	MyInfo.wholeClosedProfitSell+=MyPositionInfo.orderProfit;
		   	if(MyPositionInfo.ot>=MyInfo.startTimeSell)
		   	{
		   		MyInfo.cycleClosedProfitSell+=MyPositionInfo.orderProfit;
		   	}
		   }
		}
		return;
	}
	
	MyInfo.cycleClosedProfitSell+=MyInfo.commissionBuy;
	MyInfo.cycleClosedProfitBuy+=MyInfo.commissionSell;
	for(int i=0;i<MyInfo.mainCapsuleAmount;i++)
	{
		if(!MyInfo.mainCapsuleInfo[i].lock && MyInfo.mainCapsuleInfo[i].main
		|| MyInfo.mainCapsuleInfo[i].lock && !MyInfo.mainCapsuleInfo[i].main)
		{
			if(MyInfo.mainCapsuleInfo[i].type == 0)
			{
				MyInfo.buyMRT.profit+=(MyInfo.mainCapsuleInfo[i].lock?MyInfo.mainCapsuleInfo[i].lockProfit:MyInfo.mainCapsuleInfo[i].mainProfit);
			}
			else
			{
				MyInfo.sellMRT.profit+=(MyInfo.mainCapsuleInfo[i].lock?MyInfo.mainCapsuleInfo[i].lockProfit:MyInfo.mainCapsuleInfo[i].mainProfit);
			}
		}
	}
	
	MyInfo.equityBuy = InitialBalance+MyInfo.wholeClosedProfitBuy+MyInfo.wholeOpenProfitBuy;
   MyInfo.equitySell = InitialBalance+MyInfo.wholeClosedProfitSell+MyInfo.wholeOpenProfitSell;
   
   MyInfo.wholeOpenProfit= MyInfo.wholeOpenProfitBuy+MyInfo.wholeOpenProfitSell;
   MyInfo.wholeClosedProfit = MyInfo.wholeClosedProfitBuy+MyInfo.wholeClosedProfitSell;
   MyInfo.cycleClosedProfit = MyInfo.cycleClosedProfitBuy+MyInfo.cycleClosedProfitSell;
   MyInfo.balance = InitialBalance+MyInfo.wholeClosedProfit;
   MyInfo.equity = MyInfo.balance+MyInfo.wholeOpenProfit; 
   
   
	
	MyInfo.maxProfit = MathMax(0,MathMax(MyInfo.maxProfit,MyInfo.cycleClosedProfit));
	MyInfo.maxProfitBuy = MathMax(0,MathMax(MyInfo.maxProfitBuy,MyInfo.cycleClosedProfitBuy));
	MyInfo.maxProfitSell = MathMax(0,MathMax(MyInfo.maxProfitSell,MyInfo.cycleClosedProfitSell));
	
	MyInfo.maxEquity = MathMax(MyInfo.maxEquity,MyInfo.equity);
	MyInfo.maxEquityBuy = MathMax(MyInfo.maxEquityBuy,MyInfo.equityBuy);
	MyInfo.maxEquitySell = MathMax(MyInfo.maxEquitySell,MyInfo.equitySell);
	if(StartUsingProfitAfterPct>0)
	{
	   MyInfo.maxEquity = MathMax(MyInfo.previousEquity*(1+StartUsingProfitAfterPct/100),MyInfo.equity);
   	MyInfo.maxEquityBuy = MathMax(MyInfo.previousEquityBuy*(1+StartUsingProfitAfterPct/100),MyInfo.equityBuy);
   	MyInfo.maxEquitySell = MathMax(MyInfo.previousEquitySell*(1+StartUsingProfitAfterPct/100),MyInfo.equitySell);
	}
   double saveAmount = SaveAmount;
   if(SaveAmountType == 0)
      saveAmount = MyInfo.maxProfitBuy*SaveAmount/100;
   MyInfo.savedProfitBuy = (InitialBalance+MyInfo.wholeClosedProfitBuy-MyInfo.maxEquityBuy)-saveAmount;
   saveAmount = SaveAmount;
   if(SaveAmountType == 0)
      saveAmount = MyInfo.maxProfitSell*SaveAmount/100;
   MyInfo.savedProfitSell = (InitialBalance+MyInfo.wholeClosedProfitSell-MyInfo.maxEquitySell)-saveAmount;
   
   saveAmount = SaveAmount;
   if(SaveAmountType == 0)
      saveAmount = MyInfo.maxProfit*SaveAmount/100;
   MyInfo.savedProfit = (InitialBalance+MyInfo.wholeClosedProfit-MyInfo.maxEquity)-saveAmount;
}
void FillInfoForCapsule()
{
   if(UseDecreaseLotAmountInMRTCapsule && MyPositionInfo.isMRT && !MyPositionInfo.isCapsule)
   {
      MyInfo.mrtCapsuleInfo[MyInfo.mrtCapsuleAmount].index = MyPositionInfo.index;
      MyInfo.mrtCapsuleInfo[MyInfo.mrtCapsuleAmount].type = MyPositionInfo.orderType;
      MyInfo.mrtCapsuleInfo[MyInfo.mrtCapsuleAmount].magic = MyPositionInfo.magic;
      MyInfo.mrtCapsuleInfo[MyInfo.mrtCapsuleAmount].tradeAmount = 1;
      MyInfo.mrtCapsuleAmount++;
   }
   if(UseDecreaseLotAmountInMRTCapsule_MRTAfterFilter && MyPositionInfo.isMRT_AfterFilter && !MyPositionInfo.isCapsule)
   {
      MyInfo.mrtAfterFilterCapsuleInfo[MyInfo.mrtAfterFilterCapsuleAmount].index = MyPositionInfo.index;
      MyInfo.mrtAfterFilterCapsuleInfo[MyInfo.mrtAfterFilterCapsuleAmount].type = MyPositionInfo.orderType;
      MyInfo.mrtAfterFilterCapsuleInfo[MyInfo.mrtAfterFilterCapsuleAmount].magic = MyPositionInfo.magic;
      MyInfo.mrtAfterFilterCapsuleInfo[MyInfo.mrtAfterFilterCapsuleAmount].tradeAmount = 1;
      MyInfo.mrtAfterFilterCapsuleAmount++;
   }
   if(UseDecreaseLotAmountInCapsule_MainHedge && MyPositionInfo.isHedge && !MyPositionInfo.isCapsule)
   {
      MyInfo.hedgeCapsuleInfo[MyInfo.hedgeCapsuleAmount].index = MyPositionInfo.index;
      MyInfo.hedgeCapsuleInfo[MyInfo.hedgeCapsuleAmount].type = MyPositionInfo.orderType;
      MyInfo.hedgeCapsuleInfo[MyInfo.hedgeCapsuleAmount].magic = MyPositionInfo.magic;
      MyInfo.hedgeCapsuleInfo[MyInfo.hedgeCapsuleAmount].tradeAmount = 1;
      MyInfo.hedgeCapsuleAmount++;
   }
   
   if(UseDecreaseLotAmountInCapsule && MyPositionInfo.isCapsule)
   {
   	MyInfo.capsuleInfo[MyInfo.capsuleAmount].index = MyPositionInfo.index;
      MyInfo.capsuleInfo[MyInfo.capsuleAmount].type = MyPositionInfo.orderType;
      MyInfo.capsuleInfo[MyInfo.capsuleAmount].magic = MyPositionInfo.magic;
      MyInfo.capsuleInfo[MyInfo.capsuleAmount].tradeAmount = 1;
      MyInfo.capsuleAmount++;
   }
}
void FillInfoForSelfDecrease()
{
	
	if(!UseDecreaseLotAmountInCapsule_MainHedge
   && !UseDecreaseLotAmountInMRTCapsule_MRTAfterFilter
   && !UseDecreaseLotAmountInMRTCapsule
   && !UseDecreaseLotAmountInCapsule)
   	return;
   	
	if(UseDecreaseLotAmountInMRTCapsule && MyPositionInfo.isMRT && !MyPositionInfo.isCapsule)
   {
      for(int i=0;i<MyInfo.mrtCapsuleAmount;i++)
      {
      	if(MyInfo.mrtCapsuleInfo[i].index != MyPositionInfo.index)continue;
      	
      	if(MyPositionInfo.isLock 
      	&& MyInfo.mrtCapsuleInfo[i].type == MyPositionInfo.orderType)
      	{
      		MyInfo.mrtCapsuleInfo[i].profit[0] = MyPositionInfo.orderProfit;
      		MyInfo.mrtCapsuleInfo[i].lotSize[0] = MyPositionInfo.lotSize;
      		MyInfo.mrtCapsuleInfo[i].dist[0] = MathAbs(MyPositionInfo.op-SymbolInfoDouble(Symbol(),MyPositionInfo.orderType?SYMBOL_ASK:SYMBOL_BID))/Point();
      		MyInfo.mrtCapsuleInfo[i].tkt[0] = MyPositionInfo.tkt;
      		MyInfo.mrtCapsuleInfo[i].comment[0] = MyPositionInfo.comment;
      	}
      	if(!MyPositionInfo.isLock 
      	&& MyInfo.mrtCapsuleInfo[i].type != MyPositionInfo.orderType
      	&& MyPositionInfo.n!=1)
      	{
      		MyInfo.mrtCapsuleInfo[i].profit[MyInfo.mrtCapsuleInfo[i].tradeAmount] = MyPositionInfo.orderProfit;
      		MyInfo.mrtCapsuleInfo[i].lotSize[MyInfo.mrtCapsuleInfo[i].tradeAmount] = MyPositionInfo.lotSize;
      		MyInfo.mrtCapsuleInfo[i].dist[MyInfo.mrtCapsuleInfo[i].tradeAmount] = MathAbs(MyPositionInfo.op-SymbolInfoDouble(Symbol(),MyPositionInfo.orderType?SYMBOL_ASK:SYMBOL_BID))/Point();
      		MyInfo.mrtCapsuleInfo[i].tkt[MyInfo.mrtCapsuleInfo[i].tradeAmount] = MyPositionInfo.tkt;
      		MyInfo.mrtCapsuleInfo[i].comment[MyInfo.mrtCapsuleInfo[i].tradeAmount] = MyPositionInfo.comment;
      		MyInfo.mrtCapsuleInfo[i].tradeAmount++;
      	}
      }
   }
   if(UseDecreaseLotAmountInMRTCapsule_MRTAfterFilter && MyPositionInfo.isMRT_AfterFilter && !MyPositionInfo.isCapsule)
   {
      for(int i=0;i<MyInfo.mrtAfterFilterCapsuleAmount;i++)
      {
      	if(MyInfo.mrtAfterFilterCapsuleInfo[i].index != MyPositionInfo.index)continue;
      	
      	if(MyPositionInfo.isLock 
      	&& MyInfo.mrtAfterFilterCapsuleInfo[i].type == MyPositionInfo.orderType)
      	{
      		MyInfo.mrtAfterFilterCapsuleInfo[i].profit[0] = MyPositionInfo.orderProfit;
      		MyInfo.mrtAfterFilterCapsuleInfo[i].lotSize[0] = MyPositionInfo.lotSize;
      		MyInfo.mrtAfterFilterCapsuleInfo[i].dist[0] = MathAbs(MyPositionInfo.op-SymbolInfoDouble(Symbol(),MyPositionInfo.orderType?SYMBOL_ASK:SYMBOL_BID))/Point();
      		MyInfo.mrtAfterFilterCapsuleInfo[i].tkt[0] = MyPositionInfo.tkt;
      		MyInfo.mrtAfterFilterCapsuleInfo[i].comment[0] = MyPositionInfo.comment;
      	}
      	if(!MyPositionInfo.isLock 
      	&& MyInfo.mrtAfterFilterCapsuleInfo[i].type != MyPositionInfo.orderType
      	&& MyPositionInfo.n!=1)
      	{
      		MyInfo.mrtAfterFilterCapsuleInfo[i].profit[MyInfo.mrtAfterFilterCapsuleInfo[i].tradeAmount] = MyPositionInfo.orderProfit;
      		MyInfo.mrtAfterFilterCapsuleInfo[i].lotSize[MyInfo.mrtAfterFilterCapsuleInfo[i].tradeAmount] = MyPositionInfo.lotSize;
      		MyInfo.mrtAfterFilterCapsuleInfo[i].dist[MyInfo.mrtAfterFilterCapsuleInfo[i].tradeAmount] = MathAbs(MyPositionInfo.op-SymbolInfoDouble(Symbol(),MyPositionInfo.orderType?SYMBOL_ASK:SYMBOL_BID))/Point();
      		MyInfo.mrtAfterFilterCapsuleInfo[i].tkt[MyInfo.mrtAfterFilterCapsuleInfo[i].tradeAmount] = MyPositionInfo.tkt;
      		MyInfo.mrtAfterFilterCapsuleInfo[i].comment[MyInfo.mrtAfterFilterCapsuleInfo[i].tradeAmount] = MyPositionInfo.comment;
      		MyInfo.mrtAfterFilterCapsuleInfo[i].tradeAmount++;
      	}
      }
   }
   if(UseDecreaseLotAmountInCapsule_MainHedge && MyPositionInfo.isHedge && !MyPositionInfo.isCapsule)
   {
      for(int i=0;i<MyInfo.hedgeCapsuleAmount;i++)
      {
      	if(MyInfo.hedgeCapsuleInfo[i].index != MyPositionInfo.index)continue;
      	if(MyPositionInfo.isLock 
      	&& MyInfo.hedgeCapsuleInfo[i].type == MyPositionInfo.orderType)
      	{
      		MyInfo.hedgeCapsuleInfo[i].profit[0] = MyPositionInfo.orderProfit;
      		MyInfo.hedgeCapsuleInfo[i].lotSize[0] = MyPositionInfo.lotSize;
      		MyInfo.hedgeCapsuleInfo[i].dist[0] = MathAbs(MyPositionInfo.op-SymbolInfoDouble(Symbol(),MyPositionInfo.orderType?SYMBOL_ASK:SYMBOL_BID))/Point();
      		MyInfo.hedgeCapsuleInfo[i].tkt[0] = MyPositionInfo.tkt;
      		MyInfo.hedgeCapsuleInfo[i].comment[0] = MyPositionInfo.comment;
      	}
      	if(!MyPositionInfo.isLock 
      	&& MyInfo.hedgeCapsuleInfo[i].type != MyPositionInfo.orderType)
      	{
      		MyInfo.hedgeCapsuleInfo[i].profit[MyInfo.hedgeCapsuleInfo[i].tradeAmount] = MyPositionInfo.orderProfit;
      		MyInfo.hedgeCapsuleInfo[i].lotSize[MyInfo.hedgeCapsuleInfo[i].tradeAmount] = MyPositionInfo.lotSize;
      		MyInfo.hedgeCapsuleInfo[i].dist[MyInfo.hedgeCapsuleInfo[i].tradeAmount] = MathAbs(MyPositionInfo.op-SymbolInfoDouble(Symbol(),MyPositionInfo.orderType?SYMBOL_ASK:SYMBOL_BID))/Point();
      		MyInfo.hedgeCapsuleInfo[i].tkt[MyInfo.hedgeCapsuleInfo[i].tradeAmount] = MyPositionInfo.tkt;
      		MyInfo.hedgeCapsuleInfo[i].comment[MyInfo.hedgeCapsuleInfo[i].tradeAmount] = MyPositionInfo.comment;
      		MyInfo.hedgeCapsuleInfo[i].tradeAmount++;
      	}
      }
   }
   if(UseDecreaseLotAmountInCapsule && MyPositionInfo.isCapsule)
   {
      for(int i=0;i<MyInfo.capsuleAmount;i++)
      {
      	if(MyInfo.capsuleInfo[i].index != MyPositionInfo.index)continue;
      	
      	if(MyPositionInfo.isLock 
      	&& MyInfo.capsuleInfo[i].type == MyPositionInfo.orderType)
      	{
      		MyInfo.capsuleInfo[i].profit[0] = MyPositionInfo.orderProfit;
      		MyInfo.capsuleInfo[i].lotSize[0] = MyPositionInfo.lotSize;
      		MyInfo.capsuleInfo[i].dist[0] = MathAbs(MyPositionInfo.op-SymbolInfoDouble(Symbol(),MyPositionInfo.orderType?SYMBOL_ASK:SYMBOL_BID))/Point();
      		MyInfo.capsuleInfo[i].tkt[0] = MyPositionInfo.tkt;
      		MyInfo.capsuleInfo[i].comment[0] = MyPositionInfo.comment;
      	}
      	if(!MyPositionInfo.isLock 
      	&& MyInfo.capsuleInfo[i].type != MyPositionInfo.orderType)
      	{
      		MyInfo.capsuleInfo[i].profit[MyInfo.capsuleInfo[i].tradeAmount] = MyPositionInfo.orderProfit;
      		MyInfo.capsuleInfo[i].lotSize[MyInfo.capsuleInfo[i].tradeAmount] = MyPositionInfo.lotSize;
      		MyInfo.capsuleInfo[i].dist[MyInfo.capsuleInfo[i].tradeAmount] = MathAbs(MyPositionInfo.op-SymbolInfoDouble(Symbol(),MyPositionInfo.orderType?SYMBOL_ASK:SYMBOL_BID))/Point();
      		MyInfo.capsuleInfo[i].tkt[MyInfo.capsuleInfo[i].tradeAmount] = MyPositionInfo.tkt;
      		MyInfo.capsuleInfo[i].comment[MyInfo.capsuleInfo[i].tradeAmount] = MyPositionInfo.comment;
      		MyInfo.capsuleInfo[i].tradeAmount++;
      	}
      }
   }
}

void RunForSelfDecrease()
{
	if(!UseDecreaseLotAmountInCapsule_MainHedge
   && !UseDecreaseLotAmountInMRTCapsule_MRTAfterFilter
   && !UseDecreaseLotAmountInMRTCapsule
   && !UseDecreaseLotAmountInCapsule)
   	return;
   	
	if(UseDecreaseLotAmountInMRTCapsule)
   {
      for(int i=0;i<MyInfo.mrtCapsuleAmount;i++)
      {
      	RunForDecrease(MyInfo.mrtCapsuleInfo[i].tradeAmount,
      						MyInfo.mrtCapsuleInfo[i].profit,
      						MyInfo.mrtCapsuleInfo[i].lotSize,
      						MyInfo.mrtCapsuleInfo[i].dist,
      						MyInfo.mrtCapsuleInfo[i].tkt,
      						MyInfo.mrtCapsuleInfo[i].comment,
      						MyInfo.mrtCapsuleInfo[i].type,
      						MyInfo.mrtCapsuleInfo[i].magic,
      						" MRT Capsule ",
      						m_MinDecreaseLotAmountMRT);
      						
      }
   }
   if(UseDecreaseLotAmountInMRTCapsule_MRTAfterFilter)
   {
   	
      for(int i=0;i<MyInfo.mrtAfterFilterCapsuleAmount;i++)
      {
      	RunForDecrease(MyInfo.mrtAfterFilterCapsuleInfo[i].tradeAmount,
      						MyInfo.mrtAfterFilterCapsuleInfo[i].profit,
      						MyInfo.mrtAfterFilterCapsuleInfo[i].lotSize,
      						MyInfo.mrtAfterFilterCapsuleInfo[i].dist,
      						MyInfo.mrtAfterFilterCapsuleInfo[i].tkt,
      						MyInfo.mrtAfterFilterCapsuleInfo[i].comment,
      						MyInfo.mrtAfterFilterCapsuleInfo[i].type,
      						MyInfo.mrtAfterFilterCapsuleInfo[i].magic,
      						" MRT AFTER FILTER  ",
      						m_MinDecreaseLotAmountMRT_MRTAfterFilter);
      						
      }
   }
   if(UseDecreaseLotAmountInCapsule_MainHedge)
   {
      for(int i=0;i<MyInfo.hedgeCapsuleAmount;i++)
      {
      	RunForDecrease(MyInfo.hedgeCapsuleInfo[i].tradeAmount,
      						MyInfo.hedgeCapsuleInfo[i].profit,
      						MyInfo.hedgeCapsuleInfo[i].lotSize,
      						MyInfo.hedgeCapsuleInfo[i].dist,
      						MyInfo.hedgeCapsuleInfo[i].tkt,
      						MyInfo.hedgeCapsuleInfo[i].comment,
      						MyInfo.hedgeCapsuleInfo[i].type,
      						MyInfo.hedgeCapsuleInfo[i].magic,
      						" MAIN HEDGE  ",
      						m_DeacreaseHedgeCapsuleAfter);
      				
      }
   }
   if(UseDecreaseLotAmountInCapsule)
   {
   	
      for(int i=0;i<MyInfo.capsuleAmount;i++)
      {
      	RunForDecreaseCapsule(MyInfo.capsuleInfo[i].tradeAmount,
      						MyInfo.capsuleInfo[i].profit,
      						MyInfo.capsuleInfo[i].lotSize,
      						MyInfo.capsuleInfo[i].dist,
      						MyInfo.capsuleInfo[i].tkt,
      						MyInfo.capsuleInfo[i].comment,
      						MyInfo.capsuleInfo[i].type,
      						MyInfo.capsuleInfo[i].magic,
      						" CAPSULE   ",
      						m_MinDecreaseLotAmountInCapsule);
      						
      }
   }
}


void RunForDecrease(int amount,double &profit[],double &lotSize[],int &dist[],int &tkt[],string &comment[],int type,int magic,string addComment,double minProfitToClose)
{
	double minDecreaseLotAmount = SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   double minProfit = SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE)*minDecreaseLotAmount;
   
   if(profit[0]>0
   && dist[0]*Point()>minProfitToClose)
   {
      bool close = false;
      for(int i=1;i<amount;i++)
      {
         if(profit[0]+profit[i]>0)
         {
         	if(lotSize[i]>minDecreaseLotAmount)
         	{
	            profit[0]+=profit[i];
	            lotSize[0]-=lotSize[i];
	            MyPositionClose(tkt[i]);
	            close=true;
	            PrintLogs(__LINE__+" Close fully tkt = "+tkt[i]+" by tkt = "+tkt[0]+addComment+" "+comment[0]+" "+magic);  
            }
         }
         else
         {
            if(profit[0]+minProfit*dist[i]*(-1)>0)
            {
               int minAmount = profit[0]/(minProfit*dist[i]);
               profit[0]-=minAmount*minDecreaseLotAmount*dist[i];
               lotSize[0]-=minAmount*minDecreaseLotAmount;
               MyPartialClose(tkt[i],minAmount*minDecreaseLotAmount);
               close=true;
               PrintLogs(__LINE__+" Close Partially tkt = "+tkt[i]+" by tkt = "+tkt[0]+" "+addComment+" lot = "+(minAmount*minDecreaseLotAmount)+" "+comment[0]+" "+magic); 
            }
         }
      }
      if(close)
      {
         MyPositionClose(tkt[0]);
         if(magic == MagicMRT)
         {
	         if(type == 1)
	         {
	         	MyInfo.buyMRT.lockCloseReason = 1;
					PrintLogs(__LINE__+" Lock Close Lock reason 1");
					
			         
	         	if(DontReOpenAfterSelfDecrease)
	         	{
	         		bool hit = false;
	         		if(DontReOpenAfterSelfDecrease == 1)
	         		{
	         			hit = MyInfo.buyMRT.lockStartLotAmount*DontReOpenTriggerPct/100>=lotSize[0];
	         		}
	         		if(DontReOpenAfterSelfDecrease == 2)
	         		{
	         			double minLot = (LotSizeCalculationBalance*DontReOpenTriggerMinLot/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
					      if(DontReOpenTriggerMinLotType)  
					         minLot = DontReOpenTriggerMinLot;
					      hit = minLot>=lotSize[0];
	         		}
	         		if(hit)
	         		{
		         		MyInfo.buyMRT.lockCloseReason = 2;
		         		if(OpenOppositeInsteadLock)
		         		{
		         			int index;
		         			double current;
		         			double previous;
		         			GetIndex(0,current,previous,index,MyInfo.buyMRT.firstOP);
		         			MyPositionOpen(Symbol(),ORDER_TYPE_BUY,lotSize[0],SymbolInfoDouble(Symbol(),SYMBOL_ASK),0,0,"1="+index+"^1",MagicMRT);
		         		}
		         		PrintLogs(__LINE__+" Dont Reopen Lock and open BUY");
	         		}
	         	}
	        	}
	        	else
	        	{
	         	MyInfo.sellMRT.lockCloseReason = 1;
					PrintLogs(__LINE__+" Lock Close Lock reason 1");
	         	if(DontReOpenAfterSelfDecrease)
	         	{
	         		bool hit = false;
	         		if(DontReOpenAfterSelfDecrease == 1)
	         		{
	         			hit = MyInfo.sellMRT.lockStartLotAmount*DontReOpenTriggerPct/100>=lotSize[0];
	         		}
	         		if(DontReOpenAfterSelfDecrease == 2)
	         		{
	         			double minLot = (LotSizeCalculationBalance*DontReOpenTriggerMinLot/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
					      if(DontReOpenTriggerMinLotType)  
					         minLot = DontReOpenTriggerMinLot;
					      hit = minLot>=lotSize[0];
	         		}
	         		if(hit)
	         		{
		         		MyInfo.sellMRT.lockCloseReason = 2;
		         		if(OpenOppositeInsteadLock)
		         		{
		         			int index;
		         			double current;
		         			double previous;
		         			GetIndex(0,current,previous,index,MyInfo.buyMRT.firstOP);
		         			MyPositionOpen(Symbol(),ORDER_TYPE_SELL,lotSize[0],SymbolInfoDouble(Symbol(),SYMBOL_BID),0,0,"1="+index+"^1",MagicMRT);
		         		}
		         		PrintLogs(__LINE__+" Dont Reopen Lock and open SELL");
	         		}
	         	}
	         }
         }
         else 
         if(magic == MagicMRT_AfterFilter)
         {
         	int index = GetMRTAfterFilterIndex(comment[0]);
         	double startLot = GlobalVariableGet(prefix+index+"lockStartLotAmount"+(type==0?"sell":"buy"));
	         if(type == 1)
	         {
					GlobalVariableSet(prefix+index+"lockCloseReason"+"buy",1);
					PrintLogs(__LINE__+" Lock Close Lock reason 1");
	         	if(DontReOpenAfterSelfDecrease)
	         	{
	         		bool hit = false;
	         		if(DontReOpenAfterSelfDecrease == 1)
	         		{
	         			hit = startLot*DontReOpenTriggerPct/100>=lotSize[0];
	         		}
	         		if(DontReOpenAfterSelfDecrease == 2)
	         		{
	         			double minLot = (LotSizeCalculationBalance*DontReOpenTriggerMinLot/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
					      if(DontReOpenTriggerMinLotType)  
					         minLot = DontReOpenTriggerMinLot;
					      hit = minLot>=lotSize[0];
	         		}
	         		if(hit)
	         		{
							GlobalVariableSet(prefix+index+"lockCloseReason"+"buy",2);
		         		if(OpenOppositeInsteadLock)
		         		{
		         			MyPositionOpen(Symbol(),ORDER_TYPE_BUY,lotSize[0],SymbolInfoDouble(Symbol(),SYMBOL_ASK),0,0,"1@11^"+index,MagicMRT_AfterFilter);
		         		}
							PrintLogs(__LINE__+" Dont Reopen Lock and open BUY");
						}
	         	}
	        	}
	        	else
	        	{
					GlobalVariableSet(prefix+index+"lockCloseReason"+"sell",1);
					PrintLogs(__LINE__+" Lock Close Lock reason 1");
	         	if(DontReOpenAfterSelfDecrease)
	         	{
	         		bool hit = false;
	         		if(DontReOpenAfterSelfDecrease == 1)
	         		{
	         			hit = startLot*DontReOpenTriggerPct/100>=lotSize[0];
	         		}
	         		if(DontReOpenAfterSelfDecrease == 2)
	         		{
	         			double minLot = (LotSizeCalculationBalance*DontReOpenTriggerMinLot/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
					      if(DontReOpenTriggerMinLotType)  
					         minLot = DontReOpenTriggerMinLot;
					      hit = minLot>=lotSize[0];
	         		}
	         		if(hit)
	         		{
	         		
							GlobalVariableSet(prefix+index+"lockCloseReason"+"sell",2);
		         		if(OpenOppositeInsteadLock)
		         		{
		         			MyPositionOpen(Symbol(),ORDER_TYPE_SELL,lotSize[0],SymbolInfoDouble(Symbol(),SYMBOL_BID),0,0,"1@11^"+index,MagicMRT_AfterFilter);
		         		}
							PrintLogs(__LINE__+" Dont Reopen Lock and open SELL");
						}
	         	}
	         }
         }
         else
         {
         	if(lotSize[0]>0)
	         	MyPositionOpen(Symbol(),type?ORDER_TYPE_SELL:ORDER_TYPE_BUY,lotSize[0],SymbolInfoDouble(Symbol(),type?SYMBOL_BID:SYMBOL_ASK),0,0,comment[0],magic);
         }
	      PrintLogs(__LINE__+" Close Partially  by tkt = "+tkt[0]+" "+addComment+" "+comment[0]+" lot = "+lotSize[0]+" "+comment[0]+" "+magic);   
      }
   }
   else
   {
   	if(magic == MagicMRT_AfterFilter && UseDecreaseLotAmountInMRTCapsuleByMRT_MRTAfterFilter
   	|| magic == MagicMRT && UseDecreaseLotAmountInMRTCapsuleByMRT
   	|| magic == Magic && UseDecreaseLotAmountInCapsule_MainHedge)
   	{
	      for(int i=1;i<amount;i++)
	      {
	         if(profit[i]>0
	         && dist[i]*Point()>minProfitToClose)
	         {
	            if(profit[i]+minProfit*dist[0]*(-1)>0)
	            {
	               int minAmount = profit[i]/(minProfit*dist[0]);
	               MyPartialClose(tkt[0],minAmount*minDecreaseLotAmount);
	               lotSize[i]-=minAmount*minDecreaseLotAmount;
	               MyPositionClose(tkt[i]);
	               if(lotSize[i]>0)
	                  MyPositionOpen(Symbol(),type==0?ORDER_TYPE_SELL:ORDER_TYPE_BUY,lotSize[i],SymbolInfoDouble(Symbol(),type==0?SYMBOL_BID:SYMBOL_ASK),0,0,comment[i],magic);
	               PrintLogs(__LINE__+" Close Partially tkt = "+tkt[0]+" by tkt = "+tkt[i]+addComment+" "+comment[i]+" "+magic); 
	            }
	         }
	      }
      }
   }
   
}

void RunForDecreaseCapsule(int amount,double &profit[],double &lotSize[],int &dist[],int &tkt[],string &comment[],int type,int magic,string addComment,double minProfitToClose)
{
   double minDecreaseLotAmount = SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   double minProfit = SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE)*minDecreaseLotAmount;
   if(profit[0]>0
   && dist[0]*Point()>minProfitToClose)
   {
      bool close = false;
      for(int i=1;i<amount;i++)
      {
         if(profit[0]+profit[i]>0)
         {
         	if(lotSize[i]>minDecreaseLotAmount)
         	{
	            profit[0]+=profit[i];
	            lotSize[0]-=lotSize[i];
	            MyPositionClose(tkt[i]);
	            close=true;
	            PrintLogs(__LINE__+" Close fully tkt = "+tkt[i]+" by tkt = "+tkt[0]+addComment+" "+comment[0]+" "+magic);  
            }
         }
         else
         {
            if(profit[0]+minProfit*dist[i]*(-1)>0)
            {
               int minAmount = profit[0]/(minProfit*dist[i]);
               profit[0]-=minAmount*minDecreaseLotAmount*dist[i];
               lotSize[0]-=minAmount*minDecreaseLotAmount;
               MyPartialClose(tkt[i],minAmount*minDecreaseLotAmount);
               close=true;
               PrintLogs(__LINE__+" Close Partially tkt = "+tkt[i]+" by tkt = "+tkt[0]+" "+addComment+" lot = "+(minAmount*minDecreaseLotAmount)+" "+comment[0]+" "+magic); 
            }
         }
      }
      if(close)
      {
         MyPositionClose(tkt[0]);
      	int index = GetCapsuleIndex(comment[0]);
      	
         if(ReOpenAlwaysTrendSide)
         {
         	MyPositionOpen(Symbol(),type==0?ORDER_TYPE_BUY:ORDER_TYPE_SELL,lotSize[0],SymbolInfoDouble(Symbol(),type==0?SYMBOL_ASK:SYMBOL_BID),0,0,"0#0^"+index,magic);
				PrintLogs(__LINE__+" Reopen always");
         }
         else
         {
	      	double startLot = GlobalVariableGet(prefix+index+"lockStartLotAmount");
	      	
				GlobalVariableSet(prefix+index+"lockCloseReason",1);
				PrintLogs(__LINE__+" Lock Close Lock reason 1");
	      	if(DontReOpenAfterSelfDecrease)
	      	{
	      		bool hit = false;
         		if(DontReOpenAfterSelfDecrease == 1)
         		{
         			hit = startLot*DontReOpenTriggerPct/100>=lotSize[0];
         		}
         		if(DontReOpenAfterSelfDecrease == 2)
         		{
         			double minLot = (LotSizeCalculationBalance*DontReOpenTriggerMinLot/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
				      if(DontReOpenTriggerMinLotType)  
				         minLot = DontReOpenTriggerMinLot;
				      hit = minLot>=lotSize[0];
         		}
         		if(hit)
         		{
						GlobalVariableSet(prefix+index+"lockCloseReason",2);
		      		if(OpenOppositeInsteadLock)
		      		{
		      			MyInfo.lockCapsuleIndex++;
		      			MyPositionOpen(Symbol(),type?ORDER_TYPE_BUY:ORDER_TYPE_SELL,lotSize[0],SymbolInfoDouble(Symbol(),type?SYMBOL_ASK:SYMBOL_BID),0,0,"0#1^"+(MyInfo.lockCapsuleIndex*2+(index%2==1?1:0)),magic);
							GlobalVariableSet(prefix+(MyInfo.lockCapsuleIndex*2+(index%2==1?1:0))+"lockCloseReason",2);
							PrintLogs(__LINE__+" Open Opposite");
		      		}
						PrintLogs(__LINE__+" Dont Reopen Lock and open BUY");
					}
	      	}
      	}
      }
   }
   else
   {
      for(int i=1;i<amount;i++)
      {
         if(profit[i]>0
         && dist[i]*Point()>minProfitToClose)
         {
            if(profit[i]+minProfit*dist[0]*(-1)>0)
            {
               int minAmount = profit[i]/(minProfit*dist[0]);
               MyPartialClose(tkt[0],minAmount*minDecreaseLotAmount);
               lotSize[i]-=minAmount*minDecreaseLotAmount;
               MyPositionClose(tkt[i]);
               int index = GetCapsuleIndex(comment[i]);
		      	double startLot = GlobalVariableGet(prefix+index+"lockStartLotAmount");
		      	
		      	
					GlobalVariableSet(prefix+index+"lockCloseReason",1);
					PrintLogs(__LINE__+" Lock Close Lock reason 1");
		      	if(DontReOpenAfterSelfDecrease)
		      	{
		      		bool hit = false;
	         		if(DontReOpenAfterSelfDecrease == 1)
	         		{
	         			hit = startLot*DontReOpenTriggerPct/100>=lotSize[i];
	         		}
	         		if(DontReOpenAfterSelfDecrease == 2)
	         		{
	         			double minLot = (LotSizeCalculationBalance*DontReOpenTriggerMinLot/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
					      if(DontReOpenTriggerMinLotType)  
					         minLot = DontReOpenTriggerMinLot;
					      hit = minLot>=lotSize[i];
	         		}
	         		if(hit)
	         		{
							GlobalVariableSet(prefix+index+"lockCloseReason",2);
			      		if(OpenOppositeInsteadLock)
			      		{
			      			MyInfo.lockCapsuleIndex++;
			      			MyPositionOpen(Symbol(),type==0?ORDER_TYPE_BUY:ORDER_TYPE_SELL,lotSize[i],SymbolInfoDouble(Symbol(),type==0?SYMBOL_ASK:SYMBOL_BID),0,0,"0#1^"+(MyInfo.lockCapsuleIndex*2+(index%2==1?1:0)),magic);
								GlobalVariableSet(prefix+(MyInfo.lockCapsuleIndex*2+(index%2==1?1:0))+"lockCloseReason",2);
								PrintLogs(__LINE__+" Open Opposite");
			      		}
							PrintLogs(__LINE__+" Dont Reopen Lock");
						}
		      	}
               PrintLogs(__LINE__+" Close Partially tkt = "+tkt[0]+" by tkt = "+tkt[i]+addComment+" "+comment[i]+" "+magic); 
            }
         }
      }
   }
   
}

void CloseCapsules(double profit)
{
	for(int i=0;i<MyInfo.mainCapsuleAmount;i++)
	{
		if(profit<5)
			break;
		if(profit+MyInfo.mainCapsuleInfo[i].lockProfit+MyInfo.mainCapsuleInfo[i].mainProfit>0
		&& MyInfo.mainCapsuleInfo[i].lock
		&& MyInfo.mainCapsuleInfo[i].main)
		{
			MyPositionClose(MyInfo.mainCapsuleInfo[i].lockTkt);
			MyPositionClose(MyInfo.mainCapsuleInfo[i].mainTkt);
			PrintLogs(__LINE__+" Close Capsules After Equity Close");
		}
	}
}
void CloseCapsules(double &profit,double &prevEquity)
{
	for(int i=0;i<MyInfo.mainCapsuleAmount;i++)
	{
		if(profit<5)
			break;
		if(profit+MyInfo.mainCapsuleInfo[i].lockProfit+MyInfo.mainCapsuleInfo[i].mainProfit>0
		&& MyInfo.mainCapsuleInfo[i].lock
		&& MyInfo.mainCapsuleInfo[i].main)
		{
			profit+=MyInfo.mainCapsuleInfo[i].lockProfit+MyInfo.mainCapsuleInfo[i].mainProfit;
			prevEquity+=MyInfo.mainCapsuleInfo[i].lockProfit+MyInfo.mainCapsuleInfo[i].mainProfit;
			MyPositionClose(MyInfo.mainCapsuleInfo[i].lockTkt);
			MyPositionClose(MyInfo.mainCapsuleInfo[i].mainTkt);
			PrintLogs(__LINE__+" Close Capsules By MRT or After Equity Close");
		}
	}
}
void CheckForFeaturesCapsule(int count = 1)
{
	if(count == 1)
	{
		if(MyPositionInfo.isHistory)
		{
			for(int i=0;i<MyInfo.mainCapsuleAmount;i++)
			{
				if(MyInfo.mainCapsuleInfoHistory[i].index == MyPositionInfo.index)
				{
					if(!MyInfo.mainCapsuleInfo[i].lock
					&& MyPositionInfo.isLock && MyPositionInfo.ct>MyInfo.mainCapsuleInfoHistory[i].lockCT)
					{
						MyInfo.mainCapsuleInfoHistory[i].lockOP = MyPositionInfo.op;
						MyInfo.mainCapsuleInfoHistory[i].lockFound = true;
						MyInfo.mainCapsuleInfoHistory[i].lockProfit = MyPositionInfo.orderProfit;
						MyInfo.mainCapsuleInfoHistory[i].lockType = MyPositionInfo.orderType;
						MyInfo.mainCapsuleInfoHistory[i].lockCT = MyPositionInfo.ct;
						MyInfo.mainCapsuleInfoHistory[i].lockCP = MyPositionInfo.cp;
						MyInfo.mainCapsuleInfoHistory[i].lockLot = MyPositionInfo.lotSize;
						MyInfo.mainCapsuleInfoHistory[i].lockTkt = MyPositionInfo.positionID;
						MyInfo.mainCapsuleInfoHistory[i].type = MyPositionInfo.type;
					}
					if(!MyInfo.mainCapsuleInfo[i].main
					&& !MyPositionInfo.isLock && MyPositionInfo.ct>MyInfo.mainCapsuleInfoHistory[i].mainCT)
					{
						MyInfo.mainCapsuleInfoHistory[i].mainOP = MyPositionInfo.op;
						MyInfo.mainCapsuleInfoHistory[i].mainFound = true;
						MyInfo.mainCapsuleInfoHistory[i].mainProfit = MyPositionInfo.orderProfit;
						MyInfo.mainCapsuleInfoHistory[i].mainType = MyPositionInfo.orderType;
						MyInfo.mainCapsuleInfoHistory[i].mainCT = MyPositionInfo.ct;
						MyInfo.mainCapsuleInfoHistory[i].mainCP = MyPositionInfo.cp;
						MyInfo.mainCapsuleInfoHistory[i].mainLot = MyPositionInfo.lotSize;
						MyInfo.mainCapsuleInfoHistory[i].mainTkt = MyPositionInfo.positionID;
						MyInfo.mainCapsuleInfoHistory[i].type = MyPositionInfo.type;
					}
				}
			}
		}
		else
		{
			
			bool found = false;
			for(int i=0;i<MyInfo.mainCapsuleAmount;i++)
			{
				if(MyInfo.mainCapsuleInfo[i].index == MyPositionInfo.index)
				{
					found = true;
					MyInfo.mainCapsuleInfo[i].index = MyPositionInfo.index;
					MyInfo.mainCapsuleInfo[i].both = false;
					if(MyPositionInfo.isLock)
					{
						MyInfo.mainCapsuleInfo[i].lock = true;
						MyInfo.mainCapsuleInfo[i].lockFound = true;
						MyInfo.mainCapsuleInfo[i].lockOP = MyPositionInfo.op;
						MyInfo.mainCapsuleInfo[i].lockProfit = MyPositionInfo.orderProfit;
						MyInfo.mainCapsuleInfo[i].lockType = MyPositionInfo.orderType;
						MyInfo.mainCapsuleInfo[i].lockLot = MyPositionInfo.lotSize;
						MyInfo.mainCapsuleInfo[i].lockTkt = MyPositionInfo.tkt;
						MyInfo.mainCapsuleInfo[i].type = MyPositionInfo.type;
					}
					else
					{
						MyInfo.mainCapsuleInfo[i].main = true;
						MyInfo.mainCapsuleInfo[i].mainFound = true;
						MyInfo.mainCapsuleInfo[i].mainOP = MyPositionInfo.op;
						MyInfo.mainCapsuleInfo[i].mainProfit = MyPositionInfo.orderProfit;
						MyInfo.mainCapsuleInfo[i].mainType = MyPositionInfo.orderType;
						MyInfo.mainCapsuleInfo[i].mainLot = MyPositionInfo.lotSize;
						MyInfo.mainCapsuleInfo[i].mainTkt = MyPositionInfo.tkt;
						MyInfo.mainCapsuleInfo[i].type = MyPositionInfo.type;
					}
				}
			}
			if(!found)
			{
				int i = MyInfo.mainCapsuleAmount;
				MyInfo.mainCapsuleInfoHistory[i].index = MyPositionInfo.index;
				MyInfo.mainCapsuleInfo[i].index = MyPositionInfo.index;
				MyInfo.mainCapsuleInfo[i].lock = false;
				MyInfo.mainCapsuleInfo[i].main = false;
				MyInfo.mainCapsuleInfo[i].lockFound = false;
				MyInfo.mainCapsuleInfo[i].mainFound = false;
				MyInfo.mainCapsuleInfo[i].both = false;
				if(MyPositionInfo.isLock)
				{
					MyInfo.mainCapsuleInfo[i].lock = true;
					MyInfo.mainCapsuleInfo[i].lockFound = true;
					MyInfo.mainCapsuleInfo[i].lockOP = MyPositionInfo.op;
					MyInfo.mainCapsuleInfo[i].lockProfit = MyPositionInfo.orderProfit;
					MyInfo.mainCapsuleInfo[i].lockType = MyPositionInfo.orderType;
					MyInfo.mainCapsuleInfo[i].lockLot = MyPositionInfo.lotSize;
					MyInfo.mainCapsuleInfo[i].lockTkt = MyPositionInfo.tkt;
					MyInfo.mainCapsuleInfo[i].type = MyPositionInfo.type;
				}
				else
				{
					MyInfo.mainCapsuleInfo[i].main = true;
					MyInfo.mainCapsuleInfo[i].mainFound = true;
					MyInfo.mainCapsuleInfo[i].mainOP = MyPositionInfo.op;
					MyInfo.mainCapsuleInfo[i].mainProfit = MyPositionInfo.orderProfit;
					MyInfo.mainCapsuleInfo[i].mainType = MyPositionInfo.orderType;
					MyInfo.mainCapsuleInfo[i].mainLot = MyPositionInfo.lotSize;
					MyInfo.mainCapsuleInfo[i].mainTkt = MyPositionInfo.tkt;
					MyInfo.mainCapsuleInfo[i].type = MyPositionInfo.type;
				}
				MyInfo.mainCapsuleAmount++;
			}
		}
		return;
	}
	if(count == 2)
	{
		for(int i=0;i<MyInfo.mainCapsuleAmount;i++)
		{
			if(MyInfo.mainCapsuleInfo[i].index != MyInfo.mainCapsuleInfoHistory[i].index)
				continue;
			if(!MyInfo.mainCapsuleInfo[i].lock)
			{
				MyInfo.mainCapsuleInfo[i].lockOP = MyInfo.mainCapsuleInfoHistory[i].lockOP;
				MyInfo.mainCapsuleInfo[i].lockFound = MyInfo.mainCapsuleInfoHistory[i].lockFound;
				MyInfo.mainCapsuleInfo[i].lockProfit = MyInfo.mainCapsuleInfoHistory[i].lockProfit;
				MyInfo.mainCapsuleInfo[i].lockType = MyInfo.mainCapsuleInfoHistory[i].lockType;
				MyInfo.mainCapsuleInfo[i].lockCT = MyInfo.mainCapsuleInfoHistory[i].lockCT;
				MyInfo.mainCapsuleInfo[i].lockCP = MyInfo.mainCapsuleInfoHistory[i].lockCP;
				MyInfo.mainCapsuleInfo[i].lockLot = MyInfo.mainCapsuleInfoHistory[i].lockLot;
				MyInfo.mainCapsuleInfo[i].lockTkt = MyInfo.mainCapsuleInfoHistory[i].lockTkt;
				MyInfo.mainCapsuleInfo[i].type = MyInfo.mainCapsuleInfoHistory[i].type;
			}
			if(!MyInfo.mainCapsuleInfo[i].main)
			{
				MyInfo.mainCapsuleInfo[i].mainOP = MyInfo.mainCapsuleInfoHistory[i].mainOP;
				MyInfo.mainCapsuleInfo[i].mainFound = MyInfo.mainCapsuleInfoHistory[i].mainFound;
				MyInfo.mainCapsuleInfo[i].mainProfit = MyInfo.mainCapsuleInfoHistory[i].mainProfit;
				MyInfo.mainCapsuleInfo[i].mainType = MyInfo.mainCapsuleInfoHistory[i].mainType;
				MyInfo.mainCapsuleInfo[i].mainCT = MyInfo.mainCapsuleInfoHistory[i].mainCT;
				MyInfo.mainCapsuleInfo[i].mainCP = MyInfo.mainCapsuleInfoHistory[i].mainCP;
				MyInfo.mainCapsuleInfo[i].mainLot = MyInfo.mainCapsuleInfoHistory[i].mainLot;
				MyInfo.mainCapsuleInfo[i].mainTkt = MyInfo.mainCapsuleInfoHistory[i].mainTkt;
				MyInfo.mainCapsuleInfo[i].type = MyInfo.mainCapsuleInfoHistory[i].type;
			}
		}
		return;
	}	
			
	if(MyInfo.mainCapsuleAmount == 0)
	{
		MyInfo.lockCapsuleIndex = 0;
	}
	for(int i=0;i<MyInfo.mainCapsuleAmount;i++)
	{
		if(MyInfo.mainCapsuleInfo[i].main
		&& MyInfo.mainCapsuleInfo[i].lock)
			MyInfo.mainCapsuleInfo[i].both = true;
		if(!MyInfo.mainCapsuleInfo[i].lockFound
		|| !MyInfo.mainCapsuleInfo[i].mainFound)
			continue;
		double lockReason = GlobalVariableGet(prefix+MyInfo.mainCapsuleInfo[i].index+"lockCloseReason");
		double closeProfit = MyInfo.mainCapsuleInfo[i].lockProfit + MyInfo.mainCapsuleInfo[i].mainProfit-(MyInfo.mainCapsuleInfo[i].lockLot+MyInfo.mainCapsuleInfo[i].mainLot)*CommissionPct/100;
		
		if(CloseCapsuleFromBalance
		&& MyInfo.mainCapsuleInfo[i].lock && MyInfo.mainCapsuleInfo[i].main
		&& MathAbs(closeProfit) < (UseSavedProfitFrom?MyInfo.savedProfit:(MyInfo.mainCapsuleInfo[i].type?MyInfo.savedProfitSell:MyInfo.savedProfitBuy)))
		{
			if(UseSavedProfitFrom)
			{
				MyInfo.savedProfit+=closeProfit;
			}
			else
			{
				if(MyInfo.mainCapsuleInfo[i].type == 0)
					MyInfo.savedProfitBuy+=closeProfit;
				else
					MyInfo.savedProfitSell+=closeProfit;
				
			}
			MyPositionClose(MyInfo.mainCapsuleInfo[i].mainTkt);
			MyPositionClose(MyInfo.mainCapsuleInfo[i].lockTkt);
			PrintLogs(__LINE__+" Close Capsule From balance Index =  "+MyInfo.mainCapsuleInfo[i].index+" close Profit = "+closeProfit);
		}
		if((!MyInfo.mainCapsuleInfo[i].lock && MyInfo.mainCapsuleInfo[i].main
		|| MyInfo.mainCapsuleInfo[i].lock && !MyInfo.mainCapsuleInfo[i].main))
		{
			if(!MyInfo.mainCapsuleInfo[i].lock)
			{
				if(lockReason !=2
				&& MyInfo.mainCapsuleInfo[i].lockType == 0 
				&&(MyInfo.mainCapsuleInfo[i].lockCP + m_ReOpenDistAfterSelfDecrease<SymbolInfoDouble(Symbol(),SYMBOL_ASK)
				|| UseCapsuleTwoSideReOpen && MyInfo.mainCapsuleInfo[i].lockCP - m_ReOpenDistAfterSelfDecrease>SymbolInfoDouble(Symbol(),SYMBOL_ASK))
				|| MyInfo.mainCapsuleInfo[i].lockType == 1 
				&&(MyInfo.mainCapsuleInfo[i].lockCP - m_ReOpenDistAfterSelfDecrease>SymbolInfoDouble(Symbol(),SYMBOL_BID)
				|| UseCapsuleTwoSideReOpen && MyInfo.mainCapsuleInfo[i].lockCP + m_ReOpenDistAfterSelfDecrease<SymbolInfoDouble(Symbol(),SYMBOL_BID)))
				{
					MyPositionOpen(Symbol(),
										MyInfo.mainCapsuleInfo[i].lockType?ORDER_TYPE_SELL:ORDER_TYPE_BUY,
										MyInfo.mainCapsuleInfo[i].mainLot,SymbolInfoDouble(Symbol(),
										MyInfo.mainCapsuleInfo[i].lockType?SYMBOL_BID:SYMBOL_ASK),
										0,0,"0#0^"+MyInfo.mainCapsuleInfo[i].index,MagicMRT);
					PrintLogs(__LINE__+" Reopen Capsule Trade "+MyInfo.mainCapsuleInfo[i].index);
				} 
				if(UseBE_Capsule)
				{
					if(MyInfo.mainCapsuleInfo[i].mainType == 0 && MyInfo.mainCapsuleInfo[i].mainOP + m_BEAfter_Capsule<SymbolInfoDouble(Symbol(),SYMBOL_ASK)
					|| MyInfo.mainCapsuleInfo[i].mainType == 1 && MyInfo.mainCapsuleInfo[i].mainOP - m_BEAfter_Capsule>SymbolInfoDouble(Symbol(),SYMBOL_BID))
					{
						myTrade.PositionModify(MyInfo.mainCapsuleInfo[i].mainTkt,MyInfo.mainCapsuleInfo[i].mainOP + m_BEAt_Capsule*(MyInfo.mainCapsuleInfo[i].mainType?(-1):1),0);
						PrintLogs(__LINE__+" Set BE for ODD Trade of Capsule");
					}
				}
				if(m_TP_Capsule != 0
				&&(MyInfo.mainCapsuleInfo[i].mainType == 0 && MyInfo.mainCapsuleInfo[i].mainOP + m_TP_Capsule< SymbolInfoDouble(Symbol(),SYMBOL_ASK)
				|| MyInfo.mainCapsuleInfo[i].mainType == 1 && MyInfo.mainCapsuleInfo[i].mainOP - m_TP_Capsule> SymbolInfoDouble(Symbol(),SYMBOL_BID)))
				{
					MyPositionClose(MyInfo.mainCapsuleInfo[i].mainTkt);
					PrintLogs(__LINE__+" Close ODD Trade from Capsule IN TP");
				}
				if(IncludeOddCapsuleInProfitCalculation)
				{
					if(MyInfo.mainCapsuleInfo[i].type == 0)
					{
						MyInfo.buyMRT.profit+=MyInfo.mainCapsuleInfo[i].mainProfit;
						MyInfo.buyMRT.lotSum+=MyInfo.mainCapsuleInfo[i].mainLot;
						MyInfo.buyMRT.avgOP+=MyInfo.mainCapsuleInfo[i].mainLot*MyInfo.mainCapsuleInfo[i].mainOP;
					}
					else
					{
						MyInfo.sellMRT.profit+=MyInfo.mainCapsuleInfo[i].mainProfit;
						MyInfo.sellMRT.lotSum+=MyInfo.mainCapsuleInfo[i].mainLot;
						MyInfo.sellMRT.avgOP+=MyInfo.mainCapsuleInfo[i].mainLot*MyInfo.mainCapsuleInfo[i].mainOP;
					}
				}
			}
			if(!MyInfo.mainCapsuleInfo[i].main)
			{
				if(lockReason !=2
				&& MyInfo.mainCapsuleInfo[i].mainType == 0 
				&&(MyInfo.mainCapsuleInfo[i].mainCP + m_ReOpenDistAfterSelfDecrease<SymbolInfoDouble(Symbol(),SYMBOL_ASK)
				|| UseCapsuleTwoSideReOpen && MyInfo.mainCapsuleInfo[i].mainCP - m_ReOpenDistAfterSelfDecrease>SymbolInfoDouble(Symbol(),SYMBOL_ASK))
				|| MyInfo.mainCapsuleInfo[i].mainType == 1 
				&&(MyInfo.mainCapsuleInfo[i].mainCP - m_ReOpenDistAfterSelfDecrease>SymbolInfoDouble(Symbol(),SYMBOL_BID)
				|| UseCapsuleTwoSideReOpen && MyInfo.mainCapsuleInfo[i].lockCP + m_ReOpenDistAfterSelfDecrease<SymbolInfoDouble(Symbol(),SYMBOL_BID)))
				{
					MyPositionOpen(Symbol(),
										MyInfo.mainCapsuleInfo[i].mainType?ORDER_TYPE_SELL:ORDER_TYPE_BUY,
										MyInfo.mainCapsuleInfo[i].lockLot,SymbolInfoDouble(Symbol(),
										MyInfo.mainCapsuleInfo[i].mainType?SYMBOL_BID:SYMBOL_ASK),
										0,0,"0#1^"+MyInfo.mainCapsuleInfo[i].index,MagicMRT);
					PrintLogs(__LINE__+" Reopen Capsule Trade "+MyInfo.mainCapsuleInfo[i].index);
				} 
				
				if(UseBE_Capsule)
				{
					if(MyInfo.mainCapsuleInfo[i].lockType == 0 && MyInfo.mainCapsuleInfo[i].lockOP + m_BEAfter_Capsule<SymbolInfoDouble(Symbol(),SYMBOL_ASK)
					|| MyInfo.mainCapsuleInfo[i].lockType == 1 && MyInfo.mainCapsuleInfo[i].lockOP - m_BEAfter_Capsule>SymbolInfoDouble(Symbol(),SYMBOL_BID))
					{
						myTrade.PositionModify(MyInfo.mainCapsuleInfo[i].lockTkt,MyInfo.mainCapsuleInfo[i].lockOP + m_BEAt_Capsule*(MyInfo.mainCapsuleInfo[i].lockType?(-1):1),0);
						PrintLogs(__LINE__+" Set BE for ODD Trade of Capsule");
					}
				}
				if(m_TP_Capsule != 0
				&&(MyInfo.mainCapsuleInfo[i].lockType == 0 && MyInfo.mainCapsuleInfo[i].lockOP + m_TP_Capsule< SymbolInfoDouble(Symbol(),SYMBOL_ASK)
				|| MyInfo.mainCapsuleInfo[i].lockType == 1 && MyInfo.mainCapsuleInfo[i].lockOP - m_TP_Capsule> SymbolInfoDouble(Symbol(),SYMBOL_BID)))
				{
					MyPositionClose(MyInfo.mainCapsuleInfo[i].mainTkt);
					PrintLogs(__LINE__+" Close ODD Trade from Capsule IN TP");
				}
				if(IncludeOddCapsuleInProfitCalculation)
				{
					if(MyInfo.mainCapsuleInfo[i].type == 0)
					{
						MyInfo.buyMRT.profit+=MyInfo.mainCapsuleInfo[i].lockProfit;
						MyInfo.buyMRT.lotSum+=MyInfo.mainCapsuleInfo[i].lockLot;
						MyInfo.buyMRT.avgOP+=MyInfo.mainCapsuleInfo[i].lockLot*MyInfo.mainCapsuleInfo[i].lockOP;
					}
					else
					{
						MyInfo.sellMRT.profit+=MyInfo.mainCapsuleInfo[i].lockProfit;
						MyInfo.sellMRT.lotSum+=MyInfo.mainCapsuleInfo[i].lockLot;
						MyInfo.sellMRT.avgOP+=MyInfo.mainCapsuleInfo[i].lockLot*MyInfo.mainCapsuleInfo[i].lockOP;
					}
				}
			}
		}
	}
}
datetime lastFilterUpdate = 0;
void FindFilterCrossOver()
{
	if(iBarShift(Symbol(),TF,lastFilterUpdate) == iBarShift(Symbol(),TF,TimeCurrent()))
		return;
	SetDistanceValues();
	lastFilterUpdate = TimeCurrent();
   MyInfo.filterValue = Filter();
   MyInfo.filterValueBuy = MyInfo.filterValue == 1 || MyInfo.filterValue == 0;
   MyInfo.filterValueSell = MyInfo.filterValue == 1 || MyInfo.filterValue == -1;
   
	
	MyInfo.buyMRT.filterCrossOverIndex = 0;
	MyInfo.sellMRT.filterCrossOverIndex = 0;
	
	
	
  
   
   
	if(LockTriggerType == 0)
	{
		MyInfo.filterLockTriggerSell = MAFast()>MAMid();
		MyInfo.filterLockTriggerBuy = MAFast()<MAMid();
		MyInfo.filterLockExitTriggerSell = MAFast()<MAMid();
		MyInfo.filterLockExitTriggerBuy = MAFast()>MAMid();
	}
	if(LockTriggerType == 1)
	{
		MyInfo.filterLockTriggerSell = MAFast()>MASlow();
		MyInfo.filterLockTriggerBuy = MAFast()<MASlow();
		MyInfo.filterLockExitTriggerSell = MAFast()<MASlow();
		MyInfo.filterLockExitTriggerBuy = MAFast()>MASlow();
	}
	if(UseMATrigger == 1)
		MyInfo.MATrigger = MAMid()>MASlow() && MAFast()<MAMid() || MAMid()<MASlow() && MAFast()>MAMid();
	if(UseMATrigger == 2)
		MyInfo.MATrigger = MAMid()>MASlow() && MAFast()<MASlow() || MAMid()<MASlow() && MAFast()>MASlow();

	for(int i=1;i<1000;i++)
	{	
		double filter1=Filter(i);
		double filter2=Filter(i+1);
		if(MyInfo.buyMRT.filterCrossOverIndex==0
		&& filter1 == 0
		&& filter2 != 0)
		{
			MyInfo.buyMRT.filterCrossOverIndex = i;
		}
		if(MyInfo.sellMRT.filterCrossOverIndex==0
		&& filter1 == -1
		&& filter2 != -1)
		{
			MyInfo.sellMRT.filterCrossOverIndex = i;
		}
		if(MyInfo.buyMRT.filterCrossOverIndex != 0
		&& MyInfo.sellMRT.filterCrossOverIndex != 0)
			break;
	}
	if(MyInfo.sellMRT.filterCrossOverIndex == 0)
		MyInfo.sellMRT.filterCrossOverIndex = 1000000;
	if(MyInfo.buyMRT.filterCrossOverIndex == 0)
		MyInfo.buyMRT.filterCrossOverIndex = 1000000;
	if(EndAddTrades == 0)
	{
		MyInfo.endAddTradesBuy = MAFast()<MAMid() || MyInfo.sellMRT.filterCrossOverIndex<MyInfo.buyMRT.filterCrossOverIndex;
		MyInfo.endAddTradesSell = MAFast()>MAMid() || MyInfo.sellMRT.filterCrossOverIndex>MyInfo.buyMRT.filterCrossOverIndex;
	}
	if(EndAddTrades == 1)
	{
		MyInfo.endAddTradesBuy = MAFast()<MASlow() || MyInfo.sellMRT.filterCrossOverIndex<MyInfo.buyMRT.filterCrossOverIndex;
		MyInfo.endAddTradesSell = MAFast()>MASlow() || MyInfo.sellMRT.filterCrossOverIndex>MyInfo.buyMRT.filterCrossOverIndex;
	}
	 if(FilterEffect && (UseMAFilter == 1 || UseMACDFilter || UseRSIFilter))
   {
   	if(MyInfo.endAddTradesSell)
   		MyInfo.filterOutSell=0;
   	if(MyInfo.endAddTradesBuy)
   		MyInfo.filterOutBuy=0;
   }
}
int Filter(int index = 1)
{
   bool filterBuy = (!UseMAFilter || MAFast(index)>MAMid(index) && MAMid(index)>MASlow(index));
   filterBuy = filterBuy && (!UseRSIFilter || RSI(index)<RSIBuyLevel);
   filterBuy = filterBuy && (!UseMACDFilter || MACD(index)<MACDBuyLevel);
   
   
   bool filterSell = (!UseMAFilter || MAFast(index)<MAMid(index) && MAMid(index)<MASlow(index));
   filterSell = filterSell && (!UseRSIFilter || RSI(index)>RSISellLevel);
   filterSell = filterSell && (!UseMACDFilter || MACD(index)>MACDSellLevel);
   
   return FilterEffect==0?1:(filterBuy?0:(filterSell?-1:-2));
}
void 	CheckForOpenMRT()
{
   if(OpenSide == 0 || OpenSide == 2)
   {
      if(!MyInfo.buyMRT.isAction)
      {  
         if(MyInfo.filterValue == 1 || MyInfo.filterValue == 0)
         {
      		double startLot = (LotSizeCalculationBalance*StartLot/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
            if(StartLotType)  
               startLot = StartLot;
            if(UseLotSizeFilterAccordingToMA
            && SymbolInfoDouble(Symbol(),SYMBOL_ASK)<MALotSize())
               startLot*=LotSizeMultiplierWhenFilteredByMA;

            MyPositionOpen(Symbol(),ORDER_TYPE_BUY,(UseMinSizeForFirstTrade?SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN):startLot),SymbolInfoDouble(Symbol(),SYMBOL_ASK),0,0,"1=1"+"^"+1,MagicMRT);
            MyInfo.filterOutBuy = 2;
            MyInfo.lotBuy = startLot;
            MyInfo.buyMRT.lockCloseReason=0;
            MyInfo.buyMRT.lockStartLotAmount=0;
            MyInfo.buyMRT.lastDDTrigger = 0 ;
            PrintLogs(__LINE__+" Open First Trade MRT BUY ");
            return;
         }
      }
      else
      {
      	if(MyInfo.filterValueBuy)
      	{
	         MyInfo.buyMRT.lockCloseReason=0;
	         MyInfo.buyMRT.lockStartLotAmount=0;
         }
         CheckForFeaturesMRT(0,MyInfo.buyMRT,!MyInfo.endAddTradesBuy);
      }
   }
   if(OpenSide == 1 || OpenSide == 2)
   {
      if(!MyInfo.sellMRT.isAction)
      {
         if(MyInfo.filterValue == 1 || MyInfo.filterValue == -1)
         {
      		double startLot = (LotSizeCalculationBalance*StartLot/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
            if(StartLotType)  
               startLot = StartLot;
            
            if(UseLotSizeFilterAccordingToMA
            && SymbolInfoDouble(Symbol(),SYMBOL_BID)>MALotSize())
               startLot*=LotSizeMultiplierWhenFilteredByMA;
            MyPositionOpen(Symbol(),ORDER_TYPE_SELL,(UseMinSizeForFirstTrade?SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN):startLot),SymbolInfoDouble(Symbol(),SYMBOL_BID),0,0,"1=1"+"^"+1,MagicMRT);
            MyInfo.filterOutSell = 2;
            MyInfo.lotSell = startLot;
            MyInfo.sellMRT.lockCloseReason=0;
            MyInfo.sellMRT.lockStartLotAmount=0;
            MyInfo.sellMRT.lastDDTrigger = 0 ;
            PrintLogs(__LINE__+" Open First Trade MRT SELL ");
            return;
         }
      }
      else
      {
      	if(MyInfo.filterValueSell)
      	{
	         MyInfo.sellMRT.lockCloseReason=0;
	         MyInfo.sellMRT.lockStartLotAmount=0;
         }
         CheckForFeaturesMRT(1,MyInfo.sellMRT,!MyInfo.endAddTradesSell);
      }
   }
   
}

void GetMRTInfo(bool count = true)
{
	if(count)
	{
		if(MyPositionInfo.isHedge
		&& MyPositionInfo.index == (MyPositionInfo.type?MyInfo.sellHedge.index:MyInfo.buyHedge.index))
		{
			if(MyPositionInfo.isLock)
			{
				if(MyPositionInfo.type == 0)
					MyInfo.buyMRT.isHedged = -1;
				else
					MyInfo.sellMRT.isHedged = -1;
			}
			else
			{
				if(MyPositionInfo.type == 0)
				{
					if(MyInfo.buyMRT.isHedged!=-1)
					{
						MyInfo.buyMRT.isHedged = 1;
					}
				}
				else
				{
					if(MyInfo.sellMRT.isHedged!=-1)
					{
						MyInfo.sellMRT.isHedged = 1;
					}
				}
			}
		}
      if(UseSecondaryMRTInTP
      && MyPositionInfo.isMRT_AfterFilter
      &&!MyPositionInfo.isLock)
      {
      	if(MyPositionInfo.type == 0)
      	{
      		MyInfo.buyMRT.lotSumMRTAfterFilter+=MyPositionInfo.lotSize;
      		MyInfo.buyMRT.avgMRTAfterFilter+=MyPositionInfo.op*MyPositionInfo.lotSize;
      		MyInfo.buyMRT.profitMRTAfterFilter+=MyPositionInfo.orderProfit;
      	}
      	else
      	{
      		MyInfo.sellMRT.lotSumMRTAfterFilter+=MyPositionInfo.lotSize;
      		MyInfo.sellMRT.avgMRTAfterFilter+=MyPositionInfo.op*MyPositionInfo.lotSize;
      		MyInfo.sellMRT.profitMRTAfterFilter+=MyPositionInfo.orderProfit;
      	}
      }
      if(MyPositionInfo.isMRT
      && MyPositionInfo.isLock)
      {
      	if(MyPositionInfo.type == 0)
      	{
      		MyInfo.buyMRT.lockTkt = MyPositionInfo.tkt;
      		MyInfo.buyMRT.lockLot+= MyPositionInfo.lotSize;
      		MyInfo.buyMRT.lockProfit+= MyPositionInfo.orderProfit;
      		MyInfo.buyMRT.lockLastNType = MathMax(MyInfo.buyMRT.lockLastNType,MyPositionInfo.nType);
      	}
      	else
      	{
      		MyInfo.sellMRT.lockTkt = MyPositionInfo.tkt;
      		MyInfo.sellMRT.lockLot+= MyPositionInfo.lotSize;
      		MyInfo.sellMRT.lockProfit+= MyPositionInfo.orderProfit;
      		MyInfo.sellMRT.lockLastNType = MathMax(MyInfo.sellMRT.lockLastNType,MyPositionInfo.nType);
      	}
   		if(UseBE_LockAfterFilter)
         {
            if(MyPositionInfo.sl == 0
            &&(MyPositionInfo.orderType == 0 && MyPositionInfo.op+m_BEAfter_LockAfterFilter<SymbolInfoDouble(Symbol(),SYMBOL_BID)
            || MyPositionInfo.orderType == 1 && MyPositionInfo.op-m_BEAfter_LockAfterFilter>SymbolInfoDouble(Symbol(),SYMBOL_ASK)))
            {
		         if(MyPositionInfo.orderType == 1)
		         {
		         	MyInfo.buyMRT.lockCloseReason = 0;
		        	}
		        	else
		        	{
		         	MyInfo.sellMRT.lockCloseReason = 0;
		         }
               myTrade.PositionModify(MyPositionInfo.tkt,MyPositionInfo.op+m_BEAt_LockAfterFilter*(MyPositionInfo.orderType?-1:1),0);
            }
         }
         return;
      }
      
      if(MyPositionInfo.isMRT
      &&!MyPositionInfo.isLock
      && MyPositionInfo.nType == 3)
      {
      	if(MyPositionInfo.type == 0)
      	{
      		if(MyPositionInfo.n>0)
      			MyInfo.buyMRT.isOpen3[MyPositionInfo.n]=MyPositionInfo.op;
	         MyInfo.buyMRT.lotSum += MyPositionInfo.lotSize;
	         MyInfo.buyMRT.avgOP+=MyPositionInfo.op*MyPositionInfo.lotSize;
	         MyInfo.buyMRT.profit+=MyPositionInfo.orderProfit;
	         if(MyPositionInfo.ot>MyInfo.buyMRT.lastOpenedT)
	         {
	         	MyInfo.buyMRT.lastOpenedN = MyPositionInfo.n;	
	         	MyInfo.buyMRT.lastOpenedT = MyPositionInfo.ot;
         	}
         }
         else
      	{
      		if(MyPositionInfo.n>0)
      			MyInfo.sellMRT.isOpen3[MyPositionInfo.n]=MyPositionInfo.op;
	         MyInfo.sellMRT.lotSum += MyPositionInfo.lotSize;
	         MyInfo.sellMRT.avgOP+=MyPositionInfo.op*MyPositionInfo.lotSize;
	         MyInfo.sellMRT.profit+=MyPositionInfo.orderProfit;
	         if(MyPositionInfo.ot>MyInfo.sellMRT.lastOpenedT)
	         {
	         	MyInfo.sellMRT.lastOpenedN = MyPositionInfo.n;	
	         	MyInfo.sellMRT.lastOpenedT = MyPositionInfo.ot;
         	}
         }
      }
      
      if(MyPositionInfo.isMRT
      &&!MyPositionInfo.isLock
      && MyPositionInfo.nType == 2)
      {
      	if(MyPositionInfo.type == 0)
      	{
      		if(MyPositionInfo.n>0)
      			MyInfo.buyMRT.isOpen2[MyPositionInfo.n]=MyPositionInfo.op;
	         MyInfo.buyMRT.lotSum += MyPositionInfo.lotSize;
	         MyInfo.buyMRT.avgOP+=MyPositionInfo.op*MyPositionInfo.lotSize;
	         MyInfo.buyMRT.profit+=MyPositionInfo.orderProfit;
	         if(MyInfo.buyMRT.lastN <= MyPositionInfo.n && CloseSecondary)
	         {
	            MyInfo.buyMRT.lastN = MyPositionInfo.n;
	         }  
	         if(MyPositionInfo.ot>MyInfo.buyMRT.lastOpenedT)
	         {
	         	MyInfo.buyMRT.lastOpenedN = MyPositionInfo.n;	
	         	MyInfo.buyMRT.lastOpenedT = MyPositionInfo.ot;
         	}
	      } 
	      else
      	{
      		if(MyPositionInfo.n>0)
      			MyInfo.sellMRT.isOpen2[MyPositionInfo.n]=MyPositionInfo.op;
	         MyInfo.sellMRT.lotSum += MyPositionInfo.lotSize;
	         MyInfo.sellMRT.avgOP+=MyPositionInfo.op*MyPositionInfo.lotSize;
	         MyInfo.sellMRT.profit+=MyPositionInfo.orderProfit;
	         if(MyInfo.sellMRT.lastN <= MyPositionInfo.n && CloseSecondary)
	         {
	            MyInfo.sellMRT.lastN = MyPositionInfo.n;
	         }  
	         if(MyPositionInfo.ot>MyInfo.sellMRT.lastOpenedT)
	         {
	         	MyInfo.sellMRT.lastOpenedN = MyPositionInfo.n;	
	         	MyInfo.sellMRT.lastOpenedT = MyPositionInfo.ot;
         	}
	      } 
      }
      if(MyPositionInfo.isMRT
      &&!MyPositionInfo.isLock
      && MyPositionInfo.nType == 1)
      {
         if(MyPositionInfo.type == 0)
      	{
      		if(MyPositionInfo.n>0)
      			MyInfo.buyMRT.isOpen1[MyPositionInfo.n]=MyPositionInfo.op;
	         MyInfo.buyMRT.lotSum += MyPositionInfo.lotSize;
	         MyInfo.buyMRT.avgOP+=MyPositionInfo.op*MyPositionInfo.lotSize;
	         MyInfo.buyMRT.profit+=MyPositionInfo.orderProfit;
	         
	         if(MyPositionInfo.n == 1)
	         {
	         	MyInfo.buyMRT.firstOP = MyPositionInfo.op;
	         	MyInfo.buyMRT.oppositeOP = MyPositionInfo.op;
	         	MyInfo.buyMRT.positiveOP = MyPositionInfo.op;
	         }
	         if(MyInfo.buyMRT.lastN < MyPositionInfo.n)
	         {
	         	MyInfo.buyMRT.lastN = MyPositionInfo.n;
	         }
	         if( MyInfo.buyMRT.oppositeN < MyPositionInfo.n)
	         {
	         	MyInfo.buyMRT.oppositeN = MyPositionInfo.n;
	         	MyInfo.buyMRT.oppositeOP = MyPositionInfo.op;
	         	MyInfo.buyMRT.oppositeLot = MyPositionInfo.lotSize;
	         }
	         if(MyInfo.buyMRT.positiveN > MyPositionInfo.n)
	         {
	         	MyInfo.buyMRT.positiveN = MyPositionInfo.n;
	         	MyInfo.buyMRT.positiveOP = MyPositionInfo.op;
	         	MyInfo.buyMRT.positiveLot = MyPositionInfo.lotSize;
	         }
	         if(MyPositionInfo.ot>MyInfo.buyMRT.lastOpenedT)
	         {
	         	MyInfo.buyMRT.lastOpenedN = MyPositionInfo.n;	
	         	MyInfo.buyMRT.lastOpenedT = MyPositionInfo.ot;
         	}
         }
         else
      	{
      		if(MyPositionInfo.n>0)
      			MyInfo.sellMRT.isOpen1[MyPositionInfo.n]=MyPositionInfo.op;
	         MyInfo.sellMRT.lotSum += MyPositionInfo.lotSize;
	         MyInfo.sellMRT.avgOP+=MyPositionInfo.op*MyPositionInfo.lotSize;
	         MyInfo.sellMRT.profit+=MyPositionInfo.orderProfit;
	         
	         if(MyPositionInfo.n == 1)
	         {
	         	MyInfo.sellMRT.firstOP = MyPositionInfo.op;
	         	MyInfo.sellMRT.oppositeOP = MyPositionInfo.op;
	         	MyInfo.sellMRT.positiveOP = MyPositionInfo.op;
	         }
	         if(MyInfo.sellMRT.lastN < MyPositionInfo.n)
	         {
	         	MyInfo.sellMRT.lastN = MyPositionInfo.n;
	         }
	         if(MyInfo.sellMRT.oppositeN == 0 || MyInfo.sellMRT.oppositeN < MyPositionInfo.n)
	         {
	         	MyInfo.sellMRT.oppositeN = MyPositionInfo.n;
	         	MyInfo.sellMRT.oppositeOP = MyPositionInfo.op;
	         	MyInfo.sellMRT.oppositeLot = MyPositionInfo.lotSize;
	         }
	         if(MyInfo.sellMRT.positiveN == 0 || MyInfo.sellMRT.positiveN > MyPositionInfo.n)
	         {
	         	MyInfo.sellMRT.positiveN = MyPositionInfo.n;
	         	MyInfo.sellMRT.positiveOP = MyPositionInfo.op;
	         	MyInfo.sellMRT.positiveLot = MyPositionInfo.lotSize;
	         }
	         if(MyPositionInfo.ot>MyInfo.sellMRT.lastOpenedT)
	         {
	         	MyInfo.sellMRT.lastOpenedN = MyPositionInfo.n;	
	         	MyInfo.sellMRT.lastOpenedT = MyPositionInfo.ot;
         	}
         }
      }
      return;
   }
   
   MyInfo.buyMRT.profit+=MyInfo.buyMRT.profitMRTAfterFilter;
   MyInfo.sellMRT.profit+=MyInfo.sellMRT.profitMRTAfterFilter;
   if(MyInfo.buyMRT.lotSum>0)
      MyInfo.buyMRT.avgPrice = (MyInfo.buyMRT.avgOP+MyInfo.buyMRT.avgMRTAfterFilter)/(MyInfo.buyMRT.lotSum+MyInfo.buyMRT.lotSumMRTAfterFilter);
   if(MyInfo.sellMRT.lotSum>0)
      MyInfo.sellMRT.avgPrice = (MyInfo.sellMRT.avgOP+MyInfo.sellMRT.avgMRTAfterFilter)/(MyInfo.sellMRT.lotSum+MyInfo.sellMRT.lotSumMRTAfterFilter);
}



struct EnumNthList
{
	int n;
	ulong tkt[4];
};
struct EnumMyList
{
	EnumNthList list[10000];
	int amount;
	EnumMyList()
	{
		amount = 0;
	}
	void Clear()
	{
		amount = 0;
	}
	void Add(int n,ulong tkt,int type)
	{
		bool found = false;
		for(int i=0;i<amount;i++)
		{
			if(list[i].n == n)
			{
				list[i].tkt[type] = tkt;
				found = true;
				break;
			}
		}
		if(!found)
		{
			EnumNthList b;
			b.n = n;
			b.tkt[1]=0;
			b.tkt[2]=0;
			b.tkt[3]=0;
			b.tkt[type]=tkt;
			amount++;
			Insert(0,amount-1,b);
		}
	}
	void Insert(int from,int to,EnumNthList &item)
	{
		if(to <1)
		{
			list[from] = item;
			return;
		}
		if(from == to)
		{
			EnumNthList saveValue=list[from];
			for(int i=from;i<MathMin(amount-1,9999);i++)
			{
				EnumNthList b = list[i+1];
				list[i+1] = saveValue;
				saveValue = b;
			}
			list[from] = item;
			return;
		}
		if(list[(from+to)/2].n>=item.n)
			Insert(from,(from+to)/2,item);
		else
			Insert((from+to)/2+(from+to)%2,to,item);
	}
};


struct EnumPriceList
{
	double price;
	ulong tkt;
};
struct EnumMyPriceList
{
	EnumPriceList list[10000];
	int amount;
	EnumMyPriceList()
	{
		amount = 0;
	}
	void Clear()
	{
		amount = 0;
	}
	void Add(double price,ulong tkt)
	{
		EnumPriceList b;
		b.price = price;
		b.tkt = tkt;
		amount++;
		Insert(0,amount-1,b);
	}
	void Insert(int from,int to,EnumPriceList &item)
	{
		if(to <1)
		{
			list[from] = item;
			return;
		}
		if(from == to)
		{
			EnumPriceList saveValue=list[from];
			for(int i=from;i<MathMin(amount-1,9999);i++)
			{
				EnumPriceList b = list[i+1];
				list[i+1] = saveValue;
				saveValue = b;
			}
			list[from] = item;
			return;
		}
		if(list[(from+to)/2].price>=item.price)
			Insert(from,(from+to)/2,item);
		else
			Insert((from+to)/2+(from+to)%2,to,item);
	}
};



EnumMyList listBuyFromAbove;
EnumMyList listSellFromAbove;
EnumMyList listBuy;
EnumMyList listSell;


EnumMyPriceList listPriceBuy;
EnumMyPriceList listPriceSell;

void CloseLosingTradesByPriceFromBalance(bool count = true)
{
	if(count)
	{
		if(MyPositionInfo.type == 0)
		{
			
			if(((MyPositionInfo.isMRT && MyPositionInfo.n != 1 
			|| MyPositionInfo.isMRT_AfterFilter 
			&& MyInfo.buyMRT_AfterFilter.activeAfter<=MyInfo.buyMRT_AfterFilter.firstOT[MyPositionInfo.index]
			|| MyPositionInfo.isMRT_AfterFilter && MyPositionInfo.n != 1)
			|| !MyPositionInfo.isMRT && !MyPositionInfo.isMRT_AfterFilter)
			&& MyPositionInfo.op > SymbolInfoDouble(Symbol(),SYMBOL_ASK)+m_DistanceFromCurrentToCloseTrades
			/*
			&&(CloseSecondaryByPrice && MyPositionInfo.nType == 2
			|| CloseThirdByPrice && MyPositionInfo.nType == 3
			|| MyPositionInfo.nType == 1)*/)
			{
				listPriceBuy.Add(MyPositionInfo.op,MyPositionInfo.tkt);
			}
		}
		else
		{
			if(((MyPositionInfo.isMRT && MyPositionInfo.n != 1 
			|| MyPositionInfo.isMRT_AfterFilter 
			&& MyInfo.sellMRT_AfterFilter.activeAfter<=MyInfo.sellMRT_AfterFilter.firstOT[MyPositionInfo.index]
			|| MyPositionInfo.isMRT_AfterFilter && MyPositionInfo.n != 1)
			|| !MyPositionInfo.isMRT && !MyPositionInfo.isMRT_AfterFilter)
			&& MyPositionInfo.op < SymbolInfoDouble(Symbol(),SYMBOL_BID)-m_DistanceFromCurrentToCloseTrades
			/*
			&&(CloseSecondaryByPrice && MyPositionInfo.nType == 2
			|| CloseThirdByPrice && MyPositionInfo.nType == 3
			|| MyPositionInfo.nType == 1)*/)
			{
				listPriceSell.Add(MyPositionInfo.op,MyPositionInfo.tkt);
			}
		}
		return;
	}
}
void CloseLosingTradesByPriceFromBalanceBuy()
{
   
	for(int i=listPriceBuy.amount-1;i>=0;i--)
   {
   	bool end = true;
   	if(PositionSelectByTicket(listPriceBuy.list[i].tkt))
   	{
   		double profit = PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
   		
         if((UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitBuy)+profit
         -PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100>0 || profit>0)
         {
            if(UseSavedProfitFrom)
               MyInfo.savedProfit+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
            else
         	   MyInfo.savedProfitBuy+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
            PrintLogs(__LINE__+" Close Fully Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeBuy,TIME_DATE|TIME_MINUTES)+" Saved Profit = "+MyInfo.savedProfitBuy
            +" Trade Profit = "+profit);
            MyPositionClose(PositionGetInteger(POSITION_TICKET));
            end = false;
            continue;
         }
         double closeLot = PositionGetDouble(POSITION_VOLUME)*(UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitBuy)/MathAbs(profit);
         if(closeLot>=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN))
         {
            if(UseSavedProfitFrom)
               MyInfo.savedProfit+=profit;
            else
         	   MyInfo.savedProfitBuy+=profit;
            PrintLogs(__LINE__+" Close Partialy Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeBuy,TIME_DATE|TIME_MINUTES)+" Saved Profit "+MyInfo.savedProfitBuy
            +" Trade Profit = "+profit);
            MyPartialClose(PositionGetInteger(POSITION_TICKET),MathMin(closeLot,PositionGetDouble(POSITION_VOLUME)));
            break;
         }
   	}
   	if(end)
   		break;
   }
}
	
void CloseLosingTradesByPriceFromBalanceSell()
{
	for(int i=0;i<listPriceSell.amount;i++)
   {
   	bool end = true;
   	if(PositionSelectByTicket(listPriceSell.list[i].tkt))
   	{
   		double profit = PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
         if((UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitSell)+profit
         -PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100>0 || profit>0)
         {
            if(UseSavedProfitFrom)
               MyInfo.savedProfit+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
            else
         	   MyInfo.savedProfitSell+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
            PrintLogs(__LINE__+" Close Fully Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeSell,TIME_DATE|TIME_MINUTES)+" Saved Profit = "+MyInfo.savedProfitSell
            +" Trade Profit = "+profit);
            MyPositionClose(PositionGetInteger(POSITION_TICKET));
            end = false;
            continue;
         }
         double closeLot = PositionGetDouble(POSITION_VOLUME)*(UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitSell)/MathAbs(profit);
         if(closeLot>=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN))
         {
            if(UseSavedProfitFrom)
               MyInfo.savedProfit+=profit;
            else
         	   MyInfo.savedProfitSell+=profit;
            PrintLogs(__LINE__+" Close Partialy Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeSell,TIME_DATE|TIME_MINUTES)+" Saved Profit "+MyInfo.savedProfitSell
            +" Trade Profit = "+profit);
            MyPartialClose(PositionGetInteger(POSITION_TICKET),MathMin(closeLot,PositionGetDouble(POSITION_VOLUME)));
            break;
         }
   	}
   	if(end)
   		break;
   }
}     
void CheckForCloseNthTradeFromAbove(bool count = true)
{
	if(count)
	{
		
		if(MyPositionInfo.type == 0)
		{
			if(MyInfo.buyMRT.lastOpenedT<MyPositionInfo.ot)
			{
				MyInfo.buyMRT.lastOpenedN = MyPositionInfo.n;
				MyInfo.buyMRT.lastOpenedT = MyPositionInfo.ot;
				return;
			}
			if(MyPositionInfo.n>1
			&& MyPositionInfo.n>=FromAboveN
			&& MyInfo.buyMRT.lastOpenedN != MyPositionInfo.n
			&& MyInfo.buyMRT.lastN-ToFromLastN>=MyPositionInfo.n
			&& MyInfo.buyMRT.lastN>=AfterNthTradeOpened)
			{
				if(MyPositionInfo.nType == 1)
            {
					listBuyFromAbove.Add(MyPositionInfo.n,MyPositionInfo.tkt,1);
            } 
				if(CloseSecondaryFromAbove
				&& MyPositionInfo.nType == 2)
				{
					listBuyFromAbove.Add(MyPositionInfo.n,MyPositionInfo.tkt,2);
				}
				if(CloseThirdFromAbove
				&& MyPositionInfo.nType == 3)
				{
					listBuyFromAbove.Add(MyPositionInfo.n,MyPositionInfo.tkt,3);
				}
			}
		}
		else
		{
			if(MyInfo.sellMRT.lastOpenedT<MyPositionInfo.ot)
			{
				MyInfo.sellMRT.lastOpenedN = MyPositionInfo.n;
				MyInfo.sellMRT.lastOpenedT = MyPositionInfo.ot;
				return;
			}
			if(MyPositionInfo.n>1
			&& MyPositionInfo.n>=FromAboveN
			&& MyInfo.sellMRT.lastOpenedN != MyPositionInfo.n
			&& MyInfo.sellMRT.lastN-ToFromLastN>=MyPositionInfo.n
			&& MyInfo.sellMRT.lastN>=AfterNthTradeOpened)
			{
				if(MyPositionInfo.nType == 1)
            {
					listSellFromAbove.Add(MyPositionInfo.n,MyPositionInfo.tkt,1);
            } 
				if(CloseSecondaryFromAbove
				&& MyPositionInfo.nType == 2)
				{
					listSellFromAbove.Add(MyPositionInfo.n,MyPositionInfo.tkt,2);
				}
				if(CloseThirdFromAbove
				&& MyPositionInfo.nType == 3)
				{
					listSellFromAbove.Add(MyPositionInfo.n,MyPositionInfo.tkt,3);
				}
			}
		}
		return;
	}
   
}
void CheckForCloseNthTradeFromAboveBuy()
{
   for(int i=0;i<listBuyFromAbove.amount;i++)
   {
   	bool end = true;
   	for(int j=1;j<4;j++)
   	{
	   	end = true;
	   	if(PositionSelectByTicket(listBuyFromAbove.list[i].tkt[j]))
	   	{
	   		double profit = PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
	         if((UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitBuy)+profit
            -PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100>0 || profit>0)
            {
               if(UseSavedProfitFrom)
                  MyInfo.savedProfit+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
               else
            	   MyInfo.savedProfitBuy+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
	            PrintLogs(__LINE__+" Close Fully Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
	            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeBuy,TIME_DATE|TIME_MINUTES)+" Saved Profit = "+MyInfo.savedProfitBuy
	            +" Trade Profit = "+profit);
	            MyPositionClose(PositionGetInteger(POSITION_TICKET));
	            end = false;
	            continue;
	         }
	         double closeLot = PositionGetDouble(POSITION_VOLUME)*(UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitBuy)/MathAbs(profit);
	         if(closeLot>=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN))
	         {
               if(UseSavedProfitFrom)
                  MyInfo.savedProfit+=profit;
               else
            	   MyInfo.savedProfitBuy+=profit;
	            PrintLogs(__LINE__+" Close Partialy Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
	            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeBuy,TIME_DATE|TIME_MINUTES)+" Saved Profit "+MyInfo.savedProfitBuy
	            +" Trade Profit = "+profit);
	            MyPartialClose(PositionGetInteger(POSITION_TICKET),MathMin(closeLot,PositionGetDouble(POSITION_VOLUME)));
	            break;
	         }
	   	}
   	}
   	if(end)
   		break;
   }
}
void CheckForCloseNthTradeFromAboveSell()
{
   for(int i=0;i<listSellFromAbove.amount;i++)
   {
   	bool end = true;
   	for(int j=1;j<4;j++)
   	{
	   	end = true;
	   	if(PositionSelectByTicket(listSellFromAbove.list[i].tkt[j]))
	   	{
	   		double profit = PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
	         if((UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitSell)+profit
            -PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100>0 || profit>0)
            {
               if(UseSavedProfitFrom)
                  MyInfo.savedProfit+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
               else
            	   MyInfo.savedProfitSell+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
	            PrintLogs(__LINE__+" Close Fully Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
	            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeSell,TIME_DATE|TIME_MINUTES)+" Saved Profit = "+MyInfo.savedProfitSell
	            +" Trade Profit = "+profit);
	            MyPositionClose(PositionGetInteger(POSITION_TICKET));
	            end=false;
	            continue;
	         }
	         double closeLot = PositionGetDouble(POSITION_VOLUME)*(UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitSell)/MathAbs(profit);
	         if(closeLot>=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN))
	         {
               if(UseSavedProfitFrom)
                  MyInfo.savedProfit+=profit;
               else
            	   MyInfo.savedProfitSell+=profit;
	            PrintLogs(__LINE__+" Close Partialy Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
	            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeSell,TIME_DATE|TIME_MINUTES)+" Saved Profit "+MyInfo.savedProfitSell
	            +" Trade Profit = "+profit);
	            MyPartialClose(PositionGetInteger(POSITION_TICKET),MathMin(closeLot,PositionGetDouble(POSITION_VOLUME)));
	            break;
	         }
         }
   	}
   	break;
   }
}
void CheckForCloseNthTrade(bool count = true)
{
	if(count)
	{
		if(MyPositionInfo.type == 0)
		{
			if(MyInfo.buyMRT.lastOpenedT<MyPositionInfo.ot)
			{
				MyInfo.buyMRT.lastOpenedN = MyPositionInfo.n;
				MyInfo.buyMRT.lastOpenedT = MyPositionInfo.ot;
				return;
			}
			if(MyInfo.buyMRT.lastN-FromLastN>=MyPositionInfo.n
			&& MyInfo.buyMRT.lastOpenedN != MyPositionInfo.n
			&& MyPositionInfo.n>1)
			{
				if(MyPositionInfo.nType == 1)
            {
					listBuy.Add(MyPositionInfo.n,MyPositionInfo.tkt,2);
            } 
				if(CloseSecondary
				&& MyPositionInfo.nType == 2)
				{
					listBuy.Add(MyPositionInfo.n,MyPositionInfo.tkt,2);
				}
				if(CloseThird
				&& MyPositionInfo.nType == 3)
            {
					listBuy.Add(MyPositionInfo.n,MyPositionInfo.tkt,3);
            }
			}
		}
		else
		{
			if(MyInfo.sellMRT.lastOpenedT<MyPositionInfo.ot)
			{
				MyInfo.sellMRT.lastOpenedN = MyPositionInfo.n;
				MyInfo.sellMRT.lastOpenedT = MyPositionInfo.ot;
				return;
			}
			if(MyInfo.sellMRT.lastN-FromLastN>=MyPositionInfo.n
			&& MyInfo.sellMRT.lastOpenedN != MyPositionInfo.n
			&& MyPositionInfo.n>1)
			{
				if(MyPositionInfo.nType == 1)
            {
					listSell.Add(MyPositionInfo.n,MyPositionInfo.tkt,1);
            } 
				if(CloseSecondary
				&& MyPositionInfo.nType == 2)
				{
					listSell.Add(MyPositionInfo.n,MyPositionInfo.tkt,2);
				}
				if(CloseThird
				&& MyPositionInfo.nType == 3)
            {
					listSell.Add(MyPositionInfo.n,MyPositionInfo.tkt,3);
            } 
			}
		}
		return;
	}
}
void CheckForCloseNthTradeBuy()
{
   for(int i=listBuy.amount-1;i>=0;i--)
   {
   	bool end = true;
   	for(int j=1;j<4;j++)
   	{
	   	end = true;
	   	if(PositionSelectByTicket(listBuy.list[i].tkt[j]))
	   	{
   
	   		double profit = PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
	         if((UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitBuy)+profit
            -PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100>0 || profit>0)
            {
               if(UseSavedProfitFrom)
                  MyInfo.savedProfit+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
               else
            	   MyInfo.savedProfitBuy+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
	            PrintLogs(__LINE__+" Close Fully Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
	            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeBuy,TIME_DATE|TIME_MINUTES)+" Saved Profit = "+MyInfo.savedProfitBuy
	            +" Trade Profit = "+profit);
	            MyPositionClose(PositionGetInteger(POSITION_TICKET));
	            end = false;
	            continue;
	         }
	         double closeLot = PositionGetDouble(POSITION_VOLUME)*(UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitBuy)/MathAbs(profit);
	         if(closeLot>=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN))
	         {
               if(UseSavedProfitFrom)
                  MyInfo.savedProfit+=profit;
               else
            	   MyInfo.savedProfitBuy+=profit;
	            PrintLogs(__LINE__+" Close Partialy Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
	            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeBuy,TIME_DATE|TIME_MINUTES)+" Saved Profit "+MyInfo.savedProfitBuy
	            +" Trade Profit = "+profit);
	            MyPartialClose(PositionGetInteger(POSITION_TICKET),MathMin(closeLot,PositionGetDouble(POSITION_VOLUME)));
	            break;
	         }
         }
   	}
   	if(end)
   	break;
   }
}
void CheckForCloseNthTradeSell()
{

   for(int i=listSell.amount-1;i>=0;i--)
   {
   	bool end = true;
   	for(int j=1;j<4;j++)
   	{
	   	end = true;
	   	if(PositionSelectByTicket(listSell.list[i].tkt[j]))
	   	{
	   		double profit = PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
	         if((UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitSell)+profit
            -PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100>0 || profit>0)
            {
               if(UseSavedProfitFrom)
                  MyInfo.savedProfit+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
               else
            	   MyInfo.savedProfitSell+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
	            PrintLogs(__LINE__+" Close Fully Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
	            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeSell,TIME_DATE|TIME_MINUTES)+" Saved Profit = "+MyInfo.savedProfitSell
	            +" Trade Profit = "+profit);
	            MyPositionClose(PositionGetInteger(POSITION_TICKET));
	            end = false;
	            continue;
	         }
	         double closeLot = PositionGetDouble(POSITION_VOLUME)*(UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitSell)/MathAbs(profit);
	         if(closeLot>=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN))
	         {
               if(UseSavedProfitFrom)
                  MyInfo.savedProfit+=profit;
               else
            	   MyInfo.savedProfitSell+=profit;
	            PrintLogs(__LINE__+" Close Partialy Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
	            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeSell,TIME_DATE|TIME_MINUTES)+" Saved Profit "+MyInfo.savedProfitSell
	            +" Trade Profit = "+profit);
	            MyPartialClose(PositionGetInteger(POSITION_TICKET),MathMin(closeLot,PositionGetDouble(POSITION_VOLUME)));
	            break;
	         }
         }
   	}
   	if(end)
      break;
   }
}
EnumMyList listBuyFromAbove_MRTAfterFilter[1000];
EnumMyList listSellFromAbove_MRTAfterFilter[1000];
EnumMyList listBuy_MRTAfterFilter[1000];
EnumMyList listSell_MRTAfterFilter[1000];





	
   
void CheckForCloseNthTradeFromAbove_MRTAfterFilter(bool count = true)
{
	if(count)
	{
		
		if(MyPositionInfo.type == 0)
		{
			if(MyInfo.buyMRT_AfterFilter.lastOpenedT[MyPositionInfo.index]<MyPositionInfo.ot)
			{
				MyInfo.buyMRT_AfterFilter.lastOpenedN[MyPositionInfo.index] = MyPositionInfo.n;
				MyInfo.buyMRT_AfterFilter.lastOpenedT[MyPositionInfo.index] = MyPositionInfo.ot;
				return;
			}
			if(MyPositionInfo.n>1
			&& MyPositionInfo.n>=FromAboveN_MRTAfterFilter
			&& MyInfo.buyMRT_AfterFilter.lastOpenedN[MyPositionInfo.index] != MyPositionInfo.n
			&& MyInfo.buyMRT_AfterFilter.lastN[MyPositionInfo.index]-ToFromLastN_MRTAfterFilter>=MyPositionInfo.n
			&& MyInfo.buyMRT_AfterFilter.lastN[MyPositionInfo.index]>=AfterNthTradeOpened_MRTAfterFilter)
			{
				if(MyPositionInfo.nType == 1)
            {
					listBuyFromAbove_MRTAfterFilter[MyPositionInfo.index].Add(MyPositionInfo.n,MyPositionInfo.tkt,1);
            } 
				if(CloseSecondaryFromAbove_MRTAfterFilter
				&& MyPositionInfo.nType == 2)
				{
					listBuyFromAbove_MRTAfterFilter[MyPositionInfo.index].Add(MyPositionInfo.n,MyPositionInfo.tkt,2);
				}
				if(CloseThirdFromAbove_MRTAfterFilter
				&& MyPositionInfo.nType == 3)
				{
					listBuyFromAbove_MRTAfterFilter[MyPositionInfo.index].Add(MyPositionInfo.n,MyPositionInfo.tkt,3);
				}
			}
		}
		else
		{
			if(MyInfo.sellMRT_AfterFilter.lastOpenedT[MyPositionInfo.index]<MyPositionInfo.ot)
			{
				MyInfo.sellMRT_AfterFilter.lastOpenedN[MyPositionInfo.index] = MyPositionInfo.n;
				MyInfo.sellMRT_AfterFilter.lastOpenedT[MyPositionInfo.index] = MyPositionInfo.ot;
				return;
			}
			if(MyPositionInfo.n>1
			&& MyPositionInfo.n>=FromAboveN_MRTAfterFilter
			&& MyInfo.sellMRT_AfterFilter.lastOpenedN[MyPositionInfo.index] != MyPositionInfo.n
			&& MyInfo.sellMRT_AfterFilter.lastN[MyPositionInfo.index]-ToFromLastN_MRTAfterFilter>=MyPositionInfo.n
			&& MyInfo.sellMRT_AfterFilter.lastN[MyPositionInfo.index]>=AfterNthTradeOpened_MRTAfterFilter)
			{
				if(MyPositionInfo.nType == 1)
            {
					listSellFromAbove_MRTAfterFilter[MyPositionInfo.index].Add(MyPositionInfo.n,MyPositionInfo.tkt,1);
            } 
				if(CloseSecondaryFromAbove_MRTAfterFilter
				&& MyPositionInfo.nType == 2)
				{
					listSellFromAbove_MRTAfterFilter[MyPositionInfo.index].Add(MyPositionInfo.n,MyPositionInfo.tkt,2);
				}
				if(CloseThirdFromAbove_MRTAfterFilter
				&& MyPositionInfo.nType == 3)
				{
					listSellFromAbove_MRTAfterFilter[MyPositionInfo.index].Add(MyPositionInfo.n,MyPositionInfo.tkt,3);
				}
			}
		}
		return;
	}
	
   
}

void CheckForCloseNthTradeFromAbove_MRTAfterFilterBuy()
{
   for(int k=1;k<1000;k++)
	{
		if(MyInfo.buyMRT_AfterFilter.lastIndex<k)
			break;
	   for(int i=0;i<listBuyFromAbove_MRTAfterFilter[k].amount;i++)
	   {
	   	bool end = true;
	   	for(int j=1;j<4;j++)
	   	{
		   	end = true;
		   	if(PositionSelectByTicket(listBuyFromAbove_MRTAfterFilter[k].list[i].tkt[j]))
		   	{
		   		double profit = PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
		         if((UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitBuy)+profit
               -PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100>0 || profit>0)
               {
                  if(UseSavedProfitFrom)
                     MyInfo.savedProfit+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
                  else
               	   MyInfo.savedProfitBuy+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
		            PrintLogs(__LINE__+" Close Fully Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
		            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeBuy,TIME_DATE|TIME_MINUTES)+" Saved Profit = "+MyInfo.savedProfitBuy
		            +" Trade Profit = "+profit);
		            MyPositionClose(PositionGetInteger(POSITION_TICKET));
		            end = false;
		            continue;
		         }
		         double closeLot = PositionGetDouble(POSITION_VOLUME)*(UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitBuy)/MathAbs(profit);
		         if(closeLot>=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN))
		         {
                  if(UseSavedProfitFrom)
                     MyInfo.savedProfit+=profit;
                  else
               	   MyInfo.savedProfitBuy+=profit;
		            PrintLogs(__LINE__+" Close Partialy Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
		            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeBuy,TIME_DATE|TIME_MINUTES)+" Saved Profit "+MyInfo.savedProfitBuy
		            +" Trade Profit = "+profit);
		            MyPartialClose(PositionGetInteger(POSITION_TICKET),MathMin(closeLot,PositionGetDouble(POSITION_VOLUME)));
		            break;
		         }
		   	}
	   	}
	   	if(end)
	   		break;
	   }
   }
}

void CheckForCloseNthTradeFromAbove_MRTAfterFilterSell()
{
   for(int k=1;k<1000;k++)
	{
		if(MyInfo.sellMRT_AfterFilter.lastIndex<k)
			break;
	   for(int i=0;i<listSellFromAbove_MRTAfterFilter[k].amount;i++)
	   {
	   	bool end = true;
	   	for(int j=1;j<4;j++)
	   	{
		   	end = true;
		   	if(PositionSelectByTicket(listSellFromAbove_MRTAfterFilter[k].list[i].tkt[j]))
		   	{
		   		double profit = PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
		         if((UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitSell)+profit
               -PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100>0 || profit>0)
               {
                  if(UseSavedProfitFrom)
                     MyInfo.savedProfit+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
                  else
               	   MyInfo.savedProfitSell+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
		            PrintLogs(__LINE__+" Close Fully Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
		            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeSell,TIME_DATE|TIME_MINUTES)+" Saved Profit = "+MyInfo.savedProfitSell
		            +" Trade Profit = "+profit);
		            MyPositionClose(PositionGetInteger(POSITION_TICKET));
		            end=false;
		            continue;
		         }
		         double closeLot = PositionGetDouble(POSITION_VOLUME)*(UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitSell)/MathAbs(profit);
		         if(closeLot>=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN))
		         {
                  if(UseSavedProfitFrom)
                     MyInfo.savedProfit+=profit;
                  else
               	   MyInfo.savedProfitSell+=profit;
		            PrintLogs(__LINE__+" Close Partialy Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
		            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeSell,TIME_DATE|TIME_MINUTES)+" Saved Profit "+MyInfo.savedProfitSell
		            +" Trade Profit = "+profit);
		            MyPartialClose(PositionGetInteger(POSITION_TICKET),MathMin(closeLot,PositionGetDouble(POSITION_VOLUME)));
		            break;
		         }
	         }
	   	}
	   	break;
	   }
   }
}
void CheckForCloseNthTrade_MRTAfterFilter(bool count = true)
{
	if(count)
	{
		if(MyPositionInfo.type == 0)
		{
			if(MyInfo.buyMRT_AfterFilter.lastOpenedT[MyPositionInfo.index]<MyPositionInfo.ot)
			{
				MyInfo.buyMRT_AfterFilter.lastOpenedN[MyPositionInfo.index] = MyPositionInfo.n;
				MyInfo.buyMRT_AfterFilter.lastOpenedT[MyPositionInfo.index] = MyPositionInfo.ot;
				return;
			}
			if(MyInfo.buyMRT_AfterFilter.lastN[MyPositionInfo.index]-FromLastN_MRTAfterFilter>=MyPositionInfo.n
			&& MyInfo.buyMRT_AfterFilter.lastOpenedN[MyPositionInfo.index] != MyPositionInfo.n
			&& MyPositionInfo.n>1)
			{
				if(MyPositionInfo.nType == 1)
            {
					listBuy_MRTAfterFilter[MyPositionInfo.index].Add(MyPositionInfo.n,MyPositionInfo.tkt,2);
            } 
				if(CloseSecondary_MRTAfterFilter
				&& MyPositionInfo.nType == 2)
				{
					listBuy_MRTAfterFilter[MyPositionInfo.index].Add(MyPositionInfo.n,MyPositionInfo.tkt,2);
				}
				if(CloseThird_MRTAfterFilter
				&& MyPositionInfo.nType == 3)
            {
					listBuy_MRTAfterFilter[MyPositionInfo.index].Add(MyPositionInfo.n,MyPositionInfo.tkt,3);
            }
			}
		}
		else
		{
			if(MyInfo.sellMRT_AfterFilter.lastOpenedT[MyPositionInfo.index]<MyPositionInfo.ot)
			{
				MyInfo.sellMRT_AfterFilter.lastOpenedN[MyPositionInfo.index] = MyPositionInfo.n;
				MyInfo.sellMRT_AfterFilter.lastOpenedT[MyPositionInfo.index] = MyPositionInfo.ot;
				return;
			}
			if(MyInfo.sellMRT_AfterFilter.lastN[MyPositionInfo.index]-FromLastN_MRTAfterFilter>=MyPositionInfo.n
			&& MyInfo.sellMRT_AfterFilter.lastOpenedN[MyPositionInfo.index] != MyPositionInfo.n
			&& MyPositionInfo.n>1)
			{
				if(MyPositionInfo.nType == 1)
            {
					listSell_MRTAfterFilter[MyPositionInfo.index].Add(MyPositionInfo.n,MyPositionInfo.tkt,1);
            } 
				if(CloseSecondary_MRTAfterFilter
				&& MyPositionInfo.nType == 2)
				{
					listSell_MRTAfterFilter[MyPositionInfo.index].Add(MyPositionInfo.n,MyPositionInfo.tkt,2);
				}
				if(CloseThird_MRTAfterFilter
				&& MyPositionInfo.nType == 3)
            {
					listSell_MRTAfterFilter[MyPositionInfo.index].Add(MyPositionInfo.n,MyPositionInfo.tkt,3);
            } 
			}
		}
		return;
	}
	
	   
}

void CheckForCloseNthTrade_MRTAfterFilterBuy()
{
   for(int k=1;k<1000;k++)
	{
		if(MyInfo.buyMRT_AfterFilter.lastIndex<k)
			break;
	   for(int i=listBuy_MRTAfterFilter[k].amount;i>=0;i--)
	   {
	   	bool end = true;
	   	for(int j=1;j<4;j++)
	   	{
		   	end = true;
		   	if(PositionSelectByTicket(listBuy_MRTAfterFilter[k].list[i].tkt[j]))
		   	{
	   
		   		double profit = PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
		         if((UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitBuy)+profit
               -PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100>0 || profit>0)
               {
                  if(UseSavedProfitFrom)
                     MyInfo.savedProfit+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
                  else
               	   MyInfo.savedProfitBuy+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
		            PrintLogs(__LINE__+" Close Fully Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
		            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeBuy,TIME_DATE|TIME_MINUTES)+" Saved Profit = "+MyInfo.savedProfitBuy
		            +" Trade Profit = "+profit);
		            MyPositionClose(PositionGetInteger(POSITION_TICKET));
		            end = false;
		            continue;
		         }
		         double closeLot = PositionGetDouble(POSITION_VOLUME)*(UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitBuy)/MathAbs(profit);
		         if(closeLot>=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN))
		         {
                  if(UseSavedProfitFrom)
                     MyInfo.savedProfit+=profit;
                  else
               	   MyInfo.savedProfitBuy+=profit;
		            PrintLogs(__LINE__+" Close Partialy Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
		            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeBuy,TIME_DATE|TIME_MINUTES)+" Saved Profit "+MyInfo.savedProfitBuy
		            +" Trade Profit = "+profit);
		            MyPartialClose(PositionGetInteger(POSITION_TICKET),MathMin(closeLot,PositionGetDouble(POSITION_VOLUME)));
		            break;
		         }
	         }
	   	}
	   	if(end)
	   	break;
	   }
	}
}
void CheckForCloseNthTrade_MRTAfterFilterSell()
{
   for(int k=1;k<1000;k++)
	{
		if(MyInfo.sellMRT_AfterFilter.lastIndex<k)
			break;
	   for(int i=listSell_MRTAfterFilter[k].amount;i>=0;i--)
	   {
	   	bool end = true;
	   	for(int j=1;j<4;j++)
	   	{
		   	end = true;
		   	if(PositionSelectByTicket(listSell_MRTAfterFilter[k].list[i].tkt[j]))
		   	{
		   		double profit = PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
		         if((UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitSell)+profit
               -PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100>0 || profit>0)
               {
                  if(UseSavedProfitFrom)
                     MyInfo.savedProfit+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
                  else
               	   MyInfo.savedProfitSell+=profit-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
		            PrintLogs(__LINE__+" Close Fully Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
		            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeSell,TIME_DATE|TIME_MINUTES)+" Saved Profit = "+MyInfo.savedProfitSell
		            +" Trade Profit = "+profit);
		            MyPositionClose(PositionGetInteger(POSITION_TICKET));
		            end = false;
		            continue;
		         }
		         double closeLot = PositionGetDouble(POSITION_VOLUME)*(UseSavedProfitFrom?MyInfo.savedProfit:MyInfo.savedProfitSell)/MathAbs(profit);
		         if(closeLot>=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN))
		         {
                  if(UseSavedProfitFrom)
                     MyInfo.savedProfit+=profit;
                  else
               	   MyInfo.savedProfitSell+=profit;
		            PrintLogs(__LINE__+" Close Partialy Tkt = "+PositionGetInteger(POSITION_TICKET)+" Volume = "+
		            PositionGetDouble(POSITION_VOLUME)+" from "+TimeToString(MyInfo.startTimeSell,TIME_DATE|TIME_MINUTES)+" Saved Profit "+MyInfo.savedProfitSell
		            +" Trade Profit = "+profit);
		            MyPartialClose(PositionGetInteger(POSITION_TICKET),MathMin(closeLot,PositionGetDouble(POSITION_VOLUME)));
		            break;
		         }
	         }
	   	}
	   	if(end)
	      break;
	   }
	}
}
int GetMRTIndex(string txt)
{
   return StringToInteger(StringSubstr(txt,StringFind(txt,"^")+1));
}
int GetMRTN(string txt)
{
   return StringToInteger(StringSubstr(txt,StringFind(txt,"=")+1,StringFind(txt,"^")-StringFind(txt,"=")-1));
}
int GetMRTType(string txt)
{
   return StringToInteger(StringSubstr(txt,0,StringFind(txt,"=")));
}


int GetMRTAfterFilterIndex(string txt)
{
   return StringToInteger(StringSubstr(txt,StringFind(txt,"^")+1));
}
int GetMRTAfterFilterN(string txt)
{
   return StringToInteger(StringSubstr(txt,StringFind(txt,"@")+1,StringFind(txt,"^")-StringFind(txt,"@")-1));
}
int GetMRTAfterFilterType(string txt)
{
   return StringToInteger(StringSubstr(txt,0,StringFind(txt,"@")));
}

void CheckForOpenFilterMRT(bool count = true)
{
	if(!FilterEffect 
	|| !UseMRT_AfterFilter)
		return;
	if(count)
	{
      if(MyPositionInfo.type == 0)
      {
      	MyInfo.buyMRT_AfterFilter.mrtCycle[MyPositionInfo.index] = 1;
      	MyInfo.buyMRT_AfterFilter.lastIndex = MathMax(MyPositionInfo.index,MyInfo.buyMRT_AfterFilter.lastIndex);
      	if(MyPositionInfo.isLock)
      	{
      		MyInfo.buyMRT_AfterFilter.lockLot[MyPositionInfo.index] = MyPositionInfo.lotSize;
      		MyInfo.buyMRT_AfterFilter.lockTkt[MyPositionInfo.index] = MyPositionInfo.tkt;
      		MyInfo.buyMRT_AfterFilter.lockProfit[MyPositionInfo.index] = MyPositionInfo.orderProfit;
      		
      	}
      	else
      	{
      		if(MyPositionInfo.nType == 1 && MyPositionInfo.n>0)
      			MyInfo.buyMRT_AfterFilter.isOpen1[MyPositionInfo.index][MyPositionInfo.n] = MyPositionInfo.op;
      		if(MyPositionInfo.nType == 2 && MyPositionInfo.n>0)
      			MyInfo.buyMRT_AfterFilter.isOpen2[MyPositionInfo.index][MyPositionInfo.n] = MyPositionInfo.op;
      		if(MyPositionInfo.nType == 3 && MyPositionInfo.n>0)
      			MyInfo.buyMRT_AfterFilter.isOpen3[MyPositionInfo.index][MyPositionInfo.n] = MyPositionInfo.op;
      			
      		if(MyPositionInfo.n == 1 && MyInfo.buyMRT_AfterFilter.lastOT < MyPositionInfo.ot)
      			MyInfo.buyMRT_AfterFilter.lastOT = MyPositionInfo.ot;
      	   if(MyPositionInfo.n == 1)
      	   {
      	      MyInfo.buyMRT_AfterFilter.firstOT[MyPositionInfo.index] = MyPositionInfo.ot;
		         mrtAfterFilterOTListBuy.Add(MyPositionInfo.ot,MyPositionInfo.index);
      	   }
      		MyInfo.buyMRT_AfterFilter.typeConfirmed[MyPositionInfo.index] = true;
      		
		      MyInfo.buyMRT_AfterFilter.profit[MyPositionInfo.index]+=MyPositionInfo.orderProfit;
		      MyInfo.buyMRT_AfterFilter.lotSum[MyPositionInfo.index]+=MyPositionInfo.lotSize;
		      MyInfo.buyMRT_AfterFilter.opSum[MyPositionInfo.index]+=MyPositionInfo.lotSize*MyPositionInfo.op;
		      
		      if(MyInfo.buyMRT_AfterFilter.lastN[MyPositionInfo.index] < MyPositionInfo.n)
		      {
		      	MyInfo.buyMRT_AfterFilter.lastOP[MyPositionInfo.index] = MyPositionInfo.op;
		         MyInfo.buyMRT_AfterFilter.lastN[MyPositionInfo.index] = MyPositionInfo.n;
		      }	
		      

		      if(MyInfo.buyMRT_AfterFilter.positiveLastN[MyPositionInfo.index] == 0
		      && MyPositionInfo.n == 1)
		      {
		      	MyInfo.buyMRT_AfterFilter.positiveOP[MyPositionInfo.index] = MyPositionInfo.op;
		      }
		      if(MyInfo.buyMRT_AfterFilter.positiveLastN[MyPositionInfo.index] > MyPositionInfo.n)
		      {
		      	MyInfo.buyMRT_AfterFilter.positiveOP[MyPositionInfo.index] = MyPositionInfo.op;
		         MyInfo.buyMRT_AfterFilter.positiveLastN[MyPositionInfo.index] = MyPositionInfo.n;
		      }
      	}
      }
      else
      {
      	MyInfo.sellMRT_AfterFilter.mrtCycle[MyPositionInfo.index] = 1;
      	MyInfo.sellMRT_AfterFilter.lastIndex = MathMax(MyPositionInfo.index,MyInfo.sellMRT_AfterFilter.lastIndex);
      	if(MyPositionInfo.isLock)
      	{
      		MyInfo.sellMRT_AfterFilter.lockLot[MyPositionInfo.index] = MyPositionInfo.lotSize;
      		MyInfo.sellMRT_AfterFilter.lockTkt[MyPositionInfo.index] = MyPositionInfo.tkt;
      		MyInfo.sellMRT_AfterFilter.lockProfit[MyPositionInfo.index] = MyPositionInfo.orderProfit;
      		
      	}
      	else
      	{
      		
      		if(MyPositionInfo.nType == 1 && MyPositionInfo.n>0)
      			MyInfo.sellMRT_AfterFilter.isOpen1[MyPositionInfo.index][MyPositionInfo.n] = MyPositionInfo.op;
      		if(MyPositionInfo.nType == 2 && MyPositionInfo.n>0)
      			MyInfo.sellMRT_AfterFilter.isOpen2[MyPositionInfo.index][MyPositionInfo.n] = MyPositionInfo.op;
      		if(MyPositionInfo.nType == 3 && MyPositionInfo.n>0)
      			MyInfo.sellMRT_AfterFilter.isOpen3[MyPositionInfo.index][MyPositionInfo.n] = MyPositionInfo.op;
      			
      		if(MyPositionInfo.n == 1 && MyInfo.sellMRT_AfterFilter.lastOT < MyPositionInfo.ot)
      			MyInfo.sellMRT_AfterFilter.lastOT = MyPositionInfo.ot;
      		MyInfo.sellMRT_AfterFilter.typeConfirmed[MyPositionInfo.index] = true;
      		
		      MyInfo.sellMRT_AfterFilter.profit[MyPositionInfo.index]+=MyPositionInfo.orderProfit;
		      MyInfo.sellMRT_AfterFilter.lotSum[MyPositionInfo.index]+=MyPositionInfo.lotSize;
		      MyInfo.sellMRT_AfterFilter.opSum[MyPositionInfo.index]+=MyPositionInfo.lotSize*MyPositionInfo.op;
		      
		      if(MyInfo.sellMRT_AfterFilter.lastN[MyPositionInfo.index] < MyPositionInfo.n)
		      {
		      	MyInfo.sellMRT_AfterFilter.lastOP[MyPositionInfo.index] = MyPositionInfo.op;
		         MyInfo.sellMRT_AfterFilter.lastN[MyPositionInfo.index] = MyPositionInfo.n;
		      }	
		      if(MyPositionInfo.n == 1)
      	   {
      	      MyInfo.sellMRT_AfterFilter.firstOT[MyPositionInfo.index] = MyPositionInfo.ot;
		         mrtAfterFilterOTListSell.Add(MyPositionInfo.ot,MyPositionInfo.index);
      	   }
      	   
		      if(MyInfo.sellMRT_AfterFilter.positiveLastN[MyPositionInfo.index] == 0
		      && MyPositionInfo.n == 1)
		      {
		      	MyInfo.sellMRT_AfterFilter.positiveOP[MyPositionInfo.index] = MyPositionInfo.op;
		      }
		      if(MyInfo.sellMRT_AfterFilter.positiveLastN[MyPositionInfo.index] > MyPositionInfo.n)
		      {
		      	MyInfo.sellMRT_AfterFilter.positiveOP[MyPositionInfo.index] = MyPositionInfo.op;
		         MyInfo.sellMRT_AfterFilter.positiveLastN[MyPositionInfo.index] = MyPositionInfo.n;
		      }
      	}
      }
      
      if(UseBE_LockAfterFilter 
      && MyPositionInfo.isLock)
      {
         if(MyPositionInfo.sl==0 
         &&(MyPositionInfo.orderType == 0 && MyPositionInfo.op+m_BEAfter_LockMRTAfterFilter<SymbolInfoDouble(Symbol(),SYMBOL_BID)
         || MyPositionInfo.orderType == 1 && MyPositionInfo.op-m_BEAfter_LockMRTAfterFilter>SymbolInfoDouble(Symbol(),SYMBOL_ASK)))
         {
				GlobalVariableSet(prefix+MyPositionInfo.index+"lockCloseReason"+(MyPositionInfo.type?"sell":"buy"),0);
            myTrade.PositionModify(MyPositionInfo.tkt,MyPositionInfo.op+m_BEAt_LockMRTAfterFilter*(MyPositionInfo.orderType?-1:1),0);
         }
      }
	   return;      
   }
   MyInfo.buyMRT_AfterFilter.activeAfter = mrtAfterFilterOTListBuy.list[ActiveOnlyLastCycles].ot;
   if(ActiveOnlyLastCycles>mrtAfterFilterOTListBuy.amount)
      MyInfo.buyMRT_AfterFilter.activeAfter = 0;
   
   MyInfo.sellMRT_AfterFilter.activeAfter = mrtAfterFilterOTListSell.list[ActiveOnlyLastCycles].ot;
   if(ActiveOnlyLastCycles>mrtAfterFilterOTListSell.amount)
      MyInfo.sellMRT_AfterFilter.activeAfter = 0;
      
   CheckForOpen_MRTAfterFilter(0,MyInfo.buyMRT_AfterFilter);   
   CheckForOpen_MRTAfterFilter(1,MyInfo.sellMRT_AfterFilter);   
}

void ReOpenMRTTrades()
{
	for(int i=2;i<1000;i++)
	{
		if(AddSecondaryTrade
	   && MyInfo.buyMRT.isOpen1[i] != 0
		&& MyInfo.buyMRT.isOpen2[i] == 0
		&&(!StopOpenNewTradesAfterHedge || MyInfo.buyHedge.tkt==0)
		&& SymbolInfoDouble(Symbol(),SYMBOL_ASK)<MyInfo.buyMRT.isOpen1[i])
		{
			double startLot = MyInfo.lotBuy;
	      double lot = startLot+LotIncrementValue*i;
	      if(LotIncreaseType == 0)
	         lot = startLot*MathPow(LotIncrementValue,i);
			if(MaxLotStartAtLevel<=i)
   		{
   			
   	      double maxLot = (LotSizeCalculationBalance*MaxLotAtLevel/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
   	      if(MaxLotAtLevelType)  
   	         maxLot = MaxLotAtLevel;
   	      lot = MathMin(maxLot,lot);
   		}        
			lot = lot*SecondaryOrderPct/100;
		   double tp = SymbolInfoDouble(Symbol(),SYMBOL_ASK) + m_SecondaryTPAmount;
		   MyInfo.buyMRT.isOpen2[i] = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
		   MyPositionOpen(Symbol(),ORDER_TYPE_BUY,lot,SymbolInfoDouble(Symbol(),SYMBOL_ASK),0,tp,"2="+i+"^"+1,MagicMRT);
		   PrintLogs(__LINE__+" REOPEN BUY Type 2");
	   }
	   if(AddSecondaryTrade
	   && MyInfo.sellMRT.isOpen1[i] != 0
		&& MyInfo.sellMRT.isOpen2[i] == 0
		&&(!StopOpenNewTradesAfterHedge || MyInfo.sellHedge.tkt==0)
		&& SymbolInfoDouble(Symbol(),SYMBOL_BID)>MyInfo.sellMRT.isOpen1[i])
		{
			double startLot = MyInfo.lotSell;
	      double lot = startLot+LotIncrementValue*i;
	      if(LotIncreaseType == 0)
	         lot = startLot*MathPow(LotIncrementValue,i);
			      
			if(MaxLotStartAtLevel<=i)
   		{
   			
   	      double maxLot = (LotSizeCalculationBalance*MaxLotAtLevel/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
   	      if(MaxLotAtLevelType)  
   	         maxLot = MaxLotAtLevel;
   	      lot = MathMin(maxLot,lot);
   		}      
			lot = lot*SecondaryOrderPct/100;
		   double tp = SymbolInfoDouble(Symbol(),SYMBOL_BID) - m_SecondaryTPAmount;
		   MyInfo.buyMRT.isOpen2[i] = SymbolInfoDouble(Symbol(),SYMBOL_BID);
		   MyPositionOpen(Symbol(),ORDER_TYPE_SELL,lot,SymbolInfoDouble(Symbol(),SYMBOL_BID),0,tp,"2="+i+"^"+1,MagicMRT);
		   PrintLogs(__LINE__+" REOPEN SELL Type 2");
	   }
	   
	   if(AddThirdTrade)
	   {
	   	if(MyInfo.buyMRT.isOpen1[i] != 0
			&& MyInfo.buyMRT.isOpen3[i] == 0
			&& MyInfo.buyMRT.lastN > i
		   &&(!StopOpenNewTradesAfterHedge || MyInfo.buyHedge.tkt==0)
			&& SymbolInfoDouble(Symbol(),SYMBOL_ASK)>MyInfo.buyMRT.isOpen1[i])
			{
				double startLot = MyInfo.lotBuy;
		      double lot = startLot+LotIncrementValue*i;
		      if(LotIncreaseType == 0)
		         lot = startLot*MathPow(LotIncrementValue,i);
				if(MaxLotStartAtLevel<=i)
      		{
      			
      	      double maxLot = (LotSizeCalculationBalance*MaxLotAtLevel/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
      	      if(MaxLotAtLevelType)  
      	         maxLot = MaxLotAtLevel;
      	      lot = MathMin(maxLot,lot);
      		}      
				lot = lot*ThirdTradePct/100;
		   	MyInfo.buyMRT.isOpen3[i] = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
			   MyPositionOpen(Symbol(),ORDER_TYPE_BUY,lot,SymbolInfoDouble(Symbol(),SYMBOL_ASK),0,0,"3="+i+"^"+1,MagicMRT);
			   PrintLogs(__LINE__+" REOPEN BUY Type 3");
			}
			
			if(MyInfo.sellMRT.isOpen1[i] != 0
			&& MyInfo.sellMRT.isOpen3[i] == 0
			&& MyInfo.sellMRT.lastN > i
		   &&(!StopOpenNewTradesAfterHedge || MyInfo.sellHedge.tkt==0)
			&& SymbolInfoDouble(Symbol(),SYMBOL_BID)<MyInfo.sellMRT.isOpen1[i])
			{
				double startLot = MyInfo.lotSell;
		      double lot = startLot+LotIncrementValue*i;
		      if(LotIncreaseType == 0)
		         lot = startLot*MathPow(LotIncrementValue,i);
				if(MaxLotStartAtLevel<=i)
      		{
      			
      	      double maxLot = (LotSizeCalculationBalance*MaxLotAtLevel/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
      	      if(MaxLotAtLevelType)  
      	         maxLot = MaxLotAtLevel;
      	      lot = MathMin(maxLot,lot);
      		}      
				lot = lot*ThirdTradePct/100;
		   	MyInfo.buyMRT.isOpen3[i] = SymbolInfoDouble(Symbol(),SYMBOL_BID);
			   MyPositionOpen(Symbol(),ORDER_TYPE_SELL,lot,SymbolInfoDouble(Symbol(),SYMBOL_BID),0,0,"3="+i+"^"+1,MagicMRT);
			   PrintLogs(__LINE__+" REOPEN SELL Type 3");
			}
	   }
	   for(int j=1;j<1000;j++)
	   {
	   	if(MyInfo.buyMRT_AfterFilter.lastIndex<i
	   	&& MyInfo.sellMRT_AfterFilter.lastIndex<i)
	   		break;
	   	if(AddSecondaryTrade_AfterFilter
	   	&& MyInfo.buyMRT_AfterFilter.mrtCycle[j] != 0
		   &&(!StopOpenNewTradesAfterHedge || MyInfo.buyHedge.tkt==0)
	   	&& MyInfo.buyMRT_AfterFilter.activeAfter<=MyInfo.buyMRT_AfterFilter.firstOT[i])
	   	{
	   		if(MyInfo.buyMRT_AfterFilter.isOpen1[j][i] != 0
				&& MyInfo.buyMRT_AfterFilter.isOpen2[j][i] == 0
				&& SymbolInfoDouble(Symbol(),SYMBOL_ASK)<MyInfo.buyMRT_AfterFilter.isOpen1[j][i])
				{
            	double startLot = GlobalVariableGet(prefix+j+"buyLot");
			      double lot = startLot+LotIncrementValue_AfterFilter*i;
			      if(LotIncreaseType_AfterFilter == 0)
			         lot = startLot*MathPow(LotIncrementValue_AfterFilter,i);
			      if(MaxLotStartAtLevel_AfterFilter<=i)
         		{
         			
         	      double maxLot = (LotSizeCalculationBalance*MaxLotAtLevel_AfterFilter/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
         	      if(MaxLotAtLevelType_AfterFilter)  
         	         maxLot = MaxLotAtLevel_AfterFilter;
         	      lot = MathMin(maxLot,lot);
         		}   
					lot = lot*SecondaryOrderPct_AfterFilter/100;
				   double tp = SymbolInfoDouble(Symbol(),SYMBOL_ASK) + m_SecondaryTPAmount_AfterFilter;
		   		MyInfo.buyMRT.isOpen2[i] = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
				   MyPositionOpen(Symbol(),ORDER_TYPE_BUY,lot,SymbolInfoDouble(Symbol(),SYMBOL_ASK),0,tp,"2@"+i+"^"+j,MagicMRT_AfterFilter);
				   PrintLogs(__LINE__+" REOPEN MRT AFTER FILTER BUY Type 2");
			   }
			   
			   if(AddThirdTrade_AfterFilter)
			   {
			   	if(MyInfo.buyMRT_AfterFilter.isOpen1[j][i] != 0
					&& MyInfo.buyMRT_AfterFilter.isOpen3[j][i] == 0
					&& MyInfo.buyMRT_AfterFilter.lastN[j] > i
		         &&(!StopOpenNewTradesAfterHedge || MyInfo.buyHedge.tkt==0)
					&& SymbolInfoDouble(Symbol(),SYMBOL_ASK)>MyInfo.buyMRT_AfterFilter.isOpen1[j][i])
					{
            		double startLot = GlobalVariableGet(prefix+j+"buyLot");
				      double lot = startLot+LotIncrementValue_AfterFilter*i;
				      if(LotIncreaseType_AfterFilter == 0)
				         lot = startLot*MathPow(LotIncrementValue_AfterFilter,i);
						if(MaxLotStartAtLevel_AfterFilter<=i)
            		{
            			
            	      double maxLot = (LotSizeCalculationBalance*MaxLotAtLevel_AfterFilter/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
            	      if(MaxLotAtLevelType_AfterFilter)  
            	         maxLot = MaxLotAtLevel_AfterFilter;
            	      lot = MathMin(maxLot,lot);
            		}        
						lot = lot*ThirdTradePct_AfterFilter/100;
		   			MyInfo.buyMRT.isOpen3[i] = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
					   MyPositionOpen(Symbol(),ORDER_TYPE_BUY,lot,SymbolInfoDouble(Symbol(),SYMBOL_ASK),0,0,"3@"+i+"^"+j,MagicMRT_AfterFilter);
					   PrintLogs(__LINE__+" REOPEN BUY Type 3");
					}
			   }
	   	}
	   	/////
	   	if(AddSecondaryTrade_AfterFilter
	   	&& MyInfo.sellMRT_AfterFilter.mrtCycle[j] != 0
	   	&& MyInfo.sellMRT_AfterFilter.activeAfter<=MyInfo.sellMRT_AfterFilter.firstOT[i])
	   	{
	   		if(MyInfo.sellMRT_AfterFilter.isOpen1[j][i] != 0
				&& MyInfo.sellMRT_AfterFilter.isOpen2[j][i] == 0
		      &&(!StopOpenNewTradesAfterHedge || MyInfo.sellHedge.tkt==0)
				&& SymbolInfoDouble(Symbol(),SYMBOL_BID)>MyInfo.sellMRT_AfterFilter.isOpen1[j][i])
				{
            	double startLot = GlobalVariableGet(prefix+j+"sellLot");
			      double lot = startLot+LotIncrementValue_AfterFilter*i;
			      if(LotIncreaseType_AfterFilter == 0)
			         lot = startLot*MathPow(LotIncrementValue_AfterFilter,i);
			      if(MaxLotStartAtLevel_AfterFilter<=i)
         		{
         			
         	      double maxLot = (LotSizeCalculationBalance*MaxLotAtLevel_AfterFilter/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
         	      if(MaxLotAtLevelType_AfterFilter)  
         	         maxLot = MaxLotAtLevel_AfterFilter;
         	      lot = MathMin(maxLot,lot);
         		}    
					lot = lot*SecondaryOrderPct_AfterFilter/100;
				   double tp = SymbolInfoDouble(Symbol(),SYMBOL_BID) - m_SecondaryTPAmount_AfterFilter;
		   		MyInfo.buyMRT.isOpen2[i] = SymbolInfoDouble(Symbol(),SYMBOL_BID);
				   MyPositionOpen(Symbol(),ORDER_TYPE_BUY,lot,SymbolInfoDouble(Symbol(),SYMBOL_BID),0,tp,"2@"+i+"^"+j,MagicMRT_AfterFilter);
				   PrintLogs(__LINE__+" REOPEN MRT AFTER FILTER BUY Type 2");
			   }
			   
			   if(AddThirdTrade_AfterFilter)
			   {
			   	if(MyInfo.sellMRT_AfterFilter.isOpen1[j][i] != 0
					&& MyInfo.sellMRT_AfterFilter.isOpen3[j][i] == 0
					&& MyInfo.sellMRT_AfterFilter.lastN[j] > i
		         &&(!StopOpenNewTradesAfterHedge || MyInfo.sellHedge.tkt==0)
					&& SymbolInfoDouble(Symbol(),SYMBOL_BID)<MyInfo.sellMRT_AfterFilter.isOpen1[j][i])
					{
            		double startLot = GlobalVariableGet(prefix+j+"sellLot");
				      double lot = startLot+LotIncrementValue_AfterFilter*i;
				      if(LotIncreaseType_AfterFilter == 0)
				         lot = startLot*MathPow(LotIncrementValue_AfterFilter,i);
						if(MaxLotStartAtLevel_AfterFilter<=i)
            		{
            			
            	      double maxLot = (LotSizeCalculationBalance*MaxLotAtLevel_AfterFilter/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
            	      if(MaxLotAtLevelType_AfterFilter)  
            	         maxLot = MaxLotAtLevel_AfterFilter;
            	      lot = MathMin(maxLot,lot);
            		}      
						lot = lot*ThirdTradePct_AfterFilter/100;
		   			MyInfo.buyMRT.isOpen3[i] = SymbolInfoDouble(Symbol(),SYMBOL_BID);
					   MyPositionOpen(Symbol(),ORDER_TYPE_SELL,lot,SymbolInfoDouble(Symbol(),SYMBOL_BID),0,0,"3@"+i+"^"+j,MagicMRT_AfterFilter);
					   PrintLogs(__LINE__+" REOPEN BUY Type 3");
					}
			   }
	   	}
	   }
	}
}

struct EnumDTList
{
	datetime ot;
	int index;
};
struct EnumMyDTList
{
	EnumDTList list[1000];
	int amount;
	EnumMyDTList()
	{
		amount = 0;
	}
	void Clear()
	{
		amount = 0;
	}
	void Add(datetime ot,int index)
	{
		EnumDTList b;
		b.ot = ot;
		b.index = index;
		amount++;
		Insert(0,amount-1,b);
	}
	void Insert(int from,int to,EnumDTList &item)
	{
		if(to <1)
		{
			list[from] = item;
			return;
		}
		if(from == to)
		{
			EnumDTList saveValue=list[from];
			for(int i=from;i<MathMin(amount-1,999);i++)
			{
				EnumDTList b = list[i+1];
				list[i+1] = saveValue;
				saveValue = b;
			}
			list[from] = item;
			return;
		}
		if(list[(from+to)/2].ot<=item.ot)
			Insert(from,(from+to)/2,item);
		else
			Insert((from+to)/2+(from+to)%2,to,item);
	}
};
EnumMyDTList mrtAfterFilterOTListBuy;
EnumMyDTList mrtAfterFilterOTListSell;
void CheckForOpen_MRTAfterFilter(int type,EnumMyMRT_AfterFilterInfo &mrtAfterFilter)
{
	bool filter = !MyInfo.endAddTradesSell;
	if(type == 0)
		filter = !MyInfo.endAddTradesBuy;
   if(UseBalanceToCloseCycle_MRTAfterFilter)
   {
      double add = 0;
      if(CloseBelowPreviousBalance_MRTAfterFilter == 1)
         add = BelowPreviousBalanceAmount;
      if(CloseBelowPreviousBalance_MRTAfterFilter == 2)
         add = (UseSavedProfitFrom?MyInfo.savedProfit:(type?MyInfo.savedProfitSell:MyInfo.savedProfitBuy))*BelowPreviousBalanceAmount/100;
      for(int i=(type?mrtAfterFilterOTListSell.amount:mrtAfterFilterOTListBuy.amount)-1;i>=0;i--)
      {
         if((UseSavedProfitFrom?MyInfo.savedProfit:(type?MyInfo.savedProfitSell:MyInfo.savedProfitBuy))+mrtAfterFilter.profit[(type?mrtAfterFilterOTListSell.list[i].index:mrtAfterFilterOTListBuy.list[i].index)]+add>0)
         {
            if(UseSavedProfitFrom)
            {
               MyInfo.savedProfit+=mrtAfterFilter.profit[(type?mrtAfterFilterOTListSell.list[i].index:mrtAfterFilterOTListBuy.list[i].index)];
            }
            else
            {
               if(type == 0)
                  MyInfo.savedProfitBuy+=mrtAfterFilter.profit[(type?mrtAfterFilterOTListSell.list[i].index:mrtAfterFilterOTListBuy.list[i].index)];
               else
                  MyInfo.savedProfitSell+=mrtAfterFilter.profit[(type?mrtAfterFilterOTListSell.list[i].index:mrtAfterFilterOTListBuy.list[i].index)];
            }
            
            CloseAllFilterMRT(type,(type?mrtAfterFilterOTListSell.list[i].index:mrtAfterFilterOTListBuy.list[i].index));
            PrintLogs(__LINE__+" Close Cycle From Balance index = "+(type?mrtAfterFilterOTListSell.list[i].index:mrtAfterFilterOTListBuy.list[i].index));
            continue;
         }
         break;
      }
   }
   
   for(int i=1;i<1000;i++)
   {
   	if(type == 0 && mrtAfterFilter.lastIndex<i
   	|| type == 1 && mrtAfterFilter.lastIndex<i)
   		break;
      if(mrtAfterFilter.activeAfter>mrtAfterFilter.firstOT[i])
         continue;
   	   
      if(mrtAfterFilter.mrtCycle[i] != 0 && mrtAfterFilter.typeConfirmed[i])
      {
         double op = mrtAfterFilter.lastOP[i] + (m_StartDistance_AfterFilter+m_DistanceIncrementValue_AfterFilter*mrtAfterFilter.lastN[i])*(type?1:-1);
         if(DistanceIncreaseType_AfterFilter == 0)
            op = mrtAfterFilter.lastOP[i] + m_StartDistance_AfterFilter*MathPow(DistanceIncrementValue_AfterFilter,mrtAfterFilter.lastN[i]-1)*(type?1:-1);
         if(MaxLevelAmount_AfterFilter>mrtAfterFilter.lastN[i]
         &&(filter
         &&(type == 0 && SymbolInfoDouble(Symbol(),SYMBOL_ASK)<op
         || type == 1 && SymbolInfoDouble(Symbol(),SYMBOL_BID)>op))
         &&(!StopOpenNewTradesAfterHedge 
         ||(type == 0 && MyInfo.buyHedge.tkt==0
         || type == 1 && MyInfo.sellHedge.tkt==0)))
         {
            double startLot = GlobalVariableGet(prefix+i+(type?"sellLot":"buyLot"));
            double lot = startLot+LotIncrementValue_AfterFilter*mrtAfterFilter.lastN[i];
            if(LotIncreaseType_AfterFilter == 0)
               lot = startLot*MathPow(LotIncrementValue_AfterFilter,mrtAfterFilter.lastN[i]);
				if(MaxLotStartAtLevel_AfterFilter<=mrtAfterFilter.lastN[i])
				{
			      double maxLot = (LotSizeCalculationBalance*MaxLotAtLevel_AfterFilter/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
			      if(MaxLotAtLevelType_AfterFilter)  
			         maxLot = MaxLotAtLevel_AfterFilter;
			      lot = MathMin(maxLot,lot);
				}
            MyPositionOpen(Symbol(),type?ORDER_TYPE_SELL:ORDER_TYPE_BUY,lot,SymbolInfoDouble(Symbol(),type?SYMBOL_BID:SYMBOL_ASK),0,0,"1@"+(mrtAfterFilter.lastN[i]+1)+"^"+i,MagicMRT_AfterFilter);
            
            lot=lot*SecondaryOrderPct_AfterFilter/100;
            double tp = SymbolInfoDouble(Symbol(),type?SYMBOL_BID:SYMBOL_ASK) + m_SecondaryTPAmount_AfterFilter*(type?-1:1);
            if(AddSecondaryTrade_AfterFilter)
            MyPositionOpen(Symbol(),type?ORDER_TYPE_SELL:ORDER_TYPE_BUY,lot,SymbolInfoDouble(Symbol(),type?SYMBOL_BID:SYMBOL_ASK),0,tp,"2@"+(mrtAfterFilter.lastN[i]+1)+"^"+i,MagicMRT_AfterFilter);
            PrintLogs(__LINE__+" ADD Trades on MRT After Filter index "+i);
         }
         
         int positiveN = MathAbs(mrtAfterFilter.positiveLastN[i]);
		   op = mrtAfterFilter.positiveOP[i] + (m_StartDistance_PS_AfterFilter+m_DistanceIncrementValue_PS_AfterFilter*positiveN)*(type?-1:1);
		   if(DistanceIncreaseType_PS == 0)
		      op = mrtAfterFilter.positiveOP[i] + m_StartDistance_PS_AfterFilter*MathPow(DistanceIncrementValue_PS_AfterFilter,positiveN-1)*(type?-1:1);
		   if(MaxLevelAmount_PS_AfterFilter>positiveN
   		&& filter
		   &&(type == 0 && SymbolInfoDouble(Symbol(),SYMBOL_ASK)>op && (!StopOpenAfterAVGOP || SymbolInfoDouble(Symbol(),SYMBOL_ASK)<MyInfo.buyMRT.avgPrice)
		   || type == 1 && SymbolInfoDouble(Symbol(),SYMBOL_BID)<op && (!StopOpenAfterAVGOP || SymbolInfoDouble(Symbol(),SYMBOL_BID)>MyInfo.buyMRT.avgPrice))
         &&(!StopOpenNewTradesAfterHedge 
         ||(type == 0 && MyInfo.buyHedge.tkt==0
         || type == 1 && MyInfo.sellHedge.tkt==0)))
		   {
		   	
		   	
				
            double startLot = GlobalVariableGet(prefix+i+(type?"sellLot":"buyLot"));
		      double lot = startLot+LotIncrementValue_PS_AfterFilter*positiveN;
		      
		      
				
		      if(LotIncreaseType_PS_AfterFilter == 0)
		         lot = startLot*MathPow(LotIncrementValue_PS_AfterFilter,positiveN);
		      if(MaxLotStartAtLevel_PS_AfterFilter<=MathAbs(positiveN))
				{
			      double maxLot = (LotSizeCalculationBalance*MaxLotAtLevel_PS_AfterFilter/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
			      if(MaxLotAtLevelType_PS_AfterFilter)  
			         maxLot = MaxLotAtLevel_PS_AfterFilter;
			      lot = MathMin(maxLot,lot);
				}
		      MyPositionOpen(Symbol(),type?ORDER_TYPE_SELL:ORDER_TYPE_BUY,lot,SymbolInfoDouble(Symbol(),type?SYMBOL_BID:SYMBOL_ASK),0,0,"1@"+((positiveN+1)*(-1))+"^"+i,MagicMRT_AfterFilter);
		      PrintLogs(__LINE__+" Add Positive Side");
		   }


         double avgPrice = mrtAfterFilter.opSum[i]/mrtAfterFilter.lotSum[i];
         double goal = (m_MRTTPAmount_AfterFilter)/Point()*mrtAfterFilter.lotSum[i]*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE);
         double avgTP = avgPrice+m_MRTTPAmount_AfterFilter*(type?(-1):1);
            
            
            
			double minusAmount = CloseLockMRTAfterFilterBelowAmount*(-1);
			if(CloseLockMRTAfterFilterBelowType)
				minusAmount = MyInfo.equity*CloseLockMRTAfterFilterBelowAmount/100*(-1);
				
         if((type == 0 && SymbolInfoDouble(Symbol(),SYMBOL_BID)>avgTP
         ||  type == 1 && SymbolInfoDouble(Symbol(),SYMBOL_ASK)<avgTP)
         && mrtAfterFilter.profit[i]>=goal
         && mrtAfterFilter.lockProfit[i]>minusAmount
         &&(UseSecondaryMRTInTP!=1 || UseSecondaryMRTInTP == 3 && i%2==0))
         {
            CloseAllFilterMRT(type,i);
            if(UseLockAfterFilterCapsule_MRTAfterFilter)
	         {
	         	mrtAfterFilter.profit[i]+=MakeLockCapsule(type,mrtAfterFilter.lockTkt[i],mrtAfterFilter.profit[i]);
	         }
            PrintLogs(__LINE__+" Close AT TP MRT After Filter index "+i+" type "+type);
            return;
         } 
			bool triggered = false;
			if(UseLockAfterFilterDDTrigger_MRTAfterFilter)
			{
				double lastDDTrigger = 0;
				if(GlobalVariableCheck(prefix+i+"lastDDTrigger"))
					lastDDTrigger = GlobalVariableGet(prefix+i+"lastDDTrigger");
						
				double dd = (MathAbs(mrtAfterFilter.profit[i]))/(type?MyInfo.previousEquitySell:MyInfo.previousEquityBuy)*100;
				if(UseLockAfterFilterDDTrigger_MRTAfterFilter == 2
				&& mrtAfterFilter.profit[i]<0
				&& dd>LockAfterFilterDDTriggerAmount_MRTAfterFilter
				&&(dd>lastDDTrigger+LockAfterFilterDDTriggerAmountStep_MRTAfterFilter || lastDDTrigger == 0))
					triggered = true;
				if(triggered)
		     	{
		     		lastDDTrigger = dd;
		     	}
		     	if(!triggered)
		     	{
					if(UseLockAfterFilterDDTrigger_MRTAfterFilter == 1
					&& mrtAfterFilter.profit[i]<LockAfterFilterDDTriggerAmount_MRTAfterFilter*(-1)
					&&(mrtAfterFilter.profit[i]<lastDDTrigger-LockAfterFilterDDTriggerAmountStep_MRTAfterFilter || lastDDTrigger == 0))
						triggered = true;
					if(triggered)
			     	{
			     		lastDDTrigger = mrtAfterFilter.profit[i];
			     	}
				}
				GlobalVariableSet(prefix+i+"lastDDTrigger",lastDDTrigger);
			}
			
			
         if(Use_LockMRTAfterFilter
		   &&((type?MyInfo.filterLockTriggerSell:MyInfo.filterLockTriggerBuy)
		   || UseLockAfterFilterDDTrigger_MRTAfterFilter && triggered)
		   &&(mrtAfterFilter.lockTkt[i] == 0 || mrtAfterFilter.profit[i]>0)
         &&(!StopOpenNewTradesAfterHedge 
         ||(type == 0 && MyInfo.buyHedge.tkt==0
         || type == 1 && MyInfo.sellHedge.tkt==0)))
		   {
		   	if(MathAbs(mrtAfterFilter.lotSum[i]-mrtAfterFilter.lockLot[i])>=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN) 
		   	&&(mrtAfterFilter.lockReOpen[i] || mrtAfterFilter.lockProfit[i]>3)
		   	&& mrtAfterFilter.lotSum[i]>=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN)
		   	&& mrtAfterFilter.lotSum[i]<GetMaxLot())
		   	{
					if(mrtAfterFilter.lockTkt[i]!=0)
			   	{
			         MyPositionClose(mrtAfterFilter.lockTkt[i]);
			         PrintLogs(__LINE__+" CLOSE MRT AFTER FILTER Lock and open in one");
			   	}
			   	if(GlobalVariableGet(prefix+i+"lockStartLotAmount"+(type?"sell":"buy")) == 0)
						GlobalVariableSet(prefix+i+"lockStartLotAmount"+(type?"sell":"buy"),mrtAfterFilter.lotSum[i]);
						
			      MyPositionOpen(Symbol(),type==0?ORDER_TYPE_SELL:ORDER_TYPE_BUY,mrtAfterFilter.lotSum[i],SymbolInfoDouble(Symbol(),type==0?SYMBOL_BID:SYMBOL_ASK),0,0,"0@0^"+i,MagicMRT_AfterFilter);
			      PrintLogs(__LINE__+" Open Lock TP MRT After Filter index "+i+" type "+type);
		      }
		   }
         if((type?MyInfo.filterLockExitTriggerSell:MyInfo.filterLockExitTriggerBuy)
		   && mrtAfterFilter.lockTkt[i]!=0)
		   {
		   	double targetProfit = LockAfterFilterProfitAmount_MRTAfterFilter;
            if(CloseLockAfterFilterInProfit_MRTAfterFilter == 2)
               targetProfit = (type?MyInfo.equitySell:MyInfo.equityBuy)*LockAfterFilterProfitAmount_MRTAfterFilter/100;
            double profitLock = PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
            if(CloseLockAfterFilterInProfit_MRTAfterFilter
            && mrtAfterFilter.lockProfit[i]>targetProfit)
            {
               MyPositionClose(mrtAfterFilter.lockTkt[i]);
               PrintLogs(__LINE__+" CLOSE Lock In Profit");
            }
            else
            if(UseCapsulingAfterReturnTradeZone_MRTAfterFilter)
            {
		      	MakeLockCapsule(type,mrtAfterFilter.lockTkt[i]);
		      	PrintLogs(__LINE__+" Capsule Lock After return Trade Zone");
            }
		   }
         if(mrtAfterFilter.lockTkt[i]!=0 && mrtAfterFilter.lotSum[i]<mrtAfterFilter.lockLot[i] 
         && RoundLot(Symbol(),mrtAfterFilter.lockLot[i]-mrtAfterFilter.lotSum[i])>SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN)
         && false)
         {
            double closeAmount = mrtAfterFilter.lockLot[i]-mrtAfterFilter.lotSum[i];
            MyPartialClose(mrtAfterFilter.lockTkt[i],closeAmount);
            PrintLogs(__LINE__+" CLOSE LOCK AFTER FILTER MRT index "+i+" type "+type);
         }
      }
   }
   
   int availableIndex = 1;
   if((type == 0 && MyInfo.buyMRT.isAction && MyInfo.buyMRT.filterCrossOverIndex != 0 && MyInfo.filterValueBuy
   || type == 1 && MyInfo.sellMRT.isAction && MyInfo.sellMRT.filterCrossOverIndex != 0 && MyInfo.filterValueSell)
   && iTime(Symbol(),TF,(type?MyInfo.sellMRT.filterCrossOverIndex:MyInfo.buyMRT.filterCrossOverIndex))>mrtAfterFilter.lastOT
   &&(!StopOpenNewTradesAfterHedge 
   ||(type == 0 && MyInfo.buyHedge.tkt==0
   || type == 1 && MyInfo.sellHedge.tkt==0)))
   {
   	if(StopWhenNCapsuleOpened != 0)
   	{
   		int cnt = 0;
   		for(int i=0;i<MyInfo.mainCapsuleAmount;i++)
			{
				if(MyInfo.mainCapsuleInfo[i].type == type
				&& MyInfo.mainCapsuleInfo[i].both)
				{
					cnt++;
				}
				if(cnt>=StopWhenNCapsuleOpened)
					return;
			}
   	}
      for(int i=1;i<1000;i++)
      {
         if(mrtAfterFilter.mrtCycle[i] == 0)
         {
            availableIndex = i;
            break;
         }  
         if(i == 999)   
            return;
      }  
		GlobalVariableSet(prefix+availableIndex+"lockCloseReason"+(type?"sell":"buy"),0);
		GlobalVariableSet(prefix+availableIndex+"lockStartLotAmount"+(type?"sell":"buy"),0);
		
		GlobalVariableSet(prefix+availableIndex+"lastDDTrigger",0);
      double startLot = (LotSizeCalculationBalance*StartLot_AfterFilter/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
      if(StartLotType_AfterFilter)  
         startLot = StartLot_AfterFilter;
      
		startLot = startLot*MathPow(CycleLotIncrementValue,availableIndex-1);
		if(CycleLotIncrementType)
			startLot = startLot+CycleLotIncrementValue*(availableIndex-1);
	   
      if(UseLotSizeFilterAccordingToMA
      &&(type == 0 && SymbolInfoDouble(Symbol(),SYMBOL_ASK)<MALotSize()
      || type == 1 && SymbolInfoDouble(Symbol(),SYMBOL_BID)>MALotSize()))
         startLot*=LotSizeMultiplierWhenFilteredByMA;
      MyPositionOpen(Symbol(),type?ORDER_TYPE_SELL:ORDER_TYPE_BUY,(UseMinSizeForFirstTrade?SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN):startLot),SymbolInfoDouble(Symbol(),type?SYMBOL_BID:SYMBOL_ASK),0,0,"1@1^"+availableIndex,MagicMRT_AfterFilter);
      GlobalVariableSet(prefix+availableIndex+(type?"sellLot":"buyLot"),startLot);
      PrintLogs(__LINE__+" Start MRT After Filter");
   }
}

void CloseAllFilterMRT(int type,int index)
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      if(!PositionSelectByTicket(PositionGetTicket(i)))continue;
      bool isLock = GetMRTAfterFilterN(PositionGetString(POSITION_COMMENT)) == 0 && GetMRTAfterFilterType(PositionGetString(POSITION_COMMENT)) == 0;
      if(PositionGetString(POSITION_SYMBOL) == Symbol()
      && PositionGetInteger(POSITION_MAGIC) == MagicMRT_AfterFilter
      && PositionGetInteger(POSITION_TYPE) == type 
      && !isLock
      && GetMRTAfterFilterIndex(PositionGetString(POSITION_COMMENT)) == index)
      {
         MyPositionClose(PositionGetInteger(POSITION_TICKET));
      }
   }
}
void ReOpenMRTLock(bool count = true)
{
	if(count)
	{
		if(MyPositionInfo.type == 0)
		{
			if(MyPositionInfo.ot>MyInfo.buyMRT.lastLockOT)
			{
				MyInfo.buyMRT.lastLockOT = MyPositionInfo.ot;
				MyInfo.buyMRT.lastLockPositionID = MyPositionInfo.positionID;
			}
		}
		else
		{
			if(MyPositionInfo.ot>MyInfo.sellMRT.lastLockOT)
			{
				MyInfo.sellMRT.lastLockOT = MyPositionInfo.ot;
				MyInfo.sellMRT.lastLockPositionID = MyPositionInfo.positionID;
			}
		}
		return;
	}
	if(MyInfo.buyMRT.lastLockPositionID)
	{
		MyInfo.buyMRT.lockReOpen = true;
		HistorySelectByPosition(MyInfo.buyMRT.lastLockPositionID);
		double op;
		int total = HistoryDealsTotal()-1;
		for(int i=total;i>=0;i--)
		{
			ulong tkt = HistoryDealGetTicket(i);
			if(tkt<1)continue;
			if(HistoryDealGetInteger(tkt,DEAL_ENTRY) == DEAL_ENTRY_OUT)
				op = HistoryDealGetDouble(tkt,DEAL_PRICE);
		}
		MyInfo.buyMRT.lockReOpen = op-(MyInfo.buyMRT.lockCloseReason?m_ReOpenDistAfterSelfDecrease:m_LockAfterFilterReOpenAmount)>SymbolInfoDouble(Symbol(),SYMBOL_BID)
										|| UseCapsuleTwoSideReOpen && op+(MyInfo.buyMRT.lockCloseReason?m_ReOpenDistAfterSelfDecrease:m_LockAfterFilterReOpenAmount)<SymbolInfoDouble(Symbol(),SYMBOL_BID);
		if(MyInfo.buyMRT.lockCloseReason == 2)
			MyInfo.buyMRT.lockReOpen = false;	
	}
	
	if(MyInfo.sellMRT.lastLockPositionID)
	{
		MyInfo.sellMRT.lockReOpen = true;
		HistorySelectByPosition(MyInfo.sellMRT.lastLockPositionID);
		double op;
		int total = HistoryDealsTotal()-1;
		for(int i=total;i>=0;i--)
		{
			ulong tkt = HistoryDealGetTicket(i);
			if(tkt<1)continue;
			if(HistoryDealGetInteger(tkt,DEAL_ENTRY) == DEAL_ENTRY_OUT)
				op = HistoryDealGetDouble(tkt,DEAL_PRICE);
		}
		MyInfo.sellMRT.lockReOpen = op+(MyInfo.sellMRT.lockCloseReason?m_ReOpenDistAfterSelfDecrease:m_LockAfterFilterReOpenAmount)<SymbolInfoDouble(Symbol(),SYMBOL_ASK)
									    || UseCapsuleTwoSideReOpen && op-(MyInfo.buyMRT.lockCloseReason?m_ReOpenDistAfterSelfDecrease:m_LockAfterFilterReOpenAmount)>SymbolInfoDouble(Symbol(),SYMBOL_ASK);
		if(MyInfo.sellMRT.lockCloseReason == 2)
			MyInfo.sellMRT.lockReOpen = false;	
	}
}

void ReOpenMRTLock_MRTAfterFilter(bool count = true)
{
	if(count)
	{
		if(MyPositionInfo.type == 0)
		{
			if(MyPositionInfo.ot>MyInfo.buyMRT_AfterFilter.lastLockOT[MyPositionInfo.index])
			{
				MyInfo.buyMRT_AfterFilter.lastLockOT[MyPositionInfo.index] = MyPositionInfo.ot;
				MyInfo.buyMRT_AfterFilter.lastLockPositionID[MyPositionInfo.index] = MyPositionInfo.positionID;
			}
		}
		else
		{
			if(MyPositionInfo.ot>MyInfo.sellMRT_AfterFilter.lastLockOT[MyPositionInfo.index])
			{
				MyInfo.sellMRT_AfterFilter.lastLockOT[MyPositionInfo.index] = MyPositionInfo.ot;
				MyInfo.sellMRT_AfterFilter.lastLockPositionID[MyPositionInfo.index] = MyPositionInfo.positionID;
			}
		}
		return;
	}
	for(int i=1;i<1000;i++)
	{		
		
   	if(MyInfo.buyMRT_AfterFilter.lastIndex<i
   	&& MyInfo.sellMRT_AfterFilter.lastIndex<i)
   		break;
		if(MyInfo.buyMRT_AfterFilter.lastLockPositionID[i])
		{
			MyInfo.buyMRT_AfterFilter.lockReOpen[i] = true;
			HistorySelectByPosition(MyInfo.buyMRT_AfterFilter.lastLockPositionID[i]);
			double op;
			int total = HistoryDealsTotal()-1;
			for(int i=total;i>=0;i--)
			{
				ulong tkt = HistoryDealGetTicket(i);
				if(tkt<1)continue;
				if(HistoryDealGetInteger(tkt,DEAL_ENTRY) == DEAL_ENTRY_OUT)
					op = HistoryDealGetDouble(tkt,DEAL_PRICE);
			}
			int reason = GlobalVariableGet(prefix+i+"lockCloseReason"+"buy");
			MyInfo.buyMRT_AfterFilter.lockReOpen[i] = op-(reason?m_ReOpenDistAfterSelfDecrease_MRTAfterFilter:m_LockAfterFilterReOpenAmount_MRTAfterFilter)>SymbolInfoDouble(Symbol(),SYMBOL_BID)
				    											 || UseCapsuleTwoSideReOpen 
				    											 && op+(reason?m_ReOpenDistAfterSelfDecrease_MRTAfterFilter:m_LockAfterFilterReOpenAmount_MRTAfterFilter)<SymbolInfoDouble(Symbol(),SYMBOL_BID);
			
			if(reason == 2)
				MyInfo.buyMRT_AfterFilter.lockReOpen[i] = false;	
		}
		if(MyInfo.sellMRT_AfterFilter.lastLockPositionID[i])
		{
			MyInfo.sellMRT_AfterFilter.lockReOpen[i] = true;
			HistorySelectByPosition(MyInfo.sellMRT_AfterFilter.lastLockPositionID[i]);
			double op;
			int total = HistoryDealsTotal()-1;
			for(int i=total;i>=0;i--)
			{
				ulong tkt = HistoryDealGetTicket(i);
				if(tkt<1)continue;
				if(HistoryDealGetInteger(tkt,DEAL_ENTRY) == DEAL_ENTRY_OUT)
					op = HistoryDealGetDouble(tkt,DEAL_PRICE);
			}
			int reason = GlobalVariableGet(prefix+i+"lockCloseReason"+"sell");
			MyInfo.sellMRT_AfterFilter.lockReOpen[i] = op+(reason?m_ReOpenDistAfterSelfDecrease_MRTAfterFilter:m_LockAfterFilterReOpenAmount_MRTAfterFilter)<SymbolInfoDouble(Symbol(),SYMBOL_ASK)
				    											  || UseCapsuleTwoSideReOpen 
				    											  && op-(reason?m_ReOpenDistAfterSelfDecrease_MRTAfterFilter:m_LockAfterFilterReOpenAmount_MRTAfterFilter)>SymbolInfoDouble(Symbol(),SYMBOL_ASK);
			if(reason == 2)
				MyInfo.sellMRT_AfterFilter.lockReOpen[i] = false;	
		}
	}
}
void CheckForFeaturesMRT(int type,EnumMyMRTInfo &mrt,bool filter)
{  
   if(mrt.lockTkt!=0 && mrt.lotSum<mrt.lockLot && RoundLot(Symbol(),mrt.lockLot-mrt.lotSum)>SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN)
   && false)
   {
      double closeAmount = mrt.lockLot-mrt.lotSum;
      MyPartialClose(mrt.lockTkt,closeAmount);
      PrintLogs(__LINE__+" CLOSE LOCK After MRT Profit/Nth Trade close");
      return;
   }
   
   
   if(UseLockAfterFilter
   && (type?MyInfo.filterLockExitTriggerSell:MyInfo.filterLockExitTriggerBuy)
   && mrt.lockTkt!=0)
   {
   	double targetProfit = LockAfterFilterProfitAmount;
      if(CloseLockAfterFilterInProfit == 2)
         targetProfit = (type?MyInfo.equitySell:MyInfo.equityBuy)*LockAfterFilterProfitAmount/100;
      double profitLock = PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
      if(CloseLockAfterFilterInProfit
      && mrt.lockProfit>targetProfit)
      {
         MyPositionClose(mrt.lockTkt);
         PrintLogs(__LINE__+" CLOSE Lock In Profit");
      }
      else
      if(UseCapsulingAfterReturnTradeZone)
      {
      	MakeLockCapsule(type,mrt.lockTkt);
      	PrintLogs(__LINE__+" Capsule Lock After return Trade Zone");
      }
   }
   

   bool triggered = false;
	if(UseLockAfterFilterDDTrigger)
	{
		double dd = (MathAbs(mrt.profit))/(type?MyInfo.previousEquitySell:MyInfo.previousEquityBuy)*100;
		if(UseLockAfterFilterDDTrigger == 2
		&& mrt.profit<0
		&& dd>LockAfterFilterDDTriggerAmount
		&&(dd>mrt.lastDDTrigger+LockAfterFilterDDTriggerAmountStep || mrt.lastDDTrigger == 0))
			triggered = true;
      if(triggered)
     	{
     		mrt.lastDDTrigger = dd;
     	}
     	if(!triggered)
     	{
			if(UseLockAfterFilterDDTrigger == 1
			&& mrt.profit<LockAfterFilterDDTriggerAmount*(-1)
			&&(mrt.profit<mrt.lastDDTrigger-LockAfterFilterDDTriggerAmountStep || mrt.lastDDTrigger == 0))
				triggered = true;
			if(triggered)
	     	{
	     		mrt.lastDDTrigger = mrt.profit;
	     	}
     	}
	}
	
	
         
   if(UseLockAfterFilter
	&&(mrt.lockTkt == 0 || mrt.profit>0)
   &&((type?MyInfo.filterLockTriggerSell:MyInfo.filterLockTriggerBuy)
   || UseLockAfterFilterDDTrigger && triggered)
   &&(!StopOpenNewTradesAfterHedge 
   ||(type == 0 && MyInfo.buyHedge.tkt==0
   || type == 1 && MyInfo.sellHedge.tkt==0)))
   {
      if(mrt.lotSum>=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN) 
      &&(mrt.lockReOpen || mrt.lockProfit>3)
      && MathAbs(mrt.lotSum-mrt.lockLot)>=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN)
      && mrt.lotSum<GetMaxLot())
      {
      	if(mrt.lockTkt!=0)
      	{
            MyPositionClose(mrt.lockTkt);
            PrintLogs(__LINE__+" CLOSE Lock and open in one tkt = "+mrt.lockTkt);
      	}
      	if(mrt.lockCloseReason == 0)
				mrt.lockStartLotAmount=mrt.lotSum;
         
         ulong tkt = MyPositionOpen(Symbol(),type?ORDER_TYPE_BUY:ORDER_TYPE_SELL,mrt.lotSum,SymbolInfoDouble(Symbol(),type?SYMBOL_ASK:SYMBOL_BID),0,0,"0=0^1",MagicMRT);
         PrintLogs(__LINE__+" Lock MRT "+(type?"SELL":"BUY"));
      }
   }
   
   double goal = (m_MRTTPAmount)/Point()*mrt.lotSum*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE);
   
   if(type == 0)
   {
         
		double avgTP = mrt.avgPrice+m_MRTTPAmount;
      if(ShowLines)
      {
         if(ObjectFind(0,prefix+"BuyTP")==-1)
         {
            HLineCreate(0,prefix+"BuyTP",0,avgTP,BuyTPLineColor,BuyTPLineStyle,BuyTPLineWidth,false,false);
            HLineCreate(0,prefix+"BuyAVG",0,mrt.avgPrice,BuyAVGLineColor,BuyAVGLineStyle,BuyAVGLineWidth,false,false);
         }
         else
         {
            ObjectSetDouble(0,prefix+"BuyTP",OBJPROP_PRICE,avgTP);
            ObjectSetDouble(0,prefix+"BuyAVG",OBJPROP_PRICE,mrt.avgPrice);
         }
      }
      
      ////////////////////////////////////// AVG TP //////////////////////////////////////////////////////
      if(SymbolInfoDouble(Symbol(),SYMBOL_BID)>avgTP
      && avgTP!=0
      && mrt.profit>=goal)
      {
         CloseMRT(0);
         
	   	MyInfo.previousEquityBuy = MathMax(MyInfo.previousEquityBuy,MyInfo.equityBuy);
         if(UseLockAfterFilterCapsule && mrt.lockTkt!=0)
         {
         	mrt.profit+= MakeLockCapsule(0,mrt.lockTkt,mrt.profit);
         	PrintLogs(__LINE__);
         }
         else
         {
         	if(mrt.lockTkt!=0)
         	{
         		CloseMRT(0,true);
      			PrintLogs(__LINE__);
         	}
         }
      	if(CloseCapsulesWithMRT)
      	{
      		CloseCapsules(mrt.profit,MyInfo.equityBuy);
      		PrintLogs(__LINE__);
         }
         if(UseSecondaryMRTInTP)
         {
         	CloseMRTAfterFilter(0,false);
         	if(UseLockAfterFilterCapsule_MRTAfterFilter)
         	{
	         	for(int i=1;i<1000;i++)
				   {
				   	if(MyInfo.buyMRT_AfterFilter.lastIndex<i)
				   		break;
				      if(MyInfo.buyMRT_AfterFilter.mrtCycle[i] != 0 && MyInfo.buyMRT_AfterFilter.lockTkt[i]!=0)
				      {
				      	MyInfo.buyMRT_AfterFilter.profit[i]+=MakeLockCapsule(0,MyInfo.buyMRT_AfterFilter.lockTkt[i],mrt.profit);
				      }
				   }
			   }
			   else
			   	CloseMRTAfterFilter(0,true);
         	PrintLogs(__LINE__);
         }
         if(LockHedgeAtAVGTP && mrt.isHedged == 1 && !MyInfo.buyHedge.locked)
         {
            if(UseGlobalCapsuleInsteadLock)
			      MakeLockCapsule(0,MyInfo.buyHedge.tkt,mrt.profit);
            else
         	   CloseAndLockHedge(0,mrt.profit);
         	PrintLogs(__LINE__);
         }
         if(IncludeOddCapsuleInProfitCalculation)
         {
         	for(int i=0;i<MyInfo.mainCapsuleAmount;i++)
				{
					if(MyInfo.mainCapsuleInfo[i].type == 0
					&&(!MyInfo.mainCapsuleInfo[i].main && MyInfo.mainCapsuleInfo[i].lock 
					|| MyInfo.mainCapsuleInfo[i].main && !MyInfo.mainCapsuleInfo[i].lock))
					{
						if(MyInfo.mainCapsuleInfo[i].main)
							myTrade.PositionClose(MyInfo.mainCapsuleInfo[i].mainTkt);
						if(MyInfo.mainCapsuleInfo[i].lock)
							myTrade.PositionClose(MyInfo.mainCapsuleInfo[i].lockTkt);
         			PrintLogs(__LINE__+" Close Odd Trade when close by AVG TP");
					}
				}
         }
         if(ShowLines)
         {
            ObjectDelete(0,prefix+"BuyTP");
            ObjectDelete(0,prefix+"BuyAVG");
         }
         PrintLogs(__LINE__+" Close By AVGTP");
         return;
      }
      ////////////////////////////////////// AVG TP //////////////////////////////////////////////////////
      ///////////////////////////////////// Positive Side Close //////////////////////////////////////////
      if(MathAbs(mrt.positiveN)>=ClosePositiveAfter)
      {
         if(SymbolInfoDouble(Symbol(),SYMBOL_BID)<GetOpenPrice(0,1,mrt.positiveN+PullBackAmount))
         {
         	CloseMRT(0);
         	if(LockHedgeAtAVGTP && mrt.isHedged == 1 && !MyInfo.buyHedge.locked)
	         {
	            if(UseGlobalCapsuleInsteadLock)
   			      MakeLockCapsule(0,MyInfo.buyHedge.tkt,mrt.profit);
               else
            	   CloseAndLockHedge(0,mrt.profit);
         		PrintLogs(__LINE__);
	         }
            if(ShowLines)
            {
               ObjectDelete(0,prefix+"BuyTP");
               ObjectDelete(0,prefix+"BuyAVG");
            }
            PrintLogs(__LINE__+" Close Positive Side At "+MathAbs(mrt.positiveN+PullBackAmount));
            return;
         }
      }

      ///////////////////////////////////// Positive Side Close //////////////////////////////////////////
      if(filter)
         CheckForAdditionalOpen(0,mrt.oppositeN,mrt.oppositeOP,mrt.positiveN,mrt.positiveOP,mrt.firstOP,mrt.avgPrice);
   }
   
   if(type == 1)
   {
   	double avgTP = mrt.avgPrice-m_MRTTPAmount;
      if(ShowLines)
      {
         if(ObjectFind(0,prefix+"SellTP")==-1)
         {
            HLineCreate(0,prefix+"SellTP",0,avgTP,SellTPLineColor,SellTPLineStyle,SellTPLineWidth,false,false);
            HLineCreate(0,prefix+"SellAVG",0,mrt.avgPrice,SellAVGLineColor,SellAVGLineStyle,SellAVGLineWidth,false,false);
         }
         else
         {
            ObjectSetDouble(0,prefix+"SellTP",OBJPROP_PRICE,avgTP);
            ObjectSetDouble(0,prefix+"SellAVG",OBJPROP_PRICE,mrt.avgPrice);
         }
      }
      
      
      ////////////////////////////////////// AVG TP //////////////////////////////////////////////////////
      
      
     		
      if(SymbolInfoDouble(Symbol(),SYMBOL_ASK)<avgTP
      && avgTP!=0
      && mrt.profit>=goal)
      {
         CloseMRT(1);
         
	   	MyInfo.previousEquitySell = MathMax(MyInfo.previousEquitySell,MyInfo.equitySell);
         if(UseLockAfterFilterCapsule && mrt.lockTkt!=0)
         {
         	mrt.profit+= MakeLockCapsule(1,mrt.lockTkt,mrt.profit);
         	PrintLogs(__LINE__);
         }
         else
         {
         	if(mrt.lockTkt!=0)
         	{
         		CloseMRT(1,true);
      			PrintLogs(__LINE__);
         	}
         }
      	if(CloseCapsulesWithMRT)
      	{
      		CloseCapsules(mrt.profit,MyInfo.equitySell);
      		PrintLogs(__LINE__);
         }
      	if(UseSecondaryMRTInTP)
         {
         	CloseMRTAfterFilter(1,false);
         	if(UseLockAfterFilterCapsule_MRTAfterFilter)
         	{
	         	for(int i=1;i<1000;i++)
				   {
				   	if(MyInfo.sellMRT_AfterFilter.lastIndex<i)
				   		break;
				      if(MyInfo.sellMRT_AfterFilter.mrtCycle[i] != 0 && MyInfo.sellMRT_AfterFilter.lockTkt[i]!=0)
				      {
				      	MyInfo.sellMRT_AfterFilter.profit[i]+=MakeLockCapsule(1,MyInfo.sellMRT_AfterFilter.lockTkt[i],mrt.profit);
				      }
				   }
			   }
			   else
			   	CloseMRTAfterFilter(1,true);
         	PrintLogs(__LINE__);
         }
         if(LockHedgeAtAVGTP && mrt.isHedged == 1 && !MyInfo.sellHedge.locked)
         {
            if(UseGlobalCapsuleInsteadLock)
			      MakeLockCapsule(1,MyInfo.sellHedge.tkt,mrt.profit);
            else
         	   CloseAndLockHedge(1,mrt.profit);
         	PrintLogs(__LINE__);
         }
         if(IncludeOddCapsuleInProfitCalculation)
         {
         	for(int i=0;i<MyInfo.mainCapsuleAmount;i++)
				{
					if(MyInfo.mainCapsuleInfo[i].type == 1
					&&(!MyInfo.mainCapsuleInfo[i].main && MyInfo.mainCapsuleInfo[i].lock 
					|| MyInfo.mainCapsuleInfo[i].main && !MyInfo.mainCapsuleInfo[i].lock))
					{
						if(MyInfo.mainCapsuleInfo[i].main)
							myTrade.PositionClose(MyInfo.mainCapsuleInfo[i].mainTkt);
						if(MyInfo.mainCapsuleInfo[i].lock)
							myTrade.PositionClose(MyInfo.mainCapsuleInfo[i].lockTkt);
         			PrintLogs(__LINE__+" Close Odd Trade when close by AVG TP");
					}
				}
         }
         if(ShowLines)
         {
            ObjectDelete(0,prefix+"SellTP");
            ObjectDelete(0,prefix+"SellAVG");
         }
         PrintLogs(__LINE__+" Close By AVGTP");
         return;
      }
      ///////////////////////////////////// Positive Side Close //////////////////////////////////////////
      if(MathAbs(mrt.positiveN)>=ClosePositiveAfter)
      {
         if(SymbolInfoDouble(Symbol(),SYMBOL_ASK)>GetOpenPrice(1,1,mrt.positiveN+PullBackAmount))
         {
         	
	         if(LockHedgeAtAVGTP && mrt.isHedged == 1 && !MyInfo.sellHedge.locked)
	         {
               if(UseGlobalCapsuleInsteadLock)
   			      MakeLockCapsule(1,MyInfo.sellHedge.tkt,mrt.profit);
               else
            	   CloseAndLockHedge(1,mrt.profit);
	         	PrintLogs(__LINE__);
	         }
         	CloseMRT(1);
            if(ShowLines)
            {
               ObjectDelete(0,prefix+"SellTP");
               ObjectDelete(0,prefix+"SellAVG");
            }
            PrintLogs(__LINE__+" Close Positive Side At "+MathAbs(mrt.positiveN+PullBackAmount));
            return;
         }
      }
      ///////////////////////////////////// Positive Side Close //////////////////////////////////////////
      ////////////////////////////////////// AVG TP //////////////////////////////////////////////////////
      if(filter)
         CheckForAdditionalOpen(1,mrt.oppositeN,mrt.oppositeOP,mrt.positiveN,mrt.positiveOP,mrt.firstOP,mrt.avgPrice);
   }
}


double MakeLockCapsule(int type,ulong tkt,double profit = 0)
{
	
	if(PositionSelectByTicket(tkt))
	{
		double orderProfit = PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP)-PositionGetDouble(POSITION_VOLUME)*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*CommissionPct/100;
		
		double lotSize = PositionGetDouble(POSITION_VOLUME);
		int orderType = PositionGetInteger(POSITION_TYPE);
		int magic = PositionGetInteger(POSITION_MAGIC);
		int dist = MathAbs(PositionGetDouble(POSITION_PRICE_OPEN)-SymbolInfoDouble(Symbol(),orderType?SYMBOL_ASK:SYMBOL_BID))/Point();
		if(orderProfit>0
		|| CloseCapsuleFromBalance && orderProfit<0 && MathAbs(orderProfit)<(UseSavedProfitFrom?MyInfo.savedProfit:(type?MyInfo.savedProfitSell:MyInfo.savedProfitBuy))+profit)
		{
			if(profit!=0)
			{
				profit+=orderProfit;
				if(profit<0)
				{
					orderProfit = profit;
					profit = 0;
				}
				else
				{
					orderProfit = 0;
				}
			}
			if(UseSavedProfitFrom)
			{
				MyInfo.savedProfit+=orderProfit;
			}
			else
			{
				if(type == 0)
					MyInfo.savedProfitBuy+=orderProfit;
				else
					MyInfo.savedProfitSell+=orderProfit;
				
			}
			MyPositionClose(tkt);
			PrintLogs(__LINE__+" Instead Capsuling closed in profit or Close From Balance");
			
			return (RoundLot(Symbol(),lotSize)*dist*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE))*(-1);
		}
		double leftProfit = orderProfit;
		if(profit !=0)
		{
			leftProfit = profit+orderProfit;
		}
		if(UseSavedProfitFrom)
		{
			profit+= MyInfo.savedProfit;
		}
		else
		{
			if(type == 0)
				profit+= MyInfo.savedProfitBuy;
			else
				profit+= MyInfo.savedProfitSell;
		}
	   double closeLot = RoundLot(Symbol(),profit/dist/SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE));
	   MyInfo.lockCapsuleIndex++;
	   
	   MyPartialClose(tkt,closeLot,"0#1^"+(MyInfo.lockCapsuleIndex*2+(type?1:0)));
	   myTrade.PositionModify(tkt,0,0);
	   
	   lotSize-=RoundLot(Symbol(),closeLot);
		GlobalVariableSet(prefix+(MyInfo.lockCapsuleIndex*2+(type?1:0))+"lockStartLotAmount",lotSize);
		GlobalVariableSet(prefix+(MyInfo.lockCapsuleIndex*2+(type?1:0))+"lockCloseReason",0);
		if(lotSize>0)
	   	MyPositionOpen(Symbol(),orderType?ORDER_TYPE_BUY:ORDER_TYPE_SELL,lotSize,SymbolInfoDouble(Symbol(),orderType?SYMBOL_ASK:SYMBOL_BID),0,0,"0#0^"+(MyInfo.lockCapsuleIndex*2+(type?1:0)),magic);
	   PrintLogs(__LINE__+" Lock Capsule By Index = "+(MyInfo.lockCapsuleIndex*2+(type?1:0))+" type "+type+" tkt "+tkt);
	   if(UseSavedProfitFrom)
		{
			MyInfo.savedProfit+=leftProfit;
		}
		else
		{
			if(type == 0)
				MyInfo.savedProfitBuy+=leftProfit;
			else
				MyInfo.savedProfitSell+=leftProfit;
			
		}
	   return (RoundLot(Symbol(),MathMin(closeLot,lotSize))*dist*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE))*(-1);
	}
	return 0;	
}
void CloseAndLockHedge(int type,double &mrtProfit)
{
   double lotLock = 0;
	for(int i=PositionsTotal()-1;i>=0;i--)
   {
      if(!PositionSelectByTicket(PositionGetTicket(i)))continue;
      if(PositionGetInteger(POSITION_MAGIC) == Magic
      && PositionGetString(POSITION_SYMBOL) == Symbol()
      && PositionGetInteger(POSITION_TYPE) != type
      && StringFind(PositionGetString(POSITION_COMMENT),"#") == -1
      && GetHedgeIndex(PositionGetString(POSITION_COMMENT)) == ((type?MyInfo.sellHedge.index:MyInfo.buyHedge.index)))
      {
      	double tradeProfit = PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
      	if(tradeProfit+mrtProfit>0)
      	{
      		mrtProfit+=tradeProfit;
      		MyPositionClose(PositionGetInteger(POSITION_TICKET));
      		continue;
      	}
      	else
      	{
      		double dist = MathAbs(PositionGetDouble(POSITION_PRICE_OPEN)-SymbolInfoDouble(Symbol(),type?SYMBOL_BID:SYMBOL_ASK))/Point();
      		double closeLot = RoundLot(Symbol(),mrtProfit/dist/SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE));
      		lotLock+=PositionGetDouble(POSITION_VOLUME)-closeLot;
      		MyPartialClose(PositionGetInteger(POSITION_TICKET),closeLot);
      		continue;
      	}
			lotLock+=PositionGetDouble(POSITION_VOLUME);
      }
	}
	
	if(lotLock!=0)
	{
		MyPositionOpen(Symbol(),type?ORDER_TYPE_SELL:ORDER_TYPE_BUY,lotLock,SymbolInfoDouble(Symbol(),type?SYMBOL_BID:SYMBOL_ASK),0,0,"0-0^"+((type?MyInfo.sellHedge.index:MyInfo.buyHedge.index)),Magic);
		PrintLogs(__LINE__+" Close AT AVG TP type = "+type);
	}
}
double GetOpenPrice(int type,int mrtType,int mrtN)
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      if(!PositionSelectByTicket(PositionGetTicket(i)))continue;
      if(PositionGetInteger(POSITION_MAGIC) == MagicMRT
      && PositionGetString(POSITION_SYMBOL) == Symbol()
      && PositionGetInteger(POSITION_TYPE) == type
      && GetMRTType(PositionGetString(POSITION_COMMENT)) == mrtType
      && GetMRTN(PositionGetString(POSITION_COMMENT)) == mrtN)
      {
         return PositionGetDouble(POSITION_PRICE_OPEN);
      }
   }
   return type?1000000:-1000000;
}
void GetPrices(int side,double &current,double &previous,int index,double firstOP)
{
   previous = firstOP;
   for(int j=1;j<index;j++)
   {
      if(DistanceIncreaseType == 0)
         previous -= m_StartDistance*MathPow(DistanceIncrementValue,j-1)*(side?-1:1);
      else
         previous -= (m_StartDistance+m_DistanceIncrementValue*j)*(side?-1:1);
   }   
   if(DistanceIncreaseType == 0)
      current = previous - m_StartDistance*MathPow(DistanceIncrementValue,index-1)*(side?-1:1);
   else
      current = previous - (m_StartDistance+m_DistanceIncrementValue*index)*(side?-1:1);
}
void GetIndex(int side,double &current,double &previous,int &index,double firstOP)
{
   double op = SymbolInfoDouble(Symbol(),side?SYMBOL_BID:SYMBOL_ASK);
   index=0;
   for(int i=1;i<100;i++)
   {
      GetPrices(side,current,previous,i,firstOP);   
      if(side == 0 && op<previous && op>current
      || side == 1 && op>previous && op<current)
      {
         index = i;
         break;
      }
   }
}

void CheckForAdditionalOpen(int side,int oppositeN,double oppositeOP,int positiveN,double positiveOP,double firstOP,double avgOP)
{
   if(StopOpenNewTradesAfterHedge
   &&(side == 0 && MyInfo.buyHedge.tkt!=0
   || side == 1 && MyInfo.sellHedge.tkt!=0))
      return;
   bool open = false;
   double op = SymbolInfoDouble(Symbol(),side?SYMBOL_BID:SYMBOL_ASK);
   if(FilterEffect && (UseMAFilter == 1 || UseRSIFilter == 1  || UseMACDFilter == 1))
   {
      if((side?MyInfo.filterOutSell:MyInfo.filterOutBuy) == 0)
      {
         double previous;
         double current;
         int index = 0;
         GetIndex(side,current,previous,index,firstOP);
         if(side == 0 && op>firstOP
         || side == 1 && op<firstOP)
         {
         	if(side == 0)
         	{
         		MyInfo.filterOutBuy = 2;
         		MyInfo.filterIndexBuy = index;
         	}	
         	if(side == 1)
         	{
         		MyInfo.filterOutSell = 2;
         		MyInfo.filterIndexSell = index;
         	}
            PrintLogs(__LINE__+" "+index);
            return;
         }
         GetIndex(side,current,previous,index,firstOP);
         if(side == 0)
      	{
      		MyInfo.filterOutBuy = 1;
      		MyInfo.filterIndexBuy = index;
      	}	
      	if(side == 1)
      	{
      		MyInfo.filterOutSell = 1;
      		MyInfo.filterIndexSell = index;
      	}
         PrintLogs(__LINE__+" "+index);
         return;
      }
      
      if((side?MyInfo.filterOutSell:MyInfo.filterOutBuy) == 2)
      {
         double previous;
         double current;
         int index;
         int lastIndex;
         if(side == 0)
      	{
      		lastIndex = MyInfo.filterIndexBuy;
      	}	
      	if(side == 1)
      	{
      		lastIndex = MyInfo.filterIndexSell;
      	}
         GetIndex(side,current,previous,index,firstOP);
         if(index+1<oppositeN
         &&(side == 0 && op<firstOP
         || side == 1 && op>firstOP))
         {
            if((side?MyInfo.sellMRT.isOpen1[index+1]:MyInfo.buyMRT.isOpen1[index+1])==0)
            {
               oppositeN = index;
               open = true;
               PrintLogs(__LINE__+" "+index);
            }
         }
         
         if(index>lastIndex 
         && index<oppositeN 
         && (side?MyInfo.sellMRT.isOpen1[index]:MyInfo.buyMRT.isOpen1[index])==0
         &&(side == 0 && op<firstOP
         || side == 1 && op>firstOP))
         {
            oppositeN = index-1;
            open = true;
            PrintLogs(__LINE__+" "+index);
         }
      }
      if((side?MyInfo.filterOutSell:MyInfo.filterOutBuy) == 1)
      {
         double previous;
         double current;
         int index;
         if(side == 0)
      	{
      		index = MyInfo.filterIndexBuy;
      	}	
      	if(side == 1)
      	{
      		index = MyInfo.filterIndexSell;
      	}
         GetPrices(side,current,previous,index,firstOP);
         
         if(side == 0 && op<current
         || side == 1 && op>current)
         {
            oppositeN = index;
            open = true;
            PrintLogs(__LINE__+" "+index);
            if(side == 0)
         	{
         		MyInfo.filterOutBuy = 2;
         	}	
         	if(side == 1)
         	{
         		MyInfo.filterOutSell = 2;
         	}	
            if((side?MyInfo.sellMRT.isOpen1[oppositeN+1]:MyInfo.buyMRT.isOpen1[oppositeN+1])!=0)
               return;
         }
         if(side == 0 && op>previous && index > 1
         || side == 1 && op<previous && index > 1)
         {
            oppositeN = index-1;
            open = true;
            PrintLogs(__LINE__+" "+index);
            if(side == 0)
         	{
         		MyInfo.filterOutBuy = 2;
         	}	
         	if(side == 1)
         	{
         		MyInfo.filterOutSell = 2;
         	}
            if((side?MyInfo.sellMRT.isOpen1[oppositeN+1]:MyInfo.buyMRT.isOpen1[oppositeN+1])!=0)
               return;
         }
         if((side?MyInfo.filterOutSell:MyInfo.filterOutBuy) == 1)
            return;
      }
   }
   double startLot = (side?MyInfo.lotSell:MyInfo.lotBuy);
   ////////////////////////////////////// OPPOSITE SIDE //////////////////////////////////////////////////////
   op = oppositeOP - (m_StartDistance+m_DistanceIncrementValue*oppositeN)*(side?-1:1);
   if(DistanceIncreaseType == 0)
      op = oppositeOP - m_StartDistance*MathPow(DistanceIncrementValue,oppositeN-1)*(side?-1:1);
   if(MaxLevelAmount>oppositeN
   &&(open
   || side == 0 && SymbolInfoDouble(Symbol(),SYMBOL_ASK)<op
   || side == 1 && SymbolInfoDouble(Symbol(),SYMBOL_BID)>op))
   {
      double lot = startLot+LotIncrementValue*oppositeN;
      
      if(LotIncreaseType == 0)
         lot = startLot*MathPow(LotIncrementValue,oppositeN);
      if(MaxLotStartAtLevel<=oppositeN)
		{
			
	      double maxLot = (LotSizeCalculationBalance*MaxLotAtLevel/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
	      if(MaxLotAtLevelType)  
	         maxLot = MaxLotAtLevel;
	      lot = MathMin(maxLot,lot);
		}   
      MyPositionOpen(Symbol(),side?ORDER_TYPE_SELL:ORDER_TYPE_BUY,lot,SymbolInfoDouble(Symbol(),side?SYMBOL_BID:SYMBOL_ASK),0,0,"1="+(oppositeN+1)+"^"+1,MagicMRT);
      lot = lot*SecondaryOrderPct/100;
      double tp = SymbolInfoDouble(Symbol(),side?SYMBOL_BID:SYMBOL_ASK) + m_SecondaryTPAmount*(side?-1:1);
      if(AddSecondaryTrade)
      MyPositionOpen(Symbol(),side?ORDER_TYPE_SELL:ORDER_TYPE_BUY,lot,SymbolInfoDouble(Symbol(),side?SYMBOL_BID:SYMBOL_ASK),0,tp,"2="+(oppositeN+1)+"^"+1,MagicMRT);
      PrintLogs(__LINE__+" Add Opposite Side");
   }
   
   ////////////////////////////////////// OPPOSITE SIDE //////////////////////////////////////////////////////
   
   ////////////////////////////////////// POSITIVE SIDE //////////////////////////////////////////////////////
   positiveN = MathAbs(positiveN);
   op = positiveOP + (m_StartDistance_PS+m_DistanceIncrementValue_PS*positiveN)*(side?-1:1);
   if(DistanceIncreaseType_PS == 0)
      op = positiveOP + m_StartDistance_PS*MathPow(DistanceIncrementValue_PS,positiveN-1)*(side?-1:1);
      
   if(MaxLevelAmount_PS>positiveN
   &&(side == 0 && SymbolInfoDouble(Symbol(),SYMBOL_ASK)>op && (!StopOpenAfterAVGOP || SymbolInfoDouble(Symbol(),SYMBOL_ASK)<avgOP)
   || side == 1 && SymbolInfoDouble(Symbol(),SYMBOL_BID)<op && (!StopOpenAfterAVGOP || SymbolInfoDouble(Symbol(),SYMBOL_BID)>avgOP)))
   {
      double lot = startLot+LotIncrementValue_PS*positiveN;
      if(LotIncreaseType_PS == 0)
         lot = startLot*MathPow(LotIncrementValue_PS,positiveN);
      if(MaxLotStartAtLevel_PS<=MathAbs(positiveN))
		{
	      double maxLot = (LotSizeCalculationBalance*MaxLotAtLevel_PS/100)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*SymbolInfoDouble(Symbol(),SYMBOL_BID));
	      if(MaxLotAtLevelType_PS)  
	         maxLot = MaxLotAtLevel_PS;
	      lot = MathMin(maxLot,lot);
		}
      MyPositionOpen(Symbol(),side?ORDER_TYPE_SELL:ORDER_TYPE_BUY,lot,SymbolInfoDouble(Symbol(),side?SYMBOL_BID:SYMBOL_ASK),0,0,"1="+((positiveN+1)*(-1))+"^"+1,MagicMRT);
      PrintLogs(__LINE__+" Add Positive Side");
   }
   ////////////////////////////////////// POSITIVE SIDE //////////////////////////////////////////////////////
}
void CloseMRTAfterFilter(int type,bool lock=false)
{
	for(int i=PositionsTotal()-1;i>=0;i--)
   {
      if(!PositionSelectByTicket(PositionGetTicket(i)))continue;
      int magic = PositionGetInteger(POSITION_MAGIC);
      int orderType = PositionGetInteger(POSITION_TYPE);
      string comment = PositionGetString(POSITION_COMMENT);
      
      if(PositionGetString(POSITION_SYMBOL) == Symbol()
      && magic == MagicMRT_AfterFilter
      && IsTypeConfirmed(type,orderType,magic,comment,lock?0:1)
      && StringFind(comment,"#")==-1)
      {
      	MyPositionClose(PositionGetInteger(POSITION_TICKET));
      }
   }
}
void CloseHedge(int type,bool lock=false)
{
	for(int i=PositionsTotal()-1;i>=0;i--)
   {
      if(!PositionSelectByTicket(PositionGetTicket(i)))continue;
      int magic = PositionGetInteger(POSITION_MAGIC);
      int orderType = PositionGetInteger(POSITION_TYPE);
      string comment = PositionGetString(POSITION_COMMENT);
      
      if(PositionGetString(POSITION_SYMBOL) == Symbol()
      && magic == Magic
      && IsTypeConfirmed(type,orderType,magic,comment,lock?0:1)
      && StringFind(comment,"#")==-1)
      {
      	MyPositionClose(PositionGetInteger(POSITION_TICKET));
      }
   }
}
void CloseMRT(int type,bool lock=false)
{
	for(int i=PositionsTotal()-1;i>=0;i--)
   {
      if(!PositionSelectByTicket(PositionGetTicket(i)))continue;
      int magic = PositionGetInteger(POSITION_MAGIC);
      int orderType = PositionGetInteger(POSITION_TYPE);
      string comment = PositionGetString(POSITION_COMMENT);
      
      if(PositionGetString(POSITION_SYMBOL) == Symbol()
      && magic == MagicMRT
      && IsTypeConfirmed(type,orderType,magic,comment,lock?0:1)
      && StringFind(comment,"#")==-1)
      {
      	MyPositionClose(PositionGetInteger(POSITION_TICKET));
      }
   }
}
void CloseAll(int type=-1)
{
	for(int i=PositionsTotal()-1;i>=0;i--)
   {
      if(!PositionSelectByTicket(PositionGetTicket(i)))continue;
      int magic = PositionGetInteger(POSITION_MAGIC);
      int orderType = PositionGetInteger(POSITION_TYPE);
      string comment = PositionGetString(POSITION_COMMENT);
      
      if(PositionGetString(POSITION_SYMBOL) == Symbol()
      && IsTypeConfirmed(type,orderType,magic,comment)
      &&(type == -1||StringFind(comment,"#")==-1))
      {
      	MyPositionClose(PositionGetInteger(POSITION_TICKET));
      }
   }
}



bool IsTypeConfirmed(int type,int orderType,int magic,string comment,int mainAndLock = -1)
{
	if(magic == Magic
   &&(type == -1
   || type == 0
   &&(orderType == 1 && GetHedgeN(comment) !=0 && (mainAndLock == -1 || mainAndLock == 1)
   || orderType == 0 && GetHedgeN(comment) ==0 && (mainAndLock == -1 || mainAndLock == 0))
   || type == 1
   &&(orderType == 0 && GetHedgeN(comment) !=0 && (mainAndLock == -1 || mainAndLock == 1)
   || orderType == 1 && GetHedgeN(comment) ==0 && (mainAndLock == -1 || mainAndLock == 0))))
		return true;
   
   if(magic == MagicMRT
   &&(type == -1
   || type == 0
   &&(orderType == 0 && GetMRTN(comment) != 0 && (mainAndLock == -1 || mainAndLock == 1)
   || orderType == 1 && GetMRTN(comment) == 0 && (mainAndLock == -1 || mainAndLock == 0))
   || type == 1
   &&(orderType == 1 && GetMRTN(comment) != 0 && (mainAndLock == -1 || mainAndLock == 1)
   || orderType == 0 && GetMRTN(comment) == 0 && (mainAndLock == -1 || mainAndLock == 0))))
		return true;
   	
   if(magic == MagicMRT_AfterFilter
   &&(type == -1
   || type == 0
   &&(orderType == 0 && GetMRTAfterFilterN(comment) != 0 && (mainAndLock == -1 || mainAndLock == 1)
   || orderType == 1 && GetMRTAfterFilterN(comment) == 0 && (mainAndLock == -1 || mainAndLock == 0))
   || type == 1
   &&(orderType == 1 && GetMRTAfterFilterN(comment) != 0 && (mainAndLock == -1 || mainAndLock == 1)
   || orderType == 0 && GetMRTAfterFilterN(comment) == 0 && (mainAndLock == -1 || mainAndLock == 0))))
		return true;
   return false;
}
void CheckForEquityClose()
{

   double goal = IncreaseAmount;
   if(CloseAfterEquityIncrease == 2)
      goal = MyInfo.previousEquity*IncreaseAmount/100;
   
   if(MyInfo.equity-MyInfo.previousEquity>goal)
   {
		CloseAll();
      MyInfo.previousEquity = MyInfo.equity;
      MyInfo.previousEquityBuy = MathMax(MyInfo.previousEquityBuy,MyInfo.equityBuy);
   	MyInfo.previousEquitySell = MathMax(MyInfo.previousEquitySell,MyInfo.equitySell);
      MyInfo.startTime = TimeCurrent();
      MyInfo.maxProfit = 0;
      
      ObjectDelete(0,prefix+"SellTP");
      ObjectDelete(0,prefix+"SellAVG");
               
      ObjectDelete(0,prefix+"BuyTP");
      ObjectDelete(0,prefix+"BuyAVG");
      
      MyInfo.buyHedge.index = 0;
      MyInfo.sellHedge.index = 0;
      PrintLogs(__LINE__+" Close By Equity");
      return;
   }
   
   goal = IncreaseAmountBuy;
   if(CloseAfterEquityIncreaseBuy == 2)
      goal = MyInfo.previousEquityBuy*IncreaseAmountBuy/100;
   if(MyInfo.equityBuy-MyInfo.previousEquityBuy>goal)
   {
		CloseAll(0);
      MyInfo.previousEquityBuy = MathMax(MyInfo.previousEquityBuy,MyInfo.equityBuy);
      MyInfo.startTimeBuy = TimeCurrent();
      MyInfo.maxProfitBuy = 0;
      MyInfo.cycleClosedProfitBuy = 0;
      
               
      ObjectDelete(0,prefix+"BuyTP");
      ObjectDelete(0,prefix+"BuyAVG");
      MyInfo.buyHedge.index = 0;
      PrintLogs(__LINE__+" Close By Equity Buy");
      
      
      if(CloseCapsulesAfterEquityClose)
     		CloseCapsules(MyInfo.balance-MyInfo.maxEquity);
      return;
   }
   
   goal = IncreaseAmountSell;
   if(CloseAfterEquityIncreaseSell == 2)
      goal = MyInfo.previousEquitySell*IncreaseAmountSell/100;
   if(MyInfo.equitySell-MyInfo.previousEquitySell>goal)
   {
      CloseAll(1);
   	MyInfo.previousEquitySell = MathMax(MyInfo.previousEquitySell,MyInfo.equitySell);
      MyInfo.startTimeSell = TimeCurrent();
      MyInfo.maxProfitSell = 0;
      MyInfo.cycleClosedProfitSell = 0;
      
               
      ObjectDelete(0,prefix+"SellTP");
      ObjectDelete(0,prefix+"SellAVG");
      
      MyInfo.sellHedge.index = 0;
      PrintLogs(__LINE__+" Close By Equity Sell");
      if(CloseCapsulesAfterEquityClose)
     		CloseCapsules(MyInfo.balance-MyInfo.maxEquity);
      return;
   }
}
bool CheckForFeaturesHedge()
{	
   if(UseMainHedgeCapsuleSL
   && MyPositionInfo.index <= (MyPositionInfo.type?MyInfo.sellHedge.index:MyInfo.buyHedge.index)
   && MyPositionInfo.isLock)
   {
      bool slMargin = (MyInfo.equity-MyInfo.marginUsed)/MyInfo.equity*100<CloseBySLMarginLevel;
      bool anyWay = (MyInfo.equity-MyInfo.marginUsed)/MyInfo.equity*100<CloseAnyWayMarginLevel;
      if(UseMarginLevelFromAccount)
      {
         slMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE)/AccountInfoDouble(ACCOUNT_EQUITY)*100<CloseBySLMarginLevel;
         anyWay = AccountInfoDouble(ACCOUNT_MARGIN_FREE)/AccountInfoDouble(ACCOUNT_EQUITY)*100<CloseAnyWayMarginLevel;
      }
      if(CloseOnLowMargin && anyWay)
      {
         CloseHedgeCapsule(MyPositionInfo.orderType,MyPositionInfo.index,false);
      }   
      else
      {
         if(MyPositionInfo.type == 0 && MyPositionInfo.op+m_MainHedgeCapsuleSL*Point()<SymbolInfoDouble(Symbol(),SYMBOL_BID)
         || MyPositionInfo.type == 0 && MyPositionInfo.op-m_MainHedgeCapsuleSL2*Point()>SymbolInfoDouble(Symbol(),SYMBOL_ASK)
         || MyPositionInfo.type == 1 && MyPositionInfo.op-m_MainHedgeCapsuleSL*Point()>SymbolInfoDouble(Symbol(),SYMBOL_ASK)
         || MyPositionInfo.type == 1 && MyPositionInfo.op+m_MainHedgeCapsuleSL2*Point()<SymbolInfoDouble(Symbol(),SYMBOL_BID))
         {
            CloseHedgeCapsule(MyPositionInfo.orderType,MyPositionInfo.index,!(!CloseOnLowMargin || slMargin));
         }
      }
   }
   if(MyPositionInfo.isLock
   || MyPositionInfo.index < (MyPositionInfo.type?MyInfo.sellHedge.index:MyInfo.buyHedge.index)
   || (MyPositionInfo.type?MyInfo.sellHedge.locked:MyInfo.buyHedge.locked))
   	return false;
   
      
   if(LockHedgeAfterPullBack)
   {
   	if(MyPositionInfo.type)
   		MyInfo.sellHedge.lotSum+=MyPositionInfo.lotSize;
      else
      	MyInfo.buyHedge.lotSum+=MyPositionInfo.lotSize;
   }
   if(LockHedgeAfterPullBack
   && MyPositionInfo.n == MyInfo.MainGridLastIndex
   &&(MyPositionInfo.orderType == 0 && MyPositionInfo.op-m_LockPullBackStart<SymbolInfoDouble(Symbol(),SYMBOL_ASK)
   || MyPositionInfo.orderType == 1 && MyPositionInfo.op+m_LockPullBackStart>SymbolInfoDouble(Symbol(),SYMBOL_BID)))
   {
   	if(MyPositionInfo.type)
   		MyInfo.sellHedge.lotSum=-1000000;
      else
      	MyInfo.buyHedge.lotSum=-1000000;
   }
	
   if(MyPositionInfo.n == MyInfo.MainGridLastIndex)
   {	
   	double goal;
      if(MainTPType)
      {
         bool close = false;
         if(MainTPType == 1)
         {
            goal = (MyPositionInfo.type?MyInfo.equitySell:MyInfo.equityBuy)*MainTPAmount/100;
            if((MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)>=goal)
               close = true;
         }
         
         if(MainTPType == 2)
         {
            goal = MainTPAmount;
            if((MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)>=goal)
               close = true;
         }
         
         if(MainTPType == 3)
         {
            
            if(MyPositionInfo.orderType == 0 && MyPositionInfo.op+m_MainTPAmount<SymbolInfoDouble(Symbol(),SYMBOL_BID)
            || MyPositionInfo.orderType == 1 && MyPositionInfo.op-m_MainTPAmount>SymbolInfoDouble(Symbol(),SYMBOL_ASK))
               close = true;
         }
         if(close)
         {
            if(MainGridType)
            {
            	CloseHedge(MyPositionInfo.type);
               PrintLogs(__LINE__);
               return true;
            }
            MyPositionClose(MyPositionInfo.tkt);
            PrintLogs(__LINE__);
            return true;
         }
      }
      
      if(MainBreakEvenType)
      {
         bool hit = false;
         if(MainBreakEvenType == 1)
         {
            goal = (MyPositionInfo.type?MyInfo.equitySell:MyInfo.equityBuy)*MainBreakEvenAfter/100;
            if((MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)>=goal)
            {
            	if(MyPositionInfo.type == 0)
            		MyInfo.beStartedMainBuy = 1;
               if(MyPositionInfo.type == 1)
               	MyInfo.beStartedMainSell = 1;
            }
            if((MyPositionInfo.type?MyInfo.beStartedMainSell:MyInfo.beStartedMainBuy) == 1
            && (MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)<=MyInfo.equity*MainBreakEvenAt/100)
               hit = true;
         }
         if(MainBreakEvenType == 2)
         {
            goal = MainBreakEvenAfter;
            if((MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)>=goal)
            {
            	if(MyPositionInfo.type == 0)
            		MyInfo.beStartedMainBuy = 1;
               if(MyPositionInfo.type == 1)
               	MyInfo.beStartedMainSell = 1;
            }   	
            if((MyPositionInfo.type?MyInfo.beStartedMainSell:MyInfo.beStartedMainBuy) == 1
            && (MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)<=MainBreakEvenAt)
               hit = true;
         }
         if(MainBreakEvenType == 3)
         {
            if(MyPositionInfo.orderType == 0 && MyPositionInfo.op+m_MainBreakEvenAfter<SymbolInfoDouble(Symbol(),SYMBOL_BID)
            || MyPositionInfo.orderType == 1 && MyPositionInfo.op-m_MainBreakEvenAfter>SymbolInfoDouble(Symbol(),SYMBOL_ASK))
            {
            	if(MyPositionInfo.type == 0)
            		MyInfo.beStartedMainBuy = 1;
               if(MyPositionInfo.type == 1)
               	MyInfo.beStartedMainSell = 1;
            }
            if((MyPositionInfo.type?MyInfo.beStartedMainSell:MyInfo.beStartedMainBuy) == 1
            &&(MyPositionInfo.orderType == 0 && MyPositionInfo.op+m_MainBreakEvenAt>SymbolInfoDouble(Symbol(),SYMBOL_BID)
            || MyPositionInfo.orderType == 1 && MyPositionInfo.op-m_MainBreakEvenAt<SymbolInfoDouble(Symbol(),SYMBOL_ASK)))
               hit = true;
         }
         if((MyPositionInfo.type?MyInfo.beStartedMainSell:MyInfo.beStartedMainBuy) == 1 && hit)
         {
            if(MyPositionInfo.type == 0)
         		MyInfo.beStartedMainBuy = 0;
            if(MyPositionInfo.type == 1)
            	MyInfo.beStartedMainSell = 0;
            if(MainGridType)
            {
            	CloseHedge(MyPositionInfo.type);
               PrintLogs(__LINE__);
               return true;
            }
            MyPositionClose(MyPositionInfo.tkt);
            PrintLogs(__LINE__);
            return true;
         }
      }
      if(MainSLType)
      {
         bool close = false;
         if(MainSLType == 1)
         {
            goal = (MyPositionInfo.type?MyInfo.equitySell:MyInfo.equityBuy)*MainSLAmount/100;
            if((MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)<=goal*(-1))
               close = true;
         }
         
         if(MainSLType == 2)
         {
            goal = MainSLAmount;
            if((MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)<=goal*(-1))
               close = true;
         }
         
         if(MainSLType == 3)
         {
            if(MyPositionInfo.orderType == 0 && MyPositionInfo.op-m_MainSLAmount>SymbolInfoDouble(Symbol(),SYMBOL_BID)
            || MyPositionInfo.orderType == 1 && MyPositionInfo.op+m_MainSLAmount<SymbolInfoDouble(Symbol(),SYMBOL_ASK))
               close = true;
         }
         if(close)
         {
            if(MainGridType)
            {
            	CloseHedge(MyPositionInfo.type);
               PrintLogs(__LINE__);
               return true;
            }
            MyPositionClose(MyPositionInfo.tkt);
            PrintLogs(__LINE__);
            return true;
         }
      }
      
      if(MainTSType)
      {
         bool hit = false;
         if(MainTSType == 1)
         {
            goal = (MyPositionInfo.type?MyInfo.equitySell:MyInfo.equityBuy)*MainTSAfter/100;
            if((MyPositionInfo.type?MyInfo.trailingMainSell:MyInfo.trailingMainBuy))
            {
               goal = (MyPositionInfo.type?MyInfo.trailingMainValueSell:MyInfo.trailingMainValueBuy)+(MyPositionInfo.type?MyInfo.equitySell:MyInfo.equityBuy)*MainTSStep/100;
               if((MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)<=(MyPositionInfo.type?MyInfo.trailingMainValueSell:MyInfo.trailingMainValueBuy)
               && (MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)<=(MyPositionInfo.type?MyInfo.equitySell:MyInfo.equityBuy)*MainTSBlock/100)
                  hit = true;
            }
            if((MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)>=goal)
            {	
            	if(MyPositionInfo.type == 0)
            	{
            		MyInfo.trailingMainBuy = 1;
            		MyInfo.trailingMainValueBuy = (MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)-
               											(MyPositionInfo.type?MyInfo.equitySell:MyInfo.equityBuy)*MainTSDistance/100;
            	}
            	if(MyPositionInfo.type == 1)
            	{
            		MyInfo.trailingMainSell = 1;
            		MyInfo.trailingMainValueSell = (MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)-
               											 (MyPositionInfo.type?MyInfo.equitySell:MyInfo.equityBuy)*MainTSDistance/100;
            	}
            }
         }
         if(MainTSType == 2)
         {
            goal = MainTSAfter;
            if((MyPositionInfo.type?MyInfo.trailingMainSell:MyInfo.trailingMainBuy) == 1)
            {
               goal = (MyPositionInfo.type?MyInfo.trailingMainValueSell:MyInfo.trailingMainValueBuy)+MainTSStep;
               if((MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)<=(MyPositionInfo.type?MyInfo.trailingMainValueSell:MyInfo.trailingMainValueBuy)
               && (MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)<=MainTSBlock)
                  hit = true;
            }
            if((MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)>=goal)
            {
               if(MyPositionInfo.type == 0)
            	{
            		MyInfo.trailingMainBuy = 1;
            		MyInfo.trailingMainValueBuy = (MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)-MainTSDistance;
            	}
            	if(MyPositionInfo.type == 1)
            	{
            		MyInfo.trailingMainSell = 1;
            		MyInfo.trailingMainValueSell = (MyPositionInfo.type?MyInfo.sellHedge.profit:MyInfo.buyHedge.profit)-MainTSDistance;
            	}
            }
         }
         if(MainTSType == 3)
         {
         	if((MyPositionInfo.type?MyInfo.trailingMainSell:MyInfo.trailingMainBuy) == 0)
            	goal = MyPositionInfo.op+m_MainTSAfter*(MyPositionInfo.orderType?-1:1);
            	
            if((MyPositionInfo.type?MyInfo.trailingMainSell:MyInfo.trailingMainBuy) == 1)
            {
               goal = (MyPositionInfo.type?MyInfo.trailingMainValueSell:MyInfo.trailingMainValueBuy)+m_MainTSStep*(MyPositionInfo.orderType?-1:1);
               if((MyPositionInfo.orderType == 0 && SymbolInfoDouble(Symbol(),SYMBOL_BID)<=(MyPositionInfo.type?MyInfo.trailingMainValueSell:MyInfo.trailingMainValueBuy)
               ||  MyPositionInfo.orderType == 1 && SymbolInfoDouble(Symbol(),SYMBOL_ASK)>=(MyPositionInfo.type?MyInfo.trailingMainValueSell:MyInfo.trailingMainValueBuy))
               &&( MyPositionInfo.orderType == 0 && SymbolInfoDouble(Symbol(),SYMBOL_BID)<=MyPositionInfo.op+m_MainTSBlock
               ||  MyPositionInfo.orderType == 1 && SymbolInfoDouble(Symbol(),SYMBOL_ASK)>=MyPositionInfo.op-m_MainTSBlock))
                  hit = true;
            }
            
            if(MyPositionInfo.orderType == 0 && goal<SymbolInfoDouble(Symbol(),SYMBOL_BID)
            || MyPositionInfo.orderType == 1 && goal>SymbolInfoDouble(Symbol(),SYMBOL_ASK))
            {
               if(MyPositionInfo.type == 0)
            	{
            		MyInfo.trailingMainBuy = 1;
            		MyInfo.trailingMainValueBuy = SymbolInfoDouble(Symbol(),MyPositionInfo.orderType?SYMBOL_ASK:SYMBOL_BID)+m_MainTSDistance*(MyPositionInfo.orderType?1:-1);
            	}
            	if(MyPositionInfo.type == 1)
            	{
            		MyInfo.trailingMainSell = 1;
            		MyInfo.trailingMainValueSell = SymbolInfoDouble(Symbol(),MyPositionInfo.orderType?SYMBOL_ASK:SYMBOL_BID)+m_MainTSDistance*(MyPositionInfo.orderType?1:-1);
            	}
            }
            
         }
         if(hit)
         {
            if(MainGridType)
            {
            	CloseHedge(MyPositionInfo.type);
               PrintLogs(__LINE__);
               return true;
            }
            MyPositionClose(MyPositionInfo.tkt);
            PrintLogs(__LINE__);
            return true;
         }
      }
      if(MainGridType == 1)
      {
         ReFill(MyPositionInfo.type);
      }
   }  
   return false;
}



void CloseHedgeCapsule(int type,int index,bool considerProfit = true)
{
   double profit=0;
   if(considerProfit)
   {
      for(int i=PositionsTotal()-1;i>=0;i--)
      {
         if(!PositionSelectByTicket(PositionGetTicket(i)))continue;
         if(PositionGetInteger(POSITION_MAGIC) != Magic
         || PositionGetString(POSITION_SYMBOL) != Symbol())continue;
         if(GetHedgeIndex(PositionGetString(POSITION_COMMENT)) == index
         &&(type == PositionGetInteger(POSITION_TYPE)
         && GetHedgeN(PositionGetString(POSITION_COMMENT)) == 0
         || type != PositionGetInteger(POSITION_TYPE)
         && GetHedgeN(PositionGetString(POSITION_COMMENT)) != 0))
         {
            profit+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
         }
      }
   }
   if((UseSavedProfitFrom?MyInfo.savedProfit:(type?MyInfo.savedProfitSell:MyInfo.savedProfitBuy))+profit>0 || !considerProfit)
   {   
   	if(UseSavedProfitFrom)
		{
			MyInfo.savedProfit+=profit;
		}
		else
		{
			if(type == 0)
				MyInfo.savedProfitBuy+=profit;
			else
				MyInfo.savedProfitSell+=profit;
		}
      for(int i=PositionsTotal()-1;i>=0;i--)
      {
         if(!PositionSelectByTicket(PositionGetTicket(i)))continue;
         if(PositionGetInteger(POSITION_MAGIC) != Magic
         || PositionGetString(POSITION_SYMBOL) != Symbol())continue;
         if(GetHedgeIndex(PositionGetString(POSITION_COMMENT)) == index
         &&(type == PositionGetInteger(POSITION_TYPE)
         && GetHedgeN(PositionGetString(POSITION_COMMENT)) == 0
         || type == PositionGetInteger(POSITION_TYPE)
         && GetHedgeN(PositionGetString(POSITION_COMMENT)) != 0))
         {
            MyPositionClose(PositionGetInteger(POSITION_TICKET));
         }
      }
      PrintLogs(__LINE__+"Hedge Capsule Closed in SL ");
   }
            
}


void CheckForHedgeCapsuleClose()
{
   for(int i=0;i<capsuleAmountBuy;i++)
   {
   	if(capsuledBuy[i]
   	&& (UseSavedProfitFrom?MyInfo.savedProfit:(MyInfo.savedProfitBuy))+capsuleProfitBuy[i]>0)
   	{
   		if(UseSavedProfitFrom)
			{
				MyInfo.savedProfit+=capsuleProfitBuy[i];
			}
			else
			{
				MyInfo.savedProfitBuy+=capsuleProfitBuy[i];
			}
   		for(int j=PositionsTotal()-1;j>=0;j--)
	      {
	         if(!PositionSelectByTicket(PositionGetTicket(j)))continue;
	         if(PositionGetInteger(POSITION_MAGIC) == Magic
	         && PositionGetString(POSITION_SYMBOL) == Symbol()
	         && IsTypeConfirmed(0,PositionGetInteger(POSITION_TYPE),PositionGetInteger(POSITION_MAGIC),PositionGetString(POSITION_COMMENT))
	         && GetHedgeIndex(PositionGetString(POSITION_COMMENT)) == capsuleIndexBuy[i])
	         {
	         
	            MyPositionClose(PositionGetInteger(POSITION_TICKET));
	         }
	      }
      	PrintLogs(__LINE__+" Close Hedge Capsule From Balance");
   	}
   }
	
			
   for(int i=0;i<capsuleAmountSell;i++)
   {
   	if(capsuledSell[i]
   	&& (UseSavedProfitFrom?MyInfo.savedProfit:(MyInfo.savedProfitSell))+capsuleProfitSell[i]>0)
   	{
   		if(UseSavedProfitFrom)
			{
				MyInfo.savedProfit+=capsuleProfitSell[i];
			}
			else
			{
				MyInfo.savedProfitSell+=capsuleProfitSell[i];
			}
   		for(int j=PositionsTotal()-1;j>=0;j--)
	      {
	         if(!PositionSelectByTicket(PositionGetTicket(j)))continue;
	         if(PositionGetInteger(POSITION_MAGIC) == Magic
	         && PositionGetString(POSITION_SYMBOL) == Symbol()
	         && IsTypeConfirmed(1,PositionGetInteger(POSITION_TYPE),PositionGetInteger(POSITION_MAGIC),PositionGetString(POSITION_COMMENT))
	         && GetHedgeIndex(PositionGetString(POSITION_COMMENT)) == capsuleIndexSell[i])
	         {
	            MyPositionClose(PositionGetInteger(POSITION_TICKET));
	         }
	      }
      	PrintLogs(__LINE__+" Close Hedge Capsule From Balance");
   	}
   }  
}


void CheckForOpenHedge(int type,EnumMyHedgeInfo &hedge)
{
	
   if((type == 0 && hedge.allLotSum>0
   ||  type == 1 && hedge.allLotSum<0)
   &&(hedge.op==0 || hedge.locked))
   {
   	double lotSum=MathAbs(hedge.allLotSum);
      double triggerValue = MainTriggerAmount+MainTriggerAddAfterCapsule*hedge.capsuleAmount;
      if(MainTriggerType == 1)
      {
         triggerValue = (type?MyInfo.equitySell:MyInfo.equityBuy)*(MainTriggerAmount+MainTriggerAddAfterCapsule*hedge.capsuleAmount)/100;
      }
      if(hedge.allProfitSum<triggerValue*(-1)
      &&(hedge.reOpen
      &&!hedge.locked
      || hedge.locked 
      && MainUseReOpen))
      {
         double openLot = lotSum*MainLockPct/100;
         
         if(type)
         {
         	MyInfo.trailingMainSell = 0;
	         MyInfo.trailingMainValueSell = 0;
	         MyInfo.beStartedMainSell = 0;
         	MyInfo.sellHedge.index++;
         	MyInfo.sellHedge.lastHedegeIndex++;
         }
         else
         {
         	MyInfo.trailingMainBuy = 0;
	         MyInfo.trailingMainValueBuy = 0;
	         MyInfo.beStartedMainBuy = 0;
         	MyInfo.buyHedge.index++;
         	MyInfo.buyHedge.lastHedegeIndex++;
         }
         updateHedgeIndex = false;
         if(MainGridType!=0)
         {
            for(int j=1;j<=MyInfo.MainGridLastIndex;j++)
            {
               double gridLot = openLot*MainGridPct[j]/100;
               MyPositionOpen(Symbol(),
               type?ORDER_TYPE_BUY:ORDER_TYPE_SELL,gridLot,
               SymbolInfoDouble(Symbol(),type?SYMBOL_ASK:SYMBOL_BID),
               0,SymbolInfoDouble(Symbol(),type?SYMBOL_ASK:SYMBOL_BID)+MainGridDistance[j]*(type?1:(-1)),"0-"+(j)+"^"+((type?MyInfo.sellHedge.index:MyInfo.buyHedge.index)),Magic); 
            }
         }
         else
         {
            MyPositionOpen(Symbol(),type?ORDER_TYPE_BUY:ORDER_TYPE_SELL,openLot,SymbolInfoDouble(Symbol(),type?SYMBOL_ASK:SYMBOL_BID),0,0,"0-1"+"^"+((type?MyInfo.sellHedge.index:MyInfo.buyHedge.index)),Magic);
         }
         PrintLogs(__LINE__+" "+openLot+" "+lotSum);
         return;
      }
   }
}


ulong mrtTktBuy[1000];
ulong mrtTktSell[1000];
int closeAmountBuy;
int closeAmountSell;
double leftAmountBuy;
double leftAmountSell;
void CheckNthTradeWithHedge()
{
   if(MyInfo.buyHedge.op !=0
   &&!MyInfo.buyHedge.locked
   && MyInfo.buyMRT.lastN > MyPositionInfo.n
   && MyPositionInfo.orderType == 0
   && MyPositionInfo.n!=1
   &&(MyPositionInfo.n>=FromNth
   || MyPositionInfo.n<0)
   && leftAmountBuy+MyPositionInfo.orderProfit>0)
   {
		leftAmountBuy+=MyPositionInfo.orderProfit;
		mrtTktBuy[closeAmountBuy] = MyPositionInfo.tkt;
		closeAmountBuy++;
	}
	if(MyInfo.sellHedge.op !=0
   &&!MyInfo.sellHedge.locked
   && MyInfo.sellMRT.lastN > MyPositionInfo.n
   && MyPositionInfo.orderType == 1
   && MyPositionInfo.n!=1
   &&(MyPositionInfo.n>=FromNth
   || MyPositionInfo.n<0)
   && leftAmountSell+MyPositionInfo.orderProfit>0)
   {
		leftAmountSell+=MyPositionInfo.orderProfit;
		mrtTktSell[closeAmountSell] = MyPositionInfo.tkt;
		closeAmountSell++;
	}
}
void CloseNthTradeWithHedge()
{
   
	if(closeAmountBuy!=0)
	{
	   for(int i=0;i<closeAmountBuy;i++)
	   {
	      MyPositionClose(mrtTktBuy[i]);
	   }
	   MyPositionClose(MyInfo.buyHedge.tkt);
	   PrintLogs(__LINE__+" Close Nth Trade With Main Hedge Buy");
	}
	if(closeAmountSell!=0)
	{
	   for(int i=0;i<closeAmountSell;i++)
	   {
	      MyPositionClose(mrtTktSell[i]);
	   }
	   MyPositionClose(MyInfo.sellHedge.tkt);
	   PrintLogs(__LINE__+" Close Nth Trade With Main Hedge Sell");
	}
}
void CountProfitForMain()
{
	if(!UseHedge)
		return;
   if(MyPositionInfo.type == 0)
   {
   	if(CloseMainHedgeCapsuleFromBalance
   	&& MyPositionInfo.isHedge)
   	{
   		bool found = false;
   		int index = -1;
   		for(int i=0;i<capsuleAmountBuy;i++)
   		{
   			index = i;
   			if(capsuleIndexBuy[i] == MyPositionInfo.index)
   			{
   				found = true;
   				break;
   			}
   		}
   		if(!found)
   		{
   			capsuleAmountBuy++;
   			index++;
   		}
   		if(MyPositionInfo.isLock)
   			capsuledBuy[index] = true;
   	   capsuleProfitBuy[index]+=MyPositionInfo.orderProfit;
   	   capsuleIndexBuy[index] = MyPositionInfo.index;
   	}
   	if(MyPositionInfo.isHedge)
   		MyInfo.buyHedge.lastHedegeIndex = MathMax(MyPositionInfo.index,MyInfo.buyHedge.lastHedegeIndex);
	   if(MyPositionInfo.isMRT
	   && MyPositionInfo.orderType == 0)
	      MyInfo.buyHedge.lastMRT=MathMax(MyInfo.buyHedge.lastMRT,MyPositionInfo.n);
	      
	   if(MyPositionInfo.isHedge
	   && MyPositionInfo.orderType == 0
	   && MyPositionInfo.isLock)
	   {
	      MyInfo.buyHedge.capsuleAmount++;
	   }  
	   if(MyPositionInfo.isHedge
	   && MyPositionInfo.orderType == 0
	   && MyPositionInfo.isLock
	   && MyPositionInfo.index == MyInfo.buyHedge.index)
	   {
	      MyInfo.buyHedge.locked = true;
	   }
	   if(MyPositionInfo.isHedge
	   && MyPositionInfo.orderType != 0
	   &&!MyPositionInfo.isLock
	   && MyPositionInfo.index == MyInfo.buyHedge.index)
	   {
	      MyInfo.buyHedge.op = MyPositionInfo.op;
	      MyInfo.buyHedge.profit = MyPositionInfo.orderProfit;
	      MyInfo.buyHedge.tkt = MyPositionInfo.tkt;
	   }
	   MyInfo.buyHedge.allProfitSum+= MyPositionInfo.orderProfit;
	   MyInfo.buyHedge.allLotSum+= MyPositionInfo.lotSize*(MyPositionInfo.orderType?-1:1);
   }
   else
   {
   	if(CloseMainHedgeCapsuleFromBalance
   	&& MyPositionInfo.isHedge)
   	{
   		bool found = false;
   		int index = -1;
   		for(int i=0;i<capsuleAmountSell;i++)
   		{
   			index = i;
   			if(capsuleIndexSell[i] == MyPositionInfo.index)
   			{
   				found = true;
   				break;
   			}
   		}
   		if(!found)
   		{
   			capsuleAmountSell++;
   			index++;
   		}
   		if(MyPositionInfo.isLock)
   			capsuledSell[index] = true;
   	   capsuleProfitSell[index]+=MyPositionInfo.orderProfit;
   	   capsuleIndexSell[index] = MyPositionInfo.index;
   	}
   	
   	if(MyPositionInfo.isHedge)
   		MyInfo.sellHedge.lastHedegeIndex = MathMax(MyPositionInfo.index,MyInfo.sellHedge.lastHedegeIndex);
	   if(MyPositionInfo.isMRT
	   && MyPositionInfo.orderType == 1)
	      MyInfo.sellHedge.lastMRT=MathMax(MyInfo.sellHedge.lastMRT,MyPositionInfo.n);
	      
	   if(MyPositionInfo.isHedge
	   && MyPositionInfo.orderType == 1
	   && MyPositionInfo.isLock)
	   {
	      MyInfo.sellHedge.capsuleAmount++;
	   }  
	   if(MyPositionInfo.isHedge
	   && MyPositionInfo.orderType == 1
	   && MyPositionInfo.isLock
	   && MyPositionInfo.index == MyInfo.sellHedge.index)
	   {
	      MyInfo.sellHedge.locked = true;
	   }
	   if(MyPositionInfo.isHedge
	   && MyPositionInfo.orderType != 1
	   &&!MyPositionInfo.isLock
	   && MyPositionInfo.index == MyInfo.sellHedge.index)
	   {
	      MyInfo.sellHedge.op = MyPositionInfo.op;
	      MyInfo.sellHedge.profit = MyPositionInfo.orderProfit;
	      MyInfo.sellHedge.tkt= MyPositionInfo.tkt;
	   }
	   MyInfo.sellHedge.allProfitSum+= MyPositionInfo.orderProfit;
	   MyInfo.sellHedge.allLotSum+= MyPositionInfo.lotSize*(MyPositionInfo.orderType?-1:1);
   }
}
void ReFill(int type)
{
   bool dontOpen[];
   ArrayResize(dontOpen,22);
   for(int i=0;i<22;i++)
   {
      dontOpen[i]=false;
   }
   double op;
   double lot;
   bool open=false;
   for(int j=PositionsTotal()-1;j>=0;j--)
   {  
      if(!PositionSelectByTicket(PositionGetTicket(j)))continue;
      string comment = PositionGetString(POSITION_COMMENT);
      if(GetHedgeTkt(comment) == 0
      && GetHedgeN(comment) != 0
      && GetHedgeIndex(comment) == ((type?MyInfo.sellHedge.index:MyInfo.buyHedge.index))
      && PositionGetInteger(POSITION_TYPE) !=type
      && PositionGetInteger(POSITION_MAGIC) == Magic
      && PositionGetString(POSITION_SYMBOL) == Symbol())
      {
         dontOpen[GetHedgeN(comment)] = true;
         if(GetHedgeN(comment)==MyInfo.MainGridLastIndex)
         {
            lot = PositionGetDouble(POSITION_VOLUME)*100/MainGridPct[MyInfo.MainGridLastIndex];
            op = PositionGetDouble(POSITION_PRICE_OPEN);
            open = true;
         }
      }
   }
   if(!open)
   	return;
   
   double point = SymbolInfoDouble(Symbol(),SYMBOL_POINT);
   for(int i=1;i<=MyInfo.MainGridLastIndex;i++)
   {
      if(!dontOpen[i] 
      && MainGridPct[i]!=0.0
      &&(type == 0 && op+MainGridDistance[i-1]>SymbolInfoDouble(Symbol(),SYMBOL_ASK)/* && op+MainGridDistance[i-1]:GridDistance[i-1])-m_ReFillMaxDist<SymbolInfoDouble(Symbol(),SYMBOL_ASK)*/
      || type == 1 && op-MainGridDistance[i-1]<SymbolInfoDouble(Symbol(),SYMBOL_BID)/* && op-MainGridDistance[i-1]:GridDistance[i-1])+m_ReFillMaxDist>SymbolInfoDouble(Symbol(),SYMBOL_BID)*/))
      {
         double openLot = lot*MainGridPct[i]/100;
         MyPositionOpen(Symbol(),
         type?ORDER_TYPE_BUY:ORDER_TYPE_SELL,openLot,
         SymbolInfoDouble(Symbol(),type?SYMBOL_ASK:SYMBOL_BID),
         0,op+MainGridDistance[i]*(type?1:-1),"0-"+i+"^"+((type?MyInfo.sellHedge.index:MyInfo.buyHedge.index)),Magic);
         PrintLogs(__LINE__);
      }
   }
}

bool CheckCloseBySymbol()
{
   if(CloseAllOn_DD == 0
   && CloseAllOn_P == 0
   && UsePauseTradingByDD == 0)
      return false;
   if(UsePauseTradingByDD)
   {
      datetime updateTime = GetTime(UpdateTime);
      if(iBarShift(Symbol(),PERIOD_D1,MyInfo.lastUpdate)!=0
      && TimeCurrent()>updateTime)
      {
         MyInfo.lastUpdate = TimeCurrent();
         if(UseFromBalance
         || UseFromBalance_LVL2)
         {
         	MyInfo.pauseBalance = MyInfo.balance;
         }
         if(UseFromEquity
         || UseFromEquity_LVL2)
         {
         	MyInfo.pauseEquity = MyInfo.equity;
         }
         if(UseFromAVG
         || UseFromAVG_LVL2)
         {
         	MyInfo.pauseAVG = (MyInfo.equity+MyInfo.balance)/2;
         }
         
      }
      
		double ddStart = BigDDValue;
		double ddSL = SLAferBigDDValue;
		if(UseSLAfterBigDD == 2)
		{
			ddStart = MyInfo.balance*BigDDValue/100;
			ddSL = MyInfo.balance*SLAferBigDDValue/100;
		}
		if(UseSLAfterBigDD 
		&& !MyInfo.bigDDTriggered
		&& (MyInfo.balance-MyInfo.equity)>ddStart)
		{
			MyInfo.bigDDTriggered = true;
		}
		if(UseSLAfterBigDD
		&& MyInfo.balance-MyInfo.equity <= ddSL/2)
			MyInfo.bigDDTriggered = false;
			
		if(UseBasicDrawDown && MyInfo.balance*(1-BasicDrawDownPct/100)>MyInfo.equity
		|| UseFromBalance && MyInfo.pauseBalance*(1-FromBalancePct/100)>MyInfo.equity
		|| UseFromEquity && MyInfo.pauseEquity*(1-FromEquityPct/100)>MyInfo.equity
		|| UseFromAVG && MyInfo.pauseAVG*(1-FromAVGPct/100)>MyInfo.equity
		|| UseSLAfterBigDD && MyInfo.bigDDTriggered && (MyInfo.balance-MyInfo.equity)<ddSL)
		{
			CloseAll();
			MyInfo.bigDDTriggered = false;
      	MyInfo.pauseBalance = MyInfo.balance;
      	MyInfo.pauseEquity = MyInfo.equity;
      	MyInfo.pauseAVG = (MyInfo.equity+MyInfo.balance)/2;
         MyInfo.pauseTrading = 1;
         MyInfo.pauseTime = GetTime(UpdateTime)+ContinueTradeAfterHour*3600;
         PrintLogs(__LINE__+" Pause Trading MyInfo.balance Drow Down, MyInfo.pauseMyInfo.balance = " +DoubleToString(MyInfo.pauseBalance,2)
         +" MyInfo.pauseMyInfo.equity = " +DoubleToString(MyInfo.pauseEquity,2)+" MyInfo.pauseAVG = " +DoubleToString(MyInfo.pauseAVG,2)+" MyInfo.equity = "+DoubleToString(MyInfo.equity,2));
         
	      MyInfo.buyHedge.index = 0;
	      MyInfo.sellHedge.index = 0;
		      return true;
		}
		if(UseLevel2Triggers
		&&(UseBasicDrawDown_LVL2 && MyInfo.balance*(1-BasicDrawDownPct_LVL2/100)>MyInfo.equity
		|| UseFromBalance_LVL2 && MyInfo.pauseBalance*(1-FromBalancePct_LVL2/100)>MyInfo.equity
		|| UseFromEquity_LVL2 && MyInfo.pauseEquity*(1-FromEquityPct_LVL2/100)>MyInfo.equity
		|| UseFromAVG_LVL2 && MyInfo.pauseAVG*(1-FromAVGPct_LVL2/100)>MyInfo.equity))
		{
			bool confirmed = false;
			if(UseMarginTrigger && (MyInfo.equity-MyInfo.marginUsed)/MyInfo.equity*100>MarginTriggerPctAmount)
				confirmed = true;
			if(UseLockTrigger && MyInfo.haveLock)
				confirmed = true;
			if(UseLockCapsuleTrigger && MyInfo.haveLockCapsule)
				confirmed = true;
			if(UseMinTradeAmountTrigger && (MyInfo.buyMRT.lastN>MinTradeAmountTrigger || MyInfo.sellMRT.lastN>MinTradeAmountTrigger))
				confirmed = true;
			if(UseMATrigger && MyInfo.MATrigger)
				confirmed = true;
			if(confirmed)
			{
				CloseAll();
	      	MyInfo.pauseBalance = MyInfo.balance;
	      	MyInfo.pauseEquity = MyInfo.equity;
	      	MyInfo.pauseAVG = (MyInfo.equity+MyInfo.balance)/2;
	         MyInfo.pauseTrading = 1;
	         MyInfo.pauseTime = GetTime(UpdateTime)+ContinueTradeAfterHour*3600;
	         PrintLogs(__LINE__+" Pause Trading MyInfo.balance Drow Down, MyInfo.pauseMyInfo.balance = " +DoubleToString(MyInfo.pauseBalance,2)
	         +" MyInfo.pauseMyInfo.equity = " +DoubleToString(MyInfo.pauseEquity,2)+" MyInfo.pauseAVG = " +DoubleToString(MyInfo.pauseAVG,2)+" MyInfo.equity = "+DoubleToString(MyInfo.equity,2));
	         
		      MyInfo.buyHedge.index = 0;
		      MyInfo.sellHedge.index = 0;
		      return true;
	      }
		}
   }  
   if(CloseAllOn_DD)
   {
      double goal = CloseAllOnAmount_DD;
      if(CloseAllOn_DD == 2)
         goal = MyInfo.equity*CloseAllOnAmount_DD/100;
      if(MyInfo.wholeOpenProfit<=goal*(-1))
      {
			CloseAll();
	      MyInfo.buyHedge.index = 0;
	      MyInfo.sellHedge.index = 0;
         if(DisableAutoTradeOn_DD)
            AlgoTradingStatus(false);
         PrintLogs(__LINE__);
         return true;
      }
   }
   
   if(CloseAllOn_P)
   {
      double goal = CloseAllOnAmount_P;
      if(CloseAllOn_P == 2)
         goal = MyInfo.equity*CloseAllOnAmount_P/100;
      if(MyInfo.wholeOpenProfit>=goal)
      {
			CloseAll();
	      MyInfo.buyHedge.index = 0;
	      MyInfo.sellHedge.index = 0;
         if(DisableAutoTradeOn_P)
            AlgoTradingStatus(false);
         PrintLogs(__LINE__);
         return true;
      }
   }
   return false;
}

datetime GetTime(string time,int day = 0)
{
   datetime dt = StringToTime(time);
   MqlDateTime mqldt;
   TimeToStruct(StringToTime(time),mqldt);
   return iTime(Symbol(),PERIOD_D1,day)+mqldt.hour*3600+mqldt.min*60;
}

void ReOpenHedge(bool count=true)
{	
	if(!MainUseReOpen)
   {
		MyInfo.buyHedge.reOpen =false;	
		MyInfo.sellHedge.reOpen =false;	
		return;
	}
	if(count)
	{
   	if(MyPositionInfo.type == 0)
   	{
   		if(MyPositionInfo.index == MyInfo.buyHedge.index
   		&& MyPositionInfo.n == MyInfo.MainGridLastIndex
   		&& MyInfo.buyHedge.lastHedgeDT < MyPositionInfo.ot
   		&& MyPositionInfo.ot>MyInfo.startTimeBuy)
   		{
   			MyInfo.buyHedge.lastHedgeDT = MyPositionInfo.ot;
   			MyInfo.buyHedge.lastHedgePositionID = MyPositionInfo.positionID;
   		}
   	}
   	else
   	{
   		if(MyPositionInfo.index == MyInfo.sellHedge.index
   		&& MyPositionInfo.n == MyInfo.MainGridLastIndex
   		&& MyInfo.sellHedge.lastHedgeDT < MyPositionInfo.ot
   		&& MyPositionInfo.ot>MyInfo.startTimeSell)
   		{
   			MyInfo.sellHedge.lastHedgeDT = MyPositionInfo.ot;
   			MyInfo.sellHedge.lastHedgePositionID = MyPositionInfo.positionID;
   		}
   	}
	   return;
   }
   if(MyInfo.buyHedge.lastHedgePositionID)
   {
   	HistorySelectByPosition(MyInfo.buyHedge.lastHedgePositionID);
		int total = HistoryDealsTotal()-1;
	   for(int i=total;i>=0;i--)
	   {
	   	ulong tkt = HistoryDealGetTicket(i);
	   	if(tkt<1)continue;
	   	if(HistoryDealGetInteger(tkt,DEAL_ENTRY) == DEAL_ENTRY_OUT)
	   	{
	   		MyInfo.buyHedge.reOpen = HistoryDealGetDouble(tkt,DEAL_PRICE)-m_MainReOpenDistance>SymbolInfoDouble(Symbol(),SYMBOL_ASK);
	   		
			   break;
	   	}
	  	}
   }
   if(MyInfo.sellHedge.lastHedgePositionID)
   {
   	HistorySelectByPosition(MyInfo.sellHedge.lastHedgePositionID);
		int total = HistoryDealsTotal()-1;
	   for(int i=total;i>=0;i--)
	   {
	   	ulong tkt = HistoryDealGetTicket(i);
	   	if(tkt<1)continue;
	   	if(HistoryDealGetInteger(tkt,DEAL_ENTRY) == DEAL_ENTRY_OUT)
	   	{
	   		MyInfo.sellHedge.reOpen = HistoryDealGetDouble(tkt,DEAL_PRICE)+m_MainReOpenDistance<SymbolInfoDouble(Symbol(),SYMBOL_ASK);
	   		
			   break;
	   	}
	  	}
   }
   
}

int GetCapsuleIndex(string txt)
{
   return StringToInteger(StringSubstr(txt,StringFind(txt,"^")+1));
}
int GetCapsuleTkt(string txt)
{
   return StringToInteger(StringSubstr(txt,0,StringFind(txt,"-")));
}
int GetCapsuleN(string txt)
{
   return StringToInteger(StringSubstr(txt,StringFind(txt,"#")+1,StringFind(txt,"^")-StringFind(txt,"#")-1));
}

int GetHedgeIndex(string txt)
{
   return StringToInteger(StringSubstr(txt,StringFind(txt,"^")+1));
}
int GetHedgeTkt(string txt)
{
   return StringToInteger(StringSubstr(txt,0,StringFind(txt,"-")));
}
int GetHedgeN(string txt)
{
   return StringToInteger(StringSubstr(txt,StringFind(txt,"-")+1,StringFind(txt,"^")-StringFind(txt,"-")-1));
}
datetime once=0;
bool Once()
{
   if(iBarShift(Symbol(),OncePerCandleTF,once)!=iBarShift(Symbol(),OncePerCandleTF,TimeCurrent()))
   {
      once = TimeCurrent();
      return true;
   }
   return false;
}




ulong MyPositionOpen(string symbol,ENUM_ORDER_TYPE type,double volume,double price,double sl,double tp,string comment,int magic)
{
   myTrade.SetExpertMagicNumber(magic);
   if(sl<0)
      sl = Point();
   if(tp<0)
      tp = Point();
   myTrade.PositionOpen(symbol,type,RoundLot(symbol,volume),price,sl,tp,comment);
   return myTrade.ResultOrder();
}
double RoundLot(string symbol,double lot)
{
   double t = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   int n = 0;
   while(t<1)
   {
      t*=10;
      n++;
   }
   lot = NormalizeDouble(lot,n);
   lot = MathMax(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN),lot);
   lot = MathMin(GetMaxLot(),lot);
   return lot;
}
double GetMaxLot()
{
	return MathMin(MaxLotSize,SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX));
}

bool MyPartialClose(const ulong ticket,const double volume,string com ="")
  {
//--- check position existence
   if(!PositionSelectByTicket(ticket))
      return(false);
   string symbol=PositionGetString(POSITION_SYMBOL);
   
   MqlTradeRequest   m_request; 
   MqlTradeResult    m_result;
   ZeroMemory(m_request);
   ZeroMemory(m_result);
   if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
     {
      //--- prepare request for close BUY position
      m_request.type =ORDER_TYPE_SELL;
      m_request.price=SymbolInfoDouble(PositionGetString(POSITION_SYMBOL),SYMBOL_BID);
     }
   else
     {
      //--- prepare request for close SELL position
      m_request.type =ORDER_TYPE_BUY;
      m_request.price=SymbolInfoDouble(PositionGetString(POSITION_SYMBOL),SYMBOL_ASK);
     }
//--- check volume
   double position_volume=PositionGetDouble(POSITION_VOLUME);
   if(position_volume>volume)
      position_volume=volume;
//--- setting request
   if(com == "")
   	com = PositionGetString(POSITION_COMMENT);
   m_request.action   =TRADE_ACTION_DEAL;
   m_request.position =ticket;
   m_request.symbol   =PositionGetString(POSITION_SYMBOL);
   m_request.volume   =RoundLot(PositionGetString(POSITION_SYMBOL),position_volume);
   m_request.magic    =PositionGetInteger(POSITION_MAGIC);
   m_request.comment    = com;
//--- close position
   if(!FillingCheck(symbol,m_request,m_result))
   {
      PrintLogs("Filling Error");
      return 0;
   }
   return(OrderSend(m_request,m_result));
  }
bool MyPositionClose(const ulong ticket)
  {
//--- check position existence
   if(!PositionSelectByTicket(ticket))
      return(false);
   string symbol=PositionGetString(POSITION_SYMBOL);
//--- clean

   MqlTradeRequest   m_request; 
   MqlTradeResult    m_result;
   ZeroMemory(m_request);
   ZeroMemory(m_result);
//--- check filling
//--- check
   if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
     {
      //--- prepare request for close BUY position
      m_request.type =ORDER_TYPE_SELL;
      m_request.price=SymbolInfoDouble(symbol,SYMBOL_BID);
     }
   else
     {
      //--- prepare request for close SELL position
      m_request.type =ORDER_TYPE_BUY;
      m_request.price=SymbolInfoDouble(symbol,SYMBOL_ASK);
     }
//--- setting request
   m_request.action   =TRADE_ACTION_DEAL;
   m_request.position =ticket;
   m_request.symbol   =symbol;
   m_request.volume   =PositionGetDouble(POSITION_VOLUME);
   m_request.comment = PositionGetString(POSITION_COMMENT);
   m_request.magic    =PositionGetInteger(POSITION_MAGIC);
   m_request.deviation=0;
   
   if(!FillingCheck(symbol,m_request,m_result))
      return(false);
//--- close position
   return(OrderSend(m_request,m_result));
  }  
bool FillingCheck(const string symbol,MqlTradeRequest &m_request,MqlTradeResult &m_result)
  {
   ENUM_ORDER_TYPE_FILLING m_type_filling = ORDER_FILLING_FOK;
//--- get execution mode of orders by symbol
   ENUM_SYMBOL_TRADE_EXECUTION exec=(ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(symbol,SYMBOL_TRADE_EXEMODE);
//--- check execution mode
   if(exec==SYMBOL_TRADE_EXECUTION_REQUEST || exec==SYMBOL_TRADE_EXECUTION_INSTANT)
     {
      //--- neccessary filling type will be placed automatically
      return(true);
     }
//--- get possible filling policy types by symbol
   uint filling=(uint)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- check execution mode again
   if(exec==SYMBOL_TRADE_EXECUTION_MARKET)
     {
      //--- for the MARKET execution mode
      //--- analyze order
      if(m_request.action!=TRADE_ACTION_PENDING)
        {
         //--- in case of instant execution order
         //--- if the required filling policy is supported, add it to the request
         if((filling&SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK)
           {
            m_type_filling=ORDER_FILLING_FOK;
            m_request.type_filling=m_type_filling;
            return(true);
           }
         if((filling&SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC)
           {
            m_type_filling=ORDER_FILLING_IOC;
            m_request.type_filling=m_type_filling;
            return(true);
           }
         //--- wrong filling policy, set error code
         m_result.retcode=TRADE_RETCODE_INVALID_FILL;
         return(false);
        }
      return(true);
     }
//--- EXCHANGE execution mode
   switch(m_type_filling)
     {
      case ORDER_FILLING_FOK:
         //--- analyze order
         if(m_request.action==TRADE_ACTION_PENDING)
           {
            //--- in case of pending order
            //--- add the expiration mode to the request
            if(!ExpirationCheck(symbol,m_request))
               m_request.type_time=ORDER_TIME_DAY;
            //--- stop order?
            if(m_request.type==ORDER_TYPE_BUY_STOP || m_request.type==ORDER_TYPE_SELL_STOP ||
               m_request.type==ORDER_TYPE_BUY_LIMIT || m_request.type==ORDER_TYPE_SELL_LIMIT)
              {
               //--- in case of stop order
               //--- add the corresponding filling policy to the request
               m_request.type_filling=ORDER_FILLING_RETURN;
               return(true);
              }
           }
         //--- in case of limit order or instant execution order
         //--- if the required filling policy is supported, add it to the request
         if((filling&SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK)
           {
            m_request.type_filling=m_type_filling;
            return(true);
           }
         //--- wrong filling policy, set error code
         m_result.retcode=TRADE_RETCODE_INVALID_FILL;
         return(false);
      case ORDER_FILLING_IOC:
         //--- analyze order
         if(m_request.action==TRADE_ACTION_PENDING)
           {
            //--- in case of pending order
            //--- add the expiration mode to the request
            if(!ExpirationCheck(symbol,m_request))
               m_request.type_time=ORDER_TIME_DAY;
            //--- stop order?
            if(m_request.type==ORDER_TYPE_BUY_STOP || m_request.type==ORDER_TYPE_SELL_STOP ||
               m_request.type==ORDER_TYPE_BUY_LIMIT || m_request.type==ORDER_TYPE_SELL_LIMIT)
              {
               //--- in case of stop order
               //--- add the corresponding filling policy to the request
               m_request.type_filling=ORDER_FILLING_RETURN;
               return(true);
              }
           }
         //--- in case of limit order or instant execution order
         //--- if the required filling policy is supported, add it to the request
         if((filling&SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC)
           {
            m_request.type_filling=m_type_filling;
            return(true);
           }
         //--- wrong filling policy, set error code
         m_result.retcode=TRADE_RETCODE_INVALID_FILL;
         return(false);
      case ORDER_FILLING_RETURN:
         //--- add filling policy to the request
         m_request.type_filling=m_type_filling;
         return(true);
     }
//--- unknown execution mode, set error code
   m_result.retcode=TRADE_RETCODE_ERROR;
   return(false);
  }
bool ExpirationCheck(const string symbol,MqlTradeRequest &m_request)
  {
   CSymbolInfo sym;
//--- check symbol
   if(!sym.Name((symbol==NULL)?Symbol():symbol))
      return(false);
//--- get flags
   int flags=sym.TradeTimeFlags();
//--- check type
   switch(m_request.type_time)
     {
      case ORDER_TIME_GTC:
         if((flags&SYMBOL_EXPIRATION_GTC)!=0)
         return(true);
         break;
      case ORDER_TIME_DAY:
         if((flags&SYMBOL_EXPIRATION_DAY)!=0)
         return(true);
         break;
      case ORDER_TIME_SPECIFIED:
         if((flags&SYMBOL_EXPIRATION_SPECIFIED)!=0)
         return(true);
         break;
      case ORDER_TIME_SPECIFIED_DAY:
         if((flags&SYMBOL_EXPIRATION_SPECIFIED_DAY)!=0)
         return(true);
         break;
      default:
         PrintLogs(__FUNCTION__+": Unknown expiration type");
         break;
     }
//--- failed
   return(false);
  }
  
bool HLineCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="HLine",      // line name
                 const int             sub_window=0,      // subwindow index
                 double                price=0,           // line price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
   
   ObjectDelete(chart_ID,name);
//--- reset the error value
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      PrintLogs(__FUNCTION__+
            ": failed to create a horizontal line! Error code = "+GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
bool ButtonCreate(const long              chart_ID=0,               // chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            text="Button",            // text
                  const string            font="Arial",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=true,              // hidden in the object list
                  const long              z_order=0)                // priority for mouse click
  {
   ObjectDelete(chart_ID,name);
//--- reset the error value
   ResetLastError();
//--- create the button
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      PrintLogs(__FUNCTION__+
            ": failed to create the button! Error code = "+GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }