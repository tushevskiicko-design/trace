//+------------------------------------------------------------------+
//|                                       Trace Institucional EA.mq4 |
//|                              Copyright 2025, Trace Institucional |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
#define OBJPROP_BOLD 104

//+------------------------------------------------------------------+
//| STRUCTURES                                                       |
//+------------------------------------------------------------------+
struct ZoneInfo {
   string   zoneType;
   string   fingerprint;
   int      timeframe;
   double   top;
   double   bottom;
   double   entryPrice;
   double   stopLoss;
   double   takeProfit;
   int      breakoutBar;
   int      baseStartBar;
   int      baseEndBar;
   datetime startTime;
   datetime breakoutTime;
   double   strength;
   double   bosStrength;
   bool     bosConfirmed;
   bool     isElite;
   bool     breaker;
   bool     tpHit;
   int      touches;
   int      uniqueID;
   bool     slHit;
   datetime hitTime;
   bool     isTraded;
   double   relativeVolume;
   string   slName;
   string   tpName;
   string   slTextName;
   string   tpTextName;
};

//+------------------------------------------------------------------+
//| INPUT PARAMETERS                                                 |
//+------------------------------------------------------------------+
input string Input_OB                      = "Order Blocks------------";
input bool   Use_OrderBlocks               = true;
input bool   OB_ApplyAntiFakeFilter        = true;
input int    OB_LookbackBars               = 1440;
input int    Zone_ExpiryBars               = 1440;
input int    OB_LastCount                  = 1440;
input bool   OB_UseBody                    = false;
input int    OB_PivotLen                   = 1;
input double OB_TightenPct                 = 0.00;
input int    OB_ExtendBars                 = 5;
input bool   OB_MinGapFilter               = true;
input double OB_MinGapATR                  = 1.00;
input bool   OB_FilterWeakBreakouts        = true;
input double OB_MinDisplacementATR         = 1.20;
input double OB_MinCloseStrength           = 0.50;
input double OB_MinBodyRatio               = 0.45;
input bool   OB_SideFilter                 = true;
input double OB_SideToleranceATR           = 2.00;
input bool   OB_OppositeGapFilter          = true;
input double OB_OppositeGapATR             = 1.00;
input double OB_MinZoneHeightATR           = 1.00;
input double OB_MaxZoneHeightATR           = 5.00;
input string OB_MitigationMethod           = "Wick";
input bool   OB_HideMitigated              = false;
input bool   OB_HideOverlap                = true;
input string OB_WhichOverlap               = "Recent";
input bool   OB_ShowMidLine                = false;
input color  OB_BullColor                  = clrGreen;
input color  OB_BearColor                  = clrRed;

input string Input_AntiFake                = "Anti Fake Zone Filter------------";
input bool   Use_AntiFakeFilter            = true;
input int    AntiFake_MaxSoftFails         = 7;
input bool   AntiFake_BlockBrokenZones     = true;
input bool   AntiFake_RequireCleanDeparture= true;
input double AntiFake_MinDepartureATR      = 4.00;
input int    AntiFake_DepartureBars        = 5;
input bool   AntiFake_BlockChop            = false;
input bool   AntiFake_BlockChopNow         = true;
input bool   AntiFake_BlockBBSqueeze       = true;
input int    AntiFake_BB_TF                = 240;
input int    AntiFake_BB_Period            = 20;
input double AntiFake_BB_Dev               = 2.0;
input double AntiFake_MinBBWidthATR        = 3.00;
input int    AntiFake_ChopLookback         = 80;
input double AntiFake_MinRangeATR          = 4.00;
input int    AntiFake_MaxColorChanges      = 1;
input bool   AntiFake_BlockCounterTrend    = true;

input string Input_ImpulseBase             = "Impulse-to-Base Ratio Filter------------";
input bool   Use_ImpulseBaseRatioFilter    = true;
input double IBR_MinRatio                  = 4.00;
input int    IBR_ImpulseBars               = 4;
input double IBR_MinImpulseATR             = 4.00;

input string Input_Consolidation           = "Consolidation Filter------------";
input bool   Use_ConsolidationFilter       = true;
input bool   Consol_BlockFlatEMA           = true;
input int    Consol_EMA_Period             = 50;
input int    Consol_EMA_SlopeBars          = 10;
input double Consol_MaxEMASlopeATR         = 0.15;
input bool   Consol_BlockTightRange        = true;
input int    Consol_RangeLookback          = 50;
input double Consol_MaxRangeATR            = 2.00;
input bool   Consol_BlockZoneStacking      = true;
input int    Consol_StackMaxZones          = 4;
input int    Consol_StackATRDistance       = 2;
input bool   Consol_BlockInsideBarCluster  = true;
input int    Consol_InsideBarCount         = 3;
input int    Consol_InsideBarLookback      = 50;

input string Input_StrongBreakout          = "Strong Breakout Filter------------";
input bool   Use_StrongBreakoutFilter      = true;
input double SB_MinBodyRatio               = 0.55;
input double SB_MinCloseStrength           = 0.60;
input double SB_MinBreakoutATR             = 1.20;
input bool   SB_RequireVolumeSpike         = true;
input double SB_MinVolumeRatio             = 1.20;
input int    SB_VolumeLookback             = 30;
input bool   SB_RequireFollowThrough       = true;
input int    SB_FollowThroughBars          = 2;
input double SB_MinFollowATR               = 0.50;

input string Input_HTFConfluence           = "HTF Confluence Filter------------";
input bool   Use_HTFConfluenceFilter       = true;
input bool   HTF_RequireTrendAlignment     = true;
input bool   HTF_RequireZoneAlignment      = true;
input double HTF_ZoneProximityATR          = 2.00;
input bool   HTF_BlockCounterHTF           = true;

input string Input_VolExhaustion           = "Volume Exhaustion Filter------------";
input bool   Use_VolExhaustionFilter       = true;
input bool   VEx_RequireDecliningVolume    = true;
input int    VEx_BaseBarsToCheck           = 5;
input double VEx_MaxBaseVolRatio           = 0.90;
input bool   VEx_BlockLowVolumeBreakout    = true;
input double VEx_MinBreakoutVolRatio       = 1.20;

input string Input_FailedRetest            = "Failed Retest Filter------------";
input bool   Use_FailedRetestFilter        = true;
input int    FR_LookbackBars               = 20;
input double FR_MinPenetrationATR          = 0.40;
input int    FR_MaxPenetrations            = 2;

input string Input_WickStrength            = "Wick Strength Filter------------";
input bool   Use_WickStrengthFilter        = true;
input int    WS_LookbackBars               = 20;
input double WS_MaxWickPenetrations        = 3;
input double WS_WickPenetrationPct         = 0.30;

input string Input_NewsSpike               = "News Spike Filter------------";
input bool   Use_NewsSpikeFilter           = true;
input int    News_ATR_Period               = 14;
input double News_SpikeATRMultiplier       = 2.50;
input int    News_SpikeLookbackBars        = 20;
input int    News_CooldownBars             = 10;
input bool   News_BlockAllDuringSpike      = true;

input string Input_AdaptiveSession         =  "Adaptive Session Filter------------";
input bool   Use_AdaptiveSessionFilter     = true;
input double Asia_MinBreakoutATR           = 1.40;
input double London_MinBreakoutATR         = 1.20;
input double NY_MinBreakoutATR             = 1.10;
input double Asia_MinBodyRatio             = 0.60;
input double London_MinBodyRatio           = 0.55;
input double NY_MinBodyRatio               = 0.52;
input double Asia_MinDepartureATR          = 1.40;
input double London_MinDepartureATR        = 1.20;
input double NY_MinDepartureATR            = 1.00;
input bool   Session_BlockOffHours         = true;
input int    Asia_StartHour                = 0;
input int    Asia_EndHour                  = 9;
input int    London_StartHour              = 9;
input int    London_EndHour                = 16;
input int    NY_StartHour                  = 16;
input int    NY_EndHour                    = 23;

input string Input_FirstZoneCooldown       = "First Zone Cooldown------------";
input bool   Use_FirstZoneCooldown         = true;
input int    FZC_MinBarsSinceLastZone      = 12;
input int    FZC_ExtraConfirmBars          = 1;
input double FZC_MinFirstZoneStrength      = 5.00;

input string Input_AdaptiveATR             = "Adaptive ATR Filter------------";
input bool   Use_AdaptiveATRFilter         = true;
input int    AATR_PercentileLookback       = 500;
input double AATR_LowVolPercentile         = 25.0;
input double AATR_HighVolPercentile        = 75.0;
input double AATR_LowVolMultiplier         = 1.20;
input double AATR_HighVolMultiplier        = 0.90;

input string Input_DayOfWeekFilter         = "Day of Week Filter------------";
input bool   Use_DayOfWeekFilter           = true;
input double DOW_MondayMultiplier          = 1.15;
input double DOW_FridayMultiplier          = 1.15;
input double DOW_TueThuMultiplier          = 1.00;
input bool   DOW_BlockFridayAfterNY        = true;
input int    DOW_FridayCutoffHour          = 20;

input string Input_VolatilityRegime        = "Volatility Regime Filter------------";
input bool   Use_VolatilityRegimeFilter    = true;
input int    VR_RegimeLookback             = 50;
input double VR_LowVolThreshold            = 0.80;
input double VR_HighVolThreshold           = 1.40;
input double VR_LowVolMinBreakoutATR       = 1.50;
input double VR_LowVolMinBodyRatio         = 0.60;
input double VR_HighVolMinBreakoutATR      = 1.00;

input string Input_FVGConfirmation         = "FVG Confirmation Filter------------";
input bool   Use_FVGConfirmationFilter     = true;
input bool   FVG_RequireFVG                = true;
input int    FVG_LookbackBars              = 10;
input double FVG_MinGapATR                 = 0.25;
input bool   FVG_RequireDisplacement       = true;
input double FVG_DisplacementATR           = 1.20;
input int    FVG_DisplacementBars          = 3;

input string Input_BOSConfirmation         = "BOS Quality / Strength------------";
input bool   Use_BOSConfirmationFilter     = true;
input int    BOS_LookbackBars              = 3;
input double BOS_MinBreakATR               = 0.20;
input int    BOS_SwingLookback             = 40;
input double BOS_MaxStrengthBonus          = 1.50;

input string Input_BOSPerTF                = "BOS Per Timeframe------------";
input int    BOS_LookbackBars_D1           = 3;
input int    BOS_LookbackBars_H4           = 3;
input int    BOS_LookbackBars_H1           = 3;
input int    BOS_LookbackBars_M15          = 3;
input int    BOS_LookbackBars_M5           = 3;
input int    BOS_LookbackBars_M1           = 3;
input double BOS_MinBreakATR_D1            = 0.20;
input double BOS_MinBreakATR_H4            = 0.20;
input double BOS_MinBreakATR_H1            = 0.20;
input double BOS_MinBreakATR_M15           = 0.20;
input double BOS_MinBreakATR_M5            = 0.20;
input double BOS_MinBreakATR_M1            = 0.20;
input int    BOS_SwingLookback_D1          = 40;
input int    BOS_SwingLookback_H4          = 40;
input int    BOS_SwingLookback_H1          = 40;
input int    BOS_SwingLookback_M15         = 40;
input int    BOS_SwingLookback_M5          = 40;
input int    BOS_SwingLookback_M1          = 40;
input double BOS_MaxStrengthBonus_D1       = 1.50;
input double BOS_MaxStrengthBonus_H4       = 1.50;
input double BOS_MaxStrengthBonus_H1       = 1.50;
input double BOS_MaxStrengthBonus_M15      = 1.50;
input double BOS_MaxStrengthBonus_M5       = 1.50;
input double BOS_MaxStrengthBonus_M1       = 1.50;

input string Input_MarketStructure         = "Market Structure Trend Gate------------";
input bool   Use_MarketStructureTrendGate  = true;
input int    MS_SwingStrength              = 2;
input int    MS_LookbackBars               = 120;
input double MS_BOSBufferATR               = 0.15;
input int    MS_SwingStrength_D1           = 2;
input int    MS_SwingStrength_H4           = 2;
input int    MS_SwingStrength_H1           = 2;
input int    MS_SwingStrength_M15          = 2;
input int    MS_SwingStrength_M5           = 2;
input int    MS_SwingStrength_M1           = 2;
input int    MS_LookbackBars_D1            = 120;
input int    MS_LookbackBars_H4            = 120;
input int    MS_LookbackBars_H1            = 120;
input int    MS_LookbackBars_M15           = 120;
input int    MS_LookbackBars_M5            = 120;
input int    MS_LookbackBars_M1            = 120;
input double MS_BOSBufferATR_D1            = 0.15;
input double MS_BOSBufferATR_H4            = 0.15;
input double MS_BOSBufferATR_H1            = 0.15;
input double MS_BOSBufferATR_M15           = 0.15;
input double MS_BOSBufferATR_M5            = 0.15;
input double MS_BOSBufferATR_M1            = 0.15;

input string Input_BodyClearance           = "Body Clearance Filter------------";
input bool   Use_BodyClearanceFilter       = true;
input double BC_MinClearancePct            = 0.70;

input string Input_MinHoldTime             = "Minimum Hold Time Filter------------";
input bool   Use_MinHoldTimeFilter         = true;
input int    MHT_MinHoldBars               = 5;
input double MHT_MaxWickPct                = 0.50;

input string Input_ChopIndex               = "Choppiness Index Filter------------";
input bool   Use_ChopIndexFilter           = true;
input int    CI_Period                     = 14;
input double CI_ChopThreshold              = 61.8;
input double CI_TrendThreshold             = 38.2;
input bool   CI_BlockChopZones             = true;
input bool   CI_RequireTrendConfirmation   = true;

input string Input_Autocorrelation         = "--- Autocorrelation Filter------------";
input bool   Use_AutocorrelationFilter     = true;
input int    AC_Lookback                   = 50;
input int    AC_Lag                        = 1;
input double AC_TrendThreshold             = 0.10;
input double AC_ChopThreshold              = -0.10;
input bool   AC_BlockNegativeAC            = true;

input string Input_EfficiencyRatio         = "Kaufman Efficiency Ratio Filter------------";
input bool   Use_EfficiencyRatioFilter     = true;
input int    ER_Period                     = 20;
input double ER_MinTrendRatio              = 0.25;
input double ER_ChopRatio                  = 0.15;
input bool   ER_BlockLowEfficiency         = true;

input string Input_RSIMidRange             = "RSI Mid-Range Trap Filter------------";
input bool   Use_RSIMidRangeFilter         = true;
input int    RSI_MR_Period                 = 14;
input double RSI_MR_LowBound               = 45.0;
input double RSI_MR_HighBound              = 55.0;
input int    RSI_MR_ConsecutiveBars        = 10;
input bool   RSI_MR_BlockTrapped           = true;

input string Input_PriceLocation           = "Price Location Filter------------";
input bool   Use_PriceLocationFilter       = true;
input int    PL_RangeLookback              = 50;
input double PL_MidZonePct                 = 0.25;
input bool   PL_BlockMidRange              = true;

input string Input_Exhaustion              = "Trend Exhaustion Filter------------";
input bool   Use_ExhaustionFilter          = true;
input int    Exh_Lookback                  = 200;
input double Exh_MinRoomATR                = 2.00;

input string Input_LiquiditySweep          = "Liquidity Sweep Filter------------";
input bool   Use_LiquiditySweepFilter      = true;
input bool   Sweep_StrictMode              = false;
input double Sweep_MinScore                = 1.5;
input int    Sweep_Lookback                = 50;
input double Sweep_MinBreakPoints          = 20.0;
input bool   Sweep_RequireCloseBack        = true;
input bool   Sweep_RequireOppositeCandle   = true;
input double Sweep_MinSweepBodyATR         = 0.80;
input double Sweep_MinBreakoutBodyATR      = 0.80;
input int    Sweep_VolumeLookback          = 20;
input double Sweep_MinVolumeRatio          = 1.50;
input double Sweep_CloseBackATR            = 0.10;

input string Input_RV                      = "Relative Volume Filter------------";
input bool   Use_RVFilter                  = true;
input bool   RV_StrictMode                 = true;
input int    RV_LookbackBars               = 80;
input double RV_MinRatio                   = 1.2;

input string Input_DeltaCVD                = "Delta / CVD Tick-Volume Quality------------";
input bool   Use_DeltaCVDScore             = true;
input int    DCVD_LookbackBars             = 20;
input int    DCVD_RecentBars               = 5;
input double DCVD_ConfirmRatio             = 0.10;
input double DCVD_StrongRatio              = 0.25;
input double DCVD_MaxStrengthBonus         = 1.00;
input double DCVD_MaxStrengthPenalty       = 1.00;

input string Input_VolDivergence           = "Volume Divergence Filter------------";
input bool   Use_VolumeDivergenceFilter    = true;
input bool   VD_BlockTradesOnly            = true;   // true = zone stays drawn, only the trade is blocked
input bool   VD_CountAsSoftFail            = true;   // also count divergence as one AntiFake soft fail
input bool   VD_CheckPriceVolumeDivergence = true;   // new price extreme on lower impulse volume
input bool   VD_CheckClimaxExhaustion      = true;   // huge volume + tiny body = exhaustion
input int    VD_SwingLookback              = 60;     // bars searched for the previous impulse extreme
input int    VD_ImpulseBars                = 3;      // bars summed as one "impulse volume"
input double VD_MinDropPct                 = 0.25;   // 0.25 = new extreme on 25% less volume -> divergence
input double VD_ClimaxVolRatio             = 2.50;   // volume spike vs average ...
input double VD_ClimaxMaxBodyRatio         = 0.30;   // ... combined with this small a body
input double VD_StrengthPenalty            = 1.00;   // score penalty per divergence type

input string Input_MSS                     = "Market Structure Shift Filter------------";
input bool   Use_MSSFilter                 = true;
input bool   MSS_StrictMode                = true;
input int    MSS_PivotLookback             = 100;
input double MSS_MinBreakoutATR            = 0.30;

input string Input_WickRejection           = "Breakout Wick Rejection Filter------------";
input bool   Use_BreakoutWickRejection     = true;   // kills the classic gold liquidity-grab fake zone
input double WR_MaxBreakWickPct            = 0.35;   // wick in the breakout direction, as part of the candle range
input double WR_MaxOppositeWickPct         = 0.45;   // wick against the breakout direction
input double WR_MinBodyPct                 = 0.45;   // body must be at least this part of the range
input bool   WR_CheckFollowBar             = true;   // the bar after the breakout must not close back through the break level
input int    WR_FollowBars                 = 2;      // how many bars after the breakout are checked

input string Input_ATRAccel                = "ATR Acceleration Filter------------";
input bool   Use_ATRAccelerationFilter     = true;   // real displacement expands volatility
input int    AAC_FastATR                   = 5;      // ATR right around the breakout
input int    AAC_SlowATR                   = 50;     // background ATR
input double AAC_MinRatio                  = 1.15;   // fast/slow ATR must be at least this
input double AAC_MinRangeATR               = 1.20;   // breakout candle range vs the slow ATR
input bool   AAC_BlockDecelerating         = true;   // block when volatility is shrinking into the breakout

input string Input_Regime                  = "Market Regime (Zone Filter)------------";
input bool   Use_RegimeFilter              = true;
input bool   Regime_ApplyToNewZonesOnly    = false;
input int    Regime_ADX_TF                 = PERIOD_H4;
input int    Regime_ADX_Period             = 14;
input double Regime_MinADX                 = 20.0;
input bool   Regime_RequireValidADX        = true;
input bool   Regime_FilterSpread           = true;
input double Regime_MaxSpreadPrice         = 0.20;
input bool   Regime_FilterATR              = true;
input int    Regime_ATR_TF                 = PERIOD_H1;
input int    Regime_ATR_Period             = 14;
input int    Regime_ATR_Lookback           = 50;
input double Regime_ATR_MinRatio           = 0.80;
input bool   Regime_FilterRestoredZones    = true;

input string Input_DailyLevels             = "Daily Levels (High/Low/Mid)------------";
input bool   Use_DailyLevels               = true;
input bool   DL_UseCurrentDay              = true;
input int    DL_ShiftBars                  = 0;
input int    DL_FutureBars                 = 100;
input bool   DL_ExtendRight                = false;
input int    DL_HShiftBars                 = 0;
input int    DL_LabelShiftBars             = 20;
input bool   DL_ShowLabels                 = true;
input bool   DL_ShowPrice                  = true;
input bool   DL_LabelAbove                 = false;
input bool   DL_ShowHigh                   = true;
input bool   DL_ShowLow                    = true;
input bool   DL_ShowMid                    = true;
input bool   DL_ShowLowMid                 = true;
input bool   DL_ShowMidHigh                = true;
input color  DL_HighColor                  = clrLimeGreen;
input color  DL_LowColor                   = clrBrown;
input color  DL_MidColor                   = clrCornflowerBlue;
input color  DL_LowMidColor                = clrPeru;
input color  DL_MidHighColor               = clrOrange;
input int    DL_LineWidth                  = 3;
input int    DL_SubLineWidth               = 1;
input string DL_HighLabel                  = "High";
input string DL_LowLabel                   = "Low";
input string DL_MidLabel                   = "Mid";
input string DL_LowMidLabel                = "Low-Mid";
input string DL_MidHighLabel               = "Mid-High";

input string Input_WickExtend              = "Neighbor Wick Extension------------";
input bool   Zone_ExtendToNeighborWicks    = true;
input int    Zone_NeighborWickBars         = 2;
input double Zone_MaxWickExtendATR         = 0.00;   // 0 = no cap, cover the full wick

input string Input_ZoneResync              = "Zone Auto-Resync------------";
input bool   Zone_AutoResync               = true;
input int    Zone_ResyncMinutes            = 5;
input int    Zone_ResyncTradeMaxBars       = 3;      // resync-detected zone whose breakout is <= this many bars old is treated as live (trade + Telegram); 0 = never

input string Input_Watchdog                = "Watchdog / Anti-Sleep------------";
input bool   Use_Watchdog                  = true;
input int    WD_HeartbeatSec               = 60;    // 0 = off; pechati heartbeat vo Experts log sekoi X sek
input int    WD_SlowBlockMs                = 3000;  // predupredi ako AI/Chat blokot trae podolgo
input int    WD_CooldownSec                = 30;    // po bavan AI/Chat blok, pauziraj AI/Chat tolku sekundi
input int    WD_TimerReviveSec             = 30;    // ako OnTimer ne se javil tolku dolgo, re-armiraj EventSetTimer

input string Input_Trade                   = "SL & TP Settings------------";
input double Risk_Reward_Ratio             = 4.0;
input int    SL_Buffer_Points              = 30;
input bool   Show_SL_TP_Lines              = true;
input bool   Show_Price_Labels             = true;
input color  Color_SL                      = clrRed;
input color  Color_TP                      = clrLime;
input int    SL_TP_Width                   = 1;

input string Input_AutoTrade               = "Auto Trading------------";
input bool   Enable_AutoTrade              = true;
input bool   AutoTrade_OnNewZone           = true;

input string Input_ImmediateEntry          = "Immediate Entry------------";
input bool   Use_ImmediateEntry            = true;
input bool   Draw_CurrentChartTFOnly       = true;
input bool   AutoTrade_OnRetest            = false;
input bool   AutoTrade_RespectTimeFilter   = false;
input bool   AutoTrade_CurrentChartTFOnly  = false;
input bool   Use_Volume_Confirmation       = false;
input int    Volume_Lookback_Period        = 30;
input double Volume_Multiplier             = 2.0;
input double Retest_Max_Volume_Multiplier  = 1.2;
input bool   Use_PinBar_Filter             = false;
input bool   Use_Engulfing_Filter          = false;
input double Lot_Size                      = 0.01;
input int    Magic_Number                  = 12345;

input string Input_Safety                  = "Safety / Risk Management------------";
input bool   Use_RiskGuard                 = true;   // execution-side guards only, zones stay untouched
input bool   Risk_UsePercentLot            = false;  // false = keep fixed Lot_Size
input double Risk_PercentPerTrade          = 0.50;   // % of balance risked per trade
input double Risk_MaxLot                   = 1.00;
input int    Risk_MaxOpenTrades            = 2;      // 0 = unlimited
input int    Risk_MaxTradesPerDay          = 6;      // 0 = unlimited
input bool   Risk_OneTradePerZone          = true;
input bool   Risk_BlockOppositeDirection   = true;   // no hedging against an open position
input double Risk_MaxSpreadPoints          = 35.0;   // 0 = ignore spread
input double Risk_MaxDailyLossPct          = 3.0;    // stop trading for the day after this loss
input double Risk_MaxDailyProfitPct        = 0.0;    // 0 = no daily profit stop
input int    Risk_MaxConsecutiveLosses     = 3;      // 0 = ignore
input int    Risk_CooldownMinutesAfterLoss = 60;     // 0 = no cooldown
input double Risk_MaxEquityDrawdownPct     = 10.0;   // drawdown from peak equity, 0 = ignore
input double Risk_MinFreeMarginPct         = 30.0;   // block trades below this free margin level
input int    Risk_MaxSlippagePoints        = 10;

input string Input_DashboardSignal         = "Dashboard Signal AutoTrade------------";
input bool   Dash_EnableSignalTrading      = false;   // Master ON/OFF for this SEPARATE system (zones still work independently)
input bool   Dash_DryRunOnly               = true;  // PAPER MODE (SAFE!): print signals to log/dashboard only, NO real orders. Set false only after 2-3 paper wins.
input string Dash_GradeThreshold           = "A";    // Minimum grade: S (90+), A (75+), B (60+), C (45+), D (<45)
input int    Dash_MinStableBars            = 2;      // Require N consecutive closed bars (on Structure TF) with same grade
input bool   Dash_RequireReadyNearBOS      = true;   // Only enter when price shows [READY] near BOS (skip [EXTENDED] / [WAIT RETEST])
input int    Dash_MinScore                 = 75;     // Minimum confidence score 0-100 (matches the grade above)
input double Dash_ATRStopMultiplier        = 0.8;    // Stop loss = last swing +/- (ATR * this). Lower = tighter stop (0.8 = ~33% tighter than 1.2)
input double Dash_TakeProfitRR             = 2.5;    // Dashboard OWN Risk:Reward. 2.5 means TP target = 2.5 x SL distance (smaller target = hit more often)
input double Dash_MaxRiskPts               = 2500.0; // Max RISK distance per trade. XAUUSD/digits2: 1pt=0.01$, 2500pts=25.00$ max stop. 5-digit FX: 1pt=0.00001, 2500pts=25 pips. 0 = ignore.
input double Dash_SpreadPtsMax             = 40.0;   // Max spread in points (0 = ignore). XAUUSD: 40 pts = 0.40$ spread
input bool   Dash_UseGlobalRiskPct         = true;   // true = use Risk_PercentPerTrade from Risk section, same as zone trades
input double Dash_LotSizeFixed             = 0.01;   // If Dash_UseGlobalRiskPct=false, use this fixed lot size
input bool   Dash_AllowOppositeIfZoneHold  = false;  // true=allow Dashboard signal opposite to an open zone position (not recommended)
input bool   Dash_SessionEndBlock1h        = true;   // Block signals 1h before ASIA (23:00->00:00) and 1h before weekend close (Fri 22:00->23:00)
input int    Dash_MinBOSConfirmBars        = 2;      // After BOS, require N closed Structure bars BEYOND BOS level (prevents 1-bar fake breakouts)
input int    Dash_MinBOSConfirmBars_D1     = 2;
input int    Dash_MinBOSConfirmBars_H4     = 2;
input int    Dash_MinBOSConfirmBars_H1     = 2;
input int    Dash_MinBOSConfirmBars_M15    = 2;
input int    Dash_MinBOSConfirmBars_M5     = 2;
input int    Dash_MinBOSConfirmBars_M1     = 2;
input bool   Dash_EnableAIFilter           = true;   // "AI" triple filter: EMA200 trend direction + ADX>20 (real trend) + RSI not extreme (no tops/bottoms chasing)

input string Input_DashboardAI             = "Real AI (GPT Node.js Server)------------";
input bool   AI_Enable                     = true;   // Enable Real AI GPT (need local Node server on 127.0.0.1:3000)
input string AI_ServerURL                  = "http://127.0.0.1:3000";  // Local TraceAI_Server (StartTraceAI.bat must be running)
input int    AI_ScanEverySec               = 900;    // Sekundi megju dva AI scan povici (900 = 15 min, isto kako slikanjeto). 60 = brzo no mnogu poskapo.
input bool   AI_ScanSessionOnly            = true;   // Ne pravi /ai/scan nadvor od dozvolenata sesija
input int    AI_ScanStartHour              = 12;    // Poceten cas za platen AI scan i vision
input int    AI_ScanStartMinute            = 30;    // Pocetna minuta za platen AI scan i vision
input int    AI_ScanEndHour                = 21;    // Kraen cas za platen AI scan i vision
input int    AI_ScanEndMinute              = 0;      // Krajna minuta za platen AI scan i vision
input int    AI_FetchEverySec              = 6;      // How often to poll AI result after scan
input bool   AI_ShowOnDashboard            = true;   // Show AI analysis block at bottom of Dashboard
input bool   AI_OnlyAdviceNoAutoTrade      = true;   // SAFE ON: AI only gives advice on dashboard, NEVER opens trades automatically
input bool   AI_SkipWeekend                = true;   // Sabota/Nedela: bez scan i bez slikanje (ne trosi tokeni)
input int    AI_OfflineAfterSec            = 120;    // Server = OFFLINE ako heartbeat.txt/result.json se postari od X sekundi (30 e prestrogo koga se pishuva preku fajlovi)
input bool   AI_MultiTFEyes                = true;   // Prakjaj M1/M5/M15/M30/H1/H4/D1 snapshot do AI (multi-timeframe ochi)
input bool   AI_VisionEyes                 = true;   // Slikaj chart (ChartScreenShot) i prakjaj do GPT-4o vision
input string AI_VisionTFs                  = "M15,H1";       // Koi timeframes da se slikaat (max 2)
input bool   AI_VisionOnlyOnSetup          = true;   // Slikaj SAMO koga tvrdata porta ke premine (poevtino po tokeni)
input int    AI_VisionWidth                = 1024;
input int    AI_VisionHeight               = 600;
input bool   AI_VisionOpenMissing          = true;   // Otvori NOV prozorec ako toj TF ne e otvoren (true = otvori i nov chart koga nedostiga)
input int    AI_VisionEverySec             = 300;    // Min sekundi megju DVE slikanja (0 = koristi AI_ScanEverySec). Sprechuva dvojno slikanje po nekolku sekundi.
input bool   AI_VisionCloseAfterShot       = true;   // Zatvori gi EA vision chartovite po sekoe slikanje
input bool   AI_HardGate                   = true;   // Tvrda porta vo kod (ne samo vo prompt)
input int    AI_GateMinScore               = 70;     // Min EA score
input string AI_GateMinGrade               = "A";    // Min grade: S > A > B > C > D
input double AI_GateMinADX                 = 22.0;   // Min ADX na M15 (trend, ne chop)
input bool   AI_GateNeedH4H1               = true;   // H4 i H1 mora da se soglasat
input bool   AI_GateH4Soft                 = true;  // SOFT H4: dozvoli H1+M15 setap koga H4 e FLAT/slab; blokira samo ako H4 e SILNO protiv (ADX(H4) >= AI_GateMinADX)
input bool   AI_GateNeedM15                = true;   // M15 mora da e vo istata nasoka
input bool   AI_GateM15FlatSoft            = true;   // M15 FLAT e soft blokada, no ostanatite uslovi se proveruvaat
input bool   AI_GateNeedM5Timing           = false;  // M5 isto vo nasoka (postrogo, pomalku signali)
input double AI_GateMaxSpreadPts           = 40.0;   // Max spread vo poeni (0 = ignoriraj)
input bool   AI_GateSessionOnly            = true;   // Samo vo dozvolena sesija (IsTradingAllowed)
input bool   AI_GateBlockRsiExtreme        = true;   // Ne brkaj vrv/dno (RSI>76 BUY / RSI<24 SELL)
input bool   AI_GateScoreMode              = true;   // Score/Grade/ADX/M15/RSI se sobiraat vo poeni
input int    AI_GateMinPoints              = 6;      // Minimum poeni za AI gate
input int    AI_GateScoreSoftDelta         = 10;     // Tolku popust za sredniot score
input double AI_GateAbsMinADX              = 16.0;   // Apsoluten ADX pod koj nema AI gate
input bool   AI_JudgeNeedTrend             = false;  // Gate vekje gi blokira RANGE/CHOP
input bool   AI_SignalCSVLog               = true;   // Zapisi sekoj ARMED signal vo TraceAI\signals.csv

input string Input_Chat                    = "AI Chat Panel------------";
input bool   Chat_Enable                   = true;
input string Chat_Mode                     = "SERVER";        // SERVER = preku lokalniot Node server (kluc vo .env); DIRECT = od MT4 direktno
input string Chat_ApiUrl                   = "https://api.openai.com/v1/chat/completions";
input string Chat_ApiKey                   = "";
input string Chat_Model                    = "gpt-4o";         // Samo za DIRECT rezim; vo SERVER modelot doagja od .env (CHAT_MODEL)
input bool   Chat_UseOpenAI                = true;             // Koristi OpenAI (samo DIRECT rezim)
input bool   Chat_UseGemini                = false;            // Koristi Gemini (samo DIRECT rezim)
input string Chat_GeminiApiKey             = "";                // Gemini API kluch (samo za DIRECT rezim; drzi go vo .env)
input string Chat_GeminiModel              = "gemini-flash-latest"; // Gemini model
input string Chat_GeminiBaseUrl            = "https://generativelanguage.googleapis.com/v1beta/models/"; // Gemini URL za whitelist
input int    Chat_MaxTokens                = 700;
input double Chat_Temperature              = 0.2;
input int    Chat_TimeoutMs                = 90000;            // Gemini Pro + 4 sliki: odgovorot moze da trae 60-90 sekundi
input string Chat_Lang                     = "MK";
input string Chat_ContextTFs               = "M1,M5,M15,H1,H4,D1";
input int    Chat_X                        = 20;
input int    Chat_Y                        = 40;
input int    Chat_Width                    = 420;
input int    Chat_Lines                    = 14;
input int    Chat_WrapChars                = 62;
input int    Chat_FontSize                 = 8;
input color  Chat_BgColor                  = clrBlack;
input color  Chat_TitleColor               = clrDarkSlateGray;
input color  Chat_TextColor                = clrWhite;
input color  Chat_InputTextColor           = clrBlack;
input color  Chat_InputBgColor             = clrWhite;
input color  Chat_UserColor                = clrAqua;
input color  Chat_AiColor                  = clrLime;
input color  Chat_ButtonColor              = clrSteelBlue;
input bool   Chat_CtxLevels                = true;
input bool   Chat_CtxVolatility             = true;
input bool   Chat_CtxLiquidity              = true;
input bool   Chat_CtxSessions               = true;
input bool   Chat_CtxNews                   = true;
input int    Chat_NewsRefreshMin            = 30;
input int    Chat_NewsWindowMin             = 120;
input bool   Chat_CtxHeadlines              = true;
input int    Chat_HeadlinesRefreshMin       = 10;
input bool   Chat_CtxUsdStrength            = true;
input bool   Chat_CtxStats                  = true;
input int    Chat_StatsMaxRecords           = 300;
input string Chat_StatsResetPeriod          = "NEVER"; // WEEKLY | MONTHLY | NEVER
input string Chat_StatsStartFrom            = "";      // "2026.09.01 00:00" = ignoriraj se pred ovoj datum (svez broj od 0)
input bool   Chat_ScoreEnable               = true;
input int    Chat_PlanMaxRecords            = 200;
input int    Chat_PlanExpireHours           = 24;
input int    Chat_AsiaStartHour             = 0;
input int    Chat_AsiaEndHour               = 8;
input double Chat_RoundStep                 = 0.0;
input bool   Chat_WatchEnable              = true;
input int    Chat_WatchMinGapSec           = 600;
input int    Chat_WatchMaxPerDay           = 10;
input bool   Chat_WatchAlert               = true;
input bool   Chat_WatchTelegram            = true;
input int    Chat_WatchTimeoutMs           = 90000;  // Avtomatski WATCH povik
input bool   Chat_AutoPlan                 = true;
input int    Chat_AutoPlanMinGapSec        = 900;
input int    Chat_AutoPlanMaxPerDay        = 6;
input bool   Chat_AutoPlanAlert            = true;
input bool   Chat_AutoPlanTelegram         = true;
input bool   Chat_Scout                   = true;
input int    Chat_ScoutEveryBars          = 3;      // Na kolku M5 sveki vika SCOUT (3 = na 15 min). 1 = 3x poskapo.
input string Chat_ScoutTF                 = "M5";
input int    Chat_ScoutMinConf            = 75;
input int    Chat_ScoutMaxPerDay          = 50;     // Dneven maksimum SCOUT povici (kontrola na troshok)
input bool   Chat_ScoutAlert              = true;
input bool   Chat_ScoutTelegram           = true;
input int    Chat_ScoutQuietRepeatMin     = 30;
input bool   Chat_ScoutAlignClock         = true;  // Vikaj tocno na okrugli minuti (:00 :15 :30 :45), ne od posledniot povik
input int    Chat_ScoutStartHour          = 12;    // SCOUT raboti od ovoj cas (server vreme na chartot)
input int    Chat_ScoutEndHour            = 21;    // ...do ovoj cas. 12:30-21:00 na sekoi 15 min = 34 skeniranja
input int    Chat_ScoutStartMinute        = 30;    // Pocetna minuta na SCOUT prozorecot
input int    Chat_ScoutEndMinute          = 0;     // Krajna minuta na SCOUT prozorecot
input bool   Chat_CountOnlyAnsweredCalls  = true;  // Broj gi samo uspesnite AI odgovori kako povici
input bool   Chat_ScoutVerbose            = true;   // Pishuvaj kratok red i koga SCOUT vrati NO_TRADE (da vidish deka rabot i)
input int    Chat_ScoutWatchConf          = 75;    // Ideja so CONF vo [WatchConf, MinConf) se pishuva kako WATCH (bez signal). 0 = isklucheno
input bool   Chat_WatchNeedLtfAgree       = true;  // WATCH bara M5/M15 da ne se sprotivni bez EA potvrda
input double Chat_WatchMinRR              = 2.00;  // WATCH pod ovoj RR se odbiva
input double Chat_WatchHardMinRR           = 1.50;   // Tvrdo minimum RR za WATCH
input bool   Chat_WatchNeedH1Agree         = true;   // WATCH mora da se soglasi so H1
input bool   Chat_WatchArmEnable           = true;   // WATCH moze da se armira za signal
input int    Chat_WatchArmMinutes          = 90;     // Kolku minuti vazi armed WATCH
input double Chat_WatchArmTolATR           = 0.25;   // Tolerancija za vlez vo ATR
input bool   Chat_WatchDisableAll          = true;   // Celosno isklucen WATCH: bez WATCH plan, bez WATCH arm, bez WATCH linija vo tabelata
input bool   Chat_ScoutM15FlatOk          = true;  // SCOUT PLAN moze so M15 FLAT samo so potvrda
input double Chat_ScoutM15FlatMinRR       = 2.00;  // M15 FLAT PLAN bara najmalku ovoj RR
input bool   Chat_ScoutWatchAlert         = false; // Alert i za WATCH ideite (ne samo za polni signali)
input bool   Chat_ScoutLogCsv             = true;  // Zapishi sekoja SCOUT odluka vo TraceAI\\chat_scout.csv
input bool   Chat_BlockLiveRearm          = true;  // Ne armiraj nova ista nasoka dodeka star plan e OPEN
input bool   Chat_PlanFixSL               = true;  // Pomesti SL nad/pod posledniot swing + spread ako e preblizok
input double Chat_PlanMinSLATR            = 1.00;  // Minimalno rastojanie entry->SL vo ATR (na scout TF)
input int    Chat_PlanSLSwingBars         = 12;    // Kolku sveki nazad se gleda swing high/low
input double Chat_PlanSLBufferATR         = 0.15;  // Buffer nad swing vo ATR (plus spread)
input double Chat_PlanMinRR               = 1.50;  // Po SL popravkata: pod ovoj RR e samo WATCH, ne signal
input bool   Chat_PlanSendSLRule           = true;   // Prati mu ja EA SL pravilata na PLAN/SCOUT
input bool   Chat_PlanRetargetTP           = true;   // Pri pomesten SL preracunaj TP
input double Chat_PlanTargetRR             = 2.00;   // Ciljan RR pri TP retarget
input double Chat_PlanMaxSLATR             = 6.00;   // Maksimalen rizik vo ATR
input double Chat_PlanMaxTPATR             = 14.00;  // Maksimalna dalecina na TP vo ATR
input bool   Chat_TP1DailyLevelGuard      = true;   // Priblizi TP1 pred dnevno nivo (bufferot e vo USD)
input double Chat_TP1DailyLevelBufferUSD  = 1.50;   // Buffer pred dnevno nivo vo USD (1 poen kaj korisnikot = 0.01 USD)
input bool   Chat_FallbackNoTradeProse     = true;   // Prepoznaj jasen NO_TRADE odgovor vo sloboden tekst
input bool   Chat_InvalidReplyDiagnostics  = true;   // Zapishi del od neparsiran AI odgovor vo INVALID CSV red
input bool   Chat_StatsDisplayFix          = true;   // Prikazi n/a i broj primeroci; ignoriraj WATCH vo last10
input bool   Chat_SendEaScore              = false;  // false = NE mu go prakjame EA Score/Grade/gate na AI; nek odluchi od slikite i indikatorite
input bool   Chat_TuneEnable               = true;
input int    Chat_TuneMinGapSec            = 86400;   // TUNE e samo sovet za podesuvanja
input bool   Chat_ScoutLocalPreGate        = true;   // Evtini lokalni proverki pred AI
input double Chat_ScoutPreMinADX          = 14.0;    // Minimum ADX za SCOUT AI povik
input color  Chat_TuneColor                = clrOrange;
input bool   Chat_Vision                   = true;
input string Chat_VisionTFs                = "M5,M15,H1";
input int    Chat_VisionWidth              = 1024;
input int    Chat_VisionHeight             = 600;
input string Chat_VisionDetail             = "low";
input int    Chat_VisionMaxAgeSec          = 600;    // Sliki pomladi od ova NE se slikaat povtorno. Mora da e POGOLEMO od AI_VisionEverySec (slikanje na 5 min -> 600 = 10 min), inache TF-ovi ispadnuvaat.
input bool   Chat_VisionBarSync            = true;   // Nova svejka na scout TF = novo slikanje (ignoriraj reuse vo ramki na istata svejka)
input int    Chat_VisionStaleSec           = 1800;   // Slika postara od ova NE se prakja do AI (0 = bez proverka)
input bool   Chat_VisionSkipCurrentTF      = true;   // TF-to na ovoj chart (npr M1) da NE jade mesto ako ne e vo Chat_VisionTFs
input bool   Chat_VisionOpenMissing        = true;
input int    Chat_VisionMaxShots           = 3;      // detail=low -> ~85 tokeni po slika. M5 timing + M15 struktura + H1 trend
input bool   Chat_VisionOwnCharts          = true;   // Chat vision koristi sopstveni privremeni chartovi namesto korisnichki
input bool   Chat_VisionCleanChart         = true;   // Cist stil za privremenite chat vision chartovi
input string Chat_VisionTemplate           = "";     // Opcionen .tpl za privremenite chat vision chartovi
input bool   Chat_VisionDrawLevels         = true;   // Dnevni nivoa na privremenite chat vision chartovi
input bool   Chat_FeedbackEnable           = true;   // Prakjaj razbieni statistiki (nasoka/sesija/confidence) do AI
input int    Chat_FeedbackMinSamples       = 6;      // Min zatvoreni planovi vo grupa za da se smeta za dokaz
input double Chat_FeedbackWeakWinPct       = 40.0;   // Pod ovoj win% grupata e SLABA -> AI mora da e pokonzervativen
input bool   Chat_TriggerEnable            = true;   // AI moze da vrati TRIGGER= uslov namesto vednash vlez
input int    Chat_TriggerMaxMin            = 120;    // Kolku minuti vazi armiraniot uslov
input double Chat_TriggerMinRR             = 1.00;   // Pod ovoj RR (po SL popravka) triggerot ne se armira
input bool   Chat_TriggerAlert             = true;   // Alert koga uslovot ke se ispolni
input bool   Chat_TriggerTelegram          = true;  // Telegram koga uslovot ke se ispolni
input bool   Use_BreakEven                 = true;
input double BE_TriggerRR                  = 1.00;   // move SL to BE after this much R in profit
input double BE_LockPoints                 = 10;
input double BE_LockRR                     = 0.20;   // >0: lock this much R instead of BE_LockPoints
input bool   Use_TrailingStop              = true;
input double Trail_StartRR                 = 1.50;
input double Trail_ATRPeriod               = 14;
input double Trail_ATRMultiplier           = 1.50;
input double Trail_MinDistRR               = 0.75;   // trailing SL never closer to price than this x risk

input string Input_EntryGuard              = "Entry Placement Guard------------";
input bool   Use_EntryGuard                = true;   // sanity checks on the entry price / SL / TP
input bool   Entry_RequireInsideZone       = false;  // true = wait for a retest, false = enter immediately on the new zone
input double Entry_MaxDistanceATR          = 1.50;   // max distance from the zone for an immediate entry
input bool   Entry_BlockIfZoneBroken       = true;   // no trade after a candle closed through the zone
input bool   Entry_ConvertToPendingLimit   = true;   // too far from the zone -> park a limit order in the zone instead
input bool   Entry_UseATRStopOutside       = true;   // entering away from the zone -> tight ATR stop, not the far zone edge
input double Entry_ATRStopMult             = 1.00;   // size of that stop in ATR
input double Entry_FastTP_RR               = 1.50;   // quick scalp target measured from the real entry price
input double Entry_MinRR                   = 1.20;   // skip the trade if the real RR from the fill price is worse

input string Input_TradeRRGate             = "Trade RR Gate (all order paths)------------";
input bool   Use_TradeRRGate               = true;   // RR / stop-size sanity check before EVERY OrderSend
input double TradeGate_MinRR               = 1.20;   // reward/risk measured from the real entry price
input double TradeGate_MaxSLPoints         = 2500;   // max stop distance in points (XAUUSD 2 digits: 2500 = 25.00$), 0 = off

input string Input_ZoneAge                 = "Zone Age / Validity Guard------------";
input int    Trade_MaxAgeHours             = 48;

input string Input_SecondOrder             = "Second Order (Pending Limit in Zone)------------";
input bool   Use_SecondPendingOrder        = true;
input double Pending_EntryPct              = 0.5;    // 0 = proximal edge of zone, 0.5 = middle, 1.0 = far edge
input double Pending_Lot_Size              = 0.01;

input string Input_Time                    = "Time Filter------------";
input bool   UseTimeFilter                 = true; 
input int    TradingStartHour              = 0; 
input int    TradingEndHour                = 24; 
input bool   TradeMonday                   = true; 
input bool   TradeTuesday                  = true; 
input bool   TradeWednesday                = true; 
input bool   TradeThursday                 = true; 
input bool   TradeFriday                   = true; 
input bool   TradeSaturday                 = false; 
input bool   TradeSunday                   = false;

input string Input_Settings                = "Zone Settings------------";
input int    ZoneLookback                  = 1440;
input int    Buy_MaxZones                  = 1500;
input int    Sell_MaxZones                 = 1500;
input int    Zone_Opacity                  = 3;

input string ZoneSettings                  = "Detection Settings------------";
input bool   Use_Extreme_HighLow           = true;
input int    Extreme_Lookback              = 200;
input double Min_Impulse_ATR               = 1.20;
input bool   Use_Impulse_Filter            = true;
input bool   Use_Volume_Impulse_Filter     = true;
input double Buy_MinZoneDistance           = 30.0;
input double Buy_MaxZoneHeightATR          = 1.80;
input double Buy_MinBodyRatio              = 0.55;
input double Sell_MinZoneDistance          = 30.0;
input double Sell_MaxZoneHeightATR         = 1.80;
input double Sell_MinBodyRatio             = 0.55;

input string Input_Telegram                = "Telegram Settings------------";
input bool   EnableTelegram                = true; 
input string TelegramBotToken              = "";
input string TelegramChatID                = "";
input bool   Telegram_StartupTest          = true;   // Prati test poraka pri start (greshkata se gleda vo chat panelot)
input bool   DebugMode                     = true;

input string Input_Dash                    = "Dashboard------------";
input bool   EnableDashboard               = true;
input bool   Dash_ShowStatusRiskBlock      = false;  // Prikazi "AutoTrade / Day P/L / Trades today / Spread / RiskGuard" blok na dashboard
input color  Color_DashText                = clrWhite;
input color  Color_DashTitle               = clrLime;
input int    ATR_Period_Strength           = 14;
input int    RSI_Period                    = 14;
input int    Strength_Update_Frequency     = 14;
input bool   Filter_BigCandle_Rejection    = true;  
input double BigCandle_ATR_Factor          = 2.50;   
input bool   Include_Wicks                 = true;  
input double Buy_MinZoneHeightATR          = 0.15;
input int    Buy_MinZoneHeightPoints       = 50;
input double Sell_MinZoneHeightATR         = 0.15;
input int    Sell_MinZoneHeightPoints      = 50;
input bool   RestoreZonesOnReload          = true;
input int    ProjectionBarsAhead           = 5;
input color  EliteColor                    = clrGold;
input color  ZoneHitSLColor                = clrCrimson;
input color  ZoneHitTPColor                = clrGreen;

//+------------------------------------------------------------------+
//| GLOBALS                                                          |
//+------------------------------------------------------------------+
ZoneInfo BullishZones[];
ZoneInfo BearishZones[];
string   g_tradedZoneFingerprints[];
int      g_tradedZoneFingerprintCount = 0;
string   g_seenZoneFingerprints[];
int      g_seenZoneFingerprintCount = 0;
int      totalBullZones       = 0;
int      totalBearZones       = 0;
datetime g_wdLastTimer        = 0;
datetime g_wdLastHeartbeat    = 0;
datetime g_wdPauseUntil       = 0;
int      g_wdTickCount        = 0;
int      g_wdTimerCount       = 0;
int      g_wdLastBlockMs      = 0;
string   g_wdLastBlockTag     = "";
string   g_tgLastError        = "";
int      g_tgFailCount        = 0;

datetime g_lastBarTime        = 0;
int      g_timeframe          = 0;

#define          TF_COUNT 7
int      TF_List[TF_COUNT]    = { PERIOD_D1, PERIOD_H4, PERIOD_H1,
                                  PERIOD_M30, PERIOD_M15, PERIOD_M5, PERIOD_M1 };

datetime lastBarTime[TF_COUNT];
bool     g_histScanned[TF_COUNT];

bool g_zoneTypesLocked = true;

int      g_zoneIdCounter      = 1;
int      g_digits;
double   g_pip;
bool     g_isScanningHistory  = false;

int      g_todayBullCount     = 0;
int      g_todayBearCount     = 0;
int      g_currentDay         = 0;

double   g_peakEquity         = 0.0;
double   g_dayStartBalance    = 0.0;
string   g_riskBlockReason    = "";
double   g_lastBOSHigh        = 0.0;
double   g_prevBOSHigh        = 0.0;
double   g_lastBOSLow         = 0.0;
double   g_prevBOSLow         = 0.0;

// Dashboard Signal Confidence cache (for STABILITY - no flicker on ticks)
datetime   g_sigCacheBarTime   = 0;    // last structure TF bar close time when we calculated
int        g_sigCachedScore    = -1;   // -1 means not yet cached
string     g_sigCachedGrade    = "D";
color      g_sigCachedGradeClr = clrGray;
string     g_sigCachedDirText  = "NEUTRAL / NO SIGNAL";
color      g_sigCachedDirClr   = clrGray;
string     g_sigCachedHTF      = "Next TF: Neutral";
color      g_sigCachedHTFClr   = clrSilver;
string     g_sigCachedSession  = "---";
color      g_sigCachedSessClr  = clrSilver;
string     g_sigCachedAction   = "---";
color      g_sigCachedActClr   = clrSilver;
string     g_sigCachedBanner   = "";
color      g_sigCachedBannerClr= clrGray;
int        g_sigStableBars     = 0;    // how many consecutive bars has score stayed in same band (A/B etc)

// Dashboard Signal AutoTrade MEMO (da ne se povtori vlez po ista struktura)
string     g_dashLastTradeSigKey = "";   // unikatno za edna struktura -> trade samo ednas
int        g_sigCachedStructTF   = 15;   // cache za AttemptDashboardSignalTrade
int        g_sigCachedTrend      = 0;    // 1=Bull, -1=Bear, 0=Neutral
double     g_sigCachedBOSLevel   = 0.0;
double     g_sigCachedSwingH     = 0.0;
double     g_sigCachedSwingL     = 0.0;
bool       g_sigCachedHasStruct  = false;
// ---------- Confirm (M5) TF cache (dopolnitelna proverka megju Entry i Struct) ----------
int        g_confirmCachedTF     = 5;    // confirm timeframe (M5 za M1 chart)
int        g_confirmCachedTrend  = 0;    // 1=Bull, -1=Bear, 0=Neutral
double     g_confirmCachedBOS    = 0.0;
double     g_confirmCachedSwingH = 0.0;
double     g_confirmCachedSwingL = 0.0;
bool       g_confirmCachedHas    = false;
// DryRun + AI visual output za Dashboard:
datetime   g_dashLastDryTime     = 0;
string     g_dashLastDryText     = "[DRY] no signal yet";
color      g_dashLastDryClr      = clrSilver;
bool       g_dashAIRslt          = false; // AI filter last pass result
string     g_dashAIReason        = "";    // za dashboard
int        g_dashDryCount        = 0;     // kolku dry run signala se generirani total
// ============= REAL AI GPT (External Server) cache ==========================================
datetime   g_aiLastScanTime      = 0;
datetime   g_aiLastFetchTime     = 0;
datetime   g_aiLastHealthTime    = 0;
bool       g_aiLastScanOK        = false;
string     g_aiLastMsg           = "AI off. Start StartTraceAI.bat + set AI_Enable=true.";
string     g_aiDecision          = "WAIT";   // BUY / SELL / WAIT
double     g_aiConfidence        = 0.0;      // 0.00 - 1.00
string     g_aiR1 = "";  string g_aiR2 = "";  string g_aiR3 = "";
// ---- Plan B (File Watcher) globals ----
int        g_aiLastScanMtime     = 0;   // za da ne go prebrisuvame scan.json nonstop (serverot treba da go primi ednas)
datetime   g_aiLastResultFtime   = 0;   // last result.json file read time (za cache)
datetime   g_aiLastHeartbeatTime = 0;   // last heartbeat tick (za Server: ? offline ↔ ✅ linked display)
string     g_aiLastHeartbeatContent = "";  // last heartbeat firstLine (za da detektirame dali ima NOV zapis od node)
datetime   g_aiLastResultTs = 0;            // last result.json scannedAt timestamp (parsiran direktno od JSON)
string     g_aiLastResultSignature = "";    // last result JSON signature: scannedAt + decision + confidence
double     g_aiEntry = 0.0;  double g_aiSL = 0.0;  double g_aiTP = 0.0;
int        g_aiHbAgeSec     = -1;      // realen vozrast na heartbeat.txt vo sekundi (-1 = nepoznato)
int        g_aiRsAgeSec     = -1;      // realen vozrast na result.json (scannedAt) vo sekundi (-1 = nepoznato)
bool       g_aiServerOnline = false;   // TRUE samo dodeka node serverot AKTIVNO pishuva svezhi fajlovi
bool       g_aiResultFresh  = false;   // TRUE ako poslednata GPT odluka e posveza od AI_OfflineAfterSec

// ---- MTF snapshot cache (polneto vo AIScanMarketNow, koristeno od tvrdata porta) ----
#define MTF_N 7
string     g_mtfName[MTF_N];
string     g_mtfBias[MTF_N];
double     g_mtfAdx[MTF_N];
double     g_mtfRsi[MTF_N];
double     g_mtfClose[MTF_N];
double     g_mtfEma200[MTF_N];
datetime   g_mtfStamp = 0;

// ---- HARD GATE ----
bool       g_gatePass = false;         // TRUE = site tvrdi uslovi ispolneti
int        g_gateDir  = 0;             // 1 = BUY setup, -1 = SELL setup, 0 = nema
string     g_gateWhy  = "";            // kratok opis zoshto e ARMED
string     g_gateFail = "";            // prviot uslov shto padna
int        g_gatePassed = 0;           // kolku uslovi pominaa
int        g_gateTotal  = 0;           // kolku uslovi se proveruvani
bool       g_gateM15Flat = false;      // TRUE = M15 FLAT, ostanatite gate uslovi mozat da pominat
bool       g_gateOtherPass = false;    // TRUE = site drugi gate uslovi pominati

// ---- VISION (ChartScreenShot -> GPT-4o) ----
long       g_visChart[4];
bool       g_visOwned[4];              // TRUE = EA-to go otvorilo => EA-to ke go zatvori
string     g_visTfName[4];
int        g_visCount = 0;
string     g_visFiles = "";            // comma-separated relativni pateki (TraceAI\shot_M1.png,...)
datetime   g_visShotTime = 0;
datetime   g_visShotLocal = 0;         // PC vreme na poslednoto slikanje (throttle, ne broker vreme)
string     g_lastLoggedSigKey = "";

// cached account statistics (history scans are throttled)
datetime g_riskCacheTime      = 0;
double   g_cachedDayPnL       = 0.0;
int      g_cachedConsecLosses = 0;
datetime g_cachedLastLossTime = 0;
int      g_cachedTodayTrades  = 0;

double   g_obSwingHighLevel[TF_COUNT];
double   g_obSwingLowLevel[TF_COUNT];
datetime g_obSwingHighTime[TF_COUNT];
datetime g_obSwingLowTime[TF_COUNT];
bool     g_obSwingHighCrossed[TF_COUNT];
bool     g_obSwingLowCrossed[TF_COUNT];
// >0 limits the replay window of OB_ScanLookback (used by the periodic resync)
int      g_obScanLookbackOverride = 0;
bool     g_obResyncLiveZone = false;

// ---- TraceChat panel state ----
int      g_chatX = 20;
int      g_chatY = 40;
bool     g_chatMinimized = false;
bool     g_chatDragging = false;
int      g_chatDragDX = 0;
int      g_chatDragDY = 0;
bool     g_chatMouseScroll = true;
int      g_chatScroll = 0;
string   g_chatText[];
int      g_chatTextColor[];
int      g_chatTextCount = 0;
string   g_chatRole[];
string   g_chatMessage[];
int      g_chatConversationCount = 0;
string   g_chatStatus = "";
datetime g_chatNonce = 0;
string   g_chatWatchInstruction = "";
bool     g_chatWatchActive = false;
string   g_chatWatchLastSignature = "";
datetime g_chatWatchLastCall = 0;
int      g_chatWatchCallsToday = 0;
int      g_chatWatchDay = -1;
bool     g_chatAutoPlanWasClean = false;
string   g_chatAutoPlanLastSignature = "";
datetime g_chatAutoPlanLastFire = 0;
int      g_chatAutoPlanCallsToday = 0;
int      g_chatAutoPlanDay = -1;
datetime g_chatScoutLastBar = 0;
datetime g_chatScoutLastFire = 0;
int      g_chatScoutCallsToday = 0;
int      g_chatScoutFailedAttempts = 0;
datetime g_chatScoutOfflineRetryAfter = 0;
int      g_chatScoutBarCount = 0;      // kolku sveki pominale od posleden SCOUT povik
string   g_chatScoutWhy = "";          // zosto SCOUT ne vika (za status vo panelot)
int      g_chatScoutDay = -1;
int      g_chatScoutLastDir = 0;
double   g_chatScoutLastEntry = 0.0;
double   g_chatScoutLastSL = 0.0;
double   g_chatScoutLastTP2 = 0.0;
datetime g_chatScoutLastAnnounce = 0;
int      g_chatScoutWatchLastDir = 0;
double   g_chatScoutWatchLastEntry = 0.0;
double   g_chatScoutWatchLastSL = 0.0;
double   g_chatScoutWatchLastTP2 = 0.0;
datetime g_chatScoutWatchLastAnnounce = 0;
int      g_chatScoutArmDir = 0;
double   g_chatScoutArmEntry = 0.0;
double   g_chatScoutArmSL = 0.0;
double   g_chatScoutArmTP1 = 0.0;
double   g_chatScoutArmTP2 = 0.0;
double   g_chatScoutArmConf = 0.0;
datetime g_chatScoutArmTime = 0;
string   g_chatScoutArmSetup = "";
string   g_chatScoutArmTrigger = "";
datetime g_chatTuneLastCall = 0;
bool     g_chatBusy = false;
int      g_chatTransportTimeoutMs = 0;
bool     g_chatVisionFallback = false;
string   g_chatVisionSkipped = "";
int      g_chatVisionCount = 0;
string   g_chatVisionTf[4];
string   g_chatVisionFile[4];
datetime g_chatVisionShotLocal = 0;    // PC vreme na poslednoto chat slikanje (reuse do Chat_VisionMaxAgeSec)
datetime g_chatVisionShotBar = 0;      // svejka (scout TF) na koja e napraveno poslednoto slikanje
string   g_chatVisionAges = "";        // "M1 12s M5 12s H1 8h" - za panel i CSV
bool     g_chatVisionLevelsDrawn = false;

// ---- WAIT_FOR trigger (AI dava uslov, EA go chuva i go proveruva lokalno) ----
#define TRIG_NONE         0
#define TRIG_TOUCH        1
#define TRIG_CLOSE_ABOVE  2
#define TRIG_CLOSE_BELOW  3
#define TRIG_SWEEP_BELOW  4
#define TRIG_SWEEP_ABOVE  5
bool     g_trigActive  = false;
int      g_trigDir     = 0;            // 1 = BUY, -1 = SELL
int      g_trigType    = TRIG_NONE;
double   g_trigLevel   = 0.0;
int      g_trigTF      = PERIOD_M5;
datetime g_trigUntil   = 0;
datetime g_trigArmed   = 0;
datetime g_trigLastBar = 0;
double   g_trigEntry   = 0.0;
double   g_trigSL      = 0.0;
double   g_trigTP1     = 0.0;
double   g_trigTP2     = 0.0;
double   g_trigRR      = 0.0;
double   g_trigConf    = 0.0;
string   g_trigText    = "";
int      g_chatPlanIdNext = 1;
int      g_chatPlanId[];
string   g_chatPlanSymbol[];
datetime g_chatPlanCreateTime[];
string   g_chatPlanSetup[];
bool     g_chatPlanIsWatch[];
double   g_chatPlanEntry[];
double   g_chatPlanSL[];
double   g_chatPlanTP1[];
double   g_chatPlanTP2[];
bool     g_chatPlanTP1Hit[];
double   g_chatPlanRR[];
double   g_chatPlanConf[];
string   g_chatPlanStatus[];
datetime g_chatPlanResolveTime[];
string   g_chatPlanNote[];
bool     g_chatPlanTriggered[];
int      g_chatPlanLastShift[];
int      g_chatPlanCount = 0;
datetime g_chatPlanLastM1Bar = 0;
bool     g_chatPlanForceUpdate = false;
bool     g_chatPlansSaveBlocked = false;
bool     g_chatPlansLastSaveOk = false;
datetime g_chatCtxRangeBar = 0;
datetime g_chatCtxRangeDay = 0;
double   g_chatCtxAsiaHi = 0.0;
double   g_chatCtxAsiaLo = 0.0;
double   g_chatCtxLondonHi = 0.0;
double   g_chatCtxLondonLo = 0.0;
double   g_chatCtxNyHi = 0.0;
double   g_chatCtxNyLo = 0.0;
bool     g_chatCtxAsiaOk = false;
bool     g_chatCtxLondonOk = false;
bool     g_chatCtxNyOk = false;
#define CHAT_NEWS_MAX 128
string   g_chatNewsTitle[CHAT_NEWS_MAX];
string   g_chatNewsCurrency[CHAT_NEWS_MAX];
string   g_chatNewsImpact[CHAT_NEWS_MAX];
datetime g_chatNewsTime[CHAT_NEWS_MAX];
int      g_chatNewsCount = 0;
datetime g_chatNewsLastRefresh = 0;
datetime g_chatNewsNextTry = 0;
bool     g_chatNewsLoaded = false;
#define CHAT_HEADLINE_MAX 8
string   g_chatHeadlineTitle[CHAT_HEADLINE_MAX];
string   g_chatHeadlineSource[CHAT_HEADLINE_MAX];
string   g_chatHeadlineTag[CHAT_HEADLINE_MAX];
int      g_chatHeadlineAge[CHAT_HEADLINE_MAX];
int      g_chatHeadlineCount = 0;
datetime g_chatHeadlineNextTry = 0;
bool     g_chatHeadlineLoaded = false;
bool     g_chatDxyAvailable = false;
double   g_chatDxyValue = 0.0;
double   g_chatDxyChange = 0.0;
double   g_chatDxyChangePct = 0.0;
int      g_chatDxyAgeMin = 0;
string   g_chatDxySource = "";
int      g_chatStatsOpenTicket[];
string   g_chatStatsOpenGrade[];
string   g_chatStatsOpenSession[];
string   g_chatStatsOpenDecision[];
string   g_chatStatsOpenRegime[];
int      g_chatStatsOpenTrend[];
int      g_chatStatsOpenGateDir[];
double   g_chatStatsOpenConfidence[];
double   g_chatStatsOpenEntry[];
double   g_chatStatsOpenSL[];
double   g_chatStatsOpenTP[];
datetime g_chatStatsOpenTime[];
int      g_chatStatsRecordTicket[];
datetime g_chatStatsRecordCloseTime[];
double   g_chatStatsRecordProfit[];
double   g_chatStatsRecordR[];
string   g_chatStatsRecordGrade[];
string   g_chatStatsRecordSession[];
string   g_chatStatsRecordDecision[];
string   g_chatStatsRecordRegime[];
int      g_chatStatsRecordTrend[];
int      g_chatStatsRecordDirection[];
int      g_chatStatsRecordGateDir[];
double   g_chatStatsRecordConfidence[];
double   g_chatStatsRecordEntry[];
double   g_chatStatsRecordSL[];
double   g_chatStatsRecordTP[];
datetime g_chatStatsRecordOpenTime[];
bool     g_chatStatsRecordUnknown[];
int      g_chatStatsRecordCount = 0;

//+------------------------------------------------------------------+
//| FUNCTION DECLARATIONS                                            |
//+------------------------------------------------------------------+
void     ScanHistoricalZones(int tf);
void     DetectNewZonesForTF(int tf);
void     ProcessTimeframes();

bool     IsDemandZone_Live(int tf, int shift);
bool     IsSupplyZone_Live(int tf, int shift);
ZoneInfo CreateDemandZone(int tf, int shift);
ZoneInfo CreateSupplyZone(int tf, int shift);
bool     IsZoneValid(ZoneInfo &zone, int tf);
bool     IsStructureSwingHigh(int tf, int bar, int strength);
bool     IsStructureSwingLow(int tf, int bar, int strength);
int      GetMarketTrend(int tf, int shift);
bool     PassMarketStructureTrendGate(ZoneInfo &zone, int tf);

void     RecalculateAllZones();
double   CalculateZoneScore(ZoneInfo &zone);
color    GetZoneColor(double score);
int      GetZoneWidth(double score);

void     AttemptAutoTrade(ZoneInfo &zone, int volumeShift = 0);
void     ImmediateEntry(ZoneInfo &zone, bool firstDetection = false);
void     DrawImmediateTradeMarker(ZoneInfo &zone, int marketTicket,
                                  int orderType, double entryPrice);
void     EnsureZoneFingerprint(ZoneInfo &zone);
bool     IsZoneYoungEnoughForTrade(ZoneInfo &zone, string &reason);
bool     ImmediateZoneIsRecent(ZoneInfo &zone);
bool     IsTradedZoneFingerprint(string fingerprint);
void     RememberTradedZoneFingerprint(string fingerprint);
bool     IsSeenZoneFingerprint(string fingerprint);
bool     RememberSeenZoneFingerprint(string fingerprint);
void     ProcessRetestTrades();
void     PlaceZonePending(ZoneInfo &zone, bool forced = false);
void     ManageZonePendings();
void     ManageImmediateEntryPendings();
bool     IsVolumeSignificant(int tf, int shift);
bool     IsVolumeNormalForRetest(int tf, int shift);
bool     IsBullishPinBar(int tf, int shift);
bool     IsBearishPinBar(int tf, int shift);
bool     IsBullishEngulfing(int tf, int shift);
bool     IsBearishEngulfing(int tf, int shift);
double   GetAverageVolume(int tf, int lookback, int shift);

void     AddBullishZone(ZoneInfo &zone);
void     AddBearishZone(ZoneInfo &zone);

void     UpdateVisuals();
void     CleanupAllVisuals();
void     CleanupDailyLevelVisuals();
void     UpdateDailyLevels();
bool     DailyLevelsGet(double &dayHigh, double &dayLow, double &mid,
                        double &lowMid, double &midHigh);
void     DrawDailyLevel(string key, double price, color lineColor, int lineWidth,
                        string labelText, bool showLevel, datetime startTime,
                        datetime endTime, datetime labelTime);
void     DrawZoneRectangle(ZoneInfo &zone, int index, bool isBull);
void     DrawSLTPLines(ZoneInfo &zone, int index, bool isBull);

string   GetZoneObjectName(ZoneInfo &zone, string suffix);
string   TimeframeToString(int tf);

bool     IsZoneBroken(ZoneInfo &zone);

int      CountBullZonesForTF(int tf);
int      CountBearZonesForTF(int tf);
bool     SendTelegramMessage(string message);
void     NotifyNewZone(ZoneInfo &zone, bool fromResync);

void     UpdateDashboard();

int      FindTFIndex(int tf);
bool     OB_IsMitigatedBar(ZoneInfo &zone, int shift);
void     OB_CreateZone(int tf, bool bullish, datetime pivotTime, int breakShift);
void     OB_UpdatePivotsLive(int tf, int tfIndex);
void     OB_CheckBreakoutsLive(int tf, int tfIndex);
void     OB_ScanLookback(int tf, int tfIndex);

bool     PassAntiFakeZoneFilter(ZoneInfo &zone, int tf);
bool     AntiFakeIsBBSqueeze(int tf, int shift);
bool     AntiFakeZoneAlreadyBroken(ZoneInfo &zone, int tf);
bool     AntiFakeHasCleanDeparture(ZoneInfo &zone, int tf);
bool     AntiFakeIsChoppyMarket(int tf, int shift);
bool     AntiFakeCounterTrendReject(ZoneInfo &zone, int tf);
bool     PassZoneRegimeFilter(int zoneTF);
double   GetLiquiditySweepScore(ZoneInfo &zone, int tf);
double   GetRVScore(ZoneInfo &zone, int tf);
double   GetEstimatedTickDelta(int tf, int shift);
double   GetDeltaCVDSignal(ZoneInfo &zone, int tf);
double   GetDeltaCVDScore(ZoneInfo &zone, int tf);
double   GetMSSScore(ZoneInfo &zone, int tf);

// New anti-fake filter functions
bool     PassConsolidationFilter(ZoneInfo &zone, int tf);
bool     ConsolIsFlatEMA(int tf, int shift);
bool     ConsolIsTightRange(int tf, int shift);
bool     ConsolIsZoneStacking(ZoneInfo &zone, int tf);
bool     ConsolIsInsideBarCluster(int tf, int shift);
bool     PassStrongBreakoutFilter(ZoneInfo &zone, int tf);
bool     PassHTFConfluenceFilter(ZoneInfo &zone, int tf);
bool     PassVolExhaustionFilter(ZoneInfo &zone, int tf);
bool     PassExhaustionFilter(ZoneInfo &zone, int tf);
bool     PassFailedRetestFilter(ZoneInfo &zone, int tf);
bool     PassWickStrengthFilter(ZoneInfo &zone, int tf);
bool     PassNewsSpikeFilter(ZoneInfo &zone, int tf);
bool     NewsIsSpikePeriod(int tf, int shift);
bool     PassAdaptiveSessionFilter(ZoneInfo &zone, int tf);
int      GetCurrentSession();
double   GetSessionMinBreakoutATR(int session);
double   GetSessionMinBodyRatio(int session);
double   GetSessionMinDepartureATR(int session);
bool     PassFirstZoneCooldown(ZoneInfo &zone, int tf);
bool     PassAdaptiveATRFilter(ZoneInfo &zone, int tf);
double   GetATRPercentile(int tf, int shift, int lookback, double percentile);
double   GetVolatilityRegimeMultiplier(int tf, int shift);
bool     PassDayOfWeekFilter(ZoneInfo &zone, int tf);
double   GetDayOfWeekMultiplier();
bool     PassVolatilityRegimeFilter(ZoneInfo &zone, int tf);
bool     PassFVGConfirmationFilter(ZoneInfo &zone, int tf);
bool     HasFVGNearZone(ZoneInfo &zone, int tf);
bool     HasDisplacement(ZoneInfo &zone, int tf);
bool     PassBOSConfirmationFilter(ZoneInfo &zone, int tf);
double   GetBOSStrengthScore(ZoneInfo &zone, int tf);
int      NormalizeBOSTimeframe(int tf);
int      GetBOSLookbackBarsForTF(int tf);
double   GetBOSMinBreakATRForTF(int tf);
int      GetBOSSwingLookbackForTF(int tf);
double   GetBOSMaxStrengthBonusForTF(int tf);
int      GetMSSwingStrengthForTF(int tf);
int      GetMSLookbackBarsForTF(int tf);
double   GetMSBOSBufferATRForTF(int tf);
int      GetDashMinBOSConfirmBarsForTF(int tf);
void     UpdateZoneBOSConfirmation(ZoneInfo &zone);
void     UpdateBOSConfirmations();
bool     PassBodyClearanceFilter(ZoneInfo &zone, int tf);
bool     PassMinHoldTimeFilter(ZoneInfo &zone, int tf);
double   GetChoppinessIndex(int tf, int shift);
bool     PassChopIndexFilter(ZoneInfo &zone, int tf);
double   GetAutocorrelation(int tf, int shift, int lookback, int lag);
bool     PassAutocorrelationFilter(ZoneInfo &zone, int tf);
double   GetEfficiencyRatio(int tf, int shift);
bool     PassEfficiencyRatioFilter(ZoneInfo &zone, int tf);
bool     IsRSITrapped(int tf, int shift);
bool     PassRSIMidRangeFilter(ZoneInfo &zone, int tf);
bool     IsPriceInMidRange(int tf, int shift);
bool     PassPriceLocationFilter(ZoneInfo &zone, int tf);

// Volume divergence
double   GetVolumeDivergenceScore(ZoneInfo &zone, int tf);
bool     HasVolumeDivergence(ZoneInfo &zone, int tf);

// Risk guard / trade safety
void     UpdateRiskState(bool force = false);
double   GetSpreadPoints();
void     AIVisionOpenCharts();
void     AIVisionCloseCharts();
bool     AIVisionIsOurs(long cid);
int      AIVisionSweepOrphans(long keepCid);
bool     AIVisionClaimLock();
void     AIVisionReleaseLock();
string   AIVisionLockName();
string   AIVisionCapture(bool automatic = false);
void     AIComputeGate();
string   DetectMarketRegime(string &why);
bool     PassFinalSignalJudge(int scoutDir, double entry, double sl, double tp2,
                              double conf, string planTrigger, string &why,
                              bool allowSoftM15);
string   AIMtfStructureBias(int tf, int shift = 1);
string   AIMtfBiasShort(string bias);
int      AIMtfIdx(string tf);
double   ChatScoutPreGateAdx(int tf, bool &available);
int      ChatScoutPreGateDir(int tf, bool &available);
void     AILogSignalCSV(string sigKey, string gptDecision, double gptConf, double entry, double sl, double tp);
int      CountEAOpenTrades(int typeFilter = -1);

// Dashboard Signal AutoTrade (POSOEBEN - nezavisen od zones)
void     AttemptDashboardSignalTrade();
string   BuildDashboardTradeComment(int dir, int sc, string grd, int stable, double atrStop);
bool     DashPassSessionEndCheck(string &why);        // Session 1h-end block
bool     DashPassBOSConfirmCheck(int minBars, int tf, int trend, double bosLevel, string &why); // 2+ bars closed BEYOND BOS
bool     DashPassAITripleFilter(int tf, int trend, string &why);  // EMA200 + ADX + RSI sanity (no extreme chase)
void     SaveDashboardSignalToCSV(string type, int dir, double entry, double sl, double tp, double lot, int sc, string grd, int stable, string ai, string note);
// --- Real AI GPT (external Node server on 127.0.0.1:3000) ---
void     AIScanMarketNow();       // POST JSON -> /ai/scan (sends OHLC + score + grade + BOS to server)
void     AIFetchResultNow();      // GET -> /ai/result (fetches last AI JSON decision, saves to cache)
void     AICheckServerAliveNow(); // GET -> /ai/health (ultra fast 3s timeout to mark Server ONLINE/OFFLINE)
bool     AiWeekendSkip();
string   AIJsonEscape(string s);
string   AIUrlEncode(string s);
int      AIWrGet(string url, char &resp[], int timeoutMs, string altSubFrom, string altSubTo); // GET (dual-url try, no headers safe)
// ---- Plan B (File Watcher Pipeline, no WebRequest needed) ----
string   AIBuildScanJSON();
bool     AIWriteScanFile(string json);
bool     AIReadResultFile(string &decision, double &confidence, string &r1, string &r2, string &r3,
                          double &entry, double &sl, double &tp, string &comment);
bool     AIReadHeartbeatTxt();
bool ZoneAlreadyTraded(int zoneID);
double   GetTodayClosedProfit();
int      GetConsecutiveLosses();
datetime GetLastLossTime();
int      GetTodayTradeCount();
bool     PassBreakoutWickRejectionFilter(ZoneInfo &zone, int tf);
bool     PassATRAccelerationFilter(ZoneInfo &zone, int tf);
bool     ZoneClosedThrough(ZoneInfo &zone);
void     ComputeEntryLevels(ZoneInfo &zone, int type, double price, double &slPrice, double &tpPrice);
bool     EntryGuardAllows(ZoneInfo &zone, int type, double price, double slPrice, double tpPrice, string &reason);
bool     TradeRRGateAllows(int type, double price, double slPrice, double tpPrice, string tag);
bool     RiskGuardAccountOK(string &reason);
bool     RiskGuardAllowsTrade(ZoneInfo &zone, int type, string &reason);
double   CalcTradeLot(double entry, double slPrice, double fallbackLot);
string   BuildTradeComment(ZoneInfo &zone);
bool     WD_Allowed();
void     WD_NoteBlock(string tag, uint startMs);
void     WD_Heartbeat(string src);
void     WD_ReviveTimer();
void     ManageOpenTrades();
void     ChatInit();
void     ChatDeinit();
void     ChatLayout();
void     ChatAsk();
void     ChatPlan();
void     ChatWatchOnTimer();
void     ChatAutoPlanOnTimer();
void     ChatScoutOnTimer();
int      ChatScoutTf();
bool     ChatMinuteWindowOpen(datetime now, int startHour, int startMinute,
                              int endHour, int endMinute);
int      ChatVisionTfFromName(string name);
string   ChatScoutStateKey(string suffix);
string   ChatScoutStatusText();
void     ChatScoutSaveState();
void     ChatScoutLoadState();
void     ChatScoutCheckArmedWatch();
void     ChatScoutEmitSignal(int dir, string setup, double entry, double sl, double tp1,
                             double tp2, double conf, string trigger, string note);
void     ChatWatchSetInstruction(string instruction);
void     ChatWatchToggle();
void     ChatWatchLoad();
void     ChatWatchSave();
string   ChatWatchStatus(string suffix);
string   ChatWatchStateSignature();
bool     ChatWatchCall(string &reply);
void     ChatPlanRun(bool automatic, bool scout = false);
void     ChatScoutHandlePlan(bool ok, string answer);
void     ChatTune();
void     ChatBuildTuneContext(string &context);
string   ChatTuneB(string name, bool value);
string   ChatTuneI(string name, int value);
string   ChatTuneD(string name, double value);
string   ChatTuneS(string name, string value);
string   ChatSanitize(string text);
string   ChatVisionCapture();
bool     ChatVisionWaitChart(long cid, int tf);
bool     ChatVisionIsOwnedChart(long cid);
bool     ChatVisionDrawDailyLevels(long cid);
string   ChatVisionJson();
bool     ChatReadVisionShot(string file, uchar &data[]);
string   ChatPlanField(string reply, string key);
string   ChatPlanNormalize(string reply);
bool     ChatPlanAdjustTP1Daily(string setup, double entry, double sl,
                                double tp2, double &tp1, string &noteOut);
bool     ChatValidatePlan(string reply, string &warning);
void     ChatPlansInit();
void     ChatPlansLoad();
void     ChatPlansSave();
void     ChatPlansUpdate();
void     ChatPlanRecord(string setup, double entry, double sl, double tp1, double tp2, double rr, double conf, bool isWatch = false);
string   ChatPlanScoreLine();
string   ChatPlanAccuracyContext();
datetime ChatStatsCutoffTime();
bool     ChatPlanInStatsPeriod(datetime t);
string   ChatPlanSessionOf(datetime t);
string   ChatPlanBucket(string label, int win, int loss);
string   ChatTriggerTypeName(int type);
string   ChatTriggerDescribe();
bool     ChatTriggerParse(string raw, int &type, double &level, int &tf);
void     ChatTriggerArm(string setup, string raw, double entry, double sl,
                        double tp1, double tp2, double rr, double conf);
void     ChatTriggerDisarm(string why);
void     ChatTriggerCheck();
void     ChatTriggerSave();
void     ChatTriggerLoad();
int      ChatPanelHeight();
void     ChatScoreLayout();
void     ChatRefreshStatus();
void     ChatBuildContext(string &context);
string   ChatCtxLevels();
string   ChatCtxVolatility();
string   ChatCtxLiquidity();
string   ChatCtxSessions();
string   ChatCtxNews();
void     ChatNewsRefresh();
void     ChatNewsLoadFile();
bool     ChatNewsParseDate(string iso, datetime &brokerTime);
string   ChatNewsExtractString(string json, string key, int startPos);
bool     ChatNewsRelevant(string currency);
void     ChatNewsParseBody(string body);
void     ChatHeadlinesRefresh();
void     ChatHeadlinesParse(string json);
string   ChatCtxHeadlines();
string   ChatCtxUsdStrength();
string   ChatUsdFindSymbol(string base);
string   ChatCtxVolatilityTag();
string   ChatCtxStats();
void     ChatStatsInit();
void     ChatStatsUpdate();
void     ChatStatsLoad();
void     ChatStatsBackfill();
void     ChatStatsOpenCtxSave();
void     ChatStatsOpenCtxLoad();
void     ChatStatsSaveRecord(int ticket, datetime closeTime, double profit, double r,
                             string grade, string session, string decision, string regime,
                             int trend, int direction, int gateDir, double confidence,
                             double entry, double sl, double tp, datetime openTime, bool unknown);
string   ChatStatsBreakdown(string field);
string   ChatHistoryFilePath();
string   ChatPlansFilePath();
void     SaveChatHistory();
bool     LoadChatHistory();
void     ChatAppend(string text, int clr);
void     ChatCreateLabel(string name, string text, int x, int y, int width, int height, color clr, int size);
void     ChatCreateRect(string name, int x, int y, int width, int height, color clr);
void     ChatCreateButton(string name, string text);
string   ChatJsonExtract(string json, string key);
long     ChatJsonExtractNum(string json, string key);
double   ChatJsonExtractDouble(string json, string key);
string   ChatJsonEscape(string text);
string   ChatJsonUnescape(string text);
string   ChatWrap(string text);
bool     ChatPostDirect(string question, string context, string history, string &answer, string vision = "");
bool     ChatPostServer(string question, string context, string history, string &answer, string vision = "");
bool     ChatFileFallback(string question, string context, string history, int requestId, string &answer, string vision = "");
void     ChatBuildHistory(string &history);
void     ChatBuildGeminiHistory(string &history);
void     ChatConversationAppend(string role, string text);

//+------------------------------------------------------------------+
//| TIME FILTER CHECK                                                |
//+------------------------------------------------------------------+
bool IsTradingAllowed()
{
   if (!UseTimeFilter) return true;
   datetime now = TimeCurrent();
   int day = TimeDayOfWeek(now);
   int hour = TimeHour(now);
   if (day == 0 && !TradeSunday)    return false;
   if (day == 1 && !TradeMonday)    return false;
   if (day == 2 && !TradeTuesday)   return false;
   if (day == 3 && !TradeWednesday) return false;
   if (day == 4 && !TradeThursday)  return false;
   if (day == 5 && !TradeFriday)    return false;
   if (day == 6 && !TradeSaturday)  return false;
   if (hour < TradingStartHour || hour >= TradingEndHour) return false;
   return true;
}

string BOSMemoryKey(int structureTF, string key)
{
   return StringFormat("TraceInst_BOS_%s_%d_%s", Symbol(), structureTF, key);
}

void LoadBOSMemory(int structureTF)
{
   string n1 = BOSMemoryKey(structureTF, "LastHigh");
   string n2 = BOSMemoryKey(structureTF, "PrevHigh");
   string n3 = BOSMemoryKey(structureTF, "LastLow");
   string n4 = BOSMemoryKey(structureTF, "PrevLow");

   if (GlobalVariableCheck(n1)) g_lastBOSHigh = GlobalVariableGet(n1);
   if (GlobalVariableCheck(n2)) g_prevBOSHigh = GlobalVariableGet(n2);
   if (GlobalVariableCheck(n3)) g_lastBOSLow  = GlobalVariableGet(n3);
   if (GlobalVariableCheck(n4)) g_prevBOSLow  = GlobalVariableGet(n4);
}

void SaveBOSMemory(int structureTF)
{
   string n1 = BOSMemoryKey(structureTF, "LastHigh");
   string n2 = BOSMemoryKey(structureTF, "PrevHigh");
   string n3 = BOSMemoryKey(structureTF, "LastLow");
   string n4 = BOSMemoryKey(structureTF, "PrevLow");

   if (g_lastBOSHigh > 0.0) GlobalVariableSet(n1, g_lastBOSHigh);
   if (g_prevBOSHigh > 0.0) GlobalVariableSet(n2, g_prevBOSHigh);
   if (g_lastBOSLow  > 0.0) GlobalVariableSet(n3, g_lastBOSLow);
   if (g_prevBOSLow  > 0.0) GlobalVariableSet(n4, g_prevBOSLow);
}

//+------------------------------------------------------------------+
//| OnInit - Initialization                                          |
//+------------------------------------------------------------------+
int OnInit()
{
   EventSetTimer(3);
   g_wdLastTimer = TimeLocal();
   g_currentDay = TimeDay(TimeCurrent());
   g_todayBullCount = 0;
   g_todayBearCount = 0;
   g_peakEquity = AccountEquity();
   g_dayStartBalance = AccountBalance();
   g_riskBlockReason = "";
   LoadBOSMemory(GetHigherTimeframe(Period()));
   g_digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
   g_pip    = Point;
   if (g_digits == 3 || g_digits == 5) g_pip *= 10;
   ArrayFree(BullishZones);
   ArrayFree(BearishZones);
   ArrayFree(g_tradedZoneFingerprints);
   g_tradedZoneFingerprintCount = 0;
   ArrayFree(g_seenZoneFingerprints);
   g_seenZoneFingerprintCount = 0;
   totalBullZones = 0;
   totalBearZones = 0;
   for (int k = 0; k < TF_COUNT; k++)
   {
      int tf = TF_List[k];
      if (Draw_CurrentChartTFOnly && tf != Period()) continue;
      lastBarTime[k] = 0;
      g_histScanned[k] = false;
      g_obSwingHighLevel[k] = 0.0;
      g_obSwingLowLevel[k] = 0.0;
      g_obSwingHighTime[k] = 0;
      g_obSwingLowTime[k] = 0;
      g_obSwingHighCrossed[k] = false;
      g_obSwingLowCrossed[k] = false;
   }
   if (DebugMode)
      Print("TraceInst_Zones init on ", Symbol());
   CleanupAllVisuals();
   if (RestoreZonesOnReload && !IsTesting()) 
   {
       RestoreAllZonesFromBackup();
       
       // Filter restored zones with regime filter if enabled
       if (Use_RegimeFilter && Regime_FilterRestoredZones)
       {
          for (int i = totalBullZones - 1; i >= 0; i--)
          {
             if (!PassZoneRegimeFilter(BullishZones[i].timeframe))
             {
                DeleteZoneVisuals(BullishZones[i]);
                RemoveBullZoneAt(i);
             }
          }
          for (int i = totalBearZones - 1; i >= 0; i--)
          {
             if (!PassZoneRegimeFilter(BearishZones[i].timeframe))
             {
                DeleteZoneVisuals(BearishZones[i]);
                RemoveBearZoneAt(i);
             }
          }
       }
   }
   
   for (int k = 0; k < TF_COUNT; k++)
   {
      int tf = TF_List[k];
      if (Draw_CurrentChartTFOnly && tf != Period()) continue;
      int bars = iBars(Symbol(), tf);
      if (bars >= 350)
      {
         if (IsTesting())
         {
            Print("Strategy Tester: historical zone backfill skipped for TF ",
                  TimeframeToString(tf));
            g_histScanned[k] = true;
         }
         else
         {
            double atr = iATR(Symbol(), tf, 60, 1);
            if (atr > 0)
            {
               ScanHistoricalZones(tf);
               g_histScanned[k] = true;
            }
         }
      }
   }
   
   for(int k=0; k<TF_COUNT; k++)
   {
       PruneOldZonesForTF(TF_List[k]);
   }
   
   UpdateVisuals();
   
   EventSetTimer(3);
   g_wdLastTimer = TimeLocal();

   // ═══════ AI GLOBAL RESET pri sekoj NOV stav na EA na chart (OnInit!) ═══════
   // NE KORISTI keširani stars od prethodna instanca, sekogas pocni od nula!
   g_aiLastScanTime   = 0;
   g_aiLastFetchTime  = 0;
   g_aiLastHealthTime = 0;
   g_aiLastScanOK     = false;
   g_aiLastMsg        = "AI off. Start StartTraceAI.bat + set AI_Enable=true.";
   g_aiDecision       = "WAIT";
   g_aiConfidence     = 0.0;
   g_aiR1 = "";  g_aiR2 = "";  g_aiR3 = "";
   g_aiLastScanMtime       = 0;
   g_aiLastResultFtime     = 0;
   g_aiLastHeartbeatTime   = 0;
   g_aiLastHeartbeatContent= "";
   g_aiLastResultTs        = 0;
   g_aiLastResultSignature = "";
   g_aiEntry = 0.0;  g_aiSL = 0.0;  g_aiTP = 0.0;
   g_aiHbAgeSec     = -1;
   g_aiRsAgeSec     = -1;
   g_aiServerOnline = false;
   g_aiResultFresh  = false;
   g_gatePass = false;  g_gateDir = 0;  g_gateWhy = "";  g_gateFail = "nema uste scan";
   g_gatePassed = 0;    g_gateTotal = 0;
   g_gateM15Flat = false; g_gateOtherPass = false;
   g_visCount = 0;      g_visFiles = "";  g_visShotTime = 0;  g_visShotLocal = 0;
   g_chatVisionCount = 0;  g_chatVisionShotLocal = 0;
   for (int vz0 = 0; vz0 < 4; vz0++) { g_visChart[vz0] = 0; g_visOwned[vz0] = false; }
   g_lastLoggedSigKey = "";
   for (int mz0 = 0; mz0 < MTF_N; mz0++) { g_mtfName[mz0] = ""; g_mtfBias[mz0] = ""; }
   Print(">>> [Plan B] EA INIT: AI_Enable=", (AI_Enable ? "true" : "false"),
         " AI_ScanEverySec=", AI_ScanEverySec,
         " AI_VisionEyes=", (AI_VisionEyes ? "true" : "false"),
         " AI_VisionOnlyOnSetup=", (AI_VisionOnlyOnSetup ? "true" : "false"),
         " AI_VisionOpenMissing=", (AI_VisionOpenMissing ? "true" : "false"),
         " local=", TimeToString(TimeLocal(), TIME_DATE|TIME_MINUTES|TIME_SECONDS));
   if (DebugMode)
      Print(">>> [Plan B] PATH DEBUG data=", TerminalInfoString(TERMINAL_DATA_PATH),
            " common=", TerminalInfoString(TERMINAL_COMMONDATA_PATH),
            " x64=", TerminalInfoInteger(TERMINAL_X64),
            " build=", TerminalInfoInteger(TERMINAL_BUILD),
            " AI_ServerURL=[", AI_ServerURL, "] len=", StringLen(AI_ServerURL));

   if (Chat_Enable && !IsTesting() && !IsOptimization())
      ChatInit();

   if (EnableTelegram && Telegram_StartupTest && !IsTesting() && !IsOptimization())
   {
      bool tgOk = SendTelegramMessage("Trace EA start: " + Symbol() + " " +
                                      TimeframeToString(Period()) + " | Telegram raboti");
      if (tgOk && Chat_Enable) { ChatAppend("TELEGRAM OK - test porakata e pratena", clrLime); ChartRedraw(); }
   }

   // AI ochi: charts se otvaraat mrzelivo pri prviot scan (ne vo OnInit, za da ne
   // se zabavi vcituvanjeto na EA-to i da ne se pravi ChartOpen dodeka MT4 se podiga)

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| OnDeinit - Cleanup                                               |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   if (Chat_Enable && !IsTesting() && !IsOptimization())
   {
      ChatPlansSave();
      SaveChatHistory();
   }
   ChatDeinit();
   AIVisionCloseCharts();
   SaveBOSMemory(GetHigherTimeframe(Period()));
   if (!IsTesting())
      SaveAllZonesToBackup();
   CleanupAllVisuals();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if (!Chat_Enable || IsTesting() || IsOptimization()) return;
   if (id == CHARTEVENT_MOUSE_MOVE)
   {
      int mx = (int)lparam;
      int my = (int)dparam;
      bool down = (sparam == "1");
      if (down && !g_chatDragging &&
          mx >= g_chatX && mx <= g_chatX + Chat_Width &&
          my >= g_chatY && my <= g_chatY + 24)
      {
         g_chatDragging = true;
         g_chatDragDX = mx - g_chatX;
         g_chatDragDY = my - g_chatY;
         g_chatMouseScroll = (bool)ChartGetInteger(0, CHART_MOUSE_SCROLL);
         ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
      }
      if (g_chatDragging && down)
      {
         g_chatX = mx - g_chatDragDX;
         g_chatY = my - g_chatDragDY;
         if (g_chatX < 0) g_chatX = 0;
         if (g_chatY < 0) g_chatY = 0;
         GlobalVariableSet("TraceChatX_" + Symbol(), g_chatX);
         GlobalVariableSet("TraceChatY_" + Symbol(), g_chatY);
         ChatLayout();
         ChartRedraw();
      }
      if (!down && g_chatDragging)
      {
         g_chatDragging = false;
         ChartSetInteger(0, CHART_MOUSE_SCROLL, g_chatMouseScroll);
      }
   }
   else if (id == CHARTEVENT_OBJECT_CLICK)
   {
      string n = sparam;
      if (StringFind(n, "TraceChat_Send") == 0) ChatAsk();
      else if (StringFind(n, "TraceChat_Plan") == 0) ChatPlan();
      else if (StringFind(n, "TraceChat_Tune") == 0) ChatTune();
      else if (StringFind(n, "TraceChat_Watch") == 0) ChatWatchToggle();
      else if (StringFind(n, "TraceChat_Clear") == 0)
      {
         g_chatTextCount = 0; ArrayResize(g_chatText, 0); ArrayResize(g_chatTextColor, 0);
         g_chatConversationCount = 0;
         ArrayResize(g_chatRole, 0); ArrayResize(g_chatMessage, 0);
         g_chatScroll = 0;
         g_chatStatus = g_chatWatchActive ? ChatWatchStatus("Ready") : "Ready [" + Chat_Mode + "]";
         ChatLayout();
      }
      else if (StringFind(n, "TraceChat_Min") == 0)
      {
         g_chatMinimized = !g_chatMinimized; ChatLayout();
      }
      else if (StringFind(n, "TraceChat_Up") == 0)
      {
         g_chatScroll += 2; ChatLayout();
      }
      else if (StringFind(n, "TraceChat_Down") == 0)
      {
         if (g_chatScroll > 1) g_chatScroll -= 2; ChatLayout();
      }
      if (ObjectFind(0, n) >= 0 && StringFind(n, "TraceChat_") == 0)
         ObjectSetInteger(0, n, OBJPROP_STATE, false);
   }
   else if (id == CHARTEVENT_OBJECT_ENDEDIT && sparam == "TraceChat_Input")
      ChatAsk();
}

//+------------------------------------------------------------------+
//| WATCHDOG / ANTI-SLEEP                                             |
//+------------------------------------------------------------------+
bool WD_Allowed()
{
   if (!Use_Watchdog) return true;
   if (g_wdPauseUntil > 0 && TimeLocal() < g_wdPauseUntil) return false;
   return true;
}

void WD_NoteBlock(string tag, uint startMs)
{
   if (!Use_Watchdog) return;
   int elapsed = (int)(GetTickCount() - startMs);
   if (elapsed < 0) elapsed = 0;
   if (elapsed > g_wdLastBlockMs) { g_wdLastBlockMs = elapsed; g_wdLastBlockTag = tag; }
   if (WD_SlowBlockMs > 0 && elapsed > WD_SlowBlockMs)
   {
      Print("WATCHDOG: '", tag, "' blokira ", elapsed, " ms -> AI/Chat pauza ",
            WD_CooldownSec, "s (zonite prodolzuvaat normalno)");
      if (WD_CooldownSec > 0) g_wdPauseUntil = TimeLocal() + WD_CooldownSec;
   }
}

void WD_Heartbeat(string src)
{
   if (!Use_Watchdog || WD_HeartbeatSec < 1) return;
   datetime now = TimeLocal();
   if (g_wdLastHeartbeat > 0 && now - g_wdLastHeartbeat < WD_HeartbeatSec) return;
   g_wdLastHeartbeat = now;
   int pauseLeft = (g_wdPauseUntil > now) ? (int)(g_wdPauseUntil - now) : 0;
   Print("WATCHDOG HB src=", src, " ticks=", g_wdTickCount, " timers=", g_wdTimerCount,
         " zones=", totalBullZones + totalBearZones, " maxBlock=", g_wdLastBlockMs, "ms(", g_wdLastBlockTag,
         ") pauza=", pauseLeft, "s");
   g_wdLastBlockMs = 0;
   g_wdLastBlockTag = "";
}

void WD_ReviveTimer()
{
   if (!Use_Watchdog || WD_TimerReviveSec < 1) return;
   if (g_wdLastTimer == 0) return;
   if (TimeLocal() - g_wdLastTimer < WD_TimerReviveSec) return;
   Print("WATCHDOG: OnTimer ne se javil ", (int)(TimeLocal() - g_wdLastTimer),
         "s -> re-armiram EventSetTimer(3)");
   EventKillTimer();
   EventSetTimer(3);
   g_wdLastTimer = TimeLocal();
}

//+------------------------------------------------------------------+
//| OnTick                                                           |
//+------------------------------------------------------------------+
void OnTick()
{
   g_wdTickCount++;
   WD_ReviveTimer();
   if (EnableDashboard) 
   {
       static uint lastDashUpdate = 0;
       if (GetTickCount() - lastDashUpdate > 1000)
       {
           UpdateDashboard();
           lastDashUpdate = GetTickCount();
       }
   }
   static int tickCounter = 0;
   tickCounter++;
   int today = TimeDay(TimeCurrent());
   if (today != g_currentDay)
   {
      g_currentDay = today;
      g_todayBullCount = 0;
      g_todayBearCount = 0;
      g_dayStartBalance = AccountBalance();
   }
   static datetime lastUpdateBarTime = 0;
   datetime currentBarTime = iTime(Symbol(), Period(), 0);
   static int barsPassed = 0;
   if (currentBarTime != lastUpdateBarTime)
   {
      lastUpdateBarTime = currentBarTime;
      barsPassed++;
      if (barsPassed >= Strength_Update_Frequency)
      {
         RecalculateAllZones();
         barsPassed = 0;
      }
   }
   UpdateRiskState();
   ProcessTimeframes();
   UpdateBOSConfirmations();
   ProcessRetestTrades();
   UpdateVisuals();
   ManageZonePendings();
   ManageImmediateEntryPendings();
   ManageOpenTrades();

   // Dashboard Signal AutoTrade (POSEBEN - nezavisen od site zoni)
   if (Dash_EnableSignalTrading) AttemptDashboardSignalTrade();

   // Real AI GPT (server 127.0.0.1:3000) - fetch result on every tick (throttled inside)
   // NAPOMENA: AIScanMarketNow se vika i tuka, ne samo vo OnTimer - ako tajmerot zastane
   // (ili OnTimer padne vo nekoja druga funkcija), skenot sepak prodolzuva.
   if (AI_Enable && WD_Allowed())
   {
      uint wdAI = GetTickCount();
      AICheckServerAliveNow();
      AIScanMarketNow();
      AIFetchResultNow();
      WD_NoteBlock("AI", wdAI);
   }
   // WAIT_FOR: lokalna proverka na armiraniot uslov - besplatno, bez API povik.
   if (Chat_Enable) ChatTriggerCheck();
   WD_Heartbeat("tick");
}

void OnTimer()
{
   g_wdTimerCount++;
   g_wdLastTimer = TimeLocal();
   if (EnableDashboard) 
   {
       UpdateDashboard();
   }
   UpdateRiskState();
   ProcessTimeframes();
   UpdateVisuals();
   ManageZonePendings();
   ManageImmediateEntryPendings();
   ManageOpenTrades();

   // Dashboard Signal AutoTrade (POSEBEN - nezavisen od site zoni)
   if (Dash_EnableSignalTrading) AttemptDashboardSignalTrade();

   // Real AI GPT - scan + fetch (throttled inside functions)
   if (AI_Enable && WD_Allowed())
   {
      uint wdAIOnTimer = GetTickCount();
      AICheckServerAliveNow();
      AIScanMarketNow();
      AIFetchResultNow();
      WD_NoteBlock("AI", wdAIOnTimer);
   }
   if (Chat_Enable && !IsTesting() && !IsOptimization() && WD_Allowed())
   {
      uint wdChat = GetTickCount();
      ChatNewsRefresh();
      ChatHeadlinesRefresh();
      ChatStatsUpdate();
      ChatPlansUpdate();
      WD_NoteBlock("ChatRefresh", wdChat);
   }
   if (WD_Allowed())
   {
      uint wdChatWatch = GetTickCount();
      ChatWatchOnTimer();
      WD_NoteBlock("ChatWatch", wdChatWatch);
   }
   if (WD_Allowed())
   {
      uint wdChatAutoPlan = GetTickCount();
      ChatAutoPlanOnTimer();
      WD_NoteBlock("ChatAutoPlan", wdChatAutoPlan);
   }
   if (WD_Allowed())
   {
      uint wdChatScout = GetTickCount();
      ChatScoutOnTimer();
      WD_NoteBlock("ChatScout", wdChatScout);
   }
   if (Chat_Enable) ChatTriggerCheck();
   WD_Heartbeat("timer");
}

void ProcessTimeframes()
{
   static datetime lastScanTime = 0;
   datetime now = TimeLocal();
   
   bool forceUpdate = (now - lastScanTime >= 30);
   
   for (int k = 0; k < TF_COUNT; k++)
   {
      int tf = TF_List[k];
      if (Draw_CurrentChartTFOnly && tf != Period()) continue;
      int bars = iBars(Symbol(), tf);
      if (bars < 20) continue;
      
      if (!g_histScanned[k] && bars >= 350)
      {
         if (IsTesting())
         {
            Print("Strategy Tester: historical zone backfill skipped for TF ",
                  TimeframeToString(tf), " as history reached 350 bars");
            g_histScanned[k] = true;
         }
         else
         {
            double atr = iATR(Symbol(), tf, 60, 1);
            if (atr > 0)
            {
               ScanHistoricalZones(tf);
               g_histScanned[k] = true;
            }
         }
      }
      
      datetime bt = iTime(Symbol(), tf, 0);
      if (bt == 0) continue;
      
      bool isNewBar = (bt != lastBarTime[k]);
      
      if (isNewBar || forceUpdate)
      {
          if (isNewBar) lastBarTime[k] = bt;
          
          if (g_histScanned[k] || bars < 350) 
          {
             if (isNewBar) PruneOldZonesForTF(tf);
             DetectNewZonesForTF(tf);
          }
      }
   }
   
   if (forceUpdate) lastScanTime = now;

   OB_ResyncZones();
}

//+------------------------------------------------------------------+
//| Prune zones older than Zone_ExpiryBars                            |
//+------------------------------------------------------------------+
void PruneOldZonesForTF(int tf)
{
   int expiryBars = Zone_ExpiryBars;
   if (expiryBars <= 0) return; // 0 = never expire

   int bars = iBars(Symbol(), tf);
   if (bars <= expiryBars) return;
   datetime cutoffTime = iTime(Symbol(), tf, expiryBars);
   if (cutoffTime == 0) return;
   for (int i = totalBullZones - 1; i >= 0; i--)
   {
      if (BullishZones[i].timeframe == tf)
      {
         datetime effTime = BullishZones[i].startTime;
         if (effTime == 0 && BullishZones[i].breakoutTime > 0)
            effTime = BullishZones[i].breakoutTime;
         if (effTime == 0 && BullishZones[i].breakoutBar >= 0 && BullishZones[i].breakoutBar < iBars(Symbol(), tf))
            effTime = iTime(Symbol(), tf, BullishZones[i].breakoutBar);

         bool zoneInvalid = (effTime == 0 && BullishZones[i].top == 0);

         if ((effTime > 0 && effTime < cutoffTime) || zoneInvalid)
         {
             DeleteZoneVisuals(BullishZones[i]);
             RemoveBullZoneAt(i);
         }
      }
   }
   for (int i = totalBearZones - 1; i >= 0; i--)
   {
      if (BearishZones[i].timeframe == tf)
      {
         datetime effTime = BearishZones[i].startTime;
         if (effTime == 0 && BearishZones[i].breakoutTime > 0)
            effTime = BearishZones[i].breakoutTime;
         if (effTime == 0 && BearishZones[i].breakoutBar >= 0 && BearishZones[i].breakoutBar < iBars(Symbol(), tf))
            effTime = iTime(Symbol(), tf, BearishZones[i].breakoutBar);

         bool zoneInvalid = (effTime == 0 && BearishZones[i].top == 0);

         if ((effTime > 0 && effTime < cutoffTime) || zoneInvalid)
         {
             DeleteZoneVisuals(BearishZones[i]);
             RemoveBearZoneAt(i);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Anti fake zone filter                                            |
//+------------------------------------------------------------------+
bool PassAntiFakeZoneFilter(ZoneInfo &zone, int tf)
{
   if (!PassMarketStructureTrendGate(zone, tf)) return false;
   if (!PassBOSConfirmationFilter(zone, tf)) return false;
   if (!Use_AntiFakeFilter) return true;
   EnsureZoneOrdered(zone);

   // Impulse-to-Base Ratio - the impulse that created the zone must be
   // significantly larger than the base itself. Weak impulse = fake zone.
   if (!PassImpulseBaseRatioFilter(zone, tf))
   {
      if (DebugMode) Print("AntiFake reject: impulse-to-base ratio too low ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   // Breakout wick rejection - a breakout candle that is mostly wick is a
   // liquidity grab, not displacement. The order block behind it is fake.
   if (!PassBreakoutWickRejectionFilter(zone, tf))
   {
      if (DebugMode) Print("AntiFake reject: breakout wick rejection ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   // ATR acceleration - genuine institutional moves expand volatility.
   if (!PassATRAccelerationFilter(zone, tf))
   {
      if (DebugMode) Print("AntiFake reject: no ATR acceleration ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   // Volume divergence: price prints a new extreme on weaker volume, or the
   // breakout bar is a climax bar. With VD_BlockTradesOnly the zone is kept on
   // the chart and only the order is blocked later in AttemptAutoTrade.
   if (Use_VolumeDivergenceFilter && !VD_BlockTradesOnly && HasVolumeDivergence(zone, tf))
   {
      if (DebugMode) Print("AntiFake reject: volume divergence ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   // --- SOFT scoring ---
   // EVERY filter below stays ACTIVE, but a zone is rejected only if it fails
   // MORE than AntiFake_MaxSoftFails of them. Nothing here is a hard block, so
   // raising AntiFake_MaxSoftFails always lets more zones through.
   int fails = 0;
   int maxFails = AntiFake_MaxSoftFails;
   if (maxFails < 0) maxFails = 0;
   string failList = "";

   // Formerly "hard" checks, now counted as soft fails too:
   if (AntiFake_BlockBrokenZones && AntiFakeZoneAlreadyBroken(zone, tf))  { fails++; failList += "AlreadyBroken; "; }
   if (VD_CountAsSoftFail && HasVolumeDivergence(zone, tf))               { fails++; failList += "VolumeDivergence; "; }
   if (!PassNewsSpikeFilter(zone, tf))                                    { fails++; failList += "NewsSpike; "; }
   if (!PassZoneRegimeFilter(tf))                                         { fails++; failList += "Regime; "; }

   // Current-market chop / BB squeeze (real-time only) -> counts as ONE soft fail
   if (!g_isScanningHistory)
   {
      bool nowBad = false;
      if (AntiFake_BlockChopNow &&
          (AntiFakeIsChoppyMarket(Period(), 1)
           || (tf != Period() && AntiFakeIsChoppyMarket(tf, 1))
           || (tf != PERIOD_H1 && Period() != PERIOD_H1 && AntiFakeIsChoppyMarket(PERIOD_H1, 1))))
         nowBad = true;
      if (AntiFake_BlockBBSqueeze &&
          (AntiFakeIsBBSqueeze(Period(), 1)
           || (tf != Period() && AntiFakeIsBBSqueeze(tf, 1))))
         nowBad = true;
      if (nowBad) { fails++; failList += "NowChop/BB; "; }
   }

   if (AntiFake_BlockChop && AntiFakeIsChoppyMarket(tf, zone.breakoutBar))      { fails++; failList += "Chop; "; }
   if (AntiFake_RequireCleanDeparture && !AntiFakeHasCleanDeparture(zone, tf))  { fails++; failList += "CleanDeparture; "; }
   if (AntiFake_BlockCounterTrend && AntiFakeCounterTrendReject(zone, tf))      { fails++; failList += "CounterTrend; "; }
   if (!PassConsolidationFilter(zone, tf))     { fails++; failList += "Consolidation; "; }
   if (!PassStrongBreakoutFilter(zone, tf))    { fails++; failList += "StrongBreakout; "; }
   if (!PassHTFConfluenceFilter(zone, tf))     { fails++; failList += "HTFConfluence; "; }
   if (!PassVolExhaustionFilter(zone, tf))     { fails++; failList += "VolExhaustion; "; }
   if (!PassFailedRetestFilter(zone, tf))      { fails++; failList += "FailedRetest; "; }
   if (!PassWickStrengthFilter(zone, tf))      { fails++; failList += "WickStrength; "; }
   if (!PassAdaptiveSessionFilter(zone, tf))   { fails++; failList += "AdaptiveSession; "; }
   if (!PassFirstZoneCooldown(zone, tf))       { fails++; failList += "FirstZoneCooldown; "; }
   if (!PassAdaptiveATRFilter(zone, tf))       { fails++; failList += "AdaptiveATR; "; }
   if (!PassDayOfWeekFilter(zone, tf))         { fails++; failList += "DayOfWeek; "; }
   if (!PassVolatilityRegimeFilter(zone, tf))  { fails++; failList += "VolatilityRegime; "; }
   if (!PassFVGConfirmationFilter(zone, tf))   { fails++; failList += "FVG; "; }
   if (!PassBodyClearanceFilter(zone, tf))     { fails++; failList += "BodyClearance; "; }
   if (!PassMinHoldTimeFilter(zone, tf))       { fails++; failList += "MinHoldTime; "; }
   if (!PassChopIndexFilter(zone, tf))         { fails++; failList += "ChopIndex; "; }
   if (!PassAutocorrelationFilter(zone, tf))   { fails++; failList += "Autocorrelation; "; }
   if (!PassEfficiencyRatioFilter(zone, tf))   { fails++; failList += "EfficiencyRatio; "; }
   if (!PassRSIMidRangeFilter(zone, tf))       { fails++; failList += "RSIMidRange; "; }
   if (!PassPriceLocationFilter(zone, tf))     { fails++; failList += "PriceLocation; "; }
   if (!PassExhaustionFilter(zone, tf))        { fails++; failList += "Exhaustion; "; }

   if (fails > maxFails)
   {
      if (DebugMode) Print("AntiFake reject: ", fails, " soft-fails > ", maxFails, " [", failList, "] ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }
   if (DebugMode && fails > 0)
      Print("AntiFake PASS with ", fails, "/", maxFails, " soft-fails [", failList, "] ", zone.zoneType, " TF=", TimeframeToString(tf));
   return true;
}

bool PassImpulseBaseRatioFilter(ZoneInfo &zone, int tf)
{
   if (!Use_ImpulseBaseRatioFilter) return true;

   int boBar = zone.breakoutBar;
   if (boBar < 1) return true;

   double atr = iATR(Symbol(), tf, 14, boBar);
   if (atr <= 0) return true;

   // Measure the base (zone) height
   double baseHeight = zone.top - zone.bottom;
   if (baseHeight <= 0) return true;

   // Measure the impulse: the move that created the zone (breakout candle + follow-through)
   int impulseBars = IBR_ImpulseBars;
   if (impulseBars < 1) impulseBars = 1;

   int bars = iBars(Symbol(), tf);
   double impulseSize = 0;

   for (int i = boBar; i >= MathMax(0, boBar - impulseBars + 1); i--)
   {
      if (i >= bars) continue;
      double h = iHigh(Symbol(), tf, i);
      double l = iLow(Symbol(), tf, i);
      impulseSize += (h - l);
   }

   if (impulseSize <= 0) return true;

   // Ratio: impulse must be significantly larger than the base
   double ratio = impulseSize / baseHeight;

   if (ratio < IBR_MinRatio)
   {
      if (DebugMode) Print("IBR reject: Impulse/Base ratio too low. ", DoubleToString(ratio, 2), " < ", DoubleToString(IBR_MinRatio, 2), " TF=", TimeframeToString(tf));
      return false;
   }

   // Also check that the impulse itself is meaningful in ATR terms
   if (impulseSize < atr * IBR_MinImpulseATR)
   {
      if (DebugMode) Print("IBR reject: Impulse too small in ATR. ", DoubleToString(impulseSize / atr, 2), " < ", DoubleToString(IBR_MinImpulseATR, 2), " TF=", TimeframeToString(tf));
      return false;
   }

   return true;
}

bool AntiFakeIsBBSqueeze(int tf, int shift)
{
   int bbTF = AntiFake_BB_TF;
   if (bbTF <= 0) bbTF = tf;
   if (bbTF <= 0) return false;
   if (shift < 0) shift = 0;
   double up = iBands(Symbol(), bbTF, AntiFake_BB_Period, AntiFake_BB_Dev, 0, PRICE_CLOSE, MODE_UPPER, shift);
   double dn = iBands(Symbol(), bbTF, AntiFake_BB_Period, AntiFake_BB_Dev, 0, PRICE_CLOSE, MODE_LOWER, shift);
   if (up == EMPTY_VALUE || dn == EMPTY_VALUE) return false;
   double width = up - dn;
   if (width <= 0) return false;
   double atr = iATR(Symbol(), bbTF, 14, shift);
   if (atr <= 0) return false;
   return (width < atr * AntiFake_MinBBWidthATR);
}

bool AntiFakeZoneAlreadyBroken(ZoneInfo &zone, int tf)
{
   int startShift = iBarShift(Symbol(), tf, zone.startTime, true);
   if (startShift < 1) startShift = zone.breakoutBar;
   if (startShift < 1) return false;

   double zoneHeight = zone.top - zone.bottom;
   if (zoneHeight <= 0) return true;
   double deepBull = zone.bottom + zoneHeight * 0.30;
   double deepBear = zone.top - zoneHeight * 0.30;

   for (int i = startShift - 1; i >= 0; i--)
   {
      double c = iClose(Symbol(), tf, i);
      double h = iHigh(Symbol(), tf, i);
      double l = iLow(Symbol(), tf, i);
      if (zone.zoneType == "Bull")
      {
         if (c < zone.bottom || l < zone.bottom) return true;
         if (l <= deepBull && c < zone.top) return true;
      }
      else
      {
         if (c > zone.top || h > zone.top) return true;
         if (h >= deepBear && c > zone.bottom) return true;
      }
   }
   return false;
}

bool AntiFakeHasCleanDeparture(ZoneInfo &zone, int tf)
{
   int shift = zone.breakoutBar;
   int bars = iBars(Symbol(), tf);
   if (shift < 1 || shift >= bars) return false;

   double atr = iATR(Symbol(), tf, 14, shift);
   if (atr <= 0) return false;
   int n = AntiFake_DepartureBars;
   if (n < 2) n = 2;
   if (n > 8) n = 8;

   double bestMove = 0.0;
   int directionalBars = 0;
   for (int i = shift; i >= 0 && i >= shift - n + 1; i--)
   {
      double o = iOpen(Symbol(), tf, i);
      double c = iClose(Symbol(), tf, i);
      double h = iHigh(Symbol(), tf, i);
      double l = iLow(Symbol(), tf, i);
      if (zone.zoneType == "Bull")
      {
         if (c > o) directionalBars++;
         bestMove = MathMax(bestMove, h - zone.top);
      }
      else
      {
         if (c < o) directionalBars++;
         bestMove = MathMax(bestMove, zone.bottom - l);
      }
   }

   if (directionalBars < 1) return false;
   if (bestMove < atr * AntiFake_MinDepartureATR) return false;

   double closeBreak = iClose(Symbol(), tf, shift);
   if (zone.zoneType == "Bull" && closeBreak <= zone.top) return false;
   if (zone.zoneType == "Bear" && closeBreak >= zone.bottom) return false;
   return true;
}

bool AntiFakeIsChoppyMarket(int tf, int shift)
{
   int bars = iBars(Symbol(), tf);
   int lb = AntiFake_ChopLookback;
   if (lb < 10) lb = 10;
   if (shift + lb >= bars) lb = bars - shift - 1;
   if (lb < 10) return false;

   double atr = iATR(Symbol(), tf, 14, shift);
   if (atr <= 0) return false;
   double hi = -DBL_MAX;
   double lo = DBL_MAX;
   int colorChanges = 0;
   int lastColor = 0;

   for (int i = shift; i < shift + lb; i++)
   {
      double h = iHigh(Symbol(), tf, i);
      double l = iLow(Symbol(), tf, i);
      double o = iOpen(Symbol(), tf, i);
      double c = iClose(Symbol(), tf, i);
      if (h > hi) hi = h;
      if (l < lo) lo = l;
      int candleColor = (c > o) ? 1 : ((c < o) ? -1 : 0);
      if (candleColor != 0 && lastColor != 0 && candleColor != lastColor) colorChanges++;
      if (candleColor != 0) lastColor = candleColor;
   }

   if ((hi - lo) < atr * AntiFake_MinRangeATR) return true;
   if (colorChanges > AntiFake_MaxColorChanges) return true;
   return false;
}

bool AntiFakeCounterTrendReject(ZoneInfo &zone, int tf)
{
   int trend = GetMarketTrend(tf, 1);
   if (trend == 0) return false;
   if (zone.zoneType == "Bull") return (trend == -1);
   if (zone.zoneType == "Bear") return (trend == 1);
   return true;
}

//+------------------------------------------------------------------+
//| CONSOLIDATION FILTER                                             |
//| Detects if the zone is forming inside a consolidation area.      |
//| Consolidation = flat EMA, tight range, zone stacking, inside bars|
//+------------------------------------------------------------------+
bool PassConsolidationFilter(ZoneInfo &zone, int tf)
{
   if (!Use_ConsolidationFilter) return true;

   int shift = zone.breakoutBar;
   if (shift < 1) return true;

   // 1. Flat EMA check - if EMA is flat, market is consolidating
   if (Consol_BlockFlatEMA && ConsolIsFlatEMA(tf, shift))
   {
      if (DebugMode) Print("Consolidation reject: Flat EMA. ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   // 2. Tight range check - if recent price action is in a tight range
   if (Consol_BlockTightRange && ConsolIsTightRange(tf, shift))
   {
      if (DebugMode) Print("Consolidation reject: Tight range. ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   // 3. Zone stacking check - too many zones close together = chop
   if (Consol_BlockZoneStacking && ConsolIsZoneStacking(zone, tf))
   {
      if (DebugMode) Print("Consolidation reject: Zone stacking. ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   // 4. Inside bar cluster check - many inside bars = consolidation
   if (Consol_BlockInsideBarCluster && ConsolIsInsideBarCluster(tf, shift))
   {
      if (DebugMode) Print("Consolidation reject: Inside bar cluster. ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   return true;
}

bool ConsolIsFlatEMA(int tf, int shift)
{
   int emaPeriod = Consol_EMA_Period;
   if (emaPeriod < 10) emaPeriod = 10;
   int slopeBars = Consol_EMA_SlopeBars;
   if (slopeBars < 3) slopeBars = 3;

   double atr = iATR(Symbol(), tf, 14, shift);
   if (atr <= 0) return false;

   // Calculate EMA slope: difference between EMA now and EMA N bars ago
   double emaNow = iMA(Symbol(), tf, emaPeriod, 0, MODE_EMA, PRICE_CLOSE, shift);
   double emaPrev = iMA(Symbol(), tf, emaPeriod, 0, MODE_EMA, PRICE_CLOSE, shift + slopeBars);

   if (emaNow == EMPTY_VALUE || emaPrev == EMPTY_VALUE) return false;

   double slope = MathAbs(emaNow - emaPrev);

   // If slope is less than threshold * ATR, EMA is flat = consolidation
   return (slope < atr * Consol_MaxEMASlopeATR);
}

bool ConsolIsTightRange(int tf, int shift)
{
   int lb = Consol_RangeLookback;
   if (lb < 5) lb = 5;
   int bars = iBars(Symbol(), tf);
   if (shift + lb >= bars) lb = bars - shift - 1;
   if (lb < 5) return false;

   double atr = iATR(Symbol(), tf, 14, shift);
   if (atr <= 0) return false;

   double hi = -DBL_MAX;
   double lo = DBL_MAX;
   for (int i = shift; i < shift + lb; i++)
   {
      double h = iHigh(Symbol(), tf, i);
      double l = iLow(Symbol(), tf, i);
      if (h > hi) hi = h;
      if (l < lo) lo = l;
   }

   double range = hi - lo;
   // If range is less than MaxRangeATR * ATR, it's a tight consolidation
   return (range < atr * Consol_MaxRangeATR);
}

bool ConsolIsZoneStacking(ZoneInfo &zone, int tf)
{
   double atr = iATR(Symbol(), tf, 14, zone.breakoutBar);
   if (atr <= 0) return false;

   double proximity = atr * Consol_StackATRDistance;
   int nearbyZones = 0;

   if (zone.zoneType == "Bull")
   {
      double zoneMid = (zone.top + zone.bottom) * 0.5;
      for (int i = 0; i < totalBullZones; i++)
      {
         if (BullishZones[i].timeframe != tf) continue;
         double existMid = (BullishZones[i].top + BullishZones[i].bottom) * 0.5;
         if (MathAbs(zoneMid - existMid) < proximity)
            nearbyZones++;
      }
   }
   else
   {
      double zoneMid = (zone.top + zone.bottom) * 0.5;
      for (int i = 0; i < totalBearZones; i++)
      {
         if (BearishZones[i].timeframe != tf) continue;
         double existMid = (BearishZones[i].top + BearishZones[i].bottom) * 0.5;
         if (MathAbs(zoneMid - existMid) < proximity)
            nearbyZones++;
      }
   }

   return (nearbyZones >= Consol_StackMaxZones);
}

bool ConsolIsInsideBarCluster(int tf, int shift)
{
   int lb = Consol_InsideBarLookback;
   if (lb < 3) lb = 3;
   int bars = iBars(Symbol(), tf);
   if (shift + lb >= bars) lb = bars - shift - 1;
   if (lb < 3) return false;

   int insideBars = 0;
   for (int i = shift; i < shift + lb - 1; i++)
   {
      double hiCur = iHigh(Symbol(), tf, i);
      double loCur = iLow(Symbol(), tf, i);
      double hiPrev = iHigh(Symbol(), tf, i + 1);
      double loPrev = iLow(Symbol(), tf, i + 1);

      // Inside bar: current bar's range is within previous bar's range
      if (hiCur <= hiPrev && loCur >= loPrev)
         insideBars++;
   }

   return (insideBars >= Consol_InsideBarCount);
}

//+------------------------------------------------------------------+
//| STRONG BREAKOUT FILTER                                           |
//| Ensures the breakout candle that created the zone is strong.     |
//| Weak breakouts = fake zones.                                     |
//+------------------------------------------------------------------+
bool PassStrongBreakoutFilter(ZoneInfo &zone, int tf)
{
   if (!Use_StrongBreakoutFilter) return true;

   int boBar = zone.breakoutBar;
   if (boBar < 0) return false;

   double atr = iATR(Symbol(), tf, 14, boBar);
   if (atr <= 0) return false;

   double hi = iHigh(Symbol(), tf, boBar);
   double lo = iLow(Symbol(), tf, boBar);
   double op = iOpen(Symbol(), tf, boBar);
   double cl = iClose(Symbol(), tf, boBar);
   double range = hi - lo;
   double body = MathAbs(cl - op);

   if (range <= 0) return false;

   // 1. Body must be large relative to range (strong directional candle)
   if (body / range < SB_MinBodyRatio)
   {
      if (DebugMode) Print("StrongBreakout reject: Body ratio too low. ", DoubleToString(body/range, 2), " < ", DoubleToString(SB_MinBodyRatio, 2));
      return false;
   }

   // 2. Close must be near the extreme (strong close)
   if (zone.zoneType == "Bull")
   {
      double closeStrength = (cl - lo) / range;
      if (closeStrength < SB_MinCloseStrength)
      {
         if (DebugMode) Print("StrongBreakout reject: Bull close strength low. ", DoubleToString(closeStrength, 2));
         return false;
      }
   }
   else
   {
      double closeStrength = (hi - cl) / range;
      if (closeStrength < SB_MinCloseStrength)
      {
         if (DebugMode) Print("StrongBreakout reject: Bear close strength low. ", DoubleToString(closeStrength, 2));
         return false;
      }
   }

   // 3. Breakout must be at least MinBreakoutATR in size
   if (range < atr * SB_MinBreakoutATR)
   {
      if (DebugMode) Print("StrongBreakout reject: Breakout too small. ", DoubleToString(range/atr, 2), " ATR");
      return false;
   }

   // 4. Volume spike on breakout
   if (SB_RequireVolumeSpike)
   {
      double boVol = (double)iVolume(Symbol(), tf, boBar);
      double avgVol = GetAverageVolume(tf, SB_VolumeLookback, boBar + 1);
      if (avgVol > 0 && boVol < avgVol * SB_MinVolumeRatio)
      {
         if (DebugMode) Print("StrongBreakout reject: No volume spike. Vol ratio=", DoubleToString(boVol/avgVol, 2));
         return false;
      }
   }

   // 5. Follow-through after breakout
   if (SB_RequireFollowThrough)
   {
      int ftBars = SB_FollowThroughBars;
      if (ftBars < 1) ftBars = 1;
      int bars = iBars(Symbol(), tf);
      bool hasFollow = false;

      for (int i = boBar - 1; i >= MathMax(0, boBar - ftBars); i--)
      {
         if (i >= bars) continue;
         double ftOpen = iOpen(Symbol(), tf, i);
         double ftClose = iClose(Symbol(), tf, i);

         if (zone.zoneType == "Bull")
         {
            // Follow-through: next bars should continue upward
            if (ftClose > ftOpen && (ftClose - zone.top) >= atr * SB_MinFollowATR)
            {
               hasFollow = true;
               break;
            }
         }
         else
         {
            // Follow-through: next bars should continue downward
            if (ftClose < ftOpen && (zone.bottom - ftClose) >= atr * SB_MinFollowATR)
            {
               hasFollow = true;
               break;
            }
         }
      }

      if (!hasFollow)
      {
         if (DebugMode) Print("StrongBreakout reject: No follow-through. ", zone.zoneType, " TF=", TimeframeToString(tf));
         return false;
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| HTF CONFLUENCE FILTER                                            |
//| Zone must align with higher timeframe structure.                 |
//| Counter-HTF zones are much more likely to be fake.               |
//+------------------------------------------------------------------+
bool PassHTFConfluenceFilter(ZoneInfo &zone, int tf)
{
   if (!Use_HTFConfluenceFilter) return true;

   // During history scanning, HTF zones may not be loaded yet - skip this filter
   if (g_isScanningHistory) return true;

   int htf = GetHigherTimeframe(tf);
   if (htf == tf) return true; // Already highest TF

   // 1. Trend alignment - zone direction should match HTF trend
   if (HTF_RequireTrendAlignment)
   {
      int htfTrend = GetMarketTrend(htf, 1);
      if (htfTrend != 0)
      {
         // Counter-HTF-trend zone is suspicious
         if (HTF_BlockCounterHTF)
         {
            if (zone.zoneType == "Bull" && htfTrend == -1)
            {
               if (DebugMode) Print("HTFConfluence reject: Bull zone counter HTF downtrend. TF=", TimeframeToString(tf));
               return false;
            }
            if (zone.zoneType == "Bear" && htfTrend == 1)
            {
               if (DebugMode) Print("HTFConfluence reject: Bear zone counter HTF uptrend. TF=", TimeframeToString(tf));
               return false;
            }
         }
      }
   }

   // 2. Zone alignment - zone should be near a HTF zone of same direction
   if (HTF_RequireZoneAlignment)
   {
      double atr = iATR(Symbol(), tf, 14, zone.breakoutBar);
      if (atr <= 0) return true;

      double proximity = atr * HTF_ZoneProximityATR;
      bool hasHTFZone = false;

      if (zone.zoneType == "Bull")
      {
         for (int i = 0; i < totalBullZones; i++)
         {
            if (BullishZones[i].timeframe != htf) continue;
            double htfMid = (BullishZones[i].top + BullishZones[i].bottom) * 0.5;
            double zoneMid = (zone.top + zone.bottom) * 0.5;
            if (MathAbs(zoneMid - htfMid) < proximity)
            {
               hasHTFZone = true;
               break;
            }
         }
      }
      else
      {
         for (int i = 0; i < totalBearZones; i++)
         {
            if (BearishZones[i].timeframe != htf) continue;
            double htfMid = (BearishZones[i].top + BearishZones[i].bottom) * 0.5;
            double zoneMid = (zone.top + zone.bottom) * 0.5;
            if (MathAbs(zoneMid - htfMid) < proximity)
            {
               hasHTFZone = true;
               break;
            }
         }
      }

      // If no HTF zone alignment and counter trend, reject
      if (!hasHTFZone && HTF_RequireTrendAlignment)
      {
         int htfTrend = GetMarketTrend(htf, 1);
         if (htfTrend != 0)
         {
            // Zone against HTF trend AND no HTF zone support = very likely fake
            if ((zone.zoneType == "Bull" && htfTrend == -1) ||
                (zone.zoneType == "Bear" && htfTrend == 1))
            {
               if (DebugMode) Print("HTFConfluence reject: No HTF zone + counter trend. ", zone.zoneType, " TF=", TimeframeToString(tf));
               return false;
            }
         }
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| VOLUME EXHAUSTION FILTER                                         |
//| Checks volume quality around the zone.                           |
//| Declining volume into base = exhaustion (good for reversal).     |
//| Low volume on breakout = weak conviction (fake zone).            |
//+------------------------------------------------------------------+
bool PassVolExhaustionFilter(ZoneInfo &zone, int tf)
{
   if (!Use_VolExhaustionFilter) return true;

   int boBar = zone.breakoutBar;
   if (boBar < 1) return true;

   int bars = iBars(Symbol(), tf);

   // 1. Volume should be declining into the base (shows exhaustion before reversal)
   if (VEx_RequireDecliningVolume)
   {
      int baseBars = VEx_BaseBarsToCheck;
      if (baseBars < 2) baseBars = 2;

      double earlyVol = 0;
      double lateVol = 0;
      int earlyCount = 0;
      int lateCount = 0;

      // First half of base bars (earlier = further from breakout)
      int halfBars = baseBars / 2;
      if (halfBars < 1) halfBars = 1;

      for (int i = boBar + 1; i <= boBar + halfBars && i < bars; i++)
      {
         lateVol += (double)iVolume(Symbol(), tf, i);
         lateCount++;
      }
      for (int i = boBar + halfBars + 1; i <= boBar + baseBars && i < bars; i++)
      {
         earlyVol += (double)iVolume(Symbol(), tf, i);
         earlyCount++;
      }

      if (earlyCount > 0 && lateCount > 0)
      {
         earlyVol /= earlyCount;
         lateVol /= lateCount;

         // Volume in the base should not be higher than earlier volume
         // (high volume in base = continuation, not reversal)
         if (earlyVol > 0 && lateVol > earlyVol * (1.0 / VEx_MaxBaseVolRatio))
         {
            if (DebugMode) Print("VolExhaustion reject: Volume not declining into base. Late=", DoubleToString(lateVol, 0), " Early=", DoubleToString(earlyVol, 0));
            return false;
         }
      }
   }

   // 2. Breakout must have sufficient volume
   if (VEx_BlockLowVolumeBreakout)
   {
      double boVol = (double)iVolume(Symbol(), tf, boBar);
      double avgVol = GetAverageVolume(tf, 30, boBar + 1);
      if (avgVol > 0 && boVol < avgVol * VEx_MinBreakoutVolRatio)
      {
         if (DebugMode) Print("VolExhaustion reject: Low breakout volume. Ratio=", DoubleToString(boVol/avgVol, 2));
         return false;
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| FAILED RETEST FILTER                                             |
//| Detects if price has already penetrated the zone multiple times. |
//| Multiple penetrations = zone is weak/fake.                       |
//+------------------------------------------------------------------+
bool PassFailedRetestFilter(ZoneInfo &zone, int tf)
{
   if (!Use_FailedRetestFilter) return true;

   // During history scanning, zones from the past have already been "retested"
   // Only apply this filter to newly detected zones in real-time
   if (g_isScanningHistory) return true;

   int startShift = iBarShift(Symbol(), tf, zone.startTime, true);
   if (startShift < 1) startShift = zone.breakoutBar;
   if (startShift < 1) return true;

   double atr = iATR(Symbol(), tf, 14, zone.breakoutBar);
   if (atr <= 0) return true;

   double minPenetration = atr * FR_MinPenetrationATR;
   int penetrations = 0;

   int lookback = FR_LookbackBars;
   int endBar = MathMax(0, startShift - lookback);

   for (int i = startShift - 1; i >= endBar; i--)
   {
      double h = iHigh(Symbol(), tf, i);
      double l = iLow(Symbol(), tf, i);
      double c = iClose(Symbol(), tf, i);

      if (zone.zoneType == "Bull")
      {
         // Price penetrating below the zone bottom = failed retest
         if (l < zone.bottom - minPenetration)
            penetrations++;
      }
      else
      {
         // Price penetrating above the zone top = failed retest
         if (h > zone.top + minPenetration)
            penetrations++;
      }
   }

   if (penetrations > FR_MaxPenetrations)
   {
      if (DebugMode) Print("FailedRetest reject: Too many penetrations (", penetrations, "). ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| WICK STRENGTH FILTER                                             |
//| Checks if too many wicks are piercing the zone.                  |
//| Many wicks = market is testing the zone and it's not holding.    |
//+------------------------------------------------------------------+
bool PassWickStrengthFilter(ZoneInfo &zone, int tf)
{
   if (!Use_WickStrengthFilter) return true;

   // During history scanning, skip this filter (old zones already have wick history)
   if (g_isScanningHistory) return true;

   int startShift = iBarShift(Symbol(), tf, zone.startTime, true);
   if (startShift < 1) startShift = zone.breakoutBar;
   if (startShift < 1) return true;

   double zoneHeight = zone.top - zone.bottom;
   if (zoneHeight <= 0) return false;

   double penetrationThreshold = zoneHeight * WS_WickPenetrationPct;
   int wickPenetrations = 0;

   int lookback = WS_LookbackBars;
   int endBar = MathMax(0, startShift - lookback);

   for (int i = startShift - 1; i >= endBar; i--)
   {
      double h = iHigh(Symbol(), tf, i);
      double l = iLow(Symbol(), tf, i);
      double o = iOpen(Symbol(), tf, i);
      double c = iClose(Symbol(), tf, i);

      if (zone.zoneType == "Bull")
      {
         // Wick going below zone bottom but body closing above = wick penetration
         if (l < zone.bottom && c > zone.bottom)
         {
            double wickDepth = zone.bottom - l;
            if (wickDepth >= penetrationThreshold)
               wickPenetrations++;
         }
      }
      else
      {
         // Wick going above zone top but body closing below = wick penetration
         if (h > zone.top && c < zone.top)
         {
            double wickDepth = h - zone.top;
            if (wickDepth >= penetrationThreshold)
               wickPenetrations++;
         }
      }
   }

   if (wickPenetrations > WS_MaxWickPenetrations)
   {
      if (DebugMode) Print("WickStrength reject: Too many wick penetrations (", wickPenetrations, "). ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| NEWS SPIKE FILTER                                                |
//| Detects news-driven volatility spikes that create fake zones.    |
//| News spikes = sudden huge ATR expansion that reverts quickly.    |
//| Zones created during or right after a spike are likely fake.     |
//+------------------------------------------------------------------+
bool PassNewsSpikeFilter(ZoneInfo &zone, int tf)
{
   if (!Use_NewsSpikeFilter) return true;

   int boBar = zone.breakoutBar;
   if (boBar < 0) return true;

   // Check if the breakout bar or recent bars show news spike characteristics
   if (NewsIsSpikePeriod(tf, boBar))
   {
      if (News_BlockAllDuringSpike)
      {
         if (DebugMode) Print("NewsSpike reject: Zone created during news spike. ", zone.zoneType, " TF=", TimeframeToString(tf));
         return false;
      }
   }

   return true;
}

bool NewsIsSpikePeriod(int tf, int shift)
{
   int atrPeriod = News_ATR_Period;
   if (atrPeriod < 5) atrPeriod = 5;

   // Calculate the "normal" ATR (using longer lookback for baseline)
   double normalATR = iATR(Symbol(), tf, 50, shift + News_SpikeLookbackBars);
   if (normalATR <= 0) normalATR = iATR(Symbol(), tf, atrPeriod, shift + 5);
   if (normalATR <= 0) return false;

   // Check recent bars for abnormal ATR expansion
   int lookback = News_SpikeLookbackBars;
   if (lookback < 2) lookback = 2;

   for (int i = shift; i >= MathMax(0, shift - lookback); i--)
   {
      double currentATR = iATR(Symbol(), tf, atrPeriod, i);
      if (currentATR <= 0) continue;

      // If current ATR is significantly higher than normal, it's a spike
      if (currentATR >= normalATR * News_SpikeATRMultiplier)
      {
         return true;
      }
   }

   // Also check if the breakout bar itself has an abnormally large range
   double boRange = iHigh(Symbol(), tf, shift) - iLow(Symbol(), tf, shift);
   if (boRange >= normalATR * News_SpikeATRMultiplier * 2)
   {
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| ADAPTIVE SESSION FILTER                                          |
//| Different trading sessions have different volatility.            |
//| Asia = low vol, needs stricter filters.                          |
//| London/NY = high vol, can use normal filters.                    |
//| Zones formed outside main sessions are more likely fake.         |
//+------------------------------------------------------------------+
int GetCurrentSession()
{
   int hour = TimeHour(TimeCurrent());
   int day = TimeDayOfWeek(TimeCurrent());

   // Weekend = no session
   if (day == 0 || day == 6) return 0;

   if (hour >= Asia_StartHour && hour < Asia_EndHour)    return 1; // Asia
   if (hour >= London_StartHour && hour < London_EndHour) return 2; // London
   if (hour >= NY_StartHour && hour < NY_EndHour)         return 3; // New York

   return 0; // Off-hours
}

double GetSessionMinBreakoutATR(int session)
{
   if (session == 1) return Asia_MinBreakoutATR;
   if (session == 2) return London_MinBreakoutATR;
   if (session == 3) return NY_MinBreakoutATR;
   // Off-hours = very strict
   return Asia_MinBreakoutATR * 1.5;
}

double GetSessionMinBodyRatio(int session)
{
   if (session == 1) return Asia_MinBodyRatio;
   if (session == 2) return London_MinBodyRatio;
   if (session == 3) return NY_MinBodyRatio;
   // Off-hours = very strict
   return 0.75;
}

double GetSessionMinDepartureATR(int session)
{
   if (session == 1) return Asia_MinDepartureATR;
   if (session == 2) return London_MinDepartureATR;
   if (session == 3) return NY_MinDepartureATR;
   // Off-hours = very strict
   return Asia_MinDepartureATR * 1.5;
}

bool PassAdaptiveSessionFilter(ZoneInfo &zone, int tf)
{
   if (!Use_AdaptiveSessionFilter) return true;

   int session = GetCurrentSession();

   // Block zones during off-hours entirely
   if (Session_BlockOffHours && session == 0)
   {
      if (DebugMode) Print("AdaptiveSession reject: Off-hours zone. ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   double atr = iATR(Symbol(), tf, 14, zone.breakoutBar);
   if (atr <= 0) return false;

   // 1. Breakout must meet session-specific minimum size
   double minBreakout = GetSessionMinBreakoutATR(session);
   double boRange = iHigh(Symbol(), tf, zone.breakoutBar) - iLow(Symbol(), tf, zone.breakoutBar);
   if (boRange < atr * minBreakout)
   {
      if (DebugMode) Print("AdaptiveSession reject: Breakout too small for session ", session, ". Range=", DoubleToString(boRange/atr, 2), " ATR < ", DoubleToString(minBreakout, 2), " ATR");
      return false;
   }

   // 2. Body ratio must meet session-specific minimum
   double minBody = GetSessionMinBodyRatio(session);
   double boBody = MathAbs(iClose(Symbol(), tf, zone.breakoutBar) - iOpen(Symbol(), tf, zone.breakoutBar));
   if (boRange > 0 && boBody / boRange < minBody)
   {
      if (DebugMode) Print("AdaptiveSession reject: Body ratio too low for session ", session, ". Ratio=", DoubleToString(boBody/boRange, 2), " < ", DoubleToString(minBody, 2));
      return false;
   }

   // 3. Departure must meet session-specific minimum
   double minDeparture = GetSessionMinDepartureATR(session);
   if (AntiFake_RequireCleanDeparture)
   {
      // Re-check departure with session-specific threshold
      int shift = zone.breakoutBar;
      int bars = iBars(Symbol(), tf);
      if (shift >= 1 && shift < bars)
      {
         double bestMove = 0.0;
         int n = AntiFake_DepartureBars;
         if (n < 2) n = 2;
         for (int i = shift; i >= 0 && i >= shift - n + 1; i--)
         {
            double h = iHigh(Symbol(), tf, i);
            double l = iLow(Symbol(), tf, i);
            if (zone.zoneType == "Bull")
               bestMove = MathMax(bestMove, h - zone.top);
            else
               bestMove = MathMax(bestMove, zone.bottom - l);
         }
         if (bestMove < atr * minDeparture)
         {
            if (DebugMode) Print("AdaptiveSession reject: Departure too weak for session ", session, ". Move=", DoubleToString(bestMove/atr, 2), " ATR < ", DoubleToString(minDeparture, 2), " ATR");
            return false;
         }
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| FIRST ZONE COOLDOWN FILTER                                       |
//| The FIRST zone after a quiet period is almost always fake.       |
//| Require extra confirmation for the first zone.                   |
//+------------------------------------------------------------------+
bool PassFirstZoneCooldown(ZoneInfo &zone, int tf)
{
   if (!Use_FirstZoneCooldown) return true;

   // Find how many bars since the last zone of same type on this TF
   int lastZoneBar = -1;

   if (zone.zoneType == "Bull")
   {
      for (int i = 0; i < totalBullZones; i++)
      {
         if (BullishZones[i].timeframe != tf) continue;
         int bar = iBarShift(Symbol(), tf, BullishZones[i].startTime, true);
         if (bar > lastZoneBar) lastZoneBar = bar;
      }
   }
   else
   {
      for (int i = 0; i < totalBearZones; i++)
      {
         if (BearishZones[i].timeframe != tf) continue;
         int bar = iBarShift(Symbol(), tf, BearishZones[i].startTime, true);
         if (bar > lastZoneBar) lastZoneBar = bar;
      }
   }

   // If no previous zone, this IS the first zone - apply strict filter
   bool isFirstZone = (lastZoneBar < 0);

   // Or if the last zone was a long time ago
   int barsSinceLast = 9999;
   if (lastZoneBar >= 0)
   {
      barsSinceLast = lastZoneBar - zone.breakoutBar;
   }

   if (isFirstZone || barsSinceLast > FZC_MinBarsSinceLastZone)
   {
      // This is a "first zone" scenario - require extra confirmation

      // 1. Zone must have higher strength
      if (zone.strength < FZC_MinFirstZoneStrength)
      {
         if (DebugMode) Print("FirstZoneCooldown reject: First zone strength too low. Str=", DoubleToString(zone.strength, 1), " < ", DoubleToString(FZC_MinFirstZoneStrength, 1));
         return false;
      }

      // 2. Require extra confirmation bars
      int extraBars = FZC_ExtraConfirmBars;
      if (extraBars < 1) extraBars = 1;
      int boBar = zone.breakoutBar;
      int confirmBars = 0;

      for (int i = boBar - 1; i >= MathMax(0, boBar - extraBars - 1); i--)
      {
         if (zone.zoneType == "Bull")
         {
            if (iClose(Symbol(), tf, i) > iOpen(Symbol(), tf, i))
               confirmBars++;
         }
         else
         {
            if (iClose(Symbol(), tf, i) < iOpen(Symbol(), tf, i))
               confirmBars++;
         }
      }

      if (confirmBars < extraBars)
      {
         if (DebugMode) Print("FirstZoneCooldown reject: Not enough confirm bars for first zone. Got=", confirmBars, " Need=", extraBars);
         return false;
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| ADAPTIVE ATR FILTER                                              |
//| Instead of fixed ATR multipliers, uses percentile-based          |
//| thresholds that adapt to recent market conditions.               |
//| Low volatility period = stricter filters.                        |
//| High volatility period = more lenient.                           |
//+------------------------------------------------------------------+
double GetATRPercentile(int tf, int shift, int lookback, double percentile)
{
   int bars = iBars(Symbol(), tf);
   if (lookback < 10) lookback = 10;
   if (shift + lookback >= bars) lookback = bars - shift - 1;
   if (lookback < 10) return 0;

   // Collect ATR values
   double atrValues[];
   ArrayResize(atrValues, lookback);
   int count = 0;

   for (int i = shift; i < shift + lookback; i++)
   {
      double a = iATR(Symbol(), tf, 14, i);
      if (a > 0)
      {
         atrValues[count] = a;
         count++;
      }
   }

   if (count < 5) return 0;

   // Sort ascending (simple bubble sort - small array)
   for (int i = 0; i < count - 1; i++)
   {
      for (int j = 0; j < count - i - 1; j++)
      {
         if (atrValues[j] > atrValues[j+1])
         {
            double temp = atrValues[j];
            atrValues[j] = atrValues[j+1];
            atrValues[j+1] = temp;
         }
      }
   }

   // Get percentile value
   int idx = (int)(count * percentile / 100.0);
   if (idx < 0) idx = 0;
   if (idx >= count) idx = count - 1;

   return atrValues[idx];
}

double GetVolatilityRegimeMultiplier(int tf, int shift)
{
   int lookback = AATR_PercentileLookback;
   if (lookback < 20) lookback = 20;

   double currentATR = iATR(Symbol(), tf, 14, shift);
   if (currentATR <= 0) return 1.0;

   double p25 = GetATRPercentile(tf, shift + 1, lookback, AATR_LowVolPercentile);
   double p75 = GetATRPercentile(tf, shift + 1, lookback, AATR_HighVolPercentile);

   if (p25 <= 0 || p75 <= 0) return 1.0;

   // Low volatility regime: current ATR is below 25th percentile
   if (currentATR < p25)
   {
      return AATR_LowVolMultiplier; // Stricter (higher = harder to pass)
   }

   // High volatility regime: current ATR is above 75th percentile
   if (currentATR > p75)
   {
      return AATR_HighVolMultiplier; // More lenient (lower = easier to pass)
   }

   // Normal regime
   return 1.0;
}

bool PassAdaptiveATRFilter(ZoneInfo &zone, int tf)
{
   if (!Use_AdaptiveATRFilter) return true;

   int shift = zone.breakoutBar;
   if (shift < 1) return true;

   double atr = iATR(Symbol(), tf, 14, shift);
   if (atr <= 0) return true;

   double volMult = GetVolatilityRegimeMultiplier(tf, shift);

   // Apply multiplier to breakout size check
   double boRange = iHigh(Symbol(), tf, shift) - iLow(Symbol(), tf, shift);
   double minBreakout = atr * SB_MinBreakoutATR * volMult;

   if (boRange < minBreakout)
   {
      if (DebugMode) Print("AdaptiveATR reject: Breakout too small for vol regime. Mult=", DoubleToString(volMult, 2), " Range=", DoubleToString(boRange/atr, 2), " ATR < ", DoubleToString(minBreakout/atr, 2), " ATR");
      return false;
   }

   // Apply multiplier to departure check
   if (AntiFake_RequireCleanDeparture)
   {
      double minDeparture = atr * AntiFake_MinDepartureATR * volMult;
      double bestMove = 0.0;
      int n = AntiFake_DepartureBars;
      if (n < 2) n = 2;
      for (int i = shift; i >= 0 && i >= shift - n + 1; i--)
      {
         double h = iHigh(Symbol(), tf, i);
         double l = iLow(Symbol(), tf, i);
         if (zone.zoneType == "Bull")
            bestMove = MathMax(bestMove, h - zone.top);
         else
            bestMove = MathMax(bestMove, zone.bottom - l);
      }
      if (bestMove < minDeparture)
      {
         if (DebugMode) Print("AdaptiveATR reject: Departure too weak for vol regime. Mult=", DoubleToString(volMult, 2), " Move=", DoubleToString(bestMove/atr, 2), " ATR");
         return false;
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| DAY OF WEEK FILTER                                               |
//| Monday and Friday have different characteristics.                |
//| Monday = gap risk, slow start. Friday = reduced liquidity PM.    |
//+------------------------------------------------------------------+
double GetDayOfWeekMultiplier()
{
   int day = TimeDayOfWeek(TimeCurrent());

   if (day == 1) return DOW_MondayMultiplier;    // Monday - stricter
   if (day == 5) return DOW_FridayMultiplier;    // Friday - stricter
   if (day == 2 || day == 3 || day == 4) return DOW_TueThuMultiplier; // Tue-Thu - more lenient

   return 1.5; // Weekend - very strict (shouldn't happen but safety)
}

bool PassDayOfWeekFilter(ZoneInfo &zone, int tf)
{
   if (!Use_DayOfWeekFilter) return true;

   double dowMult = GetDayOfWeekMultiplier();
   double atr = iATR(Symbol(), tf, 14, zone.breakoutBar);
   if (atr <= 0) return true;

   // Apply day-of-week multiplier to breakout size
   double boRange = iHigh(Symbol(), tf, zone.breakoutBar) - iLow(Symbol(), tf, zone.breakoutBar);
   double minBreakout = atr * SB_MinBreakoutATR * dowMult;

   if (boRange < minBreakout)
   {
      if (DebugMode) Print("DayOfWeek reject: Breakout too small for day. Mult=", DoubleToString(dowMult, 2), " Day=", TimeDayOfWeek(TimeCurrent()));
      return false;
   }

   // Block Friday after NY close (reduced liquidity)
   if (DOW_BlockFridayAfterNY)
   {
      int day = TimeDayOfWeek(TimeCurrent());
      int hour = TimeHour(TimeCurrent());
      if (day == 5 && hour >= DOW_FridayCutoffHour)
      {
         if (DebugMode) Print("DayOfWeek reject: Friday after cutoff. Hour=", hour);
         return false;
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| VOLATILITY REGIME FILTER                                         |
//| Detects if today is a low-vol or high-vol day.                   |
//| Low-vol day: zones need much stronger confirmation.              |
//| High-vol day: can be more lenient but watch for news spikes.     |
//+------------------------------------------------------------------+
bool PassVolatilityRegimeFilter(ZoneInfo &zone, int tf)
{
   if (!Use_VolatilityRegimeFilter) return true;

   int shift = zone.breakoutBar;
   if (shift < 1) return true;

   double atr = iATR(Symbol(), tf, 14, shift);
   if (atr <= 0) return true;

   // Calculate average ATR over lookback period
   int lookback = VR_RegimeLookback;
   if (lookback < 10) lookback = 10;
   double avgATR = 0;
   int cnt = 0;
   for (int i = shift + 1; i <= shift + lookback; i++)
   {
      double a = iATR(Symbol(), tf, 14, i);
      if (a > 0) { avgATR += a; cnt++; }
   }
   if (cnt < 5) return true;
   avgATR /= cnt;

   double ratio = atr / avgATR;

   // Low volatility regime
   if (ratio < VR_LowVolThreshold)
   {
      // In low vol: require much stronger breakout
      double boRange = iHigh(Symbol(), tf, shift) - iLow(Symbol(), tf, shift);
      if (boRange < atr * VR_LowVolMinBreakoutATR)
      {
         if (DebugMode) Print("VolRegime reject: Low vol day, weak breakout. ATR ratio=", DoubleToString(ratio, 2), " Range=", DoubleToString(boRange/atr, 2), " ATR");
         return false;
      }

      // Require stronger body
      double boBody = MathAbs(iClose(Symbol(), tf, shift) - iOpen(Symbol(), tf, shift));
      if (boRange > 0 && boBody / boRange < VR_LowVolMinBodyRatio)
      {
         if (DebugMode) Print("VolRegime reject: Low vol day, weak body. Body ratio=", DoubleToString(boBody/boRange, 2));
         return false;
      }
   }

   // High volatility regime - be more lenient on size but watch out
   if (ratio > VR_HighVolThreshold)
   {
      // In high vol: smaller breakouts are acceptable
      // BUT: check if it's a news spike (already handled by NewsSpikeFilter)
      // Just ensure minimum quality
      double boRange = iHigh(Symbol(), tf, shift) - iLow(Symbol(), tf, shift);
      if (boRange < atr * VR_HighVolMinBreakoutATR)
      {
         if (DebugMode) Print("VolRegime reject: High vol day but breakout still too small. Range=", DoubleToString(boRange/atr, 2), " ATR");
         return false;
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| FVG CONFIRMATION FILTER                                          |
//| THE #1 FILTER: A real zone ALWAYS creates a Fair Value Gap.      |
//| FVG = 3-candle gap where candle1 wick doesn't overlap candle3.   |
//| No FVG = no displacement = no institutional move = FAKE zone.    |
//+------------------------------------------------------------------+
bool HasFVGNearZone(ZoneInfo &zone, int tf)
{
   int boBar = zone.breakoutBar;
   if (boBar < 2) return false;

   int bars = iBars(Symbol(), tf);
   int lookback = FVG_LookbackBars;
   if (lookback < 3) lookback = 3;

   double atr = iATR(Symbol(), tf, 14, boBar);
   if (atr <= 0) return false;

   // Check bars from breakout going forward (bars with lower shift = more recent)
   for (int i = boBar; i >= MathMax(0, boBar - lookback); i--)
   {
      if (i + 2 >= bars) continue;

      double h1 = iHigh(Symbol(), tf, i + 2);  // First candle (oldest)
      double l1 = iLow(Symbol(), tf, i + 2);
      double h3 = iHigh(Symbol(), tf, i);       // Third candle (newest)
      double l3 = iLow(Symbol(), tf, i);

      if (zone.zoneType == "Bull")
      {
         // Bullish FVG: gap between candle1 HIGH and candle3 LOW
         // candle1 high < candle3 low = gap
         double gap = l3 - h1;
         if (gap > 0 && gap >= atr * FVG_MinGapATR)
         {
            return true;
         }
      }
      else
      {
         // Bearish FVG: gap between candle1 LOW and candle3 HIGH
         // candle1 low > candle3 high = gap
         double gap = l1 - h3;
         if (gap > 0 && gap >= atr * FVG_MinGapATR)
         {
            return true;
         }
      }
   }

   return false;
}

bool HasDisplacement(ZoneInfo &zone, int tf)
{
   int boBar = zone.breakoutBar;
   if (boBar < 1) return false;

   double atr = iATR(Symbol(), tf, 14, boBar);
   if (atr <= 0) return false;

   int dispBars = FVG_DisplacementBars;
   if (dispBars < 1) dispBars = 1;

   // Check for consecutive one-sided candles with strong bodies
   int consecutiveBars = 0;
   double totalBody = 0.0;

   for (int i = boBar; i >= MathMax(0, boBar - dispBars); i--)
   {
      double op = iOpen(Symbol(), tf, i);
      double cl = iClose(Symbol(), tf, i);
      double body = MathAbs(cl - op);
      double range = iHigh(Symbol(), tf, i) - iLow(Symbol(), tf, i);

      if (range <= 0) continue;

      bool isDirectional = false;
      if (zone.zoneType == "Bull")
         isDirectional = (cl > op && body >= range * 0.50);  // Strong bullish body
      else
         isDirectional = (cl < op && body >= range * 0.50);  // Strong bearish body

      if (isDirectional)
      {
         consecutiveBars++;
         totalBody += body;
      }
      else
      {
         break;  // Must be consecutive
      }
   }

   // Need at least 1 consecutive directional bar with total body >= DisplacementATR
   return (consecutiveBars >= 1 && totalBody >= atr * FVG_DisplacementATR);
}

bool PassFVGConfirmationFilter(ZoneInfo &zone, int tf)
{
   if (!Use_FVGConfirmationFilter) return true;

   // For brand new real-time zones, FVG may not have formed yet
   // Give it a pass if breakout just happened, but require displacement
   if (!g_isScanningHistory && zone.breakoutBar < 2)
   {
      if (FVG_RequireDisplacement && !HasDisplacement(zone, tf))
      {
         if (DebugMode) Print("FVG reject (realtime): No displacement for new zone. ", zone.zoneType, " TF=", TimeframeToString(tf));
         return false;
      }
      return true;  // Will be re-checked later
   }

   // 1. FVG must exist near the zone
   if (FVG_RequireFVG && !HasFVGNearZone(zone, tf))
   {
      if (DebugMode) Print("FVG reject: No Fair Value Gap near zone. ", zone.zoneType, " TF=", TimeframeToString(tf), " ID=", zone.uniqueID);
      return false;
   }

   // 2. Displacement must exist (strong one-sided move)
   if (FVG_RequireDisplacement && !HasDisplacement(zone, tf))
   {
      if (DebugMode) Print("FVG reject: No displacement near zone. ", zone.zoneType, " TF=", TimeframeToString(tf), " ID=", zone.uniqueID);
      return false;
   }

   return true;
}

int NormalizeBOSTimeframe(int tf)
{
   switch (tf)
   {
      case PERIOD_D1:  return PERIOD_D1;
      case PERIOD_H4:  return PERIOD_H4;
      case PERIOD_H1:  return PERIOD_H1;
      case PERIOD_M15: return PERIOD_M15;
      case PERIOD_M5:  return PERIOD_M5;
      case PERIOD_M1:  return PERIOD_M1;
   }
   return tf;
}

int GetBOSLookbackBarsForTF(int tf)
{
   switch (NormalizeBOSTimeframe(tf))
   {
      case PERIOD_D1:  return BOS_LookbackBars_D1;
      case PERIOD_H4:  return BOS_LookbackBars_H4;
      case PERIOD_H1:  return BOS_LookbackBars_H1;
      case PERIOD_M15: return BOS_LookbackBars_M15;
      case PERIOD_M5:  return BOS_LookbackBars_M5;
      case PERIOD_M1:  return BOS_LookbackBars_M1;
   }
   return BOS_LookbackBars;
}

double GetBOSMinBreakATRForTF(int tf)
{
   switch (NormalizeBOSTimeframe(tf))
   {
      case PERIOD_D1:  return BOS_MinBreakATR_D1;
      case PERIOD_H4:  return BOS_MinBreakATR_H4;
      case PERIOD_H1:  return BOS_MinBreakATR_H1;
      case PERIOD_M15: return BOS_MinBreakATR_M15;
      case PERIOD_M5:  return BOS_MinBreakATR_M5;
      case PERIOD_M1:  return BOS_MinBreakATR_M1;
   }
   return BOS_MinBreakATR;
}

int GetBOSSwingLookbackForTF(int tf)
{
   switch (NormalizeBOSTimeframe(tf))
   {
      case PERIOD_D1:  return BOS_SwingLookback_D1;
      case PERIOD_H4:  return BOS_SwingLookback_H4;
      case PERIOD_H1:  return BOS_SwingLookback_H1;
      case PERIOD_M15: return BOS_SwingLookback_M15;
      case PERIOD_M5:  return BOS_SwingLookback_M5;
      case PERIOD_M1:  return BOS_SwingLookback_M1;
   }
   return BOS_SwingLookback;
}

double GetBOSMaxStrengthBonusForTF(int tf)
{
   switch (NormalizeBOSTimeframe(tf))
   {
      case PERIOD_D1:  return BOS_MaxStrengthBonus_D1;
      case PERIOD_H4:  return BOS_MaxStrengthBonus_H4;
      case PERIOD_H1:  return BOS_MaxStrengthBonus_H1;
      case PERIOD_M15: return BOS_MaxStrengthBonus_M15;
      case PERIOD_M5:  return BOS_MaxStrengthBonus_M5;
      case PERIOD_M1:  return BOS_MaxStrengthBonus_M1;
   }
   return BOS_MaxStrengthBonus;
}

int GetMSSwingStrengthForTF(int tf)
{
   switch (NormalizeBOSTimeframe(tf))
   {
      case PERIOD_D1:  return MS_SwingStrength_D1;
      case PERIOD_H4:  return MS_SwingStrength_H4;
      case PERIOD_H1:  return MS_SwingStrength_H1;
      case PERIOD_M15: return MS_SwingStrength_M15;
      case PERIOD_M5:  return MS_SwingStrength_M5;
      case PERIOD_M1:  return MS_SwingStrength_M1;
   }
   return MS_SwingStrength;
}

int GetMSLookbackBarsForTF(int tf)
{
   switch (NormalizeBOSTimeframe(tf))
   {
      case PERIOD_D1:  return MS_LookbackBars_D1;
      case PERIOD_H4:  return MS_LookbackBars_H4;
      case PERIOD_H1:  return MS_LookbackBars_H1;
      case PERIOD_M15: return MS_LookbackBars_M15;
      case PERIOD_M5:  return MS_LookbackBars_M5;
      case PERIOD_M1:  return MS_LookbackBars_M1;
   }
   return MS_LookbackBars;
}

double GetMSBOSBufferATRForTF(int tf)
{
   switch (NormalizeBOSTimeframe(tf))
   {
      case PERIOD_D1:  return MS_BOSBufferATR_D1;
      case PERIOD_H4:  return MS_BOSBufferATR_H4;
      case PERIOD_H1:  return MS_BOSBufferATR_H1;
      case PERIOD_M15: return MS_BOSBufferATR_M15;
      case PERIOD_M5:  return MS_BOSBufferATR_M5;
      case PERIOD_M1:  return MS_BOSBufferATR_M1;
   }
   return MS_BOSBufferATR;
}

int GetDashMinBOSConfirmBarsForTF(int tf)
{
   switch (NormalizeBOSTimeframe(tf))
   {
      case PERIOD_D1:  return Dash_MinBOSConfirmBars_D1;
      case PERIOD_H4:  return Dash_MinBOSConfirmBars_H4;
      case PERIOD_H1:  return Dash_MinBOSConfirmBars_H1;
      case PERIOD_M15: return Dash_MinBOSConfirmBars_M15;
      case PERIOD_M5:  return Dash_MinBOSConfirmBars_M5;
      case PERIOD_M1:  return Dash_MinBOSConfirmBars_M1;
   }
   return Dash_MinBOSConfirmBars;
}

//+------------------------------------------------------------------+
//| BREAK OF STRUCTURE (BOS) QUALITY CONFIRMATION                    |
//+------------------------------------------------------------------+
double GetBOSStrengthScore(ZoneInfo &zone, int tf)
{
   int bars = iBars(Symbol(), tf);
   int boBar = zone.breakoutBar;
   if (zone.breakoutTime > 0)
      boBar = iBarShift(Symbol(), tf, zone.breakoutTime, true);
   if (boBar < 1 || boBar >= bars) return 0.0;

   double atr = iATR(Symbol(), tf, 14, boBar);
   if (atr <= 0) return 0.0;

   int confirmationBars = GetBOSLookbackBarsForTF(tf);
   if (confirmationBars < 1) confirmationBars = 1;
   if (confirmationBars > 10) confirmationBars = 10;
   int swingLB = GetBOSSwingLookbackForTF(tf);
   if (swingLB < 10) swingLB = 10;
   int strength = GetMSSwingStrengthForTF(tf);
   if (strength < 1) strength = 1;
   double minBreakATR = GetBOSMinBreakATRForTF(tf);

   int firstSwingBar = boBar + strength + 1;
   int lastSwingBar = MathMin(bars - strength - 1, boBar + swingLB);
   int lastConfirmationBar = MathMax(1, boBar - confirmationBars + 1);
   double bestBreakATR = 0.0;
   double bestBodyRatio = 0.0;

   if (zone.zoneType == "Bull")
   {
      double swingHigh = 0;
      for (int s = firstSwingBar; s <= lastSwingBar; s++)
      {
         if (IsStructureSwingHigh(tf, s, strength))
         {
            swingHigh = iHigh(Symbol(), tf, s);
            break;
         }
      }
      if (swingHigh <= 0) return 0.0;

      for (int i = boBar; i >= lastConfirmationBar; i--)
      {
         double closePrice = iClose(Symbol(), tf, i);
         double breakATR = (closePrice - swingHigh) / atr;
         if (breakATR < minBreakATR) continue;
         double range = iHigh(Symbol(), tf, i) - iLow(Symbol(), tf, i);
         double bodyRatio = (range > 0) ? MathAbs(closePrice - iOpen(Symbol(), tf, i)) / range : 0.0;
         if (breakATR > bestBreakATR)
         {
            bestBreakATR = breakATR;
            bestBodyRatio = bodyRatio;
         }
      }
   }
   else if (zone.zoneType == "Bear")
   {
      double swingLow = DBL_MAX;
      for (int s = firstSwingBar; s <= lastSwingBar; s++)
      {
         if (IsStructureSwingLow(tf, s, strength))
         {
            swingLow = iLow(Symbol(), tf, s);
            break;
         }
      }
      if (swingLow == DBL_MAX) return 0.0;

      for (int i = boBar; i >= lastConfirmationBar; i--)
      {
         double closePrice = iClose(Symbol(), tf, i);
         double breakATR = (swingLow - closePrice) / atr;
         if (breakATR < minBreakATR) continue;
         double range = iHigh(Symbol(), tf, i) - iLow(Symbol(), tf, i);
         double bodyRatio = (range > 0) ? MathAbs(closePrice - iOpen(Symbol(), tf, i)) / range : 0.0;
         if (breakATR > bestBreakATR)
         {
            bestBreakATR = breakATR;
            bestBodyRatio = bodyRatio;
         }
      }
   }

   if (bestBreakATR < minBreakATR) return 0.0;

   double maxBonus = MathMax(0.0, GetBOSMaxStrengthBonusForTF(tf));
   if (bestBreakATR >= 0.75 && bestBodyRatio >= 0.60) return maxBonus;
   if (bestBreakATR >= 0.35 && bestBodyRatio >= 0.50) return maxBonus * 0.67;
   return maxBonus * 0.33;
}

bool PassBOSConfirmationFilter(ZoneInfo &zone, int tf)
{
   if (!Use_BOSConfirmationFilter) return true;
   if (g_isScanningHistory) return true;

   int maxAppearanceBars = GetBOSLookbackBarsForTF(tf);
   if (maxAppearanceBars < 1) maxAppearanceBars = 1;
   if (maxAppearanceBars > 10) maxAppearanceBars = 10;
   int zoneAge = zone.breakoutBar;
   if (zone.breakoutTime > 0)
      zoneAge = iBarShift(Symbol(), tf, zone.breakoutTime, true);

   if (zoneAge < 0 || zoneAge > maxAppearanceBars)
   {
      if (DebugMode) Print("BOS reject: late zone blocked at age ", zoneAge,
                           " bars. ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   return true;
}

void UpdateZoneBOSConfirmation(ZoneInfo &zone)
{
   if (!Use_BOSConfirmationFilter || zone.bosConfirmed) return;
   if (zone.breakoutTime <= 0) return;

   int age = iBarShift(Symbol(), zone.timeframe, zone.breakoutTime, true);
   int confirmationBars = GetBOSLookbackBarsForTF(zone.timeframe);
   if (confirmationBars < 1) confirmationBars = 1;
   if (confirmationBars > 10) confirmationBars = 10;
   if (age < 1 || age > confirmationBars) return;

   double score = GetBOSStrengthScore(zone, zone.timeframe);
   if (score > 0.0)
   {
      zone.bosStrength = score;
      zone.bosConfirmed = true;
      zone.strength = MathMin(10.0, zone.strength + score);
      zone.isElite = (zone.strength >= 8.0);
      if (DebugMode) Print("BOS confirmed: ", zone.zoneType, " zone #", zone.uniqueID,
                           " bonus=", DoubleToString(score, 2));
   }
}

void UpdateBOSConfirmations()
{
   for (int i = 0; i < totalBullZones; i++)
      UpdateZoneBOSConfirmation(BullishZones[i]);
   for (int i = 0; i < totalBearZones; i++)
      UpdateZoneBOSConfirmation(BearishZones[i]);
}

//+------------------------------------------------------------------+
//| BODY CLEARANCE FILTER                                            |
//| The breakout candle BODY must clear the zone, not just the wick. |
//| Wick-only breakouts = fake zones (no real commitment).           |
//+------------------------------------------------------------------+
bool PassBodyClearanceFilter(ZoneInfo &zone, int tf)
{
   if (!Use_BodyClearanceFilter) return true;

   int boBar = zone.breakoutBar;
   if (boBar < 0) return true;

   double op = iOpen(Symbol(), tf, boBar);
   double cl = iClose(Symbol(), tf, boBar);
   double bodyTop = MathMax(op, cl);
   double bodyBot = MathMin(op, cl);

   double zoneHeight = zone.top - zone.bottom;
   if (zoneHeight <= 0) return false;

   if (zone.zoneType == "Bull")
   {
      // Bull zone: breakout body must clear the TOP of the zone
      // Body must be above zone.top by at least BC_MinClearancePct of zone height
      double clearance = bodyBot - zone.top;
      double minClearance = zoneHeight * BC_MinClearancePct;

      if (clearance < minClearance)
      {
         if (DebugMode) Print("BodyClearance reject: Bull body doesn't clear zone top. BodyBot=", DoubleToString(bodyBot, Digits), " ZoneTop=", DoubleToString(zone.top, Digits));
         return false;
      }
   }
   else
   {
      // Bear zone: breakout body must clear the BOTTOM of the zone
      // Body must be below zone.bottom by at least BC_MinClearancePct of zone height
      double clearance = zone.bottom - bodyTop;
      double minClearance = zoneHeight * BC_MinClearancePct;

      if (clearance < minClearance)
      {
         if (DebugMode) Print("BodyClearance reject: Bear body doesn't clear zone bottom. BodyTop=", DoubleToString(bodyTop, Digits), " ZoneBot=", DoubleToString(zone.bottom, Digits));
         return false;
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| MINIMUM HOLD TIME FILTER                                         |
//| A real zone must hold for N bars without being deeply penetrated.|
//| If price slices through the zone within a few bars = fake.       |
//+------------------------------------------------------------------+
bool PassMinHoldTimeFilter(ZoneInfo &zone, int tf)
{
   if (!Use_MinHoldTimeFilter) return true;

   // Only apply to real-time zones (during history scan, old zones have already "held")
   if (g_isScanningHistory) return true;

   int startShift = iBarShift(Symbol(), tf, zone.startTime, true);
   if (startShift < 1) return true;

   double zoneHeight = zone.top - zone.bottom;
   if (zoneHeight <= 0) return false;

   double maxWickDepth = zoneHeight * MHT_MaxWickPct;
   int holdBars = MHT_MinHoldBars;
   if (holdBars < 3) holdBars = 3;

   // Check the first N bars after zone creation
   int barsChecked = 0;
   for (int i = startShift - 1; i >= MathMax(0, startShift - holdBars); i--)
   {
      double h = iHigh(Symbol(), tf, i);
      double l = iLow(Symbol(), tf, i);
      double c = iClose(Symbol(), tf, i);

      if (zone.zoneType == "Bull")
      {
         // Bull zone: price should NOT close below zone bottom
         // And wicks shouldn't penetrate more than MHT_MaxWickPct
         if (c < zone.bottom)
         {
            if (DebugMode) Print("MinHoldTime reject: Bull zone closed below bottom within ", barsChecked, " bars. ID=", zone.uniqueID);
            return false;
         }
         double wickDepth = zone.bottom - l;
         if (wickDepth > maxWickDepth)
         {
            if (DebugMode) Print("MinHoldTime reject: Bull zone wick too deep within ", barsChecked, " bars. ID=", zone.uniqueID);
            return false;
         }
      }
      else
      {
         // Bear zone: price should NOT close above zone top
         if (c > zone.top)
         {
            if (DebugMode) Print("MinHoldTime reject: Bear zone closed above top within ", barsChecked, " bars. ID=", zone.uniqueID);
            return false;
         }
         double wickDepth = h - zone.top;
         if (wickDepth > maxWickDepth)
         {
            if (DebugMode) Print("MinHoldTime reject: Bear zone wick too deep within ", barsChecked, " bars. ID=", zone.uniqueID);
            return false;
         }
      }
      barsChecked++;
   }

   return true;
}

//+------------------------------------------------------------------+
//| CHOPPINESS INDEX FILTER                                          |
//| THE BEST consolidation detector. Created by E.W. Dreiss.         |
//| CI > 61.8 = consolidation/chop. CI < 38.2 = trending.            |
//| Formula: CI = 100 * LOG10(SumATR / (MaxHi - MinLo)) / LOG10(n)   |
//| Zones in choppy markets = FAKE. Zones need trending market.      |
//+------------------------------------------------------------------+
double GetChoppinessIndex(int tf, int shift)
{
   int period = CI_Period;
   if (period < 5) period = 5;

   int bars = iBars(Symbol(), tf);
   if (shift + period >= bars) return 50.0; // Default to neutral

   // Sum of ATR(1) over the period
   double sumATR = 0.0;
   for (int i = shift; i < shift + period; i++)
   {
      double tr = iHigh(Symbol(), tf, i) - iLow(Symbol(), tf, i);
      // True range considers gaps
      if (i + 1 < bars)
      {
         double prevClose = iClose(Symbol(), tf, i + 1);
         double h = iHigh(Symbol(), tf, i);
         double l = iLow(Symbol(), tf, i);
         tr = MathMax(tr, MathAbs(h - prevClose));
         tr = MathMax(tr, MathAbs(l - prevClose));
      }
      sumATR += tr;
   }

   // Highest high and lowest low over the period
   double maxHi = -DBL_MAX;
   double minLo = DBL_MAX;
   for (int i = shift; i < shift + period; i++)
   {
      double h = iHigh(Symbol(), tf, i);
      double l = iLow(Symbol(), tf, i);
      if (h > maxHi) maxHi = h;
      if (l < minLo) minLo = l;
   }

   double range = maxHi - minLo;
   if (range <= 0) return 50.0;

   // CI = 100 * LOG10(SumATR / Range) / LOG10(Period)
   double ratio = sumATR / range;
   if (ratio <= 0) return 50.0;

   double ci = 100.0 * MathLog10(ratio) / MathLog10((double)period);
   return ci;
}

bool PassChopIndexFilter(ZoneInfo &zone, int tf)
{
   if (!Use_ChopIndexFilter) return true;

   double ci = GetChoppinessIndex(tf, zone.breakoutBar);

   // Block zones in choppy market (CI above threshold)
   if (CI_BlockChopZones && ci > CI_ChopThreshold)
   {
      if (DebugMode) Print("ChopIndex reject: Market is choppy. CI=", DoubleToString(ci, 1), " > ", DoubleToString(CI_ChopThreshold, 1), " ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   // Require trend confirmation (CI below trend threshold)
   if (CI_RequireTrendConfirmation && ci > CI_TrendThreshold && ci <= CI_ChopThreshold)
   {
      // In the gray zone - not clearly trending, not clearly choppy
      // Require extra quality from the zone
      double atr = iATR(Symbol(), tf, 14, zone.breakoutBar);
      if (atr > 0)
      {
         double boRange = iHigh(Symbol(), tf, zone.breakoutBar) - iLow(Symbol(), tf, zone.breakoutBar);
         // In uncertain market, require 2x stronger breakout
         if (boRange < atr * 2.0)
         {
            if (DebugMode) Print("ChopIndex reject: Gray zone, weak breakout. CI=", DoubleToString(ci, 1), " Range=", DoubleToString(boRange/atr, 2), " ATR");
            return false;
         }
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| AUTOCORRELATION FILTER                                           |
//| Statistical trending/ranging detection.                          |
//| Positive autocorrelation = trending (returns persist).           |
//| Negative autocorrelation = ranging (returns reverse = chop).     |
//| This is the MOST statistically accurate regime detector.         |
//+------------------------------------------------------------------+
double GetAutocorrelation(int tf, int shift, int lookback, int lag)
{
   if (lookback < 10) lookback = 10;
   if (lag < 1) lag = 1;

   int bars = iBars(Symbol(), tf);
   if (shift + lookback + lag >= bars) return 0.0;

   // Collect returns
   double returns[];
   ArrayResize(returns, lookback);
   for (int i = 0; i < lookback; i++)
   {
      double c0 = iClose(Symbol(), tf, shift + i);
      double c1 = iClose(Symbol(), tf, shift + i + 1);
      if (c1 > 0)
         returns[i] = (c0 - c1) / c1;
      else
         returns[i] = 0;
   }

   // Calculate mean
   double mean = 0;
   for (int i = 0; i < lookback; i++) mean += returns[i];
   mean /= lookback;

   // Calculate variance and autocovariance
   double variance = 0;
   double autocovariance = 0;
   int n = lookback - lag;

   for (int i = 0; i < n; i++)
   {
      double dev = returns[i] - mean;
      double devLag = returns[i + lag] - mean;
      variance += dev * dev;
      autocovariance += dev * devLag;
   }

   if (variance <= 0) return 0.0;

   return autocovariance / variance;
}

bool PassAutocorrelationFilter(ZoneInfo &zone, int tf)
{
   if (!Use_AutocorrelationFilter) return true;

   double ac = GetAutocorrelation(tf, zone.breakoutBar + 1, AC_Lookback, AC_Lag);

   // Negative autocorrelation = mean-reverting/choppy = fake zones
   if (AC_BlockNegativeAC && ac < AC_ChopThreshold)
   {
      if (DebugMode) Print("Autocorrelation reject: Negative AC = choppy. AC=", DoubleToString(ac, 3), " ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   // Low positive autocorrelation = weak trend, require stronger zone
   if (ac < AC_TrendThreshold && ac >= AC_ChopThreshold)
   {
      double atr = iATR(Symbol(), tf, 14, zone.breakoutBar);
      if (atr > 0)
      {
         double boRange = iHigh(Symbol(), tf, zone.breakoutBar) - iLow(Symbol(), tf, zone.breakoutBar);
         if (boRange < atr * 1.8)
         {
            if (DebugMode) Print("Autocorrelation reject: Weak trend AC, weak breakout. AC=", DoubleToString(ac, 3), " Range=", DoubleToString(boRange/atr, 2), " ATR");
            return false;
         }
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| KAUFMAN EFFICIENCY RATIO FILTER                                  |
//| Measures signal-to-noise ratio of price movement.                |
//| ER near 1.0 = clean trend. ER near 0.0 = chop/noise.             |
//| ER = |Direction| / Volatility                                    |
//+------------------------------------------------------------------+
double GetEfficiencyRatio(int tf, int shift)
{
   int period = ER_Period;
   if (period < 5) period = 5;

   int bars = iBars(Symbol(), tf);
   if (shift + period >= bars) return 0.5;

   // Direction: absolute change from start to end
   double startClose = iClose(Symbol(), tf, shift + period - 1);
   double endClose = iClose(Symbol(), tf, shift);
   double direction = MathAbs(endClose - startClose);

   // Volatility: sum of absolute bar-to-bar changes
   double volatility = 0;
   for (int i = shift; i < shift + period - 1; i++)
   {
      double c0 = iClose(Symbol(), tf, i);
      double c1 = iClose(Symbol(), tf, i + 1);
      volatility += MathAbs(c0 - c1);
   }

   if (volatility <= 0) return 0.0;

   return direction / volatility;
}

bool PassEfficiencyRatioFilter(ZoneInfo &zone, int tf)
{
   if (!Use_EfficiencyRatioFilter) return true;

   double er = GetEfficiencyRatio(tf, zone.breakoutBar + 1);

   // Low efficiency = choppy market = fake zones
   if (ER_BlockLowEfficiency && er < ER_ChopRatio)
   {
      if (DebugMode) Print("EfficiencyRatio reject: Low efficiency = chop. ER=", DoubleToString(er, 3), " < ", DoubleToString(ER_ChopRatio, 3), " ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   // Medium efficiency = require stronger breakout
   if (er < ER_MinTrendRatio && er >= ER_ChopRatio)
   {
      double atr = iATR(Symbol(), tf, 14, zone.breakoutBar);
      if (atr > 0)
      {
         double boRange = iHigh(Symbol(), tf, zone.breakoutBar) - iLow(Symbol(), tf, zone.breakoutBar);
         if (boRange < atr * 1.5)
         {
            if (DebugMode) Print("EfficiencyRatio reject: Medium ER, weak breakout. ER=", DoubleToString(er, 3), " Range=", DoubleToString(boRange/atr, 2), " ATR");
            return false;
         }
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| RSI MID-RANGE TRAP FILTER                                        |
//| When RSI is trapped in the 40-60 zone for multiple bars,         |
//| the market is in consolidation. Zones here are fake.             |
//+------------------------------------------------------------------+
bool IsRSITrapped(int tf, int shift)
{
   int period = RSI_MR_Period;
   if (period < 5) period = 5;

   int consecutiveBars = RSI_MR_ConsecutiveBars;
   if (consecutiveBars < 2) consecutiveBars = 2;

   int bars = iBars(Symbol(), tf);
   int trappedCount = 0;

   for (int i = shift; i < shift + consecutiveBars && i < bars; i++)
   {
      double rsi = iRSI(Symbol(), tf, period, PRICE_CLOSE, i);
      if (rsi >= RSI_MR_LowBound && rsi <= RSI_MR_HighBound)
         trappedCount++;
      else
         break;  // Must be consecutive
   }

   return (trappedCount >= consecutiveBars);
}

bool PassRSIMidRangeFilter(ZoneInfo &zone, int tf)
{
   if (!Use_RSIMidRangeFilter) return true;

   // Check if RSI was trapped in mid-range at zone creation
   if (RSI_MR_BlockTrapped && IsRSITrapped(tf, zone.breakoutBar + 1))
   {
      if (DebugMode) Print("RSIMidRange reject: RSI trapped in mid-range = consolidation. ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| PRICE LOCATION FILTER                                            |
//| If price is near the midpoint of recent range = consolidation.   |
//| Real zones form near the extremes of the range, not the middle.  |
//+------------------------------------------------------------------+
bool IsPriceInMidRange(int tf, int shift)
{
   int lookback = PL_RangeLookback;
   if (lookback < 10) lookback = 10;

   int bars = iBars(Symbol(), tf);
   if (shift + lookback >= bars) return false;

   double hi = -DBL_MAX;
   double lo = DBL_MAX;
   for (int i = shift; i < shift + lookback; i++)
   {
      double h = iHigh(Symbol(), tf, i);
      double l = iLow(Symbol(), tf, i);
      if (h > hi) hi = h;
      if (l < lo) lo = l;
   }

   double range = hi - lo;
   if (range <= 0) return false;

   double mid = (hi + lo) * 0.5;
   double currentPrice = iClose(Symbol(), tf, shift);

   // How close is price to the midpoint? (as percentage of range)
   double distFromMid = MathAbs(currentPrice - mid) / range;

   // If price is within PL_MidZonePct of the midpoint = in mid-range
   return (distFromMid < PL_MidZonePct);
}

bool PassPriceLocationFilter(ZoneInfo &zone, int tf)
{
   if (!Use_PriceLocationFilter) return true;

   // Check if price at zone creation was in mid-range = consolidation
   if (PL_BlockMidRange && IsPriceInMidRange(tf, zone.breakoutBar))
   {
      if (DebugMode) Print("PriceLocation reject: Price in mid-range = consolidation. ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   // Also check if the zone itself is in the middle of the range
   double atr = iATR(Symbol(), tf, 14, zone.breakoutBar);
   if (atr <= 0) return true;

   int lookback = PL_RangeLookback;
   if (lookback < 10) lookback = 10;
   int bars = iBars(Symbol(), tf);
   if (zone.breakoutBar + lookback >= bars) return true;

   double hi = -DBL_MAX;
   double lo = DBL_MAX;
   for (int i = zone.breakoutBar; i < zone.breakoutBar + lookback && i < bars; i++)
   {
      double h = iHigh(Symbol(), tf, i);
      double l = iLow(Symbol(), tf, i);
      if (h > hi) hi = h;
      if (l < lo) lo = l;
   }

   double range = hi - lo;
   if (range <= 0) return true;

   double mid = (hi + lo) * 0.5;
   double zoneMid = (zone.top + zone.bottom) * 0.5;
   double distFromMid = MathAbs(zoneMid - mid) / range;

   // Zone in the middle of the range = consolidation zone = fake
   if (distFromMid < PL_MidZonePct)
   {
      if (DebugMode) Print("PriceLocation reject: Zone in mid-range = consolidation. Dist=", DoubleToString(distFromMid, 3), " < ", DoubleToString(PL_MidZonePct, 3), " ", zone.zoneType, " TF=", TimeframeToString(tf));
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Trend Exhaustion Filter                                          |
//| Rejects a zone that forms at the extreme of the recent move:     |
//|  - SELL zone whose bottom is within Exh_MinRoomATR*ATR of the     |
//|    recent low  -> down move is exhausted, no room, likely reversal |
//|  - BUY zone whose top is within Exh_MinRoomATR*ATR of the recent  |
//|    high -> up move is exhausted, no room, likely reversal          |
//+------------------------------------------------------------------+
bool PassExhaustionFilter(ZoneInfo &zone, int tf)
{
   if (!Use_ExhaustionFilter) return true;

   double atr = iATR(Symbol(), tf, 14, zone.breakoutBar);
   if (atr <= 0) return true;

   int lookback = Exh_Lookback;
   if (lookback < 10) lookback = 10;

   int bars = iBars(Symbol(), tf);
   if (zone.breakoutBar + lookback >= bars) return true;

   double hi = -DBL_MAX;
   double lo = DBL_MAX;
   for (int i = zone.breakoutBar; i < zone.breakoutBar + lookback && i < bars; i++)
   {
      double h = iHigh(Symbol(), tf, i);
      double l = iLow(Symbol(), tf, i);
      if (h > hi) hi = h;
      if (l < lo) lo = l;
   }
   if (hi <= lo) return true;

   double minRoom = atr * Exh_MinRoomATR;
   bool bullish = (zone.zoneType == "Bull");

   if (bullish)
   {
      // BUY zone at the top of the move = no upside room left
      double room = hi - zone.top;
      if (room < minRoom)
      {
         if (DebugMode) Print("Exhaustion reject: BUY zone at top, room=", DoubleToString(room, Digits),
                              " < ", DoubleToString(minRoom, Digits), " TF=", TimeframeToString(tf));
         return false;
      }
   }
   else
   {
      // SELL zone at the bottom of the move = no downside room left
      double room = zone.bottom - lo;
      if (room < minRoom)
      {
         if (DebugMode) Print("Exhaustion reject: SELL zone at bottom, room=", DoubleToString(room, Digits),
                              " < ", DoubleToString(minRoom, Digits), " TF=", TimeframeToString(tf));
         return false;
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| Market Regime Filter                                             |
//+------------------------------------------------------------------+
bool PassZoneRegimeFilter(int zoneTF)
{
   if (!Use_RegimeFilter) return true;
   if (g_isScanningHistory && Regime_ApplyToNewZonesOnly) return true;
   int chartTF = Period();
   if (zoneTF != chartTF)
   {
      return false;
   }
   
   if (Regime_FilterSpread)
   {
      double spreadPrice = MarketInfo(Symbol(), MODE_SPREAD) * Point;
      if (spreadPrice > Regime_MaxSpreadPrice)
      {
         if (DebugMode) Print("Regime reject (Spread) TF=", TimeframeToString(zoneTF), " spread=", DoubleToString(spreadPrice, Digits), " > ", DoubleToString(Regime_MaxSpreadPrice, Digits));
         return false;
      }
   }
   
   int adxTF = Regime_ADX_TF;
   if (adxTF <= 0) adxTF = zoneTF;
   int adxPeriod = Regime_ADX_Period;
   if (adxPeriod < 3) adxPeriod = 3;
   double adx = iADX(Symbol(), adxTF, adxPeriod, PRICE_CLOSE, MODE_MAIN, 1);
   if (Regime_RequireValidADX && (adx == EMPTY_VALUE || adx <= 0))
   {
      if (DebugMode) Print("Regime reject (ADX invalid) TF=", TimeframeToString(zoneTF), " ADX_TF=", TimeframeToString(adxTF));
      return false;
   }
   if (adx != EMPTY_VALUE && adx > 0 && adx < Regime_MinADX)
   {
      if (DebugMode) Print("Regime reject (ADX) TF=", TimeframeToString(zoneTF), " adx=", DoubleToString(adx, 1), " < ", DoubleToString(Regime_MinADX, 1));
      return false;
   }
   
   if (Regime_FilterATR)
   {
      int atrTF = Regime_ATR_TF;
      if (atrTF <= 0) atrTF = zoneTF;
      int atrPeriod = Regime_ATR_Period;
      if (atrPeriod < 2) atrPeriod = 2;
      int lb = Regime_ATR_Lookback;
      if (lb < 5) lb = 5;
      double atrNow = iATR(Symbol(), atrTF, atrPeriod, 1);
      if (atrNow <= 0)
      {
         if (DebugMode) Print("Regime reject (ATR now invalid) TF=", TimeframeToString(zoneTF), " ATR_TF=", TimeframeToString(atrTF));
         return false;
      }
      double atrSum = 0.0;
      int cnt = 0;
      for (int i = 1; i <= lb; i++)
      {
         double a = iATR(Symbol(), atrTF, atrPeriod, i);
         if (a <= 0) continue;
         atrSum += a;
         cnt++;
      }
      if (cnt < 3)
      {
         if (DebugMode) Print("Regime reject (ATR avg invalid) TF=", TimeframeToString(zoneTF), " ATR_TF=", TimeframeToString(atrTF));
         return false;
      }
      double atrAvg = atrSum / cnt;
      if (atrAvg <= 0) return false;
      if (atrNow < atrAvg * Regime_ATR_MinRatio)
      {
         if (DebugMode) Print("Regime reject (ATR ratio) TF=", TimeframeToString(zoneTF), " now=", DoubleToString(atrNow, Digits), " avg=", DoubleToString(atrAvg, Digits), " ratio=", DoubleToString(Regime_ATR_MinRatio, 2));
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| LIQUIDITY SWEEP SCORING                                           |
//| Returns a score 0.0 - 3.0 based on how well the zone shows a     |
//| genuine liquidity sweep.                                          |
//| In StrictMode: score 0 = hard reject.                            |
//| Scoring breakdown:                                                |
//|  +1.5  sweep detected (broke swing level by min points)          |
//|  +0.5  sweep candle body strong                                   |
//|  +0.5  reversal candle body strong                                |
//|  +0.3  close-back past swept level                                |
//|  +0.2  opposite-direction reversal candle                         |
//|  +0.5  volume spike on sweep candle                               |
//+------------------------------------------------------------------+
double GetLiquiditySweepScore(ZoneInfo &zone, int tf)
{
   if (!Use_LiquiditySweepFilter) return 0.0;
   
   int boBar = zone.breakoutBar;
   if (zone.breakoutTime > 0) boBar = iBarShift(Symbol(), tf, zone.breakoutTime, true);
   if (boBar < 1) return 0.0;
   
   int bars = iBars(Symbol(), tf);
   int lb = Sweep_Lookback;
   if (lb < 10) lb = 10;
   if (boBar + lb >= bars) lb = bars - boBar - 1;
   if (lb < 10) return 0.0;
   
   double atr = iATR(Symbol(), tf, 14, boBar);
   if (atr <= 0) return 0.0;
   
   bool isBull = (zone.zoneType == "Bull");
   double score = 0.0;
   
   // --- 1. Detect liquidity sweep (price broke a key swing level) ---
   double sweptLevel = 0.0;
   bool sweepFound = false;
   double bestBreakPoints = 0.0;
   
   if (isBull)
   {
      for (int s = boBar + 2; s < boBar + lb && s < bars - 1; s++)
      {
         double low_s = iLow(Symbol(), tf, s);
         bool isSwingLow = true;
         for (int j = s - 1; j <= s + 1; j++)
         {
            if (j < 0 || j >= bars) { isSwingLow = false; break; }
            if (j != s && iLow(Symbol(), tf, j) < low_s)
            { isSwingLow = false; break; }
         }
         if (isSwingLow)
         {
            double boLow = iLow(Symbol(), tf, boBar);
            if (boLow < low_s)
            {
               double breakPts = (low_s - boLow) / Point;
               if (breakPts >= Sweep_MinBreakPoints && breakPts > bestBreakPoints)
               {
                  sweptLevel = low_s;
                  sweepFound = true;
                  bestBreakPoints = breakPts;
               }
            }
         }
      }
   }
   else
   {
      for (int s = boBar + 2; s < boBar + lb && s < bars - 1; s++)
      {
         double high_s = iHigh(Symbol(), tf, s);
         bool isSwingHigh = true;
         for (int j = s - 1; j <= s + 1; j++)
         {
            if (j < 0 || j >= bars) { isSwingHigh = false; break; }
            if (j != s && iHigh(Symbol(), tf, j) > high_s)
            { isSwingHigh = false; break; }
         }
         if (isSwingHigh)
         {
            double boHigh = iHigh(Symbol(), tf, boBar);
            if (boHigh > high_s)
            {
               double breakPts = (boHigh - high_s) / Point;
               if (breakPts >= Sweep_MinBreakPoints && breakPts > bestBreakPoints)
               {
                  sweptLevel = high_s;
                  sweepFound = true;
                  bestBreakPoints = breakPts;
               }
            }
         }
      }
   }
   
   if (!sweepFound)
   {
      if (Sweep_StrictMode)
      {
         if (DebugMode) Print("LiquiditySweep STRICT reject: No sweep. Zone ID: ", zone.uniqueID);
         return -100.0; // Signal hard reject
      }
      return 0.0;
   }
   
   score += 1.5; // Base score for sweep detected
   
   // --- 2. Sweep candle body strength ---
   double boOpen = iOpen(Symbol(), tf, boBar);
   double boClose = iClose(Symbol(), tf, boBar);
   double boBody = MathAbs(boClose - boOpen);
   if (Sweep_MinSweepBodyATR > 0 && boBody >= atr * Sweep_MinSweepBodyATR)
   {
      score += 0.5;
   }
   
   // --- 3. Reversal candle body strength ---
   int revBar = boBar - 1;
   if (revBar >= 0)
   {
      double revOpen = iOpen(Symbol(), tf, revBar);
      double revClose = iClose(Symbol(), tf, revBar);
      double revBody = MathAbs(revClose - revOpen);
      if (Sweep_MinBreakoutBodyATR > 0 && revBody >= atr * Sweep_MinBreakoutBodyATR)
      {
         score += 0.5;
      }
      
      // --- 4. Close-back past swept level ---
      if (Sweep_RequireCloseBack)
      {
         if (isBull && revClose >= sweptLevel + atr * Sweep_CloseBackATR)
            score += 0.3;
         else if (!isBull && revClose <= sweptLevel - atr * Sweep_CloseBackATR)
            score += 0.3;
      }
      else
      {
         // Even if not required, give bonus if it happens
         if (isBull && revClose >= sweptLevel)
            score += 0.3;
         else if (!isBull && revClose <= sweptLevel)
            score += 0.3;
      }
      
      // --- 5. Opposite-direction reversal candle ---
      if (isBull && revClose > revOpen)
         score += 0.2;
      else if (!isBull && revClose < revOpen)
         score += 0.2;
   }
   
   // --- 6. Volume spike on sweep candle ---
   if (Sweep_MinVolumeRatio > 0)
   {
      double sweepVol = (double)iVolume(Symbol(), tf, boBar);
      double avgVol = 0;
      int volCount = 0;
      int volLB = Sweep_VolumeLookback;
      if (volLB < 5) volLB = 5;
      for (int v = boBar + 1; v <= boBar + volLB && v < bars; v++)
      {
         avgVol += (double)iVolume(Symbol(), tf, v);
         volCount++;
      }
      if (volCount > 0) avgVol /= volCount;
      if (avgVol > 0 && sweepVol >= avgVol * Sweep_MinVolumeRatio)
         score += 0.5;
   }
   
   if (DebugMode) Print("LiquiditySweep score: ", DoubleToString(score, 2), " Zone ID: ", zone.uniqueID);
   return score;
}

//+------------------------------------------------------------------+
//| RELATIVE VOLUME SCORING                                           |
//| Returns a score 0.0 - 2.5 based on breakout volume quality.      |
//| In StrictMode: score 0 = hard reject.                            |
//| Scoring breakdown:                                                |
//|  +0.5  volume >= 1.0x average                                     |
//|  +0.5  volume >= 1.5x average                                     |
//|  +0.5  volume >= 2.0x average                                     |
//|  +0.5  volume >= 3.0x average                                     |
//|  +0.5  volume >= 4.0x average                                     |
//+------------------------------------------------------------------+
double GetRVScore(ZoneInfo &zone, int tf)
{
   if (!Use_RVFilter) return 0.0;
   
   int boBar = zone.breakoutBar;
   if (zone.breakoutTime > 0) boBar = iBarShift(Symbol(), tf, zone.breakoutTime, true);
   if (boBar < 0) return 0.0;
   
   int bars = iBars(Symbol(), tf);
   int lb = RV_LookbackBars;
   if (lb < 10) lb = 10;
   
   double currentVol = (double)iVolume(Symbol(), tf, boBar);
   double avgVol = 0;
   int cnt = 0;
   
   for (int v = boBar + 1; v <= boBar + lb && v < bars; v++)
   {
      avgVol += (double)iVolume(Symbol(), tf, v);
      cnt++;
   }
   
   if (cnt < 5) return 0.0;
   avgVol /= cnt;
   
   if (avgVol <= 0) return 0.0;
   
   double ratio = currentVol / avgVol;
   zone.relativeVolume = ratio;
   
   double score = 0.0;
   if (ratio >= 1.0) score += 0.5;
   if (ratio >= 1.5) score += 0.5;
   if (ratio >= 2.0) score += 0.5;
   if (ratio >= 3.0) score += 0.5;
   if (ratio >= 4.0) score += 0.5;
   
   // StrictMode: reject if below minimum ratio
   if (RV_StrictMode && ratio < RV_MinRatio)
   {
      if (DebugMode) Print("RV STRICT reject: Ratio=", DoubleToString(ratio, 2), " < ", DoubleToString(RV_MinRatio, 2), " Zone ID: ", zone.uniqueID);
      return -100.0;
   }
   
   if (DebugMode) Print("RV score: ", DoubleToString(score, 2), " Ratio=", DoubleToString(ratio, 2), " Zone ID: ", zone.uniqueID);
   return score;
}

//+------------------------------------------------------------------+
//| DELTA / CVD TICK-VOLUME QUALITY                                  |
//+------------------------------------------------------------------+
double GetEstimatedTickDelta(int tf, int shift)
{
   int bars = iBars(Symbol(), tf);
   if (shift < 0 || shift >= bars) return 0.0;

   double highPrice = iHigh(Symbol(), tf, shift);
   double lowPrice = iLow(Symbol(), tf, shift);
   double range = highPrice - lowPrice;
   if (range <= 0.0) return 0.0;

   double openPrice = iOpen(Symbol(), tf, shift);
   double closePrice = iClose(Symbol(), tf, shift);
   double bodyPressure = (closePrice - openPrice) / range;
   double closeLocation = ((closePrice - lowPrice) - (highPrice - closePrice)) / range;
   double pressure = (bodyPressure * 0.60) + (closeLocation * 0.40);
   pressure = MathMax(-1.0, MathMin(1.0, pressure));

   return (double)iVolume(Symbol(), tf, shift) * pressure;
}

double GetDeltaCVDSignal(ZoneInfo &zone, int tf)
{
   if (!Use_DeltaCVDScore) return 0.0;

   int bars = iBars(Symbol(), tf);
   int boBar = zone.breakoutBar;
   if (zone.breakoutTime > 0)
      boBar = iBarShift(Symbol(), tf, zone.breakoutTime, true);
   if (boBar < 0 || boBar >= bars) return 0.0;

   int lookback = DCVD_LookbackBars;
   if (lookback < 5) lookback = 5;
   if (lookback > 100) lookback = 100;

   int recentBars = DCVD_RecentBars;
   if (recentBars < 1) recentBars = 1;
   if (recentBars > lookback) recentBars = lookback;

   double totalDelta = 0.0;
   double totalVolume = 0.0;
   double recentDelta = 0.0;
   double recentVolume = 0.0;
   int count = 0;

   for (int i = 0; i < lookback; i++)
   {
      int shift = boBar + i;
      if (shift >= bars) break;

      double volume = (double)iVolume(Symbol(), tf, shift);
      double delta = GetEstimatedTickDelta(tf, shift);
      totalDelta += delta;
      totalVolume += volume;
      count++;

      if (i < recentBars)
      {
         recentDelta += delta;
         recentVolume += volume;
      }
   }

   if (count < 5 || totalVolume <= 0.0 || recentVolume <= 0.0) return 0.0;

   double broadRatio = totalDelta / totalVolume;
   double recentRatio = recentDelta / recentVolume;
   double signal = (broadRatio * 0.35) + (recentRatio * 0.65);
   if (zone.zoneType == "Bear") signal = -signal;

   return MathMax(-1.0, MathMin(1.0, signal));
}

double GetDeltaCVDScore(ZoneInfo &zone, int tf)
{
   if (!Use_DeltaCVDScore) return 0.0;

   double signal = GetDeltaCVDSignal(zone, tf);
   double confirmRatio = MathMax(0.01, DCVD_ConfirmRatio);
   double strongRatio = MathMax(confirmRatio + 0.01, DCVD_StrongRatio);
   double maxBonus = MathMax(0.0, DCVD_MaxStrengthBonus);
   double maxPenalty = MathMax(0.0, DCVD_MaxStrengthPenalty);

   if (signal >= strongRatio) return maxBonus;
   if (signal >= confirmRatio) return maxBonus * 0.50;
   if (signal <= -strongRatio) return -maxPenalty;
   if (signal <= -confirmRatio) return -maxPenalty * 0.50;
   return 0.0;
}

//+------------------------------------------------------------------+
//| VOLUME DIVERGENCE                                                 |
//| Two independent checks on the impulse that produced the zone:     |
//|  1) price prints a new extreme while the impulse volume is        |
//|     clearly smaller than the volume of the previous extreme       |
//|  2) climax/exhaustion: volume spike with a tiny body              |
//| Returns 0.0 (clean), 1.0 (one check fired) or 2.0 (both).         |
//+------------------------------------------------------------------+
double GetVolumeDivergenceScore(ZoneInfo &zone, int tf)
{
   if (!Use_VolumeDivergenceFilter) return 0.0;

   int bars = iBars(Symbol(), tf);
   int boBar = zone.breakoutBar;
   if (zone.breakoutTime > 0) boBar = iBarShift(Symbol(), tf, zone.breakoutTime, true);
   if (boBar < 0 || boBar >= bars) return 0.0;

   int impBars = VD_ImpulseBars;
   if (impBars < 1)  impBars = 1;
   if (impBars > 20) impBars = 20;

   int lookback = VD_SwingLookback;
   if (lookback < 20) lookback = 20;
   if (boBar + lookback + impBars + 2 >= bars) lookback = bars - boBar - impBars - 3;
   if (lookback < 20) return 0.0;

   bool bull = (zone.zoneType == "Bull");
   double score = 0.0;

   // --- impulse leg that created the zone ---
   double curVol = 0.0;
   double curExtreme = bull ? -DBL_MAX : DBL_MAX;
   for (int i = 0; i < impBars; i++)
   {
      int s = boBar + i;
      if (s >= bars) return 0.0;
      curVol += (double)iVolume(Symbol(), tf, s);
      double h = iHigh(Symbol(), tf, s);
      double l = iLow(Symbol(), tf, s);
      if (bull  && h > curExtreme) curExtreme = h;
      if (!bull && l < curExtreme) curExtreme = l;
   }

   // --- 1) price / volume divergence against the previous extreme ---
   if (VD_CheckPriceVolumeDivergence && curVol > 0.0)
   {
      int prevIdx = -1;
      double prevExtreme = bull ? -DBL_MAX : DBL_MAX;
      for (int s = boBar + impBars; s <= boBar + lookback && s + impBars < bars; s++)
      {
         double h = iHigh(Symbol(), tf, s);
         double l = iLow(Symbol(), tf, s);
         if (bull && h > prevExtreme)  { prevExtreme = h; prevIdx = s; }
         if (!bull && l < prevExtreme) { prevExtreme = l; prevIdx = s; }
      }

      if (prevIdx > 0)
      {
         double prevVol = 0.0;
         for (int i = 0; i < impBars; i++)
            prevVol += (double)iVolume(Symbol(), tf, prevIdx + i);

         bool newExtreme = bull ? (curExtreme > prevExtreme + Point)
                                : (curExtreme < prevExtreme - Point);
         double maxAllowed = prevVol * (1.0 - MathMax(0.0, MathMin(0.95, VD_MinDropPct)));

         if (newExtreme && prevVol > 0.0 && curVol < maxAllowed)
         {
            score += 1.0;
            if (DebugMode)
               Print("VolDivergence: new ", (bull ? "high" : "low"),
                     " on weaker volume. cur=", DoubleToString(curVol, 0),
                     " prev=", DoubleToString(prevVol, 0),
                     " TF=", TimeframeToString(tf), " Zone ", zone.uniqueID);
         }
      }
   }

   // --- 2) climax / exhaustion bar ---
   if (VD_CheckClimaxExhaustion)
   {
      double avgVol = 0.0;
      int cnt = 0;
      for (int s = boBar + 1; s <= boBar + lookback && s < bars; s++)
      {
         avgVol += (double)iVolume(Symbol(), tf, s);
         cnt++;
      }
      if (cnt >= 10 && avgVol > 0.0)
      {
         avgVol /= cnt;
         double boVol = (double)iVolume(Symbol(), tf, boBar);
         double hi = iHigh(Symbol(), tf, boBar);
         double lo = iLow(Symbol(), tf, boBar);
         double range = hi - lo;
         double body = MathAbs(iClose(Symbol(), tf, boBar) - iOpen(Symbol(), tf, boBar));
         double bodyRatio = (range > 0.0) ? (body / range) : 1.0;

         if (boVol >= avgVol * MathMax(1.1, VD_ClimaxVolRatio) && bodyRatio <= VD_ClimaxMaxBodyRatio)
         {
            score += 1.0;
            if (DebugMode)
               Print("VolDivergence: climax bar (vol x",
                     DoubleToString(boVol / avgVol, 2), ", body ",
                     DoubleToString(bodyRatio, 2), ") TF=", TimeframeToString(tf),
                     " Zone ", zone.uniqueID);
         }
      }
   }

   return score;
}

bool HasVolumeDivergence(ZoneInfo &zone, int tf)
{
   if (!Use_VolumeDivergenceFilter) return false;
   return (GetVolumeDivergenceScore(zone, tf) > 0.0);
}

//+------------------------------------------------------------------+
//| BREAKOUT WICK REJECTION - the candle that broke structure must    |
//| be a real displacement candle, not a wick. A long wick in the     |
//| breakout direction = liquidity grab, the order block behind it is |
//| fake. Gold produces most of its fake zones exactly this way.      |
//+------------------------------------------------------------------+
bool PassBreakoutWickRejectionFilter(ZoneInfo &zone, int tf)
{
   if (!Use_BreakoutWickRejection) return true;

   int bs = zone.breakoutBar;
   if (zone.breakoutTime > 0)
   {
      int t = iBarShift(Symbol(), tf, zone.breakoutTime, true);
      if (t >= 0) bs = t;
   }
   int bars = iBars(Symbol(), tf);
   if (bs < 0 || bs >= bars) return true;

   double hi = iHigh(Symbol(), tf, bs);
   double lo = iLow(Symbol(), tf, bs);
   double op = iOpen(Symbol(), tf, bs);
   double cl = iClose(Symbol(), tf, bs);
   double range = hi - lo;
   if (range <= 0) return false;

   double body      = MathAbs(cl - op);
   double upperWick = hi - MathMax(op, cl);
   double lowerWick = MathMin(op, cl) - lo;

   bool bull = (zone.zoneType == "Bull");
   double breakWick = bull ? upperWick : lowerWick;   // wick in the breakout direction
   double oppWick   = bull ? lowerWick : upperWick;   // wick against it

   if ((body / range) < WR_MinBodyPct) return false;
   if ((breakWick / range) > WR_MaxBreakWickPct) return false;
   if ((oppWick / range) > WR_MaxOppositeWickPct) return false;

   // The move must hold: no close back through the breakout candle's body
   if (WR_CheckFollowBar && WR_FollowBars > 0)
   {
      double breakLevel = bull ? MathMin(op, cl) : MathMax(op, cl);
      for (int i = bs - 1; i >= bs - WR_FollowBars && i >= 1; i--)
      {
         if (i >= bars) continue;
         double c = iClose(Symbol(), tf, i);
         if (bull && c < breakLevel) return false;
         if (!bull && c > breakLevel) return false;
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| ATR ACCELERATION - a genuine institutional move expands           |
//| volatility. A breakout printed into shrinking volatility is       |
//| almost always a fake / range breakout.                            |
//+------------------------------------------------------------------+
bool PassATRAccelerationFilter(ZoneInfo &zone, int tf)
{
   if (!Use_ATRAccelerationFilter) return true;

   int bs = zone.breakoutBar;
   if (zone.breakoutTime > 0)
   {
      int t = iBarShift(Symbol(), tf, zone.breakoutTime, true);
      if (t >= 0) bs = t;
   }
   int bars = iBars(Symbol(), tf);
   if (bs < 0 || bs >= bars) return true;
   if (bars < AAC_SlowATR + AAC_FastATR + 5) return true;

   double fast = iATR(Symbol(), tf, AAC_FastATR, bs);
   double slow = iATR(Symbol(), tf, AAC_SlowATR, bs + AAC_FastATR);
   if (fast <= 0 || slow <= 0) return true;

   if (AAC_BlockDecelerating && (fast / slow) < AAC_MinRatio) return false;

   double range = iHigh(Symbol(), tf, bs) - iLow(Symbol(), tf, bs);
   if (range < slow * AAC_MinRangeATR) return false;

   return true;
}

//+------------------------------------------------------------------+
//| ENTRY GUARD - the order must be placed on the correct side of    |
//| the zone. A demand zone is only bought AT the zone (retest), a   |
//| supply zone is only sold AT the zone. Chasing the breakout puts  |
//| the entry far from the zone while the SL stays on the far edge,  |
//| which is what turns a valid zone into a losing trade.            |
//+------------------------------------------------------------------+
bool ZoneClosedThrough(ZoneInfo &zone)
{
   int tf = zone.timeframe;
   int bars = iBars(Symbol(), tf);
   if (bars < 3) return false;

   int from = zone.breakoutBar - 1;
   if (zone.breakoutTime > 0)
   {
      int bs = iBarShift(Symbol(), tf, zone.breakoutTime, true);
      if (bs > 0) from = bs - 1;
   }
   if (from > 500) from = 500;
   if (from < 1) return false;

   double height = zone.top - zone.bottom;
   double buf = height * 0.10;
   if (buf < Point * 3) buf = Point * 3;

   bool bull = (zone.zoneType == "Bull");
   for (int i = from; i >= 1; i--)
   {
      if (i >= bars) continue;
      double c = iClose(Symbol(), tf, i);
      if (bull && c < zone.bottom - buf) return true;
      if (!bull && c > zone.top + buf) return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Entry levels. Entering immediately after the zone appears is fine |
//| (that is where the momentum is), but then the stop must NOT be    |
//| the far edge of the zone - that risk is huge and the R:R is fake. |
//| Outside the zone we use a tight ATR stop and a quick target.      |
//+------------------------------------------------------------------+
void ComputeEntryLevels(ZoneInfo &zone, int type, double price, double &slPrice, double &tpPrice)
{
   bool bull = (type == OP_BUY);
   slPrice = zone.stopLoss;
   tpPrice = zone.takeProfit;

   if (!Use_EntryGuard || !Entry_UseATRStopOutside) return;

   bool outside = bull ? (price > zone.top) : (price < zone.bottom);
   if (!outside) return;

   double atr = iATR(Symbol(), zone.timeframe, 14, 1);
   if (atr <= 0) return;

   double atrSL = bull ? (price - atr * Entry_ATRStopMult)
                       : (price + atr * Entry_ATRStopMult);

   // keep whichever stop is tighter, never wider than the zone stop
   if (bull  && atrSL > slPrice) slPrice = atrSL;
   if (!bull && atrSL < slPrice) slPrice = atrSL;

   double risk = bull ? (price - slPrice) : (slPrice - price);
   if (risk <= 0) return;

   double fastTP = bull ? (price + risk * Entry_FastTP_RR)
                        : (price - risk * Entry_FastTP_RR);

   // take the nearer of the two targets -> grab the move and get out
   if (bull)  tpPrice = MathMin(tpPrice, fastTP);
   else       tpPrice = MathMax(tpPrice, fastTP);
}

bool EntryGuardAllows(ZoneInfo &zone, int type, double price, double slPrice, double tpPrice, string &reason)
{
   reason = "";
   if (!Use_EntryGuard) return true;

   bool bull = (type == OP_BUY);

   if (Entry_BlockIfZoneBroken && ZoneClosedThrough(zone))
   { reason = "zone already broken"; return false; }

   double atr = iATR(Symbol(), zone.timeframe, 14, 1);
   if (atr <= 0) atr = zone.top - zone.bottom;
   double maxDist = atr * MathMax(0.0, Entry_MaxDistanceATR);

   if (bull)
   {
      // Never buy below a demand zone / sell above a supply zone: that side is
      // where the stop lives, the zone is already violated.
      if (price < zone.bottom) { reason = "price below demand zone"; return false; }
      if (price > zone.top + maxDist) { reason = "price too far above demand zone"; return false; }
   }
   else
   {
      if (price > zone.top) { reason = "price above supply zone"; return false; }
      if (price < zone.bottom - maxDist) { reason = "price too far below supply zone"; return false; }
   }

   if (Entry_RequireInsideZone)
   {
      if (bull && price > zone.top)    { reason = "waiting for retest of demand zone"; return false; }
      if (!bull && price < zone.bottom) { reason = "waiting for retest of supply zone"; return false; }
   }

   // Real risk/reward measured from the price we would actually get filled at
   if (Entry_MinRR > 0)
   {
      double risk   = bull ? (price - slPrice) : (slPrice - price);
      double reward = bull ? (tpPrice - price) : (price - tpPrice);
      if (risk <= 0 || reward <= 0) { reason = "invalid SL/TP vs price"; return false; }
      if (reward / risk < Entry_MinRR)
      {
         reason = "RR " + DoubleToString(reward / risk, 2) + " < " + DoubleToString(Entry_MinRR, 2);
         return false;
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| TRADE RR / STOP-SIZE GATE - execution-side safety                |
//+------------------------------------------------------------------+
bool TradeRRGateAllows(int type, double price, double slPrice, double tpPrice, string tag)
{
   if (!Use_TradeRRGate) return true;
   bool bull = (type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP);
   double risk   = bull ? (price - slPrice) : (slPrice - price);
   double reward = bull ? (tpPrice - price) : (price - tpPrice);
   if (risk <= 0.0 || reward <= 0.0)
   {
      Print("TradeRRGate blocked ", tag, ": SL/TP on the wrong side",
            " entry=", DoubleToString(price, Digits),
            " SL=", DoubleToString(slPrice, Digits),
            " TP=", DoubleToString(tpPrice, Digits));
      return false;
   }
   if (TradeGate_MinRR > 0.0 && reward / risk < TradeGate_MinRR)
   {
      Print("TradeRRGate blocked ", tag, ": RR ", DoubleToString(reward / risk, 2),
            " < ", DoubleToString(TradeGate_MinRR, 2),
            " entry=", DoubleToString(price, Digits),
            " SL=", DoubleToString(slPrice, Digits),
            " TP=", DoubleToString(tpPrice, Digits));
      return false;
   }
   if (TradeGate_MaxSLPoints > 0.0)
   {
      double gatePt = Point;
      if (gatePt <= 0.0) gatePt = 0.0001;
      if (risk / gatePt > TradeGate_MaxSLPoints)
      {
         Print("TradeRRGate blocked ", tag, ": stop ",
               DoubleToString(risk / gatePt, 0), " points > ",
               DoubleToString(TradeGate_MaxSLPoints, 0));
         return false;
      }
   }
   return true;
}

//+------------------------------------------------------------------+
//| RISK GUARD - execution-side safety. Never touches zones, it only |
//| decides whether an order may be sent.                            |
//+------------------------------------------------------------------+
double GetSpreadPoints()
{
   double pt = Point;
   if (pt <= 0) pt = 0.0001;
   return (Ask - Bid) / pt;
}

string BuildTradeComment(ZoneInfo &zone)
{
   return "TI_Z" + IntegerToString(zone.uniqueID);
}

int CountEAOpenTrades(int typeFilter = -1)
{
   int count = 0;
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderMagicNumber() != Magic_Number) continue;
      if (OrderSymbol() != Symbol()) continue;
      int ot = OrderType();
      if (ot != OP_BUY && ot != OP_SELL) continue;
      if (typeFilter >= 0 && ot != typeFilter) continue;
      count++;
   }
   return count;
}

bool ZoneAlreadyTraded(int zoneID)
{
   string tag = "TI_Z" + IntegerToString(zoneID);
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderMagicNumber() != Magic_Number) continue;
      if (OrderSymbol() != Symbol()) continue;
      if (StringFind(OrderComment(), tag) >= 0) return true;
   }
   for (int h = OrdersHistoryTotal() - 1; h >= 0; h--)
   {
      if (!OrderSelect(h, SELECT_BY_POS, MODE_HISTORY)) continue;
      if (OrderMagicNumber() != Magic_Number) continue;
      if (OrderSymbol() != Symbol()) continue;
      if (StringFind(OrderComment(), tag) >= 0) return true;
   }
   return false;
}

double GetTodayClosedProfit()
{
   double profit = 0.0;
   datetime now = TimeCurrent();
   for (int h = OrdersHistoryTotal() - 1; h >= 0; h--)
   {
      if (!OrderSelect(h, SELECT_BY_POS, MODE_HISTORY)) continue;
      if (OrderMagicNumber() != Magic_Number) continue;
      if (OrderSymbol() != Symbol()) continue;
      int ot = OrderType();
      if (ot != OP_BUY && ot != OP_SELL) continue;
      if (TimeDay(OrderCloseTime()) != TimeDay(now) ||
          TimeMonth(OrderCloseTime()) != TimeMonth(now) ||
          TimeYear(OrderCloseTime()) != TimeYear(now)) continue;
      profit += OrderProfit() + OrderSwap() + OrderCommission();
   }
   return profit;
}

int GetTodayTradeCount()
{
   int count = 0;
   datetime now = TimeCurrent();
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderMagicNumber() != Magic_Number) continue;
      if (OrderSymbol() != Symbol()) continue;
      int ot = OrderType();
      if (ot != OP_BUY && ot != OP_SELL) continue;
      if (TimeDay(OrderOpenTime()) == TimeDay(now) &&
          TimeMonth(OrderOpenTime()) == TimeMonth(now) &&
          TimeYear(OrderOpenTime()) == TimeYear(now)) count++;
   }
   for (int h = OrdersHistoryTotal() - 1; h >= 0; h--)
   {
      if (!OrderSelect(h, SELECT_BY_POS, MODE_HISTORY)) continue;
      if (OrderMagicNumber() != Magic_Number) continue;
      if (OrderSymbol() != Symbol()) continue;
      int ot2 = OrderType();
      if (ot2 != OP_BUY && ot2 != OP_SELL) continue;
      if (TimeDay(OrderOpenTime()) == TimeDay(now) &&
          TimeMonth(OrderOpenTime()) == TimeMonth(now) &&
          TimeYear(OrderOpenTime()) == TimeYear(now)) count++;
   }
   return count;
}

datetime GetLastLossTime()
{
   datetime last = 0;
   for (int h = OrdersHistoryTotal() - 1; h >= 0; h--)
   {
      if (!OrderSelect(h, SELECT_BY_POS, MODE_HISTORY)) continue;
      if (OrderMagicNumber() != Magic_Number) continue;
      if (OrderSymbol() != Symbol()) continue;
      int ot = OrderType();
      if (ot != OP_BUY && ot != OP_SELL) continue;
      if (OrderProfit() + OrderSwap() + OrderCommission() >= 0.0) continue;
      if (OrderCloseTime() > last) last = OrderCloseTime();
   }
   return last;
}

int GetConsecutiveLosses()
{
   // Collect the most recent closed EA trades, newest first, then count the
   // unbroken run of losers.
   datetime times[];
   double   profits[];
   int n = 0;
   for (int h = OrdersHistoryTotal() - 1; h >= 0; h--)
   {
      if (!OrderSelect(h, SELECT_BY_POS, MODE_HISTORY)) continue;
      if (OrderMagicNumber() != Magic_Number) continue;
      if (OrderSymbol() != Symbol()) continue;
      int ot = OrderType();
      if (ot != OP_BUY && ot != OP_SELL) continue;
      ArrayResize(times, n + 1);
      ArrayResize(profits, n + 1);
      times[n]   = OrderCloseTime();
      profits[n] = OrderProfit() + OrderSwap() + OrderCommission();
      n++;
      if (n >= 500) break;
   }
   if (n == 0) return 0;

   for (int i = 1; i < n; i++)
   {
      datetime kt = times[i];
      double   kp = profits[i];
      int j = i - 1;
      while (j >= 0 && times[j] < kt)
      {
         times[j + 1]   = times[j];
         profits[j + 1] = profits[j];
         j--;
      }
      times[j + 1]   = kt;
      profits[j + 1] = kp;
   }

   int losses = 0;
   for (int i = 0; i < n; i++)
   {
      if (profits[i] < 0.0) losses++;
      else break;
   }
   return losses;
}

void UpdateRiskState(bool force = false)
{
   double equity = AccountEquity();
   if (equity > g_peakEquity) g_peakEquity = equity;
   if (g_dayStartBalance <= 0.0) g_dayStartBalance = AccountBalance();

   // history scans are expensive - refresh at most every 3 seconds
   if (!force && g_riskCacheTime > 0 && (TimeCurrent() - g_riskCacheTime) < 3) return;

   g_cachedDayPnL       = GetTodayClosedProfit();
   g_cachedConsecLosses = GetConsecutiveLosses();
   g_cachedLastLossTime = GetLastLossTime();
   g_cachedTodayTrades  = GetTodayTradeCount();
   g_riskCacheTime      = TimeCurrent();
}

bool RiskGuardAccountOK(string &reason)
{
   reason = "";
   if (!Use_RiskGuard) return true;

   UpdateRiskState();

   if (!IsTradeAllowed())          { reason = "trading not allowed by terminal"; return false; }
   if (!IsConnected())             { reason = "no connection";                   return false; }

   if (Risk_MaxSpreadPoints > 0 && GetSpreadPoints() > Risk_MaxSpreadPoints)
   { reason = "spread " + DoubleToString(GetSpreadPoints(), 1) + " > max"; return false; }

   double balance = AccountBalance();
   if (balance > 0)
   {
      if (Risk_MaxDailyLossPct > 0 && g_cachedDayPnL <= -(balance * Risk_MaxDailyLossPct / 100.0))
      { reason = "daily loss limit"; return false; }
      if (Risk_MaxDailyProfitPct > 0 && g_cachedDayPnL >= (balance * Risk_MaxDailyProfitPct / 100.0))
      { reason = "daily profit target reached"; return false; }
   }

   if (Risk_MaxConsecutiveLosses > 0 && g_cachedConsecLosses >= Risk_MaxConsecutiveLosses)
   { reason = "consecutive losses"; return false; }

   if (Risk_CooldownMinutesAfterLoss > 0 && g_cachedLastLossTime > 0 &&
       (TimeCurrent() - g_cachedLastLossTime) < Risk_CooldownMinutesAfterLoss * 60)
   { reason = "cooldown after loss"; return false; }

   if (Risk_MaxEquityDrawdownPct > 0 && g_peakEquity > 0)
   {
      double dd = (g_peakEquity - AccountEquity()) / g_peakEquity * 100.0;
      if (dd >= Risk_MaxEquityDrawdownPct)
      { reason = "equity drawdown " + DoubleToString(dd, 1) + "%"; return false; }
   }

   if (Risk_MinFreeMarginPct > 0 && AccountMargin() > 0)
   {
      double marginLevel = AccountEquity() / AccountMargin() * 100.0;
      if (marginLevel < Risk_MinFreeMarginPct) { reason = "margin level too low"; return false; }
   }

   return true;
}

bool RiskGuardAllowsTrade(ZoneInfo &zone, int type, string &reason)
{
   if (!Use_RiskGuard) return true;
   UpdateRiskState(true);
   if (!RiskGuardAccountOK(reason)) return false;

   if (Risk_MaxOpenTrades > 0 && CountEAOpenTrades() >= Risk_MaxOpenTrades)
   { reason = "max open trades"; return false; }

   if (Risk_BlockOppositeDirection)
   {
      int opposite = (type == OP_BUY) ? OP_SELL : OP_BUY;
      if (CountEAOpenTrades(opposite) > 0) { reason = "opposite position open"; return false; }
   }

   if (Risk_OneTradePerZone && ZoneAlreadyTraded(zone.uniqueID))
   { reason = "zone already traded"; return false; }

   if (Risk_MaxTradesPerDay > 0 && g_cachedTodayTrades >= Risk_MaxTradesPerDay)
   { reason = "daily trade limit"; return false; }

   return true;
}

double CalcTradeLot(double entry, double slPrice, double fallbackLot)
{
   double lot = fallbackLot;

   if (Use_RiskGuard && Risk_UsePercentLot && Risk_PercentPerTrade > 0)
   {
      double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
      double tickSize  = MarketInfo(Symbol(), MODE_TICKSIZE);
      double slDist    = MathAbs(entry - slPrice);
      if (tickValue > 0 && tickSize > 0 && slDist > 0)
      {
         double riskMoney = AccountBalance() * Risk_PercentPerTrade / 100.0;
         double lossPerLot = (slDist / tickSize) * tickValue;
         if (lossPerLot > 0) lot = riskMoney / lossPerLot;
      }
   }

   double minLot  = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot  = MarketInfo(Symbol(), MODE_MAXLOT);
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   if (minLot <= 0)  minLot = 0.01;
   if (maxLot <= 0)  maxLot = 100.0;
   if (lotStep <= 0) lotStep = 0.01;

   if (Use_RiskGuard && Risk_MaxLot > 0 && lot > Risk_MaxLot) lot = Risk_MaxLot;
   lot = MathFloor(lot / lotStep) * lotStep;
   if (lot < minLot) lot = minLot;
   if (lot > maxLot) lot = maxLot;

   ResetLastError();
   double marginNeeded = AccountFreeMarginCheck(Symbol(), OP_BUY, lot);
   int marginError = GetLastError();
   if (marginNeeded <= 0 || marginError == 134)
   {
      Print("CalcTradeLot returned 0: free margin check failed",
            " lot=", DoubleToString(lot, 2),
            " freeMarginAfter=", DoubleToString(marginNeeded, 2),
            " error=", marginError);
      return 0.0;
   }

   return NormalizeDouble(lot, 2);
}

//+------------------------------------------------------------------+
//| Break-even + ATR trailing stop for open EA positions.            |
//+------------------------------------------------------------------+
void ManageOpenTrades()
{
   if (!Use_RiskGuard) return;
   if (!Use_BreakEven && !Use_TrailingStop) return;

   int atrPeriod = (int)Trail_ATRPeriod;
   if (atrPeriod < 2) atrPeriod = 14;
   double atr = iATR(Symbol(), Period(), atrPeriod, 1);
   double pt  = Point;
   if (pt <= 0) pt = 0.0001;
   double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * pt;

   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderMagicNumber() != Magic_Number) continue;
      if (OrderSymbol() != Symbol()) continue;
      int ot = OrderType();
      if (ot != OP_BUY && ot != OP_SELL) continue;

      double entry = OrderOpenPrice();
      double sl    = OrderStopLoss();
      if (sl == 0.0) continue;                 // never trail a position without an initial SL
      double risk  = MathAbs(entry - sl);
      if (risk <= 0) continue;

      double price   = (ot == OP_BUY) ? Bid : Ask;
      double profitR = (ot == OP_BUY) ? (price - entry) / risk : (entry - price) / risk;
      double newSL   = sl;

      if (Use_BreakEven && profitR >= BE_TriggerRR)
      {
         double be = (BE_LockRR > 0.0)
                     ? ((ot == OP_BUY) ? entry + risk * BE_LockRR : entry - risk * BE_LockRR)
                     : ((ot == OP_BUY) ? entry + BE_LockPoints * pt : entry - BE_LockPoints * pt);
         if (ot == OP_BUY  && be > newSL) newSL = be;
         if (ot == OP_SELL && be < newSL) newSL = be;
      }

      if (Use_TrailingStop && atr > 0 && profitR >= Trail_StartRR)
      {
         double trail = (ot == OP_BUY) ? price - atr * Trail_ATRMultiplier
                                       : price + atr * Trail_ATRMultiplier;
         if (Trail_MinDistRR > 0.0)
         {
            if (ot == OP_BUY && price - trail < risk * Trail_MinDistRR)
               trail = price - risk * Trail_MinDistRR;
            if (ot == OP_SELL && trail - price < risk * Trail_MinDistRR)
               trail = price + risk * Trail_MinDistRR;
         }
         if (ot == OP_BUY  && trail > newSL) newSL = trail;
         if (ot == OP_SELL && trail < newSL) newSL = trail;
      }

      if (MathAbs(newSL - sl) < pt) continue;
      if (ot == OP_BUY  && newSL > price - stopLevel) continue;
      if (ot == OP_SELL && newSL < price + stopLevel) continue;

      newSL = NormalizeDouble(newSL, Digits);
      if (!OrderModify(OrderTicket(), entry, newSL, OrderTakeProfit(), 0, clrYellow))
      {
         if (DebugMode) Print("Trail/BE OrderModify failed #", OrderTicket(), " err=", GetLastError());
      }
      else if (DebugMode)
      {
         Print("SL moved to ", DoubleToString(newSL, Digits), " ticket #", OrderTicket());
      }
   }
}

//+------------------------------------------------------------------+
//| MARKET STRUCTURE SHIFT (MSS) SCORING                              |
//| Returns a score 0.0 - 2.5 based on structure shift quality.      |
//| In StrictMode: score 0 = hard reject.                            |
//| Scoring breakdown:                                                |
//|  +1.0  structure break detected (broke swing level)              |
//|  +0.5  break size >= 1.0 ATR                                      |
//|  +0.5  break size >= 2.0 ATR                                      |
//|  +0.5  multiple swing levels broken                               |
//+------------------------------------------------------------------+
double GetMSSScore(ZoneInfo &zone, int tf)
{
   if (!Use_MSSFilter) return 0.0;
   
   int boBar = zone.breakoutBar;
   if (zone.breakoutTime > 0) boBar = iBarShift(Symbol(), tf, zone.breakoutTime, true);
   if (boBar < 1) return 0.0;
   
   int bars = iBars(Symbol(), tf);
   int lb = MSS_PivotLookback;
   if (lb < 10) lb = 10;
   if (boBar + lb >= bars) lb = bars - boBar - 1;
   if (lb < 5) return 0.0;
   
   double atr = iATR(Symbol(), tf, 14, boBar);
   if (atr <= 0) return 0.0;
   
   bool isBull = (zone.zoneType == "Bull");
   double score = 0.0;
   int breaksFound = 0;
   double bestBreakSize = 0.0;
   
   if (isBull)
   {
      // Find swing lows that were broken (structure break to downside before reversal)
      for (int s = boBar + 2; s < boBar + lb && s < bars - 1; s++)
      {
         double low_s = iLow(Symbol(), tf, s);
         bool isPivotLow = true;
         for (int j = s - 1; j <= s + 1; j++)
         {
            if (j < 0 || j >= bars) { isPivotLow = false; break; }
            if (j != s && iLow(Symbol(), tf, j) < low_s)
            { isPivotLow = false; break; }
         }
         if (isPivotLow)
         {
            double boLow = iLow(Symbol(), tf, boBar);
            double breakSize = low_s - boLow;
            if (breakSize > 0 && breakSize >= atr * MSS_MinBreakoutATR)
            {
               breaksFound++;
               if (breakSize > bestBreakSize) bestBreakSize = breakSize;
            }
         }
      }
   }
   else
   {
      // Find swing highs that were broken (structure break to upside before reversal)
      for (int s = boBar + 2; s < boBar + lb && s < bars - 1; s++)
      {
         double high_s = iHigh(Symbol(), tf, s);
         bool isPivotHigh = true;
         for (int j = s - 1; j <= s + 1; j++)
         {
            if (j < 0 || j >= bars) { isPivotHigh = false; break; }
            if (j != s && iHigh(Symbol(), tf, j) > high_s)
            { isPivotHigh = false; break; }
         }
         if (isPivotHigh)
         {
            double boHigh = iHigh(Symbol(), tf, boBar);
            double breakSize = boHigh - high_s;
            if (breakSize > 0 && breakSize >= atr * MSS_MinBreakoutATR)
            {
               breaksFound++;
               if (breakSize > bestBreakSize) bestBreakSize = breakSize;
            }
         }
      }
   }
   
   if (breaksFound > 0)
   {
      score += 1.0; // Base score for structure break
      if (bestBreakSize >= atr * 1.0) score += 0.5;
      if (bestBreakSize >= atr * 2.0) score += 0.5;
      if (breaksFound >= 2) score += 0.5; // Multiple levels broken = stronger shift
   }
   
   // StrictMode: reject if no structure shift found
   if (MSS_StrictMode && breaksFound == 0)
   {
      if (DebugMode) Print("MSS STRICT reject: No structure shift. Zone ID: ", zone.uniqueID);
      return -100.0;
   }
   
   if (DebugMode) Print("MSS score: ", DoubleToString(score, 2), " Breaks=", breaksFound, " Zone ID: ", zone.uniqueID);
   return score;
}

//+------------------------------------------------------------------+
//| Scan historical zones (one-time on init)                         |
//+------------------------------------------------------------------+
void ScanHistoricalZones(int tf)
{
   g_isScanningHistory = true;
   int bars = iBars(Symbol(), tf);
   if (bars < 350) { g_isScanningHistory = false; return; }
   double atr = iATR(Symbol(), tf, 60, 1);
   if (atr <= 0) { g_isScanningHistory = false; return; }
   if (Use_OrderBlocks)
   {
      int tfIndex = FindTFIndex(tf);
      if (tfIndex >= 0) OB_ScanLookback(tf, tfIndex);
      g_isScanningHistory = false;
      return;
   }
   int scanEnd = MathMin(ZoneLookback, bars - 10);
   if (scanEnd < 300) scanEnd = MathMin(100, bars - 10);
   if (DebugMode)
      Print("Scanning ", TimeframeToString(tf), " history, lookback=", scanEnd);
   double pip = (Digits == 3 || Digits == 5) ? Point * 10 : Point;
   int currentDay = TimeDay(TimeCurrent());
   for (int i = scanEnd; i >= 10; i--)
   {
      if (CountBullZonesForTF(tf) < Buy_MaxZones && IsDemandZone_Live(tf, i))
      {
         ZoneInfo zone = CreateDemandZone(tf, i);
         if (IsZoneValid(zone, tf))
         {
            AddBullishZone(zone);
            if (TimeDay(zone.startTime) == currentDay) g_todayBullCount++;
         }
      }
      if (CountBearZonesForTF(tf) < Sell_MaxZones && IsSupplyZone_Live(tf, i))
      {
         ZoneInfo zone = CreateSupplyZone(tf, i);
         if (IsZoneValid(zone, tf))
         {
             AddBearishZone(zone);
             if (TimeDay(zone.startTime) == currentDay) g_todayBearCount++;
         }
      }
   }
   g_isScanningHistory = false;
}

//+------------------------------------------------------------------+
//| Zone validation                                                  |
//+------------------------------------------------------------------+
bool IsZoneValid(ZoneInfo &zone, int tf)
{
    double atr = iATR(Symbol(), tf, 14, zone.breakoutBar);
    if (atr <= 0) return false;
    // 1. Price Action Filter in Base
    bool basePaConfirmed = false;
    if (!Use_PinBar_Filter && !Use_Engulfing_Filter) 
    {
        basePaConfirmed = true; // Skip if filters are off
    }
    else
    {
        for (int b = zone.baseStartBar; b <= zone.baseEndBar; b++)
        {
            if (zone.zoneType == "Bull")
            {
                if (Use_Engulfing_Filter && IsBullishEngulfing(tf, b)) { basePaConfirmed = true; break; }
                if (Use_PinBar_Filter && IsBullishPinBar(tf, b)) { basePaConfirmed = true; break; }
            }
            else // Bear
            {
                if (Use_Engulfing_Filter && IsBearishEngulfing(tf, b)) { basePaConfirmed = true; break; }
                if (Use_PinBar_Filter && IsBearishPinBar(tf, b)) { basePaConfirmed = true; break; }
            }
        }
    }
    if (!basePaConfirmed) 
    {
        if(DebugMode) Print("Zone Invalid: No valid PA pattern in base. Zone ID: ", zone.uniqueID);
        return false;
    }

    // 2. Minimum Impulse Check
    if (Use_Impulse_Filter)
    {
        int impulseStartBar = zone.breakoutBar - 2; // Check 3 bars of impulse
        if (impulseStartBar < 0) impulseStartBar = 0;
        double impulseHigh = 0, impulseLow = 999999;
        int consecutiveBars = 0;
        
        if (zone.zoneType == "Bull")
        {
            for (int i = zone.breakoutBar; i >= impulseStartBar; i--)
            {
                if (iClose(Symbol(), tf, i) > iOpen(Symbol(), tf, i)) consecutiveBars++;
                else break; // Must be consecutive
                if (iHigh(Symbol(), tf, i) > impulseHigh) impulseHigh = iHigh(Symbol(), tf, i);
            }
            if (consecutiveBars < 1 || (impulseHigh - zone.top) < atr * Min_Impulse_ATR)
            {
                if(DebugMode) Print("Zone Invalid: Weak impulse (BULL). Zone ID: ", zone.uniqueID);
                return false;
            }
        }
        else // Bear
        {
            for (int i = zone.breakoutBar; i >= impulseStartBar; i--)
            {
                if (iClose(Symbol(), tf, i) < iOpen(Symbol(), tf, i)) consecutiveBars++;
                else break;
                if (iLow(Symbol(), tf, i) < impulseLow) impulseLow = iLow(Symbol(), tf, i);
            }
            if (consecutiveBars < 1 || (zone.bottom - impulseLow) < atr * Min_Impulse_ATR)
            {
                if(DebugMode) Print("Zone Invalid: Weak impulse (BEAR). Zone ID: ", zone.uniqueID);
                return false;
            }
        }
    }

    // 3. Volume on Impulse
    if (Use_Volume_Impulse_Filter)
    {
        int impulseStartBar = zone.breakoutBar - 2;
        if (impulseStartBar < 0) impulseStartBar = 0;
        int volumeSpikes = 0;
        double avgVol = GetAverageVolume(tf, Volume_Lookback_Period, zone.breakoutBar + 1);
        if (avgVol > 0)
        {
            for (int i = zone.breakoutBar; i >= impulseStartBar; i--)
            {
                if ((double)iVolume(Symbol(), tf, i) >= avgVol * Volume_Multiplier)
                {
                    volumeSpikes++;
                }
            }
        }
        if (volumeSpikes < 1)
        {
            if(DebugMode) Print("Zone Invalid: Not enough volume spikes on impulse. Spikes: ", volumeSpikes);
            return false;
        }
    }

    // Existing validation logic continues...
    double pip         = (Digits == 3 || Digits == 5) ? Point * 10 : Point;
    double minZoneGap;
    if (zone.zoneType == "Bull")
        minZoneGap = Buy_MinZoneDistance * pip;
    else
        minZoneGap = Sell_MinZoneDistance * pip;
    double oppositeMinGap = 20.0 * pip;
    double edgeEps        = pip * 1.0;
    if (zone.zoneType == "Bull")
    {
        double zoneHeight = zone.top - zone.bottom;
        if (zoneHeight < atr * Buy_MinZoneHeightATR || zoneHeight > atr * Buy_MaxZoneHeightATR)
            return false;
        if (zoneHeight < Buy_MinZoneHeightPoints * Point)
            return false;
        for (int i = 0; i < totalBullZones; i++)
        {
            if (BullishZones[i].timeframe != tf) continue;
            double top1 = zone.top;
            double bot1 = zone.bottom;
            double top2 = BullishZones[i].top;
            double bot2 = BullishZones[i].bottom;
            double gap;
            if (top1 <= bot2)
                gap = bot2 - top1;
            else if (top2 <= bot1)
                gap = bot1 - top2;
            else
                gap = 0.0;
            if (gap <= edgeEps)
                return false;
            if (gap < minZoneGap)
                return false;
        }
    }
    else
    {
        double zoneHeight = zone.top - zone.bottom;
        if (zoneHeight < atr * Sell_MinZoneHeightATR || zoneHeight > atr * Sell_MaxZoneHeightATR)
            return false;
        if (zoneHeight < Sell_MinZoneHeightPoints * Point)
            return false;
        for (int i = 0; i < totalBearZones; i++)
        {
            if (BearishZones[i].timeframe != tf) continue;
            double top1 = zone.top;
            double bot1 = zone.bottom;
            double top2 = BearishZones[i].top;
            double bot2 = BearishZones[i].bottom;
            double gap;
            if (top1 <= bot2)
                gap = bot2 - top1;
            else if (top2 <= bot1)
                gap = bot1 - top2;
            else
                gap = 0.0;

            if (gap <= edgeEps)
                return false;

            if (gap < minZoneGap)
                return false;
        }
    }
    if (zone.zoneType == "Bull")
    {
        for (int i = 0; i < totalBearZones; i++)
        {
            if (BearishZones[i].timeframe != tf) continue;

            double top1 = zone.top;
            double bot1 = zone.bottom;
            double top2 = BearishZones[i].top;
            double bot2 = BearishZones[i].bottom;
            double gap;
            if (top1 <= bot2)
                gap = bot2 - top1;
            else if (top2 <= bot1)
                gap = bot1 - top2;
            else
                gap = 0.0;
            if (gap <= oppositeMinGap)
                return false;
        }
    }
    else 
    {
        for (int i = 0; i < totalBullZones; i++)
        {
            if (BullishZones[i].timeframe != tf) continue;
            double top1 = zone.top;
            double bot1 = zone.bottom;
            double top2 = BullishZones[i].top;
            double bot2 = BullishZones[i].bottom;
            double gap;
            if (top1 <= bot2)
                gap = bot2 - top1;
            else if (top2 <= bot1)
                gap = bot1 - top2;
            else
                gap = 0.0;
            if (gap <= oppositeMinGap)
                return false;
        }
    }
    int shift = zone.breakoutBar;
    int bars  = iBars(Symbol(), tf);
    int colorChanges = 0;
    for (int k = shift + 1; k <= shift + 10 && k < bars; k++)
    {
       bool isBull = (iClose(Symbol(), tf, k) > iOpen(Symbol(), tf, k));
       bool prevBull = (iClose(Symbol(), tf, k+1) > iOpen(Symbol(), tf, k+1));
       if (isBull != prevBull) colorChanges++;
    }
    if (colorChanges >= 4) 
    {
        if(DebugMode) Print("Zone Invalid: Too many color changes (choppy). Zone ID: ", zone.uniqueID);
        return false;
    } 
    int boBar = shift - 1;
    if (boBar < 0) return true;
    double preBaseAvgVol = 0;
    for(int v = 1; v <= 10; v++) preBaseAvgVol += (double)iVolume(Symbol(), tf, boBar + v);
    preBaseAvgVol /= 10.0;
    double longTermAvgVol = 0;
    for(int v = 1; v <= 50; v++) longTermAvgVol += (double)iVolume(Symbol(), tf, boBar + v);
    longTermAvgVol /= 50.0;
    if (longTermAvgVol > 0 && preBaseAvgVol < longTermAvgVol * 0.3) 
    {
        if(DebugMode) Print("Zone Invalid: Pre-base volume too low. Zone ID: ", zone.uniqueID);
        return false;
    }
    
    int rangeLookback = 50;
    double rangeHigh = -DBL_MAX;
    double rangeLow  = DBL_MAX;
    for(int k=shift; k < shift + rangeLookback && k < bars; k++)
    {
        double h = iHigh(Symbol(), tf, k);
        double l = iLow(Symbol(), tf, k);
        if(h > rangeHigh) rangeHigh = h;
        if(l < rangeLow)  rangeLow  = l;
    }
    double totalRange = rangeHigh - rangeLow;
    if(totalRange > 0)
    {
        double zoneRelativePos = 0;
        if (zone.zoneType == "Bull")
        {
            zoneRelativePos = (zone.top - rangeLow) / totalRange;
            if (zoneRelativePos > 0.85) 
            {
                if(DebugMode) Print("Zone Invalid: Bull zone too high in range. Zone ID: ", zone.uniqueID);
                return false;
            }
        }
        else
        {
            zoneRelativePos = (zone.bottom - rangeLow) / totalRange;
            if (zoneRelativePos < 0.15) 
            {
                if(DebugMode) Print("Zone Invalid: Bear zone too low in range. Zone ID: ", zone.uniqueID);
                return false;
            }
        }
    }
    
    double sumUpperWicks = 0;
    double sumLowerWicks = 0;
    double sumBodies     = 0;
    for(int b = zone.baseStartBar; b <= zone.baseEndBar; b++)
    {
       double O = iOpen(Symbol(), tf, b);
       double C = iClose(Symbol(), tf, b);
       double H = iHigh(Symbol(), tf, b);
       double L = iLow(Symbol(), tf, b);
       sumUpperWicks += (H - MathMax(O, C));
       sumLowerWicks += (MathMin(O, C) - L);
       sumBodies     += MathAbs(O - C);
    }
    if (zone.zoneType == "Bull")
    {
        if (sumUpperWicks > sumLowerWicks * 2.5 && sumUpperWicks > sumBodies * 0.9) 
        {
            if(DebugMode) Print("Zone Invalid: Too much upper wick in demand base. Zone ID: ", zone.uniqueID);
            return false;
        }
    }
    else 
    {
        if (sumLowerWicks > sumUpperWicks * 2.5 && sumLowerWicks > sumBodies * 0.9) 
        {
            if(DebugMode) Print("Zone Invalid: Too much lower wick in supply base. Zone ID: ", zone.uniqueID);
            return false;
        }
    }

    // Liquidity Sweep / RV / MSS: StrictMode hard reject (score -100 = reject)
    double scoreLS = GetLiquiditySweepScore(zone, tf);
    if (scoreLS < -50.0)
    {
        if(DebugMode) Print("Zone Invalid: Liquidity Sweep strict reject. Zone ID: ", zone.uniqueID);
        return false;
    }
    if (Sweep_StrictMode && scoreLS > 0 && scoreLS < Sweep_MinScore)
    {
        if(DebugMode) Print("Zone Invalid: Liquidity Sweep score too low: ", DoubleToString(scoreLS, 2), " < ", DoubleToString(Sweep_MinScore, 2), " Zone ID: ", zone.uniqueID);
        return false;
    }
    if (GetRVScore(zone, tf) < -50.0)
    {
        if(DebugMode) Print("Zone Invalid: RV strict reject. Zone ID: ", zone.uniqueID);
        return false;
    }
    if (GetMSSScore(zone, tf) < -50.0)
    {
        if(DebugMode) Print("Zone Invalid: MSS strict reject. Zone ID: ", zone.uniqueID);
        return false;
    }

    return true;
}

void RemoveOldestZone(int tf, string type)
{
   int oldestIdx = -1;
   datetime oldestTime = TimeCurrent(); 

   if (type == "Bull")
   {
      for (int i = 0; i < totalBullZones; i++)
      {
         if (BullishZones[i].timeframe == tf)
         {
            if (BullishZones[i].startTime < oldestTime)
            {
               oldestTime = BullishZones[i].startTime;
               oldestIdx = i;
            }
         }
      }
      if (oldestIdx != -1)
      {
         DeleteZoneVisuals(BullishZones[oldestIdx]);
         RemoveBullZoneAt(oldestIdx);
      }
   }
   else
   {
      for (int i = 0; i < totalBearZones; i++)
      {
         if (BearishZones[i].timeframe == tf)
         {
            if (BearishZones[i].startTime < oldestTime)
            {
               oldestTime = BearishZones[i].startTime;
               oldestIdx = i;
            }
         }
      }
      if (oldestIdx != -1)
      {
         DeleteZoneVisuals(BearishZones[oldestIdx]);
         RemoveBearZoneAt(oldestIdx);
      }
   }
}

//+------------------------------------------------------------------+
//| Detect new zones                                                 |
//+------------------------------------------------------------------+
void DetectNewZonesForTF(int tf)
{
   g_zoneTypesLocked = true;
   if (Use_OrderBlocks)
   {
      int tfIndex = FindTFIndex(tf);
      if (tfIndex >= 0)
      {
         OB_UpdatePivotsLive(tf, tfIndex);
         OB_CheckBreakoutsLive(tf, tfIndex);
      }
      return;
   }
   double edgeEps = 0.01 * 0.02;
   int bars = iBars(Symbol(), tf);
   if (bars < 60) return;
   for (int i = 2; i <= 50; i++)
   {
      if (IsDemandZone_Live(tf, i))
      {
         ZoneInfo zone = CreateDemandZone(tf, i);
         if (IsZoneValid(zone, tf))
         {
            bool exists = false;
            for (int j = 0; j < totalBullZones; j++)
            {
               if (BullishZones[j].timeframe == tf &&
                   MathAbs(zone.bottom - BullishZones[j].bottom) < Point * 10 &&
                   MathAbs(zone.top - BullishZones[j].top) < Point * 10)
               { 
                  exists = true; 
                  break; 
               }
            }
            if (!exists)
            {
               if (CountBullZonesForTF(tf) >= Buy_MaxZones)
               {
                   RemoveOldestZone(tf, "Bull");
               }
               AddBullishZone(zone);
               if (DebugMode)
                  Print("New DEMAND (", TimeframeToString(tf), ") at ",
                        DoubleToStr(zone.bottom, Digits), " Str:", DoubleToStr(zone.strength, 1));
            }
         }
      }
      if (IsSupplyZone_Live(tf, i))
      {
         ZoneInfo zone = CreateSupplyZone(tf, i);
         if (IsZoneValid(zone, tf))
         {
            bool exists = false;
            for (int j = 0; j < totalBearZones; j++)
            {
               if (BearishZones[j].timeframe == tf &&
                   MathAbs(zone.top - BearishZones[j].top) < Point * 10 &&
                   MathAbs(zone.bottom - BearishZones[j].bottom) < Point * 10)
               { 
                  exists = true; 
                  break; 
               }
            }
            if (!exists)
            {
               if (CountBearZonesForTF(tf) >= Sell_MaxZones)
               {
                   RemoveOldestZone(tf, "Bear");
               }
               AddBearishZone(zone);
               if (DebugMode)
                  Print("New SUPPLY (", TimeframeToString(tf), ") at ",
                        DoubleToStr(zone.top, Digits), " Str:", DoubleToStr(zone.strength, 1));
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| MARKET TREND + LIVE ZONE DETECTION                               |
//+------------------------------------------------------------------+
bool IsStructureSwingHigh(int tf, int bar, int strength)
{
   int bars = iBars(Symbol(), tf);
   if (strength < 1 || bar - strength < 0 || bar + strength >= bars) return false;

   double level = iHigh(Symbol(), tf, bar);
   for (int i = 1; i <= strength; i++)
   {
      if (iHigh(Symbol(), tf, bar - i) >= level) return false;
      if (iHigh(Symbol(), tf, bar + i) > level) return false;
   }
   return true;
}

bool IsStructureSwingLow(int tf, int bar, int strength)
{
   int bars = iBars(Symbol(), tf);
   if (strength < 1 || bar - strength < 0 || bar + strength >= bars) return false;

   double level = iLow(Symbol(), tf, bar);
   for (int i = 1; i <= strength; i++)
   {
      if (iLow(Symbol(), tf, bar - i) <= level) return false;
      if (iLow(Symbol(), tf, bar + i) < level) return false;
   }
   return true;
}

int GetMarketTrend(int tf, int shift)
{
   int bars = iBars(Symbol(), tf);
   int strength = GetMSSwingStrengthForTF(tf);
   if (strength < 1) strength = 1;
   if (shift < 0) shift = 0;
   if (bars <= shift + (strength * 2) + 5) return 0;

   int lookback = GetMSLookbackBarsForTF(tf);
   if (lookback < 20) lookback = 20;
   int firstBar = shift + strength + 1;
   int lastBar = MathMin(bars - strength - 1, shift + lookback);

   double latestHigh = 0.0;
   double previousHigh = 0.0;
   double latestLow = 0.0;
   double previousLow = 0.0;
   int highCount = 0;
   int lowCount = 0;

   for (int bar = firstBar; bar <= lastBar; bar++)
   {
      if (highCount < 2 && IsStructureSwingHigh(tf, bar, strength))
      {
         if (highCount == 0) latestHigh = iHigh(Symbol(), tf, bar);
         else previousHigh = iHigh(Symbol(), tf, bar);
         highCount++;
      }

      if (lowCount < 2 && IsStructureSwingLow(tf, bar, strength))
      {
         if (lowCount == 0) latestLow = iLow(Symbol(), tf, bar);
         else previousLow = iLow(Symbol(), tf, bar);
         lowCount++;
      }

      if (highCount >= 2 && lowCount >= 2) break;
   }

   double atr = iATR(Symbol(), tf, 14, shift);
   if (atr <= 0) atr = Point;
   double bosBuffer = atr * MathMax(0.0, GetMSBOSBufferATRForTF(tf));
   double closePrice = iClose(Symbol(), tf, shift);

   bool bullishBOS = (highCount >= 1 && closePrice > latestHigh + bosBuffer);
   bool bearishBOS = (lowCount >= 1 && closePrice < latestLow - bosBuffer);
   if (bullishBOS && !bearishBOS) return 1;
   if (bearishBOS && !bullishBOS) return -1;

   if (highCount >= 2 && lowCount >= 2)
   {
      bool higherHigh = latestHigh > previousHigh;
      bool higherLow = latestLow > previousLow;
      bool lowerHigh = latestHigh < previousHigh;
      bool lowerLow = latestLow < previousLow;

      if (higherHigh && higherLow) return 1;
      if (lowerHigh && lowerLow) return -1;
   }

   return 0;
}

int GetMarketTrendBOSOnly(int tf, int shift)
{
   int bars = iBars(Symbol(), tf);
   int strength = GetMSSwingStrengthForTF(tf);
   if (strength < 1) strength = 1;
   if (shift < 0) shift = 0;
   if (bars <= shift + (strength * 2) + 5) return 0;

   int lookback = GetMSLookbackBarsForTF(tf);
   if (lookback < 20) lookback = 20;
   int firstBar = shift + strength + 1;
   int lastBar = MathMin(bars - strength - 1, shift + lookback);

   double latestHigh = 0.0;
   double latestLow = 0.0;
   int highCount = 0;
   int lowCount = 0;

   for (int bar = firstBar; bar <= lastBar; bar++)
   {
      if (highCount < 1 && IsStructureSwingHigh(tf, bar, strength))
      {
         latestHigh = iHigh(Symbol(), tf, bar);
         highCount = 1;
      }
      if (lowCount < 1 && IsStructureSwingLow(tf, bar, strength))
      {
         latestLow = iLow(Symbol(), tf, bar);
         lowCount = 1;
      }
      if (highCount >= 1 && lowCount >= 1) break;
   }

   if (highCount < 1 && lowCount < 1) return 0;

   double atr = iATR(Symbol(), tf, 14, shift);
   if (atr <= 0) atr = Point;
   double bosBuffer = atr * MathMax(0.0, GetMSBOSBufferATRForTF(tf));
   double closePrice = iClose(Symbol(), tf, shift);

   if (highCount >= 1 && closePrice > latestHigh + bosBuffer) return 1;
   if (lowCount >= 1 && closePrice < latestLow - bosBuffer) return -1;
   return 0;
}

bool GetMarketStructureBOSLevels(int tf, int shift, int &dir, double &bosLevel, double &swingHigh, double &swingLow)
{
   dir = 0;
   bosLevel = 0.0;
   swingHigh = 0.0;
   swingLow = 0.0;

   int bars = iBars(Symbol(), tf);
   int strength = GetMSSwingStrengthForTF(tf);
   if (strength < 1) strength = 1;
   if (shift < 0) shift = 0;
   if (bars <= shift + (strength * 2) + 5) return false;

   int lookback = GetMSLookbackBarsForTF(tf);
   if (lookback < 20) lookback = 20;
   int firstBar = shift + strength + 1;
   int lastBar = MathMin(bars - strength - 1, shift + lookback);

   int highCount = 0;
   int lowCount = 0;

   for (int bar = firstBar; bar <= lastBar; bar++)
   {
      if (highCount < 1 && IsStructureSwingHigh(tf, bar, strength))
      {
         swingHigh = iHigh(Symbol(), tf, bar);
         highCount = 1;
      }
      if (lowCount < 1 && IsStructureSwingLow(tf, bar, strength))
      {
         swingLow = iLow(Symbol(), tf, bar);
         lowCount = 1;
      }
      if (highCount >= 1 && lowCount >= 1) break;
   }

   if (highCount < 1 && lowCount < 1) return false;

   double atr = iATR(Symbol(), tf, 14, shift);
   if (atr <= 0) atr = Point;
   double bosBuffer = atr * MathMax(0.0, GetMSBOSBufferATRForTF(tf));
   double closePrice = iClose(Symbol(), tf, shift);

   if (highCount >= 1 && closePrice > swingHigh + bosBuffer)
   {
      dir = 1;
      bosLevel = swingHigh;
      return true;
   }
   if (lowCount >= 1 && closePrice < swingLow - bosBuffer)
   {
      dir = -1;
      bosLevel = swingLow;
      return true;
   }
   // === FALLBACK: OPEN BAR DETECTION (samo ako eksplicitno se bara LIVE shift=0) ===
   // Vazno: ne smee da se koristi koga caller bara shift=1 (zatvoren bar), bidejki
   // toa pravi prerani BOS signali od tekoven tick i go kreva brojot na fake breakouts.
   if (dir == 0 && shift == 0)
   {
      double liveBid = (Symbol() == "" || Bid <= 0) ? iClose(Symbol(), tf, 0) : Bid;
      double liveAsk = (Symbol() == "" || Ask <= 0) ? liveBid + Point*10 : Ask;
      if (highCount >= 1 && liveAsk > swingHigh + bosBuffer)
      {
         dir = 1;
         bosLevel = swingHigh;
         return true;
      }
      if (lowCount >= 1 && liveBid < swingLow - bosBuffer)
      {
         dir = -1;
         bosLevel = swingLow;
         return true;
      }
   }
   return true;
}

bool GetPreviousBOSLevel(int tf, int shift, int dir, double &prevBosLevel)
{
   prevBosLevel = 0.0;
   if (dir == 0) return false;

   int bars = iBars(Symbol(), tf);
   int strength = GetMSSwingStrengthForTF(tf);
   if (strength < 1) strength = 1;
   if (shift < 0) shift = 0;
   if (bars <= shift + (strength * 2) + 5) return false;

   int lookback = GetMSLookbackBarsForTF(tf);
   if (lookback < 20) lookback = 20;
   int firstBar = shift + strength + 1;
   int lastBar = MathMin(bars - strength - 1, shift + lookback);

   int found = 0;
   for (int bar = firstBar; bar <= lastBar; bar++)
   {
      if (dir == 1)
      {
         if (IsStructureSwingHigh(tf, bar, strength))
         {
            found++;
            if (found == 2)
            {
               prevBosLevel = iHigh(Symbol(), tf, bar);
               return true;
            }
         }
      }
      else if (dir == -1)
      {
         if (IsStructureSwingLow(tf, bar, strength))
         {
            found++;
            if (found == 2)
            {
               prevBosLevel = iLow(Symbol(), tf, bar);
               return true;
            }
         }
      }
   }
   return false;
}

bool GetMarketStructureStrength(int tf, int shift, string &strengthText, color &strengthColor,
                                double &distanceATR, int &barsSinceBOS)
{
   strengthText = "Neutral";
   strengthColor = clrSilver;
   distanceATR = 0.0;
   barsSinceBOS = -1;

   int dir = 0;
   double bosLevel = 0.0;
   double swingHigh = 0.0;
   double swingLow = 0.0;
   if (!GetMarketStructureBOSLevels(tf, shift, dir, bosLevel, swingHigh, swingLow))
      return false;

   if (dir == 0 || bosLevel <= 0.0)
      return true;

   int bars = iBars(Symbol(), tf);
   if (bars <= shift + 5) return true;

   double atr = iATR(Symbol(), tf, 14, shift);
   if (atr <= 0.0) atr = Point;
   double bosBuffer = atr * MathMax(0.0, GetMSBOSBufferATRForTF(tf));
   double closePrice = iClose(Symbol(), tf, shift);
   distanceATR = MathAbs(closePrice - bosLevel) / atr;

   int lookback = GetMSLookbackBarsForTF(tf);
   if (lookback < 20) lookback = 20;
   int lastBar = MathMin(bars - 1, shift + lookback);

   for (int bar = shift; bar <= lastBar; bar++)
   {
      double barClose = iClose(Symbol(), tf, bar);
      if ((dir == 1 && barClose > bosLevel + bosBuffer) ||
          (dir == -1 && barClose < bosLevel - bosBuffer))
      {
         barsSinceBOS = bar - shift;
         break;
      }
   }

   double score = distanceATR;
   if (barsSinceBOS >= 0)
   {
      if (barsSinceBOS <= 2) score += 0.80;
      else if (barsSinceBOS <= 5) score += 0.55;
      else if (barsSinceBOS <= 10) score += 0.30;
      else if (barsSinceBOS <= 20) score += 0.10;
   }

   if (score >= 1.20)
   {
      strengthText = "Strong";
      strengthColor = (dir == 1) ? clrLime : clrRed;
   }
   else if (score >= 0.70)
   {
      strengthText = "Healthy";
      strengthColor = (dir == 1) ? clrLimeGreen : clrTomato;
   }
   else if (score >= 0.30)
   {
      strengthText = "Weakening";
      strengthColor = clrOrange;
   }
   else
   {
      strengthText = "Fragile";
      strengthColor = clrOrangeRed;
   }

   return true;
}

bool PassMarketStructureTrendGate(ZoneInfo &zone, int tf)
{
   if (!Use_MarketStructureTrendGate) return true;

   int structureTF = GetHigherTimeframe(tf);
   int shift = 1;
   if (zone.breakoutTime > 0)
   {
      int mappedShift = iBarShift(Symbol(), structureTF, zone.breakoutTime, true);
      if (mappedShift >= 0) shift = mappedShift;
   }
   int trend = GetMarketTrendBOSOnly(structureTF, shift);
   bool aligned = ((zone.zoneType == "Bull" && trend == 1) ||
                   (zone.zoneType == "Bear" && trend == -1));

   if (!aligned && DebugMode)
   {
      string structure = (trend == 1) ? "Bullish (BOS)" : ((trend == -1) ? "Bearish (BOS)" : "Neutral");
      Print("MarketStructure reject: ", zone.zoneType,
            " zone requires aligned HTF BOS. Structure=",
            structure, " TF=", TimeframeToString(structureTF));
   }
   return aligned;
}

int GetHigherTimeframe(int tf)
{
   // POBRZ ODGOVOR: samo 1 nivo pogore (ne 2!)
   // Old: M1→M15 (skok 15x, lag), New: M1→M5→M15→H1→H4 (step by step = pobrz signal)
   if (tf == PERIOD_M1)  return PERIOD_M5;
   if (tf == PERIOD_M5)  return PERIOD_M15;
   if (tf == PERIOD_M15) return PERIOD_H1;
   if (tf == PERIOD_M30) return PERIOD_H1;
   if (tf == PERIOD_H1)  return PERIOD_H4;
   if (tf == PERIOD_H4)  return PERIOD_D1;
   if (tf == PERIOD_D1)  return PERIOD_W1;
   if (tf == PERIOD_W1)  return PERIOD_MN1;
   return PERIOD_MN1;
}

int GetConfirmTimeframe(int tf)
{
   // Confirm = tochen megju-level (Entry→Confirm→Structure)
   // Za M1: Entry=M1, Confirm=M5, Structure=GetHigher(M1)=M5 → treba da se dvizi napred 1 poveke
   if (tf == PERIOD_M1)  return PERIOD_M15;
   if (tf == PERIOD_M5)  return PERIOD_H1;
   if (tf == PERIOD_M15) return PERIOD_H4;
   if (tf == PERIOD_M30) return PERIOD_H4;
   if (tf == PERIOD_H1)  return PERIOD_D1;
   if (tf == PERIOD_H4)  return PERIOD_W1;
   if (tf == PERIOD_D1)  return PERIOD_W1;
   if (tf == PERIOD_W1)  return PERIOD_MN1;
   return PERIOD_M15;
}

int FindTFIndex(int tf)
{
   for (int k = 0; k < TF_COUNT; k++)
   {
      if (TF_List[k] == tf) return k;
   }
   return -1;
}

bool OB_IsMitigatedBar(ZoneInfo &zone, int shift)
{
   double c = iClose(Symbol(), zone.timeframe, shift);
   double h = iHigh(Symbol(), zone.timeframe, shift);
   double l = iLow(Symbol(), zone.timeframe, shift);
   double mid = (zone.top + zone.bottom) * 0.5;

   if (zone.zoneType == "Bull")
   {
      if (OB_MitigationMethod == "Close") return (c <= zone.bottom);
      if (OB_MitigationMethod == "Avg")   return (c <= mid);
      return (l <= zone.bottom);
   }
   else
   {
      if (OB_MitigationMethod == "Close") return (c >= zone.top);
      if (OB_MitigationMethod == "Avg")   return (c >= mid);
      return (h >= zone.top);
   }
}

void OB_CreateZone(int tf, bool bullish, datetime pivotTime, int breakShift)
{
   int pivotShift = iBarShift(Symbol(), tf, pivotTime, true);
   if (pivotShift < 0) return;
   if (pivotShift <= breakShift) return;

   int bars = iBars(Symbol(), tf);
   if (bars <= pivotShift + 1) return;

   double atrMeasureBreak = iATR(Symbol(), tf, 200, breakShift);
   if (atrMeasureBreak <= 0) atrMeasureBreak = iATR(Symbol(), tf, 14, breakShift);
   if (atrMeasureBreak <= 0) return;

   if (OB_FilterWeakBreakouts)
   {
      double hi = iHigh(Symbol(), tf, breakShift);
      double lo = iLow(Symbol(), tf, breakShift);
      double op = iOpen(Symbol(), tf, breakShift);
      double cl = iClose(Symbol(), tf, breakShift);
      double range = hi - lo;
      if (range <= 0) return;
      double body = MathAbs(cl - op);

      if (body < atrMeasureBreak * OB_MinDisplacementATR) return;
      if ((body / range) < OB_MinBodyRatio) return;

      if (bullish)
      {
         double closeStrength = (cl - lo) / range;
         if (closeStrength < OB_MinCloseStrength) return;
      }
      else
      {
         double closeStrength = (hi - cl) / range;
         if (closeStrength < OB_MinCloseStrength) return;
      }
   }

   int candidateShift = -1;
   for (int s = breakShift + 1; s <= pivotShift && s < bars; s++)
   {
      double o = iOpen(Symbol(), tf, s);
      double c = iClose(Symbol(), tf, s);
      if (bullish && c < o) { candidateShift = s; break; }
      if (!bullish && c > o) { candidateShift = s; break; }
   }
   if (candidateShift < 0) return;

   int obShift = candidateShift;

   double atrMeasure = iATR(Symbol(), tf, 200, obShift);
   if (atrMeasure <= 0) atrMeasure = iATR(Symbol(), tf, 14, obShift);
   if (atrMeasure <= 0) return;

   double obHigh, obLow;
   if (OB_UseBody)
   {
      double o = iOpen(Symbol(), tf, obShift);
      double c = iClose(Symbol(), tf, obShift);
      obHigh = MathMax(o, c);
      obLow  = MathMin(o, c);
   }
   else
   {
      double hi = iHigh(Symbol(), tf, obShift);
      double lo = iLow(Symbol(), tf, obShift);
      bool highVol = (hi - lo) >= (2.0 * atrMeasure);
      double parsedHigh = highVol ? lo : hi;
      double parsedLow  = highVol ? hi : lo;
      obHigh = parsedHigh;
      obLow  = parsedLow;
   }

   double obTopRaw = MathMax(obHigh, obLow);
   double obBotRaw = MathMin(obHigh, obLow);
   double obHeight = obTopRaw - obBotRaw;
   if (obHeight < Point) obHeight = Point;

   if (OB_MinZoneHeightATR > 0 && obHeight < atrMeasure * OB_MinZoneHeightATR) return;
   if (OB_MaxZoneHeightATR > 0 && obHeight > atrMeasure * OB_MaxZoneHeightATR) return;

   double tighten = obHeight * OB_TightenPct;
   double drawTop = obTopRaw - tighten;
   double drawBot = obBotRaw + tighten;
   if (drawTop - drawBot < Point) return;

   if (OB_SideFilter && OB_SideToleranceATR > 0)
   {
      double refClose = iClose(Symbol(), tf, breakShift);
      double tol = atrMeasureBreak * OB_SideToleranceATR;
      if (tol < Point) tol = Point;
      if (bullish)
      {
         if (drawTop > (refClose + tol)) return;
      }
      else
      {
         if (drawBot < (refClose - tol)) return;
      }
   }

   if (OB_OppositeGapFilter && OB_OppositeGapATR > 0)
   {
      double minGapOpp = atrMeasureBreak * OB_OppositeGapATR;
      if (minGapOpp < Point) minGapOpp = Point;
      if (bullish)
      {
         for (int i = 0; i < totalBearZones; i++)
         {
            if (BearishZones[i].timeframe != tf) continue;
            double top2 = BearishZones[i].top;
            double bot2 = BearishZones[i].bottom;
            double gap;
            if (drawTop <= bot2) gap = bot2 - drawTop;
            else if (top2 <= drawBot) gap = drawBot - top2;
            else gap = 0.0;
            if (gap < minGapOpp) return;
         }
      }
      else
      {
         for (int i = 0; i < totalBullZones; i++)
         {
            if (BullishZones[i].timeframe != tf) continue;
            double top2 = BullishZones[i].top;
            double bot2 = BullishZones[i].bottom;
            double gap;
            if (drawTop <= bot2) gap = bot2 - drawTop;
            else if (top2 <= drawBot) gap = drawBot - top2;
            else gap = 0.0;
            if (gap < minGapOpp) return;
         }
      }
   }

   if (OB_MinGapFilter && OB_MinGapATR > 0)
   {
      double atrGap = iATR(Symbol(), tf, 14, obShift);
      if (atrGap > atrMeasure) atrMeasure = atrGap;
      double minGap = atrMeasure * OB_MinGapATR;
      if (minGap < Point) minGap = Point;
      double mid1 = (drawTop + drawBot) * 0.5;

      if (bullish)
      {
         for (int i = 0; i < totalBullZones; i++)
         {
            if (BullishZones[i].timeframe != tf) continue;
            double top2 = BullishZones[i].top;
            double bot2 = BullishZones[i].bottom;
            double mid2 = (top2 + bot2) * 0.5;

            double gap;
            if (drawTop <= bot2) gap = bot2 - drawTop;
            else if (top2 <= drawBot) gap = drawBot - top2;
            else gap = 0.0;

            if (gap < minGap) return;
            if (MathAbs(mid1 - mid2) < minGap) return;
         }
      }
      else
      {
         for (int i = 0; i < totalBearZones; i++)
         {
            if (BearishZones[i].timeframe != tf) continue;
            double top2 = BearishZones[i].top;
            double bot2 = BearishZones[i].bottom;
            double mid2 = (top2 + bot2) * 0.5;

            double gap;
            if (drawTop <= bot2) gap = bot2 - drawTop;
            else if (top2 <= drawBot) gap = drawBot - top2;
            else gap = 0.0;

            if (gap < minGap) return;
            if (MathAbs(mid1 - mid2) < minGap) return;
         }
      }
   }

   ZoneInfo zone;
   zone.zoneType = bullish ? "Bull" : "Bear";
   zone.timeframe = tf;
   zone.top = drawTop;
   zone.bottom = drawBot;
   if (zone.top < zone.bottom)
   {
      double t = zone.top;
      zone.top = zone.bottom;
      zone.bottom = t;
   }
   // Extend zone edge to cover neighbor candle wicks so a slightly
   // longer adjacent wick doesn't falsely break the zone
   if (Zone_ExtendToNeighborWicks && atrMeasure > 0)
   {
      // Only closed bars that already existed when the breakout happened, so the
      // zone edges are identical in the history scan and in live detection.
      int nFrom = MathMax(breakShift, obShift - Zone_NeighborWickBars);
      int nTo   = MathMin(bars - 1, obShift + Zone_NeighborWickBars);
      // Zone_MaxWickExtendATR <= 0 means no cap: the edge covers the whole wick
      double maxExtend = (Zone_MaxWickExtendATR > 0) ? (atrMeasure * Zone_MaxWickExtendATR)
                                                     : DBL_MAX;
      if (bullish)
      {
         double wickLow = zone.bottom;
         for (int i = nFrom; i <= nTo; i++)
         {
            double l = iLow(Symbol(), tf, i);
            if (l < wickLow) wickLow = l;
         }
         if (zone.bottom - wickLow > maxExtend) wickLow = zone.bottom - maxExtend;
         zone.bottom = wickLow;
      }
      else
      {
         double wickHigh = zone.top;
         for (int i = nFrom; i <= nTo; i++)
         {
            double h = iHigh(Symbol(), tf, i);
            if (h > wickHigh) wickHigh = h;
         }
         if (wickHigh - zone.top > maxExtend) wickHigh = zone.top + maxExtend;
         zone.top = wickHigh;
      }
   }
   
   zone.entryPrice = bullish ? zone.top : zone.bottom;
   zone.startTime = iTime(Symbol(), tf, obShift);
   zone.breakoutBar = breakShift;
   zone.breakoutTime = iTime(Symbol(), tf, breakShift);
   zone.baseStartBar = pivotShift;
   zone.baseEndBar = obShift;

   double slBuf = SL_Buffer_Points * Point;
   // Anchored to the FINAL zone edges (after wick extension / tighten) so the order
   // and the SL line drawn on the zone are the same level
   zone.stopLoss = bullish ? (zone.bottom - slBuf) : (zone.top + slBuf);
   zone.takeProfit = bullish ? (zone.entryPrice + ((zone.entryPrice - zone.stopLoss) * Risk_Reward_Ratio))
                             : (zone.entryPrice - ((zone.stopLoss - zone.entryPrice) * Risk_Reward_Ratio));

   if (g_zoneIdCounter > 2000000000) g_zoneIdCounter = 1;
   zone.uniqueID = g_zoneIdCounter++;
   zone.fingerprint = StringFormat("%d_%.5f_%.5f_%s", tf, zone.bottom, zone.top, TimeToString(zone.startTime));

   // Identical zone already on the chart (re-detected by a resync pass): skip it
   if (bullish)
   {
      for (int fp = 0; fp < totalBullZones; fp++)
      {
         if (BullishZones[fp].timeframe != tf) continue;
         EnsureZoneFingerprint(BullishZones[fp]);
         if (BullishZones[fp].fingerprint == zone.fingerprint) return;
      }
   }
   else
   {
      for (int fp = 0; fp < totalBearZones; fp++)
      {
         if (BearishZones[fp].timeframe != tf) continue;
         EnsureZoneFingerprint(BearishZones[fp]);
         if (BearishZones[fp].fingerprint == zone.fingerprint) return;
      }
   }

   zone.slName     = "TraceInst_SL_" + IntegerToString(zone.uniqueID);
   zone.tpName     = "TraceInst_TP_" + IntegerToString(zone.uniqueID);
   zone.slTextName = "TraceInst_SL_Txt_" + IntegerToString(zone.uniqueID);
   zone.tpTextName = "TraceInst_TP_Txt_" + IntegerToString(zone.uniqueID);

   zone.breaker  = false;
   zone.tpHit    = false;
   zone.slHit    = false;
   zone.hitTime  = 0;
   zone.touches  = 0;
   zone.isTraded = false;
   zone.relativeVolume = 0;
   zone.bosStrength = 0.0;
   zone.bosConfirmed = false;

   double avgVol = GetAverageVolume(tf, Volume_Lookback_Period, obShift + 1);
   if (avgVol > 0) zone.relativeVolume = (double)iVolume(Symbol(), tf, obShift) / avgVol;

   if (!PassMarketStructureTrendGate(zone, tf)) return;

   zone.bosStrength = GetBOSStrengthScore(zone, tf);
   zone.bosConfirmed = (zone.bosStrength > 0.0);
   zone.strength = CalculateZoneScore(zone);
   zone.isElite = zone.strength >= 8.0;

   bool inheritedTraded = false;
   int overlapBullIdx[];
   int overlapBearIdx[];
   int overlapBullCount = 0;
   int overlapBearCount = 0;
   if (OB_HideOverlap)
   {
      double tol = Point * 10;
      if (bullish)
      {
         for (int i = totalBullZones - 1; i >= 0; i--)
         {
            if (BullishZones[i].timeframe != tf) continue;
            double top2 = BullishZones[i].top;
            double bot2 = BullishZones[i].bottom;
            double gap;
            if (zone.top <= bot2) gap = bot2 - zone.top;
            else if (top2 <= zone.bottom) gap = zone.bottom - top2;
            else gap = 0.0;

            bool overlapsOrClose = (gap <= tol);
            if (!overlapsOrClose) continue;
            
            if (MathAbs(zone.startTime - BullishZones[i].startTime) <= PeriodSeconds(tf) * 2 &&
                MathAbs(zone.top - top2) <= tol &&
                MathAbs(zone.bottom - bot2) <= tol)
               return;
            if (OB_WhichOverlap == "Recent")
            {
               if (BullishZones[i].isTraded) inheritedTraded = true;
               ArrayResize(overlapBullIdx, overlapBullCount + 1);
               overlapBullIdx[overlapBullCount] = i;
               overlapBullCount++;
            }
            else
            {
               return;
            }
         }
      }
      else
      {
         for (int i = totalBearZones - 1; i >= 0; i--)
         {
            if (BearishZones[i].timeframe != tf) continue;
            double top2 = BearishZones[i].top;
            double bot2 = BearishZones[i].bottom;
            double gap;
            if (zone.top <= bot2) gap = bot2 - zone.top;
            else if (top2 <= zone.bottom) gap = zone.bottom - top2;
            else gap = 0.0;

            bool overlapsOrClose = (gap <= tol);
            if (!overlapsOrClose) continue;
            
            if (MathAbs(zone.startTime - BearishZones[i].startTime) <= PeriodSeconds(tf) * 2 &&
                MathAbs(zone.top - top2) <= tol &&
                MathAbs(zone.bottom - bot2) <= tol)
               return;
            if (OB_WhichOverlap == "Recent")
            {
               if (BearishZones[i].isTraded) inheritedTraded = true;
               ArrayResize(overlapBearIdx, overlapBearCount + 1);
               overlapBearIdx[overlapBearCount] = i;
               overlapBearCount++;
            }
            else
            {
               return;
            }
         }
      }
   }
   if (inheritedTraded) zone.isTraded = true;

   if (g_isScanningHistory)
   {
      int breakBar = zone.breakoutBar;
      if (breakBar > 0)
      {
         for (int i = breakBar - 1; i >= 0; i--)
         {
            if (OB_IsMitigatedBar(zone, i))
            {
               zone.breaker = true;
               zone.hitTime = iTime(Symbol(), tf, i);
               break;
            }
         }
      }
   }
   
   // Apply zone quality filters in StrictMode (score -100 = hard reject)
   double scoreLS_ob = GetLiquiditySweepScore(zone, tf);
   if (scoreLS_ob < -50.0) return;
   if (Sweep_StrictMode && scoreLS_ob > 0 && scoreLS_ob < Sweep_MinScore) return;
   if (GetRVScore(zone, tf) < -50.0) return;
   if (GetMSSScore(zone, tf) < -50.0) return;

   // Full Anti-Fake filter chain (Consolidation, StrongBreakout, HTF, FVG,
   // Choppiness, Efficiency, Exhaustion, etc.) applied to Order-Block zones too.
   // NOW-filters are auto-skipped during history scanning inside the function.
   // (Regime filter is now included inside PassAntiFakeZoneFilter's soft score)
   if (OB_ApplyAntiFakeFilter && !PassAntiFakeZoneFilter(zone, tf))
   {
      if (DebugMode) Print("OB zone rejected by Anti-Fake filter. TF=", TimeframeToString(tf));
      return;
   }

   // A zone found by the periodic resync replay whose breakout is still fresh is a
   // live zone that the pivot tracker missed, not history
   bool resyncLive = g_isScanningHistory && g_obScanLookbackOverride > 0 &&
                     Zone_ResyncTradeMaxBars > 0 && breakShift <= Zone_ResyncTradeMaxBars;
   bool liveZone = !g_isScanningHistory || resyncLive;

   if (bullish)
   {
      if (overlapBullCount > 0)
      {
         if (DebugMode) Print("OB bullish overlap replace: ", overlapBullCount,
                              " zones by new zone ", zone.uniqueID);
         // Indices were collected while walking the array backwards, so they are
         // already in descending order: removing them in that order keeps the
         // remaining indices valid.
         for (int oi = 0; oi < overlapBullCount; oi++)
         {
            int removeIdx = overlapBullIdx[oi];
            if (removeIdx < 0 || removeIdx >= totalBullZones) continue;
            DeleteZoneVisuals(BullishZones[removeIdx]);
            RemoveBullZoneAt(removeIdx);
         }
      }
      ArrayResize(BullishZones, totalBullZones + 1);
      BullishZones[totalBullZones] = zone;
      totalBullZones++;
      EnsureZoneFingerprint(BullishZones[totalBullZones - 1]);
      bool firstDetection = RememberSeenZoneFingerprint(
                               BullishZones[totalBullZones - 1].fingerprint);
      if (OB_LastCount > 0 && CountBullZonesForTF(tf) > OB_LastCount) RemoveOldestZone(tf, "Bull");
      int acceptedIndex = -1;
      for (int i = 0; i < totalBullZones; i++)
      {
         if (BullishZones[i].uniqueID == zone.uniqueID)
         {
            acceptedIndex = i;
            break;
         }
      }
      if (acceptedIndex < 0)
      {
         Print("OB bullish zone ", zone.uniqueID,
               " was removed by pruning before entry; ImmediateEntry skipped");
         return;
      }
      Print("OB bullish zone accepted for display/entry: zone ",
            BullishZones[acceptedIndex].uniqueID,
            " fingerprint=", BullishZones[acceptedIndex].fingerprint,
            " firstDetection=", firstDetection,
            " resyncLive=", resyncLive,
            " Use_ImmediateEntry=", Use_ImmediateEntry);
      if (liveZone)
         NotifyNewZone(BullishZones[acceptedIndex], resyncLive);
      g_obResyncLiveZone = resyncLive;
      if (Use_ImmediateEntry)
         ImmediateEntry(BullishZones[acceptedIndex], firstDetection);
      else
      {
         if (AutoTrade_OnNewZone)
            AttemptAutoTrade(BullishZones[acceptedIndex], 0);
         PlaceZonePending(BullishZones[acceptedIndex]);
      }
      g_obResyncLiveZone = false;
   }
   else
   {
      if (overlapBearCount > 0)
      {
         if (DebugMode) Print("OB bearish overlap replace: ", overlapBearCount,
                              " zones by new zone ", zone.uniqueID);
         // Same descending-order removal as the bullish path above.
         for (int oi = 0; oi < overlapBearCount; oi++)
         {
            int removeIdx = overlapBearIdx[oi];
            if (removeIdx < 0 || removeIdx >= totalBearZones) continue;
            DeleteZoneVisuals(BearishZones[removeIdx]);
            RemoveBearZoneAt(removeIdx);
         }
      }
      ArrayResize(BearishZones, totalBearZones + 1);
      BearishZones[totalBearZones] = zone;
      totalBearZones++;
      EnsureZoneFingerprint(BearishZones[totalBearZones - 1]);
      bool firstDetection = RememberSeenZoneFingerprint(
                               BearishZones[totalBearZones - 1].fingerprint);
      if (OB_LastCount > 0 && CountBearZonesForTF(tf) > OB_LastCount) RemoveOldestZone(tf, "Bear");
      int acceptedIndex = -1;
      for (int i = 0; i < totalBearZones; i++)
      {
         if (BearishZones[i].uniqueID == zone.uniqueID)
         {
            acceptedIndex = i;
            break;
         }
      }
      if (acceptedIndex < 0)
      {
         Print("OB bearish zone ", zone.uniqueID,
               " was removed by pruning before entry; ImmediateEntry skipped");
         return;
      }
      Print("OB bearish zone accepted for display/entry: zone ",
            BearishZones[acceptedIndex].uniqueID,
            " fingerprint=", BearishZones[acceptedIndex].fingerprint,
            " firstDetection=", firstDetection,
            " resyncLive=", resyncLive,
            " Use_ImmediateEntry=", Use_ImmediateEntry);
      if (liveZone)
         NotifyNewZone(BearishZones[acceptedIndex], resyncLive);
      g_obResyncLiveZone = resyncLive;
      if (Use_ImmediateEntry)
         ImmediateEntry(BearishZones[acceptedIndex], firstDetection);
      else
      {
         if (AutoTrade_OnNewZone)
            AttemptAutoTrade(BearishZones[acceptedIndex], 0);
         PlaceZonePending(BearishZones[acceptedIndex]);
      }
      g_obResyncLiveZone = false;
   }
}

void OB_UpdatePivotsLive(int tf, int tfIndex)
{
   int len = OB_PivotLen;
   if (len < 1) len = 1;
   int center = len + 1;
   int bars = iBars(Symbol(), tf);
   if (bars <= (2 * len + 3)) return;

   double maxHigh = -DBL_MAX;
   double minLow  = DBL_MAX;
   for (int s = 1; s <= 2 * len + 1; s++)
   {
      double h = iHigh(Symbol(), tf, s);
      double l = iLow(Symbol(), tf, s);
      if (h > maxHigh) maxHigh = h;
      if (l < minLow)  minLow  = l;
   }

   datetime centerTime = iTime(Symbol(), tf, center);
   if (centerTime == 0) return;

   double centerHigh = iHigh(Symbol(), tf, center);
   if (centerHigh >= (maxHigh - Point * 0.1))
   {
      if (centerTime != g_obSwingHighTime[tfIndex])
      {
         g_obSwingHighTime[tfIndex] = centerTime;
         g_obSwingHighLevel[tfIndex] = centerHigh;
         g_obSwingHighCrossed[tfIndex] = false;
      }
   }

   double centerLow = iLow(Symbol(), tf, center);
   if (centerLow <= (minLow + Point * 0.1))
   {
      if (centerTime != g_obSwingLowTime[tfIndex])
      {
         g_obSwingLowTime[tfIndex] = centerTime;
         g_obSwingLowLevel[tfIndex] = centerLow;
         g_obSwingLowCrossed[tfIndex] = false;
      }
   }
}

void OB_CheckBreakoutsLive(int tf, int tfIndex)
{
   if (g_obSwingHighTime[tfIndex] > 0 && !g_obSwingHighCrossed[tfIndex])
   {
      double lvl = g_obSwingHighLevel[tfIndex];
      double c1 = iClose(Symbol(), tf, 1);
      double c2 = iClose(Symbol(), tf, 2);
      if (c1 > lvl && c2 <= lvl)
      {
         OB_CreateZone(tf, true, g_obSwingHighTime[tfIndex], 1);
         g_obSwingHighCrossed[tfIndex] = true;
      }
   }

   if (g_obSwingLowTime[tfIndex] > 0 && !g_obSwingLowCrossed[tfIndex])
   {
      double lvl = g_obSwingLowLevel[tfIndex];
      double c1 = iClose(Symbol(), tf, 1);
      double c2 = iClose(Symbol(), tf, 2);
      if (c1 < lvl && c2 >= lvl)
      {
         OB_CreateZone(tf, false, g_obSwingLowTime[tfIndex], 1);
         g_obSwingLowCrossed[tfIndex] = true;
      }
   }
}

void OB_ScanLookback(int tf, int tfIndex)
{
   int bars = iBars(Symbol(), tf);
   int len = OB_PivotLen;
   if (len < 1) len = 1;
   int needed = 2 * len + 5;
   if (bars <= needed + 5) return;

   int maxLookback = (g_obScanLookbackOverride > 0) ? g_obScanLookbackOverride : OB_LookbackBars;
   if (maxLookback < 50) maxLookback = 50;
   if (maxLookback > bars - needed) maxLookback = bars - needed;
   if (maxLookback < needed) return;

   double swingHigh = 0.0;
   double swingLow  = 0.0;
   datetime swingHighTime = 0;
   datetime swingLowTime  = 0;
   bool swingHighCrossed = false;
   bool swingLowCrossed  = false;

   for (int curShift = maxLookback; curShift >= 2; curShift--)
   {
      int center = curShift + len + 1;
      if (center + len >= bars) continue;

      double maxHigh = -DBL_MAX;
      double minLow  = DBL_MAX;
      for (int s = curShift + 1; s <= curShift + 2 * len + 1; s++)
      {
         double h = iHigh(Symbol(), tf, s);
         double l = iLow(Symbol(), tf, s);
         if (h > maxHigh) maxHigh = h;
         if (l < minLow)  minLow  = l;
      }

      datetime centerTime = iTime(Symbol(), tf, center);
      if (centerTime != 0)
      {
         double centerHigh = iHigh(Symbol(), tf, center);
         if (centerHigh >= (maxHigh - Point * 0.1))
         {
            if (centerTime != swingHighTime)
            {
               swingHighTime = centerTime;
               swingHigh = centerHigh;
               swingHighCrossed = false;
            }
         }

         double centerLow = iLow(Symbol(), tf, center);
         if (centerLow <= (minLow + Point * 0.1))
         {
            if (centerTime != swingLowTime)
            {
               swingLowTime = centerTime;
               swingLow = centerLow;
               swingLowCrossed = false;
            }
         }
      }

      double closeCur = iClose(Symbol(), tf, curShift);
      double closePrev = iClose(Symbol(), tf, curShift + 1);

      if (swingHighTime > 0 && !swingHighCrossed && closeCur > swingHigh && closePrev <= swingHigh)
      {
         OB_CreateZone(tf, true, swingHighTime, curShift);
         swingHighCrossed = true;
      }

      if (swingLowTime > 0 && !swingLowCrossed && closeCur < swingLow && closePrev >= swingLow)
      {
         OB_CreateZone(tf, false, swingLowTime, curShift);
         swingLowCrossed = true;
      }
   }

   g_obSwingHighLevel[tfIndex] = swingHigh;
   g_obSwingLowLevel[tfIndex] = swingLow;
   g_obSwingHighTime[tfIndex] = swingHighTime;
   g_obSwingLowTime[tfIndex] = swingLowTime;
   g_obSwingHighCrossed[tfIndex] = swingHighCrossed;
   g_obSwingLowCrossed[tfIndex] = swingLowCrossed;
}

//+------------------------------------------------------------------+
//| Periodic replay of the recent bars, same code path as the init    |
//| history scan. Live pivot tracking keeps only one swing per side   |
//| and only inspects the bar at shift OB_PivotLen+1, so a stall of   |
//| the terminal (or a filter that only rejects in live mode) makes a |
//| zone disappear until the EA is reloaded. The replay re-detects    |
//| those zones automatically; duplicates are dropped by fingerprint  |
//| and no trade is opened because g_isScanningHistory is set.        |
//+------------------------------------------------------------------+
void OB_ResyncZones()
{
   if (!Zone_AutoResync) return;
   if (!Use_OrderBlocks) return;
   if (IsTesting() || IsOptimization()) return;

   static datetime lastResync = 0;
   datetime now = TimeLocal();
   int period = Zone_ResyncMinutes * 60;
   if (period < 60) period = 60;
   if (lastResync > 0 && (now - lastResync) < period) return;
   lastResync = now;

   // Stay inside the expiry window so a zone is not re-added and pruned in a loop
   int lookback = OB_LookbackBars;
   if (Zone_ExpiryBars > 0 && lookback > Zone_ExpiryBars - 50)
      lookback = Zone_ExpiryBars - 50;
   if (lookback < 50) lookback = 50;

   for (int k = 0; k < TF_COUNT; k++)
   {
      int tf = TF_List[k];
      if (Draw_CurrentChartTFOnly && tf != Period()) continue;
      if (!g_histScanned[k]) continue;
      if (iBars(Symbol(), tf) < 350) continue;
      double atr = iATR(Symbol(), tf, 60, 1);
      if (atr <= 0) continue;

      g_isScanningHistory = true;
      g_obScanLookbackOverride = lookback;
      OB_ScanLookback(tf, k);
      g_obScanLookbackOverride = 0;
      g_isScanningHistory = false;

      if (DebugMode)
         Print("OB resync replayed ", lookback, " bars on TF ", TimeframeToString(tf));
   }
}

bool IsDemandZone_Live(int tf, int shift)
{
    int bars = iBars(Symbol(), tf);
    if (shift < 1 || shift + 2 >= bars) return false;
    double atr = iATR(Symbol(), tf, 120, shift);
    if (atr <= 0) return false;
    double hi = iHigh(Symbol(), tf, shift);
    double lo = iLow(Symbol(), tf, shift);
    double op = iOpen(Symbol(), tf, shift);
    double cl = iClose(Symbol(), tf, shift);
    double range = hi - lo;
    double body  = cl - op;
    if (cl <= op || range <= 0) return false;
    double pip = (Digits == 1 || Digits == 3) ? Point * 10 : Point;
    double edgeEps = pip * 0.05;
    int trend = GetMarketTrend(tf, shift);
    if (Use_MarketStructureTrendGate && trend != 1) return false;
    double bodyRatio;
    double atrMult;
    
    if (Use_Extreme_HighLow)
    {
        int lowestIndex = iLowest(Symbol(), tf, MODE_LOW, Extreme_Lookback, shift);
        double lowestVal = iLow(Symbol(), tf, lowestIndex);
        
        if (lo > lowestVal + (iATR(Symbol(), tf, ATR_Period_Strength, shift) * 8.0)) return false;
    }
    
    if (Filter_BigCandle_Rejection)
    {
        double currentLen = (Include_Wicks) ? (hi - lo) : MathAbs(op - cl);
        if (currentLen < atr * BigCandle_ATR_Factor) return false;
    }
    
    if (tf == PERIOD_M15)
    {
        bodyRatio = (trend == -1) ? 0.55 : MathMax(Buy_MinBodyRatio, 0.55); 
        atrMult   = 0.20;
    }
    else
    {
        bodyRatio = (trend == 1) ? MathMax(Buy_MinBodyRatio, 0.55) : (Buy_MinBodyRatio + 0.15);
        atrMult   = (trend == 1) ? 0.30 : 0.45; 
    }
    if (cl < lo + (range * 0.70)) return false;
    if (body < range * bodyRatio || range < atr * atrMult) return false;
    double avgPrevBody = 0;
    for(int k=1; k<=3; k++) avgPrevBody += MathAbs(iOpen(Symbol(), tf, shift+k) - iClose(Symbol(), tf, shift+k));
    avgPrevBody /= 3.0;
    if (avgPrevBody > 0 && body < avgPrevBody * 1.1) return false;
    double prevBody = MathAbs(iOpen(Symbol(), tf, shift + 1) - iClose(Symbol(), tf, shift + 1));
    double prevRange = iHigh(Symbol(), tf, shift + 1) - iLow(Symbol(), tf, shift + 1);
    double breakoutStrength = (atr > 0) ? (range / atr) : 0;
    double allowedPrevBodyRatio = (breakoutStrength > 1.5) ? 0.95 : 0.6;
    bool isPinbar = (prevBody < prevRange * 0.3) && 
                    ((iClose(Symbol(), tf, shift+1) > iLow(Symbol(), tf, shift+1) + prevRange * 0.6) ||
                     (iOpen(Symbol(), tf, shift+1) > iLow(Symbol(), tf, shift+1) + prevRange * 0.6));
    if (!isPinbar && prevBody > range * allowedPrevBodyRatio) return false; 
    if (prevRange > range * 2.5) return false; 
    int    confirmBars = 0;
    double totalRise   = 0.0;
    for (int f = shift - 1; f >= 0 && f >= shift - 3; f--)
    {
        if (iClose(Symbol(), tf, f) > iOpen(Symbol(), tf, f))
        {
            confirmBars++;
            totalRise += (iClose(Symbol(), tf, f) - iOpen(Symbol(), tf, f));
        }
    }
    double minRiseMult = (tf == PERIOD_M15) ? 1.2 : 1.8; 
    if (confirmBars < 2 || totalRise < atr * minRiseMult) return false;
    double recentHigh = -DBL_MAX;
    for(int k=shift+1; k<=shift+2 && k<bars; k++) recentHigh = MathMax(recentHigh, iHigh(Symbol(), tf, k));
    if (iClose(Symbol(), tf, shift) <= recentHigh) return false;
    int boBar = shift - 1;
    if (boBar >= 0)
    {
       double boBody = iClose(Symbol(), tf, boBar) - iOpen(Symbol(), tf, boBar);
       double boRange = iHigh(Symbol(), tf, boBar) - iLow(Symbol(), tf, boBar);
       if (boBody <= 0 || boBody < boRange * 0.50) return false;
       double upperWick = iHigh(Symbol(), tf, boBar) - iClose(Symbol(), tf, boBar);
       if (upperWick > boBody * 0.5) return false;
    }
    int from = MathMax(0, shift - 2);
    int to   = MathMin(bars - 1, shift + 2);
    double maxHigh = -DBL_MAX;
    for (int k = from; k <= to; k++)
    {
        double h = iHigh(Symbol(), tf, k);
        if (h > maxHigh) maxHigh = h;
    }
    if (tf != PERIOD_M15 && hi >= maxHigh - atr * 0.1)
        return false;
    for (int k = 1; k <= 2; k++)
    {
       int nextBar = shift - k;
       if (nextBar < 0) break;
       double nextClose = iClose(Symbol(), tf, nextBar);
       if (nextClose < lo - (atr * 0.2)) 
          return false;
    }
    return true;
}

bool IsSupplyZone_Live(int tf, int shift)
{
    int bars = iBars(Symbol(), tf);
    if (shift < 1 || shift + 2 >= bars) return false;
    double atr = iATR(Symbol(), tf, 120, shift);
    if (atr <= 0) return false;
    double hi = iHigh(Symbol(), tf, shift);
    double lo = iLow(Symbol(), tf, shift);
    double op = iOpen(Symbol(), tf, shift);
    double cl = iClose(Symbol(), tf, shift);
    double range = hi - lo;
    double body  = op - cl;
    if (op <= cl || range <= 0) return false;
    double pip = (Digits == 1 || Digits == 3) ? Point * 10 : Point;
    double edgeEps = pip * 0.05;
    int trend = GetMarketTrend(tf, shift);
    if (Use_MarketStructureTrendGate && trend != -1) return false;
    double bodyRatio;
    double atrMult;
    
    if (Use_Extreme_HighLow)
    {
        int highestIndex = iHighest(Symbol(), tf, MODE_HIGH, Extreme_Lookback, shift);
        double highestVal = iHigh(Symbol(), tf, highestIndex);
        
        if (hi < highestVal - (iATR(Symbol(), tf, ATR_Period_Strength, shift) * 8.0)) return false;
    }
    
    if (Filter_BigCandle_Rejection)
    {
        double currentLen = (Include_Wicks) ? (hi - lo) : MathAbs(op - cl);
        if (currentLen < atr * BigCandle_ATR_Factor) return false;
    }
    
    if (tf == PERIOD_M15)
    {
        bodyRatio = (trend == 1) ? 0.55 : MathMax(Sell_MinBodyRatio, 0.55);
        atrMult   = 0.20;
    }
    else
    {
        bodyRatio = (trend == -1) ? MathMax(Sell_MinBodyRatio, 0.55) : (Sell_MinBodyRatio + 0.15);
        atrMult   = (trend == -1) ? 0.30 : 0.45; 
    }
    if (cl > hi - (range * 0.70)) return false;
    if (body < range * bodyRatio || range < atr * atrMult) return false;
    double avgPrevBody = 0;
    for(int k=1; k<=3; k++) avgPrevBody += MathAbs(iOpen(Symbol(), tf, shift+k) - iClose(Symbol(), tf, shift+k));
    avgPrevBody /= 3.0;
    if (avgPrevBody > 0 && body < avgPrevBody * 1.1) return false;
    double prevBody = MathAbs(iOpen(Symbol(), tf, shift + 1) - iClose(Symbol(), tf, shift + 1));
    double prevRange = iHigh(Symbol(), tf, shift + 1) - iLow(Symbol(), tf, shift + 1);
    double breakoutStrength = (atr > 0) ? (range / atr) : 0;
    double allowedPrevBodyRatio = (breakoutStrength > 1.5) ? 0.95 : 0.6;
    bool isShootingStar = (prevBody < prevRange * 0.3) && 
                          ((iClose(Symbol(), tf, shift+1) < iHigh(Symbol(), tf, shift+1) - prevRange * 0.6) || 
                           (iOpen(Symbol(), tf, shift+1) < iHigh(Symbol(), tf, shift+1) - prevRange * 0.6));
    if (!isShootingStar && prevBody > range * allowedPrevBodyRatio) return false;
    if (prevRange > range * 2.5) return false;
    int    confirmBars = 0;
    double totalDrop   = 0.0;
    for (int f = shift - 1; f >= 0 && f >= shift - 3; f--)
    {
        if (iClose(Symbol(), tf, f) < iOpen(Symbol(), tf, f))
        {
            confirmBars++;
            totalDrop += (iOpen(Symbol(), tf, f) - iClose(Symbol(), tf, f));
        }
    }
    double minDropMult = (tf == PERIOD_M15) ? 1.2 : 1.8;
    if (confirmBars < 2 || totalDrop < atr * minDropMult) return false;
    double recentLow = DBL_MAX;
    for(int k=shift+1; k<=shift+2 && k<bars; k++) recentLow = MathMin(recentLow, iLow(Symbol(), tf, k));
    if (iClose(Symbol(), tf, shift) >= recentLow) return false;
    int boBar = shift - 1;
    if (boBar >= 0)
    {
       double boBody = iOpen(Symbol(), tf, boBar) - iClose(Symbol(), tf, boBar);
       double boRange = iHigh(Symbol(), tf, boBar) - iLow(Symbol(), tf, boBar);
       if (boBody <= 0 || boBody < boRange * 0.50) return false;
       double lowerWick = iClose(Symbol(), tf, boBar) - iLow(Symbol(), tf, boBar);
       if (lowerWick > boBody * 0.5) return false; 
    }
    return true;
}

//+------------------------------------------------------------------+
//| Zone creation                                                    |
//+------------------------------------------------------------------+
ZoneInfo CreateDemandZone(int tf, int shift)
{
   ZoneInfo zone;
   double atr  = iATR(Symbol(), tf, 14, shift);
   int    bars = iBars(Symbol(), tf);
   int baseStart = shift + 1;
   int baseEnd   = baseStart;
   double breakoutRange = iHigh(Symbol(), tf, shift) - iLow(Symbol(), tf, shift);
   for (int i = baseStart; i < baseStart + 4 && i < bars; i++) 
   {
      double cHigh = iHigh(Symbol(), tf, i);
      double cLow  = iLow(Symbol(), tf, i);
      double cRange = cHigh - cLow;
      double cBody = MathAbs(iOpen(Symbol(), tf, i) - iClose(Symbol(), tf, i));
      if (cBody > breakoutRange * 0.5) break;
      if (cRange > iATR(Symbol(), tf, 120, i) * 1.5) break;
      
      baseEnd = i;
   }
   double baseHigh = -DBL_MAX;
   double baseLow  = DBL_MAX;
   for (int i = baseStart; i <= baseEnd; i++)
   {
      double h = iHigh(Symbol(), tf, i);
      double l = iLow(Symbol(), tf, i);
      if (h > baseHigh) baseHigh = h;
      if (l < baseLow)  baseLow  = l;
   }
   for (int i = baseStart; i <= baseEnd; i++)
   {
      double h = iHigh(Symbol(), tf, i);
      double l = iLow(Symbol(), tf, i);
      if (h > baseHigh) baseHigh = h;
      if (l < baseLow)  baseLow  = l;
   }
   zone.zoneType = "Bull";
   zone.bottom   = baseLow;
   zone.top      = baseHigh;
   if (zone.top - zone.bottom < Point) zone.top = zone.bottom + Point;
   double zoneHeight = zone.top - zone.bottom;
   zone.entryPrice   = zone.top;
   zone.startTime    = iTime(Symbol(), tf, baseEnd);
   zone.breakoutBar  = shift;
   zone.breakoutTime = iTime(Symbol(), tf, shift);
   zone.baseStartBar = baseStart;
   zone.baseEndBar   = baseEnd;
   zone.timeframe    = tf;
   if (g_zoneIdCounter > 2000000000) g_zoneIdCounter = 1;
   zone.uniqueID   = g_zoneIdCounter++;
   zone.fingerprint = StringFormat("%d_%d_BULL_%s", tf, shift, TimeToString(zone.startTime));
   
   // Initialize Visual Names
   zone.slName     = "TraceInst_SL_" + IntegerToString(zone.uniqueID);
   zone.tpName     = "TraceInst_TP_" + IntegerToString(zone.uniqueID);
   zone.slTextName = "TraceInst_SL_Txt_" + IntegerToString(zone.uniqueID);
   zone.tpTextName = "TraceInst_TP_Txt_" + IntegerToString(zone.uniqueID);

   // Same formula as CheckZoneHits() / DrawSLTPLines() so the order and the
   // lines drawn on the zone are always the identical levels
   zone.stopLoss   = zone.bottom - (SL_Buffer_Points * ((Point == 0) ? 0.0001 : Point));
   zone.takeProfit = zone.entryPrice + ((zone.entryPrice - zone.stopLoss) * Risk_Reward_Ratio);
   zone.breaker     = false;
   zone.tpHit       = false;
   zone.slHit       = false;
   zone.hitTime     = 0;
   zone.touches     = 0;
   zone.isTraded    = false;
   zone.relativeVolume = 0;
   zone.bosStrength = 0.0;
   zone.bosConfirmed = false;
   
   // Calculate relative volume of impulse bar
   double avgVol = GetAverageVolume(tf, Volume_Lookback_Period, shift + 1);
   if (avgVol > 0) zone.relativeVolume = (double)iVolume(Symbol(), tf, shift) / avgVol;
   zone.bosStrength = GetBOSStrengthScore(zone, tf);
   zone.bosConfirmed = (zone.bosStrength > 0.0);
   zone.strength = CalculateZoneScore(zone);
   zone.isElite = (zone.strength >= 8.0);

   zone.fingerprint = StringFormat("%d_%.5f_%.5f_%s", 
   tf, 
   zone.bottom, 
   zone.top, 
   TimeToString(zone.startTime));
   
   return zone;
}

ZoneInfo CreateSupplyZone(int tf, int shift)
{
   ZoneInfo zone;
   double atr  = iATR(Symbol(), tf, 14, shift);
   int    bars = iBars(Symbol(), tf);
   int baseStart = shift + 1;
   int baseEnd   = baseStart;
   double breakoutRange = iHigh(Symbol(), tf, shift) - iLow(Symbol(), tf, shift);
   for (int i = baseStart; i < baseStart + 4 && i < bars; i++)
   {
      double cHigh = iHigh(Symbol(), tf, i);
      double cLow  = iLow(Symbol(), tf, i);
      double cRange = cHigh - cLow;
      double cBody = MathAbs(iOpen(Symbol(), tf, i) - iClose(Symbol(), tf, i));
      if (cBody > breakoutRange * 0.5) break;
      if (cRange > iATR(Symbol(), tf, 14, i) * 1.5) break;
      
      baseEnd = i;
   }
   double baseHigh = -DBL_MAX;
   double baseLow  = DBL_MAX;
   for (int i = baseStart; i <= baseEnd; i++)
   {
      double h = iHigh(Symbol(), tf, i);
      double bodyMin = MathMin(iOpen(Symbol(), tf, i), iClose(Symbol(), tf, i));
      if (h > baseHigh) baseHigh = h;
      if (bodyMin < baseLow) baseLow = bodyMin;
   }
   zone.zoneType = "Bear";
   zone.top      = baseHigh;
   zone.bottom   = baseLow;
   if (zone.top - zone.bottom < Point) zone.bottom = zone.top - Point;

   double zoneHeight = zone.top - zone.bottom;
   zone.entryPrice   = zone.bottom;
   zone.startTime    = iTime(Symbol(), tf, baseEnd);
   zone.breakoutBar  = shift;
   zone.breakoutTime = iTime(Symbol(), tf, shift);
   zone.baseStartBar = baseStart;
   zone.baseEndBar   = baseEnd;
   zone.timeframe    = tf;
   if (g_zoneIdCounter > 2000000000) g_zoneIdCounter = 1;
   zone.uniqueID   = g_zoneIdCounter++;
   zone.fingerprint = StringFormat("%d_%d_BEAR_%s", tf, shift, TimeToString(zone.startTime));
   
   // Initialize Visual Names
   zone.slName     = "TraceInst_SL_" + IntegerToString(zone.uniqueID);
   zone.tpName     = "TraceInst_TP_" + IntegerToString(zone.uniqueID);
   zone.slTextName = "TraceInst_SL_Txt_" + IntegerToString(zone.uniqueID);
   zone.tpTextName = "TraceInst_TP_Txt_" + IntegerToString(zone.uniqueID);
   
   zone.stopLoss   = zone.top + (SL_Buffer_Points * ((Point == 0) ? 0.0001 : Point));
   zone.takeProfit = zone.entryPrice - ((zone.stopLoss - zone.entryPrice) * Risk_Reward_Ratio);
   zone.breaker     = false;
   zone.tpHit       = false;
   zone.slHit       = false;
   zone.hitTime     = 0;
   zone.touches     = 0;
   zone.isTraded    = false;
   zone.relativeVolume = 0;
   zone.bosStrength = 0.0;
   zone.bosConfirmed = false;

   // Calculate relative volume of impulse bar
   double avgVolS = GetAverageVolume(tf, Volume_Lookback_Period, shift + 1);
   if (avgVolS > 0) zone.relativeVolume = (double)iVolume(Symbol(), tf, shift) / avgVolS;
   zone.bosStrength = GetBOSStrengthScore(zone, tf);
   zone.bosConfirmed = (zone.bosStrength > 0.0);
   zone.strength = CalculateZoneScore(zone);
   zone.isElite = (zone.strength >= 8.0);

   zone.fingerprint = StringFormat("%d_%.5f_%.5f_%s", 
   tf, 
   zone.top, 
   zone.bottom, 
   TimeToString(zone.startTime));
   return zone;
}

//+------------------------------------------------------------------+
//| ZONE ARRAYS                                                      |
//+------------------------------------------------------------------+
void EnsureZoneOrdered(ZoneInfo &z)
{
   if (z.top < z.bottom)
   {
      double t = z.top;
      z.top = z.bottom;
      z.bottom = t;
   }
}

void DeleteZoneVisuals(ZoneInfo &z)
{
   ObjectDelete(0, GetZoneObjectName(z, "RECT"));
   ObjectDelete(0, z.slName);
   ObjectDelete(0, z.tpName);
   ObjectDelete(0, z.slTextName);
   ObjectDelete(0, z.tpTextName);
   ObjectDelete(0, GetZoneObjectName(z, "Status"));
   ObjectDelete(0, GetZoneObjectName(z, "LIQ"));
   ObjectDelete(0, GetZoneObjectName(z, "VOL"));
   ObjectDelete(0, GetZoneObjectName(z, "MID"));
}

// Liquidity functions removed

void RemoveBullZoneAt(int idx)
{
   if (idx < 0 || idx >= totalBullZones) return;
   for (int k = idx; k < totalBullZones - 1; k++)
      BullishZones[k] = BullishZones[k + 1];
   totalBullZones--;
   ArrayResize(BullishZones, totalBullZones);
}

void RemoveBearZoneAt(int idx)
{
   if (idx < 0 || idx >= totalBearZones) return;
   for (int k = idx; k < totalBearZones - 1; k++)
      BearishZones[k] = BearishZones[k + 1];
   totalBearZones--;
   ArrayResize(BearishZones, totalBearZones);
}

//+------------------------------------------------------------------+
//| ZONE ARRAYS                                                      |
//+------------------------------------------------------------------+
bool IsTradedZoneFingerprint(string fingerprint)
{
   if (fingerprint == "") return false;
   for (int i = 0; i < g_tradedZoneFingerprintCount; i++)
   {
      if (g_tradedZoneFingerprints[i] == fingerprint) return true;
   }
   return false;
}

void RememberTradedZoneFingerprint(string fingerprint)
{
   if (fingerprint == "" || IsTradedZoneFingerprint(fingerprint)) return;
   ArrayResize(g_tradedZoneFingerprints, g_tradedZoneFingerprintCount + 1);
   g_tradedZoneFingerprints[g_tradedZoneFingerprintCount] = fingerprint;
   g_tradedZoneFingerprintCount++;
}

bool IsSeenZoneFingerprint(string fingerprint)
{
   if (fingerprint == "") return false;
   for (int i = 0; i < g_seenZoneFingerprintCount; i++)
   {
      if (g_seenZoneFingerprints[i] == fingerprint) return true;
   }
   return false;
}

void EnsureZoneFingerprint(ZoneInfo &zone)
{
   if (zone.fingerprint != "") return;
   double top = NormalizeDouble(MathMax(zone.top, zone.bottom), 5);
   double bottom = NormalizeDouble(MathMin(zone.top, zone.bottom), 5);
   zone.fingerprint = StringFormat("%s_%d_%.5f_%.5f_%s",
                                   zone.zoneType, zone.timeframe,
                                   bottom, top,
                                   TimeToString(zone.startTime));
   Print("ImmediateEntry generated missing zone fingerprint for zone ",
         zone.uniqueID, ": ", zone.fingerprint);
}

bool RememberSeenZoneFingerprint(string fingerprint)
{
   if (fingerprint == "" || IsSeenZoneFingerprint(fingerprint))
      return false;
   ArrayResize(g_seenZoneFingerprints, g_seenZoneFingerprintCount + 1);
   g_seenZoneFingerprints[g_seenZoneFingerprintCount] = fingerprint;
   g_seenZoneFingerprintCount++;
   return true;
}

bool IsZoneYoungEnoughForTrade(ZoneInfo &zone, string &reason)
{
   reason = "";
   if (Trade_MaxAgeHours <= 0) return true;
   datetime nowTime = TimeCurrent();
   if (nowTime <= 0) nowTime = Time[0];

   datetime zoneCreated = zone.startTime;
   if (zoneCreated <= 0)
   {
      if (zone.breakoutTime > 0) zoneCreated = zone.breakoutTime;
   }
   if (zoneCreated <= 0) return true;

   int ageSeconds = (int)(nowTime - zoneCreated);
   int maxAgeSeconds = Trade_MaxAgeHours * 3600;
   if (ageSeconds > maxAgeSeconds)
   {
      double ageHours = ageSeconds / 3600.0;
      reason = StringFormat("Zone too old for trade: %.1fh > max %dh (created %s)",
                            ageHours, Trade_MaxAgeHours,
                            TimeToString(zoneCreated, TIME_DATE|TIME_MINUTES));
      return false;
   }
   return true;
}

bool ImmediateZoneIsRecent(ZoneInfo &zone)
{
   if (g_isScanningHistory && !g_obResyncLiveZone)
   {
      Print("ImmediateEntry skipped historical zone ", zone.uniqueID,
            ": fingerprint=", zone.fingerprint);
      return false;
   }
   return true;
}

void DrawImmediateTradeMarker(ZoneInfo &zone, int marketTicket,
                              int orderType, double entryPrice)
{
   string prefix = "IE_TRADE_";
   string baseName = prefix + IntegerToString(marketTicket) + "_" +
                     IntegerToString(zone.uniqueID);
   string rectName = baseName + "_ZONE";
   string arrowName = baseName + "_ARROW";
   string textName = baseName + "_TEXT";

   datetime startTime = zone.startTime;
   if (startTime <= 0) startTime = TimeCurrent();
   int barSeconds = PeriodSeconds(zone.timeframe);
   if (barSeconds <= 0) barSeconds = zone.timeframe * 60;
   if (barSeconds <= 0) barSeconds = 60;
   datetime endTime = startTime + (datetime)(barSeconds * 50);
   datetime entryTime = TimeCurrent();
   if (entryTime <= 0) entryTime = startTime;

   double top = MathMax(zone.top, zone.bottom);
   double bottom = MathMin(zone.top, zone.bottom);
   color markerColor = (orderType == OP_BUY) ? clrDeepSkyBlue : clrMagenta;

   if (ObjectFind(0, rectName) == -1)
      ObjectCreate(0, rectName, OBJ_RECTANGLE, 0,
                   startTime, top, endTime, bottom);
   else
   {
      ObjectMove(0, rectName, 0, startTime, top);
      ObjectMove(0, rectName, 1, endTime, bottom);
   }
   ObjectSetInteger(0, rectName, OBJPROP_COLOR, markerColor);
   ObjectSetInteger(0, rectName, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, rectName, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, rectName, OBJPROP_BACK, false);
   ObjectSetInteger(0, rectName, OBJPROP_FILL, false);
   ObjectSetInteger(0, rectName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, rectName, OBJPROP_HIDDEN, false);

   if (ObjectFind(0, arrowName) == -1)
      ObjectCreate(0, arrowName, OBJ_ARROW, 0, entryTime, entryPrice);
   else
      ObjectMove(0, arrowName, 0, entryTime, entryPrice);
   ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE,
                    (orderType == OP_BUY) ? 233 : 234);
   ObjectSetInteger(0, arrowName, OBJPROP_COLOR, markerColor);
   ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, arrowName, OBJPROP_BACK, false);
   ObjectSetInteger(0, arrowName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, arrowName, OBJPROP_HIDDEN, false);

   string direction = (orderType == OP_BUY) ? "BUY" : "SELL";
   string label = "IE #" + IntegerToString(zone.uniqueID) + " " + direction;
   if (ObjectFind(0, textName) == -1)
      ObjectCreate(0, textName, OBJ_TEXT, 0, entryTime, entryPrice);
   else
      ObjectMove(0, textName, 0, entryTime, entryPrice);
   ObjectSetString(0, textName, OBJPROP_TEXT, label);
   ObjectSetString(0, textName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, textName, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, textName, OBJPROP_COLOR, markerColor);
   ObjectSetInteger(0, textName, OBJPROP_ANCHOR,
                    (orderType == OP_BUY) ? ANCHOR_LEFT_LOWER
                                          : ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, textName, OBJPROP_BACK, false);
   ObjectSetInteger(0, textName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, textName, OBJPROP_HIDDEN, false);
   Print("ImmediateEntry marker drawn for zone ", zone.uniqueID,
         " market ticket=", marketTicket,
         " objects=", rectName, ",", arrowName, ",", textName);
}

void NotifyNewZone(ZoneInfo &zone, bool fromResync)
{
   if (!EnableTelegram) return;
   string side = (zone.zoneType == "Bull") ? "BUY" : "SELL";
   string msg = "Trace Institucional EA - NEW ZONE\n" +
                "Symbol: " + Symbol() + "  TF: " + TimeframeToString(zone.timeframe) + "\n" +
                "Type: " + side + (fromResync ? " (resync)" : "") + "\n" +
                "Zone: " + DoubleToString(zone.bottom, Digits) + " - " + DoubleToString(zone.top, Digits) + "\n" +
                "SL: " + DoubleToString(zone.stopLoss, Digits) + "\n" +
                "TP: " + DoubleToString(zone.takeProfit, Digits);
   SendTelegramMessage(msg);
}

void ImmediateEntry(ZoneInfo &zone, bool firstDetection)
{
   EnsureZoneFingerprint(zone);
   if (!firstDetection)
      firstDetection = RememberSeenZoneFingerprint(zone.fingerprint);
   if (!firstDetection)
   {
      Print("ImmediateEntry skipped previously seen zone ", zone.uniqueID,
            " fingerprint=", zone.fingerprint);
      return;
   }
   if (zone.isTraded)
   {
      Print("ImmediateEntry skipped duplicate/traded zone ", zone.uniqueID,
            " fingerprint=", zone.fingerprint);
      return;
   }
   if (IsTradedZoneFingerprint(zone.fingerprint))
   {
      Print("ImmediateEntry skipped duplicate fingerprint for zone ",
            zone.uniqueID, ": ", zone.fingerprint);
      zone.isTraded = true;
      return;
   }
   if (Use_VolumeDivergenceFilter && VD_BlockTradesOnly &&
       HasVolumeDivergence(zone, zone.timeframe))
   {
      Print("ImmediateEntry ignoring VD_BlockTradesOnly for zone ",
            zone.uniqueID, ": ImmediateEntry is not trade-blocked by volume divergence");
   }
   if (!ImmediateZoneIsRecent(zone)) return;

   RefreshRates();
   int type = (zone.zoneType == "Bull") ? OP_BUY : OP_SELL;
   double marketPrice = (type == OP_BUY) ? Ask : Bid;

   double point = Point;
   if (point <= 0.0) point = 0.00001;
   double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * point;
   double minDistance = MathMax(stopLevel, point);
   double slPrice = NormalizeDouble(zone.stopLoss, Digits);
   double tpPrice = NormalizeDouble(zone.takeProfit, Digits);
   double riskDistance = (type == OP_BUY)
                         ? marketPrice - slPrice
                         : slPrice - marketPrice;

   // --- USER REQUEST: IMMEDIATE ENTRY WITH EXACT ZONE SL/TP, BYPASSING ALL FILTERS ---
   double lot = CalcTradeLot(marketPrice, slPrice, Lot_Size);
   if (lot <= 0.0) lot = 0.01; // fallback to minimum lot if calculation fails

   int slippage = (Use_RiskGuard && Risk_MaxSlippagePoints > 0) ? Risk_MaxSlippagePoints : 10;
   string marketComment = BuildTradeComment(zone) + "_IE";
   
   int marketTicket = OrderSend(Symbol(), type, lot, marketPrice, slippage, slPrice, tpPrice, marketComment, Magic_Number, 0, (type == OP_BUY ? clrBlue : clrRed));
   
   if (marketTicket < 0)
   {
      int marketError = GetLastError();
      // If error 130 (Invalid Stops), send order without SL/TP, then modify to zone's SL/TP
      if (marketError == 130)
      {
         Print("ImmediateEntry error 130 (Stops too close). Opening order without stops and modifying to exact zone SL/TP...");
         RefreshRates();
         marketPrice = (type == OP_BUY) ? Ask : Bid;
         marketTicket = OrderSend(Symbol(), type, lot, marketPrice, slippage, 0, 0, marketComment, Magic_Number, 0, (type == OP_BUY ? clrBlue : clrRed));
         
         if (marketTicket >= 0)
         {
            if (OrderSelect(marketTicket, SELECT_BY_TICKET))
            {
               bool mod = OrderModify(marketTicket, OrderOpenPrice(), slPrice, tpPrice, 0, clrNONE);
               if (!mod) Print("ImmediateEntry failed to set exact zone SL/TP due to broker distance limits. Error: ", GetLastError());
            }
         }
      }
      
      if (marketTicket < 0)
      {
         Print("ImmediateEntry market order failed for zone ", zone.uniqueID,
               " error=", GetLastError(),
               " type=", type,
               " lot=", DoubleToString(lot, 2),
               " price=", DoubleToString(marketPrice, Digits),
               " SL=", DoubleToString(slPrice, Digits),
               " TP=", DoubleToString(tpPrice, Digits));
         return;
      }
   }

   zone.isTraded = true;
   RememberTradedZoneFingerprint(zone.fingerprint);
   double markerPrice = marketPrice;
   if (OrderSelect(marketTicket, SELECT_BY_TICKET))
      markerPrice = OrderOpenPrice();
   DrawImmediateTradeMarker(zone, marketTicket, type, markerPrice);
   if (EnableTelegram)
   {
      string ieSide = (type == OP_BUY) ? "BUY" : "SELL";
      string ieMsg = "Trace Institucional EA ORDER OPENED\n" +
                     "Symbol: " + Symbol() + "\n" +
                     "Type: " + ieSide + "\n" +
                     "Ticket: #" + IntegerToString(marketTicket) + "\n" +
                     "Entry: " + DoubleToString(markerPrice, Digits) + "\n" +
                     "SL: " + DoubleToString(slPrice, Digits) + "\n" +
                     "TP: " + DoubleToString(tpPrice, Digits);
      SendTelegramMessage(ieMsg);
   }
   RefreshRates();
   string pendingComment = "TI_IE_PEND_" + IntegerToString(zone.uniqueID);
   double pendingEntry = NormalizeDouble(zone.entryPrice, Digits);
   double pendingSL = NormalizeDouble(zone.stopLoss, Digits);
   double pendingTP = NormalizeDouble(zone.takeProfit, Digits);
   int pendingType = (type == OP_BUY) ? OP_BUYLIMIT : OP_SELLLIMIT;

   bool pendingEntryValid = (type == OP_BUY)
                            ? (pendingEntry < Ask - minDistance)
                            : (pendingEntry > Bid + minDistance);
   if (!pendingEntryValid)
   {
      Print("ImmediateEntry pending rejected before OrderSend for zone ",
            zone.uniqueID, ": entry too close or wrong side",
            " entry=", DoubleToString(pendingEntry, Digits),
            " market=", DoubleToString((type == OP_BUY) ? Ask : Bid, Digits),
            " minDistance=", DoubleToString(minDistance, Digits));
      return;
   }
   if ((type == OP_BUY && (pendingSL >= pendingEntry || pendingTP <= pendingEntry)) ||
       (type == OP_SELL && (pendingSL <= pendingEntry || pendingTP >= pendingEntry)))
   {
      Print("ImmediateEntry pending rejected before OrderSend for zone ",
            zone.uniqueID, ": invalid zone SL/TP at pending entry",
            " entry=", DoubleToString(pendingEntry, Digits),
            " zoneSL=", DoubleToString(zone.stopLoss, Digits),
            " zoneTP=", DoubleToString(zone.takeProfit, Digits));
      return;
   }
   if ((type == OP_BUY && (pendingEntry - pendingSL < minDistance ||
                           pendingTP - pendingEntry < minDistance)) ||
       (type == OP_SELL && (pendingSL - pendingEntry < minDistance ||
                            pendingEntry - pendingTP < minDistance)))
   {
      Print("ImmediateEntry pending rejected before OrderSend for zone ",
            zone.uniqueID, ": zone SL/TP violates MODE_STOPLEVEL",
            " entry=", DoubleToString(pendingEntry, Digits),
            " SL=", DoubleToString(pendingSL, Digits),
            " TP=", DoubleToString(pendingTP, Digits),
            " minDistance=", DoubleToString(minDistance, Digits));
      return;
   }

   if (!TradeRRGateAllows(pendingType, pendingEntry, pendingSL, pendingTP,
                          "ImmediateEntry pending zone " + IntegerToString(zone.uniqueID))) return;
   double pendingLot = CalcTradeLot(pendingEntry, pendingSL,
                                    (Pending_Lot_Size > 0.0)
                                    ? Pending_Lot_Size : Lot_Size);
   if (pendingLot <= 0.0)
   {
      Print("ImmediateEntry: pending lot size unavailable for zone ",
            zone.uniqueID, " market ticket=", marketTicket,
            " requestedLot=",
            DoubleToString((Pending_Lot_Size > 0.0)
                           ? Pending_Lot_Size : Lot_Size, 2));
      return;
   }

   int pendingTicket = OrderSend(Symbol(), pendingType, pendingLot, pendingEntry,
                                 slippage, pendingSL, pendingTP, pendingComment,
                                 Magic_Number, 0,
                                 (type == OP_BUY ? clrDodgerBlue : clrOrange));
   if (pendingTicket < 0)
   {
      Print("ImmediateEntry pending order failed for zone ", zone.uniqueID,
            " error=", GetLastError(), " market ticket=", marketTicket,
            " type=", pendingType,
            " lot=", DoubleToString(pendingLot, 2),
            " entry=", DoubleToString(pendingEntry, Digits),
            " SL=", DoubleToString(zone.stopLoss, Digits),
            " TP=", DoubleToString(zone.takeProfit, Digits));
      return;
   }

   Print(">>> IMMEDIATE ENTRY pair opened: market #", marketTicket,
         " pending #", pendingTicket, " zone ", zone.uniqueID);
}

void AttemptAutoTrade(ZoneInfo &zone, int tradeShift = 0)
{
   if (!Enable_AutoTrade) return;
   
   // Check if we are scanning history - don't trade old zones
   if (g_isScanningHistory && !g_obResyncLiveZone) return;
   
   // Check if already traded
   if (zone.isTraded) return;

   // --- MAX ZONE AGE SAFETY CHECK ---
   string ageReason = "";
   if (!IsZoneYoungEnoughForTrade(zone, ageReason))
   {
      Print("AttemptAutoTrade BLOCKED zone ", zone.uniqueID, ": ", ageReason);
      zone.isTraded = true;
      RememberTradedZoneFingerprint(zone.fingerprint);
      return;
   }
   
   if (AutoTrade_RespectTimeFilter && !IsTradingAllowed()) return;
   
   if (AutoTrade_CurrentChartTFOnly && zone.timeframe != Period()) return;

   int type = (zone.zoneType == "Bull") ? OP_BUY : OP_SELL;

   // Volume divergence blocks the ORDER only - the zone itself stays on the chart
   if (Use_VolumeDivergenceFilter && VD_BlockTradesOnly && HasVolumeDivergence(zone, zone.timeframe))
   {
      if (DebugMode) Print("AutoTrade skip: volume divergence on zone ", zone.uniqueID);
      return;
   }

   string riskReason = "";
   if (!RiskGuardAllowsTrade(zone, type, riskReason))
   {
      g_riskBlockReason = riskReason;
      if (DebugMode) Print("RiskGuard blocked trade on zone ", zone.uniqueID, ": ", riskReason);
      return;
   }
   g_riskBlockReason = "";

   RefreshRates();
   double price = (type == OP_BUY) ? Ask : Bid;

   // Zone-anchored SL/TP; when we enter away from the zone they become a tight
   // ATR stop + quick target instead of the far zone edge
   double slPrice, tpPrice;
   double pt = Point;
   if (pt == 0) pt = 0.0001;

   ComputeEntryLevels(zone, type, price, slPrice, tpPrice);
   slPrice = NormalizeDouble(slPrice, Digits);
   tpPrice = NormalizeDouble(tpPrice, Digits);

   string entryReason = "";
   if (!EntryGuardAllows(zone, type, price, slPrice, tpPrice, entryReason))
   {
      if (DebugMode) Print("EntryGuard blocked market order on zone ", zone.uniqueID, ": ", entryReason);
      // Price is not usable here -> park a limit order in the zone instead of chasing
      if (Entry_ConvertToPendingLimit) PlaceZonePending(zone, true);
      return;
   }

   // Respect the broker's minimum stop distance
   double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * pt;

   if (type == OP_BUY)
   {
      // For a BUY: SL must sit below price, TP above price
      if (slPrice >= price - stopLevel || tpPrice <= price + stopLevel)
      {
         if (DebugMode) Print("AutoTrade skip (BUY): zone SL/TP invalid vs price. Zone ", zone.uniqueID,
                              " SL=", DoubleToString(slPrice, Digits),
                              " TP=", DoubleToString(tpPrice, Digits),
                              " Price=", DoubleToString(price, Digits));
         return;
      }
   }
   else
   {
      // For a SELL: SL must sit above price, TP below price
      if (slPrice <= price + stopLevel || tpPrice >= price - stopLevel)
      {
         if (DebugMode) Print("AutoTrade skip (SELL): zone SL/TP invalid vs price. Zone ", zone.uniqueID,
                              " SL=", DoubleToString(slPrice, Digits),
                              " TP=", DoubleToString(tpPrice, Digits),
                              " Price=", DoubleToString(price, Digits));
         return;
      }
   }
   
   double lot = CalcTradeLot(price, slPrice, Lot_Size);
   if (lot <= 0.0)
   {
      g_riskBlockReason = "lot/margin";
      if (DebugMode) Print("AutoTrade skip: lot size 0 (margin) zone ", zone.uniqueID);
      return;
   }

   int slippage = (Use_RiskGuard && Risk_MaxSlippagePoints > 0) ? Risk_MaxSlippagePoints : 10;
   string cmt = BuildTradeComment(zone);

   int ticket = OrderSend(Symbol(), type, lot, price, slippage, slPrice, tpPrice, cmt, Magic_Number, 0, (type==OP_BUY?clrBlue:clrRed));
   
   if (ticket < 0)
   {
      int error = GetLastError();
      Print("OrderSend FAILED for Zone ", zone.uniqueID, " Error: ", error);
      
      // If price changed, try one more time with current price
      if (error == 135 || error == 138) // Price changed or Requote
      {
          RefreshRates();
          price = (type == OP_BUY) ? Ask : Bid;
          double stopLevel2 = MarketInfo(Symbol(), MODE_STOPLEVEL) * pt;
          // Keep the zone-anchored SL/TP, only re-validate them against the new price
          if (type == OP_BUY)
          {
             if (slPrice >= price - stopLevel2 || tpPrice <= price + stopLevel2) return;
          }
          else
          {
             if (slPrice <= price + stopLevel2 || tpPrice >= price - stopLevel2) return;
          }
          ticket = OrderSend(Symbol(), type, lot, price, slippage, slPrice, tpPrice, cmt, Magic_Number, 0, (type==OP_BUY?clrBlue:clrRed));
      }
   }
   
   if (ticket >= 0)
   {
      zone.isTraded = true;
      zone.entryPrice = price;
      zone.stopLoss = slPrice;
      zone.takeProfit = tpPrice;
      Print(">>> AUTO TRADE OPENED: Ticket #", ticket, " for Zone ", zone.uniqueID);
      
      if (EnableTelegram)
      {
         string side = (type == OP_BUY) ? "BUY" : "SELL";
         string msg = "Trace Institucional EA Symbol: " + Symbol() + "\n" +
                      "Type: " + side + "\n" +
                      "SL: " + DoubleToString(slPrice, Digits) + "\n" +
                      "TP: " + DoubleToString(tpPrice, Digits);
         
         SendTelegramMessage(msg);
      }
   }
}

//+------------------------------------------------------------------+
//| DASHBOARD SIGNAL AUTOTRADE HELPERS                                |
//+------------------------------------------------------------------+
string BuildDashboardTradeComment(int dir, int sc, string grd, int stable, double atrStop)
{
   string side = (dir == OP_BUY) ? "BUY" : "SELL";
   return "DASH_" + side + "_S" + IntegerToString(sc) + "_G" + grd +
          "_ST" + IntegerToString(stable) + "bars_ATR" + DoubleToString(atrStop, 2);
}

//======================================================================
// NEW SAFETY BLOCK 1:  SESSION END BLOCK (1h before ASIA / Friday close)
//======================================================================
bool DashPassSessionEndCheck(string &why)
{
   if (!Dash_SessionEndBlock1h) { why = ""; return true; }

   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int wday = dt.day_of_week;     // 0=Sun, 1=Mon, ..., 5=Fri, 6=Sat
   int hh   = dt.hour;

   // (A) Friday 22:00 -> 23:59 before weekend
   if (wday == 5 && hh >= 22)
   {
      why = "Fri 22-24 weekend";
      return false;
   }
   // (B) Monday 00-01: Asia open is often noisy
   if (wday == 1 && hh <= 1)
   {
      why = "Mon 00-02 Asia open";
      return false;
   }
   // (C) Every day 23:00 -> 00:00 = 1h before ASIA (liquidity drop)
   if (hh == 23)
   {
      why = "Daily 23-00 Asia";
      return false;
   }
   why = "";
   return true;
}

//======================================================================
// NEW SAFETY BLOCK 2:  BOS MULTI-BAR CONFIRMATION (prevents 1-bar fake break)
//======================================================================
bool DashPassBOSConfirmCheck(int minBars, int tf, int trend, double bosLevel, string &why)
{
   if (minBars <= 0) { why = ""; return true; }
   if (trend == 0)   { why = "no trend"; return false; }
   if (iBars(Symbol(), tf) < minBars + 2) { why = "not enough bars"; return false; }

   int okCount = 0;
   for (int i = 1; i <= minBars + 2 && i <= iBars(Symbol(), tf) - 1; i++)
   {
      double closeI = iClose(Symbol(), tf, i);
      if (trend == 1 && closeI > bosLevel) okCount++;
      if (trend == -1 && closeI < bosLevel) okCount++;
      if (okCount >= minBars) { why = ""; return true; }
   }
   why = "BOS conf " + IntegerToString(okCount) + "/" + IntegerToString(minBars) + " bars";
   return false;
}

//======================================================================
// NEW SAFETY BLOCK 3: "AI" TRIPLE FILTER
//   (1) EMA200 on Structure TF  trend direction MATCH
//   (2) ADX(14) > 20             trend is REAL (not chop)
//   (3) RSI(14) NOT in extreme   (NOT RSI>75 chase long, NOT RSI<25 chase short)
//======================================================================
bool DashPassAITripleFilter(int tf, int trend, string &why)
{
   if (!Dash_EnableAIFilter) { why = ""; return true; }
   if (trend == 0) { why = "no trend"; return false; }

   int digits = Digits;
   double pt = Point; if (pt == 0) pt = 0.0001;

   // --- (1) EMA 200 TREND MATCH ---
   double ema200 = iMA(Symbol(), tf, 200, 0, MODE_EMA, PRICE_CLOSE, 1);
   double price  = iClose(Symbol(), tf, 1);
   if (trend == 1 && price < ema200)  { why = "EMA200 BEAR vs BULL BOS"; return false; }
   if (trend == -1 && price > ema200) { why = "EMA200 BULL vs BEAR BOS"; return false; }

   // --- (2) ADX(14) > 20 ---
   double adx = iADX(Symbol(), tf, 14, PRICE_CLOSE, MODE_MAIN, 1);
   if (adx < 20.0) { why = "ADX=" + DoubleToString(adx,1) + " (chop, <20)"; return false; }

   // --- (3) RSI(14) NO EXTREME ---
   double rsi = iRSI(Symbol(), tf, 14, PRICE_CLOSE, 1);
   if (trend == 1  && rsi > 76.0) { why = "RSI=" + DoubleToString(rsi,0) + " (overbought chase BUY)"; return false; }
   if (trend == -1 && rsi < 24.0) { why = "RSI=" + DoubleToString(rsi,0) + " (oversold chase SELL)"; return false; }

   why = "EMA+ADX+RSI OK";
   return true;
}

//======================================================================
// AttemptDashboardSignalTrade FULLY REWRITTEN with 3 Locks + Dry Run
//======================================================================
void AttemptDashboardSignalTrade()
{
   if (!Dash_EnableSignalTrading && !Dash_DryRunOnly) return;
   if (g_isScanningHistory) return;
   if (!g_sigCachedHasStruct || g_sigCachedScore < 0)
   {
      g_dashLastDryText  = "[DRY] wait: no BOS";
      g_dashLastDryClr   = clrSilver;
      g_dashAIRslt       = false;
      g_dashAIReason     = "";
      return;
   }

   // ===== 1) GRADE / SCORE / STABLE BASIC FILTER =====
   if (g_sigCachedScore < Dash_MinScore)
   {
      g_dashLastDryText = "[DRY] skip: Score " + IntegerToString(g_sigCachedScore) + "<" + IntegerToString(Dash_MinScore);
      g_dashLastDryClr  = clrGray;
      return;
   }
   int gradeNeededMin = 0;
   if (Dash_GradeThreshold == "S") gradeNeededMin = 90;
   else if (Dash_GradeThreshold == "A") gradeNeededMin = 75;
   else if (Dash_GradeThreshold == "B") gradeNeededMin = 60;
   else if (Dash_GradeThreshold == "C") gradeNeededMin = 45;
   if (g_sigCachedScore < gradeNeededMin)
   {
      g_dashLastDryText = "[DRY] skip: Grade below " + Dash_GradeThreshold;
      g_dashLastDryClr  = clrGray;
      return;
   }
   if (g_sigStableBars < Dash_MinStableBars)
   {
      g_dashLastDryText = "[DRY] wait: stable " + IntegerToString(g_sigStableBars) + "/" + IntegerToString(Dash_MinStableBars);
      g_dashLastDryClr  = clrDarkOrange;
      return;
   }

   int type = -1;
   if (g_sigCachedTrend == 1 && StringFind(g_sigCachedDirText, "BUY") >= 0) type = OP_BUY;
   if (g_sigCachedTrend == -1 && StringFind(g_sigCachedDirText, "SELL") >= 0) type = OP_SELL;
   if (type < 0)
   {
      g_dashLastDryText = "[DRY] wait: no BUY/SELL dir";
      g_dashLastDryClr  = clrSilver;
      return;
   }

   if (Dash_RequireReadyNearBOS && StringFind(g_sigCachedAction, "[READY]") < 0)
   {
      g_dashLastDryText = "[DRY] wait: " + g_sigCachedAction;
      g_dashLastDryClr  = clrDarkGoldenrod;
      return;
   }

   // ===== 2) SAFETY TRIPLE LOCK (NEW) =====
   string sessionWhy = "";
   if (!DashPassSessionEndCheck(sessionWhy))
   {
      g_dashLastDryText = "[LOCK] session: " + sessionWhy;
      g_dashLastDryClr  = clrOrange;
      return;
   }

   string bosWhy = "";
   if (!DashPassBOSConfirmCheck(GetDashMinBOSConfirmBarsForTF(g_sigCachedStructTF), g_sigCachedStructTF, g_sigCachedTrend, g_sigCachedBOSLevel, bosWhy))
   {
      g_dashLastDryText = "[LOCK] " + bosWhy;
      g_dashLastDryClr  = clrTomato;
      return;
   }

   string aiWhy = "";
   bool aiPass = DashPassAITripleFilter(g_sigCachedStructTF, g_sigCachedTrend, aiWhy);
   g_dashAIRslt   = aiPass;
   g_dashAIReason = aiWhy;
   if (!aiPass)
   {
      g_dashLastDryText = "[AI-BLOCK] " + aiWhy;
      g_dashLastDryClr  = clrHotPink;
      return;
   }

   // ===== 3) MEMO: ista struktura ne 2x =====
   string sigKey = TimeframeToString(g_sigCachedStructTF) + "_" +
                   (type == OP_BUY ? "BULL" : "BEAR") + "_" +
                   DoubleToString(g_sigCachedBOSLevel, Digits);
   if (g_dashLastTradeSigKey == sigKey)
   {
      g_dashLastDryText = "[OK] " + (type==OP_BUY?"BUY":"SELL") + " - already used key";
      g_dashLastDryClr  = clrSilver;
      return;
   }

   // ===== 4) RISK PRE-CHECKS (spread, max open, opposite, time) =====
   RefreshRates();
   if (Dash_SpreadPtsMax > 0.0)
   {
      double sp = GetSpreadPoints();
      if (sp > Dash_SpreadPtsMax)
      {
         g_dashLastDryText = "[LOCK] spread " + DoubleToString(sp,1) + ">" + DoubleToString(Dash_SpreadPtsMax,0);
         g_dashLastDryClr  = clrOrange;
         return;
      }
   }
   if (Use_RiskGuard)
   {
      if (Risk_MaxOpenTrades > 0 && CountEAOpenTrades() >= Risk_MaxOpenTrades)
      {
         g_dashLastDryText = "[LOCK] Risk_MaxOpen reached";
         g_dashLastDryClr  = clrRed;
         return;
      }
      int opposite = (type == OP_BUY) ? OP_SELL : OP_BUY;
      if (!Dash_AllowOppositeIfZoneHold && Risk_BlockOppositeDirection && CountEAOpenTrades(opposite) > 0)
      {
         g_dashLastDryText = "[LOCK] opposite open";
         g_dashLastDryClr  = clrRed;
         return;
      }
      if (Risk_MaxConsecutiveLosses > 0 && GetConsecutiveLosses() >= Risk_MaxConsecutiveLosses)
      {
         g_dashLastDryText = "[LOCK] cons losses " + IntegerToString(GetConsecutiveLosses());
         g_dashLastDryClr  = clrRed;
         return;
      }
   }
   if (AutoTrade_RespectTimeFilter && !IsTradingAllowed())
   {
      g_dashLastDryText = "[LOCK] time filter";
      g_dashLastDryClr  = clrOrange;
      return;
   }

   // ===== 5) ENTRY / SL / TP / LOT =====
   double pt = Point; if (pt == 0) pt = 0.0001;
   int digits = Digits;
   double price = (type == OP_BUY) ? Ask : Bid;
   double atr = iATR(Symbol(), g_sigCachedStructTF, 14, 1);
   if (atr <= 0.0) atr = 0.5 * pt * 1000;
   double ptsSize = (digits == 3 || digits == 5) ? (pt * 10.0) : pt;

   double slPrice = 0.0, tpPrice = 0.0;
   if (type == OP_SELL)
   {
      double sh = (g_sigCachedSwingH > 0.0) ? g_sigCachedSwingH : (price + atr * 1.5);
      slPrice = NormalizeDouble(sh + Dash_ATRStopMultiplier * atr, digits);
      double dist = MathAbs(price - slPrice);
      tpPrice = NormalizeDouble(price - dist * Dash_TakeProfitRR, digits);
   }
   else
   {
      double sl = (g_sigCachedSwingL > 0.0) ? g_sigCachedSwingL : (price - atr * 1.5);
      slPrice = NormalizeDouble(sl - Dash_ATRStopMultiplier * atr, digits);
      double dist = MathAbs(price - slPrice);
      tpPrice = NormalizeDouble(price + dist * Dash_TakeProfitRR, digits);
   }

   if (Dash_MaxRiskPts > 0.0)
   {
      double riskPts = MathAbs(price - slPrice) / ptsSize;
      if (riskPts > Dash_MaxRiskPts)
      {
         g_dashLastDryText = "[LOCK] stop big " + IntegerToString((int)riskPts) + "pts > " + IntegerToString((int)Dash_MaxRiskPts);
         g_dashLastDryClr  = clrTomato;
         return;
      }
   }

   double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * pt;
   if (type == OP_BUY)  { if (slPrice >= price - stopLevel || tpPrice <= price + stopLevel) { g_dashLastDryText="[LOCK] SL/TP broker stop"; g_dashLastDryClr=clrRed; return; } }
   else                  { if (slPrice <= price + stopLevel || tpPrice >= price - stopLevel) { g_dashLastDryText="[LOCK] SL/TP broker stop"; g_dashLastDryClr=clrRed; return; } }

   if (!TradeRRGateAllows(type, price, slPrice, tpPrice, "Dashboard signal"))
   {
      g_dashLastDryText = "[LOCK] RR/stop gate";
      g_dashLastDryClr  = clrTomato;
      return;
   }
   double lot;
   if (Dash_UseGlobalRiskPct) lot = CalcTradeLot(price, slPrice, Lot_Size);
   else                        lot = Dash_LotSizeFixed;
   if (lot <= 0.0) { g_dashLastDryText="[LOCK] lot 0"; g_dashLastDryClr=clrRed; return; }
   if (Use_RiskGuard && Risk_MaxLot > 0.0 && lot > Risk_MaxLot) lot = Risk_MaxLot;

   string sideTxt = (type == OP_BUY ? "BUY" : "SELL");
   string signalText = (Dash_DryRunOnly ? "[DRY RUN 🧪] " : "[LIVE 🔴] ") +
                         sideTxt + " @ " + DoubleToString(price, digits) +
                         "  SL " + DoubleToString(slPrice, digits) +
                         "  TP " + DoubleToString(tpPrice, digits) +
                         "  Lot " + DoubleToString(lot, 2);

   // ===== DRY RUN BRANCH (SAFE) =====
   if (Dash_DryRunOnly)
   {
      g_dashLastDryTime = TimeCurrent();
      g_dashLastDryText = signalText;
      g_dashLastDryClr  = (type == OP_BUY ? clrDeepSkyBlue : clrOrangeRed);
      g_dashLastTradeSigKey = sigKey;
      g_dashDryCount++;
      Print(">>> DASH DRY RUN OK: ", signalText,
            " Score=", g_sigCachedScore, " Grade=", g_sigCachedGrade,
            " Stable=", g_sigStableBars, " AI=", aiWhy);
      SaveDashboardSignalToCSV("DRY_RUN", type, price, slPrice, tpPrice, lot,
                               g_sigCachedScore, g_sigCachedGrade, g_sigStableBars,
                               aiWhy, "signal");
      return;
   }

   // ===== LIVE BRANCH =====
   int slippage = (Use_RiskGuard && Risk_MaxSlippagePoints > 0) ? Risk_MaxSlippagePoints : 10;
   string cmt = BuildDashboardTradeComment(type, g_sigCachedScore, g_sigCachedGrade, g_sigStableBars, Dash_ATRStopMultiplier);

   int ticket = OrderSend(Symbol(), type, lot, price, slippage, slPrice, tpPrice, cmt, Magic_Number, 0, (type==OP_BUY?clrBlue:clrRed));
   if (ticket < 0)
   {
      int error = GetLastError();
      g_dashLastDryText = "[LIVE FAIL] Err " + IntegerToString(error);
      g_dashLastDryClr  = clrRed;
      Print("DASH SIGNAL OrderSend FAILED. Err=", error);
      if (error == 135 || error == 138)
      {
         RefreshRates();
         price = (type == OP_BUY) ? Ask : Bid;
         double stop2 = MarketInfo(Symbol(), MODE_STOPLEVEL) * pt;
         if (type == OP_BUY)  { if (slPrice >= price - stop2 || tpPrice <= price + stop2) return; }
         else                  { if (slPrice <= price + stop2 || tpPrice >= price - stop2) return; }
         ticket = OrderSend(Symbol(), type, lot, price, slippage, slPrice, tpPrice, cmt, Magic_Number, 0, (type==OP_BUY?clrBlue:clrRed));
      }
   }
   if (ticket >= 0)
   {
      g_dashLastTradeSigKey = sigKey;
      g_dashLastDryTime = TimeCurrent();
      g_dashLastDryText = "[LIVE 🟢 #" + IntegerToString(ticket) + "] " + sideTxt + " " + DoubleToString(lot,2);
      g_dashLastDryClr  = clrLime;
      Print(">>> DASH SIGNAL TRADE OPENED. Ticket=", ticket,
            " Score=", g_sigCachedScore, " Grade=", g_sigCachedGrade,
            " Stable=", g_sigStableBars, "bars");
      if (EnableTelegram)
      {
         string msg = "Trace EA [DASHBOARD SIGNAL] " + Symbol() + "\n" +
                      "Type: " + sideTxt + "  Score: " + IntegerToString(g_sigCachedScore) + "/" + g_sigCachedGrade + "\n" +
                      "Stable: " + IntegerToString(g_sigStableBars) + " bars\n" +
                      "AI: " + aiWhy + "\n" +
                      "SL: " + DoubleToString(slPrice, digits) + "\n" +
                      "TP: " + DoubleToString(tpPrice, digits) + "\n" +
                      "Lot: " + DoubleToString(lot, 2);
         SendTelegramMessage(msg);
      }
      SaveDashboardSignalToCSV("LIVE", type, price, slPrice, tpPrice, lot,
                               g_sigCachedScore, g_sigCachedGrade, g_sigStableBars,
                               aiWhy, "ticket #" + IntegerToString(ticket));
   }
}

//+------------------------------------------------------------------+
//| Save Dashboard (DRY RUN / LIVE) signal to CSV for long-term log  |
//| File: MQL4/Files/TraceInst_DashboardSignals.csv                  |
//+------------------------------------------------------------------+
void SaveDashboardSignalToCSV(string type, int dir, double entry, double sl, double tp, double lot, int sc, string grd, int stable, string ai, string note)
{
   string fname = "TraceInst_DashboardSignals.csv";
   bool createHeader = (FileIsExist(fname) == false);
   int handle = FileOpen(fname, FILE_CSV|FILE_WRITE|FILE_ANSI, ',', FILE_SHARE_READ);
   if (handle == INVALID_HANDLE)
   {
      Print("CSV save failed: ", fname, " err=", GetLastError());
      return;
   }

   if (createHeader)
   {
      FileWrite(handle, "DATUM", "VREME", "TIP", "SMER", "ENTRY", "SL", "TP", "LOT", "SCORE", "GRADE", "STABLE_BARS", "AI_REASON", "NOTE");
   }
   FileSeek(handle, 0, SEEK_END);

   string dt = TimeToString(TimeCurrent(), TIME_DATE);
   string tm = TimeToString(TimeCurrent(), TIME_MINUTES);
   string sm = (dir == OP_BUY ? "BUY" : (dir == OP_SELL ? "SELL" : "?"));
   int digits = Digits;
   if (digits == 0) digits = 2;

   FileWrite(handle,
             dt, tm,
             type, sm,
             DoubleToString(entry, digits),
             DoubleToString(sl, digits),
             DoubleToString(tp, digits),
             DoubleToString(lot, 2),
             IntegerToString(sc),
             grd,
             IntegerToString(stable),
             ai,
             note);
   FileClose(handle);
}

// ===== REAL AI GPT (WebRequest -> local Node.js server on 127.0.0.1:3000) =====

string AIJsonEscape(string s)
{
   string o = "";
   int len = StringLen(s);
   for (int i = 0; i < len; i++)
   {
      ushort c = StringGetChar(s, i);
      if      (c == 92)  o = o + "\\\\";
      else if (c == 34)  o = o + "\\\"";
      else if (c == 10)  o = o + "\\n";
      else if (c == 13)  o = o + "\\r";
      else if (c == 9)   o = o + "\\t";
      else               o = o + ShortToString(c);
   }
   return o;
}

string AIUrlEncode(string s)
{
   string hexmap = "0123456789ABCDEF";
   string o = "";
   int len = StringLen(s);
   for (int i = 0; i < len; i++)
   {
      int c = (int)StringGetChar(s, i);
      bool ok = ((c >= 65 && c <= 90) || (c >= 97 && c <= 122) || (c >= 48 && c <= 57) ||
                 c == 45 || c == 95 || c == 46 || c == 126);
      if (ok) { o = o + ShortToString((ushort)c); }
      else
      {
         int h = (c >> 4) & 0x0F;
         int l = c & 0x0F;
         o = o + "%" + ShortToString((ushort)StringGetChar(hexmap, h))
                   + ShortToString((ushort)StringGetChar(hexmap, l));
      }
   }
   return o;
}

int AIWrGet(string url, char &resp[], int timeoutMs, string altSubFrom, string altSubTo)
{
   static string lastDebugUrl = "";
   if (DebugMode && url != lastDebugUrl)
   {
      lastDebugUrl = url;
      int urlLen = StringLen(url);
      int firstCode = (urlLen > 0) ? StringGetChar(url, 0) : -1;
      int lastCode = (urlLen > 0) ? StringGetChar(url, urlLen - 1) : -1;
      Print(">>> [Plan B] URL DEBUG url=[", url, "] len=", urlLen,
            " firstCode=", firstCode, " lastCode=", lastCode,
            " timeoutMs=", timeoutMs, " alt=", altSubFrom, "->", altSubTo);
   }
   ArrayResize(resp, 32768);
   char d[]; ArrayResize(d, 0);
   string head = "";
   string hdrs = "Pragma: no-cache\r\nCache-Control: no-cache\r\nHost: 127.0.0.1:3000\r\n";
   if (StringFind(url, "localhost") >= 0)
      hdrs = "Pragma: no-cache\r\nCache-Control: no-cache\r\nHost: localhost:3000\r\n";
   int rc = WebRequest("GET", url, hdrs, timeoutMs, d, resp, head);
   int gle1 = GetLastError();
   string resp1 = CharArrayToString(resp);
   Print(">>> AIWrGet[1] rc=", rc, " gle=", gle1, " len=", StringLen(resp1), " url=", StringSubstr(url, 0, 80));
   if (rc == 200 && StringLen(resp1) > 1) return 200;
   if (StringLen(altSubFrom) > 0 && StringLen(altSubTo) > 0 && StringFind(url, altSubFrom) >= 0)
   {
      string alt = StringSubstr(url, 0, StringFind(url, altSubFrom)) + altSubTo
                 + StringSubstr(url, StringFind(url, altSubFrom) + StringLen(altSubFrom));
      ArrayResize(resp, 32768);
      char d2[]; ArrayResize(d2, 0);
      string head2 = "";
      string hdrs2 = "Pragma: no-cache\r\nCache-Control: no-cache\r\nHost: 127.0.0.1:3000\r\n";
      if (StringFind(alt, "localhost") >= 0)
         hdrs2 = "Pragma: no-cache\r\nCache-Control: no-cache\r\nHost: localhost:3000\r\n";
      rc = WebRequest("GET", alt, hdrs2, timeoutMs, d2, resp, head2);
      int gle2 = GetLastError();
      string resp2 = CharArrayToString(resp);
      Print(">>> AIWrGet[2] rc=", rc, " gle=", gle2, " len=", StringLen(resp2), " url=", StringSubstr(alt, 0, 80));
      if (rc == 200 && StringLen(resp2) > 1) return 200;
   }
   if (rc <= 0) return GetLastError() > 0 ? -GetLastError() : -5299;
   return rc;
}

// ═══════════════════════════════════════════════════════════════════════════════
// FRESHNESS - EDINSTVEN izvor na vistina za "kolku e star" eden zapis od Node.
//
// PROBLEMOT sto se popravuva ovde: MT4 TimeCurrent() e vreme na BROKEROT
// (druga vremenska zona!), a Node pishuva vreme na PC-to. Sporeduvanjeto
// TimeCurrent() - PC_timestamp davashe konstanten offset (1h, 2h, 3h...) pa
// EA-to sekogash mislese deka fajlot e star => isNew=0 zasekogash, i
// dashboard-ot ne mozese da razlikuva UKLUCEN od ISKLUCEN server.
//
//   unixSec  = UTC unix sekundi (1-va linija na heartbeat.txt / "scannedAtUnix")
//              -> se sporeduva so TimeGMT()  (isto UTC, 0 offset)
//   localStr = "YYYY.MM.DD HH:MM:SS" po PC chas ("local=" / "scannedAtLocal")
//              -> se sporeduva so TimeLocal() (isto PC chas, 0 offset)
//
// Vrakja vozrast vo sekundi, ili -1 dokolku ne moze da se presmeta.
// ═══════════════════════════════════════════════════════════════════════════════
int AIFreshnessAgeSec(long unixSec, string localStr, string &modeOut)
{
   int age = -1;
   modeOut = "none";

   if (unixSec >= 1000000000)
   {
      age = (int)((long)TimeGMT() - unixSec);
      modeOut = "Unix-UTC";
   }
   else
   {
      string lv = localStr;
      int posEq = StringFind(lv, "=", 0);
      if (posEq > 0) lv = StringSubstr(lv, posEq + 1);
      StringTrimLeft(lv); StringTrimRight(lv);
      if (StringLen(lv) >= 16)
      {
         datetime t = StringToTime(lv);
         if (t > 946684800)
         {
            age = (int)(TimeLocal() - t);
            modeOut = "Local-PC";
         }
      }
   }

   if (age == -1) { modeOut = "none"; return -1; }
   if (age < 0 && age > -180) age = 0;      // mal skew Node vs MT4 -> tretiraj kako "sega"
   if (age < 0) { modeOut = modeOut + "-SKEW"; return -1; }
   return age;
}

// Limit za "serverot e ziv" - heartbeat.txt se pishuva na sekoi 2s, pa 30s e mnogu.
int AIOfflineLimitSec()
{
   return (AI_OfflineAfterSec <= 0) ? 30 : AI_OfflineAfterSec;
}

// Limit za "GPT odlukata e uste upotrebliva". result.json se osvezuva samo na sekoj
// scan (AI_ScanEverySec), pa NE smee da se meri so istiot kratok limit kako heartbeat.
int AIResultStaleLimitSec()
{
   int scan = (AI_ScanEverySec <= 0) ? 90 : AI_ScanEverySec;
   int lim  = scan * 3 + 30;
   if (lim < AIOfflineLimitSec()) lim = AIOfflineLimitSec();
   return lim;
}

// ═══════════════════════════════════════════════════════════════════════════════
//  TVRDA PORTA (HARD GATE)
//
//  Promptot e samo "molba" - modelot moze da ja ignorira. Zatoa nasokata se
//  odreduva DETERMINISTICKI vo kod, a GPT sluzi samo kako posleden filter/veto.
//  BUY/SELL se prikazuva SAMO ako site vklucheni uslovi pominat.
// ═══════════════════════════════════════════════════════════════════════════════
int AIMtfIdx(string tf)
{
   for (int k = 0; k < MTF_N; k++)
      if (g_mtfName[k] == tf) return k;
   return -1;
}

int AIGradeRank(string g)
{
   string u = g; StringToUpper(u);
   if (u == "S") return 5;
   if (u == "A") return 4;
   if (u == "B") return 3;
   if (u == "C") return 2;
   if (u == "D") return 1;
   return 0;
}

// Vrakja 1/-1/0 za daden TF od MTF cache. dir==0 znaci "nema podatok ili FLAT".
int AIMtfDir(string tf)
{
   int k = AIMtfIdx(tf);
   if (k < 0) return 0;
   if (g_mtfBias[k] == "BULL") return  1;
   if (g_mtfBias[k] == "BEAR") return -1;
   return 0;
}

double ChatScoutPreGateAdx(int tf, bool &available)
{
   available = false;
   string tfName = TimeframeToString(tf);
   int k = AIMtfIdx(tfName);
   if (k >= 0 && g_mtfAdx[k] > 0.0)
   {
      available = true;
      return g_mtfAdx[k];
   }
   if (iBars(Symbol(), tf) <= 15) return 0.0;
   double adx = iADX(Symbol(), tf, 14, PRICE_CLOSE, MODE_MAIN, 1);
   if (adx <= 0.0) return 0.0;
   available = true;
   return adx;
}

int ChatScoutPreGateDir(int tf, bool &available)
{
   available = false;
   int shift = 1;
   int bars = iBars(Symbol(), tf);
   int strength = GetMSSwingStrengthForTF(tf);
   if (strength < 1) strength = 1;
   if (bars <= shift + (strength * 2) + 5) return 0;

   string tfName = TimeframeToString(tf);
   int k = AIMtfIdx(tfName);
   string bias = "";
   if (k >= 0 && (g_mtfBias[k] == "BULL" ||
                  g_mtfBias[k] == "BEAR" ||
                  g_mtfBias[k] == "FLAT"))
      bias = g_mtfBias[k];
   if (StringLen(bias) == 0)
      bias = AIMtfStructureBias(tf, shift);

   if (bias == "BULL")
   {
      available = true;
      return 1;
   }
   if (bias == "BEAR")
   {
      available = true;
      return -1;
   }
   if (bias == "FLAT")
   {
      available = true;
      return 0;
   }
   return 0;
}

string AIMtfStructureBias(int tf, int shift = 1)
{
   int trend = GetMarketTrend(tf, shift);
   if (trend == 1)  return "BULL";
   if (trend == -1) return "BEAR";

   int bars = iBars(Symbol(), tf);
   int strength = GetMSSwingStrengthForTF(tf);
   if (strength < 1) strength = 1;
   if (shift < 0) shift = 0;
   if (bars <= shift + (strength * 2) + 5) return "FLAT";

   int lookback = GetMSLookbackBarsForTF(tf);
   if (lookback < 20) lookback = 20;
   int firstBar = shift + strength + 1;
   int lastBar = MathMin(bars - strength - 1, shift + lookback);

   double latestHigh = 0.0, previousHigh = 0.0;
   double latestLow  = 0.0, previousLow  = 0.0;
   int highCount = 0, lowCount = 0;

   for (int bar = firstBar; bar <= lastBar; bar++)
   {
      if (highCount < 2 && IsStructureSwingHigh(tf, bar, strength))
      {
         if (highCount == 0) latestHigh = iHigh(Symbol(), tf, bar);
         else previousHigh = iHigh(Symbol(), tf, bar);
         highCount++;
      }
      if (lowCount < 2 && IsStructureSwingLow(tf, bar, strength))
      {
         if (lowCount == 0) latestLow = iLow(Symbol(), tf, bar);
         else previousLow = iLow(Symbol(), tf, bar);
         lowCount++;
      }
      if (highCount >= 2 && lowCount >= 2) break;
   }

   bool higherHigh = (highCount >= 2 && latestHigh > previousHigh);
   bool lowerHigh  = (highCount >= 2 && latestHigh < previousHigh);
   bool higherLow  = (lowCount  >= 2 && latestLow  > previousLow);
   bool lowerLow   = (lowCount  >= 2 && latestLow  < previousLow);

   int bullVotes = 0;
   int bearVotes = 0;
   if (higherHigh) bullVotes++;
   if (higherLow)  bullVotes++;
   if (lowerHigh)  bearVotes++;
   if (lowerLow)   bearVotes++;

   if (highCount >= 2 && lowCount >= 2)
   {
      double rangeNow = MathAbs(latestHigh - latestLow);
      double atr = iATR(Symbol(), tf, 14, shift);
      if (atr <= 0.0) atr = Point;
      bool compressed = (rangeNow <= atr * 1.2);

      if (bullVotes >= 2 && bearVotes == 0) return "BULL";
      if (bearVotes >= 2 && bullVotes == 0) return "BEAR";

      // Ako swing-ovite se meshani, ne forsiraj bias od posledniot close.
      if (!compressed)
      {
         if (bullVotes > bearVotes) return "BULL";
         if (bearVotes > bullVotes) return "BEAR";
      }
   }

   return "FLAT";
}

string AIMtfBiasShort(string bias)
{
   if (bias == "BULL") return "BU";
   if (bias == "BEAR") return "BE";
   if (bias == "FLAT") return "FL";
   return "--";
}

string DetectMarketRegime(string &why)
{
   why = "";
   datetime now = TimeCurrent();
   for (int ni = 0; ni < g_chatNewsCount; ni++)
   {
      if (g_chatNewsImpact[ni] != "HIGH") continue;
      int minutes = (int)((g_chatNewsTime[ni] - now) / 60);
      if (minutes >= 0 && minutes <= Chat_NewsWindowMin)
      {
         why = "HIGH news za " + IntegerToString(minutes) + "m: " + g_chatNewsTitle[ni];
         return "NEWS_BLOCK";
      }
   }

   int dirH4 = AIMtfDir("H4");
   int dirH1 = AIMtfDir("H1");
   int dirM15 = AIMtfDir("M15");
   int iH4 = AIMtfIdx("H4");
   int iM15 = AIMtfIdx("M15");
   double adxH4 = (iH4 >= 0) ? g_mtfAdx[iH4] : 0.0;
   double adxM15 = (iM15 >= 0) ? g_mtfAdx[iM15] : 0.0;
   string volTag = ChatCtxVolatilityTag();

   int barsM15 = iBars(Symbol(), PERIOD_M15);
   int lookback = MathMin(48, barsM15 - 2);
   bool midRange = false;
   if (lookback >= 10)
   {
      int hiShift = iHighest(Symbol(), PERIOD_M15, MODE_HIGH, lookback, 1);
      int loShift = iLowest(Symbol(), PERIOD_M15, MODE_LOW, lookback, 1);
      if (hiShift >= 0 && loShift >= 0)
      {
         double hi = iHigh(Symbol(), PERIOD_M15, hiShift);
         double lo = iLow(Symbol(), PERIOD_M15, loShift);
         double range = hi - lo;
         if (range > Point * 20)
         {
            double mid = (hi + lo) * 0.5;
            double px = (Bid + Ask) * 0.5;
            midRange = (MathAbs(px - mid) <= range * 0.12);
         }
      }
   }

   if (volTag == "DEAD" && adxM15 < AI_GateMinADX)
   {
      why = "DEAD volatility + ADX(M15) " + DoubleToString(adxM15, 1);
      return "CHOP";
   }
   if (midRange && adxM15 < AI_GateMinADX + 2.0)
   {
      why = "price vo sredina na M15 range + slab ADX";
      return "RANGE";
   }
   if (dirH1 == 0 && dirM15 == 0)
   {
      why = "H1 i M15 bias se FLAT";
      return "RANGE";
   }
   if (dirH1 != 0 && dirM15 != 0 && dirH1 != dirM15 && adxM15 < AI_GateMinADX + 4.0)
   {
      why = "H1 i M15 se sprotivni bez silen displacement";
      return "RANGE";
   }
   if (dirH4 != 0 && dirH1 != 0 && dirH4 != dirH1 && adxH4 >= AI_GateMinADX)
   {
      why = "H4 e silno sprotiven na H1";
      return "RANGE";
   }

   why = "HTF bias + volatility se dovolno cisti";
   return "TREND";
}

bool PassFinalSignalJudge(int scoutDir, double entry, double sl, double tp2, double conf,
                          string planTrigger, string &why, bool allowSoftM15)
{
   why = "";

   string regimeWhy = "";
   string regime = DetectMarketRegime(regimeWhy);
   if (regime == "NEWS_BLOCK")
   {
      why = "regime " + regime + ": " + regimeWhy;
      return false;
   }
   if (AI_JudgeNeedTrend && regime != "TREND")
   {
      why = "regime " + regime + ": " + regimeWhy;
      return false;
   }

   if (!g_sigCachedHasStruct || g_sigCachedTrend == 0 || g_sigCachedBOSLevel <= 0.0)
   {
      why = "EA nema cista struktura/BOS";
      return false;
   }
   if (!g_gatePass &&
       !(allowSoftM15 && g_gateM15Flat && g_gateOtherPass))
   {
      why = "hard gate FAIL: " + g_gateFail;
      return false;
   }
   if (g_gateDir != scoutDir)
   {
      why = "gate dir " + IntegerToString(g_gateDir) + " != scout dir " + IntegerToString(scoutDir);
      return false;
   }
   if (g_sigCachedTrend != scoutDir)
   {
      why = "EA structure dir " + IntegerToString(g_sigCachedTrend) + " != scout";
      return false;
   }
   if (g_confirmCachedHas && g_confirmCachedTrend != 0 && g_confirmCachedTrend != scoutDir)
   {
      why = "confirm TF e sprotiven";
      return false;
   }
   if (planTrigger == "" || planTrigger == "NONE")
   {
      why = "nema trigger";
      return false;
   }

   if (entry <= 0.0 || sl <= 0.0 || tp2 <= 0.0)
   {
      why = "nevalidni trade leveli";
      return false;
   }
   if (scoutDir == 1 && (sl >= entry || tp2 <= entry))
   {
      why = "BUY plan ima losh entry/SL/TP raspored";
      return false;
   }
   if (scoutDir == -1 && (sl <= entry || tp2 >= entry))
   {
      why = "SELL plan ima losh entry/SL/TP raspored";
      return false;
   }

   string bosWhy = "";
   if (!DashPassBOSConfirmCheck(GetDashMinBOSConfirmBarsForTF(g_sigCachedStructTF), g_sigCachedStructTF, scoutDir, g_sigCachedBOSLevel, bosWhy))
   {
      why = "BOS ne e potvrden: " + bosWhy;
      return false;
   }

   why = "judge PASS regime=" + regime + " conf=" + DoubleToString(conf, 0) +
         " gate=" + IntegerToString(g_gatePassed) + "/" + IntegerToString(g_gateTotal);
   return true;
}

void AIComputeGate()
{
   g_gatePass = false;
   g_gateDir  = 0;
   g_gateWhy  = "";
   g_gateFail = "";
   g_gatePassed = 0;
   g_gateTotal  = 0;
   g_gateM15Flat = false;
   g_gateOtherPass = false;

   if (!AI_HardGate)
   {
      g_gateFail = "Hard gate iskluchen (AI_HardGate=false)";
      return;
   }

   int    dirH4  = AIMtfDir("H4");
   int    dirH1  = AIMtfDir("H1");
   int    dirM15 = AIMtfDir("M15");
   int    dirM5  = AIMtfDir("M5");
   int    iM15   = AIMtfIdx("M15");
   double adxM15 = (iM15 >= 0) ? g_mtfAdx[iM15] : 0.0;
   double rsiM15 = (iM15 >= 0) ? g_mtfRsi[iM15] : 50.0;
   string regimeWhy = "";
   string marketRegime = DetectMarketRegime(regimeWhy);

   if (AI_GateScoreMode)
   {
      g_gateTotal = 9;
      if (marketRegime == "NEWS_BLOCK" || marketRegime == "CHOP" || marketRegime == "RANGE")
      {
         g_gateFail = "Regime " + marketRegime + " - " + regimeWhy;
         return;
      }
      if (dirH1 == 0)
      {
         g_gateFail = "H1 bias FLAT - nema jasen pravec od povisok TF";
         return;
      }
      int dir = dirH1;
      if (AI_GateNeedH4H1 && !AI_GateH4Soft && (dirH4 == 0 || dirH4 != dir))
      {
         g_gateFail = "H4/H1 bias ne se soglasuvaat";
         return;
      }
      if (AI_GateNeedH4H1 && AI_GateH4Soft && dirH4 != 0 && dirH4 != dir)
      {
         int iH4 = AIMtfIdx("H4");
         double adxH4 = (iH4 >= 0) ? g_mtfAdx[iH4] : 0.0;
         if (adxH4 >= AI_GateMinADX)
         {
            g_gateFail = "H4 e SILNO protiv H1";
            return;
         }
      }
      if (!g_sigCachedHasStruct || g_sigCachedTrend == 0 ||
          g_sigCachedBOSLevel <= 0.0 || g_sigCachedTrend != dir)
      {
         g_gateFail = "EA struktura ne se soglasuva so gate nasokata";
         return;
      }
      if (AI_GateMaxSpreadPts > 0.0 && GetSpreadPoints() > AI_GateMaxSpreadPts)
      {
         g_gateFail = "Spread " + DoubleToString(GetSpreadPoints(), 1) + " > " +
                      DoubleToString(AI_GateMaxSpreadPts, 0) + " pts";
         return;
      }
      if (AI_GateSessionOnly && !IsTradingAllowed())
      {
         g_gateFail = "Nadvor od dozvolena sesija / time filter";
         return;
      }
      if (AI_GateNeedM5Timing && dirM5 != dir)
      {
         g_gateFail = "M5 tajming uste ne e vo nasoka";
         return;
      }
      int adxPts = (adxM15 >= AI_GateMinADX) ? 2 :
                   ((adxM15 >= AI_GateMinADX * 0.8) ? 1 : 0);
      int scorePts = (g_sigCachedScore >= AI_GateMinScore) ? 2 :
                     ((g_sigCachedScore >= AI_GateMinScore - AI_GateScoreSoftDelta) ? 1 : 0);
      int gradeRank = AIGradeRank(g_sigCachedGrade);
      int minGradeRank = AIGradeRank(AI_GateMinGrade);
      int gradePts = (gradeRank >= minGradeRank) ? 2 :
                     (gradeRank == minGradeRank - 1 ? 1 : 0);
      int m15Pts = (dirM15 == dir) ? 2 : (dirM15 == 0 ? 1 : 0);
      g_gateM15Flat = (dirM15 == 0);
      int rsiPts = ((dir == 1 && rsiM15 > 76.0) ||
                    (dir == -1 && rsiM15 < 24.0)) ? 0 : 1;
      int points = adxPts + scorePts + gradePts + m15Pts + rsiPts;
      g_gatePassed = points;
      g_gateOtherPass = true;
      g_gateDir = dir;
      string scoreBreakdown = "gate poeni " + IntegerToString(points) + "/" +
                              IntegerToString(g_gateTotal) + ": ADX=" + IntegerToString(adxPts) +
                              " Score=" + IntegerToString(scorePts) + " Grade=" + IntegerToString(gradePts) +
                              " M15=" + IntegerToString(m15Pts) + " RSI=" + IntegerToString(rsiPts);
      if (adxM15 < AI_GateAbsMinADX || points < AI_GateMinPoints)
      {
         g_gateFail = scoreBreakdown;
         g_gatePass = false;
         return;
      }
      g_gatePass = true;
      g_gateFail = "";
      g_gateWhy = "Regime " + marketRegime + ", " + scoreBreakdown +
                  ", ADX " + DoubleToString(adxM15, 1);
      return;
   }

   g_gateTotal++;
   if (marketRegime == "NEWS_BLOCK" || marketRegime == "CHOP" || marketRegime == "RANGE")
   {
      g_gateFail = "Regime " + marketRegime + " - " + regimeWhy;
      return;
   }
   g_gatePassed++;

   // ---- 1) Nasoka od povisokite timeframes ----
   int dir = 0;
   g_gateTotal++;
   if (AI_GateNeedH4H1 && AI_GateH4Soft)
   {
      int    iH4   = AIMtfIdx("H4");
      double adxH4 = (iH4 >= 0) ? g_mtfAdx[iH4] : 0.0;
      if (dirH1 == 0)
      { g_gateFail = "H1 bias FLAT - nema jasen pravec od povisok TF"; return; }
      if (dirH4 != 0 && dirH4 != dirH1 && adxH4 >= AI_GateMinADX)
      { g_gateFail = "H4 e SILNO protiv H1 (H4=" + (dirH4 == 1 ? "BULL" : "BEAR") +
                     " ADX(H4)=" + DoubleToString(adxH4, 1) + ")"; return; }
      dir = dirH1;
   }
   else if (AI_GateNeedH4H1)
   {
      if (dirH4 == 0 || dirH1 == 0)
      { g_gateFail = "H4/H1 bias FLAT - nema jasen pravec od povisok TF"; return; }
      if (dirH4 != dirH1)
      { g_gateFail = "H4 i H1 ne se soglasuvaat (H4=" + (dirH4 == 1 ? "BULL" : "BEAR") +
                     " H1=" + (dirH1 == 1 ? "BULL" : "BEAR") + ")"; return; }
      dir = dirH1;
   }
   else
   {
      dir = (dirH1 != 0) ? dirH1 : dirM15;
      if (dir == 0) { g_gateFail = "Nema pravec nitu na H1 nitu na M15"; return; }
   }
   g_gatePassed++;

   // ---- 2) M15 struktura vo istata nasoka ----
   if (AI_GateNeedM15)
   {
      g_gateTotal++;
      if (dirM15 != dir)
      {
         g_gateFail = "M15 ne e vo nasoka na H1/H4 (M15=" +
                      (iM15 >= 0 ? g_mtfBias[iM15] : "n/a") + ")";
         if (dirM15 == 0 && AI_GateM15FlatSoft)
            g_gateM15Flat = true;
         else
            return;
      }
      if (!g_gateM15Flat)
         g_gatePassed++;
   }

   // ---- 3) M5 tajming (opcionalno, postrogo) ----
   if (AI_GateNeedM5Timing)
   {
      g_gateTotal++;
      if (dirM5 != dir)
      { g_gateFail = "M5 tajming uste ne e vo nasoka"; return; }
      g_gatePassed++;
   }

   // ---- 4) Trend sila, ne chop ----
   if (AI_GateMinADX > 0.0)
   {
      g_gateTotal++;
      if (adxM15 < AI_GateMinADX)
      { g_gateFail = "ADX(M15)=" + DoubleToString(adxM15,1) + " < " +
                     DoubleToString(AI_GateMinADX,1) + " (chop, ne trend)"; return; }
      g_gatePassed++;
   }

   // ---- 5) EA struktura mora da se soglasi ----
   g_gateTotal++;
   if (g_sigCachedTrend != 0 && g_sigCachedTrend != dir)
   { g_gateFail = "EA struktura (" + (g_sigCachedTrend == 1 ? "Bull" : "Bear") +
                  ") sprotivna na MTF pravecot"; return; }
   g_gatePassed++;

   // ---- 6) Score / Grade ----
   if (AI_GateMinScore > 0)
   {
      g_gateTotal++;
      if (g_sigCachedScore < AI_GateMinScore)
      { g_gateFail = "Score " + IntegerToString(g_sigCachedScore) + " < " +
                     IntegerToString(AI_GateMinScore); return; }
      g_gatePassed++;
   }
   if (StringLen(AI_GateMinGrade) > 0)
   {
      g_gateTotal++;
      if (AIGradeRank(g_sigCachedGrade) < AIGradeRank(AI_GateMinGrade))
      { g_gateFail = "Grade " + g_sigCachedGrade + " < " + AI_GateMinGrade; return; }
      g_gatePassed++;
   }

   // ---- 7) Spread ----
   if (AI_GateMaxSpreadPts > 0.0)
   {
      g_gateTotal++;
      double sp = GetSpreadPoints();
      if (sp > AI_GateMaxSpreadPts)
      { g_gateFail = "Spread " + DoubleToString(sp,1) + " > " +
                     DoubleToString(AI_GateMaxSpreadPts,0) + " pts"; return; }
      g_gatePassed++;
   }

   // ---- 8) Sesija ----
   if (AI_GateSessionOnly)
   {
      g_gateTotal++;
      if (!IsTradingAllowed())
      { g_gateFail = "Nadvor od dozvolena sesija / time filter"; return; }
      g_gatePassed++;
   }

   // ---- 9) Ne brkaj vrv / dno ----
   if (AI_GateBlockRsiExtreme)
   {
      g_gateTotal++;
      if (dir == 1 && rsiM15 > 76.0)
      { g_gateFail = "RSI(M15)=" + DoubleToString(rsiM15,1) + " overbought - ne brkaj vrv"; return; }
      if (dir == -1 && rsiM15 < 24.0)
      { g_gateFail = "RSI(M15)=" + DoubleToString(rsiM15,1) + " oversold - ne brkaj dno"; return; }
      g_gatePassed++;
   }

   g_gateOtherPass = true;
   g_gateDir  = dir;
   if (g_gateM15Flat)
   {
      g_gatePass = false;
      return;
   }
   g_gatePass = true;
   g_gateWhy  = "Regime " + marketRegime + ", H4+H1 " + (dir == 1 ? "BULL" : "BEAR") +
                ", M15 " + (iM15 >= 0 ? g_mtfBias[iM15] : "n/a") +
                ", ADX " + DoubleToString(adxM15,1) +
                ", Score " + IntegerToString(g_sigCachedScore) + "/" + g_sigCachedGrade;
}

// ═══════════════════════════════════════════════════════════════════════════════
//  VISION - AI-to VISTINSKI go gleda chartot
//
//  ChartScreenShot() snima PNG vo <terminal>\MQL4\Files\TraceAI\ , a node serverot
//  gi chita site TraceAI folderi, pa gi prakja kako sliki do GPT-4o vision.
//  Grafikonite se otvaraat pri prviot scan i se zatvoraat po shot ili pri deinit.
// ═══════════════════════════════════════════════════════════════════════════════
int AITfFromName(string s)
{
   string u = s; StringToUpper(u);
   StringTrimLeft(u); StringTrimRight(u);
   if (u == "M1")  return PERIOD_M1;
   if (u == "M5")  return PERIOD_M5;
   if (u == "M15") return PERIOD_M15;
   if (u == "M30") return PERIOD_M30;
   if (u == "H1")  return PERIOD_H1;
   if (u == "H4")  return PERIOD_H4;
   if (u == "D1")  return PERIOD_D1;
   return 0;
}

// Marker vo komentarot na chartot - taka gi prepoznavame NASHITE vision charts
// i po restart / crash na terminalot, pa ne se mnozat.
#define VIS_TAG "TRACEAI_EYE"
#define CHAT_VISION_TAG "TRACEAI_CHAT_VISION"

bool AIVisionIsOurs(long cid)
{
   string cm = ChartGetString(cid, CHART_COMMENT);
   return (StringFind(cm, VIS_TAG, 0) >= 0);
}

// Zatvora SITE zaostanati vision charts (i od prethodni sesii / drugi instanci).
int AIVisionSweepOrphans(long keepCid)
{
   int closed = 0;
   long ids[64];
   ArrayInitialize(ids, -1);
   int  n = 0;
   long c = ChartFirst();
   while (c >= 0 && n < 64)
   {
      ids[n] = c; n++;
      c = ChartNext(c);
   }
   for (int i = 0; i < n; i++)
   {
      if (ids[i] == ChartID() || ids[i] == keepCid) continue;
      if (!AIVisionIsOurs(ids[i])) continue;
      ChartClose(ids[i]);
      closed++;
   }
   if (closed > 0) Print(">>> [Vision] Zatvoreni ", closed, " zaostanati EYE charts.");
   return closed;
}

// Samo EDNA instanca na EA-to smee da otvara ochi (inaku sekoj chart so EA
// otvara svoj set -> kaskada od prozorci).
string AIVisionLockName() { return "TraceAI_EYES_" + Symbol(); }

bool AIVisionClaimLock()
{
   string ln = AIVisionLockName();
   if (GlobalVariableCheck(ln))
   {
      long owner = (long)GlobalVariableGet(ln);
      if (owner != 0 && owner != ChartID())
      {
         // Dali sopstvenikot uste postoi?
         long c = ChartFirst();
         while (c >= 0)
         {
            if (c == owner) return false;   // druga ziva instanca gi drzi ochite
            c = ChartNext(c);
         }
      }
   }
   GlobalVariableSet(ln, (double)ChartID());
   return true;
}

void AIVisionReleaseLock()
{
   string ln = AIVisionLockName();
   if (GlobalVariableCheck(ln) && (long)GlobalVariableGet(ln) == ChartID())
      GlobalVariableDel(ln);
}

void AIVisionOpenCharts()
{
   g_visCount = 0;
   if (!AI_VisionEyes) return;
   if (IsTesting() || IsOptimization()) return;

   // ANTI-KASKADA 1: ako ovoj chart e nashe "oko" (znaci EA-to nekako se vcitalo na nego),
   // toj NIKOGASH ne smee da otvara novi prozorci.
   if (AIVisionIsOurs(ChartID()))
   {
      Print(">>> [Vision] Ovoj chart e EYE chart - ne otvoram nishto (anti-kaskada).");
      return;
   }

   // ANTI-KASKADA 2: ako veke ima premnogu otvoreni chartovi, ne dodavaj poveke.
   int chartCnt = 0;
   long cc = ChartFirst();
   while (cc >= 0 && chartCnt < 200) { chartCnt++; cc = ChartNext(cc); }
   if (chartCnt > 20)
   {
      Print(">>> [Vision] Ima ", chartCnt, " otvoreni chartovi - ne otvoram novi (anti-kaskada). ",
            "Zatvori gi vishokot pa reload EA.");
   }

   if (!AIVisionClaimLock())
   {
      Print(">>> [Vision] Ochite gi drzi DRUGA instanca na EA-to (", Symbol(),
            "). Ovoj chart nema da otvara prozorci.");
      return;
   }

   // Prvo iscisti zaostanati EYE charts od porano (samo NASHI, so marker).
   AIVisionSweepOrphans(0);

   // VAZNO: NE se koristi ChartSaveTemplate/ChartApplyTemplate!
   //  Template-ot na tekovniot chart go sodrzi I SAMOTO EA -> novootvoreniot chart
   //  bi go vcital EA-to, toj bi otvoril uste charts, i taka vo nedogled (kaskada).
   string list = AI_VisionTFs;
   if (StringLen(list) < 2) list = "M1,M5,M15,H1";
   list = list + ",";

   int guard = 0;
   while (StringLen(list) > 0 && g_visCount < 4 && guard < 16)
   {
      guard++;
      int cpos = StringFind(list, ",", 0);
      if (cpos < 0) break;
      string tok = StringSubstr(list, 0, cpos);
      list = StringSubstr(list, cpos + 1);
      StringTrimLeft(tok); StringTrimRight(tok);
      if (StringLen(tok) == 0) continue;

      int tf = AITfFromName(tok);
      if (tf == 0) continue;

      // Veke go imame ovoj TF? (npr. "M1,M1" vo inputot)
      bool dup = false;
      for (int d = 0; d < g_visCount; d++)
         if (g_visTfName[d] == TimeframeToString(tf)) dup = true;
      if (dup) continue;

      long cid = 0;
      bool owned = false;      // TRUE = nie go otvorivme, nie ke go zatvorime

      if (tf == Period())
      {
         cid = ChartID();               // tekovniot chart - ne otvoraj duplikat
      }
      else
      {
         // 1) PRVO probaj da iskoristish chart shto VEKE e otvoren (istiot simbol + TF).
         //    Taka nema novi prozorci, a i gi gledame tvoite nacrtani zoni.
         long e = ChartFirst();
         while (e >= 0)
         {
            if (e != ChartID() && ChartSymbol(e) == Symbol() && ChartPeriod(e) == tf)
            { cid = e; break; }
            e = ChartNext(e);
         }
         if (cid != 0)
         {
            Print(">>> [Vision] Koristam POSTOECHKI chart za ", tok, " (bez nov prozorec).");
            g_visChart[g_visCount]  = cid;
            g_visOwned[g_visCount]  = false;
            g_visTfName[g_visCount] = TimeframeToString(tf);
            g_visCount++;
            continue;
         }
         if (!AI_VisionOpenMissing || chartCnt > 20)
         {
            Print(">>> [Vision] Nema otvoren ", tok, " chart -> preskoknuvam (AI_VisionOpenMissing=",
                  (AI_VisionOpenMissing ? "true" : "false"), ", charts=", chartCnt, ").");
            continue;
         }

         // 2) Nema takov chart -> otvori nov (markiran, ke go zatvorime po shot/deinit).
         owned = true;
         cid = ChartOpen(Symbol(), tf);
         if (cid == 0)
         {
            Print(">>> [Vision] ChartOpen FAIL za ", tok, " err=", GetLastError());
            continue;
         }
         ChartSetString (cid, CHART_COMMENT, VIS_TAG + " " + TimeframeToString(tf));
         ChartSetInteger(cid, CHART_SHOW_GRID,       false);
         ChartSetInteger(cid, CHART_SHOW_PERIOD_SEP, true);
         ChartSetInteger(cid, CHART_AUTOSCROLL,      true);
         ChartSetInteger(cid, CHART_SHIFT,           true);
         ChartRedraw(cid);
         if (!ChatVisionWaitChart(cid, tf))
            Print(">>> [Vision] Chartot ne se vcita celosno za ", tok, ".");
      }
      g_visChart[g_visCount]  = cid;
      g_visOwned[g_visCount]  = owned;
      g_visTfName[g_visCount] = TimeframeToString(tf);
      g_visCount++;
   }
   Print(">>> [Vision] AI ochi na ", g_visCount, " charts (", AI_VisionTFs, ")");
}

bool AIVisionChartExists(long cid)
{
   if (cid <= 0 || cid == ChartID()) return false;
   long c = ChartFirst();
   while (c >= 0)
   {
      if (c == cid) return true;
      c = ChartNext(c);
   }
   return false;
}

bool AIVisionCloseOwnedChart(long cid, string label)
{
   if (cid <= 0 || cid == ChartID()) return false;
   if (!AIVisionChartExists(cid)) return true;
   if (!ChartClose(cid))
   {
      Print(">>> [Vision] ChartClose FAIL ", label, " err=", GetLastError());
      return false;
   }
   Print(">>> [Vision] zatvoren ", label);
   return true;
}

void AIVisionCloseAfterCapture()
{
   if (!AI_VisionCloseAfterShot) return;
   int kept = 0;
   for (int i = 0; i < g_visCount; i++)
   {
      bool remove = false;
      if (g_visOwned[i])
         remove = AIVisionCloseOwnedChart(g_visChart[i],
                                           "AI eye chart " + g_visTfName[i]);
      if (remove) continue;
      g_visChart[kept] = g_visChart[i];
      g_visOwned[kept] = g_visOwned[i];
      g_visTfName[kept] = g_visTfName[i];
      kept++;
   }
   for (int clear = kept; clear < 4; clear++)
   {
      g_visChart[clear] = 0;
      g_visOwned[clear] = false;
      g_visTfName[clear] = "";
   }
   g_visCount = kept;
}

void AIVisionCloseCharts()
{
   for (int i = 0; i < g_visCount; i++)
   {
      // Zatvoraj SAMO chartovi shto NIE gi otvorivme. Tvoite postoechki ostanuvaat.
      if (g_visOwned[i])
         AIVisionCloseOwnedChart(g_visChart[i],
                                 "AI eye chart " + g_visTfName[i]);
      g_visChart[i] = 0;
      g_visOwned[i] = false;
      g_visTfName[i] = "";
   }
   g_visCount = 0;

   // Chistenje/otkluchuvanje SAMO ako ovaa instanca gi drzi ochite - inaku bi gi
   // zatvorile chartovite na drugata instanca.
   string ln = AIVisionLockName();
   if (GlobalVariableCheck(ln) && (long)GlobalVariableGet(ln) == ChartID())
   {
      AIVisionSweepOrphans(0);
      AIVisionReleaseLock();
   }
}

// Vremeto na poslednoto slikanje se chuva vo GlobalVariables za da PREZHIVEE
// re-init (menuvanje na Inputs / restart), inaku EA-to slika vednash odnovo.
datetime VisionShotStampGet(string tag)
{
   string gv = "TraceVisShot_" + tag + "_" + Symbol();
   if (!GlobalVariableCheck(gv)) return 0;
   return (datetime)GlobalVariableGet(gv);
}

void VisionShotStampSet(string tag, datetime when)
{
   GlobalVariableSet("TraceVisShot_" + tag + "_" + Symbol(), (double)when);
}

// Po re-init listata so sliki e prazna, no PNG fajlovite se uste na disk.
string AIVisionFilesOnDisk()
{
   string arr = "";
   for (int i = 0; i < g_visCount; i++)
   {
      if (StringLen(g_visTfName[i]) == 0) continue;
      if (!FileIsExist("TraceAI\\shot_" + g_visTfName[i] + ".png")) continue;
      if (StringLen(arr) > 0) arr = arr + ",";
      arr = arr + "{\"tf\":\"" + g_visTfName[i] + "\",\"file\":\"TraceAI/shot_" +
            g_visTfName[i] + ".png\"}";
   }
   return arr;
}

// Snima PNG za sekoj vision chart. Vrakja JSON array so relativni pateki.
string AIVisionCapture(bool automatic)
{
   if (automatic && AiWeekendSkip()) return "";
   if (!AI_VisionEyes || g_visCount <= 0) return "";

   // THROTTLE: slikaj SAMO ednas na sekoi X sekundi. Bez ova, dva razlichni povici
   // (scan od OnTick i scan od dashboard/chat) pravat dve slikanja za nekolku sekundi.
   int shotEvery = (AI_VisionEverySec > 0) ? AI_VisionEverySec
                                           : ((AI_ScanEverySec > 0) ? AI_ScanEverySec : 90);
   if (g_visShotLocal == 0) g_visShotLocal = VisionShotStampGet("ai");
   if (StringLen(g_visFiles) == 0) g_visFiles = AIVisionFilesOnDisk();
   long shotAge = (long)TimeLocal() - (long)g_visShotLocal;
   if (g_visShotLocal > 0 && shotAge >= 0 && shotAge < shotEvery && StringLen(g_visFiles) > 0)
   {
      Print(">>> [Vision] SHOT SKIP (throttle): slikite se stari ", shotAge, "s od ",
            shotEvery, "s -> koristam postoechki sliki.");
      return g_visFiles;
   }

   int w = (AI_VisionWidth  < 320) ? 1024 : AI_VisionWidth;
   int h = (AI_VisionHeight < 240) ? 600  : AI_VisionHeight;

   // ChartScreenShot pisha VO TERMINALSKIOT MQL4\Files (NE vo Common\Files), pa
   // TraceAI folderot mora da postoi i tamu - inaku slikanjeto tivko pagja.
   static bool shotDirOK = false;
   if (!shotDirOK)
   {
      int hd = FileOpen("TraceAI\\__shotdir__.tmp", FILE_WRITE|FILE_BIN);
      if (hd != INVALID_HANDLE)
      {
         FileWriteInteger(hd, 79, 1);
         FileClose(hd);
         FileDelete("TraceAI\\__shotdir__.tmp");
         shotDirOK = true;
      }
      else
      {
         Print(">>> [Vision] Ne mozam da napravam MQL4\\Files\\TraceAI err=", GetLastError());
      }
   }

   string arr = "";
   int okCount = 0;
   int captureChartCount = g_visCount;
   for (int i = 0; i < g_visCount; i++)
   {
      if (g_visChart[i] == 0) continue;
      string fn = "TraceAI\\shot_" + g_visTfName[i] + ".png";
      ChartRedraw(g_visChart[i]);
      if (!ChartScreenShot(g_visChart[i], fn, w, h, ALIGN_RIGHT))
      {
         Print(">>> [Vision] ChartScreenShot FAIL ", fn, " err=", GetLastError());
         continue;
      }
      if (StringLen(arr) > 0) arr = arr + ",";
      arr = arr + "{\"tf\":\"" + g_visTfName[i] + "\",\"file\":\"TraceAI/shot_" + g_visTfName[i] + ".png\"}";
      okCount++;
   }
   AIVisionCloseAfterCapture();
   if (okCount > 0)
   {
      g_visShotTime  = TimeCurrent();
      g_visShotLocal = TimeLocal();
      VisionShotStampSet("ai", g_visShotLocal);
   }
   g_visFiles = arr;
   Print(">>> [Vision] Snimeni ", okCount, "/", captureChartCount,
         " sliki za GPT-4o vision.");
   return arr;
}

// ═══════════════════════════════════════════════════════════════════════════════
//  CSV LOG - bez merenje nema podobruvanje
// ═══════════════════════════════════════════════════════════════════════════════
void AILogSignalCSV(string sigKey, string gptDecision, double gptConf,
                    double entry, double sl, double tp)
{
   if (!AI_SignalCSVLog) return;
   if (sigKey == g_lastLoggedSigKey) return;
   g_lastLoggedSigKey = sigKey;

   string p = "TraceAI\\signals.csv";
   bool isNew = !FileIsExist(p, FILE_COMMON);
   int h = FileOpen(p, FILE_COMMON|FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, ';');
   if (h == INVALID_HANDLE) { Print(">>> [CSV] FileOpen fail err=", GetLastError()); return; }
   FileSeek(h, 0, SEEK_END);
   if (isNew)
      FileWrite(h, "time","symbol","gateDir","gateWhy","score","grade","adxM15",
                   "H4","H1","M15","M5","M1","gptDecision","gptConf","entry","sl","tp","spread");
   int iH4 = AIMtfIdx("H4"), iH1 = AIMtfIdx("H1"), iM15 = AIMtfIdx("M15");
   int iM5 = AIMtfIdx("M5"), iM1 = AIMtfIdx("M1");
   FileWrite(h,
      TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS),
      Symbol(),
      (g_gateDir == 1 ? "BUY" : (g_gateDir == -1 ? "SELL" : "NONE")),
      g_gateWhy,
      IntegerToString(g_sigCachedScore),
      g_sigCachedGrade,
      (iM15 >= 0 ? DoubleToString(g_mtfAdx[iM15],1) : "n/a"),
      (iH4  >= 0 ? g_mtfBias[iH4]  : "n/a"),
      (iH1  >= 0 ? g_mtfBias[iH1]  : "n/a"),
      (iM15 >= 0 ? g_mtfBias[iM15] : "n/a"),
      (iM5  >= 0 ? g_mtfBias[iM5]  : "n/a"),
      (iM1  >= 0 ? g_mtfBias[iM1]  : "n/a"),
      gptDecision,
      DoubleToString(gptConf, 2),
      DoubleToString(entry, Digits),
      DoubleToString(sl, Digits),
      DoubleToString(tp, Digits),
      DoubleToString(GetSpreadPoints(), 1));
   FileFlush(h);
   FileClose(h);
   Print(">>> [CSV] Signal zapisan vo TraceAI\\signals.csv");
}

// ===== Plan B (File Watcher Pipeline) helper functions =====
// BITNO: SITE FAJLOVI SE BINARY + UTF-8, bidejki Node.js pišuva so 'utf8' (FILE_TXT vo MQL4 gi reže na prvi \n)
// SE koristat MQL4 Files folder: FileOpen pisa vo  /MQL4/Files/TraceAI/*.json

bool AIMkTraceDir()
{
   string subFolder = "TraceAI";
   string hbPath   = subFolder + "\\heartbeat.txt";
   string testPath = subFolder + "\\__writetest__.tmp";
   int FLAGS =    FILE_COMMON|FILE_WRITE;
   int FLAGS_WO = FILE_COMMON|FILE_WRITE;
   int FLAGS_R  = FILE_COMMON|FILE_READ;

   // --- Proveri / napravi pishuva test ---
   int hw = FileOpen(testPath, FLAGS);
   if (hw == INVALID_HANDLE) hw = FileOpen(testPath, FILE_COMMON|FILE_WRITE);
   if (hw != INVALID_HANDLE)
   {
      FileWriteInteger(hw, 79, 1);
      FileWriteInteger(hw, 75, 1);
      FileFlush(hw);
      FileClose(hw);
      FileDelete(testPath, FILE_COMMON);
      return true;
   }
   // --- fallback: samo write ---
   hw = FileOpen(hbPath, FLAGS_WO);
   if (hw == INVALID_HANDLE) hw = FileOpen(hbPath, FILE_COMMON|FILE_WRITE);
   if (hw != INVALID_HANDLE)
   {
      FileWriteInteger(hw, 112, 1);
      FileWriteInteger(hw, 105, 1);
      FileWriteInteger(hw, 110, 1);
      FileWriteInteger(hw, 103, 1);
      FileFlush(hw);
      FileClose(hw);
      return true;
   }
   // --- posleden obid read ---
   int h = FileOpen(hbPath, FLAGS_R);
   if (h == INVALID_HANDLE) h = FileOpen(hbPath, FILE_COMMON|FILE_READ);
   if (h != INVALID_HANDLE) { FileClose(h); return true; }
   return false;
}

string AIReadFileBinary(string relPath)
{
   long sz = -1;
   int h = INVALID_HANDLE;
   h = FileOpen(relPath, FILE_COMMON|FILE_READ);
   if (h == INVALID_HANDLE)
   {
      int gleC1 = GetLastError();
      Print(">>> [Plan B] Read (COMMON) fail ", relPath, " err=", gleC1, " (probuvam LOCAL+READ)");
      h = FileOpen(relPath, FILE_READ);
      if (h == INVALID_HANDLE) {
         Print(">>> [Plan B] Read ALL MODES FAIL for ", relPath, " err=", GetLastError());
         return "";
      }
   }
   sz = (long)FileSize(h);
   Print(">>> [Plan B] Open OK ", relPath, " FileSize=", sz);
   FileSeek(h, 0, SEEK_SET);
   int totalCount = 0;
   string s = "";
   // ====== 100% METOD: Line-by-line (vo TEXT mode FileReadString(h,size) se reže na prviot \n!) ======
   //    Node.js koristi JSON.stringify(null, 2) -> prva linija samo '{', pa ostatokot naniza.
   // ============================================================================================
   if (sz > 0)
   {
      // Probaj edno golamo citanje (za slucaj ako e single-line JSON, npr heartbeat)
      int isz = (int)MathMin((double)sz, 999999.0);
      s = FileReadString(h, isz);
      totalCount = StringLen(s);
      // AKO E PREKRATKO (znaci 1 linija, a e pretty JSON -> site naredni linii):
      // citaj gi site line-by-line i spoj so \n
      if ((long)totalCount < sz - 50 || totalCount <= 3)
      {
         int safe = 0;
         while (!FileIsEnding(h) && safe < 5000)
         {
            string ln = FileReadString(h, 4096);
            if (StringLen(ln) == 0 && FileIsEnding(h)) break;
            s = s + "\n" + ln;
            safe++;
         }
         totalCount = StringLen(s);
      }
   }
   if (totalCount < 2)
   {
      int safe = 0;
      while (!FileIsEnding(h) && safe < 5000)
      {
         string ln = FileReadString(h, 0);
         if (StringLen(ln) == 0 && FileIsEnding(h)) break;
         if (s != "") s = s + "\n";
         s = s + ln;
         safe++;
      }
      totalCount = StringLen(s);
   }
   // Debug: prvichni 5 kodovi
   int b0 = (totalCount > 0 ? StringGetCharacter(s, 0) : 0);
   int b1 = (totalCount > 1 ? StringGetCharacter(s, 1) : 0);
   int b2 = (totalCount > 2 ? StringGetCharacter(s, 2) : 0);
   int b3 = (totalCount > 3 ? StringGetCharacter(s, 3) : 0);
   int b4 = (totalCount > 4 ? StringGetCharacter(s, 4) : 0);
   Print(">>> [Plan B] DBG first5 chars: ", b0, " ", b1, " ", b2, " ", b3, " ", b4, "  (JSON=123 { OK )");
   FileClose(h);
   if (totalCount <= 0) {
      Print(">>> [Plan B] Read 0 bytes for ", relPath, " (FileSize bilo ", sz, ")");
      return "";
   }
   Print(">>> [Plan B] Read OK ", relPath, " bytes=", sz, " len=", totalCount);
   return s;
}

bool AIWriteFileBinaryOne(string relPath, string content, bool useCommon,
                          int &wantedOut, int &writtenOut, long &readBackOut)
{
   wantedOut = 0;
   writtenOut = 0;
   readBackOut = -1;
   int flags = FILE_WRITE|FILE_BIN;
   if (useCommon) flags |= FILE_COMMON;
   int hw = FileOpen(relPath, flags);
   if (hw == INVALID_HANDLE) return false;
   FileSeek(hw, 0, SEEK_SET);
   char data[];
   int L = StringToCharArray(content, data, 0, -1, CP_UTF8);
   int toWrite = (L > 1) ? (L - 1) : 0;
   int wr = 0;
   // ====== 100% stabilen: pisuva Bajt po Bajt (izbegnuva 5018 FileWriteArray+char bug) ======
   if (toWrite > 0)
   {
      for (int wi = 0; wi < toWrite; wi++)
      {
         int bb = data[wi];
         if (bb < 0) bb = bb + 256;
         FileWriteInteger(hw, bb, 1);
         wr++;
      }
   }
   FileFlush(hw);
   FileClose(hw);
   wantedOut = toWrite;
   writtenOut = wr;

   int verifyFlags = FILE_READ|FILE_BIN;
   if (useCommon) verifyFlags |= FILE_COMMON;
   int verify = FileOpen(relPath, verifyFlags);
   if (verify != INVALID_HANDLE)
   {
      readBackOut = (long)FileSize(verify);
      FileClose(verify);
   }
   return (toWrite == 0 || wr == toWrite) && readBackOut == toWrite;
}

bool AIWriteFileBinary(string relPath, string content)
{
   if (!AIMkTraceDir()) return false;

   // ChartScreenShot and the chat file pipeline use the terminal-local folder.
   // Ensure it exists before writing the duplicate local copy.
   int localTest = FileOpen("TraceAI\\__localwritetest__.tmp", FILE_WRITE|FILE_BIN);
   if (localTest != INVALID_HANDLE)
   {
      FileClose(localTest);
      FileDelete("TraceAI\\__localwritetest__.tmp");
   }

   int commonWanted = 0; int commonWritten = 0; long commonReadBack = -1;
   int localWanted = 0; int localWritten = 0; long localReadBack = -1;
   bool commonOK = AIWriteFileBinaryOne(relPath, content, true,
                                        commonWanted, commonWritten, commonReadBack);
   int commonErr = (commonOK ? 0 : GetLastError());
   bool localOK = AIWriteFileBinaryOne(relPath, content, false,
                                       localWanted, localWritten, localReadBack);
   int localErr = (localOK ? 0 : GetLastError());
   string commonPath = TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files\\" + relPath;
   string localPath = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL4\\Files\\" + relPath;
   if (DebugMode && relPath == "TraceAI\\scan.json")
      Print(">>> [Plan B] WRITE DEBUG COMMON path=", commonPath,
            " requested=", commonWanted, " wrote=", commonWritten,
            " readBackSize=", commonReadBack, " ok=", (commonOK ? "1" : "0"),
            " err=", commonErr,
            " | LOCAL path=", localPath,
            " requested=", localWanted, " wrote=", localWritten,
            " readBackSize=", localReadBack, " ok=", (localOK ? "1" : "0"),
            " err=", localErr);
   return commonOK || localOK;
}

bool AIReadHeartbeatTxt()
{
   if (!AIMkTraceDir()) return false;
   string hbPath = "TraceAI\\heartbeat.txt";
   datetime hbParsed = 0;
   string txt = AIReadFileBinary(hbPath);
   if (StringLen(txt) < 5)
   {
      g_aiHbAgeSec = -1;
      g_aiLastHeartbeatTime = 0;
      return false;
   }
   string ln = txt;
   int nn = StringFind(txt, "\r\n", 0); if (nn > 0) ln = StringSubstr(txt, 0, nn);
   int n  = StringFind(txt, "\n", 0);   if (n  > 0 && (nn < 0 || n < nn)) ln = StringSubstr(txt, 0, n);
   StringTrimLeft(ln); StringTrimRight(ln);

   // ══ EXTRA DEBUG: citaj LINE 4 (tick=) + LINE 5 (pid=) + LINE 6 (local=YYYY.MM.DD HH:MM:SS) ══
   string tickLine = ""; string pidLine = ""; string localLine = "";
   {
      string rest = txt;
      int lineNum = 0;
      while (StringLen(rest) > 0 && lineNum < 8)
      {
         int nn2 = StringFind(rest, "\r\n", 0);
         int n2  = StringFind(rest, "\n", 0);
         string oneLine = rest;
         string nextRest = "";
         if (nn2 >= 0 && (n2 < 0 || nn2 <= n2)) { oneLine = StringSubstr(rest, 0, nn2); nextRest = StringSubstr(rest, nn2+2); }
         else if (n2 >= 0)                     { oneLine = StringSubstr(rest, 0, n2);  nextRest = StringSubstr(rest, n2+1); }
         lineNum++;
         StringTrimLeft(oneLine); StringTrimRight(oneLine);
         if (lineNum == 4) tickLine = oneLine;
         if (lineNum == 5) pidLine  = oneLine;
         if (lineNum == 6) localLine = oneLine;
         rest = nextRest;
      }
   }

   bool ok = (StringLen(ln) > 3);
   string mode = "none";
   int hbAge = -1;
   if (ok)
   {
      long unixSec = StringToInteger(ln);          // 1-va linija = UTC unix sekundi
      if (unixSec >= 1000000000) hbParsed = (datetime)unixSec;
      hbAge = AIFreshnessAgeSec(unixSec, localLine, mode);   // localLine = "local=YYYY.MM.DD HH:MM:SS"
   }

   if (hbAge >= 0)
   {
      g_aiHbAgeSec = hbAge;
      // Chuvame vo BROKER skala za da (TimeCurrent() - g_aiLastHeartbeatTime) == REALEN vozrast.
      g_aiLastHeartbeatTime = TimeCurrent() - hbAge;
      g_aiLastHeartbeatContent = ln;
   }
   else
   {
      // Bez upotrebliv timestamp NE smeeme da se pravime deka serverot e ziv.
      g_aiHbAgeSec = -1;
      g_aiLastHeartbeatTime = 0;
   }

   bool hbFresh = (hbAge >= 0 && hbAge <= AIOfflineLimitSec());
   Print(">>> [Plan B] Heartbeat txt: len=", StringLen(txt), " firstLine=", ln,
         " ok=", ok ? "1" : "0",
         " mode=", mode,
         " tick=", tickLine, " ", pidLine, " ", localLine,
         " ageSec=", (hbAge >= 0 ? IntegerToString(hbAge) : "N/A"),
         " limit=", IntegerToString(AIOfflineLimitSec()),
         " FRESH=", hbFresh ? "1" : "0",
         " parsedTs=", (hbParsed > 0 ? IntegerToString((int)hbParsed) : "0"));
   return hbFresh;
}

bool AIWriteScanFile(string json)
{
   bool wr = AIWriteFileBinary("TraceAI\\scan.json", json);
   if (wr) Print(">>> [Plan B] scan.json zapisan ok, bytes=", StringLen(json));
   else    Print(">>> [Plan B] scan.json NE MOZHAM da zapisham (read-only? path gresen?)");
   return wr;
}

bool AIReadResultFile(string &decision, double &confidence,
                      string &r1, string &r2, string &r3,
                      double &entry, double &sl, double &tp, string &comment)
{
   if (!AIMkTraceDir()) return false;
   string json = AIReadFileBinary("TraceAI\\result.json");
   Print(">>> [Plan B] result.json read: len=", StringLen(json), " substr(0,160)=", StringSubstr(json, 0, 160));
   if (StringLen(json) < 20)
   {
      Print(">>> [Plan B] result.json premalen / prazen.");
      g_aiRsAgeSec = -1; g_aiLastResultTs = 0; g_aiResultFresh = false;
      return false;
   }
   string okS = AIJstring(json, "ok");
   if (okS == "false" || okS == "0" || okS == "False" || okS == "FALSE") {
      Print(">>> [Plan B] result.json ok=false -> skip.");
      g_aiResultFresh = false;
      return false;
   }
   string d = AIJstring(json, "decision");
   StringTrimLeft(d); StringTrimRight(d);
   if (d == "") { Print(">>> [Plan B] result.json decision prazno -> fail."); g_aiResultFresh = false; return false; }
   string sAt = AIJstring(json, "scannedAt");
   string sAtLoc = AIJstring(json, "scannedAtLocal");   // ⭐⭐⭐ Lokalniot format, najtochen!
   string cStr = AIJstring(json, "confidence");
   double conf = (cStr == "") ? 0.0 : StringToDouble(cStr);

   // ══════════ FRESHNESS: realen vozrast, BEZ mesanje na chasovnici ══════════
   datetime scanParsed = 0;
   string   scanMode   = "none";
   long     scanUnix   = 0;

   // PRIO 1: "scannedAtUnix": 1785523689   (broj, UTC unix sekundi - najtochno)
   int posU = StringFind(json, "\"scannedAtUnix\"", 0);
   if (posU >= 0)
   {
      int posCol = StringFind(json, ":", posU + 10);
      if (posCol > posU)
      {
         int i = posCol + 1;
         int len = StringLen(json);
         while (i < len)
         {
            int ch = StringGetCharacter(json, i);
            if (ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n') { i++; continue; }
            break;
         }
         int start = i;
         while (i < len)
         {
            int ch2 = StringGetCharacter(json, i);
            if (ch2 >= '0' && ch2 <= '9') { i++; continue; }
            break;
         }
         if (i > start)
         {
            long numVal = StringToInteger(StringSubstr(json, start, i - start));
            if (numVal >= 1000000000) scanUnix = numVal;
         }
      }
   }

   // PRIO 2: ISO "scannedAt" (isto UTC) -> StringToTime na "goliot" datum dava UTC unix
   if (scanUnix <= 0 && StringLen(sAt) >= 10)
   {
      string clean = sAt;
      StringReplace(clean, "-", ".");
      int posT2 = StringFind(clean, "T", 0);
      if (posT2 > 0)
      {
         string sDate = StringSubstr(clean, 0, posT2);
         string sTime = "";
         int posD  = StringFind(clean, ".", posT2);
         int posZ2 = StringFind(clean, "Z", posT2);
         int endT2 = -1;
         if (posD  > posT2) endT2 = posD;
         if (posZ2 > posT2 && (endT2 < 0 || posZ2 < endT2)) endT2 = posZ2;
         if (endT2 > posT2) sTime = StringSubstr(clean, posT2 + 1, endT2 - posT2 - 1);
         else               sTime = StringSubstr(clean, posT2 + 1);
         datetime isoT = StringToTime(sDate + " " + sTime);
         if (isoT > 946684800) scanUnix = (long)isoT;
      }
   }

   // PRIO 3 (fallback): "scannedAtLocal" po PC chas -> se sporeduva so TimeLocal()
   int rsAge = AIFreshnessAgeSec(scanUnix, sAtLoc, scanMode);
   if (scanUnix >= 1000000000) scanParsed = (datetime)scanUnix;

   if (rsAge >= 0)
   {
      g_aiRsAgeSec     = rsAge;
      g_aiLastResultTs = TimeCurrent() - rsAge;   // broker skala -> dashboard presmetkite ostanuvaat tochni
   }
   else
   {
      g_aiRsAgeSec     = -1;
      g_aiLastResultTs = 0;
   }
   g_aiResultFresh = (rsAge >= 0 && rsAge <= AIResultStaleLimitSec());

   // NOV rezultat = drug potpis od posledniot. (Prethodno ova sekogash davase 0,
   // bidejki g_aiLastResultTs se prepishuvase PRED sporedbata.)
   string sig = sAt + "|" + d + "|" + cStr;
   bool isNewResult = (sig != g_aiLastResultSignature);
   if (isNewResult) g_aiLastResultSignature = sig;

   decision = d;
   confidence = conf;
   r1 = AIJarrIdx(json, "reasons", 0);
   r2 = AIJarrIdx(json, "reasons", 1);
   r3 = AIJarrIdx(json, "reasons", 2);
   string eStr = AIJstring(json, "suggestedEntry"); entry = (eStr == "") ? 0.0 : StringToDouble(eStr);
   string sStr = AIJstring(json, "suggestedSL");     sl    = (sStr == "") ? 0.0 : StringToDouble(sStr);
   string tStr = AIJstring(json, "suggestedTP");     tp    = (tStr == "") ? 0.0 : StringToDouble(tStr);
   string cm   = AIJstring(json, "message");   comment = (cm == "") ? "" : cm;
   g_aiLastResultFtime = TimeCurrent();
   Print(">>> [Plan B] result.json PARSE OK: d=", d, " conf=", DoubleToString(confidence, 2),
         " mode=", scanMode,
         " scannedAt=", sAt,
         " parsedTs=", (scanParsed > 0 ? IntegerToString((int)scanParsed) : "-1"),
         " ageSec=", (rsAge >= 0 ? IntegerToString(rsAge) : "N/A"),
         " limit=", IntegerToString(AIResultStaleLimitSec()),
         " USABLE=", g_aiResultFresh ? "1" : "0",
         " isNew=", isNewResult ? "1" : "0");
   return true;
}

string AIJstring(string json, string key)
{
   string pat = "\"" + key + "\"";
   int k = StringFind(json, pat, 0);
   if (k < 0) return "";
   int colon = StringFind(json, ":", k + StringLen(pat));
   if (colon < 0) return "";
   int i = colon + 1;
   while (i < StringLen(json))
   {
      ushort cc = StringGetChar(json, i);
      if (cc != 32 && cc != 9 && cc != 10 && cc != 13) break;
      i++;
   }
   if (i >= StringLen(json)) return "";
   ushort fc = StringGetChar(json, i);
   if (fc == 34)
   {
      i++;
      string out = "";
      while (i < StringLen(json))
      {
         ushort c = StringGetChar(json, i);
         if (c == 34) break;
         if (c == 92 && i + 1 < StringLen(json))
         {
            ushort n = StringGetChar(json, i + 1);
            if      (n == 34)  out = out + "\"";
            else if (n == 110) out = out + " ";
            else if (n == 116) out = out + " ";
            else if (n == 92)  out = out + "\\";
            else               out = out + ShortToString(n);
            i += 2;
         }
         else
         {
            out = out + ShortToString(c);
            i++;
         }
      }
      return out;
   }
   else
   {
      string out = "";
      while (i < StringLen(json))
      {
         ushort c = StringGetChar(json, i);
         if (c == 44 || c == 125 || c == 93 || c == 10 || c == 13) break;
         out = out + ShortToString(c);
         i++;
      }
      string tmpTrim2 = out;
      StringTrimLeft(tmpTrim2);
      StringTrimRight(tmpTrim2);
      return tmpTrim2;
   }
}

string AIJarrIdx(string json, string key, int idx)
{
   string pat = "\"" + key + "\"";
   int k = StringFind(json, pat, 0);
   if (k < 0) return "";
   int brO = StringFind(json, "[", k);
   if (brO < 0) return "";
   int pos = brO + 1;
   int cur = 0;
   while (pos < StringLen(json) && cur <= idx)
   {
      while (pos < StringLen(json))
      {
         ushort cc = StringGetChar(json, pos);
         if (cc != 32 && cc != 9 && cc != 10 && cc != 13) break;
         pos++;
      }
      if (pos >= StringLen(json)) return "";
      ushort fc = StringGetChar(json, pos);
      string val = "";
      if (fc == 34)
      {
         pos++;
         while (pos < StringLen(json))
         {
            ushort c = StringGetChar(json, pos);
            if (c == 34) { pos++; break; }
            if (c == 92 && pos + 1 < StringLen(json))
            {
               ushort n = StringGetChar(json, pos + 1);
               if      (n == 34)  val = val + "\"";
               else if (n == 110) val = val + " ";
               else if (n == 116) val = val + " ";
               else               val = val + ShortToString(n);
               pos += 2;
            }
            else
            {
               val = val + ShortToString(c);
               pos++;
            }
         }
      }
      else
      {
         while (pos < StringLen(json))
         {
            ushort c = StringGetChar(json, pos);
            if (c == 44 || c == 93) break;
            val = val + ShortToString(c);
            pos++;
         }
      }
      if (cur == idx) return val;
      cur++;
      while (pos < StringLen(json))
      {
         ushort cc = StringGetChar(json, pos);
         if (cc == 44) { pos++; break; }
         if (cc == 93) return "";
         pos++;
      }
   }
   return "";
}

void AICheckServerAliveNow()
{
   static datetime lastH = 0;
   datetime now = TimeCurrent();
   if (lastH > 0 && (now - lastH) < 12) return;
   lastH = now;
   g_aiLastHealthTime = now;

   // ══ Plan B (FILES): PROCHITAJ GI SITE TRI na sekoj tick (HB + RESULT + SCAN) ══
   //    nikoj ne vrakja "return" za da ne propustime update na drugite globalni promenlivi!
   bool hbFresh = AIReadHeartbeatTxt();   // TRUE samo ako heartbeat.txt e POSVEZH od AI_OfflineAfterSec
   string dumD=""; double dumC=0, dumE=0, dumS=0, dumT=0; string dumR1="", dumR2="", dumR3="", dumCm="";
   AIReadResultFile(dumD, dumC, dumR1, dumR2, dumR3, dumE, dumS, dumT, dumCm);
   // Za "dali serverot e ziv" se koristi KRATKIOT limit, ne limitot za upotreblivost na odlukata.
   bool rsFresh = (g_aiRsAgeSec >= 0 && g_aiRsAgeSec <= AIOfflineLimitSec());

   // ⭐ ONLINE = nekoj od dvata fajla e SVEZH. Samo toa sto fajlot POSTOI na disk
   //    NE znachi deka serverot raboti - fajlovite ostanuvaat i po gasenje na node.
   g_aiServerOnline = (hbFresh || rsFresh);
   g_aiLastScanOK   = g_aiServerOnline;
   Print(">>> [Plan B] FILES: hbFresh=", hbFresh ? "1" : "0", " rsFresh=", rsFresh ? "1" : "0",
         " hbAge=", (g_aiHbAgeSec >= 0 ? IntegerToString(g_aiHbAgeSec) : "N/A"),
         " rsAge=", (g_aiRsAgeSec >= 0 ? IntegerToString(g_aiRsAgeSec) : "N/A"),
         " limit=", IntegerToString(AIOfflineLimitSec()),
         "s  =>  SERVER ", g_aiServerOnline ? "ONLINE" : "OFFLINE");
   // ---- Plan A (WEBREQUEST): fallback ako dvata FILE fail-naa
   if (g_aiLastScanOK) return;  // site podatocite od FILES se tochni, ne treba HTTP
   string baseUrl = AI_ServerURL;
   if (StringLen(baseUrl) == 0) { if (!g_aiLastScanOK) g_aiLastScanOK = false; return; }
   if (StringSubstr(baseUrl, StringLen(baseUrl) - 1, 1) == "/")
      baseUrl = StringSubstr(baseUrl, 0, StringLen(baseUrl) - 1);

   string url = baseUrl + "/ai/health";
   char resp[];
   int rc = AIWrGet(url, resp, 60000, "127.0.0.1", "localhost");
   if (rc < 0 && StringFind(url, "localhost") >= 0)
      rc = AIWrGet(url, resp, 60000, "localhost", "127.0.0.1");
   string htxt = CharArrayToString(resp);
   Print(">>> AI HEALTH (Plan A fallback) rc="+IntegerToString(rc)+" len="+IntegerToString(StringLen(htxt))+" resp="+StringSubstr(htxt, 0, 160));
   if (rc == 200)
   {
      g_aiLastScanOK = true;
      if (StringFind(htxt, "\"hasKey\":false") >= 0)
      {
         if (StringFind(g_aiLastMsg, "kluc") < 0)
            g_aiLastMsg = g_aiLastMsg + " | Serverot e ziv, NO API kluc ne e setiran (OPENAI_API_KEY).";
      }
   }
   else
   {
      // ═══ FAIL! rc != 200 znachi serverot NE ODGOVARA - vednash stavi go kako DEAD za HTTP ═══
      g_aiLastScanOK = false;
      // NE setuvaj g_aiLastHealthTime = 0; so toa se menuva i rendererot na OFF TIMEOUT so pogolem soodnos
      // (ostavame go kako e za da go vidime age-ot vo tekstot)
      if (StringFind(g_aiLastMsg, "Health") < 0)
      {
         g_aiLastMsg = g_aiLastMsg + " | Health fail: rc=" + IntegerToString(rc)
                     + ". Restartni StartTraceAI.bat (serverot da ispise heartbeat.txt).";
      }
   }
}

bool AiWeekendSkip()
{
   if (!AI_SkipWeekend) return false;
   datetime now = TimeCurrent();
   int dow = TimeDayOfWeek(now);
   if (dow != 0 && dow != 6) return false;
   static int lastLoggedDay = -1;
   int day = TimeYear(now) * 10000 + TimeMonth(now) * 100 + TimeDay(now);
   if (day != lastLoggedDay)
   {
      lastLoggedDay = day;
      Print(">>> [Plan B] SCAN SKIP: vikend (AI_SkipWeekend=true).");
   }
   return true;
}

void AIScanMarketNow()
{
   if (AiWeekendSkip()) return;
   if (AI_ScanSessionOnly && !IsTradingAllowed())
   {
      static datetime lastSessionSkip = 0;
      datetime sessionNow = TimeCurrent();
      if (sessionNow - lastSessionSkip >= 900)
      {
         lastSessionSkip = sessionNow;
         Print(">>> [Plan B] SCAN SKIP: nadvor od dozvolena sesija.");
      }
      return;
   }
   if (!ChatMinuteWindowOpen(TimeCurrent(), AI_ScanStartHour, AI_ScanStartMinute,
                             AI_ScanEndHour, AI_ScanEndMinute))
   {
      static datetime lastScanWindowSkip = 0;
      datetime scanWindowNow = TimeCurrent();
      if (scanWindowNow - lastScanWindowSkip >= 900)
      {
         lastScanWindowSkip = scanWindowNow;
         Print(">>> [Plan B] SCAN SKIP: nadvor od platen AI scan prozorec.");
      }
      return;
   }
   // THROTTLE: koristi PC chasovnik (TimeLocal), NE TimeCurrent (broker time).
   // Ako broker vremeto skokne napred, (now-lastScan) ostanuva negativno zasekogash
   // i EA-to nikogash poveke ne skenira. Tuka i negativna razlika = resetiraj.
   static datetime lastScanLocal = 0;
   datetime nowLocal = TimeLocal();
   int interval = (AI_ScanEverySec <= 0) ? 90 : AI_ScanEverySec;
   long dSec = (long)nowLocal - (long)lastScanLocal;
   if (lastScanLocal > 0)
   {
      if (dSec < 0)
      {
         Print(">>> [Plan B] SCAN THROTTLE RESET: chasovnikot skoknal nazad/napred (d=", dSec, "s).");
         lastScanLocal = 0;
      }
      else if (dSec < interval)
      {
         static datetime lastSkipLog = 0;
         if (nowLocal - lastSkipLog >= 30)
         {
            lastSkipLog = nowLocal;
            Print(">>> [Plan B] SCAN SKIP (throttle): pominale ", dSec, "s od ",
                  interval, "s. Sleden scan za ", (interval - dSec), "s.");
         }
         return;
      }
   }
   lastScanLocal = nowLocal;
   g_aiLastScanTime = TimeCurrent();
   Print(">>> [Plan B] SCAN START (interval=", interval, "s, local=", TimeToString(nowLocal, TIME_DATE|TIME_MINUTES|TIME_SECONDS), ")");

   string baseUrl = AI_ServerURL;
   if (StringSubstr(baseUrl, StringLen(baseUrl) - 1, 1) == "/")
      baseUrl = StringSubstr(baseUrl, 0, StringLen(baseUrl) - 1);

   int structTF = (g_sigCachedStructTF > 0) ? g_sigCachedStructTF : Period();
   int digits = Digits; if (digits == 0) digits = 2;
   int tfBars = iBars(Symbol(), structTF);
   int N = (tfBars < 20) ? MathMax(5, tfBars - 1) : 20;
   string closesArr = "";
   for (int i = N - 1; i >= 0; i--)
   {
      if (i >= tfBars) continue;
      double cl = iClose(Symbol(), structTF, i);
      if (StringLen(closesArr) > 0) closesArr = closesArr + ",";
      closesArr = closesArr + DoubleToString(cl, digits);
   }

   double adx = iADX(Symbol(), structTF, 14, PRICE_CLOSE, MODE_MAIN, 1);
   double rsi = iRSI(Symbol(), structTF, 14, PRICE_CLOSE, 1);
   double ema = iMA (Symbol(), structTF, 200, 0, MODE_EMA,   PRICE_CLOSE, 1);
   int chartTF = Period();
   double chartAdx = iADX(Symbol(), chartTF, 14, PRICE_CLOSE, MODE_MAIN, 1);
   double chartRsi = iRSI(Symbol(), chartTF, 14, PRICE_CLOSE, 1);
   double chartEma = iMA (Symbol(), chartTF, 200, 0, MODE_EMA,   PRICE_CLOSE, 1);
   int chartBars = iBars(Symbol(), chartTF);
   int cN = (chartBars < 20) ? MathMax(5, chartBars - 1) : 20;
   string chartClosesArr = "";
   for (int ci = cN - 1; ci >= 0; ci--)
   {
      if (ci >= chartBars) continue;
      double ccl = iClose(Symbol(), chartTF, ci);
      if (StringLen(chartClosesArr) > 0) chartClosesArr = chartClosesArr + ",";
      chartClosesArr = chartClosesArr + DoubleToString(ccl, digits);
   }
   double priceNow = (Bid > 0.0) ? Bid : iClose(Symbol(), Period(), 0);
   string actionTag = (StringLen(g_sigCachedAction) > 0) ? g_sigCachedAction : "n/a";

   // ══════════ MULTI-TIMEFRAME "OCHI": M1 M5 M15 M30 H1 H4 D1 ══════════
   //    AI-to dobiva sostojba na SEKOJ timeframe, ne samo na strukturniot.
   string mtfJson = "";
   for (int mz = 0; mz < MTF_N; mz++)
   {
      g_mtfName[mz] = ""; g_mtfBias[mz] = "";
      g_mtfAdx[mz] = 0.0; g_mtfRsi[mz] = 50.0;
      g_mtfClose[mz] = 0.0; g_mtfEma200[mz] = 0.0;
   }
   if (AI_MultiTFEyes)
   {
      int mtfTFs[7];
      mtfTFs[0] = PERIOD_M1;  mtfTFs[1] = PERIOD_M5;  mtfTFs[2] = PERIOD_M15;
      mtfTFs[3] = PERIOD_M30; mtfTFs[4] = PERIOD_H1;  mtfTFs[5] = PERIOD_H4;
      mtfTFs[6] = PERIOD_D1;
      for (int mi = 0; mi < 7; mi++)
      {
         int tfx = mtfTFs[mi];
         int barsX = iBars(Symbol(), tfx);
         if (barsX < 30) continue;
         int look = 50; if (barsX - 2 < look) look = barsX - 2;
         if (look < 5) look = 5;

         double emaF = iMA (Symbol(), tfx, 50,  0, MODE_EMA, PRICE_CLOSE, 1);
         double emaS = iMA (Symbol(), tfx, 200, 0, MODE_EMA, PRICE_CLOSE, 1);
         double rsiX = iRSI(Symbol(), tfx, 14, PRICE_CLOSE, 1);
         double adxX = iADX(Symbol(), tfx, 14, PRICE_CLOSE, MODE_MAIN, 1);
         double atrX = iATR(Symbol(), tfx, 14, 1);
         double clX  = iClose(Symbol(), tfx, 1);
         double hiX  = iHigh(Symbol(), tfx, iHighest(Symbol(), tfx, MODE_HIGH, look, 1));
         double loX  = iLow (Symbol(), tfx, iLowest (Symbol(), tfx, MODE_LOW,  look, 1));

         // MTF bias za AI/panel treba da go sledi istiot BOS market structure model,
         // ne spor EMA trend filter shto moze da kasni i da izgleda kontra na chartot.
         string biasX = AIMtfStructureBias(tfx, 1);

         int nX = (barsX < 13) ? (barsX - 1) : 12;
         string closesX = "";
         for (int cix = nX; cix >= 1; cix--)
         {
            if (StringLen(closesX) > 0) closesX = closesX + ",";
            closesX = closesX + DoubleToString(iClose(Symbol(), tfx, cix), digits);
         }

         g_mtfName[mi]   = TimeframeToString(tfx);
         g_mtfBias[mi]   = biasX;
         g_mtfAdx[mi]    = adxX;
         g_mtfRsi[mi]    = rsiX;
         g_mtfClose[mi]  = clX;
         g_mtfEma200[mi] = emaS;

         if (StringLen(mtfJson) > 0) mtfJson = mtfJson + ",";
         mtfJson = mtfJson + "{"
                 + "\"tf\":\""    + TimeframeToString(tfx)      + "\","
                 + "\"close\":"   + DoubleToString(clX,  digits) + ","
                 + "\"ema50\":"   + DoubleToString(emaF, digits) + ","
                 + "\"ema200\":"  + DoubleToString(emaS, digits) + ","
                 + "\"rsi\":"     + DoubleToString(rsiX, 1)      + ","
                 + "\"adx\":"     + DoubleToString(adxX, 1)      + ","
                 + "\"atr\":"     + DoubleToString(atrX, digits) + ","
                 + "\"swingH\":"  + DoubleToString(hiX,  digits) + ","
                 + "\"swingL\":"  + DoubleToString(loX,  digits) + ","
                 + "\"bias\":\""  + biasX + "\","
                 + "\"closes\":[" + closesX + "]"
                 + "}";
      }
   }

   string j = "{";
   j = j + "\"ea\":\"TraceAI-2.0\",";
   j = j + "\"broker\":\""       + AIJsonEscape(AccountServer()) + "\",";
   j = j + "\"chartId\":\""      + IntegerToString((int)ChartID()) + "\",";
   j = j + "\"symbol\":\""       + AIJsonEscape(Symbol()) + "\",";
   j = j + "\"digits\":"         + IntegerToString(digits) + ",";
   j = j + "\"structureTF\":\""  + TimeframeToString(structTF) + "\",";
   j = j + "\"structureTrend\":" + IntegerToString(g_sigCachedTrend) + ",";
   j = j + "\"bosLevel\":"       + DoubleToString(g_sigCachedBOSLevel, digits) + ",";
   j = j + "\"swingH\":"         + DoubleToString(g_sigCachedSwingH, digits) + ",";
   j = j + "\"swingL\":"         + DoubleToString(g_sigCachedSwingL, digits) + ",";
   j = j + "\"confirmTF\":\""    + TimeframeToString(g_confirmCachedTF) + "\",";
   j = j + "\"confirmTrend\":"   + IntegerToString(g_confirmCachedTrend) + ",";
   j = j + "\"confirmBOS\":"     + DoubleToString(g_confirmCachedBOS, digits) + ",";
   j = j + "\"confirmMatch\":"   + (g_sigCachedTrend == g_confirmCachedTrend && g_sigCachedTrend != 0 ? "true" : "false") + ",";
   j = j + "\"score\":"          + IntegerToString((int)g_sigCachedScore) + ",";
   j = j + "\"grade\":\""        + AIJsonEscape(g_sigCachedGrade) + "\",";
   j = j + "\"stableBars\":"     + IntegerToString(g_sigStableBars) + ",";
   j = j + "\"ema200\":"         + DoubleToString(ema, digits) + ",";
   j = j + "\"adx\":"            + DoubleToString(adx, 2) + ",";
   j = j + "\"rsi\":"            + DoubleToString(rsi, 2) + ",";
   j = j + "\"currentPrice\":"   + DoubleToString(priceNow, digits) + ",";
   j = j + "\"actionTag\":\""    + AIJsonEscape(actionTag) + "\",";
   j = j + "\"serverTimeISO\":\""+ AIJsonEscape(TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS)) + "\",";
   j = j + "\"scanTs\":"         + IntegerToString((int)TimeCurrent()) + ",";
   j = j + "\"nonce\":"          + IntegerToString((int)(GetTickCount() & 0x7fffffff)) + ",";
   j = j + "\"closes\":["        + closesArr + "],";
   j = j + "\"chartTF\":\""      + TimeframeToString(chartTF) + "\",";
   j = j + "\"chartAdx\":"       + DoubleToString(chartAdx, 2) + ",";
   j = j + "\"chartRsi\":"       + DoubleToString(chartRsi, 2) + ",";
   j = j + "\"chartEma200\":"    + DoubleToString(chartEma, digits) + ",";
   j = j + "\"chartCloses\":["   + chartClosesArr + "]";
   if (StringLen(mtfJson) > 0) j = j + ",\"mtf\":[" + mtfJson + "]";

   // ══════════ TVRDA PORTA + VISION ══════════
   Print(">>> [Plan B] SCAN stage1: base+mtf ok, len=", StringLen(j), " mtfLen=", StringLen(mtfJson));
   g_mtfStamp = TimeCurrent();
   AIComputeGate();
   Print(">>> [Plan B] SCAN stage2: gate pass=", (g_gatePass ? "YES" : "NO"),
         " dir=", g_gateDir, " ", g_gatePassed, "/", g_gateTotal, " fail=", g_gateFail);
   j = j + ",\"gate\":{"
         + "\"enabled\":"  + (AI_HardGate ? "true" : "false") + ","
         + "\"pass\":"     + (g_gatePass ? "true" : "false") + ","
         + "\"dir\":\""    + (g_gateDir == 1 ? "BUY" : (g_gateDir == -1 ? "SELL" : "NONE")) + "\","
         + "\"passed\":"   + IntegerToString(g_gatePassed) + ","
         + "\"total\":"    + IntegerToString(g_gateTotal) + ","
         + "\"why\":\""    + AIJsonEscape(g_gateWhy)  + "\","
         + "\"fail\":\""   + AIJsonEscape(g_gateFail) + "\"}";

   // Vision chartovite se otvorat, se chekaat da se vcitaat, pa se slikaat vo istiov scan.
   static int visOpenFails = 0;
   static datetime visOpenRetryAfter = 0;
   static bool visOpenPauseLogged = false;
   datetime visNow = TimeLocal();
   if (visNow <= 0) visNow = TimeCurrent();
   if (AI_VisionEyes && g_visCount == 0 && !IsTesting() && !IsOptimization() &&
       (visOpenRetryAfter <= 0 || visNow >= visOpenRetryAfter))
   {
      AIVisionOpenCharts();
      if (g_visCount > 0)
      {
         visOpenFails = 0;
         visOpenRetryAfter = 0;
         visOpenPauseLogged = false;
      }
      else
      {
         if (visOpenFails < 3) visOpenFails++;
         if (visOpenFails >= 3)
         {
            visOpenRetryAfter = visNow + 60;
            if (!visOpenPauseLogged)
            {
               Print(">>> [Vision] Otvaranjeto na vision chartovi ne uspeva - pauza 60s, ke probam povtorno.");
               visOpenPauseLogged = true;
            }
         }
      }
   }

   string shots = "";
   if (AI_VisionEyes && (!AI_VisionOnlyOnSetup || g_gatePass))
      shots = AIVisionCapture(true);
   j = j + ",\"vision\":{"
         + "\"enabled\":" + (AI_VisionEyes ? "true" : "false") + ","
         + "\"ts\":"      + IntegerToString((int)g_visShotTime) + ","
         + "\"shots\":["  + shots + "]}";
   Print(">>> [Plan B] SCAN stage3: vision charts=", g_visCount,
         " shotsLen=", StringLen(shots));

   j = j + "}";

   // ============ PLAN B (FILES) FIRST: PISI scan.json, 100% bez WinHTTP timeout ============
   if (AIWriteScanFile(j))
   {
      g_aiLastScanOK = (g_aiLastHeartbeatTime > 0) || (g_aiLastScanOK);
      g_aiLastMsg    = "✅ Plan B: Scan payload zapisan vo TraceAI\\scan.json. Serverot (node) go cita posle 2s -> pisuva result.json. Check Dashboard za AI Decision za 3-8s.";
      Print(">>> [Plan B] Scan OK: scan.json size=", StringLen(j), " chars. Serverot ke go procita za 2s.");
      return;
   }
   Print(">>> [Plan B] Scan FAIL: ne mozhav da zapisam scan.json (read-only Files folder?); prodolzuvam so Plan A (WebRequest).");

   // ============ PLAN A (WEBREQUEST) FALLBACK ============
   if (StringLen(baseUrl) == 0) { g_aiLastMsg = "AI_ServerURL empty"; return; }
   string url = baseUrl + "/ai/scan";
   string headers = "Content-Type: application/json\r\nAccept: application/json\r\nUser-Agent: MetaTrader 4 Terminal\r\nConnection: close\r\n";
   char data[];
   int dlen = StringToCharArray(j, data, 0, -1, CP_UTF8);
   if (dlen > 1) ArrayResize(data, dlen - 1);
   int jlen = ArraySize(data);

   char resp[]; ArrayResize(resp, 32768); string head = "";
   string postHdrs = "Host: 127.0.0.1:3000\r\nPragma: no-cache\r\nCache-Control: no-cache\r\n";
   int rcPOST = WebRequest("POST", url, postHdrs, 90000, data, resp, head);
   int postGLE = GetLastError();
   string respText = CharArrayToString(resp);
   Print(">>> AI SCAN POST rc=", rcPOST, " gle=", postGLE, " len=", StringLen(respText), " resp=", StringSubstr(respText, 0, 200));
   if (rcPOST != 200)
   {
      string qs = "";
      qs = qs + "sym="    + AIUrlEncode(Symbol()) + "&";
      qs = qs + "digits=" + IntegerToString(digits) + "&";
      qs = qs + "stf="    + AIUrlEncode(TimeframeToString(structTF)) + "&";
      qs = qs + "trend="  + IntegerToString(g_sigCachedTrend) + "&";
      qs = qs + "bos="    + DoubleToString(g_sigCachedBOSLevel, digits) + "&";
      qs = qs + "sh="     + DoubleToString(g_sigCachedSwingH, digits) + "&";
      qs = qs + "sl="     + DoubleToString(g_sigCachedSwingL, digits) + "&";
      qs = qs + "ctf2="   + AIUrlEncode(TimeframeToString(g_confirmCachedTF)) + "&";
      qs = qs + "ctrend=" + IntegerToString(g_confirmCachedTrend) + "&";
      qs = qs + "cbos="   + DoubleToString(g_confirmCachedBOS, digits) + "&";
      qs = qs + "cmatch=" + (g_sigCachedTrend == g_confirmCachedTrend && g_sigCachedTrend != 0 ? "1" : "0") + "&";
      qs = qs + "score="  + IntegerToString((int)g_sigCachedScore) + "&";
      qs = qs + "grade="  + AIUrlEncode(g_sigCachedGrade) + "&";
      qs = qs + "stable=" + IntegerToString(g_sigStableBars) + "&";
      qs = qs + "ema="    + DoubleToString(ema, digits) + "&";
      qs = qs + "adx="    + DoubleToString(adx, 2) + "&";
      qs = qs + "rsi="    + DoubleToString(rsi, 2) + "&";
      qs = qs + "ctf="    + AIUrlEncode(TimeframeToString(chartTF)) + "&";
      qs = qs + "cadx="   + DoubleToString(chartAdx, 2) + "&";
      qs = qs + "crsi="   + DoubleToString(chartRsi, 2) + "&";
      qs = qs + "cema="   + DoubleToString(chartEma, digits) + "&";
      qs = qs + "price="  + DoubleToString(priceNow, digits) + "&";
      qs = qs + "act="    + AIUrlEncode(actionTag) + "&";
      qs = qs + "t="      + AIUrlEncode(TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS)) + "&";
      qs = qs + "scanTs=" + IntegerToString((int)TimeCurrent()) + "&";
      qs = qs + "nonce="  + IntegerToString((int)(GetTickCount() & 0x7fffffff)) + "&";
      qs = qs + "closes=" + AIUrlEncode(closesArr);

      string qUrl = baseUrl + "/ai/scan-qs?" + qs;
      int qsLen = StringLen(qUrl);
      if (qsLen < 2000)
      {
         char qResp[];
         int rcQS = AIWrGet(qUrl, qResp, 10000, "127.0.0.1", "localhost");
         if (rcQS < 0 && StringFind(qUrl, "localhost") >= 0)
            rcQS = AIWrGet(qUrl, qResp, 10000, "localhost", "127.0.0.1");
         string qRespT = CharArrayToString(qResp);
         Print(">>> AI SCAN-QS rc=", rcQS, " qsLen=", qsLen, " len=", StringLen(qRespT), " resp=", StringSubstr(qRespT, 0, 220));
         bool qOK = (StringFind(qRespT, "accepted") >= 0) && ((rcQS == 200) || (rcQS <= 0));
         if (qOK)
         {
            g_aiLastScanOK = true;
            g_aiLastMsg = "✅ Scan-qs accepted (GET fallback). Check /ai/result in 2-5s.";
            Print(">>> AI SCAN-QS OK (GET fallback). URL length = ", qsLen);
         }
         else if (rcQS <= 0)
         {
            g_aiLastMsg = "FAIL: POST rc="+IntegerToString(rcPOST)+" | QS rc="+IntegerToString(rcQS)
                       +" | QSresp="+StringSubstr(qRespT,0,180);
            g_aiDecision = "WAIT"; g_aiConfidence = 0.0;
            Print("AI_SCAN FAIL_FALLBACK: ", g_aiLastMsg);
         }
         else
         {
            g_aiLastMsg = "Server HTTP " + IntegerToString(rcQS) + " [qs]: " + StringSubstr(qRespT, 0, 180);
            g_aiDecision = "WAIT"; g_aiConfidence = 0.0;
            Print("AI_SCAN-QS HTTP "+IntegerToString(rcQS)+": "+g_aiLastMsg);
         }
      }
      else
      {
         g_aiLastScanOK = (rcPOST == 200);
         if (rcPOST <= 0)
         {
            g_aiLastMsg = "Scan FAIL: server Startovan? MT4 options URL dodaden? err=" + IntegerToString(GetLastError());
            g_aiDecision = "WAIT"; g_aiConfidence = 0.0;
            Print("AI_SCAN FAIL: ", g_aiLastMsg);
         }
         else
         {
            g_aiLastMsg = "Server HTTP " + IntegerToString(rcPOST) + ": " + StringSubstr(respText, 0, 180);
            g_aiDecision = "WAIT"; g_aiConfidence = 0.0;
            Print("AI_SCAN HTTP ", rcPOST, ": ", g_aiLastMsg);
         }
      }
   }
   else
   {
      g_aiLastScanOK = true;
      g_aiLastMsg = "✅ Scan accepted. Check /ai/result in 2-5s.";
      Print(">>> AI SCAN POST OK. JSON size = "+IntegerToString(jlen));
   }
}

void AIFetchResultNow()
{
   static datetime lastF = 0;
   datetime now = TimeCurrent();
   int interval = (AI_FetchEverySec <= 0) ? 6 : AI_FetchEverySec;
   if (lastF > 0 && (now - lastF) < interval) return;
   lastF = now;
   g_aiLastFetchTime = now;

   // ================= PLAN B (FILES): READ result.json FIRST = 100% no timeout =================
   string d = "";  double conf = 0.0;
   string r1="", r2="", r3="";
   double fEntry=0.0, fSL=0.0, fTP=0.0;
   string fComment = "";
   bool fb = AIReadResultFile(d, conf, r1, r2, r3, fEntry, fSL, fTP, fComment);
   if (fb && g_aiResultFresh)
   {
      g_aiLastScanOK = true;
      string ud = d;
      {
         int _i, _c, _n = StringLen(ud);
         for (_i = 0; _i < _n; _i++) {
            _c = StringGetCharacter(ud, _i);
            if (_c >= 97 && _c <= 122) StringSetCharacter(ud, _i, (ushort)(_c - 32));
         }
      }
      if (ud != "BUY" && ud != "SELL") ud = "WAIT";
      g_aiDecision   = ud;
      g_aiConfidence = MathMax(0.0, MathMin(1.0, conf));
      g_aiR1 = r1; g_aiR2 = r2; g_aiR3 = r3;
      g_aiEntry = fEntry; g_aiSL = fSL; g_aiTP = fTP;
      if (StringLen(fComment) > 0) g_aiLastMsg = fComment;
      Print(">>> [Plan B] AI FETCH OK: decision=", ud, " conf=", DoubleToString(g_aiConfidence,2),
            " age=", IntegerToString(g_aiRsAgeSec), "s",
            " Entry=", DoubleToString(g_aiEntry,Digits),
            " SL=",    DoubleToString(g_aiSL,Digits), " TP=", DoubleToString(g_aiTP,Digits));
      return;
   }
   if (fb && !g_aiResultFresh)
   {
      // ⭐ Fajlot postoi no e ZASTAREN => serverot e isklucen.
      //    NE ja prikazuvame starata odluka kako da e aktuelna.
      g_aiDecision   = "WAIT";
      g_aiConfidence = 0.0;
      g_aiEntry = 0.0; g_aiSL = 0.0; g_aiTP = 0.0;
      string ageS = (g_aiRsAgeSec >= 0 ? IntegerToString(g_aiRsAgeSec) : "?");
      if (g_aiServerOnline)
      {
         g_aiR1 = "[GPT STALE] result.json e star " + ageS + "s - chekam nov scan od serverot.";
         g_aiR2 = "Serverot e ZIV (heartbeat ok), no uste ne vratil svezha analiza.";
         g_aiLastMsg = "GPT rezultat zastaren (" + ageS + "s)";
      }
      else
      {
         g_aiR1 = "[AI OFFLINE] result.json e star " + ageS + "s";
         g_aiR2 = "Startni go StartTraceAI.bat (node server.js) za zhiva GPT analiza.";
         g_aiLastMsg = "AI OFFLINE - result.json zastaren";
      }
      g_aiR3 = "";
      Print(">>> [Plan B] AI FETCH: result.json STALE (", g_aiRsAgeSec, "s, limit ",
            AIResultStaleLimitSec(), "s) -> ne koristam stara odluka.");
   }
   // ================= PLAN A (WEBREQUEST): FALLBACK =================
   string baseUrl = AI_ServerURL;
   if (StringLen(baseUrl) == 0) return;
   if (StringSubstr(baseUrl, StringLen(baseUrl) - 1, 1) == "/")
      baseUrl = StringSubstr(baseUrl, 0, StringLen(baseUrl) - 1);

   string url = baseUrl + "/ai/result";
   char resp[];
   int rc = AIWrGet(url, resp, 60000, "127.0.0.1", "localhost");
   if (rc < 0 && StringFind(url, "localhost") >= 0)
      rc = AIWrGet(url, resp, 60000, "localhost", "127.0.0.1");
   string json = CharArrayToString(resp);
   Print(">>> AI FETCH rc=", rc, " len=", StringLen(json), " resp=", StringSubstr(json, 0, 240));
   if (rc <= 0 || rc != 200)
   {
      if (rc <= 0 && StringFind(g_aiLastMsg, "Fetch") < 0)
         g_aiLastMsg = g_aiLastMsg + " | Fetch: server ne startuvan? rc=" + IntegerToString(rc);
      else if (rc != 200 && StringFind(g_aiLastMsg, "Fetch") < 0)
         g_aiLastMsg = g_aiLastMsg + " | Fetch HTTP " + IntegerToString(rc);
      return;
   }
   if (StringLen(json) < 10) return;

   g_aiLastScanOK = true;

   string tmpDec = AIJstring(json, "decision");
   StringTrimLeft(tmpDec);
   StringTrimRight(tmpDec);
   string d2 = tmpDec;
   {
      int _i, _c, _n = StringLen(d2);
      for (_i = 0; _i < _n; _i++) {
         _c = StringGetCharacter(d2, _i);
         if (_c >= 97 && _c <= 122) StringSetCharacter(d2, _i, (ushort)(_c - 32));
      }
   }
   if (d2 != "BUY" && d2 != "SELL") d2 = "WAIT";
   g_aiDecision   = d2;
   g_aiConfidence = MathMax(0.0, MathMin(1.0, StringToDouble(AIJstring(json, "confidence"))));
   g_aiR1         = AIJarrIdx(json, "reasons", 0);
   g_aiR2         = AIJarrIdx(json, "reasons", 1);
   g_aiR3         = AIJarrIdx(json, "reasons", 2);
   g_aiEntry      = StringToDouble(AIJstring(json, "suggestedEntry"));
   g_aiSL         = StringToDouble(AIJstring(json, "suggestedSL"));
   g_aiTP         = StringToDouble(AIJstring(json, "suggestedTP"));
   string okS     = AIJstring(json, "ok");
   if (okS == "false" || okS == "0" || okS == "False" || okS == "FALSE") g_aiLastScanOK = false;
   if (StringFind(json, "\"ok\":false") >= 0 || StringFind(json, "\"ok\": false") >= 0) g_aiLastScanOK = false;
   string msg     = AIJstring(json, "message");
   if (StringLen(msg) > 0) g_aiLastMsg = msg;
   Print(">>> AI FETCH OK: decision=", d2, " conf=", DoubleToString(g_aiConfidence,2),
         " Entry=", DoubleToString(g_aiEntry,Digits),
         " SL=", DoubleToString(g_aiSL,Digits), " TP=", DoubleToString(g_aiTP,Digits));
}

//+------------------------------------------------------------------+
//| SECOND ORDER: place a pending LIMIT inside the zone.             |
//| SL and TP are the SAME as the zone. Only placed if the zone's TP |
//| has NOT already been hit.                                        |
//+------------------------------------------------------------------+
void PlaceZonePending(ZoneInfo &zone, bool forced = false)
{
   // forced = the market entry was rejected because price is not at the zone yet,
   // so the order is parked at the zone as a limit instead of chasing price
   if (!Use_SecondPendingOrder && !forced) return;
   if (!Enable_AutoTrade) return;
   if (g_isScanningHistory) return;

   // --- MAX ZONE AGE SAFETY CHECK ---
   string ageReason = "";
   if (!IsZoneYoungEnoughForTrade(zone, ageReason))
   {
      Print("PlaceZonePending BLOCKED zone ", zone.uniqueID, ": ", ageReason);
      return;
   }

   // Condition: do NOT create a pending if the zone's TP (or SL) is already hit
   if (zone.tpHit) return;
   if (zone.slHit) return;

   if (AutoTrade_RespectTimeFilter && !IsTradingAllowed()) return;
   if (AutoTrade_CurrentChartTFOnly && zone.timeframe != Period()) return;

   if (Use_VolumeDivergenceFilter && VD_BlockTradesOnly && HasVolumeDivergence(zone, zone.timeframe))
   {
      if (DebugMode) Print("Pending skip: volume divergence on zone ", zone.uniqueID);
      return;
   }

   string pendReason = "";
   if (!RiskGuardAccountOK(pendReason))
   {
      g_riskBlockReason = pendReason;
      if (DebugMode) Print("RiskGuard blocked pending on zone ", zone.uniqueID, ": ", pendReason);
      return;
   }
   if (Use_RiskGuard && Risk_MaxOpenTrades > 0 && CountEAOpenTrades() >= Risk_MaxOpenTrades) return;

   if (Use_EntryGuard && Entry_BlockIfZoneBroken && ZoneClosedThrough(zone))
   {
      if (DebugMode) Print("Pending skip: zone ", zone.uniqueID, " already broken");
      return;
   }

   double pt = Point;
   if (pt == 0) pt = 0.0001;

   bool bull = (zone.zoneType == "Bull");
   string tag = "TraceInst_PEND_" + IntegerToString(zone.uniqueID);

   // Avoid a duplicate pending for the same zone
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderMagicNumber() != Magic_Number) continue;
      if (OrderSymbol() != Symbol()) continue;
      if (OrderComment() == tag) return;
   }

   double zoneHeight = zone.top - zone.bottom;
   double pct = Pending_EntryPct;
   if (pct < 0.0) pct = 0.0;
   if (pct > 1.0) pct = 1.0;

   double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * pt;
   double entry;
   int    type;
   double price = bull ? Ask : Bid;

   if (bull)
   {
      // Demand zone -> Buy Limit at/inside the zone (below current price)
      entry = zone.top - (zoneHeight * pct);
      type  = OP_BUYLIMIT;
      if (entry >= price - stopLevel) return; // too close / already inside
   }
   else
   {
      // Supply zone -> Sell Limit at/inside the zone (above current price)
      entry = zone.bottom + (zoneHeight * pct);
      type  = OP_SELLLIMIT;
      if (entry <= price + stopLevel) return;
   }

   entry           = NormalizeDouble(entry, Digits);
   double slPrice  = NormalizeDouble(zone.stopLoss, Digits);
   double tpPrice  = NormalizeDouble(zone.takeProfit, Digits);

   // Validate SL/TP against the pending entry
   if (bull)
   {
      if (slPrice >= entry || tpPrice <= entry) return;
   }
   else
   {
      if (slPrice <= entry || tpPrice >= entry) return;
   }

   if (!TradeRRGateAllows(type, entry, slPrice, tpPrice,
                          "ZonePending zone " + IntegerToString(zone.uniqueID))) return;
   double lot = CalcTradeLot(entry, slPrice, (Pending_Lot_Size > 0.0) ? Pending_Lot_Size : Lot_Size);
   if (lot <= 0.0) return;

   int pendSlippage = (Use_RiskGuard && Risk_MaxSlippagePoints > 0) ? Risk_MaxSlippagePoints : 10;
   int ticket = OrderSend(Symbol(), type, lot, entry, pendSlippage, slPrice, tpPrice,
                          tag, Magic_Number, 0, (bull ? clrDodgerBlue : clrOrange));
   if (ticket < 0)
   {
      if (DebugMode) Print("Pending (2nd order) FAILED zone ", zone.uniqueID,
                           " err=", GetLastError(), " entry=", DoubleToString(entry, Digits));
   }
   else if (DebugMode)
   {
      Print(">>> PENDING (2nd order) placed ticket #", ticket, " zone ", zone.uniqueID,
            " entry=", DoubleToString(entry, Digits),
            " SL=", DoubleToString(slPrice, Digits),
            " TP=", DoubleToString(tpPrice, Digits));
   }
}

//+------------------------------------------------------------------+
//| Manage the pending 2nd orders: if the zone's TP got hit (or the  |
//| zone/SL is gone), delete the still-unfilled pending automatically|
//+------------------------------------------------------------------+
void ManageZonePendings()
{
   if (!Use_SecondPendingOrder) return;

   string prefix = "TraceInst_PEND_";
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderMagicNumber() != Magic_Number) continue;
      if (OrderSymbol() != Symbol()) continue;

      int ot = OrderType();
      // Only still-pending limit orders (once filled they become OP_BUY/OP_SELL)
      if (ot != OP_BUYLIMIT && ot != OP_SELLLIMIT) continue;

      string cmt = OrderComment();
      if (StringFind(cmt, prefix) != 0) continue;

      int zid = (int)StrToInteger(StringSubstr(cmt, StringLen(prefix)));

      bool found = false, tpHit = false, slHit = false, broken = false;
      for (int b = 0; b < totalBullZones; b++)
      {
         if (BullishZones[b].uniqueID == zid)
         {
            found = true; tpHit = BullishZones[b].tpHit; slHit = BullishZones[b].slHit;
            if (Use_EntryGuard && Entry_BlockIfZoneBroken) broken = ZoneClosedThrough(BullishZones[b]);
            break;
         }
      }
      if (!found)
      {
         for (int s = 0; s < totalBearZones; s++)
         {
            if (BearishZones[s].uniqueID == zid)
            {
               found = true; tpHit = BearishZones[s].tpHit; slHit = BearishZones[s].slHit;
               if (Use_EntryGuard && Entry_BlockIfZoneBroken) broken = ZoneClosedThrough(BearishZones[s]);
               break;
            }
         }
      }

      // Delete the pending if the zone is gone, hit, or price closed through it
      if (!found || tpHit || slHit || broken)
      {
         int tk = OrderTicket();
         if (OrderDelete(tk))
         {
            if (DebugMode) Print("Pending (2nd order) deleted ticket #", tk,
                                 " zoneID=", zid, " reason=",
                                 (!found ? "zone gone" : (tpHit ? "TP hit" : (slHit ? "SL hit" : "zone broken"))));
         }
      }
   }
}

bool ImmediateMarketOrderClosed(int zoneID)
{
   string marketComment = "TI_Z" + IntegerToString(zoneID) + "_IE";
   for (int h = OrdersHistoryTotal() - 1; h >= 0; h--)
   {
      if (!OrderSelect(h, SELECT_BY_POS, MODE_HISTORY)) continue;
      if (OrderMagicNumber() != Magic_Number) continue;
      if (OrderSymbol() != Symbol()) continue;
      int ot = OrderType();
      if (ot != OP_BUY && ot != OP_SELL) continue;
      if (StringFind(OrderComment(), marketComment) != 0) continue;
      if (OrderCloseTime() <= 0) continue;
      return true;
   }
   return false;
}

void ManageImmediateEntryPendings()
{
   if (!Use_ImmediateEntry) return;

   string prefix = "TI_IE_PEND_";
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderMagicNumber() != Magic_Number) continue;
      if (OrderSymbol() != Symbol()) continue;
      int ot = OrderType();
      if (ot != OP_BUYLIMIT && ot != OP_SELLLIMIT) continue;

      string cmt = OrderComment();
      if (StringFind(cmt, prefix) != 0) continue;
      int zoneID = (int)StrToInteger(StringSubstr(cmt, StringLen(prefix)));
      if (!ImmediateMarketOrderClosed(zoneID)) continue;

      int ticket = OrderTicket();
      if (OrderDelete(ticket) && DebugMode)
         Print("ImmediateEntry pending deleted after paired market close: ticket #",
               ticket, " zoneID=", zoneID);
   }
}

//+------------------------------------------------------------------+
//| RETEST TRADING LOGIC                                             |
//+------------------------------------------------------------------+
void ProcessRetestTrades()
{
   if (!Enable_AutoTrade) return;
   if (!AutoTrade_OnRetest) return;
   if (g_isScanningHistory) return;
   if (AutoTrade_RespectTimeFilter && !IsTradingAllowed()) return;
   
   static datetime lastScanLog = 0;
   if (DebugMode && TimeCurrent() - lastScanLog > 300) // Log every 5 mins
   {
      Print("Scanning for retest trades... Bull Zones: ", totalBullZones, " Bear Zones: ", totalBearZones);
      lastScanLog = TimeCurrent();
   }
   
   int tf = Period();
   double bid = Bid;
   double ask = Ask;
   
   // Scan Bullish Zones for Retest
   for (int i = 0; i < totalBullZones; i++)
   {
      if (BullishZones[i].timeframe != tf) continue;
      if (BullishZones[i].isTraded) continue;
      if (BullishZones[i].slHit || BullishZones[i].tpHit) continue;
      
      // Check if price is within or just above the zone
      // "Approaching zone"
      double zoneTop = BullishZones[i].top;
      double zoneBot = BullishZones[i].bottom;
      double atr = iATR(Symbol(), tf, 14, 1);
      
      // If Bid is within the zone or within 0.5 ATR of the top
      if (bid <= zoneTop + (atr * 0.5) && bid >= zoneBot - (atr * 0.1))
      {
         // Check for candlestick pattern confirmation on the last closed bar (shift 1)
         bool patternConfirmed = false;
         bool patternsEnabled = Use_PinBar_Filter || Use_Engulfing_Filter;
         
         if (Use_PinBar_Filter && IsBullishPinBar(tf, 1)) 
         {
            patternConfirmed = true;
            if (DebugMode) Print("Bullish Pin Bar detected for retest.");
         }
         if (!patternConfirmed && Use_Engulfing_Filter && IsBullishEngulfing(tf, 1))
         {
            patternConfirmed = true;
            if (DebugMode) Print("Bullish Engulfing detected for retest.");
         }

         // If patterns are disabled, we treat the price being in the zone as a basic confirmation
         if (!patternsEnabled) patternConfirmed = true;

         if (patternConfirmed)
         {
            if (IsVolumeNormalForRetest(tf, 1))
            {
               if (DebugMode) Print("Retest BUY signal for Bull Zone #", BullishZones[i].uniqueID);
               AttemptAutoTrade(BullishZones[i], 1);
            }
         }
      }
   }
   
   // Scan Bearish Zones for Retest
   for (int i = 0; i < totalBearZones; i++)
   {
      if (BearishZones[i].timeframe != tf) continue;
      if (BearishZones[i].isTraded) continue;
      if (BearishZones[i].slHit || BearishZones[i].tpHit) continue;
      
      double zoneTop = BearishZones[i].top;
      double zoneBot = BearishZones[i].bottom;
      double atr = iATR(Symbol(), tf, 14, 1);
      
      // If Ask is within the zone or within 0.5 ATR of the bottom
      if (ask >= zoneBot - (atr * 0.5) && ask <= zoneTop + (atr * 0.1))
      {
         // Check for candlestick pattern confirmation on the last closed bar (shift 1)
         bool patternConfirmed = false;
         bool patternsEnabled = Use_PinBar_Filter || Use_Engulfing_Filter;
         
         if (Use_PinBar_Filter && IsBearishPinBar(tf, 1))
         {
            patternConfirmed = true;
            if (DebugMode) Print("Bearish Pin Bar detected for retest.");
         }
         if (!patternConfirmed && Use_Engulfing_Filter && IsBearishEngulfing(tf, 1))
         {
            patternConfirmed = true;
            if (DebugMode) Print("Bearish Engulfing detected for retest.");
         }

         // If patterns are disabled, we treat the price being in the zone as a basic confirmation
         if (!patternsEnabled) patternConfirmed = true;

         if (patternConfirmed)
         {
            if (IsVolumeNormalForRetest(tf, 1))
            {
               if (DebugMode) Print("Retest SELL signal for Bear Zone #", BearishZones[i].uniqueID);
               AttemptAutoTrade(BearishZones[i], 1);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| VOLUME CONFIRMATION                                              |
//+------------------------------------------------------------------+
bool IsVolumeSignificant(int tf, int shift)
{
   if (!Use_Volume_Confirmation) return true;
   
   double currentVol = (double)iVolume(Symbol(), tf, shift);
   double avgVol = GetAverageVolume(tf, Volume_Lookback_Period, shift + 1);
   
   if (avgVol <= 0) 
   {
      if (DebugMode) Print("Volume Check: Avg Volume is 0, skipping check.");
      return true;
   }
   
   double threshold = avgVol * Volume_Multiplier;
   
   if (currentVol >= threshold)
   {
      if (DebugMode)
         Print("✅ Volume Confirmed: ", (int)currentVol, " >= Threshold: ", (int)threshold, " (Avg: ", (int)avgVol, ")");
      return true;
   }
   
   // If it's not significant, let's still log it if DebugMode is on
   if (DebugMode)
   {
      static datetime lastLogTime = 0;
      if (TimeCurrent() - lastLogTime > 60) // Log once per minute to avoid spam
      {
         Print("❌ Volume NOT Significant: ", (int)currentVol, " < Threshold: ", (int)threshold, " (Avg: ", (int)avgVol, ")");
         lastLogTime = TimeCurrent();
      }
   }
   
   return false;
}

bool IsVolumeNormalForRetest(int tf, int shift)
{
   if (!Use_Volume_Confirmation) return true;

   double currentVol = (double)iVolume(Symbol(), tf, shift);
   double avgVol = GetAverageVolume(tf, Volume_Lookback_Period, shift + 1);

   if (avgVol <= 0) return true; // Safety, allow trade

   double maxAllowedVol = avgVol * Retest_Max_Volume_Multiplier;

   if (currentVol <= maxAllowedVol)
   {
      if (DebugMode) Print("✅ Retest Volume OK: ", (int)currentVol, " <= Max: ", (int)maxAllowedVol);
      return true;
   }

   if (DebugMode) Print("❌ Retest Volume TOO HIGH: ", (int)currentVol, " > Max: ", (int)maxAllowedVol, " - Potential Breakout, skipping trade.");
   return false;
}


double GetAverageVolume(int tf, int lookback, int shift)
{
   double sum = 0;
   int bars = iBars(Symbol(), tf);
   int count = 0;
   
   for (int i = shift; i < shift + lookback && i < bars; i++)
   {
      sum += (double)iVolume(Symbol(), tf, i);
      count++;
   }
   
   if (count == 0) return 0;
   return sum / count;
}

//+------------------------------------------------------------------+
//| CANDLESTICK PATTERN RECOGNITION                                  |
//+------------------------------------------------------------------+
bool IsBullishPinBar(int tf, int shift)
{
   double O = iOpen(Symbol(), tf, shift);
   double C = iClose(Symbol(), tf, shift);
   double H = iHigh(Symbol(), tf, shift);
   double L = iLow(Symbol(), tf, shift);
   
   double bodySize = MathAbs(O - C);
   double range = H - L;
   
   if (range <= 0) return false;
   
   double lowerWick = MathMin(O, C) - L;
   double upperWick = H - MathMax(O, C);
   
   // Body must be small (e.g., less than 1/3 of the total range)
   // Lower wick must be long (e.g., at least 2/3 of the total range)
   // Upper wick must be very small
   bool isPin = (bodySize < range * 0.33) && (lowerWick >= range * 0.6) && (upperWick < range * 0.2);
   
   return isPin;
}

bool IsBearishPinBar(int tf, int shift)
{
   double O = iOpen(Symbol(), tf, shift);
   double C = iClose(Symbol(), tf, shift);
   double H = iHigh(Symbol(), tf, shift);
   double L = iLow(Symbol(), tf, shift);
   
   double bodySize = MathAbs(O - C);
   double range = H - L;
   
   if (range <= 0) return false;
   
   double lowerWick = MathMin(O, C) - L;
   double upperWick = H - MathMax(O, C);
   
   // Body must be small
   // Upper wick must be long
   // Lower wick must be very small
   bool isPin = (bodySize < range * 0.33) && (upperWick >= range * 0.6) && (lowerWick < range * 0.2);
   
   return isPin;
}

bool IsBullishEngulfing(int tf, int shift)
{
   // Current candle (shift) must be bullish
   double C1 = iClose(Symbol(), tf, shift);
   double O1 = iOpen(Symbol(), tf, shift);
   if (C1 <= O1) return false;
   
   // Previous candle (shift + 1) must be bearish
   double C2 = iClose(Symbol(), tf, shift + 1);
   double O2 = iOpen(Symbol(), tf, shift + 1);
   if (C2 >= O2) return false;
   
   // Current bullish candle must engulf the previous bearish candle's body
   bool isEngulfing = (C1 > O2 && O1 < C2);
   
   return isEngulfing;
}

bool IsBearishEngulfing(int tf, int shift)
{
   // Current candle (shift) must be bearish
   double C1 = iClose(Symbol(), tf, shift);
   double O1 = iOpen(Symbol(), tf, shift);
   if (C1 >= O1) return false;
   
   // Previous candle (shift + 1) must be bullish
   double C2 = iClose(Symbol(), tf, shift + 1);
   double O2 = iOpen(Symbol(), tf, shift + 1);
   if (C2 <= O2) return false;
   
   // Current bearish candle must engulf the previous bullish candle's body
   bool isEngulfing = (O1 > C2 && C1 < O2);
   
   return isEngulfing;
}

void AddBullishZone(ZoneInfo &zone)
{
   // AntiFake filter - reject fake zones (only for newly detected zones, not restored)
   if (!g_isScanningHistory || !Regime_ApplyToNewZonesOnly)
   {
      if (!PassAntiFakeZoneFilter(zone, zone.timeframe)) return;
   }
   // Regime filter - reject zones in wrong market conditions
   if (!PassZoneRegimeFilter(zone.timeframe)) return;
   // Quality filters: StrictMode hard reject (score -100 = reject)
   double scoreLS_bull = GetLiquiditySweepScore(zone, zone.timeframe);
   if (scoreLS_bull < -50.0) return;
   if (Sweep_StrictMode && scoreLS_bull > 0 && scoreLS_bull < Sweep_MinScore) return;
   if (GetRVScore(zone, zone.timeframe) < -50.0) return;
   if (GetMSSScore(zone, zone.timeframe) < -50.0) return;
   
   double pip = (Digits == 3 || Digits == 5) ? Point * 10 : Point;
   double minZoneGap       = Buy_MinZoneDistance * pip;
   double oppositeTfMinGap = 3.0 * pip;
   double touchEps         = Point * 0.5;
   EnsureZoneOrdered(zone);
   double top1 = zone.top;
   double bot1 = zone.bottom;
   for (int i = 0; i < totalBullZones; i++)
   {
      if (BullishZones[i].timeframe != zone.timeframe) continue;
      if (MathAbs(zone.startTime - BullishZones[i].startTime) <= PeriodSeconds(zone.timeframe) * 5)
      {
          if (DebugMode) Print("Skip Duplicate Time Zone (BULL) TF=", zone.timeframe);
          return;
      }
      EnsureZoneOrdered(BullishZones[i]);
      double top2 = BullishZones[i].top;
      double bot2 = BullishZones[i].bottom;
      double gap;
      if (top1 <= bot2)
         gap = bot2 - top1;
      else if (top2 <= bot1)
         gap = bot1 - top2;
      else
         gap = 0.0;
      if (gap <= touchEps)
      {
         if (DebugMode)
            Print("Skip new BULL zone (overlap)", DoubleToStr(bot1, Digits), "-", DoubleToStr(top1, Digits),
                  " TF=", zone.timeframe,
                  " overlapping BULL #", i,
                  " ", DoubleToStr(bot2, Digits), "-", DoubleToStr(top2, Digits));
         return;
      }
      if (gap < minZoneGap)
      {
         if (DebugMode)
            Print("Skip new BULL zone ", DoubleToStr(bot1, Digits), "-", DoubleToStr(top1, Digits),
                   " TF=", zone.timeframe,
                   " too close to existing BULL #", i,
                   " ", DoubleToStr(bot2, Digits), "-", DoubleToStr(top2, Digits),
                   " gap=", DoubleToStr(gap, Digits),
                   " < minGap=", DoubleToStr(minZoneGap, Digits));
         return;
      }
   }
   for (int i = 0; i < totalBearZones; i++)
   {
      if (BearishZones[i].timeframe == zone.timeframe)
      {
         EnsureZoneOrdered(BearishZones[i]);
         double top2 = BearishZones[i].top;
         double bot2 = BearishZones[i].bottom;
         double gap;
         if (top1 <= bot2)
            gap = bot2 - top1;
         else if (top2 <= bot1)
            gap = bot1 - top2;
         else
            gap = 0.0;
         if (gap <= touchEps)
         {
            if (DebugMode)
               Print("BULL vs BEAR overlap ", DoubleToStr(bot1, Digits), "-", DoubleToStr(top1, Digits),
                     " TF=", zone.timeframe,
                     " with BEAR #", i,
                     " ", DoubleToStr(bot2, Digits), "-", DoubleToStr(top2, Digits));
            return;
         }
         if (gap < minZoneGap)
         {
            if (DebugMode)
               Print("BULL vs BEAR conflict ", DoubleToStr(bot1, Digits), "-", DoubleToStr(top1, Digits),
                     " TF=", zone.timeframe,
                     " with BEAR #", i,
                     " ", DoubleToStr(bot2, Digits), "-", DoubleToStr(top2, Digits),
                     " gap=", DoubleToStr(gap, Digits),
                     " < minGap=", DoubleToStr(minZoneGap, Digits));
            return;
         }
      }
      else
      {
         EnsureZoneOrdered(BearishZones[i]);
         double top2 = BearishZones[i].top;
         double bot2 = BearishZones[i].bottom;
         double gap;
         if (top1 <= bot2)
            gap = bot2 - top1;
         else if (top2 <= bot1)
            gap = bot1 - top2;
         else
            gap = 0.0;

         if (gap <= oppositeTfMinGap)
         {
            if (DebugMode)
               Print("BULL vs BEAR(xTF) conflict ", DoubleToStr(bot1, Digits), "-", DoubleToStr(top1, Digits),
                     " TF=", zone.timeframe,
                     " with BEAR #", i,
                     " ", DoubleToStr(bot2, Digits), "-", DoubleToStr(top2, Digits),
                     " gap=", DoubleToStr(gap, Digits),
                     " <= xTFMinGap=", DoubleToStr(oppositeTfMinGap, Digits));
            return;
         }
      }
   }
   ArrayResize(BullishZones, totalBullZones + 1);
   BullishZones[totalBullZones] = zone;
   totalBullZones++;
   EnsureZoneFingerprint(BullishZones[totalBullZones - 1]);
   bool firstDetection = RememberSeenZoneFingerprint(
                            BullishZones[totalBullZones - 1].fingerprint);
   Print("BULL zone accepted for display/entry: zone ",
         BullishZones[totalBullZones - 1].uniqueID,
         " fingerprint=", BullishZones[totalBullZones - 1].fingerprint,
         " firstDetection=", firstDetection,
         " Use_ImmediateEntry=", Use_ImmediateEntry);
   if (!g_isScanningHistory)
   {
       if (TimeDay(zone.startTime) == g_currentDay)
       {
           g_todayBullCount++;
       }
       
       if (EnableTelegram)
       {
           string msg = "Trace Institucional  Symbol: " + Symbol() + "\n" +
                        "Type: BUY \n" +
                        "SL: " + DoubleToString(zone.stopLoss, Digits) + "\n" +
                        "TP: " + DoubleToString(zone.takeProfit, Digits);
           SendTelegramMessage(msg);
       }
   }
   if (Use_ImmediateEntry)
      ImmediateEntry(BullishZones[totalBullZones-1], firstDetection);
   else
   {
      if (AutoTrade_OnNewZone)
         AttemptAutoTrade(BullishZones[totalBullZones-1], 1);
      PlaceZonePending(BullishZones[totalBullZones-1]);
   }

   if (DebugMode)
      Print("ADD BULL zone #", totalBullZones,
            " TF=", zone.timeframe,
            " ", DoubleToStr(bot1, Digits), "-", DoubleToStr(top1, Digits),
            " Str:", DoubleToStr(zone.strength, 1));
}

void AddBearishZone(ZoneInfo &zone)
{
   // AntiFake filter - reject fake zones (only for newly detected zones, not restored)
   if (!g_isScanningHistory || !Regime_ApplyToNewZonesOnly)
   {
      if (!PassAntiFakeZoneFilter(zone, zone.timeframe)) return;
   }
   // Regime filter - reject zones in wrong market conditions
   if (!PassZoneRegimeFilter(zone.timeframe)) return;
   // Quality filters: StrictMode hard reject (score -100 = reject)
   double scoreLS_bear = GetLiquiditySweepScore(zone, zone.timeframe);
   if (scoreLS_bear < -50.0) return;
   if (Sweep_StrictMode && scoreLS_bear > 0 && scoreLS_bear < Sweep_MinScore) return;
   if (GetRVScore(zone, zone.timeframe) < -50.0) return;
   if (GetMSSScore(zone, zone.timeframe) < -50.0) return;
   
   double pip = (Digits == 3 || Digits == 5) ? Point * 10 : Point;
   double minZoneGap       = Sell_MinZoneDistance * pip;
   double oppositeTfMinGap = 3.0 * pip;
   double touchEps         = Point * 0.5;
   EnsureZoneOrdered(zone);
   double top1 = zone.top;
   double bot1 = zone.bottom;
   for (int i = 0; i < totalBearZones; i++)
   {
      if (BearishZones[i].timeframe != zone.timeframe) continue;
      if (MathAbs(zone.startTime - BearishZones[i].startTime) <= PeriodSeconds(zone.timeframe) * 5)
      {
          if (DebugMode) Print("Skip Duplicate Time Zone (BEAR) TF=", zone.timeframe);
          return;
      }
      EnsureZoneOrdered(BearishZones[i]);
      double top2 = BearishZones[i].top;
      double bot2 = BearishZones[i].bottom;
      double gap;
      if (top1 <= bot2)
         gap = bot2 - top1;
      else if (top2 <= bot1)
         gap = bot1 - top2;
      else
         gap = 0.0;

      if (gap <= touchEps)
      {
         if (DebugMode)
            Print("Skip new BEAR zone (overlap)", DoubleToStr(bot1, Digits), "-", DoubleToStr(top1, Digits),
                  " TF=", zone.timeframe,
                  " overlapping BEAR #", i,
                  " ", DoubleToStr(bot2, Digits), "-", DoubleToStr(top2, Digits));
         return;
      }
      if (gap < minZoneGap)
      {
         if (DebugMode)
            Print("Skip new BEAR zone ", DoubleToStr(bot1, Digits), "-", DoubleToStr(top1, Digits),
               " TF=", zone.timeframe,
               " too close to existing BEAR #", i,
               " ", DoubleToStr(bot2, Digits), "-", DoubleToStr(top2, Digits),
               " gap=", DoubleToStr(gap, Digits),
               " < minGap=", DoubleToStr(minZoneGap, Digits));
         return;
      }
   }
   for (int i = 0; i < totalBullZones; i++)
   {
      if (BullishZones[i].timeframe == zone.timeframe)
      {
         EnsureZoneOrdered(BullishZones[i]);
         double top2 = BullishZones[i].top;
         double bot2 = BullishZones[i].bottom;
         double gap;
         if (top1 <= bot2)
            gap = bot2 - top1;
         else if (top2 <= bot1)
            gap = bot1 - top2;
         else
            gap = 0.0;

         if (gap <= touchEps)
         {
            if (DebugMode)
               Print("BEAR vs BULL overlap ", DoubleToStr(bot1, Digits), "-", DoubleToStr(top1, Digits),
                     " TF=", zone.timeframe,
                     " with BULL #", i,
                     " ", DoubleToStr(bot2, Digits), "-", DoubleToStr(top2, Digits));
            return;
         }
         if (gap < minZoneGap)
         {
            if (DebugMode)
               Print("BEAR vs BULL conflict ", DoubleToStr(bot1, Digits), "-", DoubleToStr(top1, Digits),
                     " TF=", zone.timeframe,
                     " with BULL #", i,
                     " ", DoubleToStr(bot2, Digits), "-", DoubleToStr(top2, Digits),
                     " gap=", DoubleToStr(gap, Digits),
                     " < minGap=", DoubleToStr(minZoneGap, Digits));
            return;
         }
      }
      else
      {
         EnsureZoneOrdered(BullishZones[i]);

         double top2 = BullishZones[i].top;
         double bot2 = BullishZones[i].bottom;

         double gap;
         if (top1 <= bot2)
            gap = bot2 - top1;
         else if (top2 <= bot1)
            gap = bot1 - top2;
         else
            gap = 0.0;

         if (gap <= oppositeTfMinGap)
         {
            if (DebugMode)
               Print("BEAR vs BULL(xTF) conflict ", DoubleToStr(bot1, Digits), "-", DoubleToStr(top1, Digits),
                     " TF=", zone.timeframe,
                     " with BULL #", i,
                     " ", DoubleToStr(bot2, Digits), "-", DoubleToStr(top2, Digits),
                     " gap=", DoubleToStr(gap, Digits),
                     " <= xTFMinGap=", DoubleToStr(oppositeTfMinGap, Digits));
            return;
         }
      }
   }
   ArrayResize(BearishZones, totalBearZones + 1);
   BearishZones[totalBearZones] = zone;
   totalBearZones++;
   EnsureZoneFingerprint(BearishZones[totalBearZones - 1]);
   bool firstDetection = RememberSeenZoneFingerprint(
                            BearishZones[totalBearZones - 1].fingerprint);
   Print("BEAR zone accepted for display/entry: zone ",
         BearishZones[totalBearZones - 1].uniqueID,
         " fingerprint=", BearishZones[totalBearZones - 1].fingerprint,
         " firstDetection=", firstDetection,
         " Use_ImmediateEntry=", Use_ImmediateEntry);
   if (!g_isScanningHistory)
   {
       if (TimeDay(zone.startTime) == g_currentDay)
       {
           g_todayBearCount++;
       }
       
       if (EnableTelegram)
       {
           string msg = "Trace Institucional  Symbol: " + Symbol() + "\n" +
                        "Type: SELL \n" +
                        "SL: " + DoubleToString(zone.stopLoss, Digits) + "\n" +
                        "TP: " + DoubleToString(zone.takeProfit, Digits);
           SendTelegramMessage(msg);
       }
   }
   if (Use_ImmediateEntry)
      ImmediateEntry(BearishZones[totalBearZones-1], firstDetection);
   else
   {
      if (AutoTrade_OnNewZone)
         AttemptAutoTrade(BearishZones[totalBearZones-1], 1);
      PlaceZonePending(BearishZones[totalBearZones-1]);
   }

   if (DebugMode)
      Print("ADD BEAR zone #", totalBearZones,
            " TF=", zone.timeframe,
            " ", DoubleToStr(bot1, Digits), "-", DoubleToStr(top1, Digits),
            " Str:", DoubleToStr(zone.strength, 1));
}

//+------------------------------------------------------------------+
//| Count zones for specific timeframe                               |
//+------------------------------------------------------------------+
int CountBullZonesForTF(int tf)
{
   int count = 0;
   for (int i = 0; i < totalBullZones; i++)
   {
      if (BullishZones[i].timeframe == tf)
         count++;
   }
   return count;
}

int CountBearZonesForTF(int tf)
{
   int count = 0;
   for (int i = 0; i < totalBearZones; i++)
   {
      if (BearishZones[i].timeframe == tf)
         count++;
   }
   return count;
}

//+------------------------------------------------------------------+
//| Sort zones by strength (descending order - strongest first)      |
//+------------------------------------------------------------------+
void SortZonesByStrength()
{
   for(int i = 0; i < totalBullZones-1; i++)
   {
      for(int j = 0; j < totalBullZones-i-1; j++)
      {
         if(BullishZones[j].strength < BullishZones[j+1].strength)
         {
            ZoneInfo temp = BullishZones[j];
            BullishZones[j] = BullishZones[j+1];
            BullishZones[j+1] = temp;
         }
      }
   }
   for(int i = 0; i < totalBearZones-1; i++)
   {
      for(int j = 0; j < totalBearZones-i-1; j++)
      {
         if(BearishZones[j].strength < BearishZones[j+1].strength)
         {
            ZoneInfo temp = BearishZones[j];
            BearishZones[j] = BearishZones[j+1];
            BearishZones[j+1] = temp;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| VISUALS                                                          |
//+------------------------------------------------------------------+
void CleanupDailyLevelVisuals()
{
   string prefix = "TraceInst_DL_";
   int total = ObjectsTotal(0, -1, -1);

   for (int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, -1);
      if (StringFind(name, prefix) == 0)
         ObjectDelete(0, name);
   }
}

void DrawDailyLevel(string key, double price, color lineColor, int lineWidth,
                    string labelText, bool showLevel, datetime startTime,
                    datetime endTime, datetime labelTime)
{
   string lineName = "TraceInst_DL_" + key + "_Line";
   string textName = "TraceInst_DL_" + key + "_Text";

   if (!showLevel)
   {
      if (ObjectFind(0, lineName) != -1) ObjectDelete(0, lineName);
      if (ObjectFind(0, textName) != -1) ObjectDelete(0, textName);
      return;
   }

   if (ObjectFind(0, lineName) == -1)
      ObjectCreate(0, lineName, OBJ_TREND, 0, startTime, price, endTime, price);
   else
   {
      ObjectMove(0, lineName, 0, startTime, price);
      ObjectMove(0, lineName, 1, endTime, price);
   }

   int width = lineWidth;
   if (width < 1) width = 1;

   ObjectSetInteger(0, lineName, OBJPROP_COLOR, lineColor);
   ObjectSetInteger(0, lineName, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, DL_ExtendRight);
   ObjectSetInteger(0, lineName, OBJPROP_BACK, true);
   ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, lineName, OBJPROP_HIDDEN, true);

   if (!DL_ShowLabels || labelText == "")
   {
      if (ObjectFind(0, textName) != -1) ObjectDelete(0, textName);
      return;
   }

   if (ObjectFind(0, textName) == -1)
      ObjectCreate(0, textName, OBJ_TEXT, 0, labelTime, price);
   else
      ObjectMove(0, textName, 0, labelTime, price);

   string displayText = labelText;
   if (DL_ShowPrice)
      displayText = labelText + "  " + DoubleToString(price, Digits);
   ObjectSetString(0, textName, OBJPROP_TEXT, displayText);
   ObjectSetString(0, textName, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, textName, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, textName, OBJPROP_COLOR, lineColor);
   ObjectSetInteger(0, textName, OBJPROP_ANCHOR,
                    DL_LabelAbove ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, textName, OBJPROP_BACK, false);
   ObjectSetInteger(0, textName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, textName, OBJPROP_HIDDEN, true);
}

bool DailyLevelsGet(double &dayHigh, double &dayLow, double &mid,
                    double &lowMid, double &midHigh)
{
   if (!Use_DailyLevels || iBars(Symbol(), PERIOD_D1) < 2)
      return false;

   // Which daily candle to read:
   //  DL_UseCurrentDay = true  -> shift 0 = the current, still-forming day.
   //     Its High/Low reset the moment a new D1 bar opens (i.e. when XAUUSD
   //     re-opens after the daily break) and then build up until the day closes.
   //  DL_UseCurrentDay = false -> shift 1 = the previous (completed) day.
   int dlShift = DL_UseCurrentDay ? 0 : 1;
   dayHigh = iHigh(Symbol(), PERIOD_D1, dlShift);
   dayLow = iLow(Symbol(), PERIOD_D1, dlShift);
   if (dayHigh <= dayLow)
      return false;
   mid = (dayHigh + dayLow) * 0.50;
   lowMid = (dayLow + mid) * 0.50;
   midHigh = (mid + dayHigh) * 0.50;
   return true;
}

void UpdateDailyLevels()
{
   double dayHigh = 0.0, dayLow = 0.0, mid = 0.0;
   double lowMid = 0.0, midHigh = 0.0;
   if (!DailyLevelsGet(dayHigh, dayLow, mid, lowMid, midHigh))
   {
      CleanupDailyLevelVisuals();
      return;
   }

   int chartBars = iBars(Symbol(), Period());
   if (chartBars < 1)
   {
      CleanupDailyLevelVisuals();
      return;
   }

   int shiftBars = DL_ShiftBars;
   if (shiftBars < 0) shiftBars = 0;
   if (shiftBars >= chartBars) shiftBars = chartBars - 1;

   // Left end starts DL_ShiftBars candles back from the CURRENT candle (0 = at the
   // current candle). We do NOT anchor to the day's open, so the lines do not
   // stretch all the way back to 00:00 - they sit near the price and extend right.
   datetime startTime = iTime(Symbol(), Period(), shiftBars);
   datetime currentTime = iTime(Symbol(), Period(), 0);
   if (startTime <= 0 || currentTime <= 0)
   {
      CleanupDailyLevelVisuals();
      return;
   }

   int secondsPerBar = PeriodSeconds(Period());
   if (secondsPerBar <= 0) secondsPerBar = 60;

   // Global horizontal nudge in candles: negative = move left, positive = move right.
   int hShiftSec = secondsPerBar * DL_HShiftBars;

   int futureBars = DL_FutureBars;
   if (futureBars < 1) futureBars = 1;

   // Right end is anchored to the CURRENT candle (bar 0), so the lines keep
   // moving forward with every new candle. hShiftSec lets you drag them left/right.
   startTime          = startTime + hShiftSec;
   datetime endTime   = currentTime + (secondsPerBar * futureBars) + hShiftSec;
   datetime labelTime = currentTime + (secondsPerBar * DL_LabelShiftBars) + hShiftSec;

   DrawDailyLevel("High", dayHigh, DL_HighColor, DL_LineWidth,
                  DL_HighLabel, DL_ShowHigh, startTime, endTime, labelTime);
   DrawDailyLevel("Low", dayLow, DL_LowColor, DL_LineWidth,
                  DL_LowLabel, DL_ShowLow, startTime, endTime, labelTime);
   DrawDailyLevel("Mid", mid, DL_MidColor, DL_LineWidth,
                  DL_MidLabel, DL_ShowMid, startTime, endTime, labelTime);
   DrawDailyLevel("LowMid", lowMid, DL_LowMidColor, DL_SubLineWidth,
                  DL_LowMidLabel, DL_ShowLowMid, startTime, endTime, labelTime);
   DrawDailyLevel("MidHigh", midHigh, DL_MidHighColor, DL_SubLineWidth,
                  DL_MidHighLabel, DL_ShowMidHigh, startTime, endTime, labelTime);
}

void CleanupAllVisuals()
{
   string prefix = "TraceInst_";
   
   int total = ObjectsTotal(0, -1, -1);
   for (int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, -1);
      if (StringFind(name, prefix) == 0)
         ObjectDelete(0, name);
   }
   
   ChartRedraw(0);
}

void UpdateVisuals()
{
   SortZonesByStrength();
   int currentTF = Period();
   for (int i = 0; i < totalBullZones; i++)
   {
      if (BullishZones[i].timeframe != currentTF) continue;
      CheckZoneHits(BullishZones[i]);
      DrawZoneRectangle(BullishZones[i], i, true);
      if (Show_SL_TP_Lines) DrawSLTPLines(BullishZones[i], i, true);
   }
   for (int i = 0; i < totalBearZones; i++)
   {
      if (BearishZones[i].timeframe != currentTF) continue;
      CheckZoneHits(BearishZones[i]);
      DrawZoneRectangle(BearishZones[i], i, false);
      if (Show_SL_TP_Lines) DrawSLTPLines(BearishZones[i], i, false);
   }

   UpdateDailyLevels();
   
   string status = StringFormat("Trace Institucional Running... | %s", TimeToString(TimeCurrent(), TIME_SECONDS));
   string lblName = "TraceInst_Status_Hidden";
   if(ObjectFind(0, lblName) == -1)
   {
      ObjectCreate(0, lblName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, lblName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, lblName, OBJPROP_XDISTANCE, 1);
      ObjectSetInteger(0, lblName, OBJPROP_YDISTANCE, 1);
      ObjectSetInteger(0, lblName, OBJPROP_BACK, true);
      ObjectSetInteger(0, lblName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, lblName, OBJPROP_HIDDEN, true);
   }
   ObjectSetString(0, lblName, OBJPROP_TEXT, status);
   ObjectSetInteger(0, lblName, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, lblName, OBJPROP_FONTSIZE, 8);
   Comment("");
   ChartRedraw(0);
}

void CheckZoneHits(ZoneInfo &zone)
{
   // Reset status to allow re-evaluation with new logic
   bool wasHit = zone.tpHit || zone.slHit;
   zone.tpHit = false;
   zone.slHit = false;
   
   int startBar = iBarShift(Symbol(), zone.timeframe, zone.startTime);
   if (startBar < 0) return;

   double slPrice, tpPrice;
   double pt = Point;
   if (pt == 0) pt = 0.0001;

   if (zone.zoneType == "Bull")
   {
      double entry = zone.top;
      slPrice = zone.bottom - (SL_Buffer_Points * pt);
      tpPrice = entry + ((entry - slPrice) * Risk_Reward_Ratio);
   }
   else
   {
      double entry = zone.bottom;
      slPrice = zone.top + (SL_Buffer_Points * pt);
      tpPrice = entry - ((slPrice - entry) * Risk_Reward_Ratio);
   }

   slPrice = NormalizeDouble(slPrice, Digits);
   tpPrice = NormalizeDouble(tpPrice, Digits);
   // A traded zone keeps the levels the order was actually sent with
   if (!zone.isTraded)
   {
      zone.stopLoss = slPrice;
      zone.takeProfit = tpPrice;
   }
   else
   {
      slPrice = zone.stopLoss;
      tpPrice = zone.takeProfit;
   }

   if (Use_OrderBlocks && !zone.breaker && zone.breakoutBar > 0)
   {
      // Check from breakoutBar - 1 to avoid treating the zone-forming neighbor wicks as a break
      int checkBar = iBarShift(Symbol(), zone.timeframe, zone.breakoutTime);
      if (checkBar > 0)
      {
         for (int i = checkBar - 1; i >= 0; i--)
         {
            if (OB_IsMitigatedBar(zone, i))
            {
               zone.breaker = true;
               zone.hitTime = iTime(Symbol(), zone.timeframe, i);
               break;
            }
         }
      }
   }
   
   // If it was previously hit, we can optimize by scanning from hitTime? 
   // But for safety and fixing the bug, let's scan from start.
   
   int hitScanBar = iBarShift(Symbol(), zone.timeframe, zone.breakoutTime);
   for (int i = hitScanBar; i >= 0; i--)
   {
      double high = iHigh(Symbol(), zone.timeframe, i);
      double low  = iLow(Symbol(), zone.timeframe, i);
      
      double open  = iOpen(Symbol(), zone.timeframe, i);
      double close = iClose(Symbol(), zone.timeframe, i);

      if (zone.zoneType == "Bull")
      {
         bool hitSL = (low <= zone.stopLoss);
         bool hitTP = (high >= zone.takeProfit);
         
         // Priority Check for Single Bar Double Hit
         if (hitSL && hitTP)
         {
             // Red Candle: Open -> High(TP) -> Low(SL) -> Close => TP First
             if (close < open) hitSL = false;
             // Green Candle: Open -> Low(SL) -> High(TP) -> Close => SL First
             else hitTP = false;
         }
         
         if (hitSL) {
            zone.slHit = true;
            zone.hitTime = iTime(Symbol(), zone.timeframe, i);
            return;
         }
         if (hitTP) {
            zone.tpHit = true;
            zone.hitTime = iTime(Symbol(), zone.timeframe, i);
            return;
         }
      }
      else
      {
         bool hitSL = (high >= zone.stopLoss);
         bool hitTP = (low <= zone.takeProfit);
         
         // Priority Check for Single Bar Double Hit
         if (hitSL && hitTP)
         {
             // Green Candle: Open -> Low(TP) -> High(SL) -> Close => TP First
             if (close > open) hitSL = false;
             // Red Candle: Open -> High(SL) -> Low(TP) -> Close => SL First
             else hitTP = false;
         }
         
         if (hitSL) {
            zone.slHit = true;
            zone.hitTime = iTime(Symbol(), zone.timeframe, i);
            return;
         }
         if (hitTP) {
            zone.tpHit = true;
            zone.hitTime = iTime(Symbol(), zone.timeframe, i);
            return;
         }
      }
   }
}

void DrawZoneRectangle(ZoneInfo &zone, int index, bool isBull)
{
   string rectName = GetZoneObjectName(zone, "RECT");
   
   color zoneColor = GetZoneColor(zone.strength);
   if (zone.slHit) zoneColor = ZoneHitSLColor;
   else if (zone.tpHit) zoneColor = ZoneHitTPColor;
   else if (Use_OrderBlocks)
   {
      zoneColor = isBull ? OB_BullColor : OB_BearColor;
      if (zone.breaker) zoneColor = clrDimGray;
   }
   else
   {
      if (zone.isElite) zoneColor = EliteColor;
      zoneColor = GetZoneColor(zone.strength);
   }
   
   int zoneWidth = GetZoneWidth(zone.strength);
   
   datetime timeStart = zone.startTime;
   datetime nowBarTime = iTime(Symbol(), zone.timeframe, 0);
   int extendBars = Use_OrderBlocks ? OB_ExtendBars : ProjectionBarsAhead;
   if (extendBars < 1) extendBars = ProjectionBarsAhead;
   datetime timeEnd = nowBarTime + extendBars * PeriodSeconds(zone.timeframe);
   if (timeEnd <= timeStart)
      timeEnd = timeStart + extendBars * PeriodSeconds(zone.timeframe);
   
   double top = zone.top;
   double bottom = zone.bottom;
   if (top < bottom)
   {
      double tmp = top;
      top = bottom;
      bottom = tmp;
   }
   
   if (ObjectFind(0, rectName) == -1)
   {
      ObjectCreate(0, rectName, OBJ_RECTANGLE, 0, timeStart, top, timeEnd, bottom);
      ObjectSetInteger(0, rectName, OBJPROP_STYLE, Use_OrderBlocks ? STYLE_SOLID : STYLE_DASH);
      ObjectSetInteger(0, rectName, OBJPROP_WIDTH, Zone_Opacity);
      ObjectSetInteger(0, rectName, OBJPROP_BACK, true);
      ObjectSetInteger(0, rectName, OBJPROP_SELECTABLE, false);
   }
   else
   {
      datetime existing_time1 = (datetime)ObjectGetInteger(0, rectName, OBJPROP_TIME1);
      if (existing_time1 > 0)
         timeStart = existing_time1;
      
      ObjectMove(0, rectName, 0, timeStart, top);
      ObjectMove(0, rectName, 1, timeEnd, bottom);
      ObjectSetInteger(0, rectName, OBJPROP_WIDTH, Zone_Opacity);
   }
   ObjectSetInteger(0, rectName, OBJPROP_COLOR, zoneColor);
   ObjectSetInteger(0, rectName, OBJPROP_FILL, true);
   ObjectSetInteger(0, rectName, OBJPROP_BACK, true);
   string statusName = GetZoneObjectName(zone, "Status");

   if (zone.slHit || zone.tpHit)
   {
      double midPrice = (top + bottom) / 2.0;
      datetime midTime = timeStart;
      
      if (ObjectFind(0, statusName) == -1)
      {
         ObjectCreate(0, statusName, OBJ_TEXT, 0, midTime, midPrice);
         ObjectSetInteger(0, statusName, OBJPROP_FONTSIZE, 8);
         ObjectSetString(0, statusName, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, statusName, OBJPROP_ANCHOR, ANCHOR_LEFT);
         ObjectSetInteger(0, statusName, OBJPROP_BACK, false);
         ObjectSetInteger(0, statusName, OBJPROP_SELECTABLE, false);
      }
      else
      {
         ObjectMove(0, statusName, 0, midTime, midPrice);
      }
      
      if (zone.tpHit)
      {
         ObjectSetString(0, statusName, OBJPROP_TEXT, "PROFIT");
         ObjectSetInteger(0, statusName, OBJPROP_COLOR, clrLime);
      }
      else if (zone.slHit)
      {
         ObjectSetString(0, statusName, OBJPROP_TEXT, "LOSS");
         ObjectSetInteger(0, statusName, OBJPROP_COLOR, clrRed);
      }
   }
   else
   {
      if (ObjectFind(0, statusName) != -1) ObjectDelete(0, statusName);
   }

   if (!Use_OrderBlocks)
   {
      if (zone.isElite)
      {
          string liqName = GetZoneObjectName(zone, "LIQ");
          datetime midTime = timeStart;
          
          if (ObjectFind(0, liqName) == -1)
          {
              ObjectCreate(0, liqName, OBJ_TEXT, 0, midTime, (isBull ? bottom - Point*10 : top + Point*10));
              ObjectSetString(0, liqName, OBJPROP_TEXT, "Liquidity");
              ObjectSetInteger(0, liqName, OBJPROP_COLOR, clrAqua);
              ObjectSetInteger(0, liqName, OBJPROP_ANCHOR, ANCHOR_LEFT);
              ObjectSetInteger(0, liqName, OBJPROP_FONTSIZE, 8);
              ObjectSetInteger(0, liqName, OBJPROP_BACK, false);
          }
          else
          {
              ObjectMove(0, liqName, 0, midTime, (isBull ? bottom - Point*10 : top + Point*10));
          }
      }
      
      string volName = GetZoneObjectName(zone, "VOL");
      if (zone.relativeVolume > 0)
      {
         string volText = StringFormat("Vol: %.1fx", zone.relativeVolume);
         double volPrice = bottom;
         datetime volTime = timeEnd;
         
         if (ObjectFind(0, volName) == -1)
         {
            ObjectCreate(0, volName, OBJ_TEXT, 0, volTime, volPrice);
            ObjectSetString(0, volName, OBJPROP_TEXT, volText);
            ObjectSetInteger(0, volName, OBJPROP_COLOR, clrWhite);
            ObjectSetInteger(0, volName, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
            ObjectSetInteger(0, volName, OBJPROP_FONTSIZE, 7);
            ObjectSetInteger(0, volName, OBJPROP_BACK, false);
         }
         else
         {
            ObjectMove(0, volName, 0, volTime, volPrice);
            ObjectSetString(0, volName, OBJPROP_TEXT, volText);
            ObjectSetInteger(0, volName, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
         }
      }
   }
   else
   {
      string midName = GetZoneObjectName(zone, "MID");
      if (OB_ShowMidLine && !zone.breaker)
      {
         double midPrice = (top + bottom) / 2.0;
         if (ObjectFind(0, midName) == -1)
         {
            ObjectCreate(0, midName, OBJ_TREND, 0, timeStart, midPrice, timeEnd, midPrice);
            ObjectSetInteger(0, midName, OBJPROP_RAY_RIGHT, false);
            ObjectSetInteger(0, midName, OBJPROP_STYLE, STYLE_DOT);
            ObjectSetInteger(0, midName, OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, midName, OBJPROP_BACK, true);
            ObjectSetInteger(0, midName, OBJPROP_SELECTABLE, false);
         }
         else
         {
            ObjectMove(0, midName, 0, timeStart, midPrice);
            ObjectMove(0, midName, 1, timeEnd, midPrice);
         }
         ObjectSetInteger(0, midName, OBJPROP_COLOR, zoneColor);
      }
      else
      {
         if (ObjectFind(0, midName) != -1) ObjectDelete(0, midName);
      }
      string volName = GetZoneObjectName(zone, "VOL");
      if (ObjectFind(0, volName) != -1) ObjectDelete(0, volName);
      string liqName = GetZoneObjectName(zone, "LIQ");
      if (ObjectFind(0, liqName) != -1) ObjectDelete(0, liqName);
   }
}

void DrawSLTPLines(ZoneInfo &zone, int index, bool isBull)
{
   if (!Show_SL_TP_Lines) return;

   datetime lineStartTime = zone.startTime;
   datetime nowBarTime = iTime(Symbol(), zone.timeframe, 0);
   datetime lineEndTime = nowBarTime + ProjectionBarsAhead * PeriodSeconds(zone.timeframe);
   if (lineEndTime <= lineStartTime)
      lineEndTime = lineStartTime + ProjectionBarsAhead * PeriodSeconds(zone.timeframe);

   double zoneHeight = zone.top - zone.bottom;
   if (zoneHeight <= 0) return;

   double slPrice, tpPrice;
   double pt = Point;
   if (pt == 0) pt = 0.0001;

   if (isBull)
   {
      double entry = zone.top;
      slPrice = zone.bottom - (SL_Buffer_Points * pt);
      tpPrice = entry + ((entry - slPrice) * Risk_Reward_Ratio);
   }
   else
   {
      double entry = zone.bottom;
      slPrice = zone.top + (SL_Buffer_Points * pt);
      tpPrice = entry - ((slPrice - entry) * Risk_Reward_Ratio);
   }

   slPrice = NormalizeDouble(slPrice, Digits);
   tpPrice = NormalizeDouble(tpPrice, Digits);
   if (!zone.isTraded)
   {
      zone.stopLoss    = slPrice;
      zone.takeProfit  = tpPrice;
   }
   else
   {
      slPrice = zone.stopLoss;
      tpPrice = zone.takeProfit;
   }

   // --- SL Line ---
   if (ObjectFind(0, zone.slName) == -1)
   {
      ObjectCreate(0, zone.slName, OBJ_TREND, 0, lineStartTime, slPrice, lineEndTime, slPrice);
      ObjectSetInteger(0, zone.slName, OBJPROP_COLOR, Color_SL);
      ObjectSetInteger(0, zone.slName, OBJPROP_WIDTH, SL_TP_Width);
      ObjectSetInteger(0, zone.slName, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, zone.slName, OBJPROP_STYLE, STYLE_SOLID);
   }
   else
   {
      ObjectMove(0, zone.slName, 0, lineStartTime, slPrice);
      ObjectMove(0, zone.slName, 1, lineEndTime, slPrice);
      ObjectSetInteger(0, zone.slName, OBJPROP_COLOR, Color_SL);
      ObjectSetInteger(0, zone.slName, OBJPROP_WIDTH, SL_TP_Width);
   }

   // --- TP Line ---
   if (ObjectFind(0, zone.tpName) == -1)
   {
      ObjectCreate(0, zone.tpName, OBJ_TREND, 0, lineStartTime, tpPrice, lineEndTime, tpPrice);
      ObjectSetInteger(0, zone.tpName, OBJPROP_COLOR, Color_TP);
      ObjectSetInteger(0, zone.tpName, OBJPROP_WIDTH, SL_TP_Width);
      ObjectSetInteger(0, zone.tpName, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, zone.tpName, OBJPROP_STYLE, STYLE_DOT);
   }
   else
   {
      ObjectMove(0, zone.tpName, 0, lineStartTime, tpPrice);
      ObjectMove(0, zone.tpName, 1, lineEndTime, tpPrice);
      ObjectSetInteger(0, zone.tpName, OBJPROP_COLOR, Color_TP);
      ObjectSetInteger(0, zone.tpName, OBJPROP_WIDTH, SL_TP_Width);
   }

   // --- Price Labels (Text next to lines) ---
   if (Show_Price_Labels)
   {
      // SL Label
      if (ObjectFind(0, zone.slTextName) == -1)
      {
         ObjectCreate(0, zone.slTextName, OBJ_TEXT, 0, lineEndTime, slPrice);
         ObjectSetInteger(0, zone.slTextName, OBJPROP_COLOR, Color_SL);
         ObjectSetInteger(0, zone.slTextName, OBJPROP_FONTSIZE, 8);
         ObjectSetInteger(0, zone.slTextName, OBJPROP_ANCHOR, ANCHOR_LEFT);
      }
      else
      {
         ObjectMove(0, zone.slTextName, 0, lineEndTime, slPrice);
      }
      ObjectSetString(0, zone.slTextName, OBJPROP_TEXT, "  SL: " + DoubleToString(slPrice, Digits));

      // TP Label
      if (ObjectFind(0, zone.tpTextName) == -1)
      {
         ObjectCreate(0, zone.tpTextName, OBJ_TEXT, 0, lineEndTime, tpPrice);
         ObjectSetInteger(0, zone.tpTextName, OBJPROP_COLOR, Color_TP);
         ObjectSetInteger(0, zone.tpTextName, OBJPROP_FONTSIZE, 8);
         ObjectSetInteger(0, zone.tpTextName, OBJPROP_ANCHOR, ANCHOR_LEFT);
      }
      else
      {
         ObjectMove(0, zone.tpTextName, 0, lineEndTime, tpPrice);
      }
      ObjectSetString(0, zone.tpTextName, OBJPROP_TEXT, "  TP: " + DoubleToString(tpPrice, Digits));
   }
}

bool IsZoneBroken(ZoneInfo &zone)
{
   double price = iClose(Symbol(), zone.timeframe, 0);
   
   int breakBar = iBarShift(Symbol(), zone.timeframe, zone.breakoutTime);
   int endBar   = 0;
   
   for (int i = endBar; i < breakBar; i++)
   {
      double c = iClose(Symbol(), zone.timeframe, i);
      if (zone.zoneType == "Bull" && c < zone.bottom - (Point * 5)) return true;
      if (zone.zoneType == "Bear" && c > zone.top + (Point * 5)) return true;
   }
   
   if (zone.zoneType == "Bull" && price < zone.bottom - (Point * 10))
      return true;

   if (zone.zoneType == "Bear" && price > zone.top + (Point * 10))
      return true;
   
   return false;
}

string GetZoneObjectName(ZoneInfo &zone, string suffix)
{
   return StringFormat("TraceInst_%s_%s_%d_%s",
                       TimeframeToString(zone.timeframe),
                       zone.zoneType,
                       zone.uniqueID,
                       suffix);
}
 
string TimeframeToString(int tf)
{
   switch (tf)
   {
      case PERIOD_M1:  return "M1";
      case PERIOD_M5:  return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H4:  return "H4";
      case PERIOD_D1:  return "D1";
      case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN1";
      default:         return "CUR";
   }
}

//+------------------------------------------------------------------+
//| AUTO STRENGTH LOGIC (Score 1-10)                                 |
//+------------------------------------------------------------------+
void RecalculateAllZones()
{
   for (int i = 0; i < totalBullZones; i++)
   {
      double oldScore = BullishZones[i].strength;
      double newScore = CalculateZoneScore(BullishZones[i]);   
      BullishZones[i].strength = newScore;
      BullishZones[i].isElite  = (newScore >= 8.0);
   }
   for (int i = 0; i < totalBearZones; i++)
   {
      double oldScore = BearishZones[i].strength;
      double newScore = CalculateZoneScore(BearishZones[i]);
      
      BearishZones[i].strength = newScore;
      BearishZones[i].isElite  = (newScore >= 8.0);
   }
}

double CalculateZoneScore(ZoneInfo &zone)
{
   int boBar = zone.breakoutBar;
   if (zone.breakoutTime > 0)
      boBar = iBarShift(Symbol(), zone.timeframe, zone.breakoutTime, true);
   
   if (boBar < 0) return zone.strength;
   
   double atr = iATR(Symbol(), zone.timeframe, ATR_Period_Strength, boBar);
   if (atr <= 0) atr = Point; 
   double breakoutRange = iHigh(Symbol(), zone.timeframe, boBar) - iLow(Symbol(), zone.timeframe, boBar);
   double scoreBase = (breakoutRange / atr) * 1.5; 
   if (scoreBase > 3.0) scoreBase = 3.0;
   long   boVol   = iVolume(Symbol(), zone.timeframe, boBar);
   double volSum = 0;
   for(int v=1; v<=20; v++) volSum += (double)iVolume(Symbol(), zone.timeframe, boBar + v);
   double avgVol = volSum / 20.0;
   double volRatio = 0;
   if (avgVol > 0) volRatio = (double)boVol / avgVol;
   double scoreVol = 0;
   if (volRatio >= 2.0) scoreVol = 2.0;
   else if (volRatio >= 1.5) scoreVol = 1.5;
   else if (volRatio >= 1.0) scoreVol = 1.0;
   else scoreVol = 0.5;
   int touches = 0;
   for (int k = boBar - 1; k >= 0; k--)
   {
      double lo = iLow(Symbol(), zone.timeframe, k);
      double hi = iHigh(Symbol(), zone.timeframe, k);
      
      if (zone.zoneType == "Bull")
      {
         if (lo <= zone.top && hi >= zone.bottom) touches++;
      }
      else
      {
         if (hi >= zone.bottom && lo <= zone.top) touches++;
      }
   }
   zone.touches = touches; 
   
   double scoreReact = 0;
   if (touches == 0) scoreReact = 1.0;
   else if (touches == 1) scoreReact = 2.0;
   else if (touches == 2) scoreReact = 1.5;
   else if (touches > 3) scoreReact = 0.0;
   int currentTrend = GetMarketTrend(zone.timeframe, 1);
   int htf = GetHigherTimeframe(zone.timeframe);
   int htfTrend = GetMarketTrend(htf, 1);
   
   double scoreTrend = 0.0;
   bool isCounterTrend = false;
   int finalTrend = 0;
   if (currentTrend == 1 && htfTrend == 1) finalTrend = 1;
   else if (currentTrend == -1 && htfTrend == -1) finalTrend = -1;
   else if (htfTrend != 0) finalTrend = htfTrend;
   else finalTrend = currentTrend;
   
   if (zone.zoneType == "Bull")
   {
      if (finalTrend == 1) scoreTrend = 2.0;
      else if (finalTrend == -1) {
          scoreTrend = -4.0;
          isCounterTrend = true;
      }
   }
   else
   {
      if (finalTrend == -1) scoreTrend = 2.0;
      else if (finalTrend == 1) {
          scoreTrend = -4.0;
          isCounterTrend = true;
      }
   }
   double scoreRSI = 0.0;
   double rsiVal = iRSI(Symbol(), zone.timeframe, RSI_Period, PRICE_CLOSE, zone.baseEndBar);
   
   if (zone.zoneType == "Bull") {
       if (rsiVal <= 30) scoreRSI = 1.5;
       else if (rsiVal <= 40) scoreRSI = 1.0;
       else if (rsiVal >= 60) scoreRSI = -1.0;
   } else {
       if (rsiVal >= 70) scoreRSI = 1.5;
       else if (rsiVal >= 60) scoreRSI = 1.0;
       else if (rsiVal <= 40) scoreRSI = -1.0;
   }
   double scoreHTF = 0.0;
   if (zone.zoneType == "Bull") {
       for (int i = 0; i < totalBullZones; i++) {
           if (BullishZones[i].timeframe == htf) {
               double maxBottom = MathMax(zone.bottom, BullishZones[i].bottom);
               double minTop    = MathMin(zone.top, BullishZones[i].top);
               if (minTop > maxBottom) {
                    scoreHTF = 2.0; 
                    break;
               }
           }
       }
   } else {
       for (int i = 0; i < totalBearZones; i++) {
           if (BearishZones[i].timeframe == htf) {
               double maxBottom = MathMax(zone.bottom, BearishZones[i].bottom);
               double minTop    = MathMin(zone.top, BearishZones[i].top);
               if (minTop > maxBottom) {
                    scoreHTF = 2.0; 
                    break;
               }
           }
       }
   }
   double total = scoreBase + scoreVol + scoreReact + scoreTrend + scoreRSI + scoreHTF;
   
   // --- Quality filter scores (Liquidity Sweep, Relative Volume, MSS) ---
   // These add bonus points for zones that show higher quality characteristics.
   // Zones without these qualities still appear, but with lower scores.
   double scoreLiqSweep = GetLiquiditySweepScore(zone, zone.timeframe);
   if (scoreLiqSweep > 0) total += scoreLiqSweep;
   
   double scoreRV = GetRVScore(zone, zone.timeframe);
   if (scoreRV > 0) total += scoreRV;

   double scoreDeltaCVD = GetDeltaCVDScore(zone, zone.timeframe);
   total += scoreDeltaCVD;
   
   double scoreMSS = GetMSSScore(zone, zone.timeframe);
   if (scoreMSS > 0) total += scoreMSS;

   if (zone.bosStrength > 0) total += zone.bosStrength;

   double volDiv = GetVolumeDivergenceScore(zone, zone.timeframe);
   if (volDiv > 0) total -= volDiv * MathMax(0.0, VD_StrengthPenalty);
   
   double curATR = iATR(Symbol(), zone.timeframe, ATR_Period_Strength, 1);
   if (curATR > atr * 1.5) total += 0.5;
   if (isCounterTrend)
   {
       if (total > 3.5) total = 3.5;
   }
   
   if (total > 10.0) total = 10.0;
   if (total < 1.0) total = 1.0;
   
   return total;
}

color GetZoneColor(double score)
{
   if (score >= 8.0) return clrFireBrick;
   if (score >= 6.0) return clrOrangeRed;
   if (score >= 4.0) return clrGold;
   return clrGray;
}

int GetZoneWidth(double score)
{
   if (score >= 8.0) return 5;
   if (score >= 6.0) return 4;
   if (score >= 4.0) return 3;
   return 2;
}

//+------------------------------------------------------------------+ 
//| TELEGRAM NOTIFICATIONS                                           | 
//+------------------------------------------------------------------+ 
void TelegramReportFail(string why)
{
   g_tgLastError = why;
   g_tgFailCount++;
   Print("Telegram FAILED: ", why);
   if (Chat_Enable && !IsTesting() && !IsOptimization())
   {
      ChatAppend("TELEGRAM NE E PRATENO: " + why, clrRed);
      ChartRedraw();
   }
}

bool SendTelegramMessage(string message)
{
   if (!EnableTelegram) { if (DebugMode) Print("Telegram: disabled"); return false; }
   if (TelegramBotToken == "") { TelegramReportFail("TelegramBotToken e prazen (vnesi go vo Inputs)"); return false; }
   if (TelegramChatID == "")  { TelegramReportFail("TelegramChatID e prazen (vnesi go vo Inputs)"); return false; }
   if (IsTesting() || IsOptimization()) return false;

   string url = "https://api.telegram.org/bot" + TelegramBotToken + "/sendMessage";

   string headers = "Content-Type: application/json\r\n";
   string text = message;
   StringReplace(text, "\\", "\\\\");
   StringReplace(text, "\"", "\\\"");
   StringReplace(text, "\r", "");
   StringReplace(text, "\n", "\\n");
   if (StringLen(text) > 4000) text = StringSubstr(text, 0, 4000);

   string params = "{\"chat_id\":\"" + TelegramChatID + "\",\"text\":\"" + text + "\"}";

   if (DebugMode) Print("Telegram sending: ", params);

   char data[];
   int len = StringToCharArray(params, data, 0, -1, CP_UTF8);
   if (len > 1) ArrayResize(data, len - 1);

   int res = -1; int err = 0; string resp = "";
   for (int attempt = 0; attempt < 2; attempt++)
   {
      char result[];
      string result_headers;
      ResetLastError();
      res = WebRequest("POST", url, headers, 10000, data, result, result_headers);
      err = GetLastError();
      if (res == 200) break;
      resp = CharArrayToString(result, 0, -1, CP_UTF8);
      if (res == -1 && err == 4014) break;
      if (res >= 400 && res < 500 && res != 429) break;
      Sleep(700);
   }

   if (res == 200)
   {
      g_tgLastError = "";
      if (DebugMode) Print("Telegram OK - message sent successfully");
      return true;
   }
   if (res == -1)
   {
      string why = "WebRequest err=" + IntegerToString(err);
      if (err == 4014)
         why += " - dodaj https://api.telegram.org vo Tools > Options > Expert Advisors > Allow WebRequest";
      else if (err == 4060)
         why += " - WebRequest ne e dozvolen (shtiklirj Allow WebRequest)";
      else if (err == 5203)
         why += " - HTTP request failed (internet/proxy/DNS)";
      else
         why += " - proveri internet konekcija";
      TelegramReportFail(why);
      return false;
   }
   string why2 = "HTTP " + IntegerToString(res);
   if (res == 401 || res == 404) why2 += " - nevaliden TelegramBotToken";
   else if (res == 400) why2 += " - nevaliden TelegramChatID (prvo prati /start na bot-ot)";
   else if (res == 403) why2 += " - bot-ot e blokiran / ne e vo grupata";
   else if (res == 429) why2 += " - previse poraki (rate limit)";
   if (StringLen(resp) > 0) why2 += " | " + StringSubstr(resp, 0, 160);
   TelegramReportFail(why2);
   return false;
}

void CreateLabel(string name, string text, int x, int y, color clr, int fontSize, bool bold=false)
{
   string objName = "TraceInst_" + name;
   if(ObjectFind(0, objName) == -1)
   {
      ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, objName, OBJPROP_BACK, false);
      ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   }
   else
   {
       ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
       ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
   }
   
   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, fontSize);
   if(bold) ObjectSetString(0, objName, OBJPROP_FONT, "Arial Bold");
   else ObjectSetString(0, objName, OBJPROP_FONT, "Arial");
}

string GetSessionString() 
 { 
    datetime now = TimeLocal(); 
    int hour = TimeHour(now); 
    int dayOfWeek = TimeDayOfWeek(now); 
    
    string active = ""; 
    string next = ""; 
    
    if (dayOfWeek == 0 || dayOfWeek == 6) 
    { 
        active = "WEEKEND"; 
        next = "ASIA (Sun 23:00)"; 
        return active + "|" + next; 
    } 
 
    if(hour >= 0 && hour < 9) 
    { 
        active = "ASIA"; 
        next = "LONDON (09:00)"; 
    } 
    else if(hour >= 9 && hour < 16) 
    { 
        active = "LONDON"; 
        next = "NEW YORK (16:00)"; 
    } 
    else if(hour >= 16 && hour < 23) 
    { 
        active = "NEW YORK"; 
        next = "ASIA (00:00)"; 
    } 
    else 
    { 
        active = "MARKET QUIET"; 
        next = "ASIA (00:00)"; 
    } 
    
    return active + "|" + next; 
 }

void UpdateDashboard() 
{ 
   if (!EnableDashboard) return; 

   int x = 20; 
   int y = 30;

   string dashLabels[] = {
      "TraceInst_Title",
      "TraceInst_Time",
      "TraceInst_Sep1",
      "TraceInst_TF",
      "TraceInst_ZonesBull",
      "TraceInst_ZonesBear",
      "TraceInst_TPHits",
      "TraceInst_SLHits",
      "TraceInst_Sep2",
      "TraceInst_MarketStructureTF",
      "TraceInst_MarketStructure",
      "TraceInst_BOSLevel",
      "TraceInst_PrevBOS",
      "TraceInst_BOSDistance",
      "TraceInst_BOSFalseBreak",
      "TraceInst_StructureStrength",
      "TraceInst_SignalBanner",
      "TraceInst_SignalScore",
      "TraceInst_SignalGrade",
      "TraceInst_SignalHTF",
      "TraceInst_SignalSession",
      "TraceInst_SignalAction",
      "TraceInst_SignalAI",
      "TraceInst_SignalDRHdr",
      "TraceInst_SignalDRTxt",
      "TraceInst_SignalDRCount",
      "TraceInst_SepSignal",
      "TraceInst_Sep3",
      "TraceInst_Session",
      "TraceInst_NextSes",
      "TraceInst_Sep4",
      "TraceInst_Status",
      "TraceInst_Sep5",
      "TraceInst_RiskPnL",
      "TraceInst_RiskTrades",
      "TraceInst_RiskSpread",
      "TraceInst_RiskGuard",
      "TraceInst_PrevBOSLevel",
      "TraceInst_AiSep",
      "TraceInst_AiTitle",
      "TraceInst_AiDec",
      "TraceInst_AiConf",
      "TraceInst_AiR1",
      "TraceInst_AiR2",
      "TraceInst_AiR3",
      "TraceInst_AiTrade",
      "TraceInst_AiMsg"
   };
   for (int dl = 0; dl < ArraySize(dashLabels); dl++)
   {
      if (ObjectFind(0, dashLabels[dl]) != -1) ObjectDelete(0, dashLabels[dl]);
   }
   
   string bgName = "TraceInst_Dash_BG"; 
   if(ObjectFind(0, bgName) == -1) 
   {
       ObjectCreate(0, bgName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
       ObjectSetInteger(0, bgName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
       ObjectSetInteger(0, bgName, OBJPROP_XDISTANCE, 10);
       ObjectSetInteger(0, bgName, OBJPROP_YDISTANCE, 10);
       ObjectSetInteger(0, bgName, OBJPROP_XSIZE, 410);
       ObjectSetInteger(0, bgName, OBJPROP_YSIZE, Use_RiskGuard ? 730 : 630); 
       ObjectSetInteger(0, bgName, OBJPROP_BGCOLOR, clrBlack); 
       ObjectSetInteger(0, bgName, OBJPROP_BORDER_TYPE, BORDER_FLAT); 
       ObjectSetInteger(0, bgName, OBJPROP_COLOR, Color_DashTitle); 
       ObjectSetInteger(0, bgName, OBJPROP_WIDTH, 2); 
       ObjectSetInteger(0, bgName, OBJPROP_BACK, false); 
       ObjectSetInteger(0, bgName, OBJPROP_ZORDER, 100);
   } 
   
   CreateLabel("Title", "Trace Institucional EA", x, y, Color_DashTitle, 12, true); 
   y += 25; 
   
   string timeStr = TimeToString(TimeCurrent() - 3600, TIME_DATE | TIME_MINUTES); 
   CreateLabel("Time", timeStr, x, y, Color_DashText, 8); 
   y += 20; 
   
   CreateLabel("Sep1", "-----------------------------", x, y, Color_DashTitle, 9, true);
   y += 18;
   
   // --- STATS ---
   int currentTF = Period(); 
   int bullCount = 0; 
   int bearCount = 0; 
   int slCount   = 0;
   int tpCount   = 0;
   
   // Count active zones on chart
   for(int i=0; i<totalBullZones; i++) 
   { 
      if(BullishZones[i].timeframe == currentTF) {
         bullCount++;
         if (BullishZones[i].slHit) slCount++;
         if (BullishZones[i].tpHit) tpCount++;
      }
   } 
   for(int i=0; i<totalBearZones; i++) 
   { 
      if(BearishZones[i].timeframe == currentTF) {
         bearCount++;
         if (BearishZones[i].slHit) slCount++;
         if (BearishZones[i].tpHit) tpCount++;
      }
   } 
     
   CreateLabel("TF", "Timeframe: " + TimeframeToString(currentTF), x, y, Color_DashTitle, 10, true); 
   y += 20; 
   
   CreateLabel("ZonesBull", "Bull Zones (Buy): " + IntegerToString(bullCount), x, y, clrDeepSkyBlue, 9); 
   y += 20; 
   
   CreateLabel("ZonesBear", "Bear Zones (Sell): " + IntegerToString(bearCount), x, y, clrRed, 9); 
   y += 20;

   CreateLabel("TPHits", "TP Hit: " + IntegerToString(tpCount), x, y, clrLime, 9);
   y += 20;
   
   CreateLabel("SLHits", "SL Hit: " + IntegerToString(slCount), x, y, clrRed, 9);
   y += 20;

   CreateLabel("Sep2", "-----------------------------", x, y, Color_DashTitle, 9, true);
   y += 18;

   int structureTF = GetHigherTimeframe(Period());
   int structureTrend = 0;
   double bosLevel = 0.0;
   double swingHigh = 0.0;
   double swingLow = 0.0;
   string strengthText = "Neutral";
   color strengthColor = clrSilver;
   double strengthATR = 0.0;
   int barsSinceBOS = -1;
   bool hasStruct = GetMarketStructureBOSLevels(structureTF, 1, structureTrend, bosLevel, swingHigh, swingLow);

   // (cache za AttemptDashboardSignalTrade - nezavisna trade funkcija)
   g_sigCachedStructTF  = structureTF;
   g_sigCachedTrend     = structureTrend;
   g_sigCachedBOSLevel  = bosLevel;
   g_sigCachedSwingH    = swingHigh;
   g_sigCachedSwingL    = swingLow;
   g_sigCachedHasStruct = hasStruct;

   // ---------- CONFIRM (M5) TF STRUKTURA - presmetka + cache ----------
   int confirmTF = GetConfirmTimeframe(Period());
   int confirmTrend = 0;
   double confirmBOS = 0.0;
   double confirmSwingH = 0.0;
   double confirmSwingL = 0.0;
   bool confirmHas = GetMarketStructureBOSLevels(confirmTF, 1, confirmTrend, confirmBOS, confirmSwingH, confirmSwingL);
   g_confirmCachedTF      = confirmTF;
   g_confirmCachedTrend   = confirmTrend;
   g_confirmCachedBOS     = confirmBOS;
   g_confirmCachedSwingH  = confirmSwingH;
   g_confirmCachedSwingL  = confirmSwingL;
   g_confirmCachedHas     = confirmHas;

   string structureText = (structureTrend == 1) ? "Bullish (BOS)" :
                          ((structureTrend == -1) ? "Bearish (BOS)" : "Neutral");     
   color structureColor = (structureTrend == 1) ? clrLime :
                          ((structureTrend == -1) ? clrRed : clrSilver);
   CreateLabel("MarketStructureTF", "Structure TF: " + TimeframeToString(structureTF), x, y, clrWhite, 8);
   y += 18;
   CreateLabel("MarketStructure", "Market Structure: " + structureText, x, y, structureColor, 9);
   y += 20;
   if (hasStruct)
   {
      string bosText = "-";
      string prevBosText = "";
      color bosColor = clrSilver;
      color prevBosColor = clrSilver;
      string bosDistText = "";
      color bosDistColor = clrSilver;
      double prevBosLevel = 0.0;
      bool hasPrevBos = GetPreviousBOSLevel(structureTF, 1, structureTrend, prevBosLevel);
      if (structureTrend == 1 && bosLevel > 0.0)
      {
         if (g_lastBOSHigh <= 0.0)
         {
            g_lastBOSHigh = bosLevel;
            if (g_prevBOSHigh <= 0.0 && hasPrevBos && prevBosLevel > 0.0) g_prevBOSHigh = prevBosLevel;
         }
         else if (MathAbs(bosLevel - g_lastBOSHigh) > (Point * 0.5))
         {
            g_prevBOSHigh = g_lastBOSHigh;
            g_lastBOSHigh = bosLevel;
         }
      }
      else if (structureTrend == -1 && bosLevel > 0.0)
      {
         if (g_lastBOSLow <= 0.0)
         {
            g_lastBOSLow = bosLevel;
            if (g_prevBOSLow <= 0.0 && hasPrevBos && prevBosLevel > 0.0) g_prevBOSLow = prevBosLevel;
         }
         else if (MathAbs(bosLevel - g_lastBOSLow) > (Point * 0.5))
         {
            g_prevBOSLow = g_lastBOSLow;
            g_lastBOSLow = bosLevel;
         }
      }
      SaveBOSMemory(structureTF);
      if (structureTrend == 1)
      {
         bosText = "BOS High: " + DoubleToString(bosLevel, Digits);
         bosColor = clrLime;
         if (hasPrevBos && prevBosLevel > 0.0)
         {
            prevBosText = "Prev BOS High: " + DoubleToString(prevBosLevel, Digits);
            prevBosColor = clrPaleGreen;
         }
      }
      else if (structureTrend == -1)
      {
         bosText = "BOS Low: " + DoubleToString(bosLevel, Digits);
         bosColor = clrRed;
         if (hasPrevBos && prevBosLevel > 0.0)
         {
            prevBosText = "Prev BOS Low: " + DoubleToString(prevBosLevel, Digits);
            prevBosColor = clrTomato;
         }
      }
      else
      {
         string hi = (swingHigh > 0.0) ? DoubleToString(swingHigh, Digits) : "-";
         string lo = (swingLow > 0.0) ? DoubleToString(swingLow, Digits) : "-";
         bosText = "Swing H/L: " + hi + " / " + lo;
      }
      CreateLabel("BOSLevel", bosText, x, y, bosColor, 8);
      y += 18;

      if (structureTrend == 1)
      {
         string prevBosHighText = "Prev BOS High: " + ((g_prevBOSHigh > 0.0) ? DoubleToString(g_prevBOSHigh, Digits) : "-");
         color  prevBosHighColor = (g_prevBOSHigh > 0.0) ? clrPaleGreen : clrSilver;
         CreateLabel("PrevBOS", prevBosHighText, x, y, prevBosHighColor, 8);
         y += 18;
      }
      else if (structureTrend == -1)
      {
         string prevBosLowText = "Prev BOS Low: " + ((g_prevBOSLow > 0.0) ? DoubleToString(g_prevBOSLow, Digits) : "-");
         color  prevBosLowColor = (g_prevBOSLow > 0.0) ? clrTomato : clrSilver;
         CreateLabel("PrevBOS", prevBosLowText, x, y, prevBosLowColor, 8);
         y += 18;
      }
      else
      {
         string ph = (g_prevBOSHigh > 0.0) ? DoubleToString(g_prevBOSHigh, Digits) : "-";
         string pl = (g_prevBOSLow  > 0.0) ? DoubleToString(g_prevBOSLow,  Digits) : "-";
         CreateLabel("PrevBOS", "Prev BOS H/L: " + ph + " / " + pl, x, y, clrSilver, 8);
         y += 18;
      }

      if (structureTrend != 0 && bosLevel > 0.0)
      {
         double currentPrice = Bid;
         if (currentPrice <= 0.0) currentPrice = iClose(Symbol(), Period(), 0);
         double bosDistance = (structureTrend == 1)
                              ? (currentPrice - bosLevel)
                              : (bosLevel - currentPrice);
         string sideText = (structureTrend == 1)
                           ? ((currentPrice >= bosLevel) ? "above" : "below")
                           : ((currentPrice <= bosLevel) ? "below" : "above");
         bosDistText = "Dist from BOS: " + DoubleToString(MathAbs(bosDistance), Digits) +
                       " (" + sideText + ")";
         bool falseBreakout = (bosDistance < 0.0);
         bosDistColor = falseBreakout ? clrOrangeRed : bosColor;
         CreateLabel("BOSDistance", bosDistText, x, y, bosDistColor, 8);
         y += 18;
         if (falseBreakout)
         {
            CreateLabel("BOSFalseBreak", "WARNING: False BOS (price back inside)", x, y, clrRed, 8);
            y += 18;
         }
      }

      if (GetMarketStructureStrength(structureTF, 1, strengthText, strengthColor, strengthATR, barsSinceBOS))
      {
         string strengthLine = "Structure Strength: " + strengthText;
         if (structureTrend != 0 && bosLevel > 0.0)
         {
            double currentPrice2 = Bid;
            if (currentPrice2 <= 0.0) currentPrice2 = iClose(Symbol(), Period(), 0);
            bool falseBrk = (structureTrend == 1 && currentPrice2 < bosLevel) ||
                            (structureTrend == -1 && currentPrice2 > bosLevel);
            if (falseBrk && StringFind(strengthText, "Strong") >= 0)
            {
               strengthText = "Weakening";
               strengthColor = clrOrange;
            }
            string bosAge = (barsSinceBOS >= 0) ? IntegerToString(barsSinceBOS) : "-";
            strengthLine = "Structure Strength: " + strengthText + " | " +
                            DoubleToString(strengthATR, 2) + " ATR | " + bosAge + " bars";
         }
         else if (structureTrend != 0)
         {
            string bosAge = (barsSinceBOS >= 0) ? IntegerToString(barsSinceBOS) : "-";
            strengthLine += " | " + DoubleToString(strengthATR, 2) + " ATR | " + bosAge + " bars";
         }
         CreateLabel("StructureStrength", strengthLine, x, y, strengthColor, 8);
         y += 18;
      }
      else
      {
         CreateLabel("StructureStrength", "", x, y, clrNONE, 8);
         y += 18;
      }
   }

   ObjectDelete(0, "PrevBOSLevel");
   ObjectDelete(0, "BOSRefLast");
   ObjectDelete(0, "BOSRefPrev");

   // ===== DASHBOARD SIGNAL CONFIDENCE SCORE (0-100) =====
   // --- STABILITY: recalc ONLY on STRUCTURE TF bar CLOSE, not every tick ---
   double signalScore = 0.0;
   string signalGrade = "D";
   color signalGradeColor = clrOrangeRed;
   string signalDirText = "NO SIGNAL";
   color signalDirColor = clrGray;
   string signalHTFText = "---";
   color signalHTFColor = clrGray;
   string signalSessionText = "---";
   color signalSessionColor = clrGray;
   string signalActionText = "---";
   color signalActionColor = clrSilver;
   bool signalBlocked = false;
   string bannerText = "";
   color bannerColor = clrGray;
   int stableBarsCount = g_sigStableBars;

   datetime lastClosedBarStructTF = iTime(Symbol(), structureTF, 1);
   bool needsRecompute = (g_sigCachedScore == -1 || g_sigCacheBarTime == 0 ||
                          lastClosedBarStructTF == 0 ||
                          lastClosedBarStructTF != g_sigCacheBarTime);

   if (needsRecompute)
   {
      string prevGradeForStable = g_sigCachedGrade;

      if (hasStruct && structureTrend != 0)
      {
         double sScore = 0.0;
         double sMax = 0.0;

         sMax += 15.0; sScore += 15.0;   // 1. BOS exists

         // 2. False BOS - CONFIRMED only if structure TF candle CLOSED back inside!
         sMax += 10.0;
         double closedStructCl = iClose(Symbol(), structureTF, 1);
         if (closedStructCl <= 0.0) closedStructCl = iClose(Symbol(), structureTF, 0);
         bool falseBrkClosed = (structureTrend == 1 && closedStructCl < bosLevel) ||
                               (structureTrend == -1 && closedStructCl > bosLevel);
         if (falseBrkClosed)
         {
            signalBlocked = true;
            bannerText = "!!! FALSE BOS CONFIRMED (CANDLE CLOSE) - DO NOT TRADE !!!";
            bannerColor = clrRed;
            sScore -= 40.0;
         }
         else { sScore += 10.0; }

         // 3. Structure Strength (max 25)
         sMax += 25.0;
         double rawStrScore = 0.0;
         if (strengthText == "Strong") rawStrScore = 25.0;
         else if (strengthText == "Healthy") rawStrScore = 18.0;
         else if (strengthText == "Weakening") rawStrScore = 10.0;
         else if (strengthText == "Fragile") rawStrScore = 3.0;
         sScore += rawStrScore;

         // 4. Higher TF Alignment (max 25)
         sMax += 25.0;
         int nextHTF = GetHigherTimeframe(structureTF);
         int nextHTFTrend = GetMarketTrendBOSOnly(nextHTF, 1);
         signalHTFText = "Next TF (" + TimeframeToString(nextHTF) + "): ";
         if (nextHTFTrend == 0) { signalHTFText += "Neutral"; signalHTFColor = clrSilver; sScore += 10.0; }
         else if (nextHTFTrend == structureTrend) {
            signalHTFText += (nextHTFTrend == 1) ? "Bullish (MATCH)" : "Bearish (MATCH)";
            signalHTFColor = (nextHTFTrend == 1) ? clrLime : clrRed;
            sScore += 25.0;
         } else {
            signalHTFText += (nextHTFTrend == 1) ? "Bullish (OPPOSED!)" : "Bearish (OPPOSED!)";
            signalHTFColor = clrOrangeRed;
            sScore -= 20.0;
         }

         // 5. Session Quality (max 15)
         sMax += 15.0;
         string sessStr2 = GetSessionString();
         string parts2[]; int pc2 = StringSplit(sessStr2, 124, parts2);
         string activeSess = (pc2 > 0) ? parts2[0] : "---";
         if (activeSess == "LONDON" || activeSess == "NEW YORK") {
            signalSessionText = "Session: " + activeSess + " (GOOD)"; signalSessionColor = clrLime; sScore += 15.0;
         } else if (activeSess == "ASIA") {
            signalSessionText = "Session: ASIA (WEAK - low liq.)"; signalSessionColor = clrOrange; sScore += 5.0;
         } else if (activeSess == "WEEKEND") {
            signalSessionText = "Session: WEEKEND (NO TRADE)"; signalSessionColor = clrRed; signalBlocked = true;
            if (bannerText == "") { bannerText = "!!! WEEKEND - MARKET CLOSED !!!"; bannerColor = clrRed; }
            sScore -= 40.0;
         } else {
            signalSessionText = "Session: MARKET QUIET (LOW LIQ.)"; signalSessionColor = clrOrange; sScore += 3.0;
         }

         // 6. Spread Check (max 10)
         sMax += 10.0;
         double spd = GetSpreadPoints();
         if (spd <= 0.0) spd = (Ask - Bid) / Point;
         if      (spd <= 20.0) { sScore += 10.0; }
         else if (spd <= 35.0) { sScore += 7.0; }
         else if (spd <= 50.0) { sScore += 3.0; }
         else                  { sScore -= 10.0; }

         // Normalize 0-100
         if (sMax <= 0.0) sMax = 100.0;
         signalScore = (sScore / sMax) * 100.0;
         if (signalScore < 0.0) signalScore = 0.0;
         if (signalScore > 100.0) signalScore = 100.0;

         // ==== FALSE BOS PENALTY ====
         // Ako BOS vekje bilo potvrdeno (Bull/Bear) no cena SE VRATILA nazad vo vnatresnostta
         // (price back inside), togas NE E validna nasoka -> namali score za 40.
         // Primer Grade S (90) -> 50 -> Grade C (ne e S/A/B) -> EARLY override NE aktivira,
         // DRY run NE vleguva, i panelot NE kaze SELL (vednas WAIT/Neutral).
         if (structureTrend != 0 && bosLevel > 0.0)
         {
            double brkBid = (Bid > 0) ? Bid : iClose(Symbol(), Period(), 0);
            double brkAsk = (Ask > 0) ? Ask : (brkBid + Point*10);
            double brkCur  = (structureTrend == 1) ? brkAsk : brkBid;
            double brkDist = (structureTrend == 1) ? (brkCur - bosLevel) : (bosLevel - brkCur);
            if (brkDist < 0.0)
            {
               signalScore -= 40.0;
               if (signalScore < 0.0) signalScore = 0.0;
            }
         }

         // Grade
         if      (signalScore >= 90.0) { signalGrade = "S"; signalGradeColor = clrGold; }
         else if (signalScore >= 75.0) { signalGrade = "A"; signalGradeColor = clrLime; }
         else if (signalScore >= 60.0) { signalGrade = "B"; signalGradeColor = clrLimeGreen; }
         else if (signalScore >= 45.0) { signalGrade = "C"; signalGradeColor = clrOrange; }
         else                          { signalGrade = "D"; signalGradeColor = clrOrangeRed; }

         // Direction
         if (structureTrend == 1) {
            signalDirText = "BUY (LONG)";
            signalDirColor = (signalScore >= 60.0) ? clrLime : (signalScore >= 45.0) ? clrYellow : clrOrangeRed;
         } else {
            signalDirText = "SELL (SHORT)";
            signalDirColor = (signalScore >= 60.0) ? clrRed : (signalScore >= 45.0) ? clrYellow : clrOrangeRed;
         }

         // Auto-block if <45
         if (signalScore < 45.0 && !signalBlocked) {
            signalBlocked = true;
            if (bannerText == "") {
               bannerText = "!!! SIGNAL BLOCKED: Score " + IntegerToString((int)signalScore) + "/100 - DO NOT TRADE !!!";
               bannerColor = clrOrangeRed;
            }
         }

         // RETEST recommendation
         double distanceToBOS = 0.0;
         double px = Bid; if (px <= 0.0) px = iClose(Symbol(), Period(), 0);
         double atr14 = iATR(Symbol(), structureTF, 14, 1);
         if (atr14 <= 0.0) atr14 = Point * 10.0;
         if (structureTrend == 1) {
            distanceToBOS = (px - bosLevel) / atr14;
            if (distanceToBOS > 1.5) {
               signalActionText = "[WAIT] RETEST BOS " + DoubleToString(bosLevel, Digits) + " (too far " + DoubleToString(distanceToBOS, 1) + " ATR)";
               signalActionColor = clrYellow;
            } else if (distanceToBOS > 0.5) {
               signalActionText = "[EXTENDED] Near BOS " + DoubleToString(bosLevel, Digits);
               signalActionColor = clrOrange;
            } else {
               signalActionText = "[READY] Price near BOS - entry on confirm";
               signalActionColor = clrLime;
            }
         } else {
            distanceToBOS = (bosLevel - px) / atr14;
            if (distanceToBOS > 1.5) {
               signalActionText = "[WAIT] RETEST BOS " + DoubleToString(bosLevel, Digits) + " (too far " + DoubleToString(distanceToBOS, 1) + " ATR)";
               signalActionColor = clrYellow;
            } else if (distanceToBOS > 0.5) {
               signalActionText = "[EXTENDED] Near BOS " + DoubleToString(bosLevel, Digits);
               signalActionColor = clrOrange;
            } else {
               signalActionText = "[READY] Price near BOS - entry on confirm";
               signalActionColor = clrLime;
            }
         }
      }
      else
      {
         // Neutral / no structure
         signalScore = 25.0; signalGrade = "D"; signalGradeColor = clrGray;
         signalDirText = "NEUTRAL / NO SIGNAL"; signalDirColor = clrSilver;
         signalHTFText = "Next TF: Neutral"; signalHTFColor = clrSilver;
         string sessStr3 = GetSessionString();
         string parts3[]; int pc3 = StringSplit(sessStr3, 124, parts3);
         string aSess = (pc3 > 0) ? parts3[0] : "---";
         if (aSess == "LONDON" || aSess == "NEW YORK") {
            signalSessionText = "Session: " + aSess + " (GOOD)"; signalSessionColor = clrLime;
         } else if (aSess == "ASIA") {
            signalSessionText = "Session: ASIA (WEAK - low liq.)"; signalSessionColor = clrOrange;
         } else if (aSess == "WEEKEND") {
            signalSessionText = "Session: WEEKEND (NO TRADE)"; signalSessionColor = clrRed;
         } else {
            signalSessionText = "Session: " + aSess; signalSessionColor = clrSilver;
         }
         signalActionText = "[WAIT] No confirmed structure yet"; signalActionColor = clrSilver;
         bannerText = "[MARKET NEUTRAL] Stand by for BOS confirmation"; bannerColor = clrSilver;
      }

      // Update cache + stable counter
      if (prevGradeForStable == signalGrade && g_sigCachedScore != -1) { g_sigStableBars++; }
      else { g_sigStableBars = 0; }
      stableBarsCount = g_sigStableBars;

      g_sigCacheBarTime   = lastClosedBarStructTF;
      g_sigCachedScore    = (int)signalScore;
      g_sigCachedGrade    = signalGrade;
      g_sigCachedGradeClr = signalGradeColor;
      g_sigCachedDirText  = signalDirText;
      g_sigCachedDirClr   = signalDirColor;
      g_sigCachedHTF      = signalHTFText;
      g_sigCachedHTFClr   = signalHTFColor;
      g_sigCachedSession  = signalSessionText;
      g_sigCachedSessClr  = signalSessionColor;
      g_sigCachedAction   = signalActionText;
      g_sigCachedActClr   = signalActionColor;
      g_sigCachedBanner   = bannerText;
      g_sigCachedBannerClr= bannerColor;
   }
   else
   {
      // BAR NOT CLOSED - use cached values (NO FLICKER!)
      signalScore         = g_sigCachedScore;
      signalGrade         = g_sigCachedGrade;
      signalGradeColor    = g_sigCachedGradeClr;
      signalDirText       = g_sigCachedDirText;
      signalDirColor      = g_sigCachedDirClr;
      signalHTFText       = g_sigCachedHTF;
      signalHTFColor      = g_sigCachedHTFClr;
      signalSessionText   = g_sigCachedSession;
      signalSessionColor  = g_sigCachedSessClr;
      signalActionText    = g_sigCachedAction;
      signalActionColor   = g_sigCachedActClr;
      bannerText          = g_sigCachedBanner;
      bannerColor         = g_sigCachedBannerClr;
      stableBarsCount     = g_sigStableBars;
   }

   // ============== KORAK 2: SYNC AI SCAN POSLE SITE g_sigCached* SE VTEMELENI =============
   // Nie sme sigurni deka g_sigCachedTrend ve4e e tocen (ili novo presmetan, ili vraten od cache)
   // Pa AI scan ke prati ISTOT trend shto shto EA go prikazuva na ekran (NE prethodniot cached!)
   if (AI_Enable) AIScanMarketNow();

   // ---------- RENDER: CONFIRM TF SEKCIJA ----------
   {
      int cTF = g_confirmCachedTF;
      int sTF = g_sigCachedStructTF;
      int cTr = g_confirmCachedTrend;
      int sTr = g_sigCachedTrend;
      string cTFname = TimeframeToString(cTF);
      string sTFname = TimeframeToString(sTF);
      string cTxt;
      color  cCol;
      string cMatch = "";
      if      (cTr == 1)  { cTxt = "Bullish (BOS)"; cCol = clrLime; }
      else if (cTr == -1) { cTxt = "Bearish (BOS)"; cCol = clrRed; }
      else                { cTxt = "Neutral";       cCol = clrSilver; }
      if (sTr == 0 && cTr == 0)       { cMatch = "  [both neutral - wait]"; cCol = clrSilver; }
      else if (cTr == 0)               { cMatch = "  [" + cTFname + " not confirmed - WAIT]"; cCol = clrYellow; }
      else if (sTr == 0)               { cMatch = "  [" + sTFname + " not formed - WAIT]";   cCol = clrYellow; }
      else if (sTr == cTr)             { cMatch = "   MATCH";  cCol = clrLime; }
      else                             { cMatch = "   MISMATCH - WAIT"; cCol = clrRed; }
      CreateLabel("ConfirmTF", "Confirm TF: " + cTFname, x, y, clrWhite, 8);
      y += 14;
      CreateLabel("ConfirmStruct", "Confirm " + cTFname + " Structure: " + cTxt + cMatch, x, y, cCol, 9);
      y += 18;
   }

   // ===== RENDER =====
   CreateLabel("SepSignal", "========= SIGNAL CONFIDENCE =========", x, y, Color_DashTitle, 9, true);
   y += 14;

   if (bannerText != "") {
      CreateLabel("SignalBanner", bannerText, x, y, bannerColor, 9, true);
      y += 16;
   }

   string stableSuffix = "";
   string stableTFname = TimeframeToString(g_sigCachedStructTF);
   if (stableBarsCount >= 1) {
      stableSuffix = "    [STABLE " + IntegerToString(stableBarsCount) + " bar" + (stableBarsCount == 1 ? "" : "s") + " " + stableTFname + "]";
   } else if (g_sigCachedScore != -1) {
      stableSuffix = "    [LOCKED - bar open " + stableTFname + "]";
   }
   CreateLabel("SignalScore", "SCORE: " + IntegerToString((int)signalScore) + "/100    GRADE: " + signalGrade + stableSuffix, x, y, signalGradeColor, 11, true);
   y += 18;

   CreateLabel("SignalGrade", "DIRECTION: " + signalDirText, x, y, signalDirColor, 10, true);
   y += 16;

   CreateLabel("SignalHTF", signalHTFText, x, y, signalHTFColor, 8);
   y += 13;

   CreateLabel("SignalSession", signalSessionText, x, y, signalSessionColor, 8);
   y += 13;

   CreateLabel("SignalAction", signalActionText, x, y, signalActionColor, 8);
   y += 16;

   // ===== NEW: AI FILTER & LAST DRY RUN (paper mode) =====
   if (Dash_EnableAIFilter || Dash_DryRunOnly || Dash_EnableSignalTrading)
   {
      string aiText = "";
      color  aiCol  = clrSilver;
      if (!Dash_EnableAIFilter)        { aiText = "AI Filter: OFF";                         aiCol = clrGray; }
      else if (g_sigCachedTrend == 0)  { aiText = "AI Filter: neutral market";                aiCol = clrSilver; }
      else if (g_dashAIReason == "")   { aiText = "AI Filter: checking...";                   aiCol = clrYellow; }
      else if (g_dashAIRslt)           { aiText = "AI:  " + g_dashAIReason;                 aiCol = clrLime; }
      else                             { aiText = "AI:  " + g_dashAIReason;                 aiCol = clrHotPink; }
      CreateLabel("SignalAI", aiText, x, y, aiCol, 8);
      y += 13;

      string drHeader = (Dash_DryRunOnly ? "[DRY RUN ] Last Signal: " :
                         Dash_EnableSignalTrading ? "[LIVE] Last Trade: " : "Dashboard Trade: OFF");
      color  drHeaderCol = (Dash_DryRunOnly ? clrDeepSkyBlue :
                            Dash_EnableSignalTrading ? clrRed : clrGray);
      CreateLabel("SignalDRHdr", drHeader, x, y, drHeaderCol, 8, true);
      y += 13;
      CreateLabel("SignalDRTxt", g_dashLastDryText, x, y, g_dashLastDryClr, 8);
      y += 16;

      if (Dash_DryRunOnly && g_dashDryCount > 0)
      {
         CreateLabel("SignalDRCount", "Dry signals generated: " + IntegerToString(g_dashDryCount), x, y, clrSilver, 8);
         y += 13;
      }
   }

   CreateLabel("Sep3", "-----------------------------", x, y, Color_DashTitle, 9, true);
   y += 10;
   
   string sessionStr = GetSessionString();
   string parts[];
   int pc = StringSplit(sessionStr, '|', parts);
   
   string activeSession = (pc > 0) ? parts[0] : "---";
   string nextSession   = (pc > 1) ? parts[1] : "---";
   
   CreateLabel("Session", "Session: " + activeSession, x, y, clrYellow, 10, true);
   y += 13;
   
   CreateLabel("NextSes", "Next: " + nextSession, x, y, clrWhite, 9);
   y += 11;
   
   string guardReason = "";
   bool guardOK = true;
   if (Use_RiskGuard) guardOK = RiskGuardAccountOK(guardReason);

   if (Dash_ShowStatusRiskBlock)
   {
   CreateLabel("Sep4", "-----------------------------", x, y, Color_DashTitle, 9, true);
   y += 10;
   
   string status = "Waiting...";
   color statusColor = clrGray;
   
   if (Enable_AutoTrade) {
      if (UseTimeFilter) {
         // Check if time is valid
         if (IsTradingAllowed()) {
            status = "AutoTrade: ON (Active)";
            statusColor = clrLime;
         } else {
            status = "AutoTrade: ON (Sleep)";
            statusColor = clrOrange;
         }
      } else {
         status = "AutoTrade: ON";
         statusColor = clrLime;
      }
   } else {
      status = "AutoTrade: OFF";
      statusColor = clrRed;
   }
   
   CreateLabel("Status", status, x, y, statusColor, 9);
   y += 11;

   if (Use_RiskGuard)
   {
   CreateLabel("Sep5", "-----------------------------", x, y, Color_DashTitle, 9, true);
   y += 12;

      double balance = AccountBalance();
      double dayPnL  = g_cachedDayPnL;
      double dayPct  = (balance > 0) ? (dayPnL / balance * 100.0) : 0.0;
      color  pnlCol  = (dayPnL >= 0) ? clrLime : clrRed;

      CreateLabel("RiskPnL", "Day P/L: " + DoubleToString(dayPnL, 2) +
                  " (" + DoubleToString(dayPct, 2) + "%)", x, y, pnlCol, 10);
      y += 15;

      CreateLabel("RiskTrades", "Trades today: " + IntegerToString(g_cachedTodayTrades) +
                  "  Open: " + IntegerToString(CountEAOpenTrades()), x, y, Color_DashText, 9);
      y += 14;

      CreateLabel("RiskSpread", "Spread: " + DoubleToString(GetSpreadPoints(), 1) + " pts", x, y,
                  (Risk_MaxSpreadPoints > 0 && GetSpreadPoints() > Risk_MaxSpreadPoints) ? clrRed : Color_DashText, 9);
      y += 14;

      CreateLabel("RiskGuard", guardOK ? "RiskGuard: OK" : ("RiskGuard: " + guardReason),
                  x, y, guardOK ? clrLime : clrOrangeRed, 9);
      y += 8;
   }
   }

   // ======================================================
   // REAL AI GPT (external server 127.0.0.1:3000) RENDER
   // ======================================================
   if (AI_ShowOnDashboard)
   {
      y += 6;
      CreateLabel("AiSep", "========= AI GPT ANALYSIS ==========", x, y, Color_DashTitle, 9, true);
      y += 16;

      if (!AI_Enable)
      {
         g_aiDecision = "WAIT";
         g_aiConfidence = 0.0;
         g_aiR1 = "";
         g_aiR2 = "";
         g_aiR3 = "";
         g_aiEntry = 0.0;
         g_aiSL = 0.0;
         g_aiTP = 0.0;
         g_aiLastMsg = "AI disabled via inputs (AI_Enable=false)";
         CreateLabel("AiTitle", "AI disabled (see inputs)", x, y, clrGray, 9);
         y += 14;
         CreateLabel("AiConf", "", x, y, clrNONE, 9);
         y += 15;
         CreateLabel("AiR1", "", x, y, clrNONE, 9);
         y += 15;
         CreateLabel("AiR2", "", x, y, clrNONE, 9);
         y += 15;
         CreateLabel("AiR3", "", x, y, clrNONE, 9);
         y += 15;
         CreateLabel("AiTrade", "", x, y, clrNONE, 9);
         y += 18;
         CreateLabel("AiMsg", "Turn ON AI_Enable in EA inputs + run StartTraceAI.bat", x, y, clrSilver, 9);
         y += 15;
         CreateLabel("AiDec", "", x, y, clrNONE, 9);
      }
      else
      {
         // ⭐ OFFLINE = serverot ne pishuva svezhi fajlovi (razlicno od "API greska"!)
         bool aiOffline  = !g_aiServerOnline;
         bool aiHasError = (StringFind(g_aiR1, "Greska") >= 0 || StringFind(g_aiR1, "greska") >= 0 ||
                            StringFind(g_aiR2, "Greska") >= 0 || StringFind(g_aiR2, "greska") >= 0 ||
                            StringFind(g_aiR3, "Greska") >= 0 || StringFind(g_aiR3, "greska") >= 0 ||
                            StringFind(g_aiLastMsg, "Error:") >= 0 || StringFind(g_aiLastMsg, "429") >= 0 ||
                            StringFind(g_aiLastMsg, "quota") >= 0 || StringFind(g_aiLastMsg, "kvota") >= 0);
         if (aiOffline) aiHasError = false;   // isklucen server ne e "OpenAI kvota"
         int sT = g_sigCachedTrend;
         int cT = g_confirmCachedTrend;
         string sTFname = TimeframeToString(g_sigCachedStructTF);
         string cTFname = TimeframeToString(g_confirmCachedTF);
         bool structNeutral  = (sT == 0);
         bool confirmNeutral = (cT == 0);
         bool structMismatch = (sT != 0 && cT != 0 && sT != cT);
         bool structMatch    = (sT != 0 && cT != 0 && sT == cT);
         bool forcedNeutral  = (structNeutral || confirmNeutral || structMismatch);
         string grade = g_sigCachedGrade;
         int  score100 = (int)g_sigCachedScore;
         if (sT != 0 && g_sigCachedBOSLevel > 0.0)
         {
            double brkCur = (sT == 1) ? Ask : Bid;
            if (brkCur <= 0.0) brkCur = (sT == 1) ? iClose(Symbol(), Period(), 0) + Point : iClose(Symbol(), Period(), 0);
            double brkDist = (sT == 1) ? (brkCur - g_sigCachedBOSLevel) : (g_sigCachedBOSLevel - brkCur);
            if (brkDist < 0.0)
            {
               score100 -= 40;
               if (score100 < 0) score100 = 0;
            }
         }
         string gradeLive = grade;
         if      (score100 >= 90) gradeLive = "S";
         else if (score100 >= 75) gradeLive = "A";
         else if (score100 >= 60) gradeLive = "B";
         else if (score100 >= 45) gradeLive = "C";
         else                     gradeLive = "D";
         grade = gradeLive;
         bool gradeSignal  = (grade == "S" || grade == "A" || grade == "B");
         int  eaScoreThreshold = (grade == "S" ? 30 : 55);
         bool eaNearBos = (StringFind(g_sigCachedAction, "[READY]") >= 0);
         string earlyBosWhy = "";
         bool eaBosConfirmed = DashPassBOSConfirmCheck(GetDashMinBOSConfirmBarsForTF(g_sigCachedStructTF), g_sigCachedStructTF,
                                                       sT, g_sigCachedBOSLevel, earlyBosWhy);
         bool eaReady  = (structMatch && gradeSignal && score100 >= eaScoreThreshold &&
                          eaNearBos && eaBosConfirmed);

         datetime nowT = TimeCurrent();
         if (nowT <= 0) nowT = TimeLocal();
         int scanAgeSec = (g_aiLastScanTime > 0) ? (int)(nowT - g_aiLastScanTime) : 9999;
         int staleSec = (grade == "S" ? 10 : 25);
         bool gptIsStale = (scanAgeSec > staleSec || g_aiLastScanTime == 0);
         bool gptIsWaitOrContrary = (g_aiDecision == "WAIT" ||
                                     (sT == 1 && g_aiDecision == "SELL") ||
                                     (sT == -1 && g_aiDecision == "BUY"));
         // === FIX 2+3: EARLY AI OVERRIDE ===
         bool eaEarlyOverride = (eaReady && (gptIsStale || gptIsWaitOrContrary));

         string fwdDecision = g_aiDecision;
         double fwdConfidence = g_aiConfidence;
         string fwdR1 = g_aiR1;
         string fwdR2 = g_aiR2;
         string fwdR3 = g_aiR3;
         double fwdEntry = g_aiEntry;
         double fwdSL    = g_aiSL;
         double fwdTP    = g_aiTP;
         if (eaEarlyOverride && !forcedNeutral)
         {
            string dirWord = (sT == 1 ? "BUY" : "SELL");
            color  colTag  = (sT == 1 ? clrLime : clrRed);
            fwdDecision   = dirWord;
            fwdConfidence = MathMax((double)score100 / 100.0, 0.70);
            int digits2 = Digits; if (digits2 == 0) digits2 = 2;
            double atrV = iATR(Symbol(), GetHigherTimeframe(Period()), 14, 1);
            if (atrV <= 0) atrV = Point * 50;
            double pBid = (Bid > 0) ? Bid : iClose(Symbol(), Period(), 0);
            double pAsk = (Ask > 0) ? Ask : pBid + (Point*10);
            double entry = (sT == 1) ? pAsk : pBid;
            double sl    = (sT == 1) ? (entry - atrV * 1.2) : (entry + atrV * 1.2);
            double tp    = (sT == 1) ? (entry + atrV * 2.4) : (entry - atrV * 2.4);
            fwdEntry = entry;
            fwdSL    = sl;
            fwdTP    = tp;
            string bosTxt = (sT == 1) ?
                            ("BOS High: " + DoubleToString(g_sigCachedBOSLevel, digits2)) :
                            ("BOS Low : " + DoubleToString(g_sigCachedBOSLevel, digits2));
            string stableTxt = (g_sigStableBars > 0) ? (" [STABLE " + IntegerToString(g_sigStableBars) + "b " + sTFname + "]" ) : "";
            if (gptIsStale && g_aiDecision == "WAIT" && scanAgeSec > 25)
            {
               fwdR1 = "[EARLY EA SIGNAL] Grade " + grade + " " + dirWord + "  Score " + IntegerToString(score100) + "/100" + stableTxt;
               fwdR2 = "GPT result STALE (" + IntegerToString(scanAgeSec) + "s old) - EA detektiral signal, ne chekame";
            }
            else if (gptIsWaitOrContrary)
            {
               fwdR1 = "[EARLY EA SIGNAL] Grade " + grade + " " + dirWord + "  Score " + IntegerToString(score100) + "/100" + stableTxt;
               fwdR2 = "GPT dade WAIT/kontra; EA ima potvrden MATCH signal (" + bosTxt + ")";
            }
            else
            {
               fwdR1 = "[EA SIGNAL] Grade " + grade + " " + dirWord + "  Score " + IntegerToString(score100) + "/100" + stableTxt;
               fwdR2 = bosTxt;
            }
            fwdR3 = "Risk 1:2 RR | SL=" + DoubleToString(sl,digits2) + "  TP=" + DoubleToString(tp,digits2) + "  ATR=" + DoubleToString(atrV,digits2);
         }
         if (forcedNeutral)
         {
            fwdDecision   = "WAIT";
            fwdConfidence = 0.0;
            fwdEntry = 0.0; fwdSL = 0.0; fwdTP = 0.0;
            if (structMismatch)
            {
               string sDir = (sT == 1 ? "Bull" : "Bear");
               string cDir = (cT == 1 ? "Bull" : "Bear");
               fwdR1 = "[EA OVERRIDE] STRUCTURE MISMATCH " + sTFname + " vs " + cTFname;
               fwdR2 = sTFname + " = " + sDir + "   " + cTFname + " = " + cDir + "  (ne se soglasuvaat)";
               fwdR3 = "AI SUSPENDED - cheekaj site TF da potvrdat ista nasoka";
            }
            else if (structNeutral && confirmNeutral)
            {
               fwdR1 = "[EA OVERRIDE] Market Structure = NEUTRAL (" + sTFname + " + " + cTFname + ")";
               fwdR2 = "Nitu " + sTFname + " nitu " + cTFname + " nemaa potvrden BOS (Bull/Bear)";
               fwdR3 = "AI advice SUSPENDED - cheekaj BOS na bilo koja TF";
            }
            else if (structNeutral)
            {
               fwdR1 = "[EA OVERRIDE] " + sTFname + " Structure = NEUTRAL";
               fwdR2 = "Confirm " + cTFname + " dae signal, no " + sTFname + " nema BOS";
               fwdR3 = "AI SUSPENDED - " + sTFname + " go odreduva pravce, cheekaj go";
            }
            else // confirmNeutral
            {
               fwdR1 = "[EA OVERRIDE] " + cTFname + " Confirmation = NEUTRAL";
               fwdR2 = sTFname + " Structure postoi, no " + cTFname + " uste ne go potvrdil isto BOS";
               fwdR3 = "AI SUSPENDED - cheekaj potvrda od " + cTFname + " (no false breakout)";
            }
         }
         // ═══ SERVER ISKLUCEN: nema svezha GPT analiza -> nishto staro ne se prikazuva ═══
         bool aiBlank = (aiOffline && !eaEarlyOverride);
         if (aiBlank)
         {
            fwdDecision   = "WAIT";
            fwdConfidence = 0.0;
            fwdEntry = 0.0; fwdSL = 0.0; fwdTP = 0.0;
            string ageTxt = (g_aiRsAgeSec >= 0) ? (IntegerToString(g_aiRsAgeSec) + "s") : "nema";
            fwdR1 = "[AI OFFLINE] Node serverot ne pishuva heartbeat.txt (limit " + IntegerToString(AIOfflineLimitSec()) + "s)";
            fwdR2 = "Posledna GPT analiza: pred " + ageTxt + ".  Startni StartTraceAI.bat.";
            fwdR3 = "EA strukturata, zonite i signalite prodolzuvaat da rabotat normalno.";
         }

         // ═══════════════════════════════════════════════════════════════════
         //  TVRDA PORTA: BUY/SELL izleguva SAMO ako site uslovi pominale.
         //  Ova ne e molba vo promptot - ova e proverka vo kod, GPT ne moze
         //  da ja zaobikoli. Ako portata padne -> WAIT, so tocna prichina.
         // ═══════════════════════════════════════════════════════════════════
         bool gateBlocked = false;
         bool gateArmed   = (AI_HardGate && g_gatePass && !aiBlank);
         if (AI_HardGate && !aiBlank && (fwdDecision == "BUY" || fwdDecision == "SELL"))
         {
            int wantDir = (fwdDecision == "BUY") ? 1 : -1;
            if (!g_gatePass || g_gateDir != wantDir)
            {
               gateBlocked   = true;
               fwdDecision   = "WAIT";
               fwdConfidence = 0.0;
               fwdEntry = 0.0; fwdSL = 0.0; fwdTP = 0.0;
               fwdR1 = "[GATE BLOCK] " + (StringLen(g_gateFail) > 0 ? g_gateFail : "MTF ne e poredjan");
               fwdR2 = "Pominati " + IntegerToString(g_gatePassed) + "/" + IntegerToString(g_gateTotal) +
                       " uslovi - ova NE e TOJ signalot shto go chekame.";
               fwdR3 = "Treba: H4+H1+M15 ista nasoka, ADX>" + DoubleToString(AI_GateMinADX,0) +
                       ", Score>" + IntegerToString(AI_GateMinScore) + ", sesija, spread OK.";
            }
         }
         if (gateArmed && (fwdDecision == "BUY" || fwdDecision == "SELL"))
         {
            string sigKey = TimeframeToString(g_sigCachedStructTF) + "|" + fwdDecision + "|" +
                            DoubleToString(g_sigCachedBOSLevel, Digits) + "|" +
                            IntegerToString((int)g_mtfStamp);
            AILogSignalCSV(sigKey, fwdDecision, fwdConfidence, fwdEntry, fwdSL, fwdTP);
         }

         string decTxt = "UNKNOWN";
         color  decCol = clrSilver;
         if      (aiBlank)                        { decTxt = "AI OFFLINE"; decCol = clrGray; }
         else if (forcedNeutral)                  { decTxt = "WAIT";  decCol = clrDeepSkyBlue; }
         else if (aiHasError)                     { decTxt = "API ERROR"; decCol = clrRed; }
         else if (fwdDecision == "BUY")           { decTxt = (gateArmed ? "BUY  * ARMED *"  : "BUY");  decCol = clrLime; }
         else if (fwdDecision == "SELL")          { decTxt = (gateArmed ? "SELL * ARMED *" : "SELL"); decCol = clrRed; }
         else if (gateBlocked)                    { decTxt = "WAIT (gate block)"; decCol = clrDarkOrange; }
         else if (fwdDecision == "WAIT")          { decTxt = "WAIT"; decCol = clrDeepSkyBlue; }

         string confTxt;
         color  confCol;
         if (aiBlank) {
            confTxt = "GPT: nema vrska so serverot";
            confCol = clrGray;
         } else if (forcedNeutral) {
            confTxt = "EA: Neutral market - wait for structure";
            confCol = clrDeepSkyBlue;
         } else if (aiHasError) {
            confTxt = "OpenAI kvota iscepen!";
            confCol = clrRed;
         } else {
            confTxt = "Conf: " + IntegerToString((int)(fwdConfidence * 100.0)) + "%";
            confCol = (fwdConfidence >= 0.75) ? clrLime : (fwdConfidence >= 0.55 ? clrYellow : clrSilver);
         }

         string titleLine = (aiBlank || forcedNeutral || aiHasError) ?
                            ("AI: " + decTxt + "  " + confTxt) :
                            ("Decision: " + decTxt + "   " + confTxt);
         color  titleCol  = decCol;
         CreateLabel("AiTitle", titleLine, x, y, titleCol, 9, true);
         y += 18;

         // ══════════════════════════════════════════════════════════════════
         //  SERVER STATUS - baziran na REALNA svezhina na fajlovite
         //  (g_aiHbAgeSec / g_aiRsAgeSec se veke presmetani vo ista vremenska
         //   zona kako izvorot, pa ovde nema offset greski)
         // ══════════════════════════════════════════════════════════════════
         datetime nowHB = TimeCurrent(); if (nowHB <= 0) nowHB = TimeLocal();
         int hbAge = g_aiHbAgeSec;
         int rsAge = g_aiRsAgeSec;
         int scAge = (g_aiLastScanTime   > 0) ? (int)(nowHB - g_aiLastScanTime)   : -1;
         int hlAge = (g_aiLastHealthTime > 0) ? (int)(nowHB - g_aiLastHealthTime) : -1;

         string hbA = (hbAge < 0) ? "no-data" : (IntegerToString(hbAge) + "s");
         string rsA = (rsAge < 0) ? "no-data" : (IntegerToString(rsAge) + "s");
         string scA = (scAge < 0) ? "no-data" : (IntegerToString(scAge) + "s");

         int  lim       = AIOfflineLimitSec();
         bool hbFreshD  = (hbAge >= 0 && hbAge <= lim);
         bool rsFreshD  = (rsAge >= 0 && rsAge <= lim);
         bool httpAlive = g_aiLastScanOK && (g_aiLastHealthTime > 0) && (hlAge >= 0) && (hlAge < 60);

         string srvStatus;
         color  col;
         if (hbFreshD || rsFreshD)
         {
            srvStatus = "ONLINE  [HB " + hbA + " | RESULT " + rsA + "]";
            col = clrLimeGreen;
         }
         else if (httpAlive)
         {
            srvStatus = "LIVE STALLED  [HTTP ok, no HB=" + hbA + " RS=" + rsA + "] - node ziv ama ne pishuva fajlovi";
            col = clrGold;
         }
         else if (hbAge < 0 && rsAge < 0)
         {
            srvStatus = "OFFLINE  [nema heartbeat.txt / result.json] - startni StartTraceAI.bat";
            col = clrDarkOrange;
         }
         else
         {
            srvStatus = "OFFLINE  [HB=" + hbA + " RS=" + rsA + " SC=" + scA + "] - serverot e ISKLUCEN";
            col = clrDarkOrange;
         }
         CreateLabel("AiConf", "Server: " + srvStatus, x, y, col, 9);
         y += 15;

         // ══════════ SETUP / TVRDA PORTA linija ══════════
         if (AI_HardGate)
         {
            string gLine;
            color  gCol;
            if (g_gatePass)
            {
               gLine = "Setup: ARMED " + (g_gateDir == 1 ? "BUY" : "SELL") +
                       "  [" + IntegerToString(g_gatePassed) + "/" + IntegerToString(g_gateTotal) + "]  " + g_gateWhy;
               gCol  = (g_gateDir == 1) ? clrLime : clrRed;
            }
            else
            {
               gLine = "Setup: NO  [" + IntegerToString(g_gatePassed) + "/" + IntegerToString(g_gateTotal) + "]  " +
                       (StringLen(g_gateFail) > 0 ? g_gateFail : "chekam scan...");
               gCol  = clrSilver;
            }
            CreateLabel("AiGate", gLine, x, y, gCol, 9);
            y += 15;

            string mtfLine = "MTF: ";
            int iD1 = AIMtfIdx("D1"), iH4b = AIMtfIdx("H4"), iH1b = AIMtfIdx("H1");
            int iM15b = AIMtfIdx("M15"), iM5b = AIMtfIdx("M5"), iM1b = AIMtfIdx("M1");
            mtfLine = mtfLine + "D1-"  + (iD1   >= 0 ? AIMtfBiasShort(g_mtfBias[iD1])   : AIMtfBiasShort(AIMtfStructureBias(PERIOD_D1, 1))) + "  ";
            mtfLine = mtfLine + "H4-"  + (iH4b  >= 0 ? AIMtfBiasShort(g_mtfBias[iH4b])  : AIMtfBiasShort(AIMtfStructureBias(PERIOD_H4, 1))) + "  ";
            mtfLine = mtfLine + "H1-"  + (iH1b  >= 0 ? AIMtfBiasShort(g_mtfBias[iH1b])  : AIMtfBiasShort(AIMtfStructureBias(PERIOD_H1, 1))) + "  ";
            mtfLine = mtfLine + "M15-" + (iM15b >= 0 ? AIMtfBiasShort(g_mtfBias[iM15b]) : AIMtfBiasShort(AIMtfStructureBias(PERIOD_M15, 1))) + "  ";
            mtfLine = mtfLine + "M5-"  + (iM5b  >= 0 ? AIMtfBiasShort(g_mtfBias[iM5b])  : AIMtfBiasShort(AIMtfStructureBias(PERIOD_M5, 1))) + "  ";
            mtfLine = mtfLine + "M1-"  + (iM1b  >= 0 ? AIMtfBiasShort(g_mtfBias[iM1b])  : AIMtfBiasShort(AIMtfStructureBias(PERIOD_M1, 1)));
            if (AI_VisionEyes)
               mtfLine = mtfLine + "   | Eyes " + IntegerToString(g_visCount) + " charts" +
                         (g_visShotTime > 0 ? " (shot " + IntegerToString((int)(TimeCurrent() - g_visShotTime)) + "s)" : "");
            CreateLabel("AiMtf", mtfLine, x, y, clrSilver, 8);
            y += 14;
         }

         // ============== KORAK 3: PRICE FRESHENER - zameni zastarena "price XXXX.XX" vo GPT tekst so LIVE ==============
         if (!forcedNeutral && !aiHasError && !aiBlank)
         {
            int dd2 = Digits; if (dd2 == 0) dd2 = 2;
            double pBid = (Bid > 0.0) ? Bid : iClose(Symbol(), Period(), 0);
            double staleThr;
            if (dd2 == 5 || dd2 == 3) staleThr = 0.0050;   // FX: 50 pts (pip) ≈ 0.0050
            else                     staleThr = 5.0;      // XAU: $5 diff = STALE
            string priceTag = "price ";
            int ptLen = StringLen(priceTag);

            // ------------ R1 ------------
            int pp1 = StringFind(fwdR1, priceTag, 0);
            if (pp1 >= 0)
            {
               int ns = pp1 + ptLen;
               int ne = ns;
               while (ne < StringLen(fwdR1))
               {
                  ushort ch = StringGetCharacter(fwdR1, ne);
                  bool valid = ((ch >= '0' && ch <= '9') || ch == '.' || ch == ',');
                  if (!valid) break;
                  ne++;
               }
               if (ne > ns)
               {
                  string numStr = StringSubstr(fwdR1, ns, ne - ns);
                  double staleP = StringToDouble(numStr);
                  if (staleP > 0.0)
                  {
                     fwdR1 = StringSubstr(fwdR1, 0, ns) + DoubleToString(pBid, dd2) + StringSubstr(fwdR1, ne);
                     double d = MathAbs(pBid - staleP);
                     if (d > staleThr)
                        fwdR1 = fwdR1 + "  [STALE SCAN, diff $" + DoubleToString(d, 2) + "]";
                  }
               }
            }
            // ------------ R2 ------------
            int pp2 = StringFind(fwdR2, priceTag, 0);
            if (pp2 >= 0)
            {
               int ns = pp2 + ptLen;
               int ne = ns;
               while (ne < StringLen(fwdR2))
               {
                  ushort ch = StringGetCharacter(fwdR2, ne);
                  bool valid = ((ch >= '0' && ch <= '9') || ch == '.' || ch == ',');
                  if (!valid) break;
                  ne++;
               }
               if (ne > ns)
               {
                  string numStr = StringSubstr(fwdR2, ns, ne - ns);
                  double staleP = StringToDouble(numStr);
                  if (staleP > 0.0)
                  {
                     fwdR2 = StringSubstr(fwdR2, 0, ns) + DoubleToString(pBid, dd2) + StringSubstr(fwdR2, ne);
                     double d = MathAbs(pBid - staleP);
                     if (d > staleThr)
                        fwdR2 = fwdR2 + "  [STALE SCAN, diff $" + DoubleToString(d, 2) + "]";
                  }
               }
            }
            // ------------ R3 ------------
            int pp3 = StringFind(fwdR3, priceTag, 0);
            if (pp3 >= 0)
            {
               int ns = pp3 + ptLen;
               int ne = ns;
               while (ne < StringLen(fwdR3))
               {
                  ushort ch = StringGetCharacter(fwdR3, ne);
                  bool valid = ((ch >= '0' && ch <= '9') || ch == '.' || ch == ',');
                  if (!valid) break;
                  ne++;
               }
               if (ne > ns)
               {
                  string numStr = StringSubstr(fwdR3, ns, ne - ns);
                  double staleP = StringToDouble(numStr);
                  if (staleP > 0.0)
                  {
                     fwdR3 = StringSubstr(fwdR3, 0, ns) + DoubleToString(pBid, dd2) + StringSubstr(fwdR3, ne);
                     double d = MathAbs(pBid - staleP);
                     if (d > staleThr)
                        fwdR3 = fwdR3 + "  [STALE SCAN, diff $" + DoubleToString(d, 2) + "]";
                  }
               }
            }
            // Dopolnitelno: proveri go i Entry/SL/TP vo AiTrade preku g_aiEntry (ako e zastareno)
            // (Live Bid se dodava vo AiTrade direktno podolu)
         }

         string r1 = (StringLen(fwdR1) > 0) ? ("• " + fwdR1) : " ";
         string r2 = (StringLen(fwdR2) > 0) ? ("• " + fwdR2) : " ";
         string r3 = (StringLen(fwdR3) > 0) ? ("• " + fwdR3) : " ";
         CreateLabel("AiR1", r1, x, y, (forcedNeutral ? clrDeepSkyBlue : (aiHasError ? clrTomato : Color_DashText)), 9);
         y += 15;
         CreateLabel("AiR2", r2, x, y, (forcedNeutral ? clrDeepSkyBlue : (aiHasError ? clrOrangeRed : Color_DashText)), 9);
         y += 15;
         CreateLabel("AiR3", r3, x, y, (forcedNeutral ? clrDeepSkyBlue : (aiHasError ? clrOrange : Color_DashText)), 9);
         y += 15;

         int digits = Digits; if (digits == 0) digits = 2;
         {
            color tradeCol;
            string tradeLine;
            double liveBid = (Bid > 0.0) ? Bid : iClose(Symbol(), Period(), 0);
            double liveAsk = (Ask > 0.0) ? Ask : liveBid + (Ask - Bid > 0 ? (Ask - Bid) : Point*10);
            string priceLine = "LIVE Bid=" + DoubleToString(liveBid,digits) + "  Ask=" + DoubleToString(liveAsk,digits);
            if (aiBlank) {
               tradeCol = clrGray;
               tradeLine = priceLine + "  |  AI OFFLINE - nema svezha GPT analiza";
            } else if (forcedNeutral) {
               tradeCol = clrDeepSkyBlue;
               tradeLine = priceLine + "  |  WAIT (Neutral structure)";
            } else if (aiHasError) {
               tradeCol = clrRed;
               tradeLine = "API FAIL: dodadi kredit na OpenAI billing";
            } else if (fwdDecision == "WAIT") {
               tradeCol = clrSilver;
               tradeLine = priceLine + "  |  Suggested: wait for setup";
            } else {
               tradeCol = (fwdDecision == "BUY" ? clrLime : clrRed);
               tradeLine = (priceLine + " | " +
                            "Entry " + DoubleToString(fwdEntry,digits) +
                            "  SL " + DoubleToString(fwdSL,digits) +
                            "  TP " + DoubleToString(fwdTP,digits));
            }
            CreateLabel("AiTrade", tradeLine, x, y, tradeCol, 9, true);
            y += 18;
         }

         if (StringLen(g_aiLastMsg) > 2)
         {
            string s;
            color sCol = clrSilver;
            if (aiBlank) {
               s = "AI server ISKLUCEN - pokreni StartTraceAI.bat (heartbeat " + hbA + ")";
               sCol = clrDarkOrange;
            } else if (eaEarlyOverride && !forcedNeutral) {
               string dir2 = (sT == 1 ? "BUY" : "SELL");
               s = "EARLY EA ACTIVE | Grade " + grade + " " + dir2 +
                   " Score " + IntegerToString(score100) + "/100 | GPT result pending...";
               sCol = (sT == 1 ? clrLime : clrRed);
            } else if (!aiHasError && StringLen(g_aiDecision) > 0 && g_aiDecision != "WAIT") {
               s = "OK - scanned at " + TimeToString(g_aiLastScanTime, TIME_DATE|TIME_MINUTES);
               sCol = clrSilver;
            } else {
               s = g_aiLastMsg;
               if (StringLen(s) > 58) s = StringSubstr(s, 0, 58) + "...";
            }
            CreateLabel("AiMsg", "Status: " + s, x, y, sCol, 9);
            y += 15;
         }

         if (AI_OnlyAdviceNoAutoTrade)
         {
            CreateLabel("AiDec", "Mode: ADVICE ONLY (no auto orders)", x, y, clrKhaki, 9);
         }
         else
         {
            CreateLabel("AiDec", "Mode: AUTO-TRADE enabled", x, y, clrOrangeRed, 9);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| BACKUP / RESTORE FUNCTIONS                                       |
//+------------------------------------------------------------------+
void SaveAllZonesToBackup()
{
   if (IsTesting())
   {
      if (DebugMode) Print("Backup save skipped in Strategy Tester");
      return;
   }
   int currentTF = Period();
   string filename = StringFormat("TraceInst_%s_%s_Backup.csv", Symbol(), TimeframeToString(currentTF));
   int handle = FileOpen(filename, FILE_WRITE|FILE_CSV|FILE_ANSI);
   if (handle == INVALID_HANDLE) 
   {
      Print("Backup Error: Could not open file for writing: ", filename);
      return;
   }
   
   for (int i = 0; i < totalBullZones; i++)
   {
      ZoneInfo z = BullishZones[i];
      if (z.timeframe != currentTF) continue;
      // Added explicit newline behavior with FileWrite
      FileWrite(handle, "BULL", z.timeframe, z.top, z.bottom, (long)z.startTime, z.breakoutBar,
                z.stopLoss, z.takeProfit, z.strength, (long)z.breakoutTime,
                z.bosConfirmed ? 1 : 0, z.bosStrength, z.isTraded ? 1 : 0);
   }
   for (int j = 0; j < totalBearZones; j++)
   {
      ZoneInfo z = BearishZones[j];
      if (z.timeframe != currentTF) continue;
      FileWrite(handle, "BEAR", z.timeframe, z.top, z.bottom, (long)z.startTime, z.breakoutBar,
                z.stopLoss, z.takeProfit, z.strength, (long)z.breakoutTime,
                z.bosConfirmed ? 1 : 0, z.bosStrength, z.isTraded ? 1 : 0);
   }
   
   FileClose(handle);
   if (DebugMode)
   {
      int savedCount = 0;
      for (int bi = 0; bi < totalBullZones; bi++) if (BullishZones[bi].timeframe == currentTF) savedCount++;
      for (int si = 0; si < totalBearZones; si++) if (BearishZones[si].timeframe == currentTF) savedCount++;
      Print("Backup Saved to ", filename, ": ", savedCount, " zones.");
   }
}

void RestoreAllZonesFromBackup()
{
   if (IsTesting())
   {
      if (DebugMode) Print("Backup restore skipped in Strategy Tester");
      return;
   }
   int currentTF = Period();
   string filename = StringFormat("TraceInst_%s_%s_Backup.csv", Symbol(), TimeframeToString(currentTF));
   if (!FileIsExist(filename))
   {
      string legacyFilename = StringFormat("TraceInst_%s_Backup.csv", Symbol());
      if (!FileIsExist(legacyFilename))
      {
         if (DebugMode) Print("Restore: No backup file found: ", filename);
         return;
      }
      filename = legacyFilename;
   }

   int handle = FileOpen(filename, FILE_READ|FILE_CSV|FILE_ANSI);
   if (handle == INVALID_HANDLE) 
   {
      Print("Restore Error: Could not open file: ", filename);
      return;
   }

   int count = 0;
   while (!FileIsEnding(handle))
   {
      string type = FileReadString(handle);
      if (type == "" || type == NULL) continue;
      
      if (type != "BULL" && type != "BEAR")
      {
          // Skip if we got some unexpected data (like a stray comma or newline)
          continue;
      }

      ZoneInfo z;
      z.timeframe   = (int)FileReadNumber(handle);
      if (z.timeframe != currentTF)
      {
         // Consume the rest of this CSV line but do not import other timeframe zones
         while (!FileIsLineEnding(handle) && !FileIsEnding(handle))
            FileReadString(handle);
         continue;
      }
      z.top         = FileReadNumber(handle);
      z.bottom      = FileReadNumber(handle);
      z.startTime   = (datetime)FileReadNumber(handle);
      int storedBreakoutBar = (int)FileReadNumber(handle);
      z.stopLoss    = FileReadNumber(handle);
      z.takeProfit  = FileReadNumber(handle);
      z.strength    = FileReadNumber(handle);
      z.breakoutTime = 0;
      z.bosConfirmed = false;
      z.bosStrength = 0.0;
      if (!FileIsLineEnding(handle))
         z.breakoutTime = (datetime)FileReadNumber(handle);
      if (!FileIsLineEnding(handle))
         z.bosConfirmed = ((int)FileReadNumber(handle) == 1);
      if (!FileIsLineEnding(handle))
         z.bosStrength = FileReadNumber(handle);
      z.isTraded = false;
      if (!FileIsLineEnding(handle))
         z.isTraded = ((int)FileReadNumber(handle) == 1);
      z.breakoutBar = (z.breakoutTime > 0)
                      ? iBarShift(Symbol(), z.timeframe, z.breakoutTime, true)
                      : iBarShift(Symbol(), z.timeframe, z.startTime);
      if (z.breakoutBar < 0) z.breakoutBar = storedBreakoutBar;
      
      z.isElite     = (z.strength >= 8.0);
      z.entryPrice  = (type == "BULL") ? z.top : z.bottom;
      z.zoneType    = (type == "BULL") ? "Bull" : "Bear";
      
      // Safety check: if timeframe or prices are 0, skip this record
      if (z.timeframe == 0 || z.top == 0 || z.bottom == 0) 
      {
          if (DebugMode) Print("Restore: Skipping invalid record for ", type);
          continue;
      }

      z.baseStartBar = (z.breakoutBar != -1) ? z.breakoutBar + 1 : 0; 
      z.baseEndBar   = (z.breakoutBar != -1) ? z.breakoutBar + 1 : 0;   
      
      if (g_zoneIdCounter > 2000000000) g_zoneIdCounter = 1;
      z.uniqueID = g_zoneIdCounter++;
      
      // Initialize Visual Names with correct prefix
      z.slName     = "TraceInst_SL_" + IntegerToString(z.uniqueID);
      z.tpName     = "TraceInst_TP_" + IntegerToString(z.uniqueID);
      z.slTextName = "TraceInst_SL_Txt_" + IntegerToString(z.uniqueID);
      z.tpTextName = "TraceInst_TP_Txt_" + IntegerToString(z.uniqueID);
      
      z.fingerprint = (type == "BULL")
                      ? StringFormat("%d_%.5f_%.5f_%s", z.timeframe, z.bottom, z.top,
                                     TimeToString(z.startTime))
                      : StringFormat("%d_%.5f_%.5f_%s", z.timeframe, z.top, z.bottom,
                                     TimeToString(z.startTime));
      RememberSeenZoneFingerprint(z.fingerprint);
      z.slHit = false;
      z.tpHit = false;
      z.breaker = false;
      z.touches = 0;
      z.relativeVolume = 0;
      if (z.isTraded)
         RememberTradedZoneFingerprint(z.fingerprint);
      
      if (type == "BULL")
      {
         bool exists = false;
         for(int k=0; k<totalBullZones; k++) {
             if(BullishZones[k].timeframe == z.timeframe)
             {
                 if(MathAbs(BullishZones[k].top - z.top) < Point && 
                    MathAbs(BullishZones[k].bottom - z.bottom) < Point) { exists = true; break; }
                 if(MathAbs(BullishZones[k].startTime - z.startTime) <= PeriodSeconds(z.timeframe) * 5) { exists = true; break; }
             }
         }
         if(!exists) {
             ArrayResize(BullishZones, totalBullZones + 1);
             BullishZones[totalBullZones] = z;
             totalBullZones++;
             count++;
         }
      }
      else
      {
         bool exists = false;
         for(int k=0; k<totalBearZones; k++) {
             if(BearishZones[k].timeframe == z.timeframe)
             {
                 if(MathAbs(BearishZones[k].top - z.top) < Point && 
                    MathAbs(BearishZones[k].bottom - z.bottom) < Point) { exists = true; break; }
                 if(MathAbs(BearishZones[k].startTime - z.startTime) <= PeriodSeconds(z.timeframe) * 5) { exists = true; break; }
             }
         }
         if(!exists) {
             ArrayResize(BearishZones, totalBearZones + 1);
             BearishZones[totalBearZones] = z;
             totalBearZones++;
             count++;
         }
      }
   }
   FileClose(handle);
   Print("Restore: Success! Loaded ", count, " zones from ", filename);

   // Immediately prune any restored zones that are already older than Zone_ExpiryBars.
   // This prevents 46-day-old backup zones from surviving into the current session.
   for(int k2 = 0; k2 < TF_COUNT; k2++)
   {
      PruneOldZonesForTF(TF_List[k2]);
   }
   if (DebugMode) Print("Restore: Post-restore pruning finished for all timeframes.");
}

//+------------------------------------------------------------------+
//| TraceChat - draggable AI chat panel                              |
//+------------------------------------------------------------------+
void ChatCreateRect(string name, int x, int y, int width, int height, color clr)
{
   if (ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
}

void ChatCreateLabel(string name, string text, int x, int y, int width, int height, color clr, int size)
{
   if (ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
}

void ChatCreateButton(string name, string text)
{
   if (ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, Chat_FontSize);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, Chat_ButtonColor);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_STATE, false);
   ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
}

int ChatPanelHeight()
{
   int titleH = 24;
   if (g_chatMinimized) return titleH;
   return titleH + 105 + Chat_Lines * 14;
}

void ChatLayout()
{
   int w = Chat_Width;
   int titleH = 24;
   int totalH = ChatPanelHeight();
   ChatCreateRect("TraceChat_Back", g_chatX, g_chatY, w, totalH, Chat_BgColor);
   ChatCreateRect("TraceChat_TitleBar", g_chatX, g_chatY, w, titleH, Chat_TitleColor);
   string titleText = Chat_Scout ? "TRACE AI CHAT - SCOUT ON" : "TRACE AI CHAT - drag me";
   ChatCreateLabel("TraceChat_Title", titleText, g_chatX + 7, g_chatY + 5, w - 10, 18, clrWhite, Chat_FontSize + 1);
   ChatCreateButton("TraceChat_Min", g_chatMinimized ? "+" : "-");
   ObjectSetInteger(0, "TraceChat_Min", OBJPROP_XDISTANCE, g_chatX + w - 57);
   ObjectSetInteger(0, "TraceChat_Min", OBJPROP_YDISTANCE, g_chatY + 1);
   ObjectSetInteger(0, "TraceChat_Min", OBJPROP_XSIZE, 52);
   ObjectSetInteger(0, "TraceChat_Min", OBJPROP_YSIZE, 21);
   if (g_chatMinimized)
   {
      string hidden[] = {"TraceChat_Send","TraceChat_Watch","TraceChat_Plan","TraceChat_Tune","TraceChat_Clear","TraceChat_Up","TraceChat_Down",
                        "TraceChat_Input","TraceChat_Status"};
      for (int hi = 0; hi < ArraySize(hidden); hi++)
         ObjectSetInteger(0, hidden[hi], OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
      for (int hli = 0; hli < Chat_Lines; hli++)
         ObjectSetInteger(0, "TraceChat_Line_" + IntegerToString(hli), OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
      ChatScoreLayout();
      return;
   }
   int by = g_chatY + 27;
   ChatCreateButton("TraceChat_Send", "Send");
   ChatCreateButton("TraceChat_Watch", g_chatWatchActive ? "W ON" : "Watch");
   ChatCreateButton("TraceChat_Plan", "PLAN");
   ChatCreateButton("TraceChat_Tune", "TUNE");
   ObjectSetInteger(0, "TraceChat_Tune", OBJPROP_TIMEFRAMES,
                    Chat_TuneEnable ? OBJ_ALL_PERIODS : OBJ_NO_PERIODS);
   ChatCreateButton("TraceChat_Clear", "Clear");
   ChatCreateButton("TraceChat_Up", "^");
   ChatCreateButton("TraceChat_Down", "v");
   string bn[7];
   int bx[7];
   int bw[7];
   bn[0] = "TraceChat_Send";
   bn[1] = "TraceChat_Watch";
   bn[2] = "TraceChat_Plan";
   bn[3] = "TraceChat_Tune";
   bn[4] = "TraceChat_Clear";
   bn[5] = "TraceChat_Up";
   bn[6] = "TraceChat_Down";
   bx[0] = g_chatX + 5;
   bx[1] = g_chatX + 62;
   bx[2] = g_chatX + 119;
   bx[3] = g_chatX + 176;
   bx[4] = g_chatX + 233;
   bx[5] = g_chatX + w - 57;
   bx[6] = g_chatX + w - 30;
   bw[0] = 53;
   bw[1] = 53;
   bw[2] = 53;
   bw[3] = 53;
   bw[4] = 53;
   bw[5] = 24;
   bw[6] = 24;
   for (int bi = 0; bi < 7; bi++)
   {
      ObjectSetInteger(0, bn[bi], OBJPROP_XDISTANCE, bx[bi]);
      ObjectSetInteger(0, bn[bi], OBJPROP_YDISTANCE, by);
      ObjectSetInteger(0, bn[bi], OBJPROP_XSIZE, bw[bi]);
      ObjectSetInteger(0, bn[bi], OBJPROP_YSIZE, 21);
   }
   int transcriptY = by + 25;
   int visible = Chat_Lines;
   int maxScroll = g_chatTextCount - visible;
   if (maxScroll < 0) maxScroll = 0;
   if (g_chatScroll < 0) g_chatScroll = 0;
   if (g_chatScroll > maxScroll) g_chatScroll = maxScroll;
   int first = g_chatTextCount - visible - g_chatScroll;
   if (first < 0) first = 0;
   for (int li = 0; li < visible; li++)
   {
      string ln = "";
      color lc = Chat_TextColor;
      int idx = first + li;
      if (idx < g_chatTextCount) { ln = g_chatText[idx]; lc = (color)g_chatTextColor[idx]; }
      ChatCreateLabel("TraceChat_Line_" + IntegerToString(li), ln,
                      g_chatX + 7, transcriptY + li * 14, w - 14, 14, lc, Chat_FontSize);
   }
   int inputY = transcriptY + visible * 14 + 3;
   if (ObjectFind(0, "TraceChat_Input") < 0) ObjectCreate(0, "TraceChat_Input", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "TraceChat_Input", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "TraceChat_Input", OBJPROP_XDISTANCE, g_chatX + 7);
   ObjectSetInteger(0, "TraceChat_Input", OBJPROP_YDISTANCE, inputY);
   ObjectSetInteger(0, "TraceChat_Input", OBJPROP_XSIZE, w - 14);
   ObjectSetInteger(0, "TraceChat_Input", OBJPROP_YSIZE, 22);
   ObjectSetInteger(0, "TraceChat_Input", OBJPROP_FONTSIZE, Chat_FontSize);
   ObjectSetInteger(0, "TraceChat_Input", OBJPROP_ALIGN, ALIGN_LEFT);
   ObjectSetInteger(0, "TraceChat_Input", OBJPROP_COLOR, Chat_InputTextColor);
   ObjectSetInteger(0, "TraceChat_Input", OBJPROP_BGCOLOR, Chat_InputBgColor);
   ObjectSetInteger(0, "TraceChat_Input", OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, "TraceChat_Input", OBJPROP_BACK, false);
   ObjectSetInteger(0, "TraceChat_Input", OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   ObjectSetString(0, "TraceChat_Input", OBJPROP_TEXT, ObjectGetString(0, "TraceChat_Input", OBJPROP_TEXT));
   ChatCreateLabel("TraceChat_Status", g_chatStatus, g_chatX + 7, inputY + 24, w - 14, 16, Chat_TextColor, Chat_FontSize);
   ChatScoreLayout();
}

void ChatAppend(string text, int clr)
{
   string wrapped = ChatWrap(ChatSanitize(text));
   string lines[]; int n = StringSplit(wrapped, 10, lines);
   if (n < 1) n = 1;
   for (int i = 0; i < n; i++)
   {
      ArrayResize(g_chatText, g_chatTextCount + 1);
      ArrayResize(g_chatTextColor, g_chatTextCount + 1);
      g_chatText[g_chatTextCount] = lines[i];
      g_chatTextColor[g_chatTextCount] = clr;
      g_chatTextCount++;
   }
   while (g_chatTextCount > 160)
   {
      for (int j = 1; j < g_chatTextCount; j++)
      {
         g_chatText[j - 1] = g_chatText[j];
         g_chatTextColor[j - 1] = g_chatTextColor[j];
      }
      g_chatTextCount--;
      ArrayResize(g_chatText, g_chatTextCount);
      ArrayResize(g_chatTextColor, g_chatTextCount);
   }
   g_chatScroll = 0;
}

string ChatWrap(string text)
{
   string out = ""; string words[]; int n = StringSplit(text, 32, words);
   string line = "";
   int wrapChars = MathMax(1, Chat_WrapChars);
   for (int i = 0; i < n; i++)
   {
      string word = words[i];
      while (StringLen(word) > wrapChars)
      {
         if (StringLen(line) > 0)
         {
            out += line + "\n";
            line = "";
         }
         out += StringSubstr(word, 0, wrapChars) + "\n";
         word = StringSubstr(word, wrapChars);
      }
      if (StringLen(word) == 0) continue;
      if (StringLen(line) + StringLen(word) + 1 > wrapChars && StringLen(line) > 0)
      {
         out += line + "\n"; line = word;
      }
      else
      {
         if (StringLen(line) > 0) line += " ";
         line += word;
      }
   }
   if (StringLen(line) > 0 || StringLen(out) == 0) out += line;
   return out;
}

void ChatRefreshStatus()
{
   if (ObjectFind(0, "TraceChat_Status") >= 0)
      ObjectSetString(0, "TraceChat_Status", OBJPROP_TEXT, g_chatStatus);
}

string ChatWatchStatus(string suffix)
{
   string shown = ChatSanitize(g_chatWatchInstruction);
   if (StringLen(shown) > 40) shown = StringSubstr(shown, 0, 40) + "...";
   return ChatSanitize("WATCH: " + shown + " [" + Chat_Mode + "] " + suffix);
}

string ChatSanitize(string text)
{
   string out = "";
   for (int i = 0; i < StringLen(text); i++)
   {
      ushort c = StringGetChar(text, i);
      string mapped = "";
      if (c >= 32 && c <= 126) mapped = ShortToString(c);
      else if (c == 160) mapped = " ";
      else if (c == 8216 || c == 8217 || c == 8218 || c == 8242) mapped = "'";
      else if (c == 8220 || c == 8221 || c == 8222 || c == 8243) mapped = "\"";
      else if (c == 8211 || c == 8212 || c == 8722) mapped = "-";
      else if (c == 8230) mapped = "...";
      else
      {
         switch (c)
         {
            case 0x410: mapped = "A"; break;
            case 0x430: mapped = "a"; break;
            case 0x411: mapped = "B"; break;
            case 0x431: mapped = "b"; break;
            case 0x412: mapped = "V"; break;
            case 0x432: mapped = "v"; break;
            case 0x413: mapped = "G"; break;
            case 0x433: mapped = "g"; break;
            case 0x414: mapped = "D"; break;
            case 0x434: mapped = "d"; break;
            case 0x403: mapped = "Gj"; break;
            case 0x453: mapped = "gj"; break;
            case 0x415: mapped = "E"; break;
            case 0x435: mapped = "e"; break;
            case 0x416: mapped = "Zh"; break;
            case 0x436: mapped = "zh"; break;
            case 0x417: mapped = "Z"; break;
            case 0x437: mapped = "z"; break;
            case 0x405: mapped = "Dz"; break;
            case 0x455: mapped = "dz"; break;
            case 0x418: mapped = "I"; break;
            case 0x438: mapped = "i"; break;
            case 0x408: mapped = "J"; break;
            case 0x458: mapped = "j"; break;
            case 0x419: mapped = "J"; break;
            case 0x439: mapped = "j"; break;
            case 0x41A: mapped = "K"; break;
            case 0x43A: mapped = "k"; break;
            case 0x41B: mapped = "L"; break;
            case 0x43B: mapped = "l"; break;
            case 0x409: mapped = "Lj"; break;
            case 0x459: mapped = "lj"; break;
            case 0x41C: mapped = "M"; break;
            case 0x43C: mapped = "m"; break;
            case 0x41D: mapped = "N"; break;
            case 0x43D: mapped = "n"; break;
            case 0x40A: mapped = "Nj"; break;
            case 0x45A: mapped = "nj"; break;
            case 0x41E: mapped = "O"; break;
            case 0x43E: mapped = "o"; break;
            case 0x41F: mapped = "P"; break;
            case 0x43F: mapped = "p"; break;
            case 0x420: mapped = "R"; break;
            case 0x440: mapped = "r"; break;
            case 0x421: mapped = "S"; break;
            case 0x441: mapped = "s"; break;
            case 0x422: mapped = "T"; break;
            case 0x442: mapped = "t"; break;
            case 0x40C: mapped = "Kj"; break;
            case 0x45C: mapped = "kj"; break;
            case 0x423: mapped = "U"; break;
            case 0x443: mapped = "u"; break;
            case 0x424: mapped = "F"; break;
            case 0x444: mapped = "f"; break;
            case 0x425: mapped = "H"; break;
            case 0x445: mapped = "h"; break;
            case 0x426: mapped = "C"; break;
            case 0x446: mapped = "c"; break;
            case 0x427: mapped = "Ch"; break;
            case 0x447: mapped = "ch"; break;
            case 0x40F: mapped = "Dj"; break;
            case 0x45F: mapped = "dj"; break;
            case 0x428: mapped = "Sh"; break;
            case 0x448: mapped = "sh"; break;
            case 0x401: mapped = "Yo"; break;
            case 0x451: mapped = "yo"; break;
            case 0x42B: mapped = "Y"; break;
            case 0x44B: mapped = "y"; break;
            case 0x42D: mapped = "E"; break;
            case 0x44D: mapped = "e"; break;
            case 0x42E: mapped = "Yu"; break;
            case 0x44E: mapped = "yu"; break;
            case 0x42F: mapped = "Ya"; break;
            case 0x44F: mapped = "ya"; break;
            case 0x429: mapped = "Shch"; break;
            case 0x449: mapped = "shch"; break;
            case 0x42A: case 0x44A: mapped = ""; break;
            case 0x42C: case 0x44C: mapped = ""; break;
         }
      }
      out += mapped;
   }
   return out;
}

void ChatWatchSave()
{
   string path = "TraceAI\\chat_watch_" + Symbol() + ".txt";
   int h = FileOpen(path, FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ);
   if (h == INVALID_HANDLE)
   {
      Print("TraceChat cannot save watch instruction: ", path);
      return;
   }
   FileWriteString(h, g_chatWatchInstruction);
   FileFlush(h);
   FileClose(h);
}

void ChatWatchLoad()
{
   string path = "TraceAI\\chat_watch_" + Symbol() + ".txt";
   g_chatWatchInstruction = "";
   if (FileIsExist(path))
   {
      int h = FileOpen(path, FILE_READ|FILE_TXT|FILE_SHARE_READ|FILE_SHARE_WRITE);
      if (h != INVALID_HANDLE)
      {
         g_chatWatchInstruction = FileReadString(h, (int)FileSize(h));
         FileClose(h);
      }
   }
   StringTrimLeft(g_chatWatchInstruction);
   StringTrimRight(g_chatWatchInstruction);
   g_chatWatchActive = (Chat_WatchEnable && StringLen(g_chatWatchInstruction) > 0);
}

void ChatWatchSetInstruction(string instruction)
{
   StringTrimLeft(instruction);
   StringTrimRight(instruction);
   g_chatWatchInstruction = instruction;
   g_chatWatchActive = (Chat_WatchEnable && StringLen(instruction) > 0);
   ChatWatchSave();
   if (g_chatWatchActive)
   {
      g_chatWatchLastSignature = "";
      g_chatStatus = ChatWatchStatus("armed");
      Print("TraceChat WATCH armed: ", g_chatWatchInstruction);
   }
   else
   {
      g_chatStatus = "Ready [" + Chat_Mode + "]";
      Print("TraceChat WATCH off");
   }
   ChatLayout();
   ChartRedraw();
}

void ChatWatchToggle()
{
   if (Chat_WatchDisableAll)
   {
      g_chatStatus = "WATCH e isklucen (Chat_WatchDisableAll)";
      ChatRefreshStatus();
      return;
   }
   if (StringLen(g_chatWatchInstruction) > 0)
   {
      ChatWatchSetInstruction("");
      return;
   }
   string instruction = ObjectGetString(0, "TraceChat_Input", OBJPROP_TEXT);
   StringTrimLeft(instruction);
   StringTrimRight(instruction);
   if (StringLen(instruction) == 0)
   {
      g_chatStatus = "Type a WATCH instruction first.";
      ChatLayout();
      ChartRedraw();
      return;
   }
   ChatWatchSetInstruction(instruction);
   ObjectSetString(0, "TraceChat_Input", OBJPROP_TEXT, "");
}

string ChatWatchStateSignature()
{
   string sig = (g_gatePass ? "1" : "0") + "|" + IntegerToString(g_gateDir) + "|" +
                IntegerToString(g_gatePassed) + "|" + IntegerToString(g_sigCachedTrend) + "|" +
                g_sigCachedGrade + "|" + g_aiDecision + "|Z=";
   double px = Bid;
   bool inside = false;
   for (int i = 0; i < totalBullZones; i++)
   {
      if (BullishZones[i].tpHit || BullishZones[i].slHit) continue;
      if (px >= BullishZones[i].bottom && px <= BullishZones[i].top)
      {
         sig += "B" + TimeframeToString(BullishZones[i].timeframe) + ";";
         inside = true;
      }
   }
   for (int j = 0; j < totalBearZones; j++)
   {
      if (BearishZones[j].tpHit || BearishZones[j].slHit) continue;
      if (px >= BearishZones[j].bottom && px <= BearishZones[j].top)
      {
         sig += "S" + TimeframeToString(BearishZones[j].timeframe) + ";";
         inside = true;
      }
   }
   if (!inside) sig += "NONE";
   return sig;
}

bool ChatWatchCall(string &reply)
{
   string context = "";
   ChatBuildContext(context);
   string instruction = "Stored user watch instruction: " + g_chatWatchInstruction +
                        "\nEvaluate the current EA context for this instruction. " +
                        "Your first line MUST be exactly TRIGGER=YES or TRIGGER=NO. " +
                        "After it, give one or two short lines of reasoning with concrete levels. " +
                        "Output ASCII-only plain text: Macedonian LATIN script only, absolutely no Cyrillic, " +
                        "no emoji, arrows, checkmarks, box-drawing, or other special symbols.";
   string answer = "";
   int oldTimeout = g_chatTransportTimeoutMs;
   g_chatTransportTimeoutMs = Chat_WatchTimeoutMs;
   bool ok = false;
   if (Chat_Mode == "DIRECT") ok = ChatPostDirect(instruction, context, "", answer);
   else ok = ChatPostServer(instruction, context, "", answer);
   g_chatTransportTimeoutMs = oldTimeout;
   reply = answer;
   return ok;
}

void ChatWatchOnTimer()
{
   if (Chat_WatchDisableAll) return;
   if (!Chat_Enable || !Chat_WatchEnable || IsTesting() || IsOptimization()) return;
   if (AiWeekendSkip()) return;
   if (!g_chatWatchActive || g_chatBusy) return;
   int today = TimeDay(TimeCurrent());
   if (today != g_chatWatchDay)
   {
      g_chatWatchDay = today;
      g_chatWatchCallsToday = 0;
   }
   string signature = ChatWatchStateSignature();
   if (StringLen(g_chatWatchLastSignature) == 0)
   {
      g_chatWatchLastSignature = signature;
      return;
   }
   if (signature == g_chatWatchLastSignature) return;
   g_chatWatchLastSignature = signature;
   datetime now = TimeCurrent();
   if (g_chatWatchCallsToday >= Chat_WatchMaxPerDay) return;
   if (g_chatWatchLastCall > 0 && now - g_chatWatchLastCall < Chat_WatchMinGapSec) return;
   g_chatBusy = true;
   g_chatWatchLastCall = now;
   g_chatWatchCallsToday++;
   string reply = "";
   bool ok = ChatWatchCall(reply);
   g_chatBusy = false;
   if (!ok)
   {
      g_chatStatus = ChatWatchStatus("check failed");
      Print("TraceChat WATCH ERROR: ", reply);
      ChatRefreshStatus();
      return;
   }
   int nl = StringFind(reply, "\n");
   string first = (nl >= 0) ? StringSubstr(reply, 0, nl) : reply;
   StringTrimLeft(first);
   StringTrimRight(first);
   if (StringFind(first, "TRIGGER=YES") == 0)
   {
      string reason = (nl >= 0) ? StringSubstr(reply, nl + 1) : "";
      StringTrimLeft(reason);
      StringTrimRight(reason);
      string message = ChatSanitize("WATCH TRIGGER: " + reason);
      ChatAppend(message, clrYellow);
      if (Chat_WatchAlert) Alert(message);
      if (Chat_WatchTelegram) SendTelegramMessage(message);
      g_chatStatus = ChatWatchStatus("TRIGGERED");
      Print("TraceChat WATCH YES: ", reason);
      ChatLayout();
      ChartRedraw();
   }
   else
   {
      g_chatStatus = ChatWatchStatus("last check " + TimeToString(now, TIME_MINUTES));
      Print("TraceChat WATCH NO: ", reply);
      ChatRefreshStatus();
   }
}

string ChatAutoPlanStateKey(string suffix)
{
   return "TraceChatAutoPlan_" + Symbol() + "_" + suffix;
}

void ChatAutoPlanSaveState()
{
   GlobalVariableSet(ChatAutoPlanStateKey("day"), (double)g_chatAutoPlanDay);
   GlobalVariableSet(ChatAutoPlanStateKey("calls"), (double)g_chatAutoPlanCallsToday);
   GlobalVariableSet(ChatAutoPlanStateKey("last"), (double)g_chatAutoPlanLastFire);
}

void ChatAutoPlanLoadState()
{
   g_chatAutoPlanDay = TimeDay(TimeCurrent());
   g_chatAutoPlanCallsToday = 0;
   g_chatAutoPlanLastFire = 0;
   string dayKey = ChatAutoPlanStateKey("day");
   string callsKey = ChatAutoPlanStateKey("calls");
   string lastKey = ChatAutoPlanStateKey("last");
   if (GlobalVariableCheck(dayKey)) g_chatAutoPlanDay = (int)GlobalVariableGet(dayKey);
   if (GlobalVariableCheck(callsKey)) g_chatAutoPlanCallsToday = (int)GlobalVariableGet(callsKey);
   if (GlobalVariableCheck(lastKey)) g_chatAutoPlanLastFire = (datetime)GlobalVariableGet(lastKey);
   int today = TimeDay(TimeCurrent());
   if (g_chatAutoPlanDay != today)
   {
      g_chatAutoPlanDay = today;
      g_chatAutoPlanCallsToday = 0;
      g_chatAutoPlanLastFire = 0;
      ChatAutoPlanSaveState();
   }
}

void ChatAutoPlanOnTimer()
{
   if (!Chat_Enable || !Chat_AutoPlan || IsTesting() || IsOptimization()) return;
   if (AiWeekendSkip()) return;
   if (g_chatBusy) return;

   int today = TimeDay(TimeCurrent());
   if (today != g_chatAutoPlanDay)
   {
      g_chatAutoPlanDay = today;
      g_chatAutoPlanCallsToday = 0;
      g_chatAutoPlanLastFire = 0;
      ChatAutoPlanSaveState();
   }

   string autoBosWhy = "";
   bool autoBosConfirmed = DashPassBOSConfirmCheck(GetDashMinBOSConfirmBarsForTF(g_sigCachedStructTF), g_sigCachedStructTF,
                                                   g_sigCachedTrend, g_sigCachedBOSLevel, autoBosWhy);
   bool clean = (g_gatePass && (g_gateDir == 1 || g_gateDir == -1) &&
                 g_sigCachedTrend != 0 &&
                 g_sigCachedTrend == g_confirmCachedTrend &&
                 StringFind(g_sigCachedAction, "[READY]") >= 0 &&
                 autoBosConfirmed &&
                 g_sigCachedScore >= AI_GateMinScore &&
                 AIGradeRank(g_sigCachedGrade) >= AIGradeRank(AI_GateMinGrade));
   if (!clean)
   {
      g_chatAutoPlanWasClean = false;
      g_chatAutoPlanLastSignature = "";
      return;
   }

   string signature = ChatWatchStateSignature();
   if (g_chatAutoPlanWasClean && signature == g_chatAutoPlanLastSignature) return;
   if (g_chatAutoPlanWasClean) return;
   g_chatAutoPlanWasClean = true;
   g_chatAutoPlanLastSignature = signature;

   datetime now = TimeCurrent();
   if (g_chatAutoPlanCallsToday >= Chat_AutoPlanMaxPerDay) return;
   int sharedQuietSec = MathMax(Chat_AutoPlanMinGapSec, Chat_ScoutQuietRepeatMin * 60);
   if (g_chatAutoPlanLastFire > 0 && now - g_chatAutoPlanLastFire < sharedQuietSec) return;

   g_chatAutoPlanLastFire = now;
   g_chatAutoPlanCallsToday++;
   ChatAutoPlanSaveState();
   ChatPlanRun(true, false);
}

int ChatScoutTf()
{
   int tf = ChatVisionTfFromName(Chat_ScoutTF);
   return (tf > 0) ? tf : PERIOD_M5;
}

string ChatScoutStateKey(string suffix)
{
   return "TraceChatScout_" + Symbol() + "_" + suffix;
}

// Vremenski prozorec so minuti (server vreme). Start==End ili nevaliden opseg = 24h,
// a start > end znaci preku polnok (npr 22:30-6:15).
bool ChatMinuteWindowOpen(datetime now, int startHour, int startMinute,
                          int endHour, int endMinute)
{
   startMinute = MathMax(0, MathMin(59, startMinute));
   endMinute = MathMax(0, MathMin(59, endMinute));
   if (startHour < 0 || startHour > 23 || endHour < 1 || endHour > 24) return true;
   int start = startHour * 60 + startMinute;
   int end   = endHour * 60 + endMinute;
   if (start == end) return true;
   int minuteOfDay = TimeHour(now) * 60 + TimeMinute(now);
   if (start < end) return (minuteOfDay >= start && minuteOfDay < end);
   return (minuteOfDay >= start || minuteOfDay < end);
}

bool ChatScoutInWindow(datetime now)
{
   return ChatMinuteWindowOpen(now, Chat_ScoutStartHour, Chat_ScoutStartMinute,
                               Chat_ScoutEndHour, Chat_ScoutEndMinute);
}

// Status so brojach, za da se vidi dali SCOUT uste ima povici za denes.
string ChatScoutStatusText()
{
   int everyBars = MathMax(1, Chat_ScoutEveryBars);
   string s = "SCOUT " + IntegerToString(g_chatScoutCallsToday) + "/" +
              IntegerToString(Chat_ScoutMaxPerDay) +
              " bar " + IntegerToString(g_chatScoutBarCount) + "/" +
              IntegerToString(everyBars);
   if (StringLen(g_chatScoutWhy) > 0) s = s + " " + g_chatScoutWhy;
   if (StringLen(g_chatVisionAges) > 0) s = s + " | sliki " + g_chatVisionAges;
   return s + " [" + Chat_Mode + "]";
}

void ChatScoutSaveState()
{
   GlobalVariableSet(ChatScoutStateKey("day"), (double)g_chatScoutDay);
   GlobalVariableSet(ChatScoutStateKey("calls"), (double)g_chatScoutCallsToday);
   GlobalVariableSet(ChatScoutStateKey("lastfire"), (double)g_chatScoutLastFire);
   GlobalVariableSet(ChatScoutStateKey("dir"), (double)g_chatScoutLastDir);
   GlobalVariableSet(ChatScoutStateKey("entry"), g_chatScoutLastEntry);
   GlobalVariableSet(ChatScoutStateKey("sl"), g_chatScoutLastSL);
   GlobalVariableSet(ChatScoutStateKey("tp2"), g_chatScoutLastTP2);
   GlobalVariableSet(ChatScoutStateKey("announce"), (double)g_chatScoutLastAnnounce);
   GlobalVariableSet(ChatScoutStateKey("watchdir"), (double)g_chatScoutWatchLastDir);
   GlobalVariableSet(ChatScoutStateKey("watchentry"), g_chatScoutWatchLastEntry);
   GlobalVariableSet(ChatScoutStateKey("watchsl"), g_chatScoutWatchLastSL);
   GlobalVariableSet(ChatScoutStateKey("watchtp2"), g_chatScoutWatchLastTP2);
   GlobalVariableSet(ChatScoutStateKey("watchannounce"), (double)g_chatScoutWatchLastAnnounce);
   GlobalVariableSet(ChatScoutStateKey("armdir"), (double)g_chatScoutArmDir);
   GlobalVariableSet(ChatScoutStateKey("armentry"), g_chatScoutArmEntry);
   GlobalVariableSet(ChatScoutStateKey("armsl"), g_chatScoutArmSL);
   GlobalVariableSet(ChatScoutStateKey("armtp1"), g_chatScoutArmTP1);
   GlobalVariableSet(ChatScoutStateKey("armtp2"), g_chatScoutArmTP2);
   GlobalVariableSet(ChatScoutStateKey("armconf"), g_chatScoutArmConf);
   GlobalVariableSet(ChatScoutStateKey("armtime"), (double)g_chatScoutArmTime);
}

void ChatScoutLoadState()
{
   g_chatScoutDay = TimeDay(TimeCurrent());
   g_chatScoutCallsToday = 0;
   g_chatScoutLastFire = 0;
   g_chatScoutLastDir = 0;
   g_chatScoutLastEntry = 0.0;
   g_chatScoutLastSL = 0.0;
   g_chatScoutLastTP2 = 0.0;
   g_chatScoutLastAnnounce = 0;
   g_chatScoutWatchLastDir = 0;
   g_chatScoutWatchLastEntry = 0.0;
   g_chatScoutWatchLastSL = 0.0;
   g_chatScoutWatchLastTP2 = 0.0;
   g_chatScoutWatchLastAnnounce = 0;
   g_chatScoutArmDir = 0;
   g_chatScoutArmEntry = 0.0;
   g_chatScoutArmSL = 0.0;
   g_chatScoutArmTP1 = 0.0;
   g_chatScoutArmTP2 = 0.0;
   g_chatScoutArmConf = 0.0;
   g_chatScoutArmTime = 0;
   string dayKey = ChatScoutStateKey("day");
   string callsKey = ChatScoutStateKey("calls");
   string fireKey = ChatScoutStateKey("lastfire");
   string dirKey = ChatScoutStateKey("dir");
   string entryKey = ChatScoutStateKey("entry");
   string slKey = ChatScoutStateKey("sl");
   string tp2Key = ChatScoutStateKey("tp2");
   string announceKey = ChatScoutStateKey("announce");
   string watchDirKey = ChatScoutStateKey("watchdir");
   string watchEntryKey = ChatScoutStateKey("watchentry");
   string watchSLKey = ChatScoutStateKey("watchsl");
   string watchTP2Key = ChatScoutStateKey("watchtp2");
   string watchAnnounceKey = ChatScoutStateKey("watchannounce");
   string armDirKey = ChatScoutStateKey("armdir");
   string armEntryKey = ChatScoutStateKey("armentry");
   string armSLKey = ChatScoutStateKey("armsl");
   string armTP1Key = ChatScoutStateKey("armtp1");
   string armTP2Key = ChatScoutStateKey("armtp2");
   string armConfKey = ChatScoutStateKey("armconf");
   string armTimeKey = ChatScoutStateKey("armtime");
   if (GlobalVariableCheck(dayKey)) g_chatScoutDay = (int)GlobalVariableGet(dayKey);
   if (GlobalVariableCheck(callsKey)) g_chatScoutCallsToday = (int)GlobalVariableGet(callsKey);
   if (GlobalVariableCheck(fireKey)) g_chatScoutLastFire = (datetime)GlobalVariableGet(fireKey);
   if (GlobalVariableCheck(dirKey)) g_chatScoutLastDir = (int)GlobalVariableGet(dirKey);
   if (GlobalVariableCheck(entryKey)) g_chatScoutLastEntry = GlobalVariableGet(entryKey);
   if (GlobalVariableCheck(slKey)) g_chatScoutLastSL = GlobalVariableGet(slKey);
   if (GlobalVariableCheck(tp2Key)) g_chatScoutLastTP2 = GlobalVariableGet(tp2Key);
   if (GlobalVariableCheck(announceKey)) g_chatScoutLastAnnounce = (datetime)GlobalVariableGet(announceKey);
   if (GlobalVariableCheck(watchDirKey)) g_chatScoutWatchLastDir = (int)GlobalVariableGet(watchDirKey);
   if (GlobalVariableCheck(watchEntryKey)) g_chatScoutWatchLastEntry = GlobalVariableGet(watchEntryKey);
   if (GlobalVariableCheck(watchSLKey)) g_chatScoutWatchLastSL = GlobalVariableGet(watchSLKey);
   if (GlobalVariableCheck(watchTP2Key)) g_chatScoutWatchLastTP2 = GlobalVariableGet(watchTP2Key);
   if (GlobalVariableCheck(watchAnnounceKey)) g_chatScoutWatchLastAnnounce = (datetime)GlobalVariableGet(watchAnnounceKey);
   if (GlobalVariableCheck(armDirKey)) g_chatScoutArmDir = (int)GlobalVariableGet(armDirKey);
   if (GlobalVariableCheck(armEntryKey)) g_chatScoutArmEntry = GlobalVariableGet(armEntryKey);
   if (GlobalVariableCheck(armSLKey)) g_chatScoutArmSL = GlobalVariableGet(armSLKey);
   if (GlobalVariableCheck(armTP1Key)) g_chatScoutArmTP1 = GlobalVariableGet(armTP1Key);
   if (GlobalVariableCheck(armTP2Key)) g_chatScoutArmTP2 = GlobalVariableGet(armTP2Key);
   if (GlobalVariableCheck(armConfKey)) g_chatScoutArmConf = GlobalVariableGet(armConfKey);
   if (GlobalVariableCheck(armTimeKey)) g_chatScoutArmTime = (datetime)GlobalVariableGet(armTimeKey);
   if (g_chatScoutArmDir != 0 && StringLen(g_chatScoutArmTrigger) == 0)
   {
      g_chatScoutArmDir = 0;
      g_chatScoutArmEntry = 0.0;
      g_chatScoutArmSL = 0.0;
      g_chatScoutArmTP1 = 0.0;
      g_chatScoutArmTP2 = 0.0;
      g_chatScoutArmConf = 0.0;
      g_chatScoutArmTime = 0;
      g_chatScoutArmSetup = "";
      g_chatScoutArmTrigger = "";
      ChatScoutSaveState();
   }
   int today = TimeDay(TimeCurrent());
   if (g_chatScoutDay != today)
   {
      g_chatScoutDay = today;
      g_chatScoutCallsToday = 0;
      g_chatScoutLastFire = 0;
      ChatScoutSaveState();
   }
}

void ChatScoutEmitSignal(int dir, string setup, double entry, double sl, double tp1,
                         double tp2, double conf, string trigger, string note)
{
   datetime now = TimeCurrent();
   int scoutTf = ChatVisionTfFromName(Chat_ScoutTF);
   if (scoutTf <= 0) scoutTf = PERIOD_M5;
   double scoutAtr = iATR(Symbol(), scoutTf, 14, 1);
   if (scoutAtr <= 0) scoutAtr = Point * 50;
   double tolerance = MathMax(scoutAtr * 0.25, Point * 10);
   if (g_chatScoutLastAnnounce > 0 &&
       now - g_chatScoutLastAnnounce < Chat_ScoutQuietRepeatMin * 60 &&
       dir == g_chatScoutLastDir &&
       MathAbs(entry - g_chatScoutLastEntry) <= tolerance &&
       MathAbs(sl - g_chatScoutLastSL) <= tolerance &&
       MathAbs(tp2 - g_chatScoutLastTP2) <= tolerance)
   {
      Print("TraceChat SCOUT silent: duplicate ", setup, " entry=",
            DoubleToString(entry, Digits), " tolerance=", DoubleToString(tolerance, Digits));
      ChatScoutLog("DUPLICATE", setup, conf, entry, sl, tp2, note);
      if (Chat_ScoutVerbose)
         ChatAppend(TimeToString(now, TIME_MINUTES) + " SCOUT " + setup +
                    " isto kako prethodniot signal - ne se povtoruva", clrGray);
      g_chatStatus = ChatScoutStatusText();
      ChatLayout();
      ChartRedraw();
      return;
   }
   double rr = ChatPlanRRCalc(entry, sl, tp2);
   string levelsLine = "LEVELS: ENTRY=" + DoubleToString(entry, Digits) +
                       " SL=" + DoubleToString(sl, Digits) +
                       " TP1=" + DoubleToString(tp1, Digits) +
                       " TP2=" + DoubleToString(tp2, Digits) +
                       " RR=" + DoubleToString(rr, 2);
   string alertText = ChatSanitize("SCOUT: " + setup + " " + levelsLine);
   ChatPlanRecord(setup, entry, sl, tp1, tp2, rr, conf);
   ChatTriggerArm(setup, trigger, entry, sl, tp1, tp2, rr, conf);
   ChatAppend("SCOUT:\nWATCH ARM " + levelsLine, clrAqua);
   if (StringLen(note) > 0) ChatAppend("EA: " + note, clrLime);
   if (Chat_ScoutAlert) Alert(alertText);
   if (Chat_ScoutTelegram) SendTelegramMessage(alertText);
   ChatScoutLog("WATCH_ARMED_SIGNAL", setup, conf, entry, sl, tp2, note);
   g_chatScoutLastDir = dir;
   g_chatScoutLastEntry = entry;
   g_chatScoutLastSL = sl;
   g_chatScoutLastTP2 = tp2;
   g_chatScoutLastAnnounce = now;
   g_chatAutoPlanLastFire = now;
   ChatAutoPlanSaveState();
   ChatScoutSaveState();
   g_chatStatus = ChatScoutStatusText();
   ChatLayout();
   ChartRedraw();
   Print("TraceChat SCOUT WATCH_ARMED_SIGNAL: ", setup, " CONF=", DoubleToString(conf, 0));
}

void ChatScoutCheckArmedWatch()
{
   if (Chat_WatchDisableAll || !Chat_WatchArmEnable || g_chatScoutArmDir == 0) return;
   datetime now = TimeCurrent();
   if (g_chatScoutArmTime <= 0 ||
       now - g_chatScoutArmTime > Chat_WatchArmMinutes * 60 ||
       (g_sigCachedTrend != 0 && g_sigCachedTrend == -g_chatScoutArmDir))
   {
      g_chatScoutArmDir = 0;
      g_chatScoutArmEntry = 0.0;
      g_chatScoutArmSL = 0.0;
      g_chatScoutArmTP1 = 0.0;
      g_chatScoutArmTP2 = 0.0;
      g_chatScoutArmConf = 0.0;
      g_chatScoutArmTime = 0;
      g_chatScoutArmSetup = "";
      g_chatScoutArmTrigger = "";
      ChatScoutSaveState();
      return;
   }
   int tf = ChatScoutTf();
   double atr = iATR(Symbol(), tf, 14, 1);
   if (atr <= 0.0) return;
   double bid = (Bid > 0.0) ? Bid : iClose(Symbol(), Period(), 0);
   if (MathAbs(bid - g_chatScoutArmEntry) > Chat_WatchArmTolATR * atr) return;
   string why = "";
   if (!PassFinalSignalJudge(g_chatScoutArmDir, g_chatScoutArmEntry, g_chatScoutArmSL,
                             g_chatScoutArmTP2, g_chatScoutArmConf,
                             g_chatScoutArmTrigger, why, false))
      return;
   string setup = g_chatScoutArmSetup;
   if (StringLen(setup) == 0) setup = (g_chatScoutArmDir == 1) ? "BUY" : "SELL";
   ChatScoutEmitSignal(g_chatScoutArmDir, setup, g_chatScoutArmEntry,
                       g_chatScoutArmSL, g_chatScoutArmTP1, g_chatScoutArmTP2,
                       g_chatScoutArmConf, g_chatScoutArmTrigger, "WATCH ARM");
   g_chatScoutArmDir = 0;
   g_chatScoutArmEntry = 0.0;
   g_chatScoutArmSL = 0.0;
   g_chatScoutArmTP1 = 0.0;
   g_chatScoutArmTP2 = 0.0;
   g_chatScoutArmConf = 0.0;
   g_chatScoutArmTime = 0;
   g_chatScoutArmSetup = "";
   g_chatScoutArmTrigger = "";
   ChatScoutSaveState();
}

void ChatScoutOnTimer()
{
   if (!Chat_Enable || !Chat_Scout || IsTesting() || IsOptimization()) return;
   if (AiWeekendSkip()) return;
   if (g_chatBusy) return;
   ChatScoutCheckArmedWatch();
   datetime now = TimeCurrent();
   datetime tickTime = (datetime)MarketInfo(Symbol(), MODE_TIME);

   // Zivo pokazuvanje na sostojbata na SCOUT vo statusot (za da se vidi zosto ne vika).
   bool inWindow = ChatScoutInWindow(now);
   g_chatScoutWhy = "";
   if (!IsConnected())                                    g_chatScoutWhy = "(nema konekcija)";
   else if (tickTime <= 0 || now - tickTime > 300)         g_chatScoutWhy = "(pazar zatvoren/nema tikovi)";
   else if (!inWindow)                                    g_chatScoutWhy = "(von " +
                                                                            StringFormat("%02d:%02d-%02d:%02d",
                                                                                         Chat_ScoutStartHour, Chat_ScoutStartMinute,
                                                                                         Chat_ScoutEndHour, Chat_ScoutEndMinute) + ")";
   else if (g_chatScoutCallsToday >= Chat_ScoutMaxPerDay)  g_chatScoutWhy = "(dneven limit)";
   if (!g_chatWatchActive)
   {
      string live = ChatScoutStatusText();
      if (live != g_chatStatus) { g_chatStatus = live; ChatRefreshStatus(); }
   }

   if (!IsConnected()) return;
   if (tickTime <= 0 || now <= 0 || now - tickTime > 300) return;
   if (!inWindow) return;
   int today = TimeDay(now);
   if (today != g_chatScoutDay)
   {
      g_chatScoutDay = today;
      g_chatScoutCallsToday = 0;
      g_chatScoutLastFire = 0;
      ChatScoutSaveState();
   }
   int tf = ChatScoutTf();
   datetime barTime = iTime(Symbol(), tf, 0);
   if (barTime <= 0 || barTime == g_chatScoutLastBar) return;
   g_chatScoutLastBar = barTime;
   int everyBars = MathMax(1, Chat_ScoutEveryBars);
   // Kadencata se meri po VREME od posledniot povik (zapisano vo Global Variables),
   // a ne po brojach vo pamet - inace sekoj recompile/reattach go resetira i SCOUT nikogas ne vika.
   int    gapSec  = everyBars * PeriodSeconds(tf);
   long   sinceLast = (g_chatScoutLastFire > 0) ? (long)(now - g_chatScoutLastFire) : gapSec;
   g_chatScoutBarCount = (gapSec > 0) ? (int)MathMin(everyBars, sinceLast / PeriodSeconds(tf)) : 0;
   int  tfMin   = PeriodSeconds(tf) / 60;
   // ALIGN: vikaj na okrugli minuti (:00 :15 :30 :45) namesto "15 min od posledniot povik".
   bool aligned = (Chat_ScoutAlignClock && tfMin > 0 && gapSec >= 60 && gapSec <= 1800 &&
                   (3600 % gapSec) == 0);
   if (aligned)
   {
      int slotMin  = gapSec / 60;
      int intoSlot = TimeMinute(barTime) % slotMin;
      g_chatScoutBarCount = intoSlot / tfMin;
      if (intoSlot != 0)
      {
         Print("TraceChat SCOUT wait (align): ", intoSlot, " min vo blok od ", slotMin,
               " min - chekam okrugla minuta.");
         return;
      }
      if (g_chatScoutLastFire > 0 && (long)(now - g_chatScoutLastFire) < gapSec / 2)
      {
         Print("TraceChat SCOUT wait (align): vekje vikano vo ovoj blok.");
         return;
      }
   }
   else if (sinceLast < gapSec)
   {
      Print("TraceChat SCOUT wait: ", sinceLast, "s od ", gapSec, "s (",
            Chat_ScoutTF, " x", everyBars, ")");
      return;
   }
   if (Chat_ScoutLocalPreGate)
   {
      string preWhy = "";
      string preRegimeWhy = "";
      string preRegime = DetectMarketRegime(preRegimeWhy);
      bool preAdxAvailable = false;
      bool preM15Available = false;
      bool preH1Available = false;
      double preAdx = ChatScoutPreGateAdx(PERIOD_M15, preAdxAvailable);
      int preM15 = ChatScoutPreGateDir(PERIOD_M15, preM15Available);
      int preH1 = ChatScoutPreGateDir(PERIOD_H1, preH1Available);
      double preSpread = GetSpreadPoints();
      if (preRegime == "NEWS_BLOCK") preWhy = "regime NEWS_BLOCK";
      else if (preAdxAvailable && preAdx < Chat_ScoutPreMinADX)
         preWhy = "ADX(M15)=" + DoubleToString(preAdx, 1);
      else if (preH1Available && preM15Available &&
               preH1 == 0 && preM15 == 0)
         preWhy = "H1 i M15 FLAT";
      else if (AI_GateMaxSpreadPts > 0.0 && preSpread > AI_GateMaxSpreadPts)
         preWhy = "spread=" + DoubleToString(preSpread, 1);
      if (StringLen(preWhy) > 0)
      {
         ChatScoutLog("SKIP_LOCAL", "-", 0, 0, 0, 0, preWhy);
         g_chatScoutWhy = "SKIP_LOCAL " + preWhy;
         if (Chat_ScoutVerbose)
            ChatAppend(TimeToString(now, TIME_MINUTES) + " SCOUT SKIP_LOCAL: " + preWhy, clrGray);
         g_chatStatus = ChatScoutStatusText();
         ChatScoutRedraw();
         return;
      }
   }
   if (g_chatScoutOfflineRetryAfter > now)
   {
      string offlineWhy = "server offline backoff do " +
                          TimeToString(g_chatScoutOfflineRetryAfter, TIME_MINUTES);
      ChatScoutLog("SKIP_OFFLINE", "-", 0, 0, 0, 0, offlineWhy);
      g_chatScoutWhy = "SKIP_OFFLINE";
      if (Chat_ScoutVerbose)
         ChatAppend(TimeToString(now, TIME_MINUTES) + " SCOUT SKIP_OFFLINE", clrGray);
      g_chatStatus = ChatScoutStatusText();
      ChatScoutRedraw();
      return;
   }
   if (g_chatScoutCallsToday >= Chat_ScoutMaxPerDay)
   {
      static datetime scoutCapWarn = 0;
      if (now - scoutCapWarn > 900)
      {
         scoutCapWarn = now;
         Print("TraceChat SCOUT STOP: dneven limit potroshen ", g_chatScoutCallsToday,
               "/", Chat_ScoutMaxPerDay, " - krenigo Chat_ScoutMaxPerDay ili chekaj utre.");
         if (Chat_ScoutVerbose)
            ChatAppend("SCOUT STOP: dneven limit " + IntegerToString(g_chatScoutCallsToday) +
                       "/" + IntegerToString(Chat_ScoutMaxPerDay), clrOrange);
      }
      return;
   }
   g_chatScoutLastFire = now;
   ChatScoutSaveState();
   if (!Chat_CountOnlyAnsweredCalls)
   {
      g_chatScoutCallsToday++;
      ChatScoutSaveState();
   }
   Print("TraceChat SCOUT FIRE attempt, odgovoreni ", g_chatScoutCallsToday, "/", Chat_ScoutMaxPerDay,
         " na ", TimeToString(now, TIME_MINUTES), " (", Chat_ScoutTF, " x", everyBars, " sveki)");
   g_chatStatus = "SCOUT razmisluva... [" + Chat_Mode + "]";
   ChatLayout();
   ChartRedraw();
   ChatPlanRun(false, true);
}

void ChatInit()
{
   g_chatX = Chat_X; g_chatY = Chat_Y;
   string kx = "TraceChatX_" + Symbol();
   string ky = "TraceChatY_" + Symbol();
   if (GlobalVariableCheck(kx)) g_chatX = (int)GlobalVariableGet(kx);
   if (GlobalVariableCheck(ky)) g_chatY = (int)GlobalVariableGet(ky);
   g_chatTextCount = 0; ArrayResize(g_chatText, 0); ArrayResize(g_chatTextColor, 0);
   g_chatConversationCount = 0;
   ArrayResize(g_chatRole, 0); ArrayResize(g_chatMessage, 0);
   g_chatWatchLastSignature = "";
   g_chatWatchLastCall = 0;
   g_chatWatchCallsToday = 0;
   g_chatWatchDay = TimeDay(TimeCurrent());
   g_chatAutoPlanWasClean = false;
   g_chatAutoPlanLastSignature = "";
   ChatAutoPlanLoadState();
   g_chatScoutLastBar = 0;
   g_chatVisionShotBar = 0;
   g_chatVisionAges = "";
   ChatScoutLoadState();
   ChatTriggerLoad();
   g_chatNewsLastRefresh = 0;
   g_chatNewsNextTry = 0;
   g_chatNewsCount = 0;
   g_chatNewsLoaded = false;
   if (Chat_CtxNews) ChatNewsLoadFile();
   g_chatHeadlineNextTry = 0;
   g_chatHeadlineCount = 0;
   g_chatHeadlineLoaded = false;
   g_chatDxyAvailable = false;
   g_chatDxyAgeMin = 0;
   g_chatDxySource = "";
   if (Chat_CtxStats) ChatStatsInit();
   ChatPlansInit();
   ChatWatchLoad();
   g_chatStatus = g_chatWatchActive ? ChatWatchStatus("Ready") : "Ready [" + Chat_Mode + "]";
   if (!LoadChatHistory())
      ChatAppend("AI chat ready.", Chat_TextColor);
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   ChatLayout();
   ChartRedraw();
}

void ChatDeinit()
{
   string p = "TraceChat_";
   for (int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
   {
      string n = ObjectName(0, i, -1, -1);
      if (StringFind(n, p) == 0) ObjectDelete(0, n);
   }
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, false);
   if (g_chatDragging) ChartSetInteger(0, CHART_MOUSE_SCROLL, g_chatMouseScroll);
}

string ChatHistoryFilePath()
{
   return "TraceAI\\chat_history_" + Symbol() + "_" + TimeframeToString(Period()) + ".csv";
}

string ChatPlansFilePath()
{
   return "TraceAI\\chat_plans_" + Symbol() + "_" + TimeframeToString(Period()) + ".csv";
}

void SaveChatHistory()
{
   string path = ChatHistoryFilePath();
   int h = FileOpen(path, FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ, ',');
   if (h == INVALID_HANDLE) return;

   FileWrite(h, "type", "a", "b", "text");
   for (int i = 0; i < g_chatTextCount; i++)
      FileWrite(h, "TEXT", IntegerToString(g_chatTextColor[i]), "", g_chatText[i]);

   for (int j = 0; j < g_chatConversationCount; j++)
      FileWrite(h, "CONV", g_chatRole[j], "", g_chatMessage[j]);

   FileClose(h);
}

bool LoadChatHistory()
{
   string path = ChatHistoryFilePath();
   int h = FileOpen(path, FILE_READ|FILE_CSV|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE, ',');
   if (h == INVALID_HANDLE) return false;

   bool loadedAny = false;
   if (!FileIsEnding(h))
   {
      FileReadString(h);
      FileReadString(h);
      FileReadString(h);
      FileReadString(h);
   }

   while (!FileIsEnding(h))
   {
      string type = FileReadString(h);
      string a    = FileReadString(h);
      string b    = FileReadString(h);
      string text = FileReadString(h);
      if (type == "TEXT")
      {
         ArrayResize(g_chatText, g_chatTextCount + 1);
         ArrayResize(g_chatTextColor, g_chatTextCount + 1);
         g_chatText[g_chatTextCount] = text;
         g_chatTextColor[g_chatTextCount] = (int)StringToInteger(a);
         g_chatTextCount++;
         loadedAny = true;
      }
      else if (type == "CONV")
      {
         ArrayResize(g_chatRole, g_chatConversationCount + 1);
         ArrayResize(g_chatMessage, g_chatConversationCount + 1);
         g_chatRole[g_chatConversationCount] = a;
         g_chatMessage[g_chatConversationCount] = text;
         g_chatConversationCount++;
      }
   }
   FileClose(h);
   return loadedAny;
}

void ChatBuildHistory(string &history)
{
   history = "";
   int first = g_chatConversationCount - 12;
   if (first < 0) first = 0;
   for (int i = first; i < g_chatConversationCount; i++)
   {
      string role = g_chatRole[i];
      string line = g_chatMessage[i];
      if (i > first) history += ",";
      history += "{\"role\":\"" + ChatJsonEscape(role) + "\",\"content\":\"" + ChatJsonEscape(line) + "\"}";
   }
}

void ChatBuildGeminiHistory(string &history)
{
   history = "";
   int first = g_chatConversationCount - 12;
   if (first < 0) first = 0;
   for (int i = first; i < g_chatConversationCount; i++)
   {
      string role = (g_chatRole[i] == "assistant") ? "model" : "user";
      string line = g_chatMessage[i];
      if (i > first) history += ",";
      history += "{\"role\":\"" + role + "\",\"parts\":[{\"text\":\"" + ChatJsonEscape(line) + "\"}]}";
   }
}

void ChatConversationAppend(string role, string text)
{
   ArrayResize(g_chatRole, g_chatConversationCount + 1);
   ArrayResize(g_chatMessage, g_chatConversationCount + 1);
   g_chatRole[g_chatConversationCount] = role;
   g_chatMessage[g_chatConversationCount] = text;
   g_chatConversationCount++;
   while (g_chatConversationCount > 12)
   {
      for (int i = 1; i < g_chatConversationCount; i++)
      {
         g_chatRole[i - 1] = g_chatRole[i];
         g_chatMessage[i - 1] = g_chatMessage[i];
      }
      g_chatConversationCount--;
      ArrayResize(g_chatRole, g_chatConversationCount);
      ArrayResize(g_chatMessage, g_chatConversationCount);
   }
}

string ChatNewsExtractString(string json, string key, int startPos)
{
   string pat = "\"" + key + "\"";
   int objectEnd = StringFind(json, "}", startPos + 1);
   if (objectEnd < 0) return "";
   int keyPos = StringFind(json, pat, startPos);
   if (keyPos < 0 || keyPos >= objectEnd) return "";
   int colon = StringFind(json, ":", keyPos + StringLen(pat));
   if (colon < 0 || colon >= objectEnd) return "";
   int pos = colon + 1;
   while (pos < StringLen(json))
   {
      ushort ws = StringGetChar(json, pos);
      if (ws != 32 && ws != 9 && ws != 10 && ws != 13) break;
      pos++;
   }
   if (pos >= StringLen(json) || StringGetChar(json, pos) != 34) return "";
   pos++;
   string raw = "";
   bool escaped = false;
   for (; pos < objectEnd; pos++)
   {
      ushort ch = StringGetChar(json, pos);
      if (!escaped && ch == 34) break;
      if (!escaped && ch == 92)
      {
         escaped = true;
         raw += "\\";
         continue;
      }
      raw += ShortToString(ch);
      escaped = false;
   }
   return ChatJsonUnescape(raw);
}

bool ChatNewsParseDate(string iso, datetime &brokerTime)
{
   brokerTime = 0;
   if (StringLen(iso) < 16) return false;
   int tpos = StringFind(iso, "T");
   if (tpos < 10) return false;
   string datePart = StringSubstr(iso, 0, tpos);
   string timePart = StringSubstr(iso, tpos + 1, 8);
   if (StringLen(timePart) < 5) return false;
   StringReplace(datePart, "-", ".");
   datetime localIso = StringToTime(datePart + " " + timePart);
   if (localIso <= 0) return false;
   int offsetSign = 1;
   int offsetPos = StringFind(iso, "+", tpos);
   if (offsetPos < 0)
   {
      offsetPos = StringFind(iso, "-", tpos);
      if (offsetPos >= 0) offsetSign = -1;
   }
   int offsetSec = 0;
   if (offsetPos >= 0 && offsetPos + 5 < StringLen(iso))
   {
      int oh = (int)StringToInteger(StringSubstr(iso, offsetPos + 1, 2));
      int om = (int)StringToInteger(StringSubstr(iso, offsetPos + 4, 2));
      offsetSec = offsetSign * (oh * 3600 + om * 60);
   }
   datetime utcTime = localIso - offsetSec;
   int brokerOffset = (int)(TimeCurrent() - TimeGMT());
   brokerTime = utcTime + brokerOffset;
   return true;
}

bool ChatNewsRelevant(string currency)
{
   string cur = currency;
   StringToUpper(cur);
   if (cur == "USD") return true;
   string sym = Symbol();
   StringToUpper(sym);
   if (StringFind(sym, cur) >= 0) return true;
   if (StringFind(sym, "XAU") >= 0 && cur == "USD") return true;
   return false;
}

void ChatNewsParseBody(string body)
{
   g_chatNewsCount = 0;
   int pos = 0;
   while (g_chatNewsCount < CHAT_NEWS_MAX)
   {
      int open = StringFind(body, "{", pos);
      if (open < 0) break;
      int close = StringFind(body, "}", open + 1);
      if (close < 0) break;
      string title = ChatNewsExtractString(body, "title", open);
      string country = ChatNewsExtractString(body, "country", open);
      string impact = ChatNewsExtractString(body, "impact", open);
      string dateText = ChatNewsExtractString(body, "date", open);
      datetime eventTime = 0;
      StringToUpper(impact);
      if ((impact == "HIGH" || impact == "MEDIUM") &&
          ChatNewsRelevant(country) && ChatNewsParseDate(dateText, eventTime))
      {
         g_chatNewsTitle[g_chatNewsCount] = title;
         g_chatNewsCurrency[g_chatNewsCount] = country;
         g_chatNewsImpact[g_chatNewsCount] = impact;
         g_chatNewsTime[g_chatNewsCount] = eventTime;
         g_chatNewsCount++;
      }
      pos = close + 1;
   }
   g_chatNewsLoaded = (g_chatNewsCount > 0);
}

void ChatNewsLoadFile()
{
   string path = "TraceAI\\ff_calendar.json";
   if (!FileIsExist(path)) return;
   int h = FileOpen(path, FILE_READ|FILE_BIN|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if (h == INVALID_HANDLE) return;
   int size = (int)FileSize(h);
   string body = FileReadString(h, size);
   FileClose(h);
   if (StringLen(body) > 0) ChatNewsParseBody(body);
}

void ChatNewsRefresh()
{
   if (!Chat_CtxNews) return;
   datetime now = TimeCurrent();
   int refreshSec = Chat_NewsRefreshMin * 60;
   if (refreshSec < 60) refreshSec = 60;
   if (g_chatNewsNextTry > 0 && now < g_chatNewsNextTry) return;
   g_chatNewsLastRefresh = now;
   string url = "https://nfs.faireconomy.media/ff_calendar_thisweek.json";
   char emptyData[];
   ArrayResize(emptyData, 0);
   char response[];
   string headers = "";
   string responseHeaders = "";
   int rc = WebRequest("GET", url, headers, 5000, emptyData, response, responseHeaders);
   if (rc != 200)
   {
      g_chatNewsNextTry = now + 300;
      if (!g_chatNewsLoaded) ChatNewsLoadFile();
      return;
   }
   string body = CharArrayToString(response, 0, -1, CP_UTF8);
   if (StringLen(body) == 0)
   {
      g_chatNewsNextTry = now + 300;
      if (!g_chatNewsLoaded) ChatNewsLoadFile();
      return;
   }
   int h = FileOpen("TraceAI\\ff_calendar.json", FILE_WRITE|FILE_BIN|FILE_SHARE_READ);
   if (h != INVALID_HANDLE)
   {
      FileWriteString(h, body);
      FileFlush(h);
      FileClose(h);
   }
   ChatNewsParseBody(body);
   g_chatNewsNextTry = now + refreshSec;
}

void ChatHeadlinesParse(string json)
{
   g_chatHeadlineCount = 0;
   g_chatHeadlineLoaded = false;
   g_chatDxyAvailable = false;
   int listStart = StringFind(json, "\"headlines\"");
   if (listStart >= 0)
   {
      int pos = StringFind(json, "[", listStart);
      while (pos >= 0 && g_chatHeadlineCount < CHAT_HEADLINE_MAX)
      {
         int open = StringFind(json, "{", pos + 1);
         int close = (open >= 0) ? StringFind(json, "}", open + 1) : -1;
         if (open < 0 || close < 0) break;
         string title = ChatNewsExtractString(json, "title", open);
         string source = ChatNewsExtractString(json, "src", open);
         string tag = ChatNewsExtractString(json, "tag", open);
         string objectText = StringSubstr(json, open, close - open + 1);
         int age = (int)ChatJsonExtractNum(objectText, "ageMin");
         if (StringLen(title) > 0)
         {
            g_chatHeadlineTitle[g_chatHeadlineCount] = title;
            g_chatHeadlineSource[g_chatHeadlineCount] = source;
            g_chatHeadlineTag[g_chatHeadlineCount] = tag;
            g_chatHeadlineAge[g_chatHeadlineCount] = age;
            g_chatHeadlineCount++;
         }
         pos = close + 1;
         if (StringFind(json, "]", pos) >= 0 &&
             StringFind(json, "{", pos) > StringFind(json, "]", pos)) break;
      }
   }
   int dxyKey = StringFind(json, "\"dxy\"");
   if (dxyKey >= 0)
   {
      int dxyOpen = StringFind(json, "{", dxyKey);
      int dxyClose = (dxyOpen >= 0) ? StringFind(json, "}", dxyOpen + 1) : -1;
      if (dxyOpen >= 0 && dxyClose > dxyOpen)
      {
         string dxyText = StringSubstr(json, dxyOpen, dxyClose - dxyOpen + 1);
         double dxyValue = ChatJsonExtractDouble(dxyText, "value");
         double dxyChange = ChatJsonExtractDouble(dxyText, "change");
         double dxyChangePct = ChatJsonExtractDouble(dxyText, "changePct");
         string dxySource = ChatNewsExtractString(dxyText, "source", 0);
         int dxyAge = (int)ChatJsonExtractNum(dxyText, "ageMin");
         if (dxyValue > 0.0)
         {
            g_chatDxyValue = dxyValue;
            g_chatDxyChange = dxyChange;
            g_chatDxyChangePct = dxyChangePct;
            g_chatDxySource = dxySource;
            g_chatDxyAgeMin = dxyAge;
            g_chatDxyAvailable = true;
         }
      }
   }
   g_chatHeadlineLoaded = (g_chatHeadlineCount > 0 || g_chatDxyAvailable);
}

void ChatHeadlinesRefresh()
{
   if (!Chat_CtxHeadlines) return;
   datetime now = TimeCurrent();
   int refreshSec = Chat_HeadlinesRefreshMin * 60;
   if (refreshSec < 60) refreshSec = 60;
   if (g_chatHeadlineNextTry > 0 && now < g_chatHeadlineNextTry) return;
   string baseUrl = AI_ServerURL;
   int baseLen = StringLen(baseUrl);
   if (baseLen > 0 && StringGetChar(baseUrl, baseLen - 1) == 47)
      baseUrl = StringSubstr(baseUrl, 0, baseLen - 1);
   string url = baseUrl + "/ai/news";
   char emptyData[];
   ArrayResize(emptyData, 0);
   char response[];
   string responseHeaders = "";
   int rc = WebRequest("GET", url, "", 3000, emptyData, response, responseHeaders);
   if (rc != 200)
   {
      g_chatHeadlineCount = 0;
      g_chatDxyAvailable = false;
      g_chatDxyAgeMin = 0;
      g_chatDxySource = "";
      g_chatHeadlineLoaded = false;
      g_chatHeadlineNextTry = now + 300;
      return;
   }
   string body = CharArrayToString(response, 0, -1, CP_UTF8);
   if (StringLen(body) == 0)
   {
      g_chatHeadlineCount = 0;
      g_chatDxyAvailable = false;
      g_chatDxyAgeMin = 0;
      g_chatDxySource = "";
      g_chatHeadlineLoaded = false;
      g_chatHeadlineNextTry = now + 300;
      return;
   }
   ChatHeadlinesParse(body);
   g_chatHeadlineNextTry = now + refreshSec;
}

string ChatCtxHeadlines()
{
   if (!Chat_CtxHeadlines || !g_chatHeadlineLoaded)
      return "\nHEADLINES unavailable (server off)\n";
   string out = "\nHEADLINES raw keyword heuristic only (not analysis): ";
   int limit = g_chatHeadlineCount;
   if (limit > 6) limit = 6;
   for (int hi = 0; hi < limit; hi++)
   {
      if (hi > 0) out += " | ";
      out += IntegerToString(g_chatHeadlineAge[hi]) + "m " + g_chatHeadlineTag[hi] +
             " " + g_chatHeadlineTitle[hi];
   }
   if (g_chatDxyAvailable)
   {
      string dxyChangeText = (g_chatDxySource == "SYNTHETIC")
                             ? "n/a"
                             : DoubleToString(g_chatDxyChange, 2) + " (" +
                               DoubleToString(g_chatDxyChangePct, 2) + "%)";
      out += "\nDXY server=" + DoubleToString(g_chatDxyValue, 2) +
             " source=" + g_chatDxySource + " ageMin=" + IntegerToString(g_chatDxyAgeMin) +
             " dayChg=" + dxyChangeText;
   }
   out += "\n";
   return out;
}

string ChatUsdFindSymbol(string base)
{
   string current = Symbol();
   string upperCurrent = current;
   StringToUpper(upperCurrent);
   string upperBase = base;
   StringToUpper(upperBase);
   string suffix = "";
   if (StringLen(upperCurrent) > 6)
      suffix = StringSubstr(upperCurrent, 6);
   string preferred = upperBase + suffix;
   int totalSymbols = SymbolsTotal(true);
   for (int si = 0; si < totalSymbols; si++)
   {
      string candidate = SymbolName(si, true);
      string upperCandidate = candidate;
      StringToUpper(upperCandidate);
      if (upperCandidate == preferred) return candidate;
   }
   for (int sj = 0; sj < totalSymbols; sj++)
   {
      string candidate2 = SymbolName(sj, true);
      string upperCandidate2 = candidate2;
      StringToUpper(upperCandidate2);
      if (StringFind(upperCandidate2, upperBase, 0) == 0) return candidate2;
   }
   return "";
}

string ChatCtxUsdStrength()
{
   if (!Chat_CtxHeadlines || !Chat_CtxUsdStrength) return "";
   string pairs[6];
   pairs[0] = "EURUSD"; pairs[1] = "GBPUSD"; pairs[2] = "USDJPY";
   pairs[3] = "AUDUSD"; pairs[4] = "USDCAD"; pairs[5] = "USDCHF";
   string out = "\nUSD_STRENGTH_PROXY (not real DXY): ";
   double totalScore = 0.0;
   int available = 0;
   for (int pi = 0; pi < 6; pi++)
   {
      string pairSymbol = ChatUsdFindSymbol(pairs[pi]);
      if (StringLen(pairSymbol) == 0) continue;
      double previousClose = iClose(pairSymbol, PERIOD_D1, 1);
      double currentPrice = MarketInfo(pairSymbol, MODE_BID);
      if (currentPrice <= 0.0) currentPrice = iClose(pairSymbol, PERIOD_D1, 0);
      if (previousClose <= 0.0 || currentPrice <= 0.0) continue;
      double pairChange = (currentPrice - previousClose) * 100.0 / previousClose;
      bool usdQuotedFirst = (StringFind(pairs[pi], "USD", 0) == 0);
      double usdContribution = usdQuotedFirst ? pairChange : -pairChange;
      if (available > 0) out += " ";
      out += pairs[pi] + "=" + DoubleToString(pairChange, 2) + "%";
      totalScore += usdContribution;
      available++;
   }
   if (available <= 0) return "\nUSD_STRENGTH_PROXY unavailable (pairs missing)\n";
   totalScore /= available;
   out += " score=" + DoubleToString(totalScore, 2) + "%";
   out += (totalScore > 0.10) ? " implies USD firm, gold headwind" :
          ((totalScore < -0.10) ? " implies USD weak, gold tailwind" :
           " implies USD mixed, neutral gold effect");
   out += "\n";
   return out;
}

string ChatCtxNews()
{
   if (!Chat_CtxNews || !g_chatNewsLoaded || g_chatNewsCount <= 0)
      return "\nNEWS unavailable\n";
   bool used[CHAT_NEWS_MAX];
   ArrayInitialize(used, false);
   string out = "\nNEWS approximate broker time (UTC offset conversion) ";
   datetime now = TimeCurrent();
   bool blackout = false;
   string blackoutTitle = "";
   int blackoutMin = 0;
   for (int pick = 0; pick < 3; pick++)
   {
      int chosen = -1;
      datetime chosenTime = 0;
      for (int ni = 0; ni < g_chatNewsCount; ni++)
      {
         if (used[ni] || g_chatNewsTime[ni] < now) continue;
         if (chosen < 0 || g_chatNewsTime[ni] < chosenTime)
         {
            chosen = ni;
            chosenTime = g_chatNewsTime[ni];
         }
      }
      if (chosen < 0) break;
      used[chosen] = true;
      int minutes = (int)((g_chatNewsTime[chosen] - now) / 60);
      if (g_chatNewsImpact[chosen] == "HIGH" && minutes <= Chat_NewsWindowMin)
      {
         blackout = true;
         if (StringLen(blackoutTitle) == 0)
         {
            blackoutTitle = g_chatNewsTitle[chosen];
            blackoutMin = minutes;
         }
      }
      out += g_chatNewsImpact[chosen] + ":" + g_chatNewsCurrency[chosen] + ":" +
             g_chatNewsTitle[chosen] + " in " + IntegerToString(minutes) + "m; ";
   }
   if (blackout)
      out += "NEWS_BLACKOUT=YES(" + blackoutTitle + " in " + IntegerToString(blackoutMin) + "min)\n";
   else out += "NEWS_BLACKOUT=NO\n";
   return out;
}

int ChatStatsFindOpen(int ticket)
{
   for (int i = 0; i < ArraySize(g_chatStatsOpenTicket); i++)
      if (g_chatStatsOpenTicket[i] == ticket) return i;
   return -1;
}

int ChatStatsFindRecord(int ticket)
{
   for (int i = 0; i < g_chatStatsRecordCount; i++)
      if (g_chatStatsRecordTicket[i] == ticket) return i;
   return -1;
}

void ChatStatsAddOpen(int ticket)
{
   int n = ArraySize(g_chatStatsOpenTicket);
   ArrayResize(g_chatStatsOpenTicket, n + 1);
   ArrayResize(g_chatStatsOpenGrade, n + 1);
   ArrayResize(g_chatStatsOpenSession, n + 1);
   ArrayResize(g_chatStatsOpenDecision, n + 1);
   ArrayResize(g_chatStatsOpenRegime, n + 1);
   ArrayResize(g_chatStatsOpenTrend, n + 1);
   ArrayResize(g_chatStatsOpenGateDir, n + 1);
   ArrayResize(g_chatStatsOpenConfidence, n + 1);
   ArrayResize(g_chatStatsOpenEntry, n + 1);
   ArrayResize(g_chatStatsOpenSL, n + 1);
   ArrayResize(g_chatStatsOpenTP, n + 1);
   ArrayResize(g_chatStatsOpenTime, n + 1);
   g_chatStatsOpenTicket[n] = ticket;
   g_chatStatsOpenGrade[n] = g_sigCachedGrade;
   string sessionText = GetSessionString();
   int sessionSep = StringFind(sessionText, "|");
   g_chatStatsOpenSession[n] = (sessionSep >= 0) ? StringSubstr(sessionText, 0, sessionSep) : sessionText;
   g_chatStatsOpenDecision[n] = g_aiDecision;
   g_chatStatsOpenRegime[n] = ChatCtxVolatilityTag();
   g_chatStatsOpenTrend[n] = g_sigCachedTrend;
   g_chatStatsOpenGateDir[n] = g_gateDir;
   g_chatStatsOpenConfidence[n] = g_aiConfidence;
   g_chatStatsOpenEntry[n] = OrderOpenPrice();
   g_chatStatsOpenSL[n] = OrderStopLoss();
   g_chatStatsOpenTP[n] = OrderTakeProfit();
   g_chatStatsOpenTime[n] = OrderOpenTime();
   ChatStatsOpenCtxSave();
}

void ChatStatsRemoveOpen(int index)
{
   int n = ArraySize(g_chatStatsOpenTicket);
   if (index < 0 || index >= n) return;
   for (int i = index + 1; i < n; i++)
   {
      g_chatStatsOpenTicket[i - 1] = g_chatStatsOpenTicket[i];
      g_chatStatsOpenGrade[i - 1] = g_chatStatsOpenGrade[i];
      g_chatStatsOpenSession[i - 1] = g_chatStatsOpenSession[i];
      g_chatStatsOpenDecision[i - 1] = g_chatStatsOpenDecision[i];
      g_chatStatsOpenRegime[i - 1] = g_chatStatsOpenRegime[i];
      g_chatStatsOpenTrend[i - 1] = g_chatStatsOpenTrend[i];
      g_chatStatsOpenGateDir[i - 1] = g_chatStatsOpenGateDir[i];
      g_chatStatsOpenConfidence[i - 1] = g_chatStatsOpenConfidence[i];
      g_chatStatsOpenEntry[i - 1] = g_chatStatsOpenEntry[i];
      g_chatStatsOpenSL[i - 1] = g_chatStatsOpenSL[i];
      g_chatStatsOpenTP[i - 1] = g_chatStatsOpenTP[i];
      g_chatStatsOpenTime[i - 1] = g_chatStatsOpenTime[i];
   }
   ArrayResize(g_chatStatsOpenTicket, n - 1);
   ArrayResize(g_chatStatsOpenGrade, n - 1);
   ArrayResize(g_chatStatsOpenSession, n - 1);
   ArrayResize(g_chatStatsOpenDecision, n - 1);
   ArrayResize(g_chatStatsOpenRegime, n - 1);
   ArrayResize(g_chatStatsOpenTrend, n - 1);
   ArrayResize(g_chatStatsOpenGateDir, n - 1);
   ArrayResize(g_chatStatsOpenConfidence, n - 1);
   ArrayResize(g_chatStatsOpenEntry, n - 1);
   ArrayResize(g_chatStatsOpenSL, n - 1);
   ArrayResize(g_chatStatsOpenTP, n - 1);
   ArrayResize(g_chatStatsOpenTime, n - 1);
   ChatStatsOpenCtxSave();
}

void ChatStatsOpenCtxSave()
{
   string path = "TraceAI\\chat_open_ctx.csv";
   int h = FileOpen(path, FILE_WRITE|FILE_CSV|FILE_ANSI, ';');
   if (h == INVALID_HANDLE)
   {
      Print("TraceChat open context save failed err=", GetLastError());
      return;
   }
   FileWrite(h, "ticket", "grade", "session", "decision", "regime",
             "trend", "gateDir", "confidence", "entry", "sl", "tp", "openTime");
   for (int i = 0; i < ArraySize(g_chatStatsOpenTicket); i++)
      FileWrite(h, g_chatStatsOpenTicket[i], g_chatStatsOpenGrade[i],
                g_chatStatsOpenSession[i], g_chatStatsOpenDecision[i],
                g_chatStatsOpenRegime[i], g_chatStatsOpenTrend[i],
                g_chatStatsOpenGateDir[i], g_chatStatsOpenConfidence[i],
                g_chatStatsOpenEntry[i], g_chatStatsOpenSL[i],
                g_chatStatsOpenTP[i], g_chatStatsOpenTime[i]);
   FileFlush(h);
   FileClose(h);
}

void ChatStatsOpenCtxLoad()
{
   static bool loaded = false;
   if (loaded) return;
   loaded = true;
   string path = "TraceAI\\chat_open_ctx.csv";
   int h = FileOpen(path, FILE_READ|FILE_CSV|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE, ';');
   if (h == INVALID_HANDLE) return;
   while (!FileIsEnding(h))
   {
      string ticketText = FileReadString(h);
      string grade = FileReadString(h);
      string session = FileReadString(h);
      string decision = FileReadString(h);
      string regime = FileReadString(h);
      string trendText = FileReadString(h);
      string gateText = FileReadString(h);
      string confidenceText = FileReadString(h);
      string entryText = FileReadString(h);
      string slText = FileReadString(h);
      string tpText = FileReadString(h);
      string openText = FileReadString(h);
      if (ticketText == "ticket" || StringLen(ticketText) == 0) continue;
      int ticket = (int)StringToInteger(ticketText);
      if (ticket <= 0 || ChatStatsFindRecord(ticket) >= 0 ||
          ChatStatsFindOpen(ticket) >= 0) continue;
      int n = ArraySize(g_chatStatsOpenTicket);
      ArrayResize(g_chatStatsOpenTicket, n + 1);
      ArrayResize(g_chatStatsOpenGrade, n + 1);
      ArrayResize(g_chatStatsOpenSession, n + 1);
      ArrayResize(g_chatStatsOpenDecision, n + 1);
      ArrayResize(g_chatStatsOpenRegime, n + 1);
      ArrayResize(g_chatStatsOpenTrend, n + 1);
      ArrayResize(g_chatStatsOpenGateDir, n + 1);
      ArrayResize(g_chatStatsOpenConfidence, n + 1);
      ArrayResize(g_chatStatsOpenEntry, n + 1);
      ArrayResize(g_chatStatsOpenSL, n + 1);
      ArrayResize(g_chatStatsOpenTP, n + 1);
      ArrayResize(g_chatStatsOpenTime, n + 1);
      g_chatStatsOpenTicket[n] = ticket;
      g_chatStatsOpenGrade[n] = grade;
      g_chatStatsOpenSession[n] = session;
      g_chatStatsOpenDecision[n] = decision;
      g_chatStatsOpenRegime[n] = regime;
      g_chatStatsOpenTrend[n] = (int)StringToInteger(trendText);
      g_chatStatsOpenGateDir[n] = (int)StringToInteger(gateText);
      g_chatStatsOpenConfidence[n] = StringToDouble(confidenceText);
      g_chatStatsOpenEntry[n] = StringToDouble(entryText);
      g_chatStatsOpenSL[n] = StringToDouble(slText);
      g_chatStatsOpenTP[n] = StringToDouble(tpText);
      g_chatStatsOpenTime[n] = (datetime)StringToInteger(openText);
   }
   FileClose(h);
}

double ChatStatsR(int type, double entry, double sl, double closePrice)
{
   double risk = (type == OP_BUY) ? entry - sl : sl - entry;
   if (risk <= 0.0) return 0.0;
   return (type == OP_BUY) ? (closePrice - entry) / risk : (entry - closePrice) / risk;
}

void ChatStatsSaveRecord(int ticket, datetime closeTime, double profit, double r,
                         string grade, string session, string decision, string regime,
                         int trend, int direction, int gateDir, double confidence,
                         double entry, double sl, double tp, datetime openTime, bool unknown)
{
   if (ChatStatsFindRecord(ticket) >= 0) return;
   int n = g_chatStatsRecordCount;
   ArrayResize(g_chatStatsRecordTicket, n + 1);
   ArrayResize(g_chatStatsRecordCloseTime, n + 1);
   ArrayResize(g_chatStatsRecordProfit, n + 1);
   ArrayResize(g_chatStatsRecordR, n + 1);
   ArrayResize(g_chatStatsRecordGrade, n + 1);
   ArrayResize(g_chatStatsRecordSession, n + 1);
   ArrayResize(g_chatStatsRecordDecision, n + 1);
   ArrayResize(g_chatStatsRecordRegime, n + 1);
   ArrayResize(g_chatStatsRecordTrend, n + 1);
   ArrayResize(g_chatStatsRecordDirection, n + 1);
   ArrayResize(g_chatStatsRecordGateDir, n + 1);
   ArrayResize(g_chatStatsRecordConfidence, n + 1);
   ArrayResize(g_chatStatsRecordEntry, n + 1);
   ArrayResize(g_chatStatsRecordSL, n + 1);
   ArrayResize(g_chatStatsRecordTP, n + 1);
   ArrayResize(g_chatStatsRecordOpenTime, n + 1);
   ArrayResize(g_chatStatsRecordUnknown, n + 1);
   g_chatStatsRecordTicket[n] = ticket;
   g_chatStatsRecordCloseTime[n] = closeTime;
   g_chatStatsRecordProfit[n] = profit;
   g_chatStatsRecordR[n] = r;
   g_chatStatsRecordGrade[n] = grade;
   g_chatStatsRecordSession[n] = session;
   g_chatStatsRecordDecision[n] = decision;
   g_chatStatsRecordRegime[n] = regime;
   g_chatStatsRecordTrend[n] = trend;
   g_chatStatsRecordDirection[n] = direction;
   g_chatStatsRecordGateDir[n] = gateDir;
   g_chatStatsRecordConfidence[n] = confidence;
   g_chatStatsRecordEntry[n] = entry;
   g_chatStatsRecordSL[n] = sl;
   g_chatStatsRecordTP[n] = tp;
   g_chatStatsRecordOpenTime[n] = openTime;
   g_chatStatsRecordUnknown[n] = unknown;
   g_chatStatsRecordCount++;
   while (g_chatStatsRecordCount > Chat_StatsMaxRecords)
   {
      for (int si = 1; si < g_chatStatsRecordCount; si++)
      {
         g_chatStatsRecordTicket[si - 1] = g_chatStatsRecordTicket[si];
         g_chatStatsRecordCloseTime[si - 1] = g_chatStatsRecordCloseTime[si];
         g_chatStatsRecordProfit[si - 1] = g_chatStatsRecordProfit[si];
         g_chatStatsRecordR[si - 1] = g_chatStatsRecordR[si];
         g_chatStatsRecordGrade[si - 1] = g_chatStatsRecordGrade[si];
         g_chatStatsRecordSession[si - 1] = g_chatStatsRecordSession[si];
         g_chatStatsRecordDecision[si - 1] = g_chatStatsRecordDecision[si];
         g_chatStatsRecordRegime[si - 1] = g_chatStatsRecordRegime[si];
         g_chatStatsRecordTrend[si - 1] = g_chatStatsRecordTrend[si];
         g_chatStatsRecordDirection[si - 1] = g_chatStatsRecordDirection[si];
         g_chatStatsRecordGateDir[si - 1] = g_chatStatsRecordGateDir[si];
         g_chatStatsRecordConfidence[si - 1] = g_chatStatsRecordConfidence[si];
         g_chatStatsRecordEntry[si - 1] = g_chatStatsRecordEntry[si];
         g_chatStatsRecordSL[si - 1] = g_chatStatsRecordSL[si];
         g_chatStatsRecordTP[si - 1] = g_chatStatsRecordTP[si];
         g_chatStatsRecordOpenTime[si - 1] = g_chatStatsRecordOpenTime[si];
         g_chatStatsRecordUnknown[si - 1] = g_chatStatsRecordUnknown[si];
      }
      g_chatStatsRecordCount--;
      ArrayResize(g_chatStatsRecordTicket, g_chatStatsRecordCount);
      ArrayResize(g_chatStatsRecordCloseTime, g_chatStatsRecordCount);
      ArrayResize(g_chatStatsRecordProfit, g_chatStatsRecordCount);
      ArrayResize(g_chatStatsRecordR, g_chatStatsRecordCount);
      ArrayResize(g_chatStatsRecordGrade, g_chatStatsRecordCount);
      ArrayResize(g_chatStatsRecordSession, g_chatStatsRecordCount);
      ArrayResize(g_chatStatsRecordDecision, g_chatStatsRecordCount);
      ArrayResize(g_chatStatsRecordRegime, g_chatStatsRecordCount);
      ArrayResize(g_chatStatsRecordTrend, g_chatStatsRecordCount);
      ArrayResize(g_chatStatsRecordDirection, g_chatStatsRecordCount);
      ArrayResize(g_chatStatsRecordGateDir, g_chatStatsRecordCount);
      ArrayResize(g_chatStatsRecordConfidence, g_chatStatsRecordCount);
      ArrayResize(g_chatStatsRecordEntry, g_chatStatsRecordCount);
      ArrayResize(g_chatStatsRecordSL, g_chatStatsRecordCount);
      ArrayResize(g_chatStatsRecordTP, g_chatStatsRecordCount);
      ArrayResize(g_chatStatsRecordOpenTime, g_chatStatsRecordCount);
      ArrayResize(g_chatStatsRecordUnknown, g_chatStatsRecordCount);
   }
   bool exists = FileIsExist("TraceAI\\chat_stats.csv");
   int h = FileOpen("TraceAI\\chat_stats.csv", FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ);
   if (h == INVALID_HANDLE) return;
   if (!exists || FileSize(h) == 0)
      FileWrite(h, "ticket", "closeTime", "profit", "R", "grade", "session", "decision",
                "regime", "trend", "direction", "gateDir", "confidence", "entry", "sl",
                "tp", "openTime", "unknown");
   FileSeek(h, 0, SEEK_END);
   FileWrite(h, ticket, (int)closeTime, DoubleToString(profit, 2), DoubleToString(r, 4),
             grade, session, decision, regime, trend, direction, gateDir,
             DoubleToString(confidence, 3), DoubleToString(entry, Digits),
             DoubleToString(sl, Digits), DoubleToString(tp, Digits), (int)openTime,
             unknown ? 1 : 0);
   FileClose(h);
}

void ChatStatsLoad()
{
   g_chatStatsRecordCount = 0;
   ArrayResize(g_chatStatsRecordTicket, 0);
   ArrayResize(g_chatStatsRecordCloseTime, 0);
   ArrayResize(g_chatStatsRecordProfit, 0);
   ArrayResize(g_chatStatsRecordR, 0);
   ArrayResize(g_chatStatsRecordGrade, 0);
   ArrayResize(g_chatStatsRecordSession, 0);
   ArrayResize(g_chatStatsRecordDecision, 0);
   ArrayResize(g_chatStatsRecordRegime, 0);
   ArrayResize(g_chatStatsRecordTrend, 0);
   ArrayResize(g_chatStatsRecordDirection, 0);
   ArrayResize(g_chatStatsRecordGateDir, 0);
   ArrayResize(g_chatStatsRecordConfidence, 0);
   ArrayResize(g_chatStatsRecordEntry, 0);
   ArrayResize(g_chatStatsRecordSL, 0);
   ArrayResize(g_chatStatsRecordTP, 0);
   ArrayResize(g_chatStatsRecordOpenTime, 0);
   ArrayResize(g_chatStatsRecordUnknown, 0);
   int h = FileOpen("TraceAI\\chat_stats.csv", FILE_READ|FILE_CSV|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if (h == INVALID_HANDLE) return;
   while (!FileIsEnding(h))
   {
      string ticketText = FileReadString(h);
      string closeText = FileReadString(h);
      string profitText = FileReadString(h);
      string rText = FileReadString(h);
      string grade = FileReadString(h);
      string session = FileReadString(h);
      string decision = FileReadString(h);
      string regime = FileReadString(h);
      string trendText = FileReadString(h);
      string directionText = FileReadString(h);
      string gateText = FileReadString(h);
      string confidenceText = FileReadString(h);
      string entryText = FileReadString(h);
      string slText = FileReadString(h);
      string tpText = FileReadString(h);
      string openText = FileReadString(h);
      string unknownText = FileReadString(h);
      if (ticketText == "ticket" || StringLen(ticketText) == 0) continue;
      int ticket = (int)StringToInteger(ticketText);
      if (ticket <= 0) continue;
      datetime statsCut = ChatStatsCutoffTime();
      datetime closeTime = (datetime)StringToInteger(closeText);
      if (statsCut > 0 && closeTime < statsCut) continue;
      int n = g_chatStatsRecordCount;
      ArrayResize(g_chatStatsRecordTicket, n + 1);
      ArrayResize(g_chatStatsRecordCloseTime, n + 1);
      ArrayResize(g_chatStatsRecordProfit, n + 1);
      ArrayResize(g_chatStatsRecordR, n + 1);
      ArrayResize(g_chatStatsRecordGrade, n + 1);
      ArrayResize(g_chatStatsRecordSession, n + 1);
      ArrayResize(g_chatStatsRecordDecision, n + 1);
      ArrayResize(g_chatStatsRecordRegime, n + 1);
      ArrayResize(g_chatStatsRecordTrend, n + 1);
      ArrayResize(g_chatStatsRecordDirection, n + 1);
      ArrayResize(g_chatStatsRecordGateDir, n + 1);
      ArrayResize(g_chatStatsRecordConfidence, n + 1);
      ArrayResize(g_chatStatsRecordEntry, n + 1);
      ArrayResize(g_chatStatsRecordSL, n + 1);
      ArrayResize(g_chatStatsRecordTP, n + 1);
      ArrayResize(g_chatStatsRecordOpenTime, n + 1);
      ArrayResize(g_chatStatsRecordUnknown, n + 1);
      g_chatStatsRecordTicket[n] = ticket;
      g_chatStatsRecordCloseTime[n] = closeTime;
      g_chatStatsRecordProfit[n] = StringToDouble(profitText);
      g_chatStatsRecordR[n] = StringToDouble(rText);
      g_chatStatsRecordGrade[n] = grade;
      g_chatStatsRecordSession[n] = session;
      g_chatStatsRecordDecision[n] = decision;
      g_chatStatsRecordRegime[n] = regime;
      g_chatStatsRecordTrend[n] = (int)StringToInteger(trendText);
      g_chatStatsRecordDirection[n] = (int)StringToInteger(directionText);
      g_chatStatsRecordGateDir[n] = (int)StringToInteger(gateText);
      g_chatStatsRecordConfidence[n] = StringToDouble(confidenceText);
      g_chatStatsRecordEntry[n] = StringToDouble(entryText);
      g_chatStatsRecordSL[n] = StringToDouble(slText);
      g_chatStatsRecordTP[n] = StringToDouble(tpText);
      g_chatStatsRecordOpenTime[n] = (datetime)StringToInteger(openText);
      g_chatStatsRecordUnknown[n] = (StringToInteger(unknownText) != 0);
      g_chatStatsRecordCount++;
      while (g_chatStatsRecordCount > Chat_StatsMaxRecords)
      {
         for (int li = 1; li < g_chatStatsRecordCount; li++)
         {
            g_chatStatsRecordTicket[li - 1] = g_chatStatsRecordTicket[li];
            g_chatStatsRecordCloseTime[li - 1] = g_chatStatsRecordCloseTime[li];
            g_chatStatsRecordProfit[li - 1] = g_chatStatsRecordProfit[li];
            g_chatStatsRecordR[li - 1] = g_chatStatsRecordR[li];
            g_chatStatsRecordGrade[li - 1] = g_chatStatsRecordGrade[li];
            g_chatStatsRecordSession[li - 1] = g_chatStatsRecordSession[li];
            g_chatStatsRecordDecision[li - 1] = g_chatStatsRecordDecision[li];
            g_chatStatsRecordRegime[li - 1] = g_chatStatsRecordRegime[li];
            g_chatStatsRecordTrend[li - 1] = g_chatStatsRecordTrend[li];
            g_chatStatsRecordDirection[li - 1] = g_chatStatsRecordDirection[li];
            g_chatStatsRecordGateDir[li - 1] = g_chatStatsRecordGateDir[li];
            g_chatStatsRecordConfidence[li - 1] = g_chatStatsRecordConfidence[li];
            g_chatStatsRecordEntry[li - 1] = g_chatStatsRecordEntry[li];
            g_chatStatsRecordSL[li - 1] = g_chatStatsRecordSL[li];
            g_chatStatsRecordTP[li - 1] = g_chatStatsRecordTP[li];
            g_chatStatsRecordOpenTime[li - 1] = g_chatStatsRecordOpenTime[li];
            g_chatStatsRecordUnknown[li - 1] = g_chatStatsRecordUnknown[li];
         }
         g_chatStatsRecordCount--;
         ArrayResize(g_chatStatsRecordTicket, g_chatStatsRecordCount);
         ArrayResize(g_chatStatsRecordCloseTime, g_chatStatsRecordCount);
         ArrayResize(g_chatStatsRecordProfit, g_chatStatsRecordCount);
         ArrayResize(g_chatStatsRecordR, g_chatStatsRecordCount);
         ArrayResize(g_chatStatsRecordGrade, g_chatStatsRecordCount);
         ArrayResize(g_chatStatsRecordSession, g_chatStatsRecordCount);
         ArrayResize(g_chatStatsRecordDecision, g_chatStatsRecordCount);
         ArrayResize(g_chatStatsRecordRegime, g_chatStatsRecordCount);
         ArrayResize(g_chatStatsRecordTrend, g_chatStatsRecordCount);
         ArrayResize(g_chatStatsRecordDirection, g_chatStatsRecordCount);
         ArrayResize(g_chatStatsRecordGateDir, g_chatStatsRecordCount);
         ArrayResize(g_chatStatsRecordConfidence, g_chatStatsRecordCount);
         ArrayResize(g_chatStatsRecordEntry, g_chatStatsRecordCount);
         ArrayResize(g_chatStatsRecordSL, g_chatStatsRecordCount);
         ArrayResize(g_chatStatsRecordTP, g_chatStatsRecordCount);
         ArrayResize(g_chatStatsRecordOpenTime, g_chatStatsRecordCount);
         ArrayResize(g_chatStatsRecordUnknown, g_chatStatsRecordCount);
      }
   }
   FileClose(h);
}

void ChatStatsBackfill()
{
   ChatStatsOpenCtxLoad();
   for (int i = 0; i < OrdersHistoryTotal(); i++)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic_Number) continue;
      int type = OrderType();
      if (type != OP_BUY && type != OP_SELL) continue;
      datetime statsCut = ChatStatsCutoffTime();
      if (statsCut > 0 && OrderCloseTime() > 0 && OrderCloseTime() < statsCut) continue;
      int ticket = OrderTicket();
      if (ChatStatsFindRecord(ticket) >= 0) continue;
      double r = ChatStatsR(type, OrderOpenPrice(), OrderStopLoss(), OrderClosePrice());
      int openIndex = ChatStatsFindOpen(ticket);
      if (openIndex >= 0)
      {
         r = ChatStatsR(type, g_chatStatsOpenEntry[openIndex],
                        g_chatStatsOpenSL[openIndex], OrderClosePrice());
         ChatStatsSaveRecord(ticket, OrderCloseTime(), OrderProfit(), r,
                             g_chatStatsOpenGrade[openIndex],
                             g_chatStatsOpenSession[openIndex],
                             g_chatStatsOpenDecision[openIndex],
                             g_chatStatsOpenRegime[openIndex],
                             g_chatStatsOpenTrend[openIndex], type,
                             g_chatStatsOpenGateDir[openIndex],
                             g_chatStatsOpenConfidence[openIndex],
                             g_chatStatsOpenEntry[openIndex],
                             g_chatStatsOpenSL[openIndex],
                             g_chatStatsOpenTP[openIndex],
                             g_chatStatsOpenTime[openIndex], false);
         ChatStatsRemoveOpen(openIndex);
      }
      else
      {
         ChatStatsSaveRecord(ticket, OrderCloseTime(), OrderProfit(), r,
                             "UNKNOWN", "UNKNOWN", "UNKNOWN", "UNKNOWN",
                             0, type, 0, 0.0, OrderOpenPrice(),
                             OrderStopLoss(), OrderTakeProfit(),
                             OrderOpenTime(), true);
      }
   }
}

void ChatStatsUpdate()
{
   if (!Chat_CtxStats || !Chat_Enable || IsTesting() || IsOptimization()) return;
   for (int oi = 0; oi < OrdersTotal(); oi++)
   {
      if (!OrderSelect(oi, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Magic_Number) continue;
      int type = OrderType();
      if (type != OP_BUY && type != OP_SELL) continue;
      if (ChatStatsFindOpen(OrderTicket()) < 0) ChatStatsAddOpen(OrderTicket());
   }
   for (int si = ArraySize(g_chatStatsOpenTicket) - 1; si >= 0; si--)
   {
      int ticket = g_chatStatsOpenTicket[si];
      bool stillOpen = false;
      for (int oi2 = 0; oi2 < OrdersTotal(); oi2++)
      {
         if (!OrderSelect(oi2, SELECT_BY_POS, MODE_TRADES)) continue;
         if (OrderTicket() == ticket) { stillOpen = true; break; }
      }
      if (stillOpen)
      {
         g_chatStatsOpenTP[si] = OrderTakeProfit();
         continue;
      }
      bool foundHistory = false;
      for (int hi = 0; hi < OrdersHistoryTotal(); hi++)
      {
         if (!OrderSelect(hi, SELECT_BY_POS, MODE_HISTORY) || OrderTicket() != ticket) continue;
         int htype = OrderType();
         if (htype != OP_BUY && htype != OP_SELL) break;
         double rr = ChatStatsR(htype, g_chatStatsOpenEntry[si], g_chatStatsOpenSL[si], OrderClosePrice());
         ChatStatsSaveRecord(ticket, OrderCloseTime(), OrderProfit(), rr,
                             g_chatStatsOpenGrade[si], g_chatStatsOpenSession[si],
                             g_chatStatsOpenDecision[si], g_chatStatsOpenRegime[si],
                             g_chatStatsOpenTrend[si], (htype == OP_BUY) ? OP_BUY : OP_SELL,
                             g_chatStatsOpenGateDir[si], g_chatStatsOpenConfidence[si],
                             g_chatStatsOpenEntry[si], g_chatStatsOpenSL[si],
                             g_chatStatsOpenTP[si], g_chatStatsOpenTime[si], false);
         foundHistory = true;
         break;
      }
      if (foundHistory) ChatStatsRemoveOpen(si);
   }
}

string ChatStatsBreakdown(string field)
{
   string names[];
   int counts[];
   int wins[];
   ArrayResize(names, 0); ArrayResize(counts, 0); ArrayResize(wins, 0);
   for (int i = 0; i < g_chatStatsRecordCount; i++)
   {
      if (g_chatStatsRecordUnknown[i]) continue;
      string name = "";
      if (field == "grade") name = g_chatStatsRecordGrade[i];
      else if (field == "session") name = g_chatStatsRecordSession[i];
      else name = (g_chatStatsRecordDirection[i] == OP_BUY) ? "BUY" : "SELL";
      int found = -1;
      for (int ni = 0; ni < ArraySize(names); ni++)
         if (names[ni] == name) { found = ni; break; }
      if (found < 0)
      {
         found = ArraySize(names);
         ArrayResize(names, found + 1); ArrayResize(counts, found + 1); ArrayResize(wins, found + 1);
         names[found] = name; counts[found] = 0; wins[found] = 0;
      }
      counts[found]++;
      if (g_chatStatsRecordR[i] > 0.0) wins[found]++;
   }
   string out = "";
   for (int oi = 0; oi < ArraySize(names); oi++)
      out += names[oi] + "=" + IntegerToString(counts[oi]) + "/" +
             IntegerToString(wins[oi]) + " ";
   return out;
}

void ChatStatsInit()
{
   ArrayResize(g_chatStatsOpenTicket, 0);
   ArrayResize(g_chatStatsOpenGrade, 0);
   ArrayResize(g_chatStatsOpenSession, 0);
   ArrayResize(g_chatStatsOpenDecision, 0);
   ArrayResize(g_chatStatsOpenRegime, 0);
   ArrayResize(g_chatStatsOpenTrend, 0);
   ArrayResize(g_chatStatsOpenGateDir, 0);
   ArrayResize(g_chatStatsOpenConfidence, 0);
   ArrayResize(g_chatStatsOpenEntry, 0);
   ArrayResize(g_chatStatsOpenSL, 0);
   ArrayResize(g_chatStatsOpenTP, 0);
   ArrayResize(g_chatStatsOpenTime, 0);
   ChatStatsLoad();
   ChatStatsOpenCtxLoad();
   ChatStatsBackfill();
   ChatStatsUpdate();
}

string ChatCtxStats()
{
   if (!Chat_CtxStats || g_chatStatsRecordCount <= 0) return "\nSTATS no realized trades\n";
   int wins = 0;
   double sumR = 0.0, grossWin = 0.0, grossLoss = 0.0, best = -1.0e100, worst = 1.0e100;
   for (int i = 0; i < g_chatStatsRecordCount; i++)
   {
      double rr = g_chatStatsRecordR[i];
      if (rr > 0.0) { wins++; grossWin += g_chatStatsRecordProfit[i]; }
      if (rr < 0.0) grossLoss += MathAbs(g_chatStatsRecordProfit[i]);
      sumR += rr;
      if (rr > best) best = rr;
      if (rr < worst) worst = rr;
   }
   double pf = (grossLoss > 0.0) ? grossWin / grossLoss : 0.0;
   string out = "\nSTATS n=" + IntegerToString(g_chatStatsRecordCount) +
                " win=" + DoubleToString(100.0 * wins / g_chatStatsRecordCount, 1) +
                "% avgR=" + DoubleToString(sumR / g_chatStatsRecordCount, 2) +
                " PF=" + DoubleToString(pf, 2) + " best/worst=" +
                DoubleToString(best, 2) + "/" + DoubleToString(worst, 2);
   out += " grade{" + ChatStatsBreakdown("grade") + "} session{" +
          ChatStatsBreakdown("session") + "} dir{" + ChatStatsBreakdown("direction") + "}";
   out += " last=";
   int first = g_chatStatsRecordCount - 10;
   if (first < 0) first = 0;
   for (int li = g_chatStatsRecordCount - 1; li >= first; li--)
      out += DoubleToString(g_chatStatsRecordR[li], 2) + ",";
   if (StringLen(out) > 700) out = StringSubstr(out, 0, 700);
   return out + "\n";
}

string ChatCtxLevels()
{
   double px = (Bid + Ask) * 0.5;
   double dayHi = iHigh(Symbol(), PERIOD_D1, 1);
   double dayLo = iLow(Symbol(), PERIOD_D1, 1);
   double dayCl = iClose(Symbol(), PERIOD_D1, 1);
   double dayOpen = iOpen(Symbol(), PERIOD_D1, 0);
   double weekHi = iHigh(Symbol(), PERIOD_W1, 1);
   double weekLo = iLow(Symbol(), PERIOD_W1, 1);
   double weekOpen = iOpen(Symbol(), PERIOD_W1, 0);
   string out = "\nLEVELS prevD_HL_C=" + DoubleToString(dayHi, Digits) + "/" +
                DoubleToString(dayLo, Digits) + "/" + DoubleToString(dayCl, Digits) +
                " todayOpen=" + DoubleToString(dayOpen, Digits) +
                " prevW_HL=" + DoubleToString(weekHi, Digits) + "/" +
                DoubleToString(weekLo, Digits) + " weekOpen=" +
                DoubleToString(weekOpen, Digits);
   datetime dayStart = iTime(Symbol(), PERIOD_D1, 0);
   datetime rangeBar = iTime(Symbol(), PERIOD_M1, 0);
   if (rangeBar != g_chatCtxRangeBar || dayStart != g_chatCtxRangeDay)
   {
      g_chatCtxAsiaHi = 0.0; g_chatCtxAsiaLo = 0.0;
      g_chatCtxLondonHi = 0.0; g_chatCtxLondonLo = 0.0;
      g_chatCtxNyHi = 0.0; g_chatCtxNyLo = 0.0;
      g_chatCtxAsiaOk = false; g_chatCtxLondonOk = false; g_chatCtxNyOk = false;
      int dshift = iBarShift(Symbol(), PERIOD_M1, dayStart, false);
      for (int ri = dshift; ri >= 0; ri--)
      {
         datetime bt = iTime(Symbol(), PERIOD_M1, ri);
         if (bt < dayStart) break;
         int hr = TimeHour(bt);
         double bh = iHigh(Symbol(), PERIOD_M1, ri);
         double bl = iLow(Symbol(), PERIOD_M1, ri);
         if (hr >= Chat_AsiaStartHour && hr < Chat_AsiaEndHour)
         {
            if (!g_chatCtxAsiaOk || bh > g_chatCtxAsiaHi) g_chatCtxAsiaHi = bh;
            if (!g_chatCtxAsiaOk || bl < g_chatCtxAsiaLo) g_chatCtxAsiaLo = bl;
            g_chatCtxAsiaOk = true;
         }
         if (hr >= London_StartHour && hr < London_EndHour)
         {
            if (!g_chatCtxLondonOk || bh > g_chatCtxLondonHi) g_chatCtxLondonHi = bh;
            if (!g_chatCtxLondonOk || bl < g_chatCtxLondonLo) g_chatCtxLondonLo = bl;
            g_chatCtxLondonOk = true;
         }
         if (hr >= NY_StartHour && hr < NY_EndHour)
         {
            if (!g_chatCtxNyOk || bh > g_chatCtxNyHi) g_chatCtxNyHi = bh;
            if (!g_chatCtxNyOk || bl < g_chatCtxNyLo) g_chatCtxNyLo = bl;
            g_chatCtxNyOk = true;
         }
      }
      g_chatCtxRangeBar = rangeBar;
      g_chatCtxRangeDay = dayStart;
   }
   string asiaState = !g_chatCtxAsiaOk ? "NA" : (px > g_chatCtxAsiaHi ? "ABOVE" :
                      (px < g_chatCtxAsiaLo ? "BELOW" : "INSIDE"));
   out += " Asia=" + (g_chatCtxAsiaOk ? DoubleToString(g_chatCtxAsiaHi, Digits) + "/" +
          DoubleToString(g_chatCtxAsiaLo, Digits) + " dPts=" +
          DoubleToString(MathAbs(px - g_chatCtxAsiaHi) / Point, 0) + "/" +
          DoubleToString(MathAbs(px - g_chatCtxAsiaLo) / Point, 0) : "NA") + "(" + asiaState + ")";
   out += " London=" + (g_chatCtxLondonOk ? DoubleToString(g_chatCtxLondonHi, Digits) + "/" +
          DoubleToString(g_chatCtxLondonLo, Digits) + " dPts=" +
          DoubleToString(MathAbs(px - g_chatCtxLondonHi) / Point, 0) + "/" +
          DoubleToString(MathAbs(px - g_chatCtxLondonLo) / Point, 0) : "NA");
   out += " NY=" + (g_chatCtxNyOk ? DoubleToString(g_chatCtxNyHi, Digits) + "/" +
          DoubleToString(g_chatCtxNyLo, Digits) + " dPts=" +
          DoubleToString(MathAbs(px - g_chatCtxNyHi) / Point, 0) + "/" +
          DoubleToString(MathAbs(px - g_chatCtxNyLo) / Point, 0) : "NA");
   double pp = (dayHi + dayLo + dayCl) / 3.0;
   double r1 = 2.0 * pp - dayLo, s1 = 2.0 * pp - dayHi;
   double r2 = pp + dayHi - dayLo, s2 = pp - dayHi + dayLo;
   double r3 = dayHi + 2.0 * (pp - dayLo), s3 = dayLo - 2.0 * (dayHi - pp);
   out += " pivots=PP/R1/R2/R3=" + DoubleToString(pp, Digits) + "/" +
          DoubleToString(r1, Digits) + "/" + DoubleToString(r2, Digits) + "/" +
          DoubleToString(r3, Digits) + " S1/S2/S3=" + DoubleToString(s1, Digits) +
          "/" + DoubleToString(s2, Digits) + "/" + DoubleToString(s3, Digits);
   double step = Chat_RoundStep;
   if (step <= 0.0)
      step = (Digits <= 2) ? 10.0 : ((Digits >= 4) ? 0.0100 : 1.0);
   double below = MathFloor(px / step) * step;
   double above = below + step;
   out += " roundBelow/Above=" + DoubleToString(below, Digits) + "/" + DoubleToString(above, Digits);
   out += " distPts(DH/DL/DC/DO/WH/WL/WO/PP/R1/S1)=" +
          DoubleToString(MathAbs(px - dayHi) / Point, 0) + "/" +
          DoubleToString(MathAbs(px - dayLo) / Point, 0) + "/" +
          DoubleToString(MathAbs(px - dayCl) / Point, 0) + "/" +
          DoubleToString(MathAbs(px - dayOpen) / Point, 0) + "/" +
          DoubleToString(MathAbs(px - weekHi) / Point, 0) + "/" +
          DoubleToString(MathAbs(px - weekLo) / Point, 0) + "/" +
          DoubleToString(MathAbs(px - weekOpen) / Point, 0) + "/" +
          DoubleToString(MathAbs(px - pp) / Point, 0) + "/" +
          DoubleToString(MathAbs(px - r1) / Point, 0) + "/" +
          DoubleToString(MathAbs(px - s1) / Point, 0);
   double dlHigh = 0.0, dlLow = 0.0, dlMid = 0.0;
   double dlLowMid = 0.0, dlMidHigh = 0.0;
   if (DailyLevelsGet(dlHigh, dlLow, dlMid, dlLowMid, dlMidHigh))
   {
      string dlZone = (px > dlHigh) ? "ABOVE High" :
                      (px < dlLow) ? "BELOW Low" :
                      (px >= dlMidHigh) ? "MidHigh..High" :
                      (px >= dlMid) ? "Mid..MidHigh" :
                      (px >= dlLowMid) ? "LowMid..Mid" : "Low..LowMid";
      out += " daily=H/MH/M/LM/L=" + DoubleToString(dlHigh, Digits) + "/" +
             DoubleToString(dlMidHigh, Digits) + "/" +
             DoubleToString(dlMid, Digits) + "/" +
             DoubleToString(dlLowMid, Digits) + "/" +
             DoubleToString(dlLow, Digits) + " dPts=" +
             DoubleToString(MathAbs(px - dlHigh) / Point, 0) + "/" +
             DoubleToString(MathAbs(px - dlMidHigh) / Point, 0) + "/" +
             DoubleToString(MathAbs(px - dlMid) / Point, 0) + "/" +
             DoubleToString(MathAbs(px - dlLowMid) / Point, 0) + "/" +
             DoubleToString(MathAbs(px - dlLow) / Point, 0) + " zone=" + dlZone +
             " rangePts=" + DoubleToString((dlHigh - dlLow) / Point, 0);
   }
   return out + "\n";
}

string ChatCtxVolatility()
{
   double adr5 = 0.0, adr10 = 0.0, adr20 = 0.0;
   for (int i = 1; i <= 20; i++)
   {
      double range = iHigh(Symbol(), PERIOD_D1, i) - iLow(Symbol(), PERIOD_D1, i);
      if (i <= 5) adr5 += range;
      if (i <= 10) adr10 += range;
      adr20 += range;
   }
   adr5 /= 5.0; adr10 /= 10.0; adr20 /= 20.0;
   double todayRange = iHigh(Symbol(), PERIOD_D1, 0) - iLow(Symbol(), PERIOD_D1, 0);
   double adrPct = (adr10 > 0.0) ? 100.0 * todayRange / adr10 : 0.0;
   int chartTf = Period();
   double atrNow = iATR(Symbol(), chartTf, 14, 1);
   int bars = iBars(Symbol(), chartTf);
   int look = (bars > 102) ? 100 : bars - 2;
   int atrCount = 0, atrBelow = 0;
   for (int i = 1; i <= look; i++)
   {
      double av = iATR(Symbol(), chartTf, 14, i);
      if (av > 0.0) { atrCount++; if (av <= atrNow) atrBelow++; }
   }
   double atrPctRank = (atrCount > 0) ? 100.0 * atrBelow / atrCount : 0.0;
   double currentSpread = (Ask - Bid);
   double avgRange = 0.0;
   int m1Count = 0;
   for (int j = 1; j <= 60 && j < iBars(Symbol(), PERIOD_M1); j++)
   {
      avgRange += iHigh(Symbol(), PERIOD_M1, j) - iLow(Symbol(), PERIOD_M1, j);
      m1Count++;
   }
   if (m1Count > 0) avgRange /= m1Count;
   string regime = ChatCtxVolatilityTag();
   return "\nVOLATILITY ADR5/10/20=" + DoubleToString(adr5, Digits) + "/" +
          DoubleToString(adr10, Digits) + "/" + DoubleToString(adr20, Digits) +
          " todayRange=" + DoubleToString(todayRange, Digits) + " ADR10pct=" +
          DoubleToString(adrPct, 1) + " ATR14=" + DoubleToString(atrNow, Digits) +
          " ATRrank100=" + DoubleToString(atrPctRank, 1) + " spread=" +
          DoubleToString(currentSpread / Point, 1) + " avgM1RangeProxy=" +
          DoubleToString(avgRange / Point, 1) + " regime=" + regime + "\n";
}

string ChatCtxVolatilityTag()
{
   double adr10 = 0.0;
   for (int di = 1; di <= 10; di++)
      adr10 += iHigh(Symbol(), PERIOD_D1, di) - iLow(Symbol(), PERIOD_D1, di);
   adr10 /= 10.0;
   double todayRange = iHigh(Symbol(), PERIOD_D1, 0) - iLow(Symbol(), PERIOD_D1, 0);
   double adrPct = (adr10 > 0.0) ? 100.0 * todayRange / adr10 : 0.0;
   double currentAtr = iATR(Symbol(), Period(), 14, 1);
   int bars = iBars(Symbol(), Period());
   int look = (bars > 102) ? 100 : bars - 2;
   int count = 0, below = 0;
   for (int ai = 1; ai <= look; ai++)
   {
      double av = iATR(Symbol(), Period(), 14, ai);
      if (av > 0.0) { count++; if (av <= currentAtr) below++; }
   }
   double rank = (count > 0) ? 100.0 * below / count : 0.0;
   if (rank < 25.0 || (adr10 > 0.0 && adrPct < 35.0)) return "DEAD";
   if (rank > 75.0 || (adr10 > 0.0 && adrPct > 90.0)) return "EXPANSION";
   return "NORMAL";
}

string ChatCtxLiquidity()
{
   double px = (Bid + Ask) * 0.5;
   string out = "\nLIQUIDITY ";
   int tfList[2];
   tfList[0] = PERIOD_M15; tfList[1] = PERIOD_H1;
   for (int ti = 0; ti < 2; ti++)
   {
      int tf = tfList[ti];
      double atr = iATR(Symbol(), tf, 14, 1);
      double highs[64], lows[64];
      double pools[64];
      int hc = 0, lc = 0;
      int poolCount = 0;
      ArrayInitialize(highs, 0.0);
      ArrayInitialize(lows, 0.0);
      ArrayInitialize(pools, 0.0);
      int bars = iBars(Symbol(), tf);
      int maxBars = (bars > 105) ? 100 : bars - 5;
      for (int bi = 2; bi <= maxBars && (hc < 64 || lc < 64); bi++)
      {
         double h = iHigh(Symbol(), tf, bi);
         if (hc < 64 && h >= iHigh(Symbol(), tf, bi - 1) && h >= iHigh(Symbol(), tf, bi + 1))
         {
            highs[hc] = h;
            hc++;
         }
         double l = iLow(Symbol(), tf, bi);
         if (lc < 64 && l <= iLow(Symbol(), tf, bi - 1) && l <= iLow(Symbol(), tf, bi + 1))
         {
            lows[lc] = l;
            lc++;
         }
      }
      out += TimeframeToString(tf) + " EQH/EQL=";
      int eqCount = 0;
      for (int hi = 0; hi < hc && eqCount < 4; hi++)
         for (int hj = hi + 1; hj < hc && eqCount < 4; hj++)
            if (MathAbs(highs[hi] - highs[hj]) <= atr * 0.1)
            {
               double poolHigh = (highs[hi] + highs[hj]) / 2.0;
               out += "H" + DoubleToString(poolHigh, Digits) + ";";
               if (poolCount < 64) pools[poolCount++] = poolHigh;
               eqCount++;
            }
      for (int li = 0; li < lc && eqCount < 8; li++)
         for (int lj = li + 1; lj < lc && eqCount < 8; lj++)
            if (MathAbs(lows[li] - lows[lj]) <= atr * 0.1)
            {
               double poolLow = (lows[li] + lows[lj]) / 2.0;
               out += "L" + DoubleToString(poolLow, Digits) + ";";
               if (poolCount < 64) pools[poolCount++] = poolLow;
               eqCount++;
            }
      out += " nearest=";
      for (int side = 0; side < 2; side++)
      {
         double best[3]; bool used[64];
         ArrayInitialize(best, 0.0); ArrayInitialize(used, false);
         for (int rank = 0; rank < 3; rank++)
         {
            double choice = 0.0, distance = 1.0e100;
            int chosenIndex = -1;
            for (int pi = 0; pi < poolCount; pi++)
            {
               if (used[pi]) continue;
               choice = pools[pi];
               if (side == 0 && choice <= px) continue;
               if (side == 1 && choice >= px) continue;
               if (MathAbs(choice - px) < distance)
               {
                  distance = MathAbs(choice - px);
                  best[rank] = choice;
                  chosenIndex = pi;
               }
            }
            if (distance < 1.0e99)
            {
               out += (side == 0 ? "A" : "B") + DoubleToString(best[rank], Digits) + ";";
               if (chosenIndex >= 0) used[chosenIndex] = true;
            }
         }
      }
      int sweep = 0;
      for (int si = 1; si <= 5 && si + 5 < bars; si++)
      {
         double bh = iHigh(Symbol(), tf, si), bl = iLow(Symbol(), tf, si);
         double priorH = iHigh(Symbol(), tf, si + 1), priorL = iLow(Symbol(), tf, si + 1);
         for (int sj = si + 1; sj <= si + 5; sj++)
         {
            if (iHigh(Symbol(), tf, sj) > priorH) priorH = iHigh(Symbol(), tf, sj);
            if (iLow(Symbol(), tf, sj) < priorL) priorL = iLow(Symbol(), tf, sj);
         }
         double close = iClose(Symbol(), tf, si);
         if (bh > priorH && close < priorH) sweep++;
         if (bl < priorL && close > priorL) sweep++;
      }
      out += " sweeps5=" + IntegerToString(sweep) + " FVG=";
      int fvgCount = 0;
      for (int fi = 1; fi <= 30 && fi + 2 < bars && fvgCount < 3; fi++)
      {
         double oldHigh = iHigh(Symbol(), tf, fi + 2), oldLow = iLow(Symbol(), tf, fi + 2);
         double newLow = iLow(Symbol(), tf, fi), newHigh = iHigh(Symbol(), tf, fi);
         if (newLow > oldHigh)
         {
            double fvgDist = (px < oldHigh) ? oldHigh - px : ((px > newLow) ? px - newLow : 0.0);
            out += "B" + DoubleToString(oldHigh, Digits) + "-" + DoubleToString(newLow, Digits) +
                   " dPts=" + DoubleToString(fvgDist / Point, 0) + ";";
            fvgCount++;
         }
         else if (newHigh < oldLow)
         {
            double fvgDist = (px < newHigh) ? newHigh - px : ((px > oldLow) ? px - oldLow : 0.0);
            out += "S" + DoubleToString(newHigh, Digits) + "-" + DoubleToString(oldLow, Digits) +
                   " dPts=" + DoubleToString(fvgDist / Point, 0) + ";";
            fvgCount++;
         }
      }
      double hi100 = iHigh(Symbol(), tf, iHighest(Symbol(), tf, MODE_HIGH, 100, 1));
      double lo100 = iLow(Symbol(), tf, iLowest(Symbol(), tf, MODE_LOW, 100, 1));
      double pct = (hi100 > lo100) ? 100.0 * (px - lo100) / (hi100 - lo100) : 50.0;
      out += " premiumDiscount=" + DoubleToString(pct, 1) + "% eq50=" +
             DoubleToString((hi100 + lo100) / 2.0, Digits) + " ";
   }
   int m5Bars = iBars(Symbol(), PERIOD_M5);
   out += "M5 FVG=";
   int m5Fvg = 0;
   for (int m5i = 1; m5i <= 30 && m5i + 2 < m5Bars && m5Fvg < 3; m5i++)
   {
      double m5OldHigh = iHigh(Symbol(), PERIOD_M5, m5i + 2);
      double m5OldLow = iLow(Symbol(), PERIOD_M5, m5i + 2);
      double m5NewLow = iLow(Symbol(), PERIOD_M5, m5i);
      double m5NewHigh = iHigh(Symbol(), PERIOD_M5, m5i);
      if (m5NewLow > m5OldHigh)
      {
         out += "B" + DoubleToString(m5OldHigh, Digits) + "-" +
                DoubleToString(m5NewLow, Digits) + " dPts=" +
                DoubleToString(((px < m5OldHigh) ? m5OldHigh - px :
                ((px > m5NewLow) ? px - m5NewLow : 0.0)) / Point, 0) + ";";
         m5Fvg++;
      }
      else if (m5NewHigh < m5OldLow)
      {
         out += "S" + DoubleToString(m5NewHigh, Digits) + "-" +
                DoubleToString(m5OldLow, Digits) + " dPts=" +
                DoubleToString(((px < m5NewHigh) ? m5NewHigh - px :
                ((px > m5OldLow) ? px - m5OldLow : 0.0)) / Point, 0) + ";";
         m5Fvg++;
      }
   }
   return out + "\n";
}

string ChatCtxSessions()
{
   datetime brokerNow = TimeCurrent();
   datetime localNow = TimeLocal();
   int bh = TimeHour(brokerNow);
   int minute = TimeMinute(brokerNow);
   int session = GetCurrentSession();
   string sessionName = (session == 1) ? "ASIA" : ((session == 2) ? "LONDON" :
                         ((session == 3) ? "NEW_YORK" : "OFF_HOURS"));
   int closeHour = (session == 1) ? Chat_AsiaEndHour : ((session == 2) ? London_EndHour :
                   ((session == 3) ? NY_EndHour : 0));
   int nextHour = (session == 1) ? London_StartHour : ((session == 2) ? NY_StartHour : Asia_StartHour);
   int untilClose = (closeHour > bh) ? closeHour * 60 - (bh * 60 + minute) :
                    ((closeHour > 0) ? (24 * 60 - (bh * 60 + minute) + closeHour * 60) : 0);
   int untilNext = (nextHour > bh) ? nextHour * 60 - (bh * 60 + minute) :
                   (24 * 60 - (bh * 60 + minute) + nextHour * 60);
   string activeNext = GetSessionString();
   return "\nSESSIONS current=" + sessionName + " getSession=" + activeNext +
          " untilCloseMin=" + IntegerToString(untilClose) + " untilNextOpenMin=" +
          IntegerToString(untilNext) + " brokerDOW=" + IntegerToString(TimeDayOfWeek(brokerNow)) +
          " brokerHour=" + IntegerToString(bh) + " localHour=" +
          IntegerToString(TimeHour(localNow)) + "\n";
}

void ChatBuildContext(string &context)
{
   double bid = Bid, ask = Ask;
   context = "SYMBOL " + Symbol() + " digits=" + IntegerToString(Digits) +
             " point=" + DoubleToString(Point, Digits) +
             " spreadPts=" + DoubleToString((ask - bid) / Point, 1) +
             " bid=" + DoubleToString(bid, Digits) + " ask=" + DoubleToString(ask, Digits) +
             " server=" + TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS) + "\n";
   context += "ACCOUNT balance=" + DoubleToString(AccountBalance(), 2) +
              " equity=" + DoubleToString(AccountEquity(), 2) +
              " freeMargin=" + DoubleToString(AccountFreeMargin(), 2) +
              " currency=" + AccountCurrency() + " chartTF=" + TimeframeToString(Period()) + "\n";
   if (Chat_SendEaScore)
   {
      context += "EA signal trend=" + IntegerToString(g_sigCachedTrend) +
                 " score=" + IntegerToString(g_sigCachedScore) + " grade=" + g_sigCachedGrade +
                 " BOS=" + DoubleToString(g_sigCachedBOSLevel, Digits) +
                 " swingH=" + DoubleToString(g_sigCachedSwingH, Digits) +
                 " swingL=" + DoubleToString(g_sigCachedSwingL, Digits) +
                 " confirmTF=" + TimeframeToString(g_confirmCachedTF) +
                 " confirmTrend=" + IntegerToString(g_confirmCachedTrend) +
                 " gate=" + (g_gatePass ? "PASS" : "FAIL") + " " +
                 IntegerToString(g_gatePassed) + "/" + IntegerToString(g_gateTotal) +
                 " dir=" + IntegerToString(g_gateDir) + " why=" + g_gateWhy + " fail=" + g_gateFail + "\n";
      context += "AI decision=" + g_aiDecision + " confidence=" + DoubleToString(g_aiConfidence, 2) +
                 " reasons=" + g_aiR1 + " | " + g_aiR2 + " | " + g_aiR3 + "\n";
   }
   else
   {
      // Bez EA score/grade/gate - samo chisti fakti od chartot, AI odluchuva sam.
      context += "LEVELS BOS=" + DoubleToString(g_sigCachedBOSLevel, Digits) +
                 " swingH=" + DoubleToString(g_sigCachedSwingH, Digits) +
                 " swingL=" + DoubleToString(g_sigCachedSwingL, Digits) + "\n";
      context += "NOTE EA scoring i hard gate NE se prakjaat namerno - odluchi samo od slikite, " +
                 "strukturata i indikatorite podolu.\n";
   }
   context += "MTF ";
   for (int mi = 0; mi < MTF_N; mi++)
      if (StringLen(g_mtfName[mi]) > 0) context += g_mtfName[mi] + "=" + g_mtfBias[mi] + " ";
   context += "\nORDERS ";
   for (int oi = 0; oi < OrdersTotal(); oi++)
   {
      if (!OrderSelect(oi, SELECT_BY_POS, MODE_TRADES) || OrderSymbol() != Symbol()) continue;
      if (OrderMagicNumber() != Magic_Number) continue;
      context += "#" + IntegerToString(OrderTicket()) + " type=" + IntegerToString(OrderType()) +
                 " lots=" + DoubleToString(OrderLots(), 2) +
                 " open=" + DoubleToString(OrderOpenPrice(), Digits) +
                 " sl=" + DoubleToString(OrderStopLoss(), Digits) +
                 " tp=" + DoubleToString(OrderTakeProfit(), Digits) +
                 " profit=" + DoubleToString(OrderProfit(), 2) +
                 " time=" + TimeToString(OrderOpenTime(), TIME_DATE|TIME_MINUTES) +
                 " magic=" + IntegerToString(OrderMagicNumber()) + " comment=" + OrderComment() + "; ";
   }
   double px = (bid + ask) * 0.5;
   context += "\nZONES ";
   int shown = 0;
   for (int zi = 0; zi < totalBullZones && shown < 5; zi++)
   {
      if (BullishZones[zi].tpHit || BullishZones[zi].slHit) continue;
      context += "BULL " + TimeframeToString(BullishZones[zi].timeframe) + " top=" + DoubleToString(BullishZones[zi].top, Digits) +
                 " bot=" + DoubleToString(BullishZones[zi].bottom, Digits) + " entry=" + DoubleToString(BullishZones[zi].entryPrice, Digits) +
                 " sl=" + DoubleToString(BullishZones[zi].stopLoss, Digits) + " tp=" + DoubleToString(BullishZones[zi].takeProfit, Digits) +
                 " strength=" + DoubleToString(BullishZones[zi].strength, 1) + " elite=" + (BullishZones[zi].isElite ? "Y" : "N") +
                 " bos=" + (BullishZones[zi].bosConfirmed ? "Y" : "N") + " touches=" + IntegerToString(BullishZones[zi].touches) +
                 " dist=" + DoubleToString(MathAbs(px - (BullishZones[zi].top + BullishZones[zi].bottom) * 0.5), Digits) + "; ";
      shown++;
   }
   shown = 0;
   for (int zi2 = 0; zi2 < totalBearZones && shown < 5; zi2++)
   {
      if (BearishZones[zi2].tpHit || BearishZones[zi2].slHit) continue;
      context += "BEAR " + TimeframeToString(BearishZones[zi2].timeframe) + " top=" + DoubleToString(BearishZones[zi2].top, Digits) +
                 " bot=" + DoubleToString(BearishZones[zi2].bottom, Digits) + " entry=" + DoubleToString(BearishZones[zi2].entryPrice, Digits) +
                 " sl=" + DoubleToString(BearishZones[zi2].stopLoss, Digits) + " tp=" + DoubleToString(BearishZones[zi2].takeProfit, Digits) +
                 " strength=" + DoubleToString(BearishZones[zi2].strength, 1) + " elite=" + (BearishZones[zi2].isElite ? "Y" : "N") +
                 " bos=" + (BearishZones[zi2].bosConfirmed ? "Y" : "N") + " touches=" + IntegerToString(BearishZones[zi2].touches) +
                 " dist=" + DoubleToString(MathAbs(px - (BearishZones[zi2].top + BearishZones[zi2].bottom) * 0.5), Digits) + "; ";
      shown++;
   }
   string tfs[]; int tc = StringSplit(Chat_ContextTFs, ',', tfs);
   context += "\nTIMEFRAMES ";
   for (int ti = 0; ti < tc; ti++)
   {
      int tf = PERIOD_CURRENT;
      string ts = tfs[ti];
      if (ts == "M1") tf = PERIOD_M1; else if (ts == "M5") tf = PERIOD_M5;
      else if (ts == "M15") tf = PERIOD_M15; else if (ts == "H1") tf = PERIOD_H1;
      else if (ts == "H4") tf = PERIOD_H4; else if (ts == "D1") tf = PERIOD_D1;
      double c = iClose(Symbol(), tf, 1);
      double ema = iMA(Symbol(), tf, 200, 0, MODE_EMA, PRICE_CLOSE, 1);
      double rsi = iRSI(Symbol(), tf, 14, PRICE_CLOSE, 1);
      double adx = iADX(Symbol(), tf, 14, PRICE_CLOSE, MODE_MAIN, 1);
      double atr = iATR(Symbol(), tf, 14, 1);
      double sh = iHigh(Symbol(), tf, iHighest(Symbol(), tf, MODE_HIGH, 30, 1));
      double sl = iLow(Symbol(), tf, iLowest(Symbol(), tf, MODE_LOW, 30, 1));
      context += ts + " close=" + DoubleToString(c, Digits) + " ema200=" + DoubleToString(ema, Digits) +
                 " rsi=" + DoubleToString(rsi, 1) + " adx=" + DoubleToString(adx, 1) +
                 " atr=" + DoubleToString(atr, Digits) + " swingH=" + DoubleToString(sh, Digits) +
                 " swingL=" + DoubleToString(sl, Digits) + " candles=";
      for (int ci = 1; ci <= 12; ci++)
         context += DoubleToString(iOpen(Symbol(), tf, ci), Digits) + "/" +
                    DoubleToString(iHigh(Symbol(), tf, ci), Digits) + "/" +
                    DoubleToString(iLow(Symbol(), tf, ci), Digits) + "/" +
                    DoubleToString(iClose(Symbol(), tf, ci), Digits) + ",";
      context += "\n";
   }
   if (Chat_CtxLevels) context += ChatCtxLevels();
   if (Chat_CtxVolatility) context += ChatCtxVolatility();
   if (Chat_CtxLiquidity) context += ChatCtxLiquidity();
   if (Chat_CtxSessions) context += ChatCtxSessions();
   if (Chat_CtxNews) context += ChatCtxNews();
   if (Chat_CtxHeadlines)
   {
      context += ChatCtxHeadlines();
      context += ChatCtxUsdStrength();
   }
   if (Chat_CtxStats)
   {
      context += ChatCtxStats();
      context += ChatPlanAccuracyContext();
   }
   if (Chat_TriggerEnable && g_trigActive)
      context += "ACTIVE_TRIGGER " + ChatTriggerDescribe() +
                 " (EA vekje cheka ovoj uslov lokalno; ne davaj nov plan bez pricina)\n";
   int contextCap = 12000;
   if (StringLen(context) > contextCap)
   {
      int candlePos = StringFind(context, " candles=");
      int richPos = StringFind(context, "\nLEVELS ");
      if (richPos < 0) richPos = StringFind(context, "\nVOLATILITY ");
      if (richPos < 0) richPos = StringFind(context, "\nLIQUIDITY ");
      if (richPos < 0) richPos = StringFind(context, "\nSESSIONS ");
      if (candlePos >= 0 && richPos > candlePos)
      {
         int candleStart = candlePos + StringLen(" candles=");
         int richLen = StringLen(context) - richPos;
         int candleBudget = contextCap - candleStart - richLen;
         if (candleBudget < 0) candleBudget = 0;
         string prefix = StringSubstr(context, 0, candleStart);
         string candles = StringSubstr(context, candleStart, richPos - candleStart);
         string suffix = StringSubstr(context, richPos);
         context = prefix + StringSubstr(candles, 0, candleBudget) +
                   "\n[CANDLE_DUMP_TRUNCATED]\n" + suffix;
         if (StringLen(context) > contextCap)
            context = StringSubstr(context, 0, contextCap);
      }
      else context = StringSubstr(context, 0, contextCap);
   }
}

string ChatJsonUnescape(string text)
{
   string out = "";
   for (int i = 0; i < StringLen(text); i++)
   {
      ushort c = StringGetChar(text, i);
      if (c != 92 || i + 1 >= StringLen(text)) { out += ShortToString(c); continue; }
      ushort n = StringGetChar(text, ++i);
      if (n == 110) out += "\n";
      else if (n == 114) out += "\n";
      else if (n == 116) out += "  ";
      else if (n == 117 && i + 4 < StringLen(text))
      {
         int v = 0;
         bool validHex = true;
         for (int h = 0; h < 4; h++)
         {
            ushort q = StringGetChar(text, i + 1 + h);
            int d = -1;
            if (q >= 48 && q <= 57) d = q - 48;
            else if (q >= 65 && q <= 70) d = q - 55;
            else if (q >= 97 && q <= 102) d = q - 87;
            else validHex = false;
            if (d < 0) d = 0;
            v = v * 16 + d;
         }
         out += validHex ? ShortToString((ushort)v) : "?"; i += 4;
      }
      else out += ShortToString(n);
   }
   return out;
}

string ChatJsonEscape(string text)
{
   string out = "";
   string hex = "0123456789ABCDEF";
   for (int i = 0; i < StringLen(text); i++)
   {
      ushort c = StringGetChar(text, i);
      if (c == 34) out += "\\\"";
      else if (c == 92) out += "\\\\";
      else if (c == 10) out += "\\n";
      else if (c == 13) out += "\\r";
      else if (c == 9) out += "\\t";
      else if (c < 32)
      {
         out += "\\u00" + StringSubstr(hex, c / 16, 1) +
                StringSubstr(hex, c % 16, 1);
      }
      else out += ShortToString(c);
   }
   return out;
}

string ChatJsonExtract(string json, string key)
{
   string pat = "\"" + key + "\"";
   int k = StringFind(json, pat);
   if (k < 0) return "";
   int c = StringFind(json, ":", k + StringLen(pat));
   if (c < 0) return "";
   int i = c + 1;
   while (i < StringLen(json) && (StringGetChar(json, i) == 32 || StringGetChar(json, i) == 10 || StringGetChar(json, i) == 13)) i++;
   if (i >= StringLen(json) || StringGetChar(json, i) != 34) return "";
   i++; string out = ""; bool esc = false;
   for (; i < StringLen(json); i++)
   {
      ushort q = StringGetChar(json, i);
      if (!esc && q == 34) break;
      if (!esc && q == 92) { esc = true; out += "\\"; continue; }
      out += ShortToString(q); esc = false;
   }
   return ChatJsonUnescape(out);
}

long ChatJsonExtractNum(string json, string key)
{
   string pat = "\"" + key + "\"";
   int k = StringFind(json, pat);
   if (k < 0) return 0;
   int c = StringFind(json, ":", k + StringLen(pat));
   if (c < 0) return 0;
   int i = c + 1;
   while (i < StringLen(json))
   {
      ushort q = StringGetChar(json, i);
      if (q != 32 && q != 9 && q != 10 && q != 13) break;
      i++;
   }
   bool negative = false;
   if (i < StringLen(json))
   {
      ushort sign = StringGetChar(json, i);
      if (sign == 45) { negative = true; i++; }
      else if (sign == 43) i++;
   }
   long value = 0;
   bool found = false;
   while (i < StringLen(json))
   {
      ushort digit = StringGetChar(json, i);
      if (digit < 48 || digit > 57) break;
      value = value * 10 + (digit - 48);
      found = true;
      i++;
   }
   if (!found) return 0;
   return negative ? -value : value;
}

double ChatJsonExtractDouble(string json, string key)
{
   string pat = "\"" + key + "\"";
   int k = StringFind(json, pat);
   if (k < 0) return 0.0;
   int c = StringFind(json, ":", k + StringLen(pat));
   if (c < 0) return 0.0;
   int i = c + 1;
   while (i < StringLen(json))
   {
      ushort q = StringGetChar(json, i);
      if (q != 32 && q != 9 && q != 10 && q != 13) break;
      i++;
   }
   int start = i;
   while (i < StringLen(json))
   {
      ushort digit = StringGetChar(json, i);
      if (!((digit >= 48 && digit <= 57) || digit == 45 || digit == 43 ||
            digit == 46 || digit == 69 || digit == 101)) break;
      i++;
   }
   if (i <= start) return 0.0;
   return StringToDouble(StringSubstr(json, start, i - start));
}

bool ChatPlanKnownKey(string token)
{
   return (token == "SETUP" || token == "ENTRY" || token == "SL" ||
           token == "TP1" || token == "TP2" || token == "RR" ||
           token == "CONF" || token == "TRIGGER" || token == "VALID_UNTIL" ||
           token == "INVALIDATION" || token == "WHY");
}

bool ChatPlanIsKeyAt(string text, int pos)
{
   int length = StringLen(text);
   if (pos < 0 || pos >= length) return false;
   int i = pos;
   while (i < length)
   {
      ushort c = StringGetChar(text, i);
      bool alpha = ((c >= 65 && c <= 90) || (c >= 97 && c <= 122) ||
                    (c >= 48 && c <= 57) || c == 95);
      if (!alpha) break;
      i++;
   }
   if (i <= pos) return false;
   int tokenEnd = i;
   while (i < length)
   {
      ushort gap = StringGetChar(text, i);
      if (gap != 32 && gap != 9) break;
      i++;
   }
   if (i >= length || StringGetChar(text, i) != 61) return false;
   return ChatPlanKnownKey(StringSubstr(text, pos, tokenEnd - pos));
}

string ChatPlanNormalize(string reply)
{
   string normalized = reply;
   StringReplace(normalized, "*", "");
   StringReplace(normalized, "`", "");
   StringReplace(normalized, "#", "");
   StringReplace(normalized, " =", "=");
   StringReplace(normalized, "= ", "=");
   return normalized;
}

string ChatPlanField(string reply, string key)
{
   int search = 0;
   int pos = -1;
   int equals = -1;
   int replyLength = StringLen(reply);
   while (search < replyLength)
   {
      int found = StringFind(reply, key, search);
      if (found < 0) break;
      bool boundary = (found == 0);
      if (!boundary)
      {
         ushort before = StringGetChar(reply, found - 1);
         boundary = (before == 32 || before == 9 || before == 10 ||
                     before == 13 || before == 44 || before == 59);
      }
      int candidate = found + StringLen(key);
      while (candidate < replyLength)
      {
         ushort gap = StringGetChar(reply, candidate);
         if (gap != 32 && gap != 9) break;
         candidate++;
      }
      if (boundary && candidate < replyLength && StringGetChar(reply, candidate) == 61)
      {
         pos = found;
         equals = candidate;
         break;
      }
      search = found + 1;
   }
   if (pos < 0) return "";
   int start = equals + 1;
   while (start < replyLength)
   {
      ushort gap = StringGetChar(reply, start);
      if (gap != 32 && gap != 9) break;
      start++;
   }
   int end = StringFind(reply, "\n", start);
   if (end < 0) end = replyLength;
   for (int i = start; i < end; i++)
   {
      ushort separator = StringGetChar(reply, i);
      bool whitespace = (separator == 32 || separator == 9 ||
                         separator == 10 || separator == 13);
      if (!whitespace && separator != 44 && separator != 59) continue;
      int next = i + 1;
      while (next < end)
      {
         ushort space = StringGetChar(reply, next);
         if (space != 32 && space != 9) break;
         next++;
      }
      if (ChatPlanIsKeyAt(reply, next))
      {
         end = i;
         break;
      }
   }
   string value = StringSubstr(reply, start, end - start);
   StringTrimLeft(value); StringTrimRight(value);
   while (StringLen(value) > 0)
   {
      int last = StringLen(value) - 1;
      ushort tail = StringGetChar(value, last);
      if (tail != 44 && tail != 59 && tail != 46) break;
      value = StringSubstr(value, 0, last);
      StringTrimRight(value);
   }
   return value;
}

bool ChatPlanNumber(string text, double &value)
{
   StringTrimLeft(text); StringTrimRight(text);
   string lower = text; StringToLower(lower);
   if (StringLen(lower) == 0 || lower == "n/a" || lower == "-" || lower == "none")
   {
      value = 0.0;
      return false;
   }
   value = StringToDouble(text);
   return (value > 0.0);
}

bool ChatPlanWholeWord(string text, string word, int pos)
{
   int length = StringLen(text);
   int wordLength = StringLen(word);
   if (pos < 0 || pos + wordLength > length) return false;
   if (StringSubstr(text, pos, wordLength) != word) return false;
   bool leftOk = (pos == 0);
   if (!leftOk)
   {
      ushort left = StringGetChar(text, pos - 1);
      leftOk = !((left >= 65 && left <= 90) || (left >= 97 && left <= 122) ||
                 (left >= 48 && left <= 57) || left == 95);
   }
   bool rightOk = (pos + wordLength >= length);
   if (!rightOk)
   {
      ushort right = StringGetChar(text, pos + wordLength);
      rightOk = !((right >= 65 && right <= 90) || (right >= 97 && right <= 122) ||
                  (right >= 48 && right <= 57) || right == 95);
   }
   return (leftOk && rightOk);
}

string ChatPlanFallbackSetup(string reply)
{
   string upperReply = reply;
   StringToUpper(upperReply);
   string noTradeReply = upperReply;
   StringReplace(noTradeReply, "-", " ");
   string noTradeWords[10];
   noTradeWords[0] = "NO TRADE";
   noTradeWords[1] = "NO_TRADE";
   noTradeWords[2] = "NOTRADE";
   noTradeWords[3] = "WAIT";
   noTradeWords[4] = "NONE";
   noTradeWords[5] = "HOLD";
   noTradeWords[6] = "NEMA SETAP";
   noTradeWords[7] = "NEMA VLEZ";
   noTradeWords[8] = "CEKAJ";
   noTradeWords[9] = "BEZ VLEZ";
   if (Chat_FallbackNoTradeProse)
   {
      for (int nti = 0; nti < 10; nti++)
      {
         int noTradeSearch = 0;
         while (noTradeSearch < StringLen(noTradeReply))
         {
            int noTradePos = StringFind(noTradeReply, noTradeWords[nti], noTradeSearch);
            if (noTradePos < 0) break;
            if (ChatPlanWholeWord(noTradeReply, noTradeWords[nti], noTradePos))
               return "NO_TRADE";
            noTradeSearch = noTradePos + 1;
         }
      }
   }
   string words[3];
   words[0] = "NO_TRADE";
   words[1] = "BUY";
   words[2] = "SELL";
   int bestPos = -1;
   string best = "";
   int buyPos = -1;
   int sellPos = -1;
   for (int wi = 0; wi < 3; wi++)
   {
      int search = 0;
      while (search < StringLen(upperReply))
      {
         int found = StringFind(upperReply, words[wi], search);
         if (found < 0) break;
         if (ChatPlanWholeWord(upperReply, words[wi], found))
         {
            if (words[wi] == "BUY") buyPos = found;
            if (words[wi] == "SELL") sellPos = found;
            if (bestPos < 0 || found < bestPos)
            {
               bestPos = found;
               best = words[wi];
            }
         }
         search = found + 1;
      }
   }
   if (buyPos >= 0 && sellPos >= 0) return "NO_TRADE";
   return best;
}

// RR presmetan LOKALNO od entry/SL/TP2 - AI cesto zaokruzuva pogresno.
double ChatPlanRRCalc(double entry, double sl, double tp2)
{
   double risk = MathAbs(entry - sl);
   if (risk <= 0.0) return 0.0;
   return MathAbs(tp2 - entry) / risk;
}

bool ChatPlanAdjustTP1Daily(string setup, double entry, double sl,
                            double tp2, double &tp1, string &noteOut)
{
   noteOut = "";
   if (!Chat_TP1DailyLevelGuard) return false;
   if ((setup != "BUY" && setup != "SELL") ||
       entry <= 0.0 || sl <= 0.0 || tp1 <= 0.0 || tp2 <= 0.0)
      return false;
   double dayHigh = 0.0; double dayLow = 0.0; double mid = 0.0;
   double lowMid = 0.0; double midHigh = 0.0;
   if (!DailyLevelsGet(dayHigh, dayLow, mid, lowMid, midHigh))
      return false;
   double risk = MathAbs(entry - sl);
   if (risk <= 0.0) return false;
   double buffer = Chat_TP1DailyLevelBufferUSD;
   if (buffer < 0.0) buffer = 0.0;
   double levels[5];
   string names[5];
   if (setup == "BUY")
   {
      levels[0] = dayLow;  names[0] = "Low";
      levels[1] = lowMid;  names[1] = "Low-Mid";
      levels[2] = mid;     names[2] = "Mid";
      levels[3] = midHigh; names[3] = "Mid-High";
      levels[4] = dayHigh; names[4] = "High";
   }
   else
   {
      levels[0] = dayHigh; names[0] = "High";
      levels[1] = midHigh; names[1] = "Mid-High";
      levels[2] = mid;     names[2] = "Mid";
      levels[3] = lowMid;  names[3] = "Low-Mid";
      levels[4] = dayLow;  names[4] = "Low";
   }
   double selected = 0.0;
   string selectedName = "";
   for (int li = 0; li < 5; li++)
   {
      if (setup == "BUY")
      {
         if (levels[li] > entry && levels[li] <= tp1 + buffer)
         {
            selected = levels[li];
            selectedName = names[li];
            break;
         }
      }
      else if (levels[li] < entry && levels[li] >= tp1 - buffer)
      {
         selected = levels[li];
         selectedName = names[li];
         break;
      }
   }
   if (selected <= 0.0) return false;
   double adjusted = (setup == "BUY") ? selected - buffer : selected + buffer;
   adjusted = NormalizeDouble(adjusted, Digits);
   double minDistance = risk * 0.30;
   if (setup == "BUY")
   {
      if (adjusted <= entry || adjusted < entry + minDistance || adjusted >= tp2)
         return false;
   }
   else if (adjusted >= entry || adjusted > entry - minDistance || adjusted <= tp2)
      return false;
   if (MathAbs(adjusted - tp1) < Point) return false;
   noteOut = "TP1 " + DoubleToString(tp1, Digits) + " -> " +
             DoubleToString(adjusted, Digits) + " (pred dnevno nivo " +
             selectedName + " " + DoubleToString(selected, Digits) + ")";
   tp1 = adjusted;
   return true;
}

bool ChatValidatePlan(string reply, string &warning)
{
   warning = "";
   string normalized = ChatPlanNormalize(reply);
   string setup = ChatPlanField(normalized, "SETUP");
   StringTrimLeft(setup); StringTrimRight(setup);
   StringToUpper(setup);
   if (setup != "BUY" && setup != "SELL" && setup != "NO_TRADE")
   {
      setup = ChatPlanFallbackSetup(normalized);
      if (setup == "") 
      {
         warning = "PLAN warning: invalid SETUP.";
         return false;
      }
   }
   if (setup == "NO_TRADE") return true;
   double entry = 0.0; double sl = 0.0; double tp1 = 0.0; double tp2 = 0.0; double rr = 0.0;
   bool entryProvided = ChatPlanNumber(ChatPlanField(normalized, "ENTRY"), entry);
   bool slProvided = ChatPlanNumber(ChatPlanField(normalized, "SL"), sl);
   bool tp1Provided = ChatPlanNumber(ChatPlanField(normalized, "TP1"), tp1);
   bool tp2Provided = ChatPlanNumber(ChatPlanField(normalized, "TP2"), tp2);
   bool rrProvided = ChatPlanNumber(ChatPlanField(normalized, "RR"), rr);
   bool bad = false;
   // RR e samo aritmetika - ako AI go zaokruzhi pogresno EA go presmetuva sam,
   // nema pricina cel setap da se frla zaradi toa.
   if (!entryProvided || !slProvided || !tp1Provided || !tp2Provided) bad = true;
   if (setup == "BUY" && (sl >= entry || tp1 <= entry || tp2 <= entry)) bad = true;
   if (setup == "SELL" && (sl <= entry || tp1 >= entry || tp2 >= entry)) bad = true;
   if (bad)
   {
      warning = "PLAN warning: levels are inconsistent with " + setup +
                " (entry/SL/TP na pogreshna strana).";
      return false;
   }
   double expected = ChatPlanRRCalc(entry, sl, tp2);
   if (!rrProvided || rr <= 0.0 || MathAbs(rr - expected) > 0.20)
      warning = "PLAN note: RR od AI (" + (rrProvided ? DoubleToString(rr, 2) : "n/a") +
                ") ne se poklopuva - EA go koristi presmetaniot " + DoubleToString(expected, 2) + ".";
   return true;
}

void ChatPlansLogSkipped(string reason, string idText, string symbolText,
                         string setupText, string statusText,
                         int &rowsSkipped, int &skipLogCount)
{
   rowsSkipped++;
   if (skipLogCount >= 10) return;
   Print("TraceChat plan skip: ", reason, " id=", idText,
         " symbol=", symbolText, " setup=", setupText,
         " status=", statusText);
   skipLogCount++;
}

bool ChatPlansBackupRaw(string path, string backupPath)
{
   int source = FileOpen(path, FILE_READ|FILE_BIN|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if (source == INVALID_HANDLE)
   {
      Print("TraceChat plan backup FAIL path=", path, " err=", GetLastError());
      return false;
   }
   int size = (int)FileSize(source);
   if (size < 0)
   {
      int sizeError = GetLastError();
      FileClose(source);
      Print("TraceChat plan backup FAIL path=", path, " size err=", sizeError);
      return false;
   }
   uchar data[];
   if (size > 0)
   {
      ArrayResize(data, size);
      int got = (int)FileReadArray(source, data, 0, size);
      if (got != size)
      {
         int readError = GetLastError();
         FileClose(source);
         Print("TraceChat plan backup FAIL path=", path, " read=", got,
               "/", size, " err=", readError);
         return false;
      }
   }
   FileClose(source);

   int target = FileOpen(backupPath, FILE_WRITE|FILE_BIN|FILE_SHARE_READ);
   if (target == INVALID_HANDLE)
   {
      Print("TraceChat plan backup FAIL path=", backupPath, " err=", GetLastError());
      return false;
   }
   for (int bi = 0; bi < size; bi++)
      FileWriteInteger(target, (int)data[bi], 1);
   FileFlush(target);
   FileClose(target);

   int verify = FileOpen(backupPath, FILE_READ|FILE_BIN|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if (verify == INVALID_HANDLE)
   {
      Print("TraceChat plan backup VERIFY FAIL path=", backupPath,
            " err=", GetLastError());
      return false;
   }
   int verifySize = (int)FileSize(verify);
   if (verifySize != size)
   {
      FileClose(verify);
      Print("TraceChat plan backup VERIFY FAIL path=", backupPath,
            " size=", verifySize, " expected=", size);
      return false;
   }
   if (size > 0)
   {
      uchar verifyData[];
      ArrayResize(verifyData, size);
      int verifyGot = (int)FileReadArray(verify, verifyData, 0, size);
      if (verifyGot != size)
      {
         int verifyError = GetLastError();
         FileClose(verify);
         Print("TraceChat plan backup VERIFY FAIL path=", backupPath,
               " read=", verifyGot, "/", size, " err=", verifyError);
         return false;
      }
      for (int vi = 0; vi < size; vi++)
      {
         if (verifyData[vi] == data[vi]) continue;
         FileClose(verify);
         Print("TraceChat plan backup VERIFY FAIL path=", backupPath,
               " bajtot=", vi);
         return false;
      }
   }
   FileClose(verify);
   return true;
}

void ChatPlansSave()
{
   string path = ChatPlansFilePath();
   g_chatPlansLastSaveOk = false;
   if (g_chatPlansSaveBlocked)
   {
      Print("TraceChat plan save PRESKOK path=", path,
            " (prethodno nema backup za rewrite)");
      return;
   }
   int handle = FileOpen(path, FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ, ',');
   if (handle == INVALID_HANDLE)
   {
      Print("TraceChat plan save FAIL path=", path, " err=", GetLastError());
      return;
   }
   FileWrite(handle, "id", "symbol", "createTime", "setup", "entry", "sl", "tp1", "tp2",
             "tp1Hit", "rr", "conf", "status", "resolveTime", "note", "triggered", "isWatch");
   int digits = Digits;
   for (int i = 0; i < g_chatPlanCount; i++)
      FileWrite(handle, g_chatPlanId[i], g_chatPlanSymbol[i],
                TimeToString(g_chatPlanCreateTime[i], TIME_DATE|TIME_SECONDS),
                g_chatPlanSetup[i], DoubleToString(g_chatPlanEntry[i], digits),
                DoubleToString(g_chatPlanSL[i], digits), DoubleToString(g_chatPlanTP1[i], digits),
                DoubleToString(g_chatPlanTP2[i], digits), (g_chatPlanTP1Hit[i] ? "1" : "0"),
                DoubleToString(g_chatPlanRR[i], 2),
                DoubleToString(g_chatPlanConf[i], 1), g_chatPlanStatus[i],
                TimeToString(g_chatPlanResolveTime[i], TIME_DATE|TIME_SECONDS),
                g_chatPlanNote[i], (g_chatPlanTriggered[i] ? "1" : "0"),
                (g_chatPlanIsWatch[i] ? "1" : "0"));
   FileFlush(handle);
   FileClose(handle);
   g_chatPlansLastSaveOk = true;
}

void ChatPlansLoad()
{
   string scopedPath = ChatPlansFilePath();
   string path = scopedPath;
   bool fileExisted = FileIsExist(path);
   bool needsRewrite = false;
   bool backupDone = false;
   bool rewriteDone = false;
   int rowsLoaded = 0;
   int rowsSkipped = 0;
   int skipLogCount = 0;
   int watchLoaded = 0;
   int rowsDroppedByLimit = 0;
   int headerColumns = 0;
   bool hasWatchColumn = false;
   bool hasTP1HitColumn = false;
   if (!fileExisted)
   {
      string legacyPath = "TraceAI\\chat_plans.csv";
      if (!FileIsExist(legacyPath))
      {
         Print("TraceChat plan load: path=", scopedPath,
               " postoi=NE rows=0 skip=0 rewrite=NE max=",
               Chat_PlanMaxRecords, " period=", Chat_StatsResetPeriod,
               " watch=0 cols=0 watchCol=NE tp1HitCol=NE");
         return;
      }
      path = legacyPath;
      fileExisted = true;
      needsRewrite = true;
   }
   int handle = FileOpen(path, FILE_READ|FILE_CSV|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE, ',');
   if (handle == INVALID_HANDLE)
   {
      Print("TraceChat plan load FAIL path=", path, " err=", GetLastError(),
            " rows=0 skip=0 rewrite=NE max=", Chat_PlanMaxRecords,
            " period=", Chat_StatsResetPeriod,
            " watch=0 cols=0 watchCol=NE tp1HitCol=NE");
      return;
   }
   string headerLine = "";
   while (!FileIsLineEnding(handle) && !FileIsEnding(handle))
   {
      string headerItem = FileReadString(handle);
      if (StringLen(headerLine) > 0) headerLine += ",";
      headerLine += headerItem;
      headerColumns++;
   }
   hasWatchColumn = (StringFind(headerLine, "isWatch") >= 0);
   hasTP1HitColumn = (StringFind(headerLine, "tp1Hit") >= 0);
   while (!FileIsEnding(handle))
   {
      string rowFields[];
      int rowFieldCount = 0;
      string firstField = FileReadString(handle);
      if (StringLen(firstField) > 0 ||
          (!FileIsLineEnding(handle) && !FileIsEnding(handle)))
      {
         ArrayResize(rowFields, 1);
         rowFields[0] = firstField;
         rowFieldCount = 1;
         while (!FileIsLineEnding(handle) && !FileIsEnding(handle))
         {
            string rowField = FileReadString(handle);
            ArrayResize(rowFields, rowFieldCount + 1);
            rowFields[rowFieldCount] = rowField;
            rowFieldCount++;
         }
      }
      if (rowFieldCount <= 0)
         continue;

      int fieldIndex = 0;
      int idIndex = fieldIndex++;
      int symbolIndex = fieldIndex++;
      int createIndex = fieldIndex++;
      int setupIndex = fieldIndex++;
      int entryIndex = fieldIndex++;
      int slIndex = fieldIndex++;
      int tp1Index = fieldIndex++;
      int tp2Index = fieldIndex++;
      int tp1HitIndex = -1;
      if (hasTP1HitColumn) tp1HitIndex = fieldIndex++;
      int rrIndex = fieldIndex++;
      int confIndex = fieldIndex++;
      int statusIndex = fieldIndex++;
      int resolveIndex = fieldIndex++;
      int noteIndex = fieldIndex++;
      int triggeredIndex = fieldIndex++;
      int watchIndex = -1;
      if (hasWatchColumn) watchIndex = fieldIndex++;

      string idText = (rowFieldCount > idIndex) ? rowFields[idIndex] : "";
      string symbolText = (rowFieldCount > symbolIndex) ? rowFields[symbolIndex] : "";
      string createText = (rowFieldCount > createIndex) ? rowFields[createIndex] : "";
      string setupText = (rowFieldCount > setupIndex) ? rowFields[setupIndex] : "";
      string entryText = (rowFieldCount > entryIndex) ? rowFields[entryIndex] : "";
      string slText = (rowFieldCount > slIndex) ? rowFields[slIndex] : "";
      string tp1Text = (rowFieldCount > tp1Index) ? rowFields[tp1Index] : "";
      string tp2Text = (rowFieldCount > tp2Index) ? rowFields[tp2Index] : "";
      string tp1HitText = "0";
      if (tp1HitIndex >= 0 && rowFieldCount > tp1HitIndex)
         tp1HitText = rowFields[tp1HitIndex];
      string rrText = (rowFieldCount > rrIndex) ? rowFields[rrIndex] : "";
      string confText = (rowFieldCount > confIndex) ? rowFields[confIndex] : "";
      string statusText = (rowFieldCount > statusIndex) ? rowFields[statusIndex] : "";
      string resolveText = (rowFieldCount > resolveIndex) ? rowFields[resolveIndex] : "";
      string noteText = (rowFieldCount > noteIndex) ? rowFields[noteIndex] : "";
      string triggeredText = (rowFieldCount > triggeredIndex) ? rowFields[triggeredIndex] : "";
      string watchText = "0";
      if (watchIndex >= 0 && rowFieldCount > watchIndex)
         watchText = rowFields[watchIndex];
      if (StringLen(idText) == 0 || StringLen(symbolText) == 0)
      {
         ChatPlansLogSkipped("prazni id/symbol", idText, symbolText,
                            setupText, statusText, rowsSkipped, skipLogCount);
         continue;
      }
      if (symbolText != Symbol())
      {
         needsRewrite = true;
         ChatPlansLogSkipped("pogreshen symbol", idText, symbolText,
                            setupText, statusText, rowsSkipped, skipLogCount);
         continue;
      }
      if (setupText != "BUY" && setupText != "SELL" && setupText != "NO_TRADE")
      {
         needsRewrite = true;
         ChatPlansLogSkipped("pogreshen setup", idText, symbolText,
                            setupText, statusText, rowsSkipped, skipLogCount);
         continue;
      }
      if (statusText != "OPEN" && statusText != "TP1" && statusText != "TP2" && statusText != "SL" &&
          statusText != "EXPIRED" && statusText != "NOT_TRIGGERED")
      {
         needsRewrite = true;
         ChatPlansLogSkipped("pogreshen status", idText, symbolText,
                            setupText, statusText, rowsSkipped, skipLogCount);
         continue;
      }
      int parsedId = (int)StringToInteger(idText);
      datetime parsedCreate = StringToTime(createText);
      double parsedEntry = StringToDouble(entryText);
      double parsedSL = StringToDouble(slText);
      double parsedTP1 = StringToDouble(tp1Text);
      double parsedTP2 = StringToDouble(tp2Text);
      bool parsedTP1Hit = (tp1HitText == "1");
      double parsedRR = StringToDouble(rrText);
      double parsedConf = StringToDouble(confText);
      if (parsedId <= 0 || parsedCreate <= 0)
      {
         needsRewrite = true;
         ChatPlansLogSkipped("nevalid id/time", idText, symbolText,
                            setupText, statusText, rowsSkipped, skipLogCount);
         continue;
      }
      datetime planCut = ChatStatsCutoffTime();
      if (planCut > 0 && parsedCreate < planCut)
      {
         ChatPlansLogSkipped("pred Chat_StatsStartFrom", idText, symbolText,
                            setupText, statusText, rowsSkipped, skipLogCount);
         continue;
      }
      if (parsedConf < 0.0 || parsedConf > 100.0)
      {
         needsRewrite = true;
         ChatPlansLogSkipped("nevalid conf", idText, symbolText,
                            setupText, statusText, rowsSkipped, skipLogCount);
         continue;
      }
      if (setupText != "NO_TRADE" && (parsedEntry <= 0.0 || parsedSL <= 0.0 || parsedTP1 <= 0.0))
      {
         needsRewrite = true;
         ChatPlansLogSkipped("nevalid levels", idText, symbolText,
                            setupText, statusText, rowsSkipped, skipLogCount);
         continue;
      }
      ArrayResize(g_chatPlanId, g_chatPlanCount + 1);
      ArrayResize(g_chatPlanSymbol, g_chatPlanCount + 1);
      ArrayResize(g_chatPlanCreateTime, g_chatPlanCount + 1);
      ArrayResize(g_chatPlanSetup, g_chatPlanCount + 1);
      ArrayResize(g_chatPlanIsWatch, g_chatPlanCount + 1);
      ArrayResize(g_chatPlanEntry, g_chatPlanCount + 1);
      ArrayResize(g_chatPlanSL, g_chatPlanCount + 1);
      ArrayResize(g_chatPlanTP1, g_chatPlanCount + 1);
      ArrayResize(g_chatPlanTP2, g_chatPlanCount + 1);
      ArrayResize(g_chatPlanTP1Hit, g_chatPlanCount + 1);
      ArrayResize(g_chatPlanRR, g_chatPlanCount + 1);
      ArrayResize(g_chatPlanConf, g_chatPlanCount + 1);
      ArrayResize(g_chatPlanStatus, g_chatPlanCount + 1);
      ArrayResize(g_chatPlanResolveTime, g_chatPlanCount + 1);
      ArrayResize(g_chatPlanNote, g_chatPlanCount + 1);
      ArrayResize(g_chatPlanTriggered, g_chatPlanCount + 1);
      ArrayResize(g_chatPlanLastShift, g_chatPlanCount + 1);
      g_chatPlanId[g_chatPlanCount] = parsedId;
      g_chatPlanSymbol[g_chatPlanCount] = symbolText;
      g_chatPlanCreateTime[g_chatPlanCount] = parsedCreate;
      g_chatPlanSetup[g_chatPlanCount] = setupText;
      g_chatPlanIsWatch[g_chatPlanCount] = (watchText == "1");
      g_chatPlanEntry[g_chatPlanCount] = parsedEntry;
      g_chatPlanSL[g_chatPlanCount] = parsedSL;
      g_chatPlanTP1[g_chatPlanCount] = parsedTP1;
      g_chatPlanTP2[g_chatPlanCount] = parsedTP2;
      g_chatPlanTP1Hit[g_chatPlanCount] = parsedTP1Hit;
      g_chatPlanRR[g_chatPlanCount] = parsedRR;
      g_chatPlanConf[g_chatPlanCount] = parsedConf;
      g_chatPlanStatus[g_chatPlanCount] = statusText;
      g_chatPlanResolveTime[g_chatPlanCount] = StringToTime(resolveText);
      g_chatPlanNote[g_chatPlanCount] = noteText;
      g_chatPlanTriggered[g_chatPlanCount] = (triggeredText == "1");
      g_chatPlanLastShift[g_chatPlanCount] = -1;
      if (g_chatPlanIsWatch[g_chatPlanCount]) watchLoaded++;
      if (g_chatPlanId[g_chatPlanCount] >= g_chatPlanIdNext)
         g_chatPlanIdNext = g_chatPlanId[g_chatPlanCount] + 1;
      g_chatPlanCount++;
      rowsLoaded++;
   }
   FileClose(handle);
   bool loadedLegacy = (path != scopedPath);
   while (g_chatPlanCount > Chat_PlanMaxRecords && g_chatPlanCount > 0)
   {
      bool removedWatch = g_chatPlanIsWatch[0];
      for (int move = 1; move < g_chatPlanCount; move++)
      {
         g_chatPlanId[move-1] = g_chatPlanId[move];
         g_chatPlanSymbol[move-1] = g_chatPlanSymbol[move];
         g_chatPlanCreateTime[move-1] = g_chatPlanCreateTime[move];
         g_chatPlanSetup[move-1] = g_chatPlanSetup[move];
         g_chatPlanIsWatch[move-1] = g_chatPlanIsWatch[move];
         g_chatPlanEntry[move-1] = g_chatPlanEntry[move];
         g_chatPlanSL[move-1] = g_chatPlanSL[move];
         g_chatPlanTP1[move-1] = g_chatPlanTP1[move];
         g_chatPlanTP2[move-1] = g_chatPlanTP2[move];
         g_chatPlanTP1Hit[move-1] = g_chatPlanTP1Hit[move];
         g_chatPlanRR[move-1] = g_chatPlanRR[move];
         g_chatPlanConf[move-1] = g_chatPlanConf[move];
         g_chatPlanStatus[move-1] = g_chatPlanStatus[move];
         g_chatPlanResolveTime[move-1] = g_chatPlanResolveTime[move];
         g_chatPlanNote[move-1] = g_chatPlanNote[move];
         g_chatPlanTriggered[move-1] = g_chatPlanTriggered[move];
         g_chatPlanLastShift[move-1] = g_chatPlanLastShift[move];
      }
      g_chatPlanCount--;
      rowsDroppedByLimit++;
      if (removedWatch && watchLoaded > 0) watchLoaded--;
   }
   if (rowsDroppedByLimit > 0) needsRewrite = true;
   if (loadedLegacy || needsRewrite)
   {
      string backupPath = path + ".bak";
      bool backupMade = ChatPlansBackupRaw(path, backupPath);
      backupDone = backupMade;
      if (rowsDroppedByLimit > 0)
         Print("TraceChat plan load: limitot otstrani ", rowsDroppedByLimit,
               " reda; backup=", (backupMade ? "DA" : "NE"));
      if (backupMade)
      {
         ChatPlansSave();
         rewriteDone = g_chatPlansLastSaveOk;
         if (rewriteDone)
            Print("TraceChat plan rewrite: backup=", backupPath, " rewrite=DA");
      }
      else
      {
         g_chatPlansSaveBlocked = true;
         Print("TraceChat plan rewrite PRESKOK: nema validen backup path=", path);
      }
   }
   if (skipLogCount >= 10 && rowsSkipped > skipLogCount)
      Print("TraceChat plan skip summary: ", rowsSkipped - skipLogCount,
            " dopolnitelni reda ne se ispisani.");
   Print("TraceChat plan load: path=", path, " postoi=",
         (fileExisted ? "DA" : "NE"), " rows=", rowsLoaded,
         " skip=", rowsSkipped, " backup=",
         (backupDone ? "DA" : "NE"), " rewrite=",
         (rewriteDone ? "DA" : "NE"), " max=", Chat_PlanMaxRecords,
         " period=", Chat_StatsResetPeriod, " watch=", watchLoaded,
         " cols=", headerColumns, " watchCol=",
         (hasWatchColumn ? "DA" : "NE"), " tp1HitCol=",
         (hasTP1HitColumn ? "DA" : "NE"));
}

void ChatPlansInit()
{
   g_chatPlanCount = 0;
   g_chatPlanIdNext = 1;
   ArrayResize(g_chatPlanId, 0); ArrayResize(g_chatPlanSymbol, 0);
   ArrayResize(g_chatPlanCreateTime, 0); ArrayResize(g_chatPlanSetup, 0);
   ArrayResize(g_chatPlanIsWatch, 0);
   ArrayResize(g_chatPlanEntry, 0); ArrayResize(g_chatPlanSL, 0);
   ArrayResize(g_chatPlanTP1, 0); ArrayResize(g_chatPlanTP2, 0);
   ArrayResize(g_chatPlanTP1Hit, 0);
   ArrayResize(g_chatPlanRR, 0); ArrayResize(g_chatPlanConf, 0);
   ArrayResize(g_chatPlanStatus, 0); ArrayResize(g_chatPlanResolveTime, 0);
   ArrayResize(g_chatPlanNote, 0); ArrayResize(g_chatPlanTriggered, 0);
   ArrayResize(g_chatPlanLastShift, 0);
   g_chatPlanLastM1Bar = 0;
   g_chatPlanForceUpdate = false;
   g_chatPlansSaveBlocked = false;
   if (!FileIsExist(ChatPlansFilePath()) &&
       !FileIsExist("TraceAI\\chat_plans.csv"))
      Print("TraceChat plan init: file NE postoi path=", ChatPlansFilePath(),
            " max=", Chat_PlanMaxRecords, " period=", Chat_StatsResetPeriod);
   if (Chat_PlanMaxRecords < 1) return;
   ChatPlansLoad();
}

void ChatPlanRecord(string setup, double entry, double sl, double tp1, double tp2, double rr, double conf, bool isWatch)
{
   if (Chat_PlanMaxRecords < 1) return;
   bool lowRR = false;
   if (setup == "BUY" || setup == "SELL")
   {
      double reward = MathAbs(tp2 - entry);
      double risk = MathAbs(entry - sl);
      double computedRR = (risk > 0.0) ? reward / risk : 0.0;
      if (Chat_PlanMinRR > 0.0 && computedRR < Chat_PlanMinRR)
      {
         isWatch = true;
         lowRR = true;
      }
   }
   for (int existing = g_chatPlanCount - 1; existing >= 0; existing--)
   {
      if (g_chatPlanSymbol[existing] != Symbol()) continue;
      if (g_chatPlanSetup[existing] != setup) continue;
      // Dedupe only active/recent watch ideas. If the previous watch already
      // resolved (TP/SL/EXPIRED), a new similar watch must count as a new sample.
      if (g_chatPlanStatus[existing] != "OPEN") continue;
      if (MathAbs(g_chatPlanEntry[existing] - entry) > Point * 30) continue;
      if (MathAbs(g_chatPlanSL[existing] - sl) > Point * 30) continue;
      if (MathAbs(g_chatPlanTP2[existing] - tp2) > Point * 60) continue;
      if (TimeCurrent() - g_chatPlanCreateTime[existing] < 0 ||
          TimeCurrent() - g_chatPlanCreateTime[existing] > 30 * 60) continue;
      if (g_chatPlanIsWatch[existing] && !isWatch)
      {
         g_chatPlanIsWatch[existing] = false;
         g_chatPlanNote[existing] = "";
         g_chatPlanRR[existing] = rr;
         g_chatPlanConf[existing] = conf;
         g_chatPlanForceUpdate = true;
         ChatPlansSave();
         return;
      }
      return;
   }
   while (g_chatPlanCount >= Chat_PlanMaxRecords && g_chatPlanCount > 0)
   {
      for (int move = 1; move < g_chatPlanCount; move++)
      {
         g_chatPlanId[move-1] = g_chatPlanId[move];
         g_chatPlanSymbol[move-1] = g_chatPlanSymbol[move];
         g_chatPlanCreateTime[move-1] = g_chatPlanCreateTime[move];
         g_chatPlanSetup[move-1] = g_chatPlanSetup[move];
         g_chatPlanIsWatch[move-1] = g_chatPlanIsWatch[move];
         g_chatPlanEntry[move-1] = g_chatPlanEntry[move];
         g_chatPlanSL[move-1] = g_chatPlanSL[move];
         g_chatPlanTP1[move-1] = g_chatPlanTP1[move];
         g_chatPlanTP2[move-1] = g_chatPlanTP2[move];
         g_chatPlanTP1Hit[move-1] = g_chatPlanTP1Hit[move];
         g_chatPlanRR[move-1] = g_chatPlanRR[move];
         g_chatPlanConf[move-1] = g_chatPlanConf[move];
         g_chatPlanStatus[move-1] = g_chatPlanStatus[move];
         g_chatPlanResolveTime[move-1] = g_chatPlanResolveTime[move];
         g_chatPlanNote[move-1] = g_chatPlanNote[move];
         g_chatPlanTriggered[move-1] = g_chatPlanTriggered[move];
         g_chatPlanLastShift[move-1] = g_chatPlanLastShift[move];
      }
      g_chatPlanCount--;
   }
   ArrayResize(g_chatPlanId, g_chatPlanCount + 1);
   ArrayResize(g_chatPlanSymbol, g_chatPlanCount + 1);
   ArrayResize(g_chatPlanCreateTime, g_chatPlanCount + 1);
   ArrayResize(g_chatPlanSetup, g_chatPlanCount + 1);
   ArrayResize(g_chatPlanIsWatch, g_chatPlanCount + 1);
   ArrayResize(g_chatPlanEntry, g_chatPlanCount + 1);
   ArrayResize(g_chatPlanSL, g_chatPlanCount + 1);
   ArrayResize(g_chatPlanTP1, g_chatPlanCount + 1);
   ArrayResize(g_chatPlanTP2, g_chatPlanCount + 1);
   ArrayResize(g_chatPlanTP1Hit, g_chatPlanCount + 1);
   ArrayResize(g_chatPlanRR, g_chatPlanCount + 1);
   ArrayResize(g_chatPlanConf, g_chatPlanCount + 1);
   ArrayResize(g_chatPlanStatus, g_chatPlanCount + 1);
   ArrayResize(g_chatPlanResolveTime, g_chatPlanCount + 1);
   ArrayResize(g_chatPlanNote, g_chatPlanCount + 1);
   ArrayResize(g_chatPlanTriggered, g_chatPlanCount + 1);
   ArrayResize(g_chatPlanLastShift, g_chatPlanCount + 1);
   int index = g_chatPlanCount;
   g_chatPlanId[index] = g_chatPlanIdNext++;
   g_chatPlanSymbol[index] = Symbol();
   g_chatPlanCreateTime[index] = TimeCurrent();
   g_chatPlanSetup[index] = setup;
   g_chatPlanIsWatch[index] = isWatch;
   g_chatPlanEntry[index] = entry;
   g_chatPlanSL[index] = sl;
   g_chatPlanTP1[index] = tp1;
   g_chatPlanTP2[index] = tp2;
   g_chatPlanTP1Hit[index] = false;
   g_chatPlanRR[index] = rr;
   g_chatPlanConf[index] = conf;
   g_chatPlanStatus[index] = (setup == "NO_TRADE") ? "NOT_TRIGGERED" : "OPEN";
   g_chatPlanResolveTime[index] = 0;
   g_chatPlanNote[index] = (setup == "NO_TRADE") ? "SKIPPED" :
                          (lowRR ? "WATCH LOW_RR" : (isWatch ? "WATCH" : ""));
   g_chatPlanTriggered[index] = (setup == "NO_TRADE");
   g_chatPlanLastShift[index] = -1;
   g_chatPlanCount++;
   g_chatPlanForceUpdate = true;
   ChatPlansSave();
}

void ChatPlansUpdate()
{
   if (g_chatPlanCount <= 0 || IsTesting() || IsOptimization()) return;
   datetime currentM1Bar = iTime(Symbol(), PERIOD_M1, 0);
   bool newM1Bar = (currentM1Bar > 0 && currentM1Bar != g_chatPlanLastM1Bar);
   if (!newM1Bar && !g_chatPlanForceUpdate) return;
   if (currentM1Bar > 0) g_chatPlanLastM1Bar = currentM1Bar;
   bool justAdded = g_chatPlanForceUpdate;
   g_chatPlanForceUpdate = false;
   bool changed = false;
   datetime now = TimeCurrent();
   int expireSeconds = Chat_PlanExpireHours * 3600;
   if (expireSeconds < 60) expireSeconds = 60;
   for (int pi = 0; pi < g_chatPlanCount; pi++)
   {
      if (g_chatPlanStatus[pi] != "OPEN" || g_chatPlanSymbol[pi] != Symbol()) continue;
      if (g_chatPlanSetup[pi] == "NO_TRADE")
      {
         g_chatPlanStatus[pi] = "NOT_TRIGGERED";
         g_chatPlanResolveTime[pi] = now;
         g_chatPlanNote[pi] = "SKIPPED";
         changed = true;
         continue;
      }
      int bars = iBars(Symbol(), PERIOD_M1);
      if (bars < 2) continue;
      datetime windowEnd = g_chatPlanCreateTime[pi] + expireSeconds;
      if (windowEnd > now) windowEnd = now;
      int startShift = iBarShift(Symbol(), PERIOD_M1, windowEnd, false);
      int endShift = iBarShift(Symbol(), PERIOD_M1, g_chatPlanCreateTime[pi], false);
      if (startShift < 1) startShift = 1;
      if (endShift < startShift) continue;
      if (endShift >= bars) endShift = bars - 1;
      if (!justAdded && g_chatPlanLastShift[pi] == 1)
      {
         startShift = 1;
         endShift = 1;
      }
      for (int shift = endShift; shift >= startShift; shift--)
      {
         datetime barTime = iTime(Symbol(), PERIOD_M1, shift);
         if (barTime <= 0 || barTime < g_chatPlanCreateTime[pi]) continue;
         double high = iHigh(Symbol(), PERIOD_M1, shift);
         double low = iLow(Symbol(), PERIOD_M1, shift);
         if (!g_chatPlanTriggered[pi])
         {
            bool entryHit = (g_chatPlanSetup[pi] == "BUY") ? (high >= g_chatPlanEntry[pi]) :
                            (low <= g_chatPlanEntry[pi]);
            if (!entryHit) continue;
            g_chatPlanTriggered[pi] = true;
            changed = true;
         }
         bool slHit = (g_chatPlanSetup[pi] == "BUY") ? (low <= g_chatPlanSL[pi]) :
                      (high >= g_chatPlanSL[pi]);
         bool tp1Hit = (g_chatPlanSetup[pi] == "BUY") ? (high >= g_chatPlanTP1[pi]) :
                       (low <= g_chatPlanTP1[pi]);
         bool tp2Usable = (g_chatPlanTP2[pi] > 0.0 &&
                           ((g_chatPlanSetup[pi] == "BUY" && g_chatPlanTP2[pi] > g_chatPlanEntry[pi]) ||
                            (g_chatPlanSetup[pi] == "SELL" && g_chatPlanTP2[pi] < g_chatPlanEntry[pi])));
         bool tp2Hit = tp2Usable && ((g_chatPlanSetup[pi] == "BUY") ? (high >= g_chatPlanTP2[pi]) :
                                     (low <= g_chatPlanTP2[pi]));
         if (slHit || tp1Hit || tp2Hit)
         {
            if (slHit && (tp1Hit || tp2Hit))
            {
               g_chatPlanStatus[pi] = "SL";
               g_chatPlanNote[pi] = "AMBIGUOUS";
               g_chatPlanResolveTime[pi] = barTime;
            }
            else if (tp2Hit)
            {
               g_chatPlanTP1Hit[pi] = true;
               g_chatPlanStatus[pi] = "TP2";
               g_chatPlanResolveTime[pi] = barTime;
            }
            else if (slHit)
            {
               g_chatPlanStatus[pi] = g_chatPlanTP1Hit[pi] ? "TP1" : "SL";
               g_chatPlanResolveTime[pi] = barTime;
            }
            else if (!tp2Usable)
            {
               g_chatPlanTP1Hit[pi] = true;
               g_chatPlanStatus[pi] = "TP1";
               g_chatPlanResolveTime[pi] = barTime;
            }
            else if (tp1Hit)
            {
               g_chatPlanTP1Hit[pi] = true;
               changed = true;
            }
            changed = true;
            if (g_chatPlanStatus[pi] != "OPEN") break;
         }
      }
      g_chatPlanLastShift[pi] = 1;
      if (g_chatPlanStatus[pi] == "OPEN" && now - g_chatPlanCreateTime[pi] >= expireSeconds)
      {
         g_chatPlanStatus[pi] = g_chatPlanTP1Hit[pi] ? "TP1" :
                                (g_chatPlanTriggered[pi] ? "EXPIRED" : "NOT_TRIGGERED");
         g_chatPlanResolveTime[pi] = now;
         if (!g_chatPlanTriggered[pi]) g_chatPlanNote[pi] = "ENTRY_NOT_TRADED";
         changed = true;
      }
   }
   if (changed)
   {
      ChatPlansSave();
      if (Chat_ScoreEnable) ChatLayout();
   }
}

datetime ChatStatsCutoffTime()
{
   static bool   parsed = false;
   static datetime cutoff = 0;
   if (parsed) return cutoff;
   parsed = true;
   string text = Chat_StatsStartFrom;
   StringTrimLeft(text);
   StringTrimRight(text);
   if (StringLen(text) == 0) { cutoff = 0; return cutoff; }
   cutoff = StringToTime(text);
   if (cutoff <= 0)
   {
      Print("TraceChat: Chat_StatsStartFrom nevaliden ('", text, "') - ignoriran");
      cutoff = 0;
   }
   else Print("TraceChat: statistika se broi od ", TimeToString(cutoff, TIME_DATE|TIME_MINUTES));
   return cutoff;
}

bool ChatPlanInStatsPeriod(datetime t)
{
   datetime cut = ChatStatsCutoffTime(); if (cut > 0 && t < cut) return false;
   string mode = Chat_StatsResetPeriod;
   StringTrimLeft(mode);
   StringTrimRight(mode);
   StringToUpper(mode);
   if (mode == "NEVER") return true;
   if (mode != "WEEKLY" && mode != "MONTHLY") return true;
   datetime now = TimeCurrent();
   datetime dayStart = StringToTime(TimeToString(now, TIME_DATE));
   if (mode == "MONTHLY")
      return (TimeYear(t) == TimeYear(now) && TimeMonth(t) == TimeMonth(now));
   int dow = TimeDayOfWeek(dayStart);
   int daysFromMonday = (dow == 0) ? 6 : dow - 1;
   datetime weekStart = dayStart - daysFromMonday * 86400;
   return (t >= weekStart);
}

string ChatPlanScoreLine()
{
   int total = 0; int tp1 = 0; int tp2 = 0; int sl = 0; int expired = 0; int notTriggered = 0;
   int skipped = 0;
   int resolved = 0; double rrSum = 0.0;
   int buyWin = 0; int buyLoss = 0; int sellWin = 0; int sellLoss = 0;
   int watchTotal = 0; int watchTp1 = 0; int watchTp2 = 0; int watchSl = 0;
   int watchExpired = 0; int watchNotTriggered = 0;
   string last = "";
   for (int i = 0; i < g_chatPlanCount; i++)
   {
      if (g_chatPlanSymbol[i] != Symbol()) continue;
      if (!ChatPlanInStatsPeriod(g_chatPlanCreateTime[i])) continue;
      if (g_chatPlanIsWatch[i])
      {
         if (g_chatPlanSetup[i] == "NO_TRADE") continue;
         watchTotal++;
         if (g_chatPlanStatus[i] == "TP1") watchTp1++;
         else if (g_chatPlanStatus[i] == "TP2") watchTp2++;
         else if (g_chatPlanStatus[i] == "SL") watchSl++;
         else if (g_chatPlanStatus[i] == "EXPIRED") watchExpired++;
         else if (g_chatPlanStatus[i] == "NOT_TRIGGERED") watchNotTriggered++;
         continue;
      }
      if (g_chatPlanSetup[i] == "NO_TRADE") { skipped++; continue; }
      total++;
      if (g_chatPlanStatus[i] == "TP1") { tp1++; resolved++; rrSum += g_chatPlanRR[i]; }
      else if (g_chatPlanStatus[i] == "TP2") { tp2++; resolved++; rrSum += g_chatPlanRR[i]; }
      else if (g_chatPlanStatus[i] == "SL") { sl++; resolved++; rrSum += g_chatPlanRR[i]; }
      else if (g_chatPlanStatus[i] == "EXPIRED") expired++;
      else if (g_chatPlanStatus[i] == "NOT_TRIGGERED") notTriggered++;
      if (g_chatPlanStatus[i] == "TP1" || g_chatPlanStatus[i] == "TP2")
      {
         if (g_chatPlanSetup[i] == "BUY") buyWin++; else if (g_chatPlanSetup[i] == "SELL") sellWin++;
      }
      else if (g_chatPlanStatus[i] == "SL")
      {
         if (g_chatPlanSetup[i] == "BUY") buyLoss++; else if (g_chatPlanSetup[i] == "SELL") sellLoss++;
      }
   }
   int shown = 0;
   for (int i2 = g_chatPlanCount - 1; i2 >= 0 && shown < 10; i2--)
   {
      if (g_chatPlanSymbol[i2] != Symbol()) continue;
      if (!ChatPlanInStatsPeriod(g_chatPlanCreateTime[i2])) continue;
      if (Chat_StatsDisplayFix && g_chatPlanIsWatch[i2]) continue;
      if (g_chatPlanStatus[i2] != "TP1" && g_chatPlanStatus[i2] != "TP2" &&
          g_chatPlanStatus[i2] != "SL") continue;
      last += (g_chatPlanStatus[i2] == "TP2") ? "2" :
              ((g_chatPlanStatus[i2] == "TP1") ? "T" : "S");
      shown++;
   }
   int wins = tp1 + tp2;
   double accuracy = (resolved > 0) ? (100.0 * wins / resolved) : 0.0;
   double avgRR = (resolved > 0) ? rrSum / resolved : 0.0;
   double buyAcc = (buyWin + buyLoss > 0) ? (100.0 * buyWin / (buyWin + buyLoss)) : 0.0;
   double sellAcc = (sellWin + sellLoss > 0) ? (100.0 * sellWin / (sellWin + sellLoss)) : 0.0;
   string buyStats = Chat_StatsDisplayFix ?
                     (DoubleToString(buyAcc, 1) + "% (" +
                      IntegerToString(buyWin) + "/" +
                      IntegerToString(buyWin + buyLoss) + ")") :
                     (DoubleToString(buyAcc, 1) + "%");
   string sellStats = Chat_StatsDisplayFix ?
                      (DoubleToString(sellAcc, 1) + "% (" +
                       IntegerToString(sellWin) + "/" +
                       IntegerToString(sellWin + sellLoss) + ")") :
                      (DoubleToString(sellAcc, 1) + "%");
   if (Chat_StatsDisplayFix)
   {
      if (buyWin + buyLoss <= 0) buyStats = "n/a";
      if (sellWin + sellLoss <= 0) sellStats = "n/a";
   }
   string quality = "N/A";
   if (resolved >= 5)
      quality = (accuracy >= 60.0 && avgRR >= 1.0) ? "GOOD" :
                ((accuracy < 40.0 || avgRR < 0.5) ? "WEAK" : "OK");
   string watchLine = "WATCH " + IntegerToString(watchTotal) + " | TP1 " + IntegerToString(watchTp1) +
                      " | TP2 " + IntegerToString(watchTp2) +
                      " | SL " + IntegerToString(watchSl) + " | EXPIRED " +
                      IntegerToString(watchExpired) + " | NOTRIG " + IntegerToString(watchNotTriggered);
   string watchSuffix = Chat_WatchDisableAll ? "" : ("\n" + watchLine);
   return "PLANS " + IntegerToString(total) + " | TP1 " + IntegerToString(tp1) +
          " | TP2 " + IntegerToString(tp2) +
          " | SL " + IntegerToString(sl) + " | EXPIRED " + IntegerToString(expired) +
          " | NOTRIG " + IntegerToString(notTriggered) + " | SKIPPED " +
          IntegerToString(skipped) + "\nACCURACY " +
          DoubleToString(accuracy, 1) + "% | avgRR " + DoubleToString(avgRR, 2) +
          " | Q: " + quality + " | last10: " + last + "\nBUY " + buyStats +
          " | SELL " + sellStats + watchSuffix;
}

// Sesija na planot spored chasot koga bil napraven (broker vreme).
string ChatPlanSessionOf(datetime t)
{
   int h = TimeHour(t);
   if (h >= Asia_StartHour   && h < Asia_EndHour)   return "ASIA";
   if (h >= London_StartHour && h < London_EndHour) return "LONDON";
   if (h >= NY_StartHour     && h < NY_EndHour)     return "NY";
   return "OFF";
}

string ChatPlanBucket(string label, int win, int loss)
{
   int n = win + loss;
   if (n <= 0) return label + "=n/a";
   return label + "=" + IntegerToString(win) + "/" + IntegerToString(n) + " " +
          DoubleToString(100.0 * win / n, 0) + "%";
}

double ChatPlanWinPctBySetup(string setup, int &samples)
{
   samples = 0;
   int wins = 0;
   int losses = 0;
   string want = setup;
   StringTrimLeft(want); StringTrimRight(want); StringToUpper(want);
   for (int i = 0; i < g_chatPlanCount; i++)
   {
      if (g_chatPlanSymbol[i] != Symbol()) continue;
      if (!ChatPlanInStatsPeriod(g_chatPlanCreateTime[i])) continue;
      string s = g_chatPlanSetup[i];
      StringToUpper(s);
      if (s != want) continue;
      if (g_chatPlanStatus[i] == "TP1" || g_chatPlanStatus[i] == "TP2") wins++;
      else if (g_chatPlanStatus[i] == "SL") losses++;
   }
   samples = wins + losses;
   if (samples <= 0) return -1.0;
   return 100.0 * wins / samples;
}

double ChatPlanWinPctBySession(string session, int &samples)
{
   samples = 0;
   int wins = 0;
   int losses = 0;
   for (int i = 0; i < g_chatPlanCount; i++)
   {
      if (g_chatPlanSymbol[i] != Symbol()) continue;
      if (!ChatPlanInStatsPeriod(g_chatPlanCreateTime[i])) continue;
      if (ChatPlanSessionOf(g_chatPlanCreateTime[i]) != session) continue;
      if (g_chatPlanSetup[i] == "NO_TRADE") continue;
      if (g_chatPlanStatus[i] == "TP1" || g_chatPlanStatus[i] == "TP2") wins++;
      else if (g_chatPlanStatus[i] == "SL") losses++;
   }
   samples = wins + losses;
   if (samples <= 0) return -1.0;
   return 100.0 * wins / samples;
}

double ChatPlanRecentWinPct(int maxResolved, int &samples)
{
   samples = 0;
   int wins = 0;
   int losses = 0;
   int limit = (maxResolved < 3) ? 3 : maxResolved;
   for (int i = g_chatPlanCount - 1; i >= 0 && samples < limit; i--)
   {
      if (g_chatPlanSymbol[i] != Symbol()) continue;
      if (!ChatPlanInStatsPeriod(g_chatPlanCreateTime[i])) continue;
      if (g_chatPlanStatus[i] == "TP1" || g_chatPlanStatus[i] == "TP2") { wins++; samples++; }
      else if (g_chatPlanStatus[i] == "SL") { losses++; samples++; }
   }
   if (samples <= 0) return -1.0;
   return 100.0 * wins / samples;
}

int ChatScoutRequiredConf(string setup, string &why)
{
   why = "";
   int need = Chat_ScoutMinConf;
   if (!Chat_FeedbackEnable) return need;

   int minN = (Chat_FeedbackMinSamples < 3) ? 3 : Chat_FeedbackMinSamples;
   string parts = "";

   int dirN = 0;
   double dirWp = ChatPlanWinPctBySetup(setup, dirN);
   if (dirN >= minN && dirWp >= 0.0 && dirWp < Chat_FeedbackWeakWinPct)
   {
      need = MathMax(need, 85);
      parts += setup + " istorija " + DoubleToString(dirWp, 0) + "%/" + IntegerToString(dirN);
   }

   string nowSession = ChatPlanSessionOf(TimeCurrent());
   int sesN = 0;
   double sesWp = ChatPlanWinPctBySession(nowSession, sesN);
   if (sesN >= minN && sesWp >= 0.0 && sesWp < Chat_FeedbackWeakWinPct)
   {
      need = MathMax(need, 80);
      if (StringLen(parts) > 0) parts += "; ";
      parts += nowSession + " session " + DoubleToString(sesWp, 0) + "%/" + IntegerToString(sesN);
   }

   int recentN = 0;
   double recentWp = ChatPlanRecentWinPct(6, recentN);
   if (recentN >= 6 && recentWp >= 0.0 && recentWp < 34.0)
   {
      need = MathMax(need, 90);
      if (StringLen(parts) > 0) parts += "; ";
      parts += "last" + IntegerToString(recentN) + "=" + DoubleToString(recentWp, 0) + "%";
   }

   if (StringLen(parts) > 0)
      why = "history guard -> min CONF " + IntegerToString(need) + " (" + parts + ")";
   return need;
}

// FEEDBACK JAMKA: EA gi meri sopstvenite planovi (TP1/TP2 vs SL) i mu vrakja na AI
// razbieno po nasoka / sesija / confidence, plus gotovi pravila za slabite grupi.
string ChatPlanAccuracyContext()
{
   int total = 0; int tp1 = 0; int tp2 = 0; int sl = 0; int expired = 0; int notTriggered = 0;
   int skipped = 0; double rrSum = 0.0;
   int buyW = 0; int buyL = 0; int sellW = 0; int sellL = 0;
   int sessW[4];
   int sessL[4];
   int confW[4];
   int confL[4];
   ArrayInitialize(sessW, 0);
   ArrayInitialize(sessL, 0);
   ArrayInitialize(confW, 0);
   ArrayInitialize(confL, 0);

   for (int i = 0; i < g_chatPlanCount; i++)
   {
      if (g_chatPlanSymbol[i] != Symbol()) continue;
      if (!ChatPlanInStatsPeriod(g_chatPlanCreateTime[i])) continue;
      if (g_chatPlanSetup[i] == "NO_TRADE") { skipped++; continue; }
      total++;
      if      (g_chatPlanStatus[i] == "EXPIRED")       expired++;
      else if (g_chatPlanStatus[i] == "NOT_TRIGGERED") notTriggered++;
      bool isWin  = (g_chatPlanStatus[i] == "TP1" || g_chatPlanStatus[i] == "TP2");
      bool isLoss = (g_chatPlanStatus[i] == "SL");
      if (!isWin && !isLoss) continue;
      if (g_chatPlanStatus[i] == "TP1") tp1++;
      else if (g_chatPlanStatus[i] == "TP2") tp2++;
      else sl++;
      rrSum += g_chatPlanRR[i];

      if (g_chatPlanSetup[i] == "BUY") { if (isWin) buyW++;  else buyL++; }
      else                             { if (isWin) sellW++; else sellL++; }

      string ses = ChatPlanSessionOf(g_chatPlanCreateTime[i]);
      int si = (ses == "ASIA") ? 0 : ((ses == "LONDON") ? 1 : ((ses == "NY") ? 2 : 3));
      if (isWin) sessW[si]++; else sessL[si]++;

      double cf = g_chatPlanConf[i];
      int ci = (cf < 70.0) ? 0 : ((cf < 80.0) ? 1 : ((cf < 90.0) ? 2 : 3));
      if (isWin) confW[ci]++; else confL[ci]++;
   }

   int resolved = tp1 + tp2 + sl;
   double accuracy = (resolved > 0) ? (100.0 * (tp1 + tp2) / resolved) : 0.0;
   double avgRR    = (resolved > 0) ? rrSum / resolved : 0.0;
   string outText = "\nPLAN_ACCURACY plans=" + IntegerToString(total) + " tp1=" + IntegerToString(tp1) +
          " tp2=" + IntegerToString(tp2) +
          " sl=" + IntegerToString(sl) + " expired=" + IntegerToString(expired) +
          " not_triggered=" + IntegerToString(notTriggered) + " skipped=" + IntegerToString(skipped) +
          " hit_rate=" + DoubleToString(accuracy, 1) + "% avgRR=" + DoubleToString(avgRR, 2) +
          " (EA tracked proposed plans; be conservative if weak)\n";
   if (!Chat_FeedbackEnable) return outText;

   outText += "PLAN_BY_DIR " + ChatPlanBucket("BUY", buyW, buyL) + " " +
              ChatPlanBucket("SELL", sellW, sellL) + "\n";
   outText += "PLAN_BY_SESSION " + ChatPlanBucket("ASIA", sessW[0], sessL[0]) + " " +
              ChatPlanBucket("LONDON", sessW[1], sessL[1]) + " " +
              ChatPlanBucket("NY", sessW[2], sessL[2]) + " " +
              ChatPlanBucket("OFF", sessW[3], sessL[3]) + "\n";
   outText += "PLAN_BY_CONF " + ChatPlanBucket("lt70", confW[0], confL[0]) + " " +
              ChatPlanBucket("70_79", confW[1], confL[1]) + " " +
              ChatPlanBucket("80_89", confW[2], confL[2]) + " " +
              ChatPlanBucket("90_plus", confW[3], confL[3]) + "\n";

   string last = "";
   int shown = 0;
   for (int k = g_chatPlanCount - 1; k >= 0 && shown < 10; k--)
   {
      if (g_chatPlanSymbol[k] != Symbol()) continue;
      if (!ChatPlanInStatsPeriod(g_chatPlanCreateTime[k])) continue;
      if (g_chatPlanStatus[k] != "TP1" && g_chatPlanStatus[k] != "TP2" &&
          g_chatPlanStatus[k] != "SL") continue;
      if (g_chatPlanStatus[k] == "TP2") last += "2";
      else if (g_chatPlanStatus[k] == "TP1") last += "T";
      else last += "S";
      shown++;
   }
   if (StringLen(last) == 0) last = "nema";
   outText += "PLAN_LAST10 " + last + " (najnov prv)\n";

   // Gotovi pravila: samo grupi so dovolno primeroci se tretiraat kako dokaz.
   int minN = (Chat_FeedbackMinSamples < 3) ? 3 : Chat_FeedbackMinSamples;
   string rules = "";
   string labels[10];
   int    wins[10];
   int    losses[10];
   labels[0] = "BUY";      wins[0] = buyW;     losses[0] = buyL;
   labels[1] = "SELL";     wins[1] = sellW;    losses[1] = sellL;
   labels[2] = "ASIA";     wins[2] = sessW[0]; losses[2] = sessL[0];
   labels[3] = "LONDON";   wins[3] = sessW[1]; losses[3] = sessL[1];
   labels[4] = "NY";       wins[4] = sessW[2]; losses[4] = sessL[2];
   labels[5] = "OFF";      wins[5] = sessW[3]; losses[5] = sessL[3];
   labels[6] = "CONF_lt70";  wins[6] = confW[0]; losses[6] = confL[0];
   labels[7] = "CONF_70_79"; wins[7] = confW[1]; losses[7] = confL[1];
   labels[8] = "CONF_80_89"; wins[8] = confW[2]; losses[8] = confL[2];
   labels[9] = "CONF_90_plus"; wins[9] = confW[3]; losses[9] = confL[3];
   for (int r = 0; r < 10; r++)
   {
      int n = wins[r] + losses[r];
      if (n < minN) continue;
      double wp = 100.0 * wins[r] / n;
      if (wp >= Chat_FeedbackWeakWinPct) continue;
      if (StringLen(rules) > 0) rules += "; ";
      rules += labels[r] + " samo " + DoubleToString(wp, 0) + "% na " + IntegerToString(n) +
               " planovi -> baraj posilen dokaz ili NO_TRADE";
   }
   if (StringLen(rules) == 0)
      rules = "nema slaba grupa so barem " + IntegerToString(minN) + " zatvoreni planovi";
   outText += "PLAN_FEEDBACK_RULE " + rules + "\n";
   return outText;
}

// ═══════════════════════════════════════════════════════════════════════════════
//  WAIT_FOR TRIGGER - AI vrakja USLOV, EA go proveruva lokalno na sekoj tick.
//  Taka ne se troshat tokeni dodeka se cheka, a vlezot ne docni.
// ═══════════════════════════════════════════════════════════════════════════════
string ChatTriggerTypeName(int type)
{
   if (type == TRIG_TOUCH)       return "TOUCH";
   if (type == TRIG_CLOSE_ABOVE) return "CLOSE_ABOVE";
   if (type == TRIG_CLOSE_BELOW) return "CLOSE_BELOW";
   if (type == TRIG_SWEEP_BELOW) return "SWEEP_BELOW";
   if (type == TRIG_SWEEP_ABOVE) return "SWEEP_ABOVE";
   return "NONE";
}

string ChatTriggerDescribe()
{
   if (!g_trigActive) return "";
   string dir = (g_trigDir == 1) ? "BUY" : "SELL";
   return dir + " " + ChatTriggerTypeName(g_trigType) + " " +
          DoubleToString(g_trigLevel, Digits) + " " + TimeframeToString(g_trigTF) +
          " do " + TimeToString(g_trigUntil, TIME_MINUTES);
}

bool ChatTriggerParse(string raw, int &type, double &level, int &tf)
{
   type = TRIG_NONE; level = 0.0; tf = 0;
   string t = raw;
   StringTrimLeft(t); StringTrimRight(t); StringToUpper(t);
   if (StringLen(t) == 0 || t == "NONE" || t == "N/A" || t == "-") return false;
   string raw2[]; int rawCount = StringSplit(t, 32, raw2);
   string parts[8]; int n = 0;
   for (int i = 0; i < rawCount && n < 8; i++)
   {
      string piece = raw2[i];
      StringTrimLeft(piece); StringTrimRight(piece);
      if (StringLen(piece) == 0) continue;
      parts[n] = piece; n++;
   }
   if (n < 2) return false;
   if      (parts[0] == "TOUCH")       type = TRIG_TOUCH;
   else if (parts[0] == "CLOSE_ABOVE") type = TRIG_CLOSE_ABOVE;
   else if (parts[0] == "CLOSE_BELOW") type = TRIG_CLOSE_BELOW;
   else if (parts[0] == "SWEEP_BELOW") type = TRIG_SWEEP_BELOW;
   else if (parts[0] == "SWEEP_ABOVE") type = TRIG_SWEEP_ABOVE;
   else return false;
   level = StringToDouble(parts[1]);
   if (level <= 0.0) return false;
   if (n >= 3) tf = ChatVisionTfFromName(parts[2]);
   if (tf <= 0) tf = ChatScoutTf();
   return true;
}

void ChatTriggerSave()
{
   string p = "TraceChatTrig_" + Symbol() + "_";
   GlobalVariableSet(p + "active", g_trigActive ? 1.0 : 0.0);
   GlobalVariableSet(p + "dir",    (double)g_trigDir);
   GlobalVariableSet(p + "type",   (double)g_trigType);
   GlobalVariableSet(p + "level",  g_trigLevel);
   GlobalVariableSet(p + "tf",     (double)g_trigTF);
   GlobalVariableSet(p + "until",  (double)g_trigUntil);
   GlobalVariableSet(p + "entry",  g_trigEntry);
   GlobalVariableSet(p + "sl",     g_trigSL);
   GlobalVariableSet(p + "tp1",    g_trigTP1);
   GlobalVariableSet(p + "tp2",    g_trigTP2);
   GlobalVariableSet(p + "rr",     g_trigRR);
   GlobalVariableSet(p + "conf",   g_trigConf);
}

void ChatTriggerLoad()
{
   g_trigActive = false;
   string p = "TraceChatTrig_" + Symbol() + "_";
   if (!GlobalVariableCheck(p + "active")) return;
   if (GlobalVariableGet(p + "active") < 0.5) return;
   g_trigDir   = (int)GlobalVariableGet(p + "dir");
   g_trigType  = (int)GlobalVariableGet(p + "type");
   g_trigLevel = GlobalVariableGet(p + "level");
   g_trigTF    = (int)GlobalVariableGet(p + "tf");
   g_trigUntil = (datetime)GlobalVariableGet(p + "until");
   g_trigEntry = GlobalVariableGet(p + "entry");
   g_trigSL    = GlobalVariableGet(p + "sl");
   g_trigTP1   = GlobalVariableGet(p + "tp1");
   g_trigTP2   = GlobalVariableGet(p + "tp2");
   g_trigRR    = GlobalVariableGet(p + "rr");
   g_trigConf  = GlobalVariableGet(p + "conf");
   if (g_trigType == TRIG_NONE || g_trigLevel <= 0.0) return;
   if (Chat_TriggerMinRR > 0.0 && g_trigRR > 0.0 && g_trigRR < Chat_TriggerMinRR)
   {
      Print("TraceChat TRIGGER ne e vraten: RR ", DoubleToString(g_trigRR, 2),
            " < ", DoubleToString(Chat_TriggerMinRR, 2), " po SL popravka.");
      ChatTriggerSave();
      return;
   }
   if (g_trigUntil > 0 && TimeCurrent() > g_trigUntil) { ChatTriggerSave(); return; }
   if (g_trigTF <= 0) g_trigTF = PERIOD_M5;
   g_trigActive  = true;
   g_trigLastBar = iTime(Symbol(), g_trigTF, 0);
   g_trigText    = ChatTriggerDescribe();
   Print("TraceChat TRIGGER vraten po restart: ", g_trigText);
}

void ChatTriggerDisarm(string why)
{
   if (!g_trigActive) return;
   Print("TraceChat TRIGGER disarm (", why, "): ", ChatTriggerDescribe());
   g_trigActive = false;
   g_trigType   = TRIG_NONE;
   g_trigLevel  = 0.0;
   g_trigUntil  = 0;
   g_trigText   = "";
   ChatTriggerSave();
}

void ChatTriggerArm(string setup, string raw, double entry, double sl,
                    double tp1, double tp2, double rr, double conf)
{
   if (!Chat_TriggerEnable) return;
   if (setup != "BUY" && setup != "SELL") { ChatTriggerDisarm("nov NO_TRADE plan"); return; }
   int type = TRIG_NONE; double level = 0.0; int tf = 0;
   if (!ChatTriggerParse(raw, type, level, tf)) return;
   double effectiveRR = rr;
   if (effectiveRR <= 0.0)
      effectiveRR = ChatPlanRRCalc(entry, sl, tp2);
   if (effectiveRR > 0.0 && Chat_TriggerMinRR > 0.0 &&
       effectiveRR < Chat_TriggerMinRR)
   {
      string why = "RR " + DoubleToString(effectiveRR, 2) + " < " +
                   DoubleToString(Chat_TriggerMinRR, 2) + " po SL popravka";
      if (g_trigActive) ChatTriggerDisarm("nov plan so nizok RR");
      else ChatTriggerSave();
      Print("TraceChat TRIGGER ODBIEN: ", why);
      ChatAppend("TRIGGER ODBIEN: " + why, clrOrange);
      ChatScoutLog("RR_TOO_LOW", setup, conf, entry, sl, tp2, why);
      return;
   }
   if (rr <= 0.0 && effectiveRR > 0.0) rr = effectiveRR;
   int maxMin = (Chat_TriggerMaxMin < 5) ? 5 : Chat_TriggerMaxMin;
   g_trigActive  = true;
   g_trigDir     = (setup == "BUY") ? 1 : -1;
   g_trigType    = type;
   g_trigLevel   = level;
   g_trigTF      = tf;
   g_trigArmed   = TimeCurrent();
   g_trigUntil   = g_trigArmed + maxMin * 60;
   g_trigLastBar = iTime(Symbol(), tf, 0);
   g_trigEntry   = entry;
   g_trigSL      = sl;
   g_trigTP1     = tp1;
   g_trigTP2     = tp2;
   g_trigRR      = rr;
   g_trigConf    = conf;
   g_trigText    = ChatTriggerDescribe();
   ChatTriggerSave();
   ChatAppend("TRIGGER armiran: " + g_trigText, clrYellow);
   Print("TraceChat TRIGGER armiran: ", g_trigText);
}

void ChatTriggerCheck()
{
   if (!Chat_TriggerEnable || !g_trigActive) return;
   if (IsTesting() || IsOptimization()) return;
   datetime now = TimeCurrent();
   if (g_trigUntil > 0 && now > g_trigUntil)
   {
      ChatAppend("TRIGGER isteche bez da se ispolni: " + g_trigText, clrOrange);
      ChatTriggerDisarm("isteche vremeto");
      ChatRefreshStatus();
      return;
   }

   bool fired = false;
   if (g_trigType == TRIG_TOUCH)
   {
      double px = (g_trigDir == 1) ? Ask : Bid;
      fired = (g_trigDir == 1) ? (px <= g_trigLevel) : (px >= g_trigLevel);
   }
   else
   {
      // Uslovi na zatvorena svekja: cenime SAMO koga ke se pojavi nova svekja.
      datetime barNow = iTime(Symbol(), g_trigTF, 0);
      if (barNow <= 0 || barNow == g_trigLastBar) return;
      g_trigLastBar = barNow;
      double c1 = iClose(Symbol(), g_trigTF, 1);
      double h1 = iHigh (Symbol(), g_trigTF, 1);
      double l1 = iLow  (Symbol(), g_trigTF, 1);
      if (c1 <= 0.0) return;
      if      (g_trigType == TRIG_CLOSE_ABOVE) fired = (c1 > g_trigLevel);
      else if (g_trigType == TRIG_CLOSE_BELOW) fired = (c1 < g_trigLevel);
      else if (g_trigType == TRIG_SWEEP_BELOW) fired = (l1 < g_trigLevel && c1 > g_trigLevel);
      else if (g_trigType == TRIG_SWEEP_ABOVE) fired = (h1 > g_trigLevel && c1 < g_trigLevel);
   }
   if (!fired) return;

   string dirText = (g_trigDir == 1) ? "BUY" : "SELL";
   string msg = ChatSanitize("TRIGGER ISPOLNET: " + dirText + " " +
                ChatTriggerTypeName(g_trigType) + " " + DoubleToString(g_trigLevel, Digits) +
                " " + TimeframeToString(g_trigTF) +
                " | entry=" + DoubleToString(g_trigEntry, Digits) +
                " SL=" + DoubleToString(g_trigSL, Digits) +
                " TP1=" + DoubleToString(g_trigTP1, Digits) +
                " TP2=" + DoubleToString(g_trigTP2, Digits) +
                " RR=" + DoubleToString(g_trigRR, 2) +
                " CONF=" + DoubleToString(g_trigConf, 0));
   ChatAppend(msg, clrLime);
   if (Chat_TriggerAlert)    Alert(msg);
   if (Chat_TriggerTelegram) SendTelegramMessage(msg);
   Print("TraceChat ", msg);
   ChatTriggerDisarm("ispolnet");
   ChatLayout();
   ChartRedraw();
}

void ChatScoreLayout()
{
   string names[5];
   names[0] = "TraceChat_Score_Back";
   names[1] = "TraceChat_Score_1";
   names[2] = "TraceChat_Score_2";
   names[3] = "TraceChat_Score_3";
   names[4] = "TraceChat_Score_4";
   int scoreY = g_chatY + ChatPanelHeight() + 3;
   if (!Chat_ScoreEnable || g_chatMinimized)
   {
      for (int hide = 0; hide < 5; hide++)
         ObjectSetInteger(0, names[hide], OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
      return;
   }
   ChatCreateRect(names[0], g_chatX, scoreY, Chat_Width, 65, Chat_BgColor);
   ChatCreateLabel(names[1], "", g_chatX + 7, scoreY + 3, Chat_Width - 14, 14, clrGold, Chat_FontSize);
   ChatCreateLabel(names[2], "", g_chatX + 7, scoreY + 18, Chat_Width - 14, 14, clrLime, Chat_FontSize);
   ChatCreateLabel(names[3], "", g_chatX + 7, scoreY + 33, Chat_Width - 14, 14, Chat_TextColor, Chat_FontSize);
    ChatCreateLabel(names[4], "", g_chatX + 7, scoreY + 48, Chat_Width - 14, 14, clrKhaki, Chat_FontSize);
   string score = ChatPlanScoreLine();
   string lines[]; int lineCount = StringSplit(score, 10, lines);
   if (lineCount > 0) ObjectSetString(0, names[1], OBJPROP_TEXT, lines[0]);
   if (lineCount > 1) ObjectSetString(0, names[2], OBJPROP_TEXT, lines[1]);
   if (lineCount > 2) ObjectSetString(0, names[3], OBJPROP_TEXT, lines[2]);
   if (lineCount > 3) ObjectSetString(0, names[4], OBJPROP_TEXT, lines[3]);
}

int ChatVisionTfFromName(string name)
{
   string u = name; StringToUpper(u);
   if (u == "M1") return PERIOD_M1;
   if (u == "M5") return PERIOD_M5;
   if (u == "M15") return PERIOD_M15;
   if (u == "M30") return PERIOD_M30;
   if (u == "H1") return PERIOD_H1;
   if (u == "H4") return PERIOD_H4;
   if (u == "D1") return PERIOD_D1;
   if (u == "W1") return PERIOD_W1;
   if (u == "MN1") return PERIOD_MN1;
   return 0;
}

string ChatVisionTfName(int tf)
{
   return TimeframeToString(tf);
}

bool ChatVisionHasTf(string tf)
{
   for (int i = 0; i < g_chatVisionCount; i++)
      if (g_chatVisionTf[i] == tf) return true;
   return false;
}

bool ChatWaitVisionFileReady(string file, int minBytes = 256, int maxBytes = 2000000, int maxWaitMs = 1200)
{
   StringReplace(file, "/", "\\");
   int loops = maxWaitMs / 50;
   if (loops < 1) loops = 1;
   int lastSize = -1;
   int stable = 0;
   for (int i = 0; i < loops; i++)
   {
      if (FileIsExist(file))
      {
         int h = FileOpen(file, FILE_READ|FILE_BIN|FILE_SHARE_READ|FILE_SHARE_WRITE);
         if (h != INVALID_HANDLE)
         {
            int size = (int)FileSize(h);
            FileClose(h);
            if (size >= minBytes && size <= maxBytes)
            {
               if (size == lastSize) stable++;
               else stable = 0;
               lastSize = size;
               if (stable >= 1) return true;
            }
            else
            {
               lastSize = size;
               stable = 0;
            }
         }
      }
      Sleep(50);
   }
   return false;
}

bool ChatVisionIsOwnedChart(long cid)
{
   string comment = ChartGetString(cid, CHART_COMMENT);
   return (AIVisionIsOurs(cid) || StringFind(comment, CHAT_VISION_TAG, 0) >= 0);
}

bool ChatVisionDrawDailyLevels(long cid)
{
   if (cid <= 0 || !Chat_VisionDrawLevels) return false;
   double dayHigh = 0.0, dayLow = 0.0, mid = 0.0;
   double lowMid = 0.0, midHigh = 0.0;
   if (!DailyLevelsGet(dayHigh, dayLow, mid, lowMid, midHigh)) return false;

   // Prompt legend contract: High=Lime, Mid-High=Orange, Mid=DodgerBlue,
   // Low-Mid=Silver, Low=Red.
   string names[5] = {"High", "MidHigh", "Mid", "LowMid", "Low"};
   double prices[5];
   color colors[5];
   int widths[5];
   prices[0] = dayHigh; prices[1] = midHigh; prices[2] = mid;
   prices[3] = lowMid; prices[4] = dayLow;
   colors[0] = clrLime; colors[1] = clrOrange; colors[2] = clrDodgerBlue;
   colors[3] = clrSilver; colors[4] = clrRed;
   widths[0] = 2; widths[1] = 1; widths[2] = 1; widths[3] = 1; widths[4] = 2;
   string prefix = "TraceChatVisionDL_" + IntegerToString((int)cid) + "_";
   bool drawn = false;
   for (int i = 0; i < 5; i++)
   {
      string name = prefix + names[i];
      if (!ObjectCreate(cid, name, OBJ_HLINE, 0, 0, prices[i]))
         continue;
      ObjectSetInteger(cid, name, OBJPROP_COLOR, colors[i]);
      ObjectSetInteger(cid, name, OBJPROP_WIDTH, widths[i]);
      ObjectSetInteger(cid, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(cid, name, OBJPROP_BACK, false);
      ObjectSetInteger(cid, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(cid, name, OBJPROP_SELECTED, false);
      ObjectSetInteger(cid, name, OBJPROP_HIDDEN, true);
      drawn = true;
   }
   return drawn;
}

bool ChatVisionWaitChart(long cid, int tf)
{
   if (cid == 0) return false;
   ChartSetSymbolPeriod(cid, Symbol(), tf);
   for (int wait = 0; wait < 8; wait++)
   {
      if (ChartSymbol(cid) == Symbol() && ChartPeriod(cid) == tf)
      {
         ChartRedraw(cid);
         Sleep(200);
         return true;
      }
      ChartRedraw(cid);
      Sleep(100);
   }
   return (ChartSymbol(cid) == Symbol() && ChartPeriod(cid) == tf);
}

// Sekoja slika si ima svoj pechat (PC vreme) za da znaeme kolku e stara TOCHNO taa slika,
// a ne samo posledniot uspeshen krug na slikanje.
string ChatShotStampKey(string tf)
{
   return "TraceChatShot_" + Symbol() + "_" + tf;
}

void ChatShotStampSet(string tf)
{
   GlobalVariableSet(ChatShotStampKey(tf), (double)TimeLocal());
}

string ChatShotLevelsKey(string tf)
{
   return "TraceChatShotLevels_" + Symbol() + "_" + tf;
}

void ChatShotLevelsSet(string tf, bool drawn)
{
   GlobalVariableSet(ChatShotLevelsKey(tf), drawn ? 1.0 : 0.0);
}

bool ChatShotLevelsGet(string tf)
{
   string key = ChatShotLevelsKey(tf);
   if (!GlobalVariableCheck(key)) return false;
   return (GlobalVariableGet(key) > 0.5);
}

datetime ChatShotStampGet(string tf)
{
   string key = ChatShotStampKey(tf);
   if (!GlobalVariableCheck(key)) return 0;
   return (datetime)GlobalVariableGet(key);
}

int ChatShotAgeSec(string tf)
{
   datetime stamp = ChatShotStampGet(tf);
   if (stamp <= 0) return -1;
   long age = (long)TimeLocal() - (long)stamp;
   if (age < 0) age = 0;
   return (int)age;
}

string ChatShotAgeText(int ageSec)
{
   if (ageSec < 0) return "?";
   if (ageSec < 90) return IntegerToString(ageSec) + "s";
   if (ageSec < 5400) return IntegerToString(ageSec / 60) + "m";
   return IntegerToString(ageSec / 3600) + "h";
}

// Slika postara od Chat_VisionStaleSec e lazen dokaz za AI - podobro da ne ja vidi.
bool ChatShotIsStale(string tf)
{
   if (Chat_VisionStaleSec <= 0) return false;
   int age = ChatShotAgeSec(tf);
   if (age < 0) return true;
   return (age > Chat_VisionStaleSec);
}

void ChatVisionBuildAges()
{
   g_chatVisionAges = "";
   for (int i = 0; i < g_chatVisionCount; i++)
   {
      if (StringLen(g_chatVisionAges) > 0) g_chatVisionAges += " ";
      g_chatVisionAges += g_chatVisionTf[i] + " " + ChatShotAgeText(ChatShotAgeSec(g_chatVisionTf[i]));
   }
}

// Frli sekoja slika koja e prestara - i kazi mu na AI koja TF nema slika.
void ChatVisionDropStale()
{
   if (Chat_VisionStaleSec <= 0) return;
   int kept = 0;
   for (int i = 0; i < g_chatVisionCount; i++)
   {
      if (ChatShotIsStale(g_chatVisionTf[i]))
      {
         string note = g_chatVisionTf[i] + "(stara " + ChatShotAgeText(ChatShotAgeSec(g_chatVisionTf[i])) + ")";
         if (StringLen(g_chatVisionSkipped) > 0) g_chatVisionSkipped += "," + note;
         else g_chatVisionSkipped = note;
         Print("TraceChat VISION DROP stale ", note);
         continue;
      }
      g_chatVisionTf[kept] = g_chatVisionTf[i];
      g_chatVisionFile[kept] = g_chatVisionFile[i];
      kept++;
   }
   g_chatVisionCount = kept;
}

// Svejkata na scout TF: dodeka trae istata svejka slikite se validni, nova svejka = novo slikanje.
datetime ChatVisionSyncBar()
{
   int tf = ChatVisionTfFromName(Chat_ScoutTF);
   if (tf <= 0) tf = Period();
   if (Period() < tf && Period() > 0) tf = Period();
   return iTime(Symbol(), tf, 0);
}

// Po re-init (smena na Inputs) listata e prazna a chatshot_*.png se uste na disk.
void ChatVisionRebuildFromDisk()
{
   g_chatVisionCount = 0;
   int maxShots = Chat_VisionMaxShots;
   if (maxShots < 1) maxShots = 1;
   if (maxShots > 4) maxShots = 4;
   string wanted[]; int wantedCount = StringSplit(Chat_VisionTFs, 44, wanted);
   string names[5]; int nameCount = 0;
   string currentName = ChatVisionTfName(Period());
   bool currentInList = false;
   for (int ci = 0; ci < wantedCount; ci++)
   {
      string ciName = wanted[ci];
      StringTrimLeft(ciName); StringTrimRight(ciName); StringToUpper(ciName);
      if (ciName == currentName) currentInList = true;
   }
   if (currentInList || !Chat_VisionSkipCurrentTF || wantedCount <= 0)
   {
      names[0] = currentName; nameCount = 1;
   }
   for (int wi = 0; wi < wantedCount && nameCount < 5; wi++)
   {
      string one = wanted[wi];
      StringTrimLeft(one); StringTrimRight(one); StringToUpper(one);
      if (StringLen(one) == 0) continue;
      bool dup = false;
      for (int di = 0; di < nameCount; di++) if (names[di] == one) dup = true;
      if (dup) continue;
      names[nameCount] = one; nameCount++;
   }
   for (int ni = 0; ni < nameCount && g_chatVisionCount < maxShots; ni++)
   {
      if (!FileIsExist("TraceAI\\chatshot_" + names[ni] + ".png")) continue;
      if (ChatShotIsStale(names[ni]))
      {
         Print("TraceChat VISION rebuild: preskoknata stara slika ", names[ni],
               " (", ChatShotAgeText(ChatShotAgeSec(names[ni])), ")");
         continue;
      }
      g_chatVisionTf[g_chatVisionCount]   = names[ni];
      g_chatVisionFile[g_chatVisionCount] = "TraceAI/chatshot_" + names[ni] + ".png";
      g_chatVisionCount++;
   }
   g_chatVisionLevelsDrawn = (g_chatVisionCount > 0);
   for (int li = 0; li < g_chatVisionCount; li++)
   {
      if (!ChatShotLevelsGet(g_chatVisionTf[li]))
      {
         g_chatVisionLevelsDrawn = false;
         break;
      }
   }
}

string ChatVisionCapture()
{
   if (!Chat_Vision) return "";

   // REUSE: ako postoechkite sliki se pomladi od Chat_VisionMaxAgeSec, NE slikaj povtorno.
   // Inaku scout/auto-plan/chat povicite pravat novo slikanje sekoj pat (dvojno slikanje).
   if (g_chatVisionShotLocal == 0) g_chatVisionShotLocal = VisionShotStampGet("chat");
   if (g_chatVisionCount == 0 && g_chatVisionShotLocal > 0) ChatVisionRebuildFromDisk();
   long chatAge = (long)TimeLocal() - (long)g_chatVisionShotLocal;
   datetime syncBar = ChatVisionSyncBar();
   bool sameBar = (!Chat_VisionBarSync || (g_chatVisionShotBar > 0 && g_chatVisionShotBar == syncBar));
   if (Chat_VisionMaxAgeSec > 0 && g_chatVisionCount > 0 && g_chatVisionShotLocal > 0 &&
       chatAge >= 0 && chatAge < Chat_VisionMaxAgeSec && sameBar)
   {
      g_chatVisionSkipped = "";
      int reuseMaxShots = Chat_VisionMaxShots;
      if (reuseMaxShots < 1) reuseMaxShots = 1;
      if (reuseMaxShots > 4) reuseMaxShots = 4;
      string reuseWanted[];
      int reuseWantedCount = StringSplit(Chat_VisionTFs, 44, reuseWanted);
      string reuseRequired[5];
      bool reuseWasStale[5];
      int reuseRequiredCount = 0;
      string reuseCurrent = ChatVisionTfName(Period());
      bool reuseCurrentInList = false;
      for (int rci = 0; rci < reuseWantedCount; rci++)
      {
         string rciName = reuseWanted[rci];
         StringTrimLeft(rciName); StringTrimRight(rciName); StringToUpper(rciName);
         if (rciName == reuseCurrent) reuseCurrentInList = true;
      }
      if (reuseCurrentInList || !Chat_VisionSkipCurrentTF || reuseWantedCount <= 0)
      {
         reuseRequired[0] = reuseCurrent;
         reuseRequiredCount = 1;
      }
      for (int rwi = 0; rwi < reuseWantedCount && reuseRequiredCount < 5; rwi++)
      {
         string reuseOne = reuseWanted[rwi];
         StringTrimLeft(reuseOne); StringTrimRight(reuseOne); StringToUpper(reuseOne);
         if (StringLen(reuseOne) == 0) continue;
         bool reuseDup = false;
         for (int rdi = 0; rdi < reuseRequiredCount; rdi++)
            if (reuseRequired[rdi] == reuseOne) reuseDup = true;
         if (reuseDup) continue;
         reuseRequired[reuseRequiredCount] = reuseOne;
         reuseRequiredCount++;
      }
      for (int rsi = 0; rsi < reuseRequiredCount && rsi < reuseMaxShots; rsi++)
         reuseWasStale[rsi] = ChatVisionHasTf(reuseRequired[rsi]) &&
                              ChatShotIsStale(reuseRequired[rsi]);
      ChatVisionDropStale();
      g_chatVisionLevelsDrawn = (g_chatVisionCount > 0);
      for (int li = 0; li < g_chatVisionCount; li++)
      {
         if (!ChatShotLevelsGet(g_chatVisionTf[li]))
         {
            g_chatVisionLevelsDrawn = false;
            break;
         }
      }
      ChatVisionBuildAges();
      bool reuseComplete = true;
      string reuseIncomplete = "";
      for (int rci = 0; rci < reuseRequiredCount && rci < reuseMaxShots; rci++)
      {
         if (ChatVisionHasTf(reuseRequired[rci])) continue;
         reuseComplete = false;
         string reuseIssue = reuseWasStale[rci] ? "stale" : "missing";
         if (StringLen(reuseIncomplete) > 0) reuseIncomplete += ",";
         reuseIncomplete += reuseRequired[rci] + "(" + reuseIssue + ")";
      }
      if (reuseComplete)
      {
         Print("TraceChat VISION SKIP (reuse): slikite se stari ", chatAge, "s od ",
               Chat_VisionMaxAgeSec, "s (ista svejka). Vozrast: ", g_chatVisionAges);
         g_chatVisionFallback = false;
         if (g_chatVisionCount > 0) return ChatVisionJson();
         Print("TraceChat VISION: site sliki bea prestari - slikam povtorno.");
      }
      else
      {
         Print("TraceChat VISION REUSE INCOMPLETE: ", reuseIncomplete,
               " -> slikam odnovo.");
      }
   }

   g_chatVisionLevelsDrawn = false;
   g_chatVisionCount = 0;
   g_chatVisionSkipped = "";
   g_chatVisionFallback = false;
   int width = (Chat_VisionWidth < 320) ? 1024 : Chat_VisionWidth;
   int height = (Chat_VisionHeight < 240) ? 600 : Chat_VisionHeight;
   int maxShots = Chat_VisionMaxShots;
   if (maxShots < 1) maxShots = 1;
   if (maxShots > 4) maxShots = 4;
   bool allowOpenMissing = (Chat_VisionOpenMissing &&
                            (Chat_VisionOwnCharts || !ChatVisionIsOwnedChart(ChartID())));
   int chartTotal = 0;
   long chartCountId = ChartFirst();
   while (chartCountId >= 0 && chartTotal < 200)
   {
      chartTotal++;
      chartCountId = ChartNext(chartCountId);
   }
   int hdir = FileOpen("TraceAI\\__chatshotdir__.tmp", FILE_WRITE|FILE_BIN);
   if (hdir != INVALID_HANDLE)
   {
      FileWriteInteger(hdir, 79, 1);
      FileClose(hdir);
      FileDelete("TraceAI\\__chatshotdir__.tmp");
   }
   string requested[]; int requestedCount = StringSplit(Chat_VisionTFs, 44, requested);
   string currentTf = ChatVisionTfName(Period());
   bool currentWanted = false;
   for (int cw = 0; cw < requestedCount; cw++)
   {
      string cwName = requested[cw];
      StringTrimLeft(cwName); StringTrimRight(cwName); StringToUpper(cwName);
      if (cwName == currentTf) currentWanted = true;
   }
   // Ako TF-to na ovoj chart ne e vo listata, ne mu davame mesto od Chat_VisionMaxShots -
   // inache poslednata TF od listata (npr H1) nikogash ne se slika.
   bool shootCurrent = (currentWanted || !Chat_VisionSkipCurrentTF || requestedCount <= 0);
   string currentFile = "TraceAI\\chatshot_" + currentTf + ".png";
   if (shootCurrent)
   {
      ChartRedraw(0);
      if (ChartScreenShot(0, currentFile, width, height, ALIGN_RIGHT) &&
          ChatWaitVisionFileReady(currentFile))
      {
         g_chatVisionTf[0] = currentTf;
         g_chatVisionFile[0] = "TraceAI/chatshot_" + currentTf + ".png";
         g_chatVisionCount = 1;
         ChatShotStampSet(currentTf);
         ChatShotLevelsSet(currentTf, false);
         g_chatVisionLevelsDrawn = false;
      }
      else g_chatVisionSkipped = currentTf;
   }
   else Print("TraceChat VISION: ", currentTf, " ne e vo Chat_VisionTFs - ne zafakja mesto.");
   long chartId = ChartFirst();
   while (chartId >= 0 && g_chatVisionCount < maxShots)
   {
      int chartTf = ChartPeriod(chartId);
      string chartTfName = ChatVisionTfName(chartTf);
      bool wanted = false;
      for (int ri = 0; ri < requestedCount; ri++)
      {
         string req = requested[ri]; StringTrimLeft(req); StringTrimRight(req); StringToUpper(req);
         if (req == chartTfName) wanted = true;
      }
      if (wanted && !ChatVisionHasTf(chartTfName) &&
          !ChatVisionIsOwnedChart(chartId) && !Chat_VisionOwnCharts)
      {
         string shotFile = "TraceAI\\chatshot_" + chartTfName + ".png";
         ChartRedraw(chartId);
         if (ChartScreenShot(chartId, shotFile, width, height, ALIGN_RIGHT) &&
             ChatWaitVisionFileReady(shotFile))
         {
            g_chatVisionTf[g_chatVisionCount] = chartTfName;
            g_chatVisionFile[g_chatVisionCount] = "TraceAI/chatshot_" + chartTfName + ".png";
            g_chatVisionCount++;
            ChatShotStampSet(chartTfName);
            ChatShotLevelsSet(chartTfName, false);
            g_chatVisionLevelsDrawn = false;
         }
         else if (StringLen(g_chatVisionSkipped) > 0) g_chatVisionSkipped += "," + chartTfName;
         else g_chatVisionSkipped = chartTfName;
      }
      chartId = ChartNext(chartId);
   }
   for (int si = 0; si < requestedCount; si++)
   {
      string missing = requested[si]; StringTrimLeft(missing); StringTrimRight(missing); StringToUpper(missing);
      if (StringLen(missing) > 0 && !ChatVisionHasTf(missing))
      {
         int missingTf = ChatVisionTfFromName(missing);
         bool captured = false;
         bool temporaryOwned = false;
         if (allowOpenMissing && chartTotal <= 20 && missingTf != 0 && g_chatVisionCount < maxShots)
         {
            long temporary = ChartOpen(Symbol(), missingTf);
            if (temporary != 0 && temporary != ChartID())
            {
               temporaryOwned = true;
               if (StringLen(Chat_VisionTemplate) > 0)
               {
                  if (!ChartApplyTemplate(temporary, Chat_VisionTemplate))
                     Print("TraceChat VISION: template ne se vcita za ", missing,
                           " err=", GetLastError());
               }
               else if (Chat_VisionCleanChart)
               {
                  ChartSetInteger(temporary, CHART_MODE, CHART_CANDLES);
                  ChartSetInteger(temporary, CHART_COLOR_BACKGROUND, clrBlack);
                  ChartSetInteger(temporary, CHART_COLOR_FOREGROUND, clrWhite);
                  ChartSetInteger(temporary, CHART_SHOW_OHLC, false);
                  ChartSetInteger(temporary, CHART_SHOW_GRID, false);
                  ChartSetInteger(temporary, CHART_SHOW_VOLUMES, false);
                  ChartSetInteger(temporary, CHART_SHOW_ASK_LINE, false);
                  ChartSetInteger(temporary, CHART_SHOW_PERIOD_SEP, false);
                  ChartSetInteger(temporary, CHART_COLOR_CANDLE_BULL, clrLime);
                  ChartSetInteger(temporary, CHART_COLOR_CANDLE_BEAR, clrRed);
                  ChartSetInteger(temporary, CHART_COLOR_CHART_UP, clrLime);
                  ChartSetInteger(temporary, CHART_COLOR_CHART_DOWN, clrRed);
                  ChartSetInteger(temporary, CHART_COLOR_CHART_LINE, clrWhite);
                  ChartSetInteger(temporary, CHART_AUTOSCROLL, true);
                  ChartSetInteger(temporary, CHART_SHIFT, true);
               }
               else
               {
                  ChartSetInteger(temporary, CHART_SHOW_GRID, false);
                  ChartSetInteger(temporary, CHART_SHOW_PERIOD_SEP, true);
                  ChartSetInteger(temporary, CHART_AUTOSCROLL, true);
                  ChartSetInteger(temporary, CHART_SHIFT, true);
               }
               ChartSetString(temporary, CHART_COMMENT, CHAT_VISION_TAG + " " + missing);
               if (ChatVisionWaitChart(temporary, missingTf))
               {
                  bool levelsDrawn = ChatVisionDrawDailyLevels(temporary);
                  string temporaryFile = "TraceAI\\chatshot_" + missing + ".png";
                  ChartRedraw(temporary);
                  if (ChartScreenShot(temporary, temporaryFile, width, height, ALIGN_RIGHT) &&
                      ChatWaitVisionFileReady(temporaryFile))
                  {
                     g_chatVisionTf[g_chatVisionCount] = missing;
                     g_chatVisionFile[g_chatVisionCount] = "TraceAI/chatshot_" + missing + ".png";
                     g_chatVisionCount++;
                     ChatShotStampSet(missing);
                     ChatShotLevelsSet(missing, levelsDrawn);
                     if (g_chatVisionCount == 1)
                        g_chatVisionLevelsDrawn = levelsDrawn;
                     else
                        g_chatVisionLevelsDrawn = g_chatVisionLevelsDrawn && levelsDrawn;
                     captured = true;
                  }
               }
               if (temporaryOwned)
                  AIVisionCloseOwnedChart(temporary, "privremen chart " + missing);
            }
         }
         if (!captured)
         {
            if (StringLen(g_chatVisionSkipped) > 0) g_chatVisionSkipped += "," + missing;
            else g_chatVisionSkipped = missing;
         }
      }
   }
   if (g_chatVisionCount > 0)
   {
      g_chatVisionShotLocal = TimeLocal();
      g_chatVisionShotBar = syncBar;
      VisionShotStampSet("chat", g_chatVisionShotLocal);
   }
   ChatVisionDropStale();
   ChatVisionBuildAges();
   Print("TraceChat VISION SHOTS: ", (g_chatVisionCount > 0 ? g_chatVisionAges : "nema"),
         (StringLen(g_chatVisionSkipped) > 0 ? (" | preskoknato: " + g_chatVisionSkipped) : ""));
   return ChatVisionJson();
}

string ChatVisionJson()
{
   int maxShots = Chat_VisionMaxShots;
   if (maxShots < 1) maxShots = 1;
   if (maxShots > 4) maxShots = 4;
   string shots = "";
   int shotCount = g_chatVisionCount;
   if (shotCount > maxShots) shotCount = maxShots;
   for (int i = 0; i < shotCount; i++)
   {
      if (StringLen(shots) > 0) shots += ",";
      shots += "{\"tf\":\"" + ChatJsonEscape(g_chatVisionTf[i]) + "\",\"file\":\"" +
               ChatJsonEscape(g_chatVisionFile[i]) + "\"}";
   }
   return "{\"enabled\":" + (Chat_Vision ? "true" : "false") + ",\"detail\":\"" +
          ChatJsonEscape(Chat_VisionDetail) + "\",\"maxAgeSec\":" +
          IntegerToString(Chat_VisionMaxAgeSec) + ",\"maxShots\":" +
          IntegerToString(maxShots) + ",\"shots\":[" + shots + "]}";
}

bool ChatReadVisionShot(string file, uchar &data[])
{
   StringReplace(file, "/", "\\");
   int lastErr = 0;
   int lastSize = -1;
   for (int attempt = 0; attempt < 10; attempt++)
   {
      int h = FileOpen(file, FILE_READ|FILE_BIN|FILE_SHARE_READ|FILE_SHARE_WRITE);
      if (h == INVALID_HANDLE)
      {
         lastErr = GetLastError();
         Sleep(100);
         continue;
      }
      int size = (int)FileSize(h);
      lastSize = size;
      if (size <= 0 || size > 2000000)
      {
         FileClose(h);
         Sleep(100);
         continue;
      }
      ArrayResize(data, size);
      int got = (int)FileReadArray(h, data, 0, size);
      FileClose(h);
      if (got == size) return true;
      lastErr = GetLastError();
      Sleep(100);
   }
   Print("TraceChat VISION READ FAIL ", file, " size=", lastSize, " err=", lastErr,
         " postoi=", (FileIsExist(file) ? "DA" : "NE"));
   return false;
}

void ChatPlan()
{
   ChatPlanRun(false);
}

string ChatTuneB(string name, bool value)
{
   return name + "=" + (value ? "true" : "false") + " ";
}

string ChatTuneI(string name, int value)
{
   return name + "=" + IntegerToString(value) + " ";
}

string ChatTuneD(string name, double value)
{
   return name + "=" + DoubleToString(value, 4) + " ";
}

string ChatTuneS(string name, string value)
{
   return name + "=" + value + " ";
}

void ChatBuildTuneContext(string &context)
{
   string line = "";
   context = "TUNE_CONTEXT symbol=" + Symbol() + "\n";
   context += ChatCtxStats();
   context += ChatPlanAccuracyContext();
   context += "\nCURRENT_INPUTS (all listed inputs are in scope; suggestions only):\n";

   line = "OB_ZONE ";
   line += ChatTuneB("Use_OrderBlocks", Use_OrderBlocks);
   line += ChatTuneB("OB_ApplyAntiFakeFilter", OB_ApplyAntiFakeFilter);
   line += ChatTuneI("OB_LookbackBars", OB_LookbackBars);
   line += ChatTuneI("Zone_ExpiryBars", Zone_ExpiryBars);
   line += ChatTuneI("OB_LastCount", OB_LastCount);
   line += ChatTuneB("OB_UseBody", OB_UseBody);
   line += ChatTuneI("OB_PivotLen", OB_PivotLen);
   line += ChatTuneD("OB_TightenPct", OB_TightenPct);
   line += ChatTuneI("OB_ExtendBars", OB_ExtendBars);
   line += ChatTuneB("OB_MinGapFilter", OB_MinGapFilter);
   line += ChatTuneD("OB_MinGapATR", OB_MinGapATR);
   line += ChatTuneB("OB_FilterWeakBreakouts", OB_FilterWeakBreakouts);
   line += ChatTuneD("OB_MinDisplacementATR", OB_MinDisplacementATR);
   line += ChatTuneD("OB_MinCloseStrength", OB_MinCloseStrength);
   line += ChatTuneD("OB_MinBodyRatio", OB_MinBodyRatio);
   line += ChatTuneB("OB_SideFilter", OB_SideFilter);
   line += ChatTuneD("OB_SideToleranceATR", OB_SideToleranceATR);
   line += ChatTuneB("OB_OppositeGapFilter", OB_OppositeGapFilter);
   line += ChatTuneD("OB_OppositeGapATR", OB_OppositeGapATR);
   line += ChatTuneD("OB_MinZoneHeightATR", OB_MinZoneHeightATR);
   line += ChatTuneD("OB_MaxZoneHeightATR", OB_MaxZoneHeightATR);
   line += ChatTuneS("OB_MitigationMethod", OB_MitigationMethod);
   line += ChatTuneI("ZoneLookback", ZoneLookback);
   line += ChatTuneI("Buy_MaxZones", Buy_MaxZones);
   line += ChatTuneI("Sell_MaxZones", Sell_MaxZones);
   line += ChatTuneB("Use_Extreme_HighLow", Use_Extreme_HighLow);
   line += ChatTuneI("Extreme_Lookback", Extreme_Lookback);
   line += ChatTuneD("Min_Impulse_ATR", Min_Impulse_ATR);
   line += ChatTuneB("Use_Impulse_Filter", Use_Impulse_Filter);
   line += ChatTuneB("Use_Volume_Impulse_Filter", Use_Volume_Impulse_Filter);
   line += ChatTuneD("Buy_MinZoneDistance", Buy_MinZoneDistance);
   line += ChatTuneD("Buy_MaxZoneHeightATR", Buy_MaxZoneHeightATR);
   line += ChatTuneD("Buy_MinBodyRatio", Buy_MinBodyRatio);
   line += ChatTuneD("Sell_MinZoneDistance", Sell_MinZoneDistance);
   line += ChatTuneD("Sell_MaxZoneHeightATR", Sell_MaxZoneHeightATR);
   line += ChatTuneD("Sell_MinBodyRatio", Sell_MinBodyRatio);
   line += ChatTuneB("Zone_ExtendToNeighborWicks", Zone_ExtendToNeighborWicks);
   line += ChatTuneI("Zone_NeighborWickBars", Zone_NeighborWickBars);
   line += ChatTuneD("Zone_MaxWickExtendATR", Zone_MaxWickExtendATR);
   context += line + "\n";

   line = "ANTI_FAKE ";
   line += ChatTuneB("Use_AntiFakeFilter", Use_AntiFakeFilter);
   line += ChatTuneI("AntiFake_MaxSoftFails", AntiFake_MaxSoftFails);
   line += ChatTuneB("AntiFake_BlockBrokenZones", AntiFake_BlockBrokenZones);
   line += ChatTuneB("AntiFake_RequireCleanDeparture", AntiFake_RequireCleanDeparture);
   line += ChatTuneD("AntiFake_MinDepartureATR", AntiFake_MinDepartureATR);
   line += ChatTuneI("AntiFake_DepartureBars", AntiFake_DepartureBars);
   line += ChatTuneB("AntiFake_BlockChop", AntiFake_BlockChop);
   line += ChatTuneB("AntiFake_BlockChopNow", AntiFake_BlockChopNow);
   line += ChatTuneB("AntiFake_BlockBBSqueeze", AntiFake_BlockBBSqueeze);
   line += ChatTuneI("AntiFake_BB_TF", AntiFake_BB_TF);
   line += ChatTuneI("AntiFake_BB_Period", AntiFake_BB_Period);
   line += ChatTuneD("AntiFake_BB_Dev", AntiFake_BB_Dev);
   line += ChatTuneD("AntiFake_MinBBWidthATR", AntiFake_MinBBWidthATR);
   line += ChatTuneI("AntiFake_ChopLookback", AntiFake_ChopLookback);
   line += ChatTuneD("AntiFake_MinRangeATR", AntiFake_MinRangeATR);
   line += ChatTuneI("AntiFake_MaxColorChanges", AntiFake_MaxColorChanges);
   line += ChatTuneB("AntiFake_BlockCounterTrend", AntiFake_BlockCounterTrend);
   line += ChatTuneB("Use_ImpulseBaseRatioFilter", Use_ImpulseBaseRatioFilter);
   line += ChatTuneD("IBR_MinRatio", IBR_MinRatio);
   line += ChatTuneI("IBR_ImpulseBars", IBR_ImpulseBars);
   line += ChatTuneD("IBR_MinImpulseATR", IBR_MinImpulseATR);
   context += line + "\n";

   line = "QUALITY ";
   line += ChatTuneB("Use_ConsolidationFilter", Use_ConsolidationFilter);
   line += ChatTuneB("Consol_BlockFlatEMA", Consol_BlockFlatEMA);
   line += ChatTuneI("Consol_EMA_Period", Consol_EMA_Period);
   line += ChatTuneI("Consol_EMA_SlopeBars", Consol_EMA_SlopeBars);
   line += ChatTuneD("Consol_MaxEMASlopeATR", Consol_MaxEMASlopeATR);
   line += ChatTuneB("Consol_BlockTightRange", Consol_BlockTightRange);
   line += ChatTuneI("Consol_RangeLookback", Consol_RangeLookback);
   line += ChatTuneD("Consol_MaxRangeATR", Consol_MaxRangeATR);
   line += ChatTuneB("Consol_BlockZoneStacking", Consol_BlockZoneStacking);
   line += ChatTuneI("Consol_StackMaxZones", Consol_StackMaxZones);
   line += ChatTuneI("Consol_StackATRDistance", Consol_StackATRDistance);
   line += ChatTuneB("Consol_BlockInsideBarCluster", Consol_BlockInsideBarCluster);
   line += ChatTuneI("Consol_InsideBarCount", Consol_InsideBarCount);
   line += ChatTuneI("Consol_InsideBarLookback", Consol_InsideBarLookback);
   line += ChatTuneB("Use_StrongBreakoutFilter", Use_StrongBreakoutFilter);
   line += ChatTuneD("SB_MinBodyRatio", SB_MinBodyRatio);
   line += ChatTuneD("SB_MinCloseStrength", SB_MinCloseStrength);
   line += ChatTuneD("SB_MinBreakoutATR", SB_MinBreakoutATR);
   line += ChatTuneB("SB_RequireVolumeSpike", SB_RequireVolumeSpike);
   line += ChatTuneD("SB_MinVolumeRatio", SB_MinVolumeRatio);
   line += ChatTuneI("SB_VolumeLookback", SB_VolumeLookback);
   line += ChatTuneB("SB_RequireFollowThrough", SB_RequireFollowThrough);
   line += ChatTuneI("SB_FollowThroughBars", SB_FollowThroughBars);
   line += ChatTuneD("SB_MinFollowATR", SB_MinFollowATR);
   line += ChatTuneB("Use_HTFConfluenceFilter", Use_HTFConfluenceFilter);
   line += ChatTuneB("HTF_RequireTrendAlignment", HTF_RequireTrendAlignment);
   line += ChatTuneB("HTF_RequireZoneAlignment", HTF_RequireZoneAlignment);
   line += ChatTuneD("HTF_ZoneProximityATR", HTF_ZoneProximityATR);
   line += ChatTuneB("HTF_BlockCounterHTF", HTF_BlockCounterHTF);
   line += ChatTuneB("Use_FailedRetestFilter", Use_FailedRetestFilter);
   line += ChatTuneI("FR_LookbackBars", FR_LookbackBars);
   line += ChatTuneD("FR_MinPenetrationATR", FR_MinPenetrationATR);
   line += ChatTuneI("FR_MaxPenetrations", FR_MaxPenetrations);
   line += ChatTuneB("Use_WickStrengthFilter", Use_WickStrengthFilter);
   line += ChatTuneI("WS_LookbackBars", WS_LookbackBars);
   line += ChatTuneD("WS_MaxWickPenetrations", WS_MaxWickPenetrations);
   line += ChatTuneD("WS_WickPenetrationPct", WS_WickPenetrationPct);
   context += line + "\n";

   line = "SESSION_VOL ";
   line += ChatTuneB("Use_AdaptiveSessionFilter", Use_AdaptiveSessionFilter);
   line += ChatTuneD("Asia_MinBreakoutATR", Asia_MinBreakoutATR);
   line += ChatTuneD("London_MinBreakoutATR", London_MinBreakoutATR);
   line += ChatTuneD("NY_MinBreakoutATR", NY_MinBreakoutATR);
   line += ChatTuneD("Asia_MinBodyRatio", Asia_MinBodyRatio);
   line += ChatTuneD("London_MinBodyRatio", London_MinBodyRatio);
   line += ChatTuneD("NY_MinBodyRatio", NY_MinBodyRatio);
   line += ChatTuneD("Asia_MinDepartureATR", Asia_MinDepartureATR);
   line += ChatTuneD("London_MinDepartureATR", London_MinDepartureATR);
   line += ChatTuneD("NY_MinDepartureATR", NY_MinDepartureATR);
   line += ChatTuneB("Session_BlockOffHours", Session_BlockOffHours);
   line += ChatTuneI("Asia_StartHour", Asia_StartHour);
   line += ChatTuneI("Asia_EndHour", Asia_EndHour);
   line += ChatTuneI("London_StartHour", London_StartHour);
   line += ChatTuneI("London_EndHour", London_EndHour);
   line += ChatTuneI("NY_StartHour", NY_StartHour);
   line += ChatTuneI("NY_EndHour", NY_EndHour);
   line += ChatTuneB("Use_FirstZoneCooldown", Use_FirstZoneCooldown);
   line += ChatTuneI("FZC_MinBarsSinceLastZone", FZC_MinBarsSinceLastZone);
   line += ChatTuneI("FZC_ExtraConfirmBars", FZC_ExtraConfirmBars);
   line += ChatTuneD("FZC_MinFirstZoneStrength", FZC_MinFirstZoneStrength);
   line += ChatTuneB("Use_AdaptiveATRFilter", Use_AdaptiveATRFilter);
   line += ChatTuneI("AATR_PercentileLookback", AATR_PercentileLookback);
   line += ChatTuneD("AATR_LowVolPercentile", AATR_LowVolPercentile);
   line += ChatTuneD("AATR_HighVolPercentile", AATR_HighVolPercentile);
   line += ChatTuneD("AATR_LowVolMultiplier", AATR_LowVolMultiplier);
   line += ChatTuneD("AATR_HighVolMultiplier", AATR_HighVolMultiplier);
   line += ChatTuneB("Use_DayOfWeekFilter", Use_DayOfWeekFilter);
   line += ChatTuneD("DOW_MondayMultiplier", DOW_MondayMultiplier);
   line += ChatTuneD("DOW_FridayMultiplier", DOW_FridayMultiplier);
   line += ChatTuneD("DOW_TueThuMultiplier", DOW_TueThuMultiplier);
   line += ChatTuneB("DOW_BlockFridayAfterNY", DOW_BlockFridayAfterNY);
   line += ChatTuneI("DOW_FridayCutoffHour", DOW_FridayCutoffHour);
   line += ChatTuneB("Use_VolatilityRegimeFilter", Use_VolatilityRegimeFilter);
   line += ChatTuneI("VR_RegimeLookback", VR_RegimeLookback);
   line += ChatTuneD("VR_LowVolThreshold", VR_LowVolThreshold);
   line += ChatTuneD("VR_HighVolThreshold", VR_HighVolThreshold);
   line += ChatTuneD("VR_LowVolMinBreakoutATR", VR_LowVolMinBreakoutATR);
   line += ChatTuneD("VR_LowVolMinBodyRatio", VR_LowVolMinBodyRatio);
   line += ChatTuneD("VR_HighVolMinBreakoutATR", VR_HighVolMinBreakoutATR);
   context += line + "\n";

   line = "STRUCTURE ";
   line += ChatTuneB("Use_FVGConfirmationFilter", Use_FVGConfirmationFilter);
   line += ChatTuneB("FVG_RequireFVG", FVG_RequireFVG);
   line += ChatTuneI("FVG_LookbackBars", FVG_LookbackBars);
   line += ChatTuneD("FVG_MinGapATR", FVG_MinGapATR);
   line += ChatTuneB("FVG_RequireDisplacement", FVG_RequireDisplacement);
   line += ChatTuneD("FVG_DisplacementATR", FVG_DisplacementATR);
   line += ChatTuneI("FVG_DisplacementBars", FVG_DisplacementBars);
   line += ChatTuneB("Use_BOSConfirmationFilter", Use_BOSConfirmationFilter);
   line += ChatTuneI("BOS_LookbackBars_" + TimeframeToString(Period()), GetBOSLookbackBarsForTF(Period()));
   line += ChatTuneD("BOS_MinBreakATR_" + TimeframeToString(Period()), GetBOSMinBreakATRForTF(Period()));
   line += ChatTuneI("BOS_SwingLookback_" + TimeframeToString(Period()), GetBOSSwingLookbackForTF(Period()));
   line += ChatTuneD("BOS_MaxStrengthBonus_" + TimeframeToString(Period()), GetBOSMaxStrengthBonusForTF(Period()));
   line += ChatTuneB("Use_MarketStructureTrendGate", Use_MarketStructureTrendGate);
   line += ChatTuneI("MS_SwingStrength_" + TimeframeToString(GetHigherTimeframe(Period())), GetMSSwingStrengthForTF(GetHigherTimeframe(Period())));
   line += ChatTuneI("MS_LookbackBars_" + TimeframeToString(GetHigherTimeframe(Period())), GetMSLookbackBarsForTF(GetHigherTimeframe(Period())));
   line += ChatTuneD("MS_BOSBufferATR_" + TimeframeToString(GetHigherTimeframe(Period())), GetMSBOSBufferATRForTF(GetHigherTimeframe(Period())));
   line += ChatTuneB("Use_BodyClearanceFilter", Use_BodyClearanceFilter);
   line += ChatTuneD("BC_MinClearancePct", BC_MinClearancePct);
   line += ChatTuneB("Use_MinHoldTimeFilter", Use_MinHoldTimeFilter);
   line += ChatTuneI("MHT_MinHoldBars", MHT_MinHoldBars);
   line += ChatTuneD("MHT_MaxWickPct", MHT_MaxWickPct);
   line += ChatTuneB("Use_ChopIndexFilter", Use_ChopIndexFilter);
   line += ChatTuneI("CI_Period", CI_Period);
   line += ChatTuneD("CI_ChopThreshold", CI_ChopThreshold);
   line += ChatTuneD("CI_TrendThreshold", CI_TrendThreshold);
   line += ChatTuneB("CI_BlockChopZones", CI_BlockChopZones);
   line += ChatTuneB("CI_RequireTrendConfirmation", CI_RequireTrendConfirmation);
   line += ChatTuneB("Use_AutocorrelationFilter", Use_AutocorrelationFilter);
   line += ChatTuneI("AC_Lookback", AC_Lookback);
   line += ChatTuneI("AC_Lag", AC_Lag);
   line += ChatTuneD("AC_TrendThreshold", AC_TrendThreshold);
   line += ChatTuneD("AC_ChopThreshold", AC_ChopThreshold);
   line += ChatTuneB("AC_BlockNegativeAC", AC_BlockNegativeAC);
   line += ChatTuneB("Use_EfficiencyRatioFilter", Use_EfficiencyRatioFilter);
   line += ChatTuneI("ER_Period", ER_Period);
   line += ChatTuneD("ER_MinTrendRatio", ER_MinTrendRatio);
   line += ChatTuneD("ER_ChopRatio", ER_ChopRatio);
   line += ChatTuneB("ER_BlockLowEfficiency", ER_BlockLowEfficiency);
   context += line + "\n";

   line = "LOCATION_SWEEP ";
   line += ChatTuneB("Use_RSIMidRangeFilter", Use_RSIMidRangeFilter);
   line += ChatTuneI("RSI_MR_Period", RSI_MR_Period);
   line += ChatTuneD("RSI_MR_LowBound", RSI_MR_LowBound);
   line += ChatTuneD("RSI_MR_HighBound", RSI_MR_HighBound);
   line += ChatTuneI("RSI_MR_ConsecutiveBars", RSI_MR_ConsecutiveBars);
   line += ChatTuneB("RSI_MR_BlockTrapped", RSI_MR_BlockTrapped);
   line += ChatTuneB("Use_PriceLocationFilter", Use_PriceLocationFilter);
   line += ChatTuneI("PL_RangeLookback", PL_RangeLookback);
   line += ChatTuneD("PL_MidZonePct", PL_MidZonePct);
   line += ChatTuneB("PL_BlockMidRange", PL_BlockMidRange);
   line += ChatTuneB("Use_ExhaustionFilter", Use_ExhaustionFilter);
   line += ChatTuneI("Exh_Lookback", Exh_Lookback);
   line += ChatTuneD("Exh_MinRoomATR", Exh_MinRoomATR);
   line += ChatTuneB("Use_LiquiditySweepFilter", Use_LiquiditySweepFilter);
   line += ChatTuneB("Sweep_StrictMode", Sweep_StrictMode);
   line += ChatTuneD("Sweep_MinScore", Sweep_MinScore);
   line += ChatTuneI("Sweep_Lookback", Sweep_Lookback);
   line += ChatTuneD("Sweep_MinBreakPoints", Sweep_MinBreakPoints);
   line += ChatTuneB("Sweep_RequireCloseBack", Sweep_RequireCloseBack);
   line += ChatTuneB("Sweep_RequireOppositeCandle", Sweep_RequireOppositeCandle);
   line += ChatTuneD("Sweep_MinSweepBodyATR", Sweep_MinSweepBodyATR);
   line += ChatTuneD("Sweep_MinBreakoutBodyATR", Sweep_MinBreakoutBodyATR);
   line += ChatTuneI("Sweep_VolumeLookback", Sweep_VolumeLookback);
   line += ChatTuneD("Sweep_MinVolumeRatio", Sweep_MinVolumeRatio);
   line += ChatTuneD("Sweep_CloseBackATR", Sweep_CloseBackATR);
   line += ChatTuneB("Use_MSSFilter", Use_MSSFilter);
   line += ChatTuneB("MSS_StrictMode", MSS_StrictMode);
   line += ChatTuneI("MSS_PivotLookback", MSS_PivotLookback);
   line += ChatTuneD("MSS_MinBreakoutATR", MSS_MinBreakoutATR);
   context += line + "\n";

   line = "VOLUME ";
   line += ChatTuneB("Use_VolExhaustionFilter", Use_VolExhaustionFilter);
   line += ChatTuneB("VEx_RequireDecliningVolume", VEx_RequireDecliningVolume);
   line += ChatTuneI("VEx_BaseBarsToCheck", VEx_BaseBarsToCheck);
   line += ChatTuneD("VEx_MaxBaseVolRatio", VEx_MaxBaseVolRatio);
   line += ChatTuneB("VEx_BlockLowVolumeBreakout", VEx_BlockLowVolumeBreakout);
   line += ChatTuneD("VEx_MinBreakoutVolRatio", VEx_MinBreakoutVolRatio);
   line += ChatTuneB("Use_RVFilter", Use_RVFilter);
   line += ChatTuneB("RV_StrictMode", RV_StrictMode);
   line += ChatTuneI("RV_LookbackBars", RV_LookbackBars);
   line += ChatTuneD("RV_MinRatio", RV_MinRatio);
   line += ChatTuneB("Use_DeltaCVDScore", Use_DeltaCVDScore);
   line += ChatTuneI("DCVD_LookbackBars", DCVD_LookbackBars);
   line += ChatTuneI("DCVD_RecentBars", DCVD_RecentBars);
   line += ChatTuneD("DCVD_ConfirmRatio", DCVD_ConfirmRatio);
   line += ChatTuneD("DCVD_StrongRatio", DCVD_StrongRatio);
   line += ChatTuneD("DCVD_MaxStrengthBonus", DCVD_MaxStrengthBonus);
   line += ChatTuneD("DCVD_MaxStrengthPenalty", DCVD_MaxStrengthPenalty);
   line += ChatTuneB("Use_VolumeDivergenceFilter", Use_VolumeDivergenceFilter);
   line += ChatTuneB("VD_BlockTradesOnly", VD_BlockTradesOnly);
   line += ChatTuneB("VD_CountAsSoftFail", VD_CountAsSoftFail);
   line += ChatTuneB("VD_CheckPriceVolumeDivergence", VD_CheckPriceVolumeDivergence);
   line += ChatTuneB("VD_CheckClimaxExhaustion", VD_CheckClimaxExhaustion);
   line += ChatTuneI("VD_SwingLookback", VD_SwingLookback);
   line += ChatTuneI("VD_ImpulseBars", VD_ImpulseBars);
   line += ChatTuneD("VD_MinDropPct", VD_MinDropPct);
   line += ChatTuneD("VD_ClimaxVolRatio", VD_ClimaxVolRatio);
   line += ChatTuneD("VD_ClimaxMaxBodyRatio", VD_ClimaxMaxBodyRatio);
   line += ChatTuneD("VD_StrengthPenalty", VD_StrengthPenalty);
   context += line + "\n";

   line = "WICK_ATR_NEWS ";
   line += ChatTuneB("Use_BreakoutWickRejection", Use_BreakoutWickRejection);
   line += ChatTuneD("WR_MaxBreakWickPct", WR_MaxBreakWickPct);
   line += ChatTuneD("WR_MaxOppositeWickPct", WR_MaxOppositeWickPct);
   line += ChatTuneD("WR_MinBodyPct", WR_MinBodyPct);
   line += ChatTuneB("WR_CheckFollowBar", WR_CheckFollowBar);
   line += ChatTuneI("WR_FollowBars", WR_FollowBars);
   line += ChatTuneB("Use_ATRAccelerationFilter", Use_ATRAccelerationFilter);
   line += ChatTuneI("AAC_FastATR", AAC_FastATR);
   line += ChatTuneI("AAC_SlowATR", AAC_SlowATR);
   line += ChatTuneD("AAC_MinRatio", AAC_MinRatio);
   line += ChatTuneD("AAC_MinRangeATR", AAC_MinRangeATR);
   line += ChatTuneB("AAC_BlockDecelerating", AAC_BlockDecelerating);
   line += ChatTuneB("Use_NewsSpikeFilter", Use_NewsSpikeFilter);
   line += ChatTuneI("News_ATR_Period", News_ATR_Period);
   line += ChatTuneD("News_SpikeATRMultiplier", News_SpikeATRMultiplier);
   line += ChatTuneI("News_SpikeLookbackBars", News_SpikeLookbackBars);
   line += ChatTuneI("News_CooldownBars", News_CooldownBars);
   line += ChatTuneB("News_BlockAllDuringSpike", News_BlockAllDuringSpike);
   line += ChatTuneB("Use_RegimeFilter", Use_RegimeFilter);
   line += ChatTuneB("Regime_ApplyToNewZonesOnly", Regime_ApplyToNewZonesOnly);
   line += ChatTuneI("Regime_ADX_TF", Regime_ADX_TF);
   line += ChatTuneI("Regime_ADX_Period", Regime_ADX_Period);
   line += ChatTuneD("Regime_MinADX", Regime_MinADX);
   line += ChatTuneB("Regime_RequireValidADX", Regime_RequireValidADX);
   line += ChatTuneB("Regime_FilterSpread", Regime_FilterSpread);
   line += ChatTuneD("Regime_MaxSpreadPrice", Regime_MaxSpreadPrice);
   line += ChatTuneB("Regime_FilterATR", Regime_FilterATR);
   line += ChatTuneI("Regime_ATR_TF", Regime_ATR_TF);
   line += ChatTuneI("Regime_ATR_Period", Regime_ATR_Period);
   line += ChatTuneI("Regime_ATR_Lookback", Regime_ATR_Lookback);
   line += ChatTuneD("Regime_ATR_MinRatio", Regime_ATR_MinRatio);
   line += ChatTuneB("Regime_FilterRestoredZones", Regime_FilterRestoredZones);
   context += line + "\n";

   line = "ENTRY_MANAGEMENT ";
   line += ChatTuneD("Risk_Reward_Ratio", Risk_Reward_Ratio);
   line += ChatTuneI("SL_Buffer_Points", SL_Buffer_Points);
   line += ChatTuneB("Use_BreakEven", Use_BreakEven);
   line += ChatTuneD("BE_TriggerRR", BE_TriggerRR);
   line += ChatTuneD("BE_LockPoints", BE_LockPoints);
   line += ChatTuneB("Use_TrailingStop", Use_TrailingStop);
   line += ChatTuneD("Trail_StartRR", Trail_StartRR);
   line += ChatTuneD("Trail_ATRPeriod", Trail_ATRPeriod);
   line += ChatTuneD("Trail_ATRMultiplier", Trail_ATRMultiplier);
   line += ChatTuneB("Use_EntryGuard", Use_EntryGuard);
   line += ChatTuneB("Entry_RequireInsideZone", Entry_RequireInsideZone);
   line += ChatTuneD("Entry_MaxDistanceATR", Entry_MaxDistanceATR);
   line += ChatTuneB("Entry_BlockIfZoneBroken", Entry_BlockIfZoneBroken);
   line += ChatTuneB("Entry_ConvertToPendingLimit", Entry_ConvertToPendingLimit);
   line += ChatTuneB("Entry_UseATRStopOutside", Entry_UseATRStopOutside);
   line += ChatTuneD("Entry_ATRStopMult", Entry_ATRStopMult);
   line += ChatTuneD("Entry_FastTP_RR", Entry_FastTP_RR);
   line += ChatTuneD("Entry_MinRR", Entry_MinRR);
   line += ChatTuneI("Trade_MaxAgeHours", Trade_MaxAgeHours);
   line += ChatTuneB("Use_SecondPendingOrder", Use_SecondPendingOrder);
   line += ChatTuneD("Pending_EntryPct", Pending_EntryPct);
   line += ChatTuneD("Pending_Lot_Size", Pending_Lot_Size);
   line += ChatTuneB("Use_ImmediateEntry", Use_ImmediateEntry);
   line += ChatTuneB("AutoTrade_OnRetest", AutoTrade_OnRetest);
   line += ChatTuneB("AutoTrade_RespectTimeFilter", AutoTrade_RespectTimeFilter);
   line += ChatTuneB("AutoTrade_CurrentChartTFOnly", AutoTrade_CurrentChartTFOnly);
   line += ChatTuneB("Use_Volume_Confirmation", Use_Volume_Confirmation);
   line += ChatTuneI("Volume_Lookback_Period", Volume_Lookback_Period);
   line += ChatTuneD("Volume_Multiplier", Volume_Multiplier);
   line += ChatTuneD("Retest_Max_Volume_Multiplier", Retest_Max_Volume_Multiplier);
   line += ChatTuneB("Use_PinBar_Filter", Use_PinBar_Filter);
   line += ChatTuneB("Use_Engulfing_Filter", Use_Engulfing_Filter);
   line += ChatTuneB("Use_RiskGuard", Use_RiskGuard);
   line += ChatTuneB("Risk_UsePercentLot", Risk_UsePercentLot);
   line += ChatTuneD("Lot_Size", Lot_Size);
   line += ChatTuneD("Risk_PercentPerTrade", Risk_PercentPerTrade);
   line += ChatTuneD("Risk_MaxLot", Risk_MaxLot);
   line += ChatTuneI("Risk_MaxOpenTrades", Risk_MaxOpenTrades);
   line += ChatTuneI("Risk_MaxTradesPerDay", Risk_MaxTradesPerDay);
   line += ChatTuneB("Risk_OneTradePerZone", Risk_OneTradePerZone);
   line += ChatTuneB("Risk_BlockOppositeDirection", Risk_BlockOppositeDirection);
   line += ChatTuneD("Risk_MaxSpreadPoints", Risk_MaxSpreadPoints);
   line += ChatTuneD("Risk_MaxDailyLossPct", Risk_MaxDailyLossPct);
   line += ChatTuneD("Risk_MaxDailyProfitPct", Risk_MaxDailyProfitPct);
   line += ChatTuneI("Risk_MaxConsecutiveLosses", Risk_MaxConsecutiveLosses);
   line += ChatTuneI("Risk_CooldownMinutesAfterLoss", Risk_CooldownMinutesAfterLoss);
   line += ChatTuneD("Risk_MaxEquityDrawdownPct", Risk_MaxEquityDrawdownPct);
   line += ChatTuneD("Risk_MinFreeMarginPct", Risk_MinFreeMarginPct);
   line += ChatTuneI("Risk_MaxSlippagePoints", Risk_MaxSlippagePoints);
   context += line + "\n";

   line = "TIME ";
   line += ChatTuneB("UseTimeFilter", UseTimeFilter);
   line += ChatTuneI("TradingStartHour", TradingStartHour);
   line += ChatTuneI("TradingEndHour", TradingEndHour);
   line += ChatTuneB("TradeMonday", TradeMonday);
   line += ChatTuneB("TradeTuesday", TradeTuesday);
   line += ChatTuneB("TradeWednesday", TradeWednesday);
   line += ChatTuneB("TradeThursday", TradeThursday);
   line += ChatTuneB("TradeFriday", TradeFriday);
   line += ChatTuneB("TradeSaturday", TradeSaturday);
   line += ChatTuneB("TradeSunday", TradeSunday);
   context += line + "\n";

   line = "DASH_GATE ";
   line += ChatTuneB("Enable_AutoTrade", Enable_AutoTrade);
   line += ChatTuneB("AutoTrade_OnNewZone", AutoTrade_OnNewZone);
   line += ChatTuneB("Dash_EnableSignalTrading", Dash_EnableSignalTrading);
   line += ChatTuneB("Dash_DryRunOnly", Dash_DryRunOnly);
   line += ChatTuneS("Dash_GradeThreshold", Dash_GradeThreshold);
   line += ChatTuneI("Dash_MinStableBars", Dash_MinStableBars);
   line += ChatTuneB("Dash_RequireReadyNearBOS", Dash_RequireReadyNearBOS);
   line += ChatTuneI("Dash_MinScore", Dash_MinScore);
   line += ChatTuneD("Dash_ATRStopMultiplier", Dash_ATRStopMultiplier);
   line += ChatTuneD("Dash_TakeProfitRR", Dash_TakeProfitRR);
   line += ChatTuneD("Dash_MaxRiskPts", Dash_MaxRiskPts);
   line += ChatTuneD("Dash_SpreadPtsMax", Dash_SpreadPtsMax);
   line += ChatTuneB("Dash_UseGlobalRiskPct", Dash_UseGlobalRiskPct);
   line += ChatTuneD("Dash_LotSizeFixed", Dash_LotSizeFixed);
   line += ChatTuneB("Dash_AllowOppositeIfZoneHold", Dash_AllowOppositeIfZoneHold);
   line += ChatTuneB("Dash_SessionEndBlock1h", Dash_SessionEndBlock1h);
   line += ChatTuneI("Dash_MinBOSConfirmBars_" + TimeframeToString(GetHigherTimeframe(Period())), GetDashMinBOSConfirmBarsForTF(GetHigherTimeframe(Period())));
   line += ChatTuneB("Dash_EnableAIFilter", Dash_EnableAIFilter);
   line += ChatTuneI("ATR_Period_Strength", ATR_Period_Strength);
   line += ChatTuneI("RSI_Period", RSI_Period);
   line += ChatTuneI("Strength_Update_Frequency", Strength_Update_Frequency);
   line += ChatTuneB("Filter_BigCandle_Rejection", Filter_BigCandle_Rejection);
   line += ChatTuneD("BigCandle_ATR_Factor", BigCandle_ATR_Factor);
   line += ChatTuneB("Include_Wicks", Include_Wicks);
   line += ChatTuneD("Buy_MinZoneHeightATR", Buy_MinZoneHeightATR);
   line += ChatTuneI("Buy_MinZoneHeightPoints", Buy_MinZoneHeightPoints);
   line += ChatTuneD("Sell_MinZoneHeightATR", Sell_MinZoneHeightATR);
   line += ChatTuneI("Sell_MinZoneHeightPoints", Sell_MinZoneHeightPoints);
   line += ChatTuneB("RestoreZonesOnReload", RestoreZonesOnReload);
   line += ChatTuneB("AI_HardGate", AI_HardGate);
   line += ChatTuneI("AI_GateMinScore", AI_GateMinScore);
   line += ChatTuneS("AI_GateMinGrade", AI_GateMinGrade);
   line += ChatTuneD("AI_GateMinADX", AI_GateMinADX);
   line += ChatTuneB("AI_GateNeedH4H1", AI_GateNeedH4H1);
   line += ChatTuneB("AI_GateH4Soft", AI_GateH4Soft);
   line += ChatTuneB("AI_GateNeedM15", AI_GateNeedM15);
   line += ChatTuneB("AI_GateNeedM5Timing", AI_GateNeedM5Timing);
   line += ChatTuneD("AI_GateMaxSpreadPts", AI_GateMaxSpreadPts);
   line += ChatTuneB("AI_GateSessionOnly", AI_GateSessionOnly);
   line += ChatTuneB("AI_GateBlockRsiExtreme", AI_GateBlockRsiExtreme);
   context += line + "\n";
}

void ChatTune()
{
   if (!Chat_TuneEnable || g_chatMinimized || g_chatBusy) return;
   if (!Chat_Enable || IsTesting() || IsOptimization()) return;
   datetime now = TimeCurrent();
   if (g_chatTuneLastCall > 0 && now - g_chatTuneLastCall < Chat_TuneMinGapSec)
   {
      g_chatStatus = "TUNE cooldown [" + Chat_Mode + "]";
      ChatLayout(); ChartRedraw();
      return;
   }
   g_chatTuneLastCall = now;
   g_chatBusy = true;
   string context = "";
   string answer = "";
   string instruction =
      "TUNE_REQUEST: review only the supplied realized trading statistics, PLAN_ACCURACY and CURRENT_INPUTS. " +
      "Suggest EA input changes only; never change inputs, write files, or claim to apply anything. " +
      "Any listed CURRENT_INPUTS name is in scope; prefer filters with a clear statistical link to losing grade, session or direction buckets. " +
      "Every suggestion MUST use exactly one line: SUGGEST <InputName>: <current> -> <proposed> | <evidence: win rate/avg R/PF on N trades> | <expected effect>. " +
      "Refuse any relevant bucket with fewer than 20 closed trades: write NEDOVOLNO PODATOCI for that bucket instead of guessing. " +
      "Explicitly warn when a sample is small or marginal. Give at most 3 highest-impact suggestions, ordered by expected impact. " +
      "If nothing is statistically supported, output one line saying there is not enough data and how many more trades are needed. " +
      "Use ASCII-only Macedonian LATIN. End exactly with: EA ne menuva nisto avtomatski; racno izmeni gi Properties."; 
   ChatBuildTuneContext(context);
   ChatAppend("TUNE request", Chat_UserColor);
   g_chatStatus = "AI tune razmisluva... [" + Chat_Mode + "]";
   ChatLayout(); ChartRedraw();
   bool ok = false;
   if (Chat_Mode == "DIRECT") ok = ChatPostDirect(instruction, context, "", answer, "");
   else ok = ChatPostServer(instruction, context, "", answer, "");
   g_chatBusy = false;
   if (ok) ChatAppend("TUNE:\n" + answer, Chat_TuneColor);
   else ChatAppend("TUNE: " + answer, Chat_TuneColor);
   g_chatStatus = ok ? ("Ready [" + Chat_Mode + "]") : ("Error [" + Chat_Mode + "]");
   ChatLayout(); ChartRedraw();
}

// ChatAppend samo go polni baferot - bez ChatLayout redot NE se iscrtuva vo panelot.
void ChatScoutRedraw()
{
   ChatRefreshStatus();
   ChatLayout();
   ChartRedraw();
}

// SL od AI cesto e POD swing-ot i pod spread-ot - toga sweep-ot go zema sigurno.
// Ovde SL se pomestuva nad/pod posledniot swing (+ spread + mal ATR buffer) i
// minimum Chat_PlanMinSLATR x ATR od entry. Vrakja true ako bil pomesten.
bool ChatPlanFixSL(string setup, double entry, double &sl, string &noteOut)
{
   noteOut = "";
   if (!Chat_PlanFixSL) return false;
   if (entry <= 0.0 || sl <= 0.0) return false;
   if (setup != "BUY" && setup != "SELL") return false;
   int tf = ChatVisionTfFromName(Chat_ScoutTF);
   if (tf <= 0) tf = PERIOD_M5;
   double atr = iATR(Symbol(), tf, 14, 1);
   if (atr <= 0.0) atr = Point * 50;
   double spread  = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   double buffer  = spread + atr * MathMax(0.0, Chat_PlanSLBufferATR);
   double minDist = atr * MathMax(0.0, Chat_PlanMinSLATR);
   int    bars    = MathMax(3, Chat_PlanSLSwingBars);
   double oldSl   = sl;
   if (setup == "BUY")
   {
      int lowIdx = iLowest(Symbol(), tf, MODE_LOW, bars, 1);
      double swingLow = (lowIdx >= 0) ? iLow(Symbol(), tf, lowIdx) : sl;
      double needBuy = MathMin(entry - minDist, swingLow - buffer);
      if (sl > needBuy) sl = needBuy;
   }
   else
   {
      int highIdx = iHighest(Symbol(), tf, MODE_HIGH, bars, 1);
      double swingHigh = (highIdx >= 0) ? iHigh(Symbol(), tf, highIdx) : sl;
      double needSell = MathMax(entry + minDist, swingHigh + buffer);
      if (sl < needSell) sl = needSell;
   }
   if (MathAbs(sl - oldSl) < Point) { sl = oldSl; return false; }
   sl = NormalizeDouble(sl, Digits);
   noteOut = "SL pomesten " + DoubleToString(oldSl, Digits) + " -> " + DoubleToString(sl, Digits) +
             " (nad/pod swing " + IntegerToString(bars) + " sveki + spread + " +
             DoubleToString(Chat_PlanSLBufferATR, 2) + " ATR)";
   return true;
}

// Kratok eden red od WHY (bez nov red, bez zapirka) za panel i CSV.
string ChatScoutWhyLine(string parseReply)
{
   string why = ChatPlanField(parseReply, "WHY");
   StringReplace(why, "\r", " ");
   StringReplace(why, "\n", " ");
   StringReplace(why, ",", ";");
   StringTrimLeft(why); StringTrimRight(why);
   int maxWhyChars = MathMax(Chat_WrapChars, Chat_WrapChars * 3 - 3);
   if (StringLen(why) > maxWhyChars)
   {
      int cut = MathMax(1, maxWhyChars - 3);
      while (cut > 0 && StringGetChar(why, cut) != 32) cut--;
      if (cut <= 0) cut = maxWhyChars - 3;
      why = StringSubstr(why, 0, cut) + "...";
   }
   return why;
}

bool ChatScoutLtfConfirmation(int dir, string &why)
{
   why = "";
   if (!g_sigCachedHasStruct || g_sigCachedTrend == 0 ||
       g_sigCachedBOSLevel <= 0.0)
   {
      why = "nema EA struktura/BOS potvrda";
      return false;
   }
   if (g_sigCachedTrend != dir)
   {
      why = "EA struktura e sprotivna";
      return false;
   }
   string bosWhy = "";
   if (!DashPassBOSConfirmCheck(
          GetDashMinBOSConfirmBarsForTF(g_sigCachedStructTF),
          g_sigCachedStructTF, dir, g_sigCachedBOSLevel, bosWhy))
   {
      why = "BOS ne e potvrden: " + bosWhy;
      return false;
   }
   return true;
}

bool ChatScoutWatchAllowed(int dir, double planRR, string &why)
{
   why = "";
   bool allowed = true;
   string regimeWhy = "";
   string regime = DetectMarketRegime(regimeWhy);
   if (regime == "NEWS_BLOCK" || regime == "RANGE" || regime == "CHOP")
   {
      why = "regime " + regime + ": " + regimeWhy;
      allowed = false;
   }
   string confirmWhy = "";
   if (!ChatScoutLtfConfirmation(dir, confirmWhy))
   {
      if (StringLen(why) > 0) why += " | ";
      why += confirmWhy;
      allowed = false;
   }
   if (Chat_WatchNeedH1Agree && AIMtfDir("H1") != dir)
   {
      if (StringLen(why) > 0) why += " | ";
      why += "H1 ne se soglasuva";
      allowed = false;
   }
   if (g_confirmCachedHas && g_confirmCachedTrend != 0 &&
       g_confirmCachedTrend == -dir)
   {
      if (StringLen(why) > 0) why += " | ";
      why += "confirm TF e sprotiven";
      allowed = false;
   }
   if (Chat_WatchNeedLtfAgree)
   {
      int dirM5 = AIMtfDir("M5");
      int dirM15 = AIMtfDir("M15");
      if (dirM5 == -dir || dirM15 == -dir)
      {
         if (!ChatScoutLtfConfirmation(dir, confirmWhy))
         {
            if (StringLen(why) > 0) why += " | ";
            why += "sprotiven LTF (M5/M15) bez potvrda";
            allowed = false;
         }
      }
   }
   double watchMinRR = MathMax(Chat_WatchMinRR, Chat_WatchHardMinRR);
   if (planRR <= 0.0 || planRR < watchMinRR)
   {
      if (StringLen(why) > 0) why += " | ";
      why += "RR " + DoubleToString(planRR, 2) + " < " +
             DoubleToString(watchMinRR, 2);
      allowed = false;
   }
   return allowed;
}

bool ChatScoutWatchDuplicate(int dir, double planEntry, double planSL,
                             double planTP2, double &tolerance)
{
   int scoutTf = ChatVisionTfFromName(Chat_ScoutTF);
   if (scoutTf <= 0) scoutTf = PERIOD_M5;
   double scoutAtr = iATR(Symbol(), scoutTf, 14, 1);
   if (scoutAtr <= 0.0) scoutAtr = Point * 50;
   tolerance = MathMax(scoutAtr * 0.25, Point * 10);
   if (g_chatScoutWatchLastAnnounce <= 0 ||
       TimeCurrent() - g_chatScoutWatchLastAnnounce >= Chat_ScoutQuietRepeatMin * 60)
      return false;
   return (dir == g_chatScoutWatchLastDir &&
           MathAbs(planEntry - g_chatScoutWatchLastEntry) <= tolerance &&
           MathAbs(planSL - g_chatScoutWatchLastSL) <= tolerance &&
           MathAbs(planTP2 - g_chatScoutWatchLastTP2) <= tolerance);
}

// Sekoja SCOUT odluka (i NO_TRADE) odi vo CSV za da moze da se vidi cel den nazad.
void ChatScoutLog(string decision, string setup, double conf, double entry,
                  double sl, double tp2, string why)
{
   if (!Chat_ScoutLogCsv) return;
   string path = "TraceAI\\chat_scout.csv";
   bool fresh = !FileIsExist(path);
   int handle = FileOpen(path, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ, ',');
   if (handle == INVALID_HANDLE)
   {
      Print("TraceChat SCOUT CSV FAIL err=", GetLastError());
      return;
   }
   if (fresh)
      FileWrite(handle, "time", "symbol", "scoutTF", "decision", "setup", "conf",
                "entry", "sl", "tp2", "visionAges", "visionSkipped", "why");
   else FileSeek(handle, 0, SEEK_END);
   string safeVisionAges = (StringLen(g_chatVisionAges) > 0 ? g_chatVisionAges : "-");
   string safeVisionSkipped = (StringLen(g_chatVisionSkipped) > 0 ? g_chatVisionSkipped : "-");
   string safeWhy = (StringLen(why) > 0 ? why : "-");
   StringReplace(safeVisionAges, ",", ";");
   StringReplace(safeVisionSkipped, ",", ";");
   StringReplace(safeWhy, ",", ";");
   FileWrite(handle, TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS), Symbol(), Chat_ScoutTF,
             decision, setup, DoubleToString(conf, 0),
             DoubleToString(entry, Digits), DoubleToString(sl, Digits), DoubleToString(tp2, Digits),
             safeVisionAges, safeVisionSkipped, safeWhy);
   FileFlush(handle);
   FileClose(handle);
}

void ChatScoutHandlePlan(bool ok, string answer)
{
   datetime now = TimeCurrent();
   if (!ok || StringLen(answer) == 0)
   {
      g_chatScoutFailedAttempts++;
      if (g_chatScoutFailedAttempts >= 3)
         g_chatScoutOfflineRetryAfter = now + 600;
      Print("TraceChat SCOUT silent: request failed: ", answer);
      ChatScoutLog("ERROR", "-", 0, 0, 0, 0, ChatSanitize(answer));
      if (Chat_ScoutVerbose) ChatAppend("SCOUT greshka: " + answer, clrOrange);
      g_chatStatus = ChatScoutStatusText();
      ChatScoutRedraw();
      return;
   }
   g_chatScoutFailedAttempts = 0;
   g_chatScoutOfflineRetryAfter = 0;
   if (Chat_CountOnlyAnsweredCalls)
   {
      g_chatScoutCallsToday++;
      ChatScoutSaveState();
   }
   string warning = "";
   string parseReply = ChatPlanNormalize(answer);
   if (!ChatValidatePlan(parseReply, warning))
   {
      Print("TraceChat SCOUT silent: invalid PLAN: ", answer);
      string rawSetup = ChatPlanField(parseReply, "SETUP");
      StringTrimLeft(rawSetup); StringTrimRight(rawSetup); StringToUpper(rawSetup);
      string rawLine = "SETUP=" + rawSetup +
                       " ENTRY=" + ChatPlanField(parseReply, "ENTRY") +
                       " SL=" + ChatPlanField(parseReply, "SL") +
                       " TP1=" + ChatPlanField(parseReply, "TP1") +
                       " TP2=" + ChatPlanField(parseReply, "TP2") +
                       " RR=" + ChatPlanField(parseReply, "RR");
      StringReplace(rawLine, ",", ";");
      string rawAnswer = "";
      if (Chat_InvalidReplyDiagnostics)
      {
         rawAnswer = ChatSanitize(answer);
         StringReplace(rawAnswer, "\r", " ");
         StringReplace(rawAnswer, "\n", " ");
         StringReplace(rawAnswer, ",", ";");
         if (StringLen(rawAnswer) > 160)
            rawAnswer = StringSubstr(rawAnswer, 0, 160);
      }
      string invalidWhy = warning + " | " + rawLine;
      if (StringLen(rawAnswer) > 0) invalidWhy += " | raw=" + rawAnswer;
      ChatScoutLog("INVALID", (StringLen(rawSetup) > 0 ? rawSetup : "-"), 0, 0, 0, 0,
                   invalidWhy);
      ChatAppend(TimeToString(now, TIME_MINUTES) + " SCOUT ODBIEN: " + warning, clrOrange);
      ChatAppend("   " + rawLine, clrOrange);
      g_chatStatus = ChatScoutStatusText();
      ChatScoutRedraw();
      return;
   }
   string setup = ChatPlanField(parseReply, "SETUP");
   StringTrimLeft(setup); StringTrimRight(setup); StringToUpper(setup);
   string planTrigger = ChatPlanField(parseReply, "TRIGGER");
   StringTrimLeft(planTrigger); StringTrimRight(planTrigger); StringToUpper(planTrigger);
   double planEntry = 0.0; double planSL = 0.0; double planTP1 = 0.0;
   double planTP2 = 0.0; double planRR = 0.0; double planConf = 0.0;
   ChatPlanNumber(ChatPlanField(parseReply, "ENTRY"), planEntry);
   ChatPlanNumber(ChatPlanField(parseReply, "SL"), planSL);
   ChatPlanNumber(ChatPlanField(parseReply, "TP1"), planTP1);
   ChatPlanNumber(ChatPlanField(parseReply, "TP2"), planTP2);
   ChatPlanNumber(ChatPlanField(parseReply, "RR"), planRR);
   ChatPlanNumber(ChatPlanField(parseReply, "CONF"), planConf);
   double rrCalc = ChatPlanRRCalc(planEntry, planSL, planTP2);
   if (rrCalc > 0.0 && (planRR <= 0.0 || MathAbs(planRR - rrCalc) > 0.20)) planRR = rrCalc;
   string scoutWhy = ChatScoutWhyLine(parseReply);
   if (setup != "BUY" && setup != "SELL")
   {
      Print("TraceChat SCOUT silent: ", setup, " CONF=", DoubleToString(planConf, 0),
            " why=", scoutWhy);
      ChatScoutLog("NO_TRADE", (StringLen(setup) > 0 ? setup : "NO_TRADE"), planConf,
                   0, 0, 0, scoutWhy);
      if (Chat_ScoutVerbose)
         ChatAppend(TimeToString(now, TIME_MINUTES) + " SCOUT NO_TRADE: " +
                    (StringLen(scoutWhy) > 0 ? scoutWhy : "nema setap"), clrGray);
      g_chatStatus = ChatScoutStatusText();
      ChatScoutRedraw();
      return;
   }
   int scoutDir = (setup == "BUY") ? 1 : -1;
   if (StringLen(g_chatVisionSkipped) > 0)
   {
      string visionWhy = "VISION missing/stale: " + g_chatVisionSkipped + " -> direction blocked";
      Print("TraceChat SCOUT blocked: ", setup, " ", visionWhy);
      ChatScoutLog("VISION_BLOCK", setup, planConf, planEntry, planSL, planTP2, visionWhy);
      if (Chat_ScoutVerbose)
         ChatAppend(TimeToString(now, TIME_MINUTES) + " SCOUT NO_TRADE: " + visionWhy, clrGray);
      g_chatStatus = ChatScoutStatusText();
      ChatScoutRedraw();
      return;
   }
   if (planTrigger == "" || planTrigger == "NONE")
   {
      string trigWhy = "NO_TRADE: nema potvrden trigger";
      Print("TraceChat SCOUT blocked: ", setup, " ", trigWhy);
      ChatScoutLog("TRIGGER_BLOCK", setup, planConf, planEntry, planSL, planTP2, trigWhy + " | " + scoutWhy);
      if (Chat_ScoutVerbose)
         ChatAppend(TimeToString(now, TIME_MINUTES) + " SCOUT NO_TRADE: " + trigWhy, clrGray);
      g_chatStatus = ChatScoutStatusText();
      ChatScoutRedraw();
      return;
   }
   // SL sanity PRED site drugi proverki - RR se presmetuva na popraveniot SL.
   string slNote = "";
   if (ChatPlanFixSL(setup, planEntry, planSL, slNote))
   {
      planRR = ChatPlanRRCalc(planEntry, planSL, planTP2);
      Print("TraceChat SCOUT ", slNote, " -> RR ", DoubleToString(planRR, 2));
   }
   int scoutTfIntegrity = ChatScoutTf();
   double scoutAtrIntegrity = iATR(Symbol(), scoutTfIntegrity, 14, 1);
   if (scoutAtrIntegrity <= 0.0) scoutAtrIntegrity = Point * 50;
   double slRiskIntegrity = MathAbs(planEntry - planSL);
   if (Chat_PlanMaxSLATR > 0.0 &&
       slRiskIntegrity > Chat_PlanMaxSLATR * scoutAtrIntegrity)
   {
      string wideWhy = "SL_TOO_WIDE risk=" + DoubleToString(slRiskIntegrity, Digits) +
                       " ATR=" + DoubleToString(scoutAtrIntegrity, Digits) +
                       " max=" + DoubleToString(Chat_PlanMaxSLATR * scoutAtrIntegrity, Digits);
      Print("TraceChat SCOUT ", wideWhy);
      ChatScoutLog("SL_TOO_WIDE", setup, planConf, planEntry, planSL, planTP2, wideWhy);
      if (Chat_ScoutVerbose) ChatAppend(TimeToString(now, TIME_MINUTES) +
                                         " SCOUT NO_TRADE: " + wideWhy, clrGray);
      g_chatStatus = ChatScoutStatusText();
      ChatScoutRedraw();
      return;
   }
   if (Chat_PlanRetargetTP && Chat_PlanTargetRR > 0.0 &&
       Chat_PlanMinRR > 0.0 && planRR > 0.0 && planRR < Chat_PlanMinRR)
   {
      double candidateTP2 = planEntry + scoutDir * slRiskIntegrity * Chat_PlanTargetRR;
      double candidateTP1 = planEntry + scoutDir * slRiskIntegrity;
      if (Chat_PlanMaxTPATR <= 0.0 ||
          MathAbs(candidateTP2 - planEntry) <= Chat_PlanMaxTPATR * scoutAtrIntegrity)
      {
         double oldTP2 = planTP2;
         planTP2 = NormalizeDouble(candidateTP2, Digits);
         if (MathAbs(planTP1 - planEntry) < slRiskIntegrity)
            planTP1 = NormalizeDouble(candidateTP1, Digits);
         if ((scoutDir == 1 && planTP1 > planTP2) ||
             (scoutDir == -1 && planTP1 < planTP2))
            planTP1 = NormalizeDouble(planEntry + scoutDir * slRiskIntegrity, Digits);
         planRR = ChatPlanRRCalc(planEntry, planSL, planTP2);
         string tpNote = "TP retargetiran na RR " + DoubleToString(Chat_PlanTargetRR, 2) +
                         " (TP2 " + DoubleToString(oldTP2, Digits) + " -> " +
                         DoubleToString(planTP2, Digits) + ")";
         if (StringLen(slNote) > 0) slNote += " | ";
         slNote += tpNote;
      }
      else
      {
         string unreachableWhy = "RR_UNREACHABLE risk=" + DoubleToString(slRiskIntegrity, Digits) +
                                 " candidateTP2=" + DoubleToString(candidateTP2, Digits) +
                                 " cap=" + DoubleToString(Chat_PlanMaxTPATR * scoutAtrIntegrity, Digits);
         Print("TraceChat SCOUT ", unreachableWhy);
         ChatScoutLog("RR_UNREACHABLE", setup, planConf, planEntry, planSL, planTP2, unreachableWhy);
         if (Chat_ScoutVerbose) ChatAppend(TimeToString(now, TIME_MINUTES) +
                                            " SCOUT NO_TRADE: " + unreachableWhy, clrGray);
         g_chatStatus = ChatScoutStatusText();
         ChatScoutRedraw();
         return;
      }
   }
   string tp1DailyNote = "";
   if (ChatPlanAdjustTP1Daily(setup, planEntry, planSL, planTP2,
                              planTP1, tp1DailyNote))
   {
      if (StringLen(slNote) > 0) slNote += " | ";
      slNote += tp1DailyNote;
      Print("TraceChat SCOUT ", tp1DailyNote);
   }
   bool rrTooLow = (Chat_PlanMinRR > 0.0 && planRR > 0.0 && planRR < Chat_PlanMinRR);
   string historyWhy = "";
   int minConfNeed = ChatScoutRequiredConf(setup, historyWhy);
   if (planConf < minConfNeed || rrTooLow)
   {
      bool watch = (!Chat_WatchDisableAll && Chat_ScoutWatchConf > 0 && planConf >= Chat_ScoutWatchConf);
      string lowReason = rrTooLow ? ("RR " + DoubleToString(planRR, 2) + " < " +
                                     DoubleToString(Chat_PlanMinRR, 2) + " po SL popravka")
                                  : ("CONF " + DoubleToString(planConf, 0) + " < " +
                                     IntegerToString(minConfNeed));
      if (StringLen(historyWhy) > 0 && !rrTooLow) lowReason += " | " + historyWhy;
      if (watch)
      {
         string watchRejectWhy = "";
         if (!ChatScoutWatchAllowed(scoutDir, planRR, watchRejectWhy))
         {
            string rejectText = TimeToString(now, TIME_MINUTES) +
                                " SCOUT WATCH ODBIEN: " + watchRejectWhy;
            Print("TraceChat SCOUT WATCH REJECT: ", setup, " ", watchRejectWhy,
                  " why=", scoutWhy);
            ChatScoutLog("WATCH_REJECT", setup, planConf, planEntry, planSL,
                         planTP2, watchRejectWhy + " | " + scoutWhy);
            ChatAppend(rejectText, clrGray);
            g_chatStatus = ChatScoutStatusText();
            ChatScoutRedraw();
            return;
         }
         double watchTolerance = 0.0;
         if (ChatScoutWatchDuplicate(scoutDir, planEntry, planSL,
                                     planTP2, watchTolerance))
         {
            Print("TraceChat SCOUT silent: duplicate WATCH ", setup,
                  " entry=", DoubleToString(planEntry, Digits),
                  " tolerance=", DoubleToString(watchTolerance, Digits));
            ChatScoutLog("WATCH_DUPLICATE", setup, planConf, planEntry,
                         planSL, planTP2, scoutWhy);
            g_chatStatus = ChatScoutStatusText();
            ChatScoutRedraw();
            return;
         }
         string watchText = TimeToString(now, TIME_MINUTES) + " SCOUT WATCH " + setup +
                            " CONF " + DoubleToString(planConf, 0) + " entry " +
                            DoubleToString(planEntry, Digits) + " SL " +
                            DoubleToString(planSL, Digits) + " TP2 " +
                            DoubleToString(planTP2, Digits) + " RR " +
                            DoubleToString(planRR, 2) +
                            " (" + lowReason + " - samo ideja)";
         Print("TraceChat SCOUT WATCH: ", setup, " ", lowReason,
               " why=", scoutWhy);
         ChatScoutLog("WATCH", setup, planConf, planEntry, planSL, planTP2,
                      lowReason + " | " + slNote + " | " + scoutWhy);
         ChatPlanRecord(setup, planEntry, planSL, planTP1, planTP2, planRR, planConf, true);
         g_chatScoutWatchLastDir = scoutDir;
         g_chatScoutWatchLastEntry = planEntry;
         g_chatScoutWatchLastSL = planSL;
         g_chatScoutWatchLastTP2 = planTP2;
         g_chatScoutWatchLastAnnounce = now;
         g_chatScoutArmDir = scoutDir;
         g_chatScoutArmEntry = planEntry;
         g_chatScoutArmSL = planSL;
         g_chatScoutArmTP1 = planTP1;
         g_chatScoutArmTP2 = planTP2;
         g_chatScoutArmConf = planConf;
         g_chatScoutArmTime = now;
         g_chatScoutArmSetup = setup;
         g_chatScoutArmTrigger = planTrigger;
         ChatScoutSaveState();
         ChatAppend(watchText, clrKhaki);
         if (StringLen(slNote) > 0) ChatAppend("   EA: " + slNote, clrKhaki);
         if (StringLen(scoutWhy) > 0) ChatAppend("   " + scoutWhy, clrKhaki);
         if (Chat_ScoutWatchAlert) Alert(ChatSanitize(watchText));
      }
      else
      {
         Print("TraceChat SCOUT silent: ", setup, " ", lowReason,
               " why=", scoutWhy);
         if (!Chat_WatchDisableAll && Chat_ScoutWatchConf > 0 && planConf < Chat_ScoutWatchConf)
         {
            string rejectConf = "CONF " + DoubleToString(planConf, 0) +
                                " < " + IntegerToString(Chat_ScoutWatchConf);
            ChatScoutLog("WATCH_REJECT", setup, planConf, planEntry, planSL,
                         planTP2, rejectConf + " | " + lowReason + " | " + scoutWhy);
            ChatAppend(TimeToString(now, TIME_MINUTES) +
                       " SCOUT WATCH ODBIEN: " + rejectConf, clrGray);
         }
         else if (Chat_ScoutVerbose)
         {
            ChatScoutLog("LOW_CONF", setup, planConf, planEntry, planSL,
                         planTP2, lowReason + " | " + slNote + " | " + scoutWhy);
            ChatAppend(TimeToString(now, TIME_MINUTES) + " SCOUT " + setup + " " + lowReason +
                       " -> preslabo", clrGray);
         }
      }
      g_chatStatus = ChatScoutStatusText();
      ChatScoutRedraw();
      return;
   }
   string judgeWhy = "";
   bool promotedM15Flat = false;
   bool judgePass = PassFinalSignalJudge(scoutDir, planEntry, planSL, planTP2,
                                         planConf, planTrigger, judgeWhy, false);
   if (!judgePass && Chat_ScoutM15FlatOk &&
       g_gateM15Flat && g_gateOtherPass)
   {
      int dirH1 = AIMtfDir("H1");
      int dirM5 = AIMtfDir("M5");
      int dirM15 = AIMtfDir("M15");
      string confirmWhy = "";
      bool flatCandidate = (dirH1 == scoutDir &&
                            dirM5 != -scoutDir &&
                            dirM15 == 0 &&
                            planRR >= Chat_ScoutM15FlatMinRR &&
                            planConf >= minConfNeed &&
                            ChatScoutLtfConfirmation(scoutDir, confirmWhy));
      if (flatCandidate)
      {
         string flatJudgeWhy = "";
         if (PassFinalSignalJudge(scoutDir, planEntry, planSL, planTP2,
                                  planConf, planTrigger, flatJudgeWhy, true))
         {
            promotedM15Flat = true;
            judgePass = true;
            judgeWhy = "M15 FLAT - dozvoleno so potvrda i RR " +
                       DoubleToString(planRR, 2);
         }
      }
   }
   if (!judgePass)
   {
      bool watchJudge = (!Chat_WatchDisableAll && Chat_ScoutWatchConf > 0 && planConf >= Chat_ScoutWatchConf);
      string judgeText = "final judge block: " + judgeWhy;
      if (watchJudge)
      {
         string watchRejectWhy = "";
         if (!ChatScoutWatchAllowed(scoutDir, planRR, watchRejectWhy))
         {
            string rejectText = TimeToString(now, TIME_MINUTES) +
                                " SCOUT WATCH ODBIEN: " + watchRejectWhy;
            Print("TraceChat SCOUT WATCH REJECT: ", setup, " ", watchRejectWhy,
                  " why=", scoutWhy);
            ChatScoutLog("WATCH_REJECT", setup, planConf, planEntry, planSL,
                         planTP2, watchRejectWhy + " | " + judgeText + " | " + scoutWhy);
            ChatAppend(rejectText, clrGray);
            g_chatStatus = ChatScoutStatusText();
            ChatScoutRedraw();
            return;
         }
         double watchTolerance = 0.0;
         if (ChatScoutWatchDuplicate(scoutDir, planEntry, planSL,
                                     planTP2, watchTolerance))
         {
            Print("TraceChat SCOUT silent: duplicate WATCH ", setup,
                  " entry=", DoubleToString(planEntry, Digits),
                  " tolerance=", DoubleToString(watchTolerance, Digits));
            ChatScoutLog("WATCH_DUPLICATE", setup, planConf, planEntry,
                         planSL, planTP2, judgeText + " | " + scoutWhy);
            g_chatStatus = ChatScoutStatusText();
            ChatScoutRedraw();
            return;
         }
         string watchText2 = TimeToString(now, TIME_MINUTES) + " SCOUT WATCH " + setup +
                             " CONF " + DoubleToString(planConf, 0) +
                             " entry " + DoubleToString(planEntry, Digits) +
                             " SL " + DoubleToString(planSL, Digits) +
                             " TP2 " + DoubleToString(planTP2, Digits) +
                             " RR " + DoubleToString(planRR, 2) +
                             " (" + judgeText + ")";
         Print("TraceChat SCOUT WATCH: ", setup, " ", judgeText,
               " why=", scoutWhy);
         ChatScoutLog("WATCH_JUDGE", setup, planConf, planEntry, planSL,
                      planTP2, judgeText + " | " + scoutWhy);
         ChatPlanRecord(setup, planEntry, planSL, planTP1, planTP2, planRR, planConf, true);
         g_chatScoutWatchLastDir = scoutDir;
         g_chatScoutWatchLastEntry = planEntry;
         g_chatScoutWatchLastSL = planSL;
         g_chatScoutWatchLastTP2 = planTP2;
         g_chatScoutWatchLastAnnounce = now;
         g_chatScoutArmDir = scoutDir;
         g_chatScoutArmEntry = planEntry;
         g_chatScoutArmSL = planSL;
         g_chatScoutArmTP1 = planTP1;
         g_chatScoutArmTP2 = planTP2;
         g_chatScoutArmConf = planConf;
         g_chatScoutArmTime = now;
         g_chatScoutArmSetup = setup;
         g_chatScoutArmTrigger = planTrigger;
         ChatScoutSaveState();
         ChatAppend(watchText2, clrKhaki);
         if (StringLen(slNote) > 0) ChatAppend("   EA: " + slNote, clrKhaki);
         if (StringLen(scoutWhy) > 0) ChatAppend("   " + scoutWhy, clrKhaki);
      }
      else if (Chat_ScoutVerbose)
      {
         Print("TraceChat SCOUT blocked: ", setup, " ", judgeText,
               " why=", scoutWhy);
         ChatScoutLog("JUDGE_BLOCK", setup, planConf, planEntry, planSL,
                      planTP2, judgeText + " | " + scoutWhy);
         ChatAppend(TimeToString(now, TIME_MINUTES) + " SCOUT " + setup + " " +
                    judgeText + " -> WAIT", clrGray);
      }
      g_chatStatus = ChatScoutStatusText();
      ChatScoutRedraw();
      return;
   }
   int scoutTf = ChatVisionTfFromName(Chat_ScoutTF);
   if (scoutTf <= 0) scoutTf = PERIOD_M5;
   double scoutAtr = iATR(Symbol(), scoutTf, 14, 1);
   if (scoutAtr <= 0) scoutAtr = Point * 50;
   double tolerance = MathMax(scoutAtr * 0.25, Point * 10);
   if (g_chatScoutLastAnnounce > 0 &&
       now - g_chatScoutLastAnnounce < Chat_ScoutQuietRepeatMin * 60 &&
       scoutDir == g_chatScoutLastDir &&
       MathAbs(planEntry - g_chatScoutLastEntry) <= tolerance &&
       MathAbs(planSL - g_chatScoutLastSL) <= tolerance &&
       MathAbs(planTP2 - g_chatScoutLastTP2) <= tolerance)
   {
      Print("TraceChat SCOUT silent: duplicate ", setup, " entry=",
            DoubleToString(planEntry, Digits), " tolerance=", DoubleToString(tolerance, Digits));
      ChatScoutLog("DUPLICATE", setup, planConf, planEntry, planSL, planTP2, scoutWhy);
      if (Chat_ScoutVerbose)
         ChatAppend(TimeToString(now, TIME_MINUTES) + " SCOUT " + setup +
                    " isto kako prethodniot signal - ne se povtoruva", clrGray);
      g_chatStatus = ChatScoutStatusText();
      ChatScoutRedraw();
      return;
   }
   if (Chat_BlockLiveRearm)
   {
      int livePlanId = -1;
      for (int liveIdx = g_chatPlanCount - 1; liveIdx >= 0; liveIdx--)
      {
         if (g_chatPlanSymbol[liveIdx] != Symbol()) continue;
         if (g_chatPlanIsWatch[liveIdx]) continue;
         if (g_chatPlanStatus[liveIdx] != "OPEN") continue;
         if (g_chatPlanSetup[liveIdx] != setup) continue;
         livePlanId = g_chatPlanId[liveIdx];
         break;
      }
      if (livePlanId >= 0)
      {
         string rearmWhy = "zivechkiot plan #" + IntegerToString(livePlanId) +
                           " e OPEN za " + setup + "; novoto armiranje e blokirano";
         Print("TraceChat SCOUT REARM_BLOCK: ", rearmWhy);
         ChatScoutLog("REARM_BLOCK", setup, planConf, planEntry, planSL, planTP2, rearmWhy);
         ChatAppend(TimeToString(now, TIME_MINUTES) + " SCOUT " + setup +
                    " REARM_BLOCK: " + rearmWhy, clrGray);
         g_chatStatus = ChatScoutStatusText();
         ChatScoutRedraw();
         return;
      }
   }
   ChatPlanRecord(setup, planEntry, planSL, planTP1, planTP2, planRR, planConf);
   ChatTriggerArm(setup, ChatPlanField(parseReply, "TRIGGER"),
                  planEntry, planSL, planTP1, planTP2, planRR, planConf);
   g_chatScoutLastDir = scoutDir;
   g_chatScoutLastEntry = planEntry;
   g_chatScoutLastSL = planSL;
   g_chatScoutLastTP2 = planTP2;
   g_chatScoutLastAnnounce = now;
   g_chatAutoPlanLastFire = now;
   ChatAutoPlanSaveState();
   ChatScoutSaveState();
   string levelsLine = "LEVELS: ENTRY=" + DoubleToString(planEntry, Digits) +
                       " SL=" + DoubleToString(planSL, Digits) +
                       " TP1=" + DoubleToString(planTP1, Digits) +
                       " TP2=" + DoubleToString(planTP2, Digits) +
                       " RR=" + DoubleToString(planRR, 2);
   string eaLine = "";
   if (StringLen(slNote) > 0)
      eaLine = "EA: " + slNote + " | SL=" + DoubleToString(planSL, Digits) +
               " TP1=" + DoubleToString(planTP1, Digits) +
               " TP2=" + DoubleToString(planTP2, Digits) +
               " RR=" + DoubleToString(planRR, 2) + " (koristi go OVOJ SL)";
   string alertText = ChatSanitize("SCOUT: " + setup + " " + levelsLine +
                                   (StringLen(eaLine) > 0 ? (" | " + eaLine) : ""));
   ChatAppend("SCOUT:\n" + answer, clrAqua);
   if (promotedM15Flat)
      ChatAppend("M15 FLAT - dozvoleno so potvrda i RR " +
                 DoubleToString(planRR, 2), clrLime);
   ChatAppend(levelsLine, clrAqua);
   if (StringLen(eaLine) > 0) ChatAppend(eaLine, clrLime);
   if (Chat_ScoutAlert) Alert(alertText);
   if (Chat_ScoutTelegram) SendTelegramMessage(alertText);
   g_chatStatus = ChatScoutStatusText();
   ChatScoutLog((promotedM15Flat ? "SIGNAL_M15_FLAT" : "SIGNAL"),
                setup, planConf, planEntry, planSL, planTP2,
                (StringLen(slNote) > 0 ? (slNote + " | ") : "") + scoutWhy);
   Print("TraceChat SCOUT YES: ", setup, " CONF=", DoubleToString(planConf, 0));
   ChatLayout();
   ChartRedraw();
}

void ChatPlanRun(bool automatic, bool scout)
{
   if ((!automatic && !scout && g_chatMinimized) || g_chatBusy) return;
   g_chatBusy = true;
   string request = ObjectGetString(0, "TraceChat_Input", OBJPROP_TEXT);
   StringTrimLeft(request); StringTrimRight(request);
   string context = ""; string answer = ""; string vision = "";
   ChatBuildContext(context);
   if (Chat_Vision)
   {
      g_chatStatus = "AI slika chartovi... [" + Chat_Mode + "]";
      ChatLayout(); ChartRedraw();
      vision = ChatVisionCapture();
   }
   if (StringLen(g_chatVisionSkipped) > 0)
      context += "\nVISION_SKIPPED=" + g_chatVisionSkipped + "\n";
   if (StringLen(g_chatVisionAges) > 0)
      context += "\nVISION_AGES=" + g_chatVisionAges + "\n";
   string statsRule = scout ?
      "Treat STATS and PLAN_ACCURACY as secondary historical context only; if recent history is weak, prefer NO_TRADE unless the visible evidence is exceptional. Do not use the EA gate, score or grade as a reason for or against this chart judgement. " :
      "Weigh STATS and PLAN_ACCURACY, especially weak grade/session performance or poor recent plan accuracy; become more conservative. ";
   string eaSlRule = "";
   string prompt = "Create one concrete trade plan from the supplied EA context and chart images. " +
      "Return exactly one field per line, with no commas or markdown: SETUP=BUY|SELL|NO_TRADE\nENTRY=\nSL=\nTP1=\nTP2=\nRR=\nCONF=0-100\nTRIGGER=\nVALID_UNTIL=\nINVALIDATION=<one short line>\nWHY=<maximum 3 short lines>. " +
      "For NO_TRADE, empty level fields must be omitted or written exactly as n/a, and include a short reason in WHY. " +
      "TRIGGER is the single condition the EA must wait for before the entry is valid. Write it in exactly this machine format: " +
      "TRIGGER=<TOUCH|CLOSE_ABOVE|CLOSE_BELOW|SWEEP_BELOW|SWEEP_ABOVE> <price level> <timeframe M1|M5|M15|M30|H1|H4>, for example TRIGGER=SWEEP_BELOW 1.08420 M5. " +
      "TOUCH means price simply reaches the level; CLOSE_ABOVE/CLOSE_BELOW need a closed candle body beyond the level on that timeframe; " +
      "SWEEP_BELOW means the candle wicks below the level and closes back above it (SWEEP_ABOVE is the mirror). " +
      "Prefer a confirmation trigger over an immediate entry; write TRIGGER=NONE only for NO_TRADE. " +
      "Do not add any words, brackets or explanation on the TRIGGER line. " +
      "Use real levels from zones, FVGs, EQH/EQL, pivots, PDH/PDL and round numbers. Put SL beyond structure and outside noise, with ATR as a sanity floor; target actual liquidity and levels. " +
      "SL RULE (hard): SL must sit beyond the most recent swing wick plus the current spread, and at least 1 ATR of the execution timeframe away from ENTRY. Never place SL inside the noise range or just under a round number - the EA will widen such an SL and recompute RR, and a setup whose RR then drops below 1.2 is discarded. " +
      "Choose NO_TRADE for dead volatility, NEWS_BLACKOUT, mid-range price, or conflicting MTF bias. " + statsRule +
      "SMC REASONING ORDER (use this order before answering; stay neutral and allow NO_TRADE): 1) Start with H4/H1 structure: trend or range, then premium/discount location in the active range. Do not take a counter-HTF entry unless a confirmed CHoCH supports it. 2) Check liquidity: PDH/PDL, EQH/EQL, session high/low and round numbers. A sweep followed by displacement back inside the range supports reversal; a sweep that keeps going is continuation, not reversal. 3) Classify BOS/CHoCH: real only with displacement, body close and an FVG; wick-only breaks, weak follow-through or low volatility are false breaks. State which. 4) Refine entry on execution TF at FVG, order block or 50% of the displacement leg; do not chase mid-range. 5) Put SL beyond the invalidating structure and sweep wick; ATR is only a sanity floor. 6) Target next real liquidity, not an arbitrary RR multiple. 7) State the session phase: Asia builds range, London often sweeps/reverses, NY may continue or reverse at its open. 8) NO_TRADE dominates for dead volatility, NEWS_BLACKOUT, mid-range price or conflicting MTF bias; a pattern in range middle can be a trap. WHY must name the structure and liquidity reason, e.g. sweep na PDL, CHoCH na M5, vlez vo FVG. " +
      "Output ASCII-only Macedonian LATIN plain text: no Cyrillic, emoji, arrows, checkmarks, box-drawing, or other special symbols.";
   if (Chat_PlanSendSLRule)
   {
      int slRuleTf = ChatVisionTfFromName(Chat_ScoutTF);
      if (slRuleTf <= 0) slRuleTf = PERIOD_M5;
      double slRuleAtr = iATR(Symbol(), slRuleTf, 14, 1);
      if (slRuleAtr <= 0.0) slRuleAtr = Point * 50;
      double slRuleSpread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
      double slRuleBuffer = slRuleSpread + slRuleAtr * MathMax(0.0, Chat_PlanSLBufferATR);
      double slRuleMinDist = slRuleAtr * MathMax(0.0, Chat_PlanMinSLATR);
      int slRuleBars = MathMax(3, Chat_PlanSLSwingBars);
      int slRuleLowIdx = iLowest(Symbol(), slRuleTf, MODE_LOW, slRuleBars, 1);
      int slRuleHighIdx = iHighest(Symbol(), slRuleTf, MODE_HIGH, slRuleBars, 1);
      double slRuleSwingLow = (slRuleLowIdx >= 0) ? iLow(Symbol(), slRuleTf, slRuleLowIdx) : Bid;
      double slRuleSwingHigh = (slRuleHighIdx >= 0) ? iHigh(Symbol(), slRuleTf, slRuleHighIdx) : Ask;
      double slRuleBuy = MathMin(Bid - slRuleMinDist, slRuleSwingLow - slRuleBuffer);
      double slRuleSell = MathMax(Ask + slRuleMinDist, slRuleSwingHigh + slRuleBuffer);
      double slRuleBuyDist = MathAbs(Bid - slRuleBuy);
      double slRuleSellDist = MathAbs(slRuleSell - Ask);
      eaSlRule = "\nEA_SL_RULE: scoutTF=" + Chat_ScoutTF +
                 " ATR=" + DoubleToString(slRuleAtr, Digits) +
                 " spread=" + DoubleToString(slRuleSpread, Digits) +
                 " min SL distance BUY=" + DoubleToString(slRuleBuyDist, Digits) +
                 " SELL=" + DoubleToString(slRuleSellDist, Digits) +
                 " (= max(" + DoubleToString(Chat_PlanMinSLATR, 2) + " x ATR, swing" +
                 IntegerToString(slRuleBars) + " +/- spread + " +
                 DoubleToString(Chat_PlanSLBufferATR, 2) + " x ATR));" +
                 " BUY SL <= " + DoubleToString(slRuleBuy, Digits) +
                 ", SELL SL >= " + DoubleToString(slRuleSell, Digits) +
                 "; max allowed risk=" + DoubleToString(Chat_PlanMaxSLATR * slRuleAtr, Digits) +
                 ". Compute RR from THAT SL and plan TP2 for RR >= " +
                 DoubleToString(Chat_PlanMinRR, 2) + "; otherwise return NO_TRADE.\n";
      eaSlRule += "Daily levels H/MH/M/LM/L are the chart's daily-range levels; use them as context or candidate TP targets only when structure agrees, never as guaranteed destinations or a reason alone to enter.\n";
      if (g_chatVisionLevelsDrawn)
         eaSlRule += "Screenshot lines: High=Lime, Mid-High=Orange, Mid=DodgerBlue, Low-Mid=Silver, Low=Red; these are context, not guaranteed targets.\n";
      prompt += eaSlRule;
   }
   if (scout)
      prompt += " SCOUT MODE: autonomously review this chart as a discretionary trader on each completed bar. Judge this bar on its own evidence: " +
                "do not force a setup and do not guess. Report BUY or SELL only when the chart image already shows a confirmed structure, liquidity event and execution trigger. " +
                "If the setup is still forming, if confirmation is missing, if the break is wick-only, or if you would need to assume unseen price action, answer NO_TRADE. " +
                "CONF must reflect the real quality of the visible evidence, not optimism: only a clean HTF-aligned sweep plus confirmed CHoCH/BOS with displacement deserves a high CONF. " +
                "Use NO_TRADE whenever the chart is unclear, mid-range, low-volatility, conflicting, or only potentially setting up. " +
                "Do not use the EA gate, score or grade as a reason for or against any conclusion; judge the chart, price structure and liquidity independently. " +
                "VISION_SKIPPED lists timeframes whose chart image is missing or too old: never assume what those timeframes look like, and if any required timeframe is skipped answer NO_TRADE.";
   if (!automatic && !scout && StringLen(request) > 0) prompt += "\nUser focus: " + request;
   if (!scout) ChatAppend(automatic ? "AUTO PLAN request" : "PLAN request", Chat_UserColor);
   g_chatStatus = scout ? "SCOUT razmisluva... [" + Chat_Mode + "]" :
                  (automatic ? "AI auto plan razmisluva... [" + Chat_Mode + "]" :
                               "AI plan razmisluva... [" + Chat_Mode + "]");
   ChatLayout(); ChartRedraw();
   bool ok = false;
   if (Chat_Mode == "DIRECT") ok = ChatPostDirect(prompt, context, "", answer, vision);
   else ok = ChatPostServer(prompt, context, "", answer, vision);
   g_chatBusy = false;
   Print("TraceChat PLAN raw: ", answer);
   if (scout)
   {
      ChatScoutHandlePlan(ok, answer);
      return;
   }
   if (ok)
   {
      ChatAppend((automatic ? "AUTO PLAN:\n" : "PLAN:\n") + answer, clrGold);
      string warning = "";
      string parseReply = ChatPlanNormalize(answer);
      bool planValid = ChatValidatePlan(parseReply, warning);
      if (planValid)
      {
         string setup = ChatPlanField(parseReply, "SETUP");
         StringTrimLeft(setup); StringTrimRight(setup); StringToUpper(setup);
         double planEntry = 0.0; double planSL = 0.0; double planTP1 = 0.0;
         double planTP2 = 0.0; double planRR = 0.0; double planConf = 0.0;
         ChatPlanNumber(ChatPlanField(parseReply, "ENTRY"), planEntry);
         ChatPlanNumber(ChatPlanField(parseReply, "SL"), planSL);
         ChatPlanNumber(ChatPlanField(parseReply, "TP1"), planTP1);
         ChatPlanNumber(ChatPlanField(parseReply, "TP2"), planTP2);
         ChatPlanNumber(ChatPlanField(parseReply, "RR"), planRR);
         ChatPlanNumber(ChatPlanField(parseReply, "CONF"), planConf);
         double rrCalcPlan = ChatPlanRRCalc(planEntry, planSL, planTP2);
         if (rrCalcPlan > 0.0 && (planRR <= 0.0 || MathAbs(planRR - rrCalcPlan) > 0.20)) planRR = rrCalcPlan;
         string slNotePlan = "";
         if (ChatPlanFixSL(setup, planEntry, planSL, slNotePlan))
         {
            planRR = ChatPlanRRCalc(planEntry, planSL, planTP2);
            ChatAppend("EA: " + slNotePlan + " | SL=" + DoubleToString(planSL, Digits) +
                       " RR=" + DoubleToString(planRR, 2) + " (koristi go OVOJ SL)", clrLime);
         }
         string tp1DailyNotePlan = "";
         if (ChatPlanAdjustTP1Daily(setup, planEntry, planSL, planTP2,
                                    planTP1, tp1DailyNotePlan))
         {
            if (StringLen(slNotePlan) > 0) slNotePlan += " | ";
            slNotePlan += tp1DailyNotePlan;
            ChatAppend("EA: " + tp1DailyNotePlan, clrLime);
         }
         if (setup == "BUY" || setup == "SELL" || setup == "NO_TRADE")
            ChatPlanRecord(setup, planEntry, planSL, planTP1, planTP2, planRR, planConf);
         // WAIT_FOR: zapamti go uslovot, EA go proveruva lokalno na sekoj tick.
         ChatTriggerArm(setup, ChatPlanField(parseReply, "TRIGGER"),
                        planEntry, planSL, planTP1, planTP2, planRR, planConf);
         string autoHistoryWhy = "";
         int autoNeedConf = ChatScoutRequiredConf(setup, autoHistoryWhy);
         if (automatic && (setup == "BUY" || setup == "SELL") && planConf >= autoNeedConf)
         {
            string alertText = ChatSanitize("AUTO PLAN: " + setup + " " + answer);
            if (Chat_AutoPlanAlert) Alert(alertText);
            if (Chat_AutoPlanTelegram) SendTelegramMessage(alertText);
         }
      }
      if (StringLen(warning) > 0) ChatAppend(warning, clrOrange);
   }
   else ChatAppend((automatic ? "AUTO PLAN: " : "PLAN: ") + answer, Chat_TextColor);
   if (StringLen(g_chatVisionSkipped) > 0) ChatAppend("Vision: " + g_chatVisionSkipped, clrOrange);
   g_chatStatus = ok ? ("Ready [" + Chat_Mode + "]") : ("Error [" + Chat_Mode + "]");
   if (!automatic) ObjectSetString(0, "TraceChat_Input", OBJPROP_TEXT, "");
   ChatLayout(); ChartRedraw();
}

bool ChatPostDirect(string question, string context, string history, string &answer, string vision)
{
   static bool providerWarningPrinted = false;
   static bool providerFallbackWarningPrinted = false;
   bool useGemini = false;
   if (Chat_UseGemini && !Chat_UseOpenAI) useGemini = true;
   if (Chat_UseGemini && Chat_UseOpenAI && !providerWarningPrinted)
   {
      Print("Chat: Chat_UseOpenAI i Chat_UseGemini se true; se koristi OpenAI.");
      providerWarningPrinted = true;
   }
   string apiKey = useGemini ? Chat_GeminiApiKey : Chat_ApiKey;
   if (StringLen(apiKey) == 0)
   {
      if (useGemini && StringLen(Chat_ApiKey) > 0)
      {
         useGemini = false;
         apiKey = Chat_ApiKey;
         if (!providerFallbackWarningPrinted)
         {
            Print("Chat: Gemini kluchot e prazen, se koristi OpenAI kluchot od Chat_ApiKey.");
            providerFallbackWarningPrinted = true;
         }
      }
      else if (!useGemini && StringLen(Chat_GeminiApiKey) > 0)
      {
         useGemini = true;
         apiKey = Chat_GeminiApiKey;
         if (!providerFallbackWarningPrinted)
         {
            Print("Chat: OpenAI kluchot e prazen, se koristi Gemini kluchot od Chat_GeminiApiKey.");
            providerFallbackWarningPrinted = true;
         }
      }
   }
   if (StringLen(apiKey) == 0)
   {
      answer = "Chat_ApiKey i Chat_GeminiApiKey se prazni. Vnesi kluch vo eden od niv ili stavi Chat_Mode=SERVER.";
      return false;
   }
   string sys = "You are a professional price-action and SMC trading assistant. Answer concisely. ";
   if (Chat_Lang == "MK") sys += "Answer in Macedonian latin script. ";
   sys += "This is not financial advice. Use ONLY the provided context data and do not invent facts. ";
   sys += "Primary evidence for market questions is the attached chart image(s) and raw price structure: levels, structure, liquidity, FVG, sessions and multi-timeframe context. " +
          "Read what price is doing and answer the user's actual question from the chart. The EA score, grade and gate are INTERNAL EA state and secondary context only; " +
          "they may be mentioned as a supporting note, but must never be the reason for a market judgement or quoted as if they were market analysis. Never answer a market question solely with score, grade or gate status. " +
          "Use this condensed SMC order: higher-timeframe structure and premium/discount, liquidity sweep or continuation, BOS/CHoCH quality, entry area, then session phase. " +
          "Stay neutral: dead volatility, news blackout, mid-range price or conflicting MTF bias can justify WAIT or NO_TRADE. Keep plain chat conversational and short; do not force PLAN fields. ";
   sys += "The STATS section is the EA's own realized performance; weigh it and warn if the current setup matches a weak grade or session bucket. ";
   sys += "The PLAN_ACCURACY section is the EA's own tracked plan hit rate; become more conservative when recent accuracy is poor. ";
   sys += "Output ASCII-only plain text: Macedonian LATIN script only, absolutely no Cyrillic, no emoji, " +
          "arrows, checkmarks, box-drawing, or other special symbols.";
   string historyPart = (StringLen(history) > 0) ? "," + history : "";
   string geminiHistory = "";
   if (useGemini) ChatBuildGeminiHistory(geminiHistory);
   string userText = "Question: " + question + "\nContext:\n" + context;
   string userContent = "{\"type\":\"text\",\"text\":\"" + ChatJsonEscape(userText) + "\"}";
   string geminiContent = "{\"text\":\"" + ChatJsonEscape(userText) + "\"}";
   if (g_chatVisionCount > 0)
   {
      for (int vi = 0; vi < g_chatVisionCount; vi++)
      {
         uchar shotData[]; uchar emptyKey[]; uchar encoded[];
         if (!ChatReadVisionShot(g_chatVisionFile[vi], shotData))
         {
            if (StringLen(g_chatVisionSkipped) > 0) g_chatVisionSkipped += ",";
            g_chatVisionSkipped += g_chatVisionTf[vi] + "(too_large_or_unreadable)";
            continue;
         }
         int encSize = CryptEncode(CRYPT_BASE64, shotData, emptyKey, encoded);
         if (encSize <= 0) continue;
         string b64 = CharArrayToString(encoded, 0, encSize, CP_UTF8);
         userContent += ",{\"type\":\"image_url\",\"image_url\":{\"url\":\"data:image/png;base64," +
                        b64 + "\",\"detail\":\"" + ChatJsonEscape(Chat_VisionDetail) + "\"}}";
         geminiContent += ",{\"inlineData\":{\"mimeType\":\"image/png\",\"data\":\"" + b64 + "\"}}";
      }
   }
   string body;
   if (useGemini)
   {
      string geminiHistoryPart = (StringLen(geminiHistory) > 0) ? geminiHistory + "," : "";
      body = "{\"systemInstruction\":{\"parts\":[{\"text\":\"" + ChatJsonEscape(sys) +
             "\"}]},\"contents\":[" + geminiHistoryPart + "{\"role\":\"user\",\"parts\":[" +
             geminiContent + "]}],\"generationConfig\":{\"maxOutputTokens\":" + IntegerToString(Chat_MaxTokens) +
             ",\"temperature\":" + DoubleToString(Chat_Temperature, 2) + "}}";
   }
   else
   {
      body = "{\"model\":\"" + ChatJsonEscape(Chat_Model) + "\",\"messages\":[{\"role\":\"system\",\"content\":\"" +
             ChatJsonEscape(sys) + "\"}" + historyPart + ",{\"role\":\"user\",\"content\":[" +
             userContent + "]}],\"max_tokens\":" + IntegerToString(Chat_MaxTokens) +
             ",\"temperature\":" + DoubleToString(Chat_Temperature, 2) + "}";
   }
   if (StringLen(body) > 18000000 && g_chatVisionCount > 0)
   {
      g_chatVisionFallback = true;
      userContent = "{\"type\":\"text\",\"text\":\"" + ChatJsonEscape(userText) + "\"}";
      geminiContent = "{\"text\":\"" + ChatJsonEscape(userText) + "\"}";
      if (useGemini)
      {
         string geminiHistoryPart2 = (StringLen(geminiHistory) > 0) ? geminiHistory + "," : "";
         body = "{\"systemInstruction\":{\"parts\":[{\"text\":\"" + ChatJsonEscape(sys) +
                "\"}]},\"contents\":[" + geminiHistoryPart2 + "{\"role\":\"user\",\"parts\":[" +
                geminiContent + "]}],\"generationConfig\":{\"maxOutputTokens\":" + IntegerToString(Chat_MaxTokens) +
                ",\"temperature\":" + DoubleToString(Chat_Temperature, 2) + "}}";
      }
      else
      {
         body = "{\"model\":\"" + ChatJsonEscape(Chat_Model) + "\",\"messages\":[{\"role\":\"system\",\"content\":\"" +
                ChatJsonEscape(sys) + "\"}" + historyPart + ",{\"role\":\"user\",\"content\":[" +
                userContent + "]}],\"max_tokens\":" + IntegerToString(Chat_MaxTokens) +
                ",\"temperature\":" + DoubleToString(Chat_Temperature, 2) + "}";
      }
   }
   int timeoutMs = (g_chatTransportTimeoutMs > 0) ? g_chatTransportTimeoutMs : Chat_TimeoutMs;
   char data[]; int sz = StringToCharArray(body, data, 0, -1, CP_UTF8);
   if (sz > 1) ArrayResize(data, sz - 1);
   char result[]; string headers = "Content-Type: application/json\r\n";
   string url = Chat_ApiUrl;
   if (!useGemini) headers += "Authorization: Bearer " + apiKey + "\r\n";
   else url = Chat_GeminiBaseUrl + Chat_GeminiModel + ":generateContent?key=" + apiKey;
   string responseHeaders = "";
   ResetLastError();
   int rc = WebRequest("POST", url, headers, timeoutMs, data, result, responseHeaders);
   int err = GetLastError();
   string raw = CharArrayToString(result, 0, -1, CP_UTF8);
   if (rc != 200)
   {
      if (rc == -1 && (err == 4060 || err == 4014))
      {
         answer = "WebRequest is not permitted or connection failed (error " +
                  IntegerToString(err) + "). Add " + url +
                  " to Tools > Options > Expert Advisors WebRequest whitelist.";
      }
      else if (rc == 401)
      {
         answer = useGemini ? "Nevaliden ili prazen Chat_GeminiApiKey (HTTP 401). Proveri go Chat_GeminiApiKey vo Inputs." :
                              "Nevaliden ili prazen Chat_ApiKey (HTTP 401). Proveri go Chat_ApiKey vo Inputs ili stavi Chat_Mode=SERVER za kluchot od serverot .env.";
      }
      else if (rc == 429)
      {
         answer = useGemini ? "Gemini rate limit ili quota problem (HTTP 429). Proveri ja Gemini smetkata i ogranicuvanjata na API." :
                              "OpenAI rate limit ili quota problem (HTTP 429). Proveri ja smetkata, billingot i ogranicuvanjata na API.";
      }
      else
      {
         string detail = ChatJsonExtract(raw, "message");
         if (StringLen(detail) == 0) detail = StringSubstr(raw, 0, 150);
         else if (StringLen(detail) > 150) detail = StringSubstr(detail, 0, 150);
         answer = "API error rc=" + IntegerToString(rc) + " lastError=" +
                  IntegerToString(err) + ": " + detail;
      }
      return false;
   }
   answer = ChatJsonExtract(raw, useGemini ? "text" : "content");
   if (StringLen(answer) == 0) answer = "API returned no answer.";
   return (StringLen(answer) > 0);
}

string ChatReadFileLocalUtf8(string relPath, int &fileSizeOut, int &rawLengthOut,
                             string &prefixOut)
{
   fileSizeOut = -1;
   rawLengthOut = 0;
   prefixOut = "";
   int h = FileOpen(relPath, FILE_READ|FILE_BIN|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if (h == INVALID_HANDLE) return "";
   int fileSize = (int)FileSize(h);
   fileSizeOut = fileSize;
   if (fileSize <= 0)
   {
      FileClose(h);
      return "";
   }
   uchar data[];
   ArrayResize(data, fileSize);
   int got = (int)FileReadArray(h, data, 0, fileSize);
   FileClose(h);
   if (got <= 0) return "";
   string raw = CharArrayToString(data, 0, got, CP_UTF8);
   rawLengthOut = StringLen(raw);
   prefixOut = StringSubstr(raw, 0, 40);
   StringReplace(prefixOut, "\r", " ");
   StringReplace(prefixOut, "\n", " ");
   return raw;
}

bool ChatFileFallback(string question, string context, string history, int requestId, string &answer, string vision)
{
   int timeoutMs = (g_chatTransportTimeoutMs > 0) ? g_chatTransportTimeoutMs : Chat_TimeoutMs;
   string payload = "{\"id\":" + IntegerToString(requestId) + ",\"msg\":\"" +
                    ChatJsonEscape(question) + "\",\"context\":\"" + ChatJsonEscape(context) +
                    "\",\"history\":[" + history + "],\"vision\":" +
                    (StringLen(vision) > 0 ? vision : "{\"enabled\":false,\"shots\":[]}") + "}";
   int h = FileOpen("TraceAI\\chat_input.json", FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ);
   if (h == INVALID_HANDLE)
   {
      answer = "Cannot write TraceAI\\chat_input.json";
      return false;
   }
   FileWriteString(h, payload);
   FileFlush(h);
   FileClose(h);
   Print("TraceChat file request written id=", requestId, " to TraceAI\\chat_input.json");
   uint started = GetTickCount();
   int lastFileSize = -1;
   int lastRawLength = 0;
   int lastReplyId = 0;
   string lastPrefix = "";
   while ((int)(GetTickCount() - started) < timeoutMs)
   {
      if (FileIsExist("TraceAI\\chat_output.json"))
      {
         string raw = ChatReadFileLocalUtf8(
            "TraceAI\\chat_output.json", lastFileSize, lastRawLength, lastPrefix);
         if (StringLen(raw) > 0)
         {
            lastReplyId = (int)ChatJsonExtractNum(raw, "replyId");
            string reply = ChatJsonExtract(raw, "reply");
            if (lastReplyId == requestId && StringLen(reply) > 0 &&
                StringFind(reply, "(pending AI") != 0)
            {
               answer = reply;
               return true;
            }
         }
      }
      Sleep(500);
   }
   Print("TraceChat file timeout DBG: size=", lastFileSize,
         " rawLen=", lastRawLength, " first40=\"", lastPrefix,
         "\" replyId=", lastReplyId, " expected=", requestId);
   answer = "SERVER file timeout waiting for TraceAI\\chat_output.json. Add " +
            "http://127.0.0.1:3000 to the WebRequest whitelist.";
   return false;
}

bool ChatPostServer(string question, string context, string history, string &answer, string vision)
{
   int timeoutMs = (g_chatTransportTimeoutMs > 0) ? g_chatTransportTimeoutMs : Chat_TimeoutMs;
   int requestId = (int)(GetTickCount() & 0x7fffffff);
   if (requestId <= 0) requestId = 1;
   string body = "{\"id\":" + IntegerToString(requestId) + ",\"msg\":\"" +
                 ChatJsonEscape(question) + "\",\"context\":\"" + ChatJsonEscape(context) +
                 "\",\"history\":[" + history + "],\"vision\":" +
                 (StringLen(vision) > 0 ? vision : "{\"enabled\":false,\"shots\":[]}") + "}";
   char data[]; int sz = StringToCharArray(body, data, 0, -1, CP_UTF8);
   if (sz > 1) ArrayResize(data, sz - 1);
   char result[]; string rh = "";
   string headers = "Content-Type: application/json\r\n";
   ResetLastError();
   int rc = WebRequest("POST", AI_ServerURL + "/ai/chat", headers, timeoutMs, data, result, rh);
   int postError = GetLastError();
   if (rc == 200)
   {
      Print("TraceChat server request accepted id=", requestId);
      uint started = GetTickCount();
      while ((int)(GetTickCount() - started) < timeoutMs)
      {
         char pollResp[];
         int pollRc = AIWrGet(AI_ServerURL + "/ai/chat/result", pollResp, 5000, "127.0.0.1", "localhost");
         if (pollRc == 200)
         {
            string raw = CharArrayToString(pollResp, 0, -1, CP_UTF8);
            int replyId = (int)ChatJsonExtractNum(raw, "replyId");
            string reply = ChatJsonExtract(raw, "reply");
            if (replyId == requestId && StringLen(reply) > 0 &&
                StringFind(reply, "(pending AI") != 0)
            {
               answer = reply;
               return true;
            }
         }
         Sleep(500);
      }
      answer = "SERVER timeout waiting for /ai/chat/result. Add " +
               "http://127.0.0.1:3000 to the WebRequest whitelist.";
      return false;
   }
   Print("TraceChat server POST failed rc=", rc, " err=", postError);
   return ChatFileFallback(question, context, history, requestId, answer, vision);
}

void ChatAsk()
{
   if (g_chatMinimized || g_chatBusy) return;
   string question = ObjectGetString(0, "TraceChat_Input", OBJPROP_TEXT);
   StringTrimLeft(question); StringTrimRight(question);
   if (StringLen(question) == 0) return;
   ObjectSetString(0, "TraceChat_Input", OBJPROP_TEXT, "");
   ChatLayout();
   ChartRedraw();
   if (StringFind(question, "/watch") == 0)
   {
      string instruction = StringSubstr(question, 6);
      StringTrimLeft(instruction);
      StringTrimRight(instruction);
      if (instruction == "off")
         ChatWatchSetInstruction("");
      else if (StringLen(instruction) > 0)
         ChatWatchSetInstruction(instruction);
      else
         g_chatStatus = "Use /watch <instruction> or /watch off.";
      ChatLayout();
      ChartRedraw();
      return;
   }
   string context = ""; string history = ""; string answer = "";
   ChatBuildContext(context); ChatBuildHistory(history);
   string vision = "";
   if (Chat_Vision)
   {
      g_chatStatus = "AI slika chartovi... [" + Chat_Mode + "]";
      ChatLayout(); ChartRedraw();
      vision = ChatVisionCapture();
   }
   if (StringLen(g_chatVisionSkipped) > 0)
      context += "\nVISION_SKIPPED=" + g_chatVisionSkipped + "\n";
   ChatAppend("You: " + question, Chat_UserColor);
   ChatConversationAppend("user", question);
   g_chatStatus = "AI razmisluva... [" + Chat_Mode + "]";
   ChatLayout(); ChartRedraw();
   bool ok = false;
   g_chatBusy = true;
   if (Chat_Mode == "DIRECT") ok = ChatPostDirect(question, context, history, answer, vision);
   else ok = ChatPostServer(question, context, history, answer, vision);
   g_chatBusy = false;
   if (ok) ChatAppend("AI: " + answer, Chat_AiColor);
   else ChatAppend("AI: " + answer, Chat_TextColor);
   if (StringLen(g_chatVisionSkipped) > 0) ChatAppend("Vision skipped: " + g_chatVisionSkipped, clrOrange);
   if (g_chatVisionFallback) ChatAppend("Vision fallback: text-only request.", clrOrange);
   if (ok) ChatConversationAppend("assistant", answer);
   g_chatStatus = ok ? ("Ready [" + Chat_Mode + "]") : ("Error [" + Chat_Mode + "]");
   ChatLayout(); ChartRedraw();
}
//+═══════════════════════════════════════════════════════════════════════════════════+
//|  END OF EA Trace Institucional                                                    |
//+═══════════════════════════════════════════════════════════════════════════════════+
