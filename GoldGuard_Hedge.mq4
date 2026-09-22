//+------------------------------------------------------------------+
//|                                              GoldGuard_Hedge.mq4 |
//|                                                  GoldGuard_Hedge |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "GoldGuard_Hedge"
#property link      ""
#property description "GoldGuard_Hedge"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| STRUCTURES                                                       |
//+------------------------------------------------------------------+
// for 2 types
enum TradeType
      {
         Buy=0,        
         Sell=1   
         
      };

// how the direction of the very first order is decided
enum EntryMode
      {
         FixedDirection=0,                    // always use FirstTrade / FirstTrade2
         FollowMarket=1                       // decide from the market
      };

// how the market direction is measured when EntryMode = FollowMarket
enum DirectionMethod
      {
         LastClosedCandle=0,                  // direction of the last closed candle
         RunningCandle=1,                     // direction of the candle in progress
         MovingAverage=2                      // price above/below a moving average
      };

enum EntryConfirmMethod
      {
         ConfirmNone=0,                       // no local confirmation
         ConfirmBreakClosedBar=1,             // break of previous candle high/low
         ConfirmBreakAndEMA=2                 // break plus EMA filter on confirmation timeframe
      };

//+------------------------------------------------------------------+
//| INPUT PARAMETERS                                                 |
//+------------------------------------------------------------------+
input string    Input_Security                = "========== ACCOUNT AUTHORIZATION ==========";
input string    AllowedAccounts               = "";

input string    Input_Direction               = "========== DIRECTION ==========";
input TradeType FirstTrade                    = Buy;
input EntryMode FirstEntryMode                = FollowMarket;
input DirectionMethod DirMethod               = MovingAverage;
input ENUM_TIMEFRAMES DirTimeframe            = PERIOD_H1;
input int       DirMaPeriod                   = 50;
input EntryConfirmMethod FirstEntryConfirm    = ConfirmNone;
input ENUM_TIMEFRAMES ConfirmTimeframe        = PERIOD_M15;
input int       ConfirmMaPeriod               = 50;
input double    ConfirmBreakBufferPips        = 0;

input string    Input_BosFilter               = "========== BOS FILTER ==========";
input bool      UseBosFilter                  = true;
input ENUM_TIMEFRAMES BosTimeframe            = PERIOD_M15;
input bool      Segment2Inverse               = true;

input string    Input_Trading                 = "========== TRADING ==========";
input bool      segment1                      = true;
input bool      segment2                      = false;
input TradeType FirstTrade2                   = Sell;
input double    LotSize                       = 0.01;
input double    TpPip                         = 10;
input double    LotMultiplier                 = 1.5;
input int       MaxMultiplierLevels           = 0;
input double    CloseAllOrdersAmountAt        = 2;
input int       SlippagePoints                = 50;
input int       MagicNumber1                  = 1001;
input int       MagicNumber2                  = 1002;
input double    PipSizeManual                 = 0;

input string    Input_Grid                    = "========== GRID ==========";
input double    GapSizePip                    = 100;
input bool      UseAtrGap                     = true;
input ENUM_TIMEFRAMES AtrTimeframe            = PERIOD_H1;
input int       AtrPeriod                     = 14;
input double    AtrGapMultiplier              = 1.0;
input double    MinGapPip                     = 250;
input double    MaxGapPip                     = 350;

input string    Input_Target                  = "========== TARGET ==========";
input bool      ScaleTargetByLots             = true;
input double    TargetPerLot                  = 20;
input double    MinCloseTarget                = 0;
input double    MaxSpreadPips                 = 8;
input int       NoEntryMinutesAroundMidnight  = 60;

input string    Input_News                    = "========== NEWS FILTER ==========";
input bool      EnableNewsFilter              = true;
input string    NewsFeedUrl                   = "https://nfs.faireconomy.media/ff_calendar_thisweek.xml";
input int       NewsBlockMinutesBefore        = 60;
input int       NewsBlockMinutesAfter         = 30;
input int       NewsRefreshMinutes            = 15;
input int       NewsRequestTimeoutMs          = 5000;
input bool      NewsFilterUSD                 = true;
input bool      NewsFilterCNY                 = false;
input int       NewsFeedOffsetMinutes         = 0;

input string    Input_Weekend                 = "========== WEEKEND ==========";
input bool      EnableWeekendProtection       = true;
input int       FridayBlockEntryHour          = 20;
input bool      CloseBasketOnFriday           = true;
input int       FridayCloseHour               = 23;
input double    MaxWeekendCloseLoss           = 20;

input string    Input_Safety                  = "========== SAFETY ==========";
input double    MinFirstOrderCloseProfit      = 0;
input int       MaxOrdersPerSegment           = 10;
input double    MaxLotsPerSegment             = 0.0;
input double    MaxBasketLossPerSegment       = 300;
input bool      RecoverOpenOrdersOnAttach     = true;

input string    Input_Dashboard               = "========== DASHBOARD ==========";
input bool      ShowDashboard                 = true;
input bool      DashShowResetButton           = true;
input int       DashCorner                    = 0;                            // 0 upper left, 1 upper right, 2 lower left, 3 lower right
input int       DashX                         = 12;
input int       DashY                         = 18;
input int       DashFontSize                  = 9;
input bool      DashShowHistory               = true;

input string    Input_Colors                  = "========== COLORS ==========";
input color     DashTextColor                 = clrWhite;
input color     DashProfitColor               = clrLime;
input color     DashLossColor                 = clrOrangeRed;
input color     DashBgColor                   = C'25,30,40';
input color     DashBorderColor               = clrDimGray;
input color     DashTitleColor                = clrGold;
input color     DashHeaderColor               = clrSilver;
input color     DashBuyColor                  = clrDeepSkyBlue;
input color     DashSellColor                 = clrTomato;

input string    Input_ChartVisuals            = "========== CHART VISUALS ==========";
input bool      ShowEmaLines                  = true;
input int       EmaBarsToDraw                 = 1400;
input color     ColorDirEma                   = clrBlue;
input color     ColorConfirmEma               = clrOrange;

input string Input_DailyLevels                = "========== DAILY LELELS ==========";
input bool   Use_DailyLevels                  = true;
input bool   DL_UseCurrentDay                 = true;
input int    DL_ShiftBars                     = 0;
input int    DL_FutureBars                    = 10;
input bool   DL_ExtendRight                   = false;
input int    DL_HShiftBars                    = 0;
input int    DL_LabelShiftBars                = 3;
input bool   DL_ShowLabels                    = true;
input bool   DL_ShowPrice                     = true;
input bool   DL_LabelAbove                    = false;
input bool   DL_ShowHigh                      = true;
input bool   DL_ShowLow                       = true;
input bool   DL_ShowMid                       = true;
input bool   DL_ShowLowMid                    = true;
input bool   DL_ShowMidHigh                   = true;
input color  DL_HighColor                     = clrLimeGreen;
input color  DL_LowColor                      = clrBrown;
input color  DL_MidColor                      = clrCornflowerBlue;
input color  DL_LowMidColor                   = clrPeru;
input color  DL_MidHighColor                  = clrOrange;
input int    DL_LineWidth                     = 3;
input int    DL_SubLineWidth                  = 1;
input string DL_HighLabel                     = "High";
input string DL_LowLabel                      = "Low";
input string DL_MidLabel                      = "Mid";
input string DL_LowMidLabel                   = "Low-Mid";
input string DL_MidHighLabel                  = "Mid-High";

input string    Input_MidBreakout             = "========== STRATEGY 2: MID BREAKOUT ==========";
input bool      Enable_MidBreakout            = true;
input int       MidBreak_Magic                = 2001;
input double    MidBreak_Lot                  = 0.01;
input ENUM_TIMEFRAMES MidBreak_Timeframe      = PERIOD_H1;
input double    MidBreak_MinCandlePips        = 30;
input double    MidBreak_MaxCandlePips        = 250;
input double    MidBreak_MaxSlPips            = 150;
input double    MidBreak_BreakBufferPips      = 2;
input double    MidBreak_MinTpPips            = 20;
input double    MidBreak_MinRR                = 1.5;
input bool      MidBreak_UseBreakEven         = true;
input double    MidBreak_BE_TriggerPips       = 100;
input bool      MidBreak_UseGlobalFilters     = true;   // news filter + spread + weekend + midnight block (isti kako grid)
input bool      MidBreak_UsePrevDayLevels     = true;   // Mid/TP nivoa od prethodniot den (fiksni), false = DL_UseCurrentDay logika
input bool      MidBreak_UsePendingStop       = true;   // pending Buy/Sell Stop na high/low+buffer namesto market vlez
input int       MidBreak_PendingExpiryBars    = 2;      // pending se brise po tolku sveki
input bool      MidBreak_UseAtrFilter         = true;
input int       MidBreak_AtrPeriod            = 14;
input double    MidBreak_MinBodyATR           = 0.6;    // telo >= X * ATR(MidBreak_Timeframe)
input double    MidBreak_MaxClosePosPct       = 30;     // zatvoranje vo gornite/dolnite X% od sveketa
input bool      MidBreak_UseTrendFilter       = true;
input ENUM_TIMEFRAMES MidBreak_TrendTF        = PERIOD_H4;
input int       MidBreak_TrendEmaPeriod       = 50;
input bool      MidBreak_UseSessionFilter     = true;
input int       MidBreak_SessionStartHour     = 8;      // server time
input int       MidBreak_SessionEndHour       = 17;
input bool      MidBreak_UseExhaustedDayFilter= true;
input int       MidBreak_DailyAtrPeriod       = 14;
input double    MidBreak_MaxDayRangeATR       = 1.2;    // ne vleguva ako denesniot opseg > X * ATR(D1)
input bool      MidBreak_OneTradePerDayDir    = true;   // max 1 trejd dnevno po nasoka (i posle SL)
input bool      MidBreak_UseAtrBE             = true;   // BE trigger = MidBreak_BE_ATR * ATR namesto fiksni pips
input double    MidBreak_BE_ATR               = 1.0;
input bool      MidBreak_UseSwingTrail        = true;   // posle BE: trail SL pod/nad posledniot swing low/high na MidBreak_Timeframe
input int       MidBreak_TrailSwingBars       = 3;      // swing = najnizok low (BUY) / najvisok high (SELL) od poslednite N zatvoreni sveki

input string    Input_Rescue                  = "========== STRATEGY 3: RESCUE MODULE ==========";
input bool      Enable_Rescue                 = false;
input double    Rescue_Activation_Loss        = 80;
input double    Rescue_LotSize                = 0.02;
input double    Rescue_TargetProfit           = 1.0;
input int       Rescue_Magic1                 = 3001;
input int       Rescue_Magic2                 = 3002;

input string    Input_Stats                   = "========== STATS ==========";
input bool      DashHistoryAllMagic           = false;                        // true = count every closed order of this symbol, false = only orders opened by this EA
input datetime  StatsStartTime                = 0;                            // reset point: closed orders before this date/time are ignored (0 = all)

//+------------------------------------------------------------------+
//| GLOBALS                                                          |
//+------------------------------------------------------------------+
//magic numbers, always taken from the MagicNumber1/MagicNumber2 inputs in OnInit
int magicNumber=0;

//for second segment-------------------------------------------------------------------------
int magicNumber2=0;

double   pipSize = 0;
datetime statsResetTime = 0;
string   statsResetKey = "";
datetime lastSafetyLimitPrint1 = 0;
datetime lastSafetyLimitPrint2 = 0;
datetime lastSafetyLossPrint1  = 0;
datetime lastSafetyLossPrint2  = 0;
datetime newsLastFetchTime = 0;
datetime newsLastErrorPrintTime = 0;
datetime newsLastBlockPrintTime = 0;
string   newsXmlCache = "";
uint     lastDashboardRefreshMs = 0;
uint     lastEmaRefreshMs = 0;
uint     lastDailyLevelsRefreshMs = 0;
uint     lastRescueCloseAttempt1Ms = 0;
uint     lastRescueCloseAttempt2Ms = 0;

// globals for Mid Breakout strategy
datetime lastMidSignalTime = 0;
int      midSignalDir = -1;
double   midSignalHigh = 0;
double   midSignalLow = 0;
datetime midLastBuyDay = 0, midLastSellDay = 0;   // date-only stamp; 1 trade/day/dir
int      midPendingTicket = 0;
datetime midPendingPlacedBar = 0;

int ResolveTimeframe(ENUM_TIMEFRAMES tf)
  {
   if(tf == PERIOD_CURRENT) return Period();
   return (int)tf;
  }

string BuildStatsResetKey()
  {
   return "GGH_RESET_" + IntegerToString(AccountNumber()) + "_" + Symbol()
          + "_" + IntegerToString(magicNumber) + "_" + IntegerToString(magicNumber2);
  }

datetime EffectiveStatsStartTime(datetime fromTime)
  {
   datetime effective = fromTime;

   if(StatsStartTime > effective) effective = StatsStartTime;
   if(statsResetTime > effective) effective = statsResetTime;

   return effective;
  }

void LoadStatsResetTime()
  {
   statsResetKey = BuildStatsResetKey();
   statsResetTime = 0;

   if(GlobalVariableCheck(statsResetKey))
      statsResetTime = (datetime)GlobalVariableGet(statsResetKey);
  }

void SaveStatsResetTime()
  {
   if(statsResetKey == "") statsResetKey = BuildStatsResetKey();

   if(statsResetTime > 0)
      GlobalVariableSet(statsResetKey, (double)statsResetTime);
   else if(GlobalVariableCheck(statsResetKey))
      GlobalVariableDel(statsResetKey);
  }

void ResetHistoryStats()
  {
   statsResetTime = TimeCurrent();
   SaveStatsResetTime();
   Print("History stats reset at ", TimeToString(statsResetTime, TIME_DATE|TIME_MINUTES));
  }

bool HasForeignSymbolOrders()
  {
   static datetime lastPrintTime = 0;
   bool found = false;

   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderSymbol() != Symbol()) continue;

      int type = OrderType();
      if(type != OP_BUY && type != OP_SELL && type != OP_BUYSTOP && type != OP_SELLSTOP) continue;
      if(OrderMagicNumber() == magicNumber || OrderMagicNumber() == magicNumber2) continue;

      found = true;
      break;
     }

   if(found)
     {
      datetime now = TimeCurrent();
      datetime currentMinute = now - now % 60;
      if(currentMinute != lastPrintTime)
        {
         Print("First entry blocked: existing symbol orders were found with a different magic number.");
         lastPrintTime = currentMinute;
        }
     }

   return found;
  }

bool FindSingleForeignMagic(int &foreignMagic)
  {
   bool found = false;
   foreignMagic = 0;

   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderSymbol() != Symbol()) continue;

      int type = OrderType();
      if(type != OP_BUY && type != OP_SELL && type != OP_BUYSTOP && type != OP_SELLSTOP) continue;

      int currentMagic = OrderMagicNumber();
      if(currentMagic == magicNumber || currentMagic == magicNumber2) continue;

      if(!found)
        {
         foreignMagic = currentMagic;
         found = true;
        }
      else if(currentMagic != foreignMagic)
        {
         return false;
        }
     }

   return found;
  }

void RecoverExistingOrders()
  {
   if(!RecoverOpenOrdersOnAttach) return;

   int foreignMagic = 0;
   if(!FindSingleForeignMagic(foreignMagic)) return;

   // magic numbers are fixed inputs, orders from an earlier run keep the same
   // magic and are picked up automatically; anything else stays untouched
   Print("Found existing symbol orders with foreign magic ", foreignMagic,
         ". They are not managed by this EA and block fresh first entries.");
  }

bool IsGoldSymbol()
  {
   string sym = Symbol();
   StringToUpper(sym);
   return (StringFind(sym, "XAU") >= 0 || StringFind(sym, "GOLD") >= 0);
  }

string CleanXmlText(string text)
  {
   int start = StringFind(text, "<![CDATA[");
   if(start >= 0)
     {
      start += 9;
      int finish = StringFind(text, "]]>", start);
      if(finish < 0) finish = StringLen(text);
      text = StringSubstr(text, start, finish - start);
     }

   StringTrimLeft(text);
   StringTrimRight(text);
   return text;
  }

string XmlTagValue(string xml, string tag)
  {
   string openTag = "<" + tag + ">";
   string closeTag = "</" + tag + ">";

   int start = StringFind(xml, openTag);
   if(start < 0) return "";
   start += StringLen(openTag);

   int finish = StringFind(xml, closeTag, start);
   if(finish < 0) return "";

   return CleanXmlText(StringSubstr(xml, start, finish - start));
  }

bool NewsCurrencyAllowed(string currency)
  {
   StringToUpper(currency);

   if(currency == "USD" && NewsFilterUSD) return true;
   if(currency == "CNY" && NewsFilterCNY) return true;

   return false;
  }

bool NewsImpactAllowed(string impact)
  {
   StringToUpper(impact);
   return (impact == "HIGH");
  }

datetime ParseNewsEventTime(string dateText, string timeText)
  {
   dateText = CleanXmlText(dateText);
   timeText = CleanXmlText(timeText);

   if(StringLen(dateText) < 10 || StringLen(timeText) < 4) return 0;

   string upperTime = timeText;
   StringToUpper(upperTime);
   if(StringFind(upperTime, "ALL DAY") >= 0 || StringFind(upperTime, "TENTATIVE") >= 0) return 0;

   int month = StrToInteger(StringSubstr(dateText, 0, 2));
   int day   = StrToInteger(StringSubstr(dateText, 3, 2));
   int year  = StrToInteger(StringSubstr(dateText, 6, 4));

   int colon = StringFind(timeText, ":");
   if(colon < 1) return 0;

   int hour = StrToInteger(StringSubstr(timeText, 0, colon));
   int minute = StrToInteger(StringSubstr(timeText, colon + 1, 2));
   string ampm = StringSubstr(upperTime, StringLen(upperTime) - 2, 2);

   if(ampm == "PM" && hour < 12) hour += 12;
   if(ampm == "AM" && hour == 12) hour = 0;

   datetime gmtTime = StrToTime(StringFormat("%04d.%02d.%02d %02d:%02d", year, month, day, hour, minute));
   if(gmtTime <= 0) return 0;

   int serverOffsetSeconds = (int)(TimeCurrent() - TimeGMT());
   return gmtTime + serverOffsetSeconds + NewsFeedOffsetMinutes * 60;
  }

bool FetchNewsFeed(string &xml)
  {
   char post[];
   char result[];
   string headers = "";

   ArrayResize(post, 0);
   ResetLastError();
   int httpCode = WebRequest("GET", NewsFeedUrl, "", "", NewsRequestTimeoutMs, post, 0, result, headers);

   if(httpCode == -1)
     {
      datetime now = TimeCurrent();
      if(now - newsLastErrorPrintTime >= 60)
        {
         Print("News filter WebRequest failed. Add URL in MT4 WebRequest list: ", NewsFeedUrl, " Error=", GetLastError());
         newsLastErrorPrintTime = now;
        }
      return false;
     }

   if(httpCode != 200)
     {
      datetime now = TimeCurrent();
      if(now - newsLastErrorPrintTime >= 60)
        {
         Print("News filter HTTP error: ", httpCode, " URL=", NewsFeedUrl);
         newsLastErrorPrintTime = now;
        }
      return false;
     }

   xml = CharArrayToString(result, 0, ArraySize(result));
   newsLastFetchTime = TimeCurrent();
   return (StringLen(xml) > 0);
  }

bool EnsureNewsFeed()
  {
   if(!EnableNewsFilter || !IsGoldSymbol()) return false;

   if(newsXmlCache != "" && newsLastFetchTime > 0 && TimeCurrent() - newsLastFetchTime < NewsRefreshMinutes * 60)
      return true;

   return FetchNewsFeed(newsXmlCache);
  }

bool NewsBlocksFreshSeries()
  {
   if(!EnableNewsFilter || !IsGoldSymbol()) return false;
   if(!EnsureNewsFeed()) return false;

   datetime now = TimeCurrent();
   int pos = 0;

   while(true)
     {
      int start = StringFind(newsXmlCache, "<event>", pos);
      if(start < 0) break;

      int finish = StringFind(newsXmlCache, "</event>", start);
      if(finish < 0) break;

      string eventXml = StringSubstr(newsXmlCache, start, finish - start);
      pos = finish + 8;

      string impact = XmlTagValue(eventXml, "impact");
      if(!NewsImpactAllowed(impact)) continue;

      string currency = XmlTagValue(eventXml, "country");
      if(!NewsCurrencyAllowed(currency)) continue;

      datetime eventTime = ParseNewsEventTime(XmlTagValue(eventXml, "date"), XmlTagValue(eventXml, "time"));
      if(eventTime <= 0) continue;

      datetime blockStart = eventTime - NewsBlockMinutesBefore * 60;
      datetime blockEnd   = eventTime + NewsBlockMinutesAfter * 60;

      if(now >= blockStart && now <= blockEnd)
        {
         if(now - newsLastBlockPrintTime >= 60)
           {
            Print("Fresh series blocked by red news: ", XmlTagValue(eventXml, "title"),
                  " ", currency,
                  " at ", TimeToString(eventTime, TIME_DATE|TIME_MINUTES));
            newsLastBlockPrintTime = now;
           }
         return true;
        }
     }

   return false;
  }

string GetNextNewsEventInfo()
  {
   if(!EnableNewsFilter || !IsGoldSymbol()) return "";
   if(!EnsureNewsFeed()) return "";

   datetime now = TimeCurrent();
   int pos = 0;
   
   datetime closestEventTime = 0;
   string closestEventTitle = "";
   bool isActive = false;

   while(true)
     {
      int start = StringFind(newsXmlCache, "<event>", pos);
      if(start < 0) break;

      int finish = StringFind(newsXmlCache, "</event>", start);
      if(finish < 0) break;

      string eventXml = StringSubstr(newsXmlCache, start, finish - start);
      pos = finish + 8;

      string impact = XmlTagValue(eventXml, "impact");
      if(!NewsImpactAllowed(impact)) continue;

      string currency = XmlTagValue(eventXml, "country");
      if(!NewsCurrencyAllowed(currency)) continue;

      datetime eventTime = ParseNewsEventTime(XmlTagValue(eventXml, "date"), XmlTagValue(eventXml, "time"));
      if(eventTime <= 0) continue;

      datetime blockStart = eventTime - NewsBlockMinutesBefore * 60;
      datetime blockEnd   = eventTime + NewsBlockMinutesAfter * 60;

      if(now >= blockStart && now <= blockEnd)
        {
         // Active blocking event
         return "BLOCKING: " + TimeToString(eventTime, TIME_MINUTES) + " " + currency + " " + XmlTagValue(eventXml, "title");
        }
        
      if(eventTime > now)
        {
         if(closestEventTime == 0 || eventTime < closestEventTime)
           {
            closestEventTime = eventTime;
            closestEventTitle = currency + " " + XmlTagValue(eventXml, "title");
           }
        }
     }

   if(closestEventTime > 0)
      return "NEXT: " + TimeToString(closestEventTime, TIME_DATE|TIME_MINUTES) + " " + closestEventTitle;

   return "NO UPCOMING RED NEWS";
  }

// time of the active blocking event, or the closest upcoming red news event
datetime GetNextNewsEventTime()
  {
   if(!EnableNewsFilter || !IsGoldSymbol()) return 0;
   if(!EnsureNewsFeed()) return 0;

   datetime now = TimeCurrent();
   int pos = 0;
   datetime closestEventTime = 0;

   while(true)
     {
      int start = StringFind(newsXmlCache, "<event>", pos);
      if(start < 0) break;

      int finish = StringFind(newsXmlCache, "</event>", start);
      if(finish < 0) break;

      string eventXml = StringSubstr(newsXmlCache, start, finish - start);
      pos = finish + 8;

      string impact = XmlTagValue(eventXml, "impact");
      if(!NewsImpactAllowed(impact)) continue;

      string currency = XmlTagValue(eventXml, "country");
      if(!NewsCurrencyAllowed(currency)) continue;

      datetime eventTime = ParseNewsEventTime(XmlTagValue(eventXml, "date"), XmlTagValue(eventXml, "time"));
      if(eventTime <= 0) continue;

      datetime blockStart = eventTime - NewsBlockMinutesBefore * 60;
      datetime blockEnd   = eventTime + NewsBlockMinutesAfter * 60;

      if(now >= blockStart && now <= blockEnd)
         return eventTime;

      if(eventTime > now && (closestEventTime == 0 || eventTime < closestEventTime))
         closestEventTime = eventTime;
     }

   return closestEventTime;
  }

//+------------------------------------------------------------------+
//| One pip in price for the current symbol                          |
//+------------------------------------------------------------------+
double PipSize()
  {
   if(PipSizeManual > 0) return PipSizeManual;

   int    digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
   double point  = MarketInfo(Symbol(), MODE_POINT);
   if(point <= 0) point = Point;

   string sym = Symbol();
   StringToUpper(sym);

   // metals are quoted with 2 or 3 digits, one pip is 0.1 for gold and 0.01 for silver
   if(StringFind(sym, "XAU") >= 0 || StringFind(sym, "GOLD") >= 0) return 0.1;
   if(StringFind(sym, "XAG") >= 0 || StringFind(sym, "SILVER") >= 0) return 0.01;

   // FX: 3 and 5 digit quotes carry one extra fractional digit
   if(digits == 3 || digits == 5) return point * 10.0;

   return point;
  }

//+------------------------------------------------------------------+
//| Lot size accepted by the broker                                  |
//+------------------------------------------------------------------+
double NormalizeLots(double lots)
  {
   double minLot  = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot   = MarketInfo(Symbol(), MODE_MAXLOT);
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);

   if(lotStep <= 0) lotStep = 0.01;
   if(minLot  <= 0) minLot  = lotStep;

   lots = MathFloor(lots / lotStep + 0.5) * lotStep;

   if(lots < minLot) lots = minLot;
   if(maxLot > 0 && lots > maxLot) lots = maxLot;

   int lotDigits = 2;
   if(lotStep >= 1)         lotDigits = 0;
   else if(lotStep >= 0.1)  lotDigits = 1;
   else if(lotStep >= 0.01) lotDigits = 2;
   else                     lotDigits = 3;

   return NormalizeDouble(lots, lotDigits);
  }

double NextChainLot(double lastLot)
  {
   if(MaxMultiplierLevels <= 0)
      return NormalizeLots(lastLot * LotMultiplier);

   double capLot = LotSize * MathPow(LotMultiplier, MaxMultiplierLevels);
   double grown = NormalizeLots(lastLot * LotMultiplier);

   if(grown > capLot)
     {
      static double lastPrintedLot = -1;
      if(lastPrintedLot != lastLot)
        {
         Print("Lot growth capped at ", lastLot, " lots (MaxMultiplierLevels=", MaxMultiplierLevels, ")");
         lastPrintedLot = lastLot;
        }
      return NormalizeLots(lastLot);
     }

   return grown;
  }

//+------------------------------------------------------------------+
//| Minimum distance in price for a pending stop order               |
//+------------------------------------------------------------------+
double MinStopDistance()
  {
   double point = MarketInfo(Symbol(), MODE_POINT);
   if(point <= 0) point = Point;

   double stopLevel   = MarketInfo(Symbol(), MODE_STOPLEVEL) * point;
   double freezeLevel = MarketInfo(Symbol(), MODE_FREEZELEVEL) * point;
   double spread      = MarketInfo(Symbol(), MODE_ASK) - MarketInfo(Symbol(), MODE_BID);

   double minDistance = stopLevel;
   if(freezeLevel > minDistance) minDistance = freezeLevel;
   if(spread      > minDistance) minDistance = spread;

   return minDistance;
  }

double GapDistance()
  {
   double fallback = GapSizePip * pipSize;
   if(!UseAtrGap) return fallback;

   double atr = iATR(Symbol(), AtrTimeframe, AtrPeriod, 1);
   if(atr <= 0) return fallback;

   double gap = atr * AtrGapMultiplier;
   double floor = (MinGapPip > 0) ? MinGapPip * pipSize : fallback;
   if(gap < floor) gap = floor;
   if(MaxGapPip > 0 && gap > MaxGapPip * pipSize) gap = MaxGapPip * pipSize;

   return gap;
  }

bool CanOpenFirstEntry()
  {
   static datetime lastPrintTime = 0;
   datetime now = TimeCurrent();
   bool blocked = false;
   string reason = "";

   RefreshRates();

   if(MaxSpreadPips > 0 && (Ask - Bid) / pipSize > MaxSpreadPips)
     {
      blocked = true;
      reason = "spread";
     }

   if(!blocked && EnableWeekendProtection && TimeDayOfWeek(now) == 5)
     {
      // Блокирај нови влезови ако е поминато FridayBlockEntryHour ИЛИ ако е поминато FridayCloseHour
      if(TimeHour(now) >= FridayBlockEntryHour || (CloseBasketOnFriday && TimeHour(now) >= FridayCloseHour))
        {
         blocked = true;
         reason = "weekend";
        }
     }

   if(!blocked && NoEntryMinutesAroundMidnight > 0)
     {
      int minuteOfDay = TimeHour(now) * 60 + TimeMinute(now);
      int minutesUntilMidnight = 1440 - minuteOfDay;

      if(minuteOfDay <= NoEntryMinutesAroundMidnight ||
         minutesUntilMidnight <= NoEntryMinutesAroundMidnight)
        {
         blocked = true;
         reason = "rollover";
        }
     }

   if(blocked)
     {
      datetime currentMinute = now - now % 60;
      if(currentMinute != lastPrintTime)
        {
         Print("First entry blocked by ", reason, ".");
         lastPrintTime = currentMinute;
        }
      return false;
     }

   return true;
  }

void PrintSafetyOncePerMinute(string text, int segmentId, bool lossEvent)
  {
   datetime now = TimeCurrent();
   datetime currentMinute = now - now % 60;

   if(segmentId == 1)
     {
      if(lossEvent)
        {
         if(currentMinute == lastSafetyLossPrint1) return;
         lastSafetyLossPrint1 = currentMinute;
        }
      else
        {
         if(currentMinute == lastSafetyLimitPrint1) return;
         lastSafetyLimitPrint1 = currentMinute;
        }
     }
   else
     {
      if(lossEvent)
        {
         if(currentMinute == lastSafetyLossPrint2) return;
         lastSafetyLossPrint2 = currentMinute;
        }
      else
        {
         if(currentMinute == lastSafetyLimitPrint2) return;
         lastSafetyLimitPrint2 = currentMinute;
        }
     }

   Print(text);
  }

bool CanPlaceNextSegmentOrder(int segmentId, int marketOrders, double totalLots, double nextLots)
  {
   string segmentName = (segmentId == 1) ? "segment 1" : "segment 2";

   if(MaxOrdersPerSegment > 0 && marketOrders >= MaxOrdersPerSegment)
     {
      PrintSafetyOncePerMinute("Safety block: " + segmentName + " reached MaxOrdersPerSegment.", segmentId, false);
      return false;
     }

   if(MaxLotsPerSegment > 0 && totalLots + nextLots > MaxLotsPerSegment + 0.0000001)
     {
      PrintSafetyOncePerMinute("Safety block: " + segmentName + " reached MaxLotsPerSegment.", segmentId, false);
      return false;
     }

   return true;
  }

bool EmergencyLossTriggered(int segmentId, int marketOrders, double profit)
  {
   string segmentName = (segmentId == 1) ? "segment 1" : "segment 2";

   if(MaxBasketLossPerSegment <= 0 || marketOrders <= 0) return false;
   if(profit > -MaxBasketLossPerSegment) return false;

   PrintSafetyOncePerMinute("Emergency close: " + segmentName + " hit MaxBasketLossPerSegment.", segmentId, true);
   return true;
  }

bool IsBosBullish()
  {
   double high1 = 0, high2 = 0;
   double low1 = 0, low2 = 0;
   int highsFound = 0, lowsFound = 0;
   
   for(int i = 2; i < 200; i++)
     {
      // Find Swing Highs (Fractal High)
      double h = iHigh(Symbol(), BosTimeframe, i);
      if(highsFound < 2 && h > iHigh(Symbol(), BosTimeframe, i-1) && h > iHigh(Symbol(), BosTimeframe, i-2) && 
         h > iHigh(Symbol(), BosTimeframe, i+1) && h > iHigh(Symbol(), BosTimeframe, i+2))
        {
         if(highsFound == 0) high1 = h;
         else if(highsFound == 1) high2 = h;
         highsFound++;
        }
        
      // Find Swing Lows (Fractal Low)
      double l = iLow(Symbol(), BosTimeframe, i);
      if(lowsFound < 2 && l < iLow(Symbol(), BosTimeframe, i-1) && l < iLow(Symbol(), BosTimeframe, i-2) && 
         l < iLow(Symbol(), BosTimeframe, i+1) && l < iLow(Symbol(), BosTimeframe, i+2))
        {
         if(lowsFound == 0) low1 = l;
         else if(lowsFound == 1) low2 = l;
         lowsFound++;
        }
        
      if(highsFound == 2 && lowsFound == 2) break;
     }
     
   // If we can't find structure, don't block
   if(highsFound < 2 || lowsFound < 2) return true;
   
   // For Bullish Trend:
   // 1. Most recent High must be higher than previous High (Higher High)
   // 2. Most recent Low must be higher than previous Low (Higher Low)
   bool isHigherHigh = (high1 > high2);
   bool isHigherLow = (low1 > low2);
   
   // We allow entry if at least the lows are rising (uptrend structure intact)
   // Even if it hasn't broken the high yet, rising lows mean buyers are stepping in earlier.
   return (isHigherLow);
  }

bool IsBosBearish()
  {
   double high1 = 0, high2 = 0;
   double low1 = 0, low2 = 0;
   int highsFound = 0, lowsFound = 0;
   
   for(int i = 2; i < 200; i++)
     {
      // Find Swing Highs
      double h = iHigh(Symbol(), BosTimeframe, i);
      if(highsFound < 2 && h > iHigh(Symbol(), BosTimeframe, i-1) && h > iHigh(Symbol(), BosTimeframe, i-2) && 
         h > iHigh(Symbol(), BosTimeframe, i+1) && h > iHigh(Symbol(), BosTimeframe, i+2))
        {
         if(highsFound == 0) high1 = h;
         else if(highsFound == 1) high2 = h;
         highsFound++;
        }
        
      // Find Swing Lows
      double l = iLow(Symbol(), BosTimeframe, i);
      if(lowsFound < 2 && l < iLow(Symbol(), BosTimeframe, i-1) && l < iLow(Symbol(), BosTimeframe, i-2) && 
         l < iLow(Symbol(), BosTimeframe, i+1) && l < iLow(Symbol(), BosTimeframe, i+2))
        {
         if(lowsFound == 0) low1 = l;
         else if(lowsFound == 1) low2 = l;
         lowsFound++;
        }
        
      if(highsFound == 2 && lowsFound == 2) break;
     }
     
   if(highsFound < 2 || lowsFound < 2) return true;
   
   // For Bearish Trend:
   // 1. Most recent Low must be lower than previous Low (Lower Low)
   // 2. Most recent High must be lower than previous High (Lower High)
   bool isLowerLow = (low1 < low2);
   bool isLowerHigh = (high1 < high2);
   
   // We allow entry if at least the highs are falling (downtrend structure intact)
   return (isLowerHigh);
  }

//+------------------------------------------------------------------+
//| Direction of the market, OP_BUY or OP_SELL                       |
//+------------------------------------------------------------------+
int MarketDirection(int fallback)
  {
   double open, close;
   int dir = fallback;

   if(DirMethod == MovingAverage)
     {
      // СНАЈПЕР 100%: Користиме shift 0 (жива цена) наместо shift 1 (затворена свеќа).
      // Вака отвора ВО СЕКУНДАТА кога ќе ја пробие линијата!
      double ma = iMA(Symbol(), DirTimeframe, DirMaPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
      double currentPrice = (fallback == OP_BUY) ? Ask : Bid;

      if(ma <= 0 || currentPrice <= 0) return fallback;
      if(currentPrice > ma) dir = OP_BUY;
      else if(currentPrice < ma) dir = OP_SELL;
     }
   else
     {
      int shift = (DirMethod == RunningCandle) ? 0 : 1;
      open  = iOpen(Symbol(), DirTimeframe, shift);
      close = iClose(Symbol(), DirTimeframe, shift);

      if(open <= 0 || close <= 0) return fallback;
      if(close > open) dir = OP_BUY;
      else if(close < open) dir = OP_SELL;
     }
     
   // BOS СЕМАФОР (Traffic Light) - Го штити Снајперот од пукање во контра-тренд
   if(UseBosFilter)
     {
      if(dir == OP_BUY && !IsBosBullish()) 
        {
         // Снајперот сака BUY, но BOS вика дека трендот паѓа. БЛОКИРАЈ.
         static datetime lastBosPrintBuy = 0;
         if(TimeCurrent() != lastBosPrintBuy)
           {
            Print("BOS Filter: BUY signal blocked. Market structure is not Bullish.");
            lastBosPrintBuy = TimeCurrent();
           }
         return -1; 
        }
      if(dir == OP_SELL && !IsBosBearish())
        {
         // Снајперот сака SELL, но BOS вика дека трендот расте. БЛОКИРАЈ.
         static datetime lastBosPrintSell = 0;
         if(TimeCurrent() != lastBosPrintSell)
           {
            Print("BOS Filter: SELL signal blocked. Market structure is not Bearish.");
            lastBosPrintSell = TimeCurrent();
           }
         return -1;
        }
     }
     
   return dir;
  }

bool FirstEntryConfirmed(int side)
  {
   // If side is -1 (meaning the MarketDirection blocked it), we definitely shouldn't confirm it
   if(side < 0) return false;

   if(FirstEntryConfirm == ConfirmNone) return true;

   RefreshRates();

   int tf = ResolveTimeframe(ConfirmTimeframe);
   double prevHigh = iHigh(Symbol(), tf, 1);
   double prevLow  = iLow(Symbol(), tf, 1);
   double price = (side == OP_BUY) ? Ask : Bid;
   double breakBuffer = ConfirmBreakBufferPips * pipSize;

   if(prevHigh <= 0 || prevLow <= 0 || price <= 0) return false;

   if(side == OP_BUY)
     {
      if(price < prevHigh + breakBuffer)
        {
         static datetime lastConfPrintBuy = 0;
         if(TimeCurrent() != lastConfPrintBuy)
           {
            Print("Confirm Filter: BUY blocked. Price (", price, ") has not broken previous High (", prevHigh, ") + Buffer.");
            lastConfPrintBuy = TimeCurrent();
           }
         return false;
        }
     }
   else
     {
      if(price > prevLow - breakBuffer)
        {
         static datetime lastConfPrintSell = 0;
         if(TimeCurrent() != lastConfPrintSell)
           {
            Print("Confirm Filter: SELL blocked. Price (", price, ") has not broken previous Low (", prevLow, ") - Buffer.");
            lastConfPrintSell = TimeCurrent();
           }
         return false;
        }
     }

   if(FirstEntryConfirm == ConfirmBreakAndEMA)
     {
      double ema = iMA(Symbol(), tf, ConfirmMaPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);

      if(ema <= 0 || price <= 0) return false;

      if(side == OP_BUY)
        {
         if(!(price > ema))
           {
            static datetime lastEmaPrintBuy = 0;
            if(TimeCurrent() != lastEmaPrintBuy)
              {
               Print("Confirm Filter: BUY blocked. Price is not above confirmation EMA.");
               lastEmaPrintBuy = TimeCurrent();
              }
            return false;
           }
        }
      else
        {
         if(!(price < ema))
           {
            static datetime lastEmaPrintSell = 0;
            if(TimeCurrent() != lastEmaPrintSell)
              {
               Print("Confirm Filter: SELL blocked. Price is not below confirmation EMA.");
               lastEmaPrintSell = TimeCurrent();
              }
            return false;
           }
        }
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Side of the first order of a segment                             |
//+------------------------------------------------------------------+
int FirstOrderSide(TradeType fixedSide, bool inverse)
  {
   int fallback = (fixedSide == Buy) ? OP_BUY : OP_SELL;

   if(FirstEntryMode == FixedDirection) return fallback;

   int side = MarketDirection(fallback);

   if(inverse) side = (side == OP_BUY) ? OP_SELL : OP_BUY;

   return side;
  }

//+------------------------------------------------------------------+
//| Market order with refreshed price                                |
//+------------------------------------------------------------------+
int SendMarketOrder(int side, double lots, int magic, color clr)
  {
   RefreshRates();

   double price = (side == OP_BUY) ? Ask : Bid;
   price = NormalizeDouble(price, Digits);

   int ticket = OrderSend(NULL, side, NormalizeLots(lots), price, SlippagePoints, 0, 0, NULL, magic, 0, clr);

   if(ticket < 0) Print("Market order failed, side ", side, ", error ", GetLastError());

   return ticket;
  }

//+------------------------------------------------------------------+
//| Pending stop order, pushed away if the broker distance is bigger |
//+------------------------------------------------------------------+
int SendStopOrder(int side, double lots, double entryPrice, int magic, color clr)
  {
   RefreshRates();

   double minDistance = MinStopDistance();

   if(side == OP_BUYSTOP)
     {
      if(entryPrice < Ask + minDistance) entryPrice = Ask + minDistance;
     }
   else
     {
      if(entryPrice > Bid - minDistance) entryPrice = Bid - minDistance;
     }

   entryPrice = NormalizeDouble(entryPrice, Digits);

   int ticket = OrderSend(NULL, side, NormalizeLots(lots), entryPrice, SlippagePoints, 0, 0, NULL, magic, 0, clr);

   if(ticket < 0) Print("Pending order failed, side ", side, ", price ", entryPrice, ", error ", GetLastError());

   return ticket;
  }

//+------------------------------------------------------------------+
//| Dashboard                                                        |
//+------------------------------------------------------------------+
string dashPrefix = "MH_DASH_";
// buy/sell counts, lots, profit and pending count of one segment
void SegmentStats(int magic, int &buyCount, int &sellCount, double &buyLots, double &sellLots, double &profit, int &pendingCount)
  {
   buyCount     = 0;
   sellCount    = 0;
   buyLots      = 0;
   sellLots     = 0;
   profit       = 0;
   pendingCount = 0;

   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;

      if(OrderType() == OP_BUY)
        {
         buyCount++;
         buyLots += OrderLots();
         profit  += OrderProfit() + OrderSwap() + OrderCommission();
        }
      else if(OrderType() == OP_SELL)
        {
         sellCount++;
         sellLots += OrderLots();
         profit   += OrderProfit() + OrderSwap() + OrderCommission();
        }
      else if(OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP)
        {
         pendingCount++;
        }
     }
  }

// closed buy/sell counts, lots and realized profit from the account history
void HistoryStats(datetime fromTime, int &buyCount, int &sellCount, double &buyLots, double &sellLots, double &profit)
  {
   buyCount  = 0;
   sellCount = 0;
   buyLots   = 0;
   sellLots  = 0;
   profit    = 0;
   datetime effectiveFromTime = EffectiveStatsStartTime(fromTime);

   for(int i = 0; i < OrdersHistoryTotal(); i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderSymbol() != Symbol()) continue;
      if(OrderType() != OP_BUY && OrderType() != OP_SELL) continue;
      if(effectiveFromTime > 0 && OrderCloseTime() < effectiveFromTime) continue;

      if(!DashHistoryAllMagic &&
         OrderMagicNumber() != magicNumber && 
         OrderMagicNumber() != magicNumber2 && 
         OrderMagicNumber() != MidBreak_Magic && 
         OrderMagicNumber() != Rescue_Magic1 && 
         OrderMagicNumber() != Rescue_Magic2) continue;

      if(OrderType() == OP_BUY)
        {
         buyCount++;
         buyLots += OrderLots();
        }
      else
        {
         sellCount++;
         sellLots += OrderLots();
        }

      profit += OrderProfit() + OrderSwap() + OrderCommission();
     }
  }

int DashRowHeight()
  {
   return DashFontSize + 8;
  }

int DashCharWidth()
  {
   return (int)MathRound(DashFontSize * 0.62) + 1;
  }

int DashRowCount()
  {
   int rows = 4;                  // title, header, total, info
   if(segment1) rows++;
   if(segment2) rows++;
   if(Enable_MidBreakout) rows++; // row for strategy 2 (mid breakout)
   if(Enable_Rescue) rows++;      // row for strategy 3 (rescue)
   if(DashShowHistory) rows += 4; // separator plus closed day, week and all
   if(EnableNewsFilter) rows += 5; // separator, news status, news info, pause from, resume at
   return rows;
  }

// screen distance of a text row, rows always read top to bottom
int DashRowY(int row)
  {
   if(DashCorner == 2 || DashCorner == 3)
      return DashY + (DashRowCount() - 1 - row) * DashRowHeight();

   return DashY + row * DashRowHeight();
  }

// screen distance of a column, mirrored when the panel sits on the right side
int DashColX(int columnPixels, int panelWidth)
  {
   if(DashCorner == 1 || DashCorner == 3)
      return DashX + panelWidth - 6 - columnPixels;

   return DashX + columnPixels;
  }

void SetDashPanel(string name, int x, int y, int width, int height)
  {
   string obj = dashPrefix + name;

   if(ObjectFind(0, obj) < 0)
     {
      ObjectCreate(0, obj, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, obj, OBJPROP_BACK, false);
      ObjectSetInteger(0, obj, OBJPROP_ZORDER, 100);
      ObjectSetInteger(0, obj, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, obj, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, obj, OBJPROP_WIDTH, 1);
     }

   ObjectSetInteger(0, obj, OBJPROP_CORNER, DashCorner);
   ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, obj, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, obj, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, obj, OBJPROP_BGCOLOR, DashBgColor);
   ObjectSetInteger(0, obj, OBJPROP_COLOR, DashBorderColor);
  }

void SetDashText(string name, string text, int x, int y, color clr)
  {
   string obj = dashPrefix + name;

   if(ObjectFind(0, obj) < 0)
     {
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, obj, OBJPROP_BACK, false);
      ObjectSetInteger(0, obj, OBJPROP_ZORDER, 101);
      ObjectSetString(0, obj, OBJPROP_FONT, "Courier New");
     }

   ObjectSetInteger(0, obj, OBJPROP_CORNER, DashCorner);
   ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, DashFontSize);
   ObjectSetInteger(0, obj, OBJPROP_COLOR, clr);
   ObjectSetString(0, obj, OBJPROP_TEXT, text);
  }

void SetDashButton(string name, string text, int x, int y, int width, int height)
  {
   string obj = dashPrefix + name;

   if(ObjectFind(0, obj) < 0)
     {
      ObjectCreate(0, obj, OBJ_BUTTON, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, obj, OBJPROP_BACK, false);
      ObjectSetInteger(0, obj, OBJPROP_ZORDER, 102);
      ObjectSetInteger(0, obj, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, obj, OBJPROP_STATE, false);
      ObjectSetString(0, obj, OBJPROP_FONT, "Arial");
     }

   ObjectSetInteger(0, obj, OBJPROP_CORNER, DashCorner);
   ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, obj, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, obj, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, MathMax(8, DashFontSize - 1));
   ObjectSetInteger(0, obj, OBJPROP_BGCOLOR, DashBgColor);
   ObjectSetInteger(0, obj, OBJPROP_COLOR, DashHeaderColor);
   ObjectSetString(0, obj, OBJPROP_TEXT, text);
  }

// one data row: name, buy cell, sell cell, profit cell
void SetDashRow(string name, string label, string buyCell, string sellCell, string profitCell,
                int row, int panelWidth, color labelColor, color buyColor, color sellColor, color profitColor)
  {
   int cw = DashCharWidth();
   int y  = DashRowY(row);

   SetDashText(name + "_c0", label,      DashColX(0,       panelWidth), y, labelColor);
   SetDashText(name + "_c1", buyCell,    DashColX(8  * cw, panelWidth), y, buyColor);
   SetDashText(name + "_c2", sellCell,   DashColX(22 * cw, panelWidth), y, sellColor);
   SetDashText(name + "_c3", profitCell, DashColX(36 * cw, panelWidth), y, profitColor);
  }

string StatsCell(int count, double lots)
  {
   return IntegerToString(count) + " / " + DoubleToString(lots, 2);
  }

color ProfitColor(double profit)
  {
   if(profit > 0) return DashProfitColor;
   if(profit < 0) return DashLossColor;
   return DashTextColor;
  }

bool RefreshIntervalPassed(uint &lastRefreshMs, uint intervalMs, bool force)
  {
   uint nowMs = (uint)GetTickCount();

   if(force || lastRefreshMs == 0 || nowMs - lastRefreshMs >= intervalMs)
     {
      lastRefreshMs = nowMs;
      return true;
     }

   return false;
  }

void RefreshVisuals(bool force = false)
  {
   bool didRefresh = false;

   if(ShowDashboard && RefreshIntervalPassed(lastDashboardRefreshMs, 500, force))
     {
      DrawDashboard();
      didRefresh = true;
     }
   else if(!ShowDashboard && force)
     {
      RemoveDashboard();
      didRefresh = true;
     }

   if(RefreshIntervalPassed(lastEmaRefreshMs, 2000, force))
     {
      DrawEMAs();
      didRefresh = true;
     }

   if(RefreshIntervalPassed(lastDailyLevelsRefreshMs, 1000, force))
     {
      DrawDailyLevels();
      didRefresh = true;
     }

   if(didRefresh)
      ChartRedraw();
  }

void DrawDashboard()
  {
   if(!ShowDashboard) return;

   int    buy1 = 0, sell1 = 0, pend1 = 0, buy2 = 0, sell2 = 0, pend2 = 0;
   int    buyMid = 0, sellMid = 0, pendMid = 0;
   int    buyRes1 = 0, sellRes1 = 0, pendRes1 = 0;
   int    buyRes2 = 0, sellRes2 = 0, pendRes2 = 0;
   
   double buyLots1 = 0, sellLots1 = 0, profit1 = 0;
   double buyLots2 = 0, sellLots2 = 0, profit2 = 0;
   double buyLotsMid = 0, sellLotsMid = 0, profitMid = 0;
   double buyLotsRes1 = 0, sellLotsRes1 = 0, profitRes1 = 0;
   double buyLotsRes2 = 0, sellLotsRes2 = 0, profitRes2 = 0;

   SegmentStats(magicNumber,  buy1, sell1, buyLots1, sellLots1, profit1, pend1);
   SegmentStats(magicNumber2, buy2, sell2, buyLots2, sellLots2, profit2, pend2);
   SegmentStats(MidBreak_Magic, buyMid, sellMid, buyLotsMid, sellLotsMid, profitMid, pendMid);
   SegmentStats(Rescue_Magic1, buyRes1, sellRes1, buyLotsRes1, sellLotsRes1, profitRes1, pendRes1);
   SegmentStats(Rescue_Magic2, buyRes2, sellRes2, buyLotsRes2, sellLotsRes2, profitRes2, pendRes2);

   double totalProfit = profit1 + profit2 + profitMid + profitRes1 + profitRes2;

   int cw       = DashCharWidth();
   int rh       = DashRowHeight();
   int pad      = 6;
   int panelW   = 54 * cw + pad * 2;
   int panelH   = DashRowCount() * rh + pad * 2;
   int row      = 0;

   SetDashPanel("bg", DashX - pad, DashY - pad, panelW, panelH);

   SetDashText("title", Symbol() + "   GOLDGUARD HEDGE", DashColX(0, panelW), DashRowY(row), DashTitleColor);
   SetDashText("title_time", TimeToString(TimeCurrent(), TIME_MINUTES), DashColX(36 * cw, panelW), DashRowY(row), DashTitleColor);
   if(DashShowResetButton && DashShowHistory)
      SetDashButton("reset", "RESET", DashColX(45 * cw, panelW), DashRowY(row) - 2, 9 * cw, rh - 2);
   row++;

   SetDashButton("closeall", "CLOSE ALL", DashColX(45 * cw, panelW), DashRowY(row) - 2, 9 * cw, rh - 2);

   SetDashRow("head", "", "BUY", "SELL", "PROFIT", row++, panelW,
              DashHeaderColor, clrLime, clrRed, clrDeepSkyBlue);

   if(segment1)
     {
      SetDashRow("seg1", "SEG 1", StatsCell(buy1, buyLots1), StatsCell(sell1, sellLots1),
                 DoubleToString(profit1, 2), row++, panelW,
                 DashTextColor, DashBuyColor, DashSellColor, ProfitColor(profit1));
     }

   if(segment2)
     {
      SetDashRow("seg2", "SEG 2", StatsCell(buy2, buyLots2), StatsCell(sell2, sellLots2),
                 DoubleToString(profit2, 2), row++, panelW,
                 DashTextColor, DashBuyColor, DashSellColor, ProfitColor(profit2));
     }

   if(Enable_MidBreakout)
     {
      SetDashRow("mid", "MID BRK", StatsCell(buyMid, buyLotsMid), StatsCell(sellMid, sellLotsMid),
                 DoubleToString(profitMid, 2), row++, panelW,
                 DashTextColor, DashBuyColor, DashSellColor, ProfitColor(profitMid));
     }

   if(Enable_Rescue)
     {
      int buyRes = buyRes1 + buyRes2;
      int sellRes = sellRes1 + sellRes2;
      double buyLotsRes = buyLotsRes1 + buyLotsRes2;
      double sellLotsRes = sellLotsRes1 + sellLotsRes2;
      double profitRes = profitRes1 + profitRes2;
      
      SetDashRow("rescue", "RESCUE", StatsCell(buyRes, buyLotsRes), StatsCell(sellRes, sellLotsRes),
                 DoubleToString(profitRes, 2), row++, panelW,
                 DashTextColor, DashBuyColor, DashSellColor, ProfitColor(profitRes));
     }

   SetDashRow("total", "TOTAL", StatsCell(buy1 + buy2 + buyMid + buyRes1 + buyRes2, buyLots1 + buyLots2 + buyLotsMid + buyLotsRes1 + buyLotsRes2),
              StatsCell(sell1 + sell2 + sellMid + sellRes1 + sellRes2, sellLots1 + sellLots2 + sellLotsMid + sellLotsRes1 + sellLotsRes2),
              DoubleToString(totalProfit, 2), row++, panelW,
              DashTextColor, DashBuyColor, DashSellColor, ProfitColor(totalProfit));

   double target1 = BasketTarget(buyLots1 + sellLots1);
   double target2 = BasketTarget(buyLots2 + sellLots2);
   double target  = segment2 ? MathMax(target1, target2) : target1;

   if(DashShowHistory)
     {
      int    hBuyD = 0, hSellD = 0, hBuyW = 0, hSellW = 0, hBuyA = 0, hSellA = 0;
      double hBuyLotsD = 0, hSellLotsD = 0, hProfitD = 0;
      double hBuyLotsW = 0, hSellLotsW = 0, hProfitW = 0;
      double hBuyLotsA = 0, hSellLotsA = 0, hProfitA = 0;

      datetime now       = TimeCurrent();
      datetime dayStart  = now - (now % 86400);
      int      dayOfWeek = DayOfWeek();
      // trading week runs monday to friday, sunday counts as the start of the new week
      datetime weekStart = (dayOfWeek == 0) ? dayStart : dayStart - (dayOfWeek - 1) * 86400;

      HistoryStats(dayStart,  hBuyD, hSellD, hBuyLotsD, hSellLotsD, hProfitD);
      HistoryStats(weekStart, hBuyW, hSellW, hBuyLotsW, hSellLotsW, hProfitW);
      HistoryStats(0,         hBuyA, hSellA, hBuyLotsA, hSellLotsA, hProfitA);

      string historyLabel = "CLOSED ORDERS";
      datetime resetFrom = EffectiveStatsStartTime(0);
      if(resetFrom > 0)
         historyLabel = "CLOSED FROM " + TimeToString(resetFrom, TIME_DATE|TIME_MINUTES);

      SetDashText("sep", historyLabel, DashColX(0, panelW), DashRowY(row++), DashTitleColor);

      SetDashRow("histday", "DAY", StatsCell(hBuyD, hBuyLotsD), StatsCell(hSellD, hSellLotsD),
                 DoubleToString(hProfitD, 2), row++, panelW,
                 DashTextColor, DashBuyColor, DashSellColor, ProfitColor(hProfitD));

      SetDashRow("histweek", "WEEK", StatsCell(hBuyW, hBuyLotsW), StatsCell(hSellW, hSellLotsW),
                 DoubleToString(hProfitW, 2), row++, panelW,
                 DashTextColor, DashBuyColor, DashSellColor, ProfitColor(hProfitW));

      SetDashRow("histall", "ALL", StatsCell(hBuyA, hBuyLotsA), StatsCell(hSellA, hSellLotsA),
                 DoubleToString(hProfitA, 2), row++, panelW,
                 DashTextColor, DashBuyColor, DashSellColor, ProfitColor(hProfitA));
     }

   if(EnableNewsFilter)
     {
      string newsStatus = "NEWS: CLEAR (TRADING ALLOWED)";
      color newsColor = clrLimeGreen; // Силна зелена боја кога е безбедно
      
      if(NewsBlocksFreshSeries())
        {
         newsStatus = "NEWS: DANGER! (TRADING BLOCKED)";
         newsColor = clrOrangeRed; // Силна портокалово-црвена боја кога е блокирано
        }
      
      string newsInfo = GetNextNewsEventInfo();
      if(newsInfo == "") newsInfo = "FETCHING NEWS DATA...";
      
      SetDashText("news_sep", "--- NEWS STATUS ---", DashColX(0, panelW), DashRowY(row++), DashTitleColor);
      SetDashText("news_stat", newsStatus, DashColX(0, panelW), DashRowY(row++), newsColor);
      SetDashText("news_info", newsInfo, DashColX(0, panelW), DashRowY(row++), DashTitleColor);

      string pauseText  = "PAUSE FROM: -";
      string resumeText = "RESUME AT : -";
      datetime nextEventTime = GetNextNewsEventTime();
      bool newsPaused = NewsBlocksFreshSeries();
      string stateTag = newsPaused ? "  PAUSED" : "  ON";
      if(nextEventTime > 0)
        {
         pauseText  = "PAUSE FROM: " + TimeToString(nextEventTime - NewsBlockMinutesBefore * 60, TIME_DATE|TIME_MINUTES) + stateTag;
         resumeText = "RESUME AT : " + TimeToString(nextEventTime + NewsBlockMinutesAfter * 60, TIME_DATE|TIME_MINUTES) + stateTag;
        }
      color stateColor = newsPaused ? clrOrangeRed : clrLimeGreen;
      SetDashText("news_pause",  pauseText,  DashColX(0, panelW), DashRowY(row++), stateColor);
      SetDashText("news_resume", resumeText, DashColX(0, panelW), DashRowY(row++), stateColor);
     }

   SetDashText("info", "GAP " + DoubleToString(GapDistance() / pipSize, 1) + " pip"
               + "   SPREAD " + DoubleToString((Ask - Bid) / pipSize, 1)
               + "   PEND " + IntegerToString(pend1 + pend2)
               + "   TARGET " + DoubleToString(target, 2),
               DashColX(0, panelW), DashRowY(row), clrDeepSkyBlue);
  }

void RemoveDashboard()
  {
   ObjectsDeleteAll(0, dashPrefix);
   ChartRedraw();
  }
  
void DrawEMAs()
  {
   if(!ShowEmaLines)
     {
      RemoveEMAs();
      return;
     }

   if(DirMethod == MovingAverage)
      DrawEMALine(1, DirTimeframe, DirMaPeriod, ColorDirEma);
   else
      ObjectsDeleteAll(0, "EA_EMA_Line_1_");
   
   if(FirstEntryConfirm == ConfirmBreakAndEMA)
      DrawEMALine(2, ConfirmTimeframe, ConfirmMaPeriod, ColorConfirmEma);
   else
      ObjectsDeleteAll(0, "EA_EMA_Line_2_");
  }

void DrawEMALine(int id, ENUM_TIMEFRAMES tf, int period, color clr)
  {
   int limit = MathMin(EmaBarsToDraw, Bars - 2);
   for(int i = 0; i < limit; i++)
     {
      string objName = "EA_EMA_Line_" + IntegerToString(id) + "_" + IntegerToString(i);
      
      datetime time1 = Time[i];
      datetime time2 = Time[i+1];
      
      int shift1 = iBarShift(Symbol(), tf, time1);
      int shift2 = iBarShift(Symbol(), tf, time2);
      
      double ema1 = iMA(Symbol(), tf, period, 0, MODE_EMA, PRICE_CLOSE, shift1);
      double ema2 = iMA(Symbol(), tf, period, 0, MODE_EMA, PRICE_CLOSE, shift2);
      
      if(ObjectFind(0, objName) < 0)
        {
         ObjectCreate(0, objName, OBJ_TREND, 0, time2, ema2, time1, ema1);
         ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
         ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
         ObjectSetInteger(0, objName, OBJPROP_RAY_RIGHT, false);
         ObjectSetInteger(0, objName, OBJPROP_BACK, true);
         ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, objName, OBJPROP_HIDDEN, true);
        }
      else
        {
         ObjectMove(0, objName, 0, time2, ema2);
         ObjectMove(0, objName, 1, time1, ema1);
        }
     }
  }

void RemoveEMAs()
  {
   ObjectsDeleteAll(0, "EA_EMA_Line_");
  }

void DrawDailyLevels()
  {
   if(!Use_DailyLevels)
     {
      RemoveDailyLevels();
      return;
     }

   int dayShift = DL_UseCurrentDay ? 0 : 1;
   dayShift += DL_ShiftBars;
   
   double dHigh = iHigh(Symbol(), PERIOD_D1, dayShift);
   double dLow  = iLow(Symbol(), PERIOD_D1, dayShift);
   
   if(dHigh <= 0 || dLow <= 0) return;

   double dMid = (dHigh + dLow) / 2.0;
   double dMidHigh = (dHigh + dMid) / 2.0;
   double dLowMid = (dLow + dMid) / 2.0;

   int chartBars = iBars(Symbol(), Period());
   if (chartBars < 1) return;
   
   int shiftBars = DL_ShiftBars;
   if (shiftBars < 0) shiftBars = 0;
   if (shiftBars >= chartBars) shiftBars = chartBars - 1;

   datetime startTime = iTime(Symbol(), Period(), shiftBars);
   datetime currentTime = iTime(Symbol(), Period(), 0);
   
   if (startTime <= 0 || currentTime <= 0) return;

   int secondsPerBar = PeriodSeconds(Period());
   if (secondsPerBar <= 0) secondsPerBar = 60;

   int hShiftSec = secondsPerBar * DL_HShiftBars;

   int futureBars = DL_FutureBars;
   if (futureBars < 1) futureBars = 1;

   startTime          = startTime + hShiftSec;
   datetime endTime   = currentTime + (secondsPerBar * futureBars) + hShiftSec;
   datetime labelTime = currentTime + (secondsPerBar * DL_LabelShiftBars) + hShiftSec;
   
   if(DL_ShowHigh) DrawDLObj("DL_High", dHigh, startTime, endTime, labelTime, DL_HighColor, DL_LineWidth, DL_HighLabel);
   else { ObjectDelete(0, "DL_High"); ObjectDelete(0, "DL_High_L"); }
   
   if(DL_ShowLow) DrawDLObj("DL_Low", dLow, startTime, endTime, labelTime, DL_LowColor, DL_LineWidth, DL_LowLabel);
   else { ObjectDelete(0, "DL_Low"); ObjectDelete(0, "DL_Low_L"); }
   
   if(DL_ShowMid) DrawDLObj("DL_Mid", dMid, startTime, endTime, labelTime, DL_MidColor, DL_LineWidth, DL_MidLabel);
   else { ObjectDelete(0, "DL_Mid"); ObjectDelete(0, "DL_Mid_L"); }
   
   if(DL_ShowLowMid) DrawDLObj("DL_LowMid", dLowMid, startTime, endTime, labelTime, DL_LowMidColor, DL_SubLineWidth, DL_LowMidLabel);
   else { ObjectDelete(0, "DL_LowMid"); ObjectDelete(0, "DL_LowMid_L"); }
   
   if(DL_ShowMidHigh) DrawDLObj("DL_MidHigh", dMidHigh, startTime, endTime, labelTime, DL_MidHighColor, DL_SubLineWidth, DL_MidHighLabel);
   else { ObjectDelete(0, "DL_MidHigh"); ObjectDelete(0, "DL_MidHigh_L"); }
  }

void DrawDLObj(string name, double price, datetime t1, datetime t2, datetime labelTime, color clr, int width, string labelText)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
   else
     {
      ObjectMove(0, name, 0, t1, price);
      ObjectMove(0, name, 1, t2, price);
     }
     
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, DL_ExtendRight);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);

   string labelName = name + "_L";
   if(DL_ShowLabels)
     {
      if(ObjectFind(0, labelName) < 0)
        {
         ObjectCreate(0, labelName, OBJ_TEXT, 0, labelTime, price);
         ObjectSetInteger(0, labelName, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, labelName, OBJPROP_HIDDEN, true);
        }
      else
        {
         ObjectSetInteger(0, labelName, OBJPROP_TIME, labelTime);
         ObjectSetDouble(0, labelName, OBJPROP_PRICE, price);
        }
        
      string finalLabel = labelText;
      if(DL_ShowPrice) finalLabel += " (" + DoubleToString(price, Digits) + ")";
      
      ObjectSetString(0, labelName, OBJPROP_TEXT, " " + finalLabel);
      ObjectSetInteger(0, labelName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 9);
      ObjectSetString(0, labelName, OBJPROP_FONT, "Arial");
      
      if(DL_LabelAbove) 
         ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      else 
         ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
     }
   else
     {
      ObjectDelete(0, labelName);
     }
  }

void RemoveDailyLevels()
  {
   ObjectDelete(0, "DL_High"); ObjectDelete(0, "DL_High_L");
   ObjectDelete(0, "DL_Low"); ObjectDelete(0, "DL_Low_L");
   ObjectDelete(0, "DL_Mid"); ObjectDelete(0, "DL_Mid_L");
   ObjectDelete(0, "DL_LowMid"); ObjectDelete(0, "DL_LowMid_L");
   ObjectDelete(0, "DL_MidHigh"); ObjectDelete(0, "DL_MidHigh_L");
  }
  
//+------------------------------------------------------------------+
//| MID BREAKOUT STRATEGY FUNCTIONS                                  |
//+------------------------------------------------------------------+
double GetDailyLevelValue(int type)
  {
   int dayShift = MidBreak_UsePrevDayLevels ? 1 : (DL_UseCurrentDay ? 0 : 1);
   dayShift += DL_ShiftBars;
   double dHigh = iHigh(Symbol(), PERIOD_D1, dayShift);
   double dLow  = iLow(Symbol(), PERIOD_D1, dayShift);
   if(dHigh <= 0 || dLow <= 0) return 0;
   
   double dMid = (dHigh + dLow) / 2.0;
   
   if(type == 1) return dHigh;
   if(type == 2) return (dHigh + dMid) / 2.0; // MidHigh
   if(type == 3) return dMid;
   if(type == 4) return (dLow + dMid) / 2.0;  // LowMid
   if(type == 5) return dLow;
   
   return 0;
  }

int CountMidBreakoutOrders()
  {
   int count = 0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MidBreak_Magic)
            count++;
        }
     }
   return count;
  }

void CheckMidBreakoutSignal()
  {
   if(!Enable_MidBreakout) return;
   
   datetime candleTime = iTime(Symbol(), MidBreak_Timeframe, 1);
   if(candleTime == lastMidSignalTime) return; // Already checked this candle
   
   double dMid = GetDailyLevelValue(3);
   if(dMid <= 0) return;
   
   double open = iOpen(Symbol(), MidBreak_Timeframe, 1);
   double close = iClose(Symbol(), MidBreak_Timeframe, 1);
   double high = iHigh(Symbol(), MidBreak_Timeframe, 1);
   double low = iLow(Symbol(), MidBreak_Timeframe, 1);
   
   double bodyPips = MathAbs(close - open) / pipSize;
   double totalPips = (high - low) / pipSize;
   
   // Reset previous signal if it wasn't triggered
   if(candleTime > lastMidSignalTime)
      midSignalDir = -1;
   
   if(bodyPips >= MidBreak_MinCandlePips && totalPips <= MidBreak_MaxCandlePips)
     {
      int dir = -1;
      if(open < dMid && close > dMid)       dir = OP_BUY;
      else if(open > dMid && close < dMid) dir = OP_SELL;

      if(dir >= 0)
        {
         string skipReason = "";

         // ATR filter: silno telo + zatvoranje kaj ekstremot na svekjata
         if(MidBreak_UseAtrFilter)
           {
            double atr = iATR(Symbol(), MidBreak_Timeframe, MidBreak_AtrPeriod, 1);
            if(atr <= 0 || bodyPips * pipSize < MidBreak_MinBodyATR * atr)
               skipReason = "ATR filter (body < " + DoubleToString(MidBreak_MinBodyATR, 2) + "xATR)";
            else if(dir == OP_BUY && (high - close) > (high - low) * MidBreak_MaxClosePosPct / 100.0)
               skipReason = "close not in top " + DoubleToString(MidBreak_MaxClosePosPct, 0) + "% of candle";
            else if(dir == OP_SELL && (close - low) > (high - low) * MidBreak_MaxClosePosPct / 100.0)
               skipReason = "close not in bottom " + DoubleToString(MidBreak_MaxClosePosPct, 0) + "% of candle";
           }

         // Trend filter: samo vo nasoka na EMA na MidBreak_TrendTF
         if(skipReason == "" && MidBreak_UseTrendFilter)
           {
            double ema = iMA(Symbol(), MidBreak_TrendTF, MidBreak_TrendEmaPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
            if(dir == OP_BUY && close <= ema)       skipReason = "trend filter (close <= EMA)";
            else if(dir == OP_SELL && close >= ema) skipReason = "trend filter (close >= EMA)";
           }

         // Session filter po server vreme
         if(skipReason == "" && MidBreak_UseSessionFilter)
           {
            int hr = TimeHour(candleTime);
            bool inSession = (MidBreak_SessionStartHour <= MidBreak_SessionEndHour)
                             ? (hr >= MidBreak_SessionStartHour && hr < MidBreak_SessionEndHour)
                             : (hr >= MidBreak_SessionStartHour || hr < MidBreak_SessionEndHour);
            if(!inSession) skipReason = "outside session hours";
           }

         // Exhausted day: denesniot opseg veke go minal dnevniot ATR
         if(skipReason == "" && MidBreak_UseExhaustedDayFilter)
           {
            double dayRange = iHigh(Symbol(), PERIOD_D1, 0) - iLow(Symbol(), PERIOD_D1, 0);
            double atrD = iATR(Symbol(), PERIOD_D1, MidBreak_DailyAtrPeriod, 1);
            if(atrD > 0 && dayRange > MidBreak_MaxDayRangeATR * atrD)
               skipReason = "day range already > " + DoubleToString(MidBreak_MaxDayRangeATR, 2) + "xATR(D1)";
           }

         // Max 1 trejd dnevno po nasoka (i posle SL)
         if(skipReason == "" && MidBreak_OneTradePerDayDir)
           {
            datetime today = TimeCurrent() - TimeCurrent() % 86400;
            if(dir == OP_BUY && midLastBuyDay == today)        skipReason = "BUY already traded today";
            else if(dir == OP_SELL && midLastSellDay == today) skipReason = "SELL already traded today";
           }

         if(skipReason != "")
           {
            Print("Mid Breakout: ", (dir == OP_BUY ? "BUY" : "SELL"), " signal skipped: ", skipReason);
            lastMidSignalTime = candleTime;
           }
         else if(dir == OP_BUY)
           {
            // Bullish Breakout
            midSignalDir = OP_BUY;
            midSignalHigh = high;
            midSignalLow = low;
            lastMidSignalTime = candleTime;
            Print("Mid Breakout: BUY Signal Detected at ", DoubleToString(close, Digits));
           }
         else
           {
            // Bearish Breakout
            midSignalDir = OP_SELL;
            midSignalHigh = high;
            midSignalLow = low;
            lastMidSignalTime = candleTime;
            Print("Mid Breakout: SELL Signal Detected at ", DoubleToString(close, Digits));
           }
        }
     }
  }

void ProcessMidBreakout()
  {
   if(!Enable_MidBreakout) return;
   if(CountMidBreakoutOrders() > 0) return; // Only 1 active trade at a time
   if(midSignalDir == -1) return;           // No active signal

   // Isti globalni filtri kako grid: news + spread/weekend/midnight block.
   // Signalot ostava zhiv - samo odlozhi vlezot.
   if(MidBreak_UseGlobalFilters && (NewsBlocksFreshSeries() || !CanOpenFirstEntry()))
      return;

   // Expire signal if a new candle closed
   datetime currentCandleTime = iTime(Symbol(), MidBreak_Timeframe, 0);
   if(currentCandleTime > lastMidSignalTime + PeriodSeconds(MidBreak_Timeframe))
     {
      midSignalDir = -1;
      return;
     }
     
   RefreshRates();
   double buffer = MidBreak_BreakBufferPips * pipSize;
   datetime today = TimeCurrent() - TimeCurrent() % 86400;

   if(midSignalDir == OP_BUY)
     {
      // Pending Buy Stop na high+buffer (ako cenata veke e nad entry -> market pat podolu)
      if(MidBreak_UsePendingStop && Ask < midSignalHigh + buffer)
        {
         double entry = NormalizeDouble(midSignalHigh + buffer, Digits);
         double sl = NormalizeDouble(midSignalLow, Digits);
         if((entry - sl) / pipSize > MidBreak_MaxSlPips)
            sl = NormalizeDouble(entry - (MidBreak_MaxSlPips * pipSize), Digits);
         double tp = NormalizeDouble(GetDailyLevelValue(2), Digits); // MidHigh
         if(tp - entry < MidBreak_MinTpPips * pipSize)
            tp = NormalizeDouble(GetDailyLevelValue(1), Digits); // High
         double risk = entry - sl;
         double reward = tp - entry;
         if(reward >= MidBreak_MinTpPips * pipSize && reward >= risk * MidBreak_MinRR)
           {
            if(entry - Ask >= MinStopDistance())
              {
               int ticket = OrderSend(Symbol(), OP_BUYSTOP, NormalizeLots(MidBreak_Lot), entry, SlippagePoints, sl, tp, "Mid Breakout BUY", MidBreak_Magic, 0, clrBlue);
               if(ticket > 0)
                 {
                  Print("Mid Breakout: BUY STOP placed. Ticket: ", ticket, " @ ", DoubleToString(entry, Digits));
                  midPendingTicket = ticket;
                  midPendingPlacedBar = iTime(Symbol(), MidBreak_Timeframe, 0);
                  midLastBuyDay = today;
                  midSignalDir = -1;
                 }
              }
            else
              {
               static datetime lastBuyStopSkip = 0;
               if(TimeCurrent() != lastBuyStopSkip)
                 {
                  Print("Mid Breakout BUY STOP skipped: entry too close to price");
                  lastBuyStopSkip = TimeCurrent();
                 }
              }
           }
         else
           {
            static datetime lastBuyPendSkip = 0;
            if(TimeCurrent() != lastBuyPendSkip)
              {
               Print("Mid Breakout BUY STOP skipped: Bad Risk/Reward (Risk: ", DoubleToString(risk/pipSize, 1), " pips, Reward: ", DoubleToString(reward/pipSize, 1), " pips)");
               lastBuyPendSkip = TimeCurrent();
              }
           }
        }
      else if(Ask >= midSignalHigh + buffer)
        {
      double sl = NormalizeDouble(midSignalLow, Digits); 
      
      // Limit SL to MaxSlPips
      if((Ask - sl) / pipSize > MidBreak_MaxSlPips)
         sl = NormalizeDouble(Ask - (MidBreak_MaxSlPips * pipSize), Digits);
         
      double tp = NormalizeDouble(GetDailyLevelValue(2), Digits); // MidHigh
      
      // Провери дали TP е премногу блиску. Ако е помало од MinTpPips, гаѓај го следното ниво (High)
      if(tp - Ask < MidBreak_MinTpPips * pipSize)
         tp = NormalizeDouble(GetDailyLevelValue(1), Digits); // High
         
      double risk = Ask - sl;
      double reward = tp - Ask;
      
      // Risk/Reward & Min TP check
      if(reward >= MidBreak_MinTpPips * pipSize && reward >= risk * MidBreak_MinRR)
        {
         int ticket = OrderSend(Symbol(), OP_BUY, NormalizeLots(MidBreak_Lot), Ask, SlippagePoints, sl, tp, "Mid Breakout BUY", MidBreak_Magic, 0, clrBlue);
         if(ticket > 0) 
           {
            Print("Mid Breakout: BUY Executed. Ticket: ", ticket);
            midLastBuyDay = today;
            midSignalDir = -1; // Reset signal after successful entry
           }
        }
      else
        {
         // Print safety limit log once per signal to avoid spam
         static datetime lastBuySkip = 0;
         if(TimeCurrent() != lastBuySkip)
           {
            Print("Mid Breakout BUY skipped: Bad Risk/Reward (Risk: ", DoubleToString(risk/pipSize, 1), " pips, Reward: ", DoubleToString(reward/pipSize, 1), " pips)");
            lastBuySkip = TimeCurrent();
           }
        }
        }
     }
   else if(midSignalDir == OP_SELL)
     {
      // Pending Sell Stop na low-buffer (ako cenata veke e pod entry -> market pat podolu)
      if(MidBreak_UsePendingStop && Bid > midSignalLow - buffer)
        {
         double entry = NormalizeDouble(midSignalLow - buffer, Digits);
         double sl = NormalizeDouble(midSignalHigh, Digits);
         if((sl - entry) / pipSize > MidBreak_MaxSlPips)
            sl = NormalizeDouble(entry + (MidBreak_MaxSlPips * pipSize), Digits);
         double tp = NormalizeDouble(GetDailyLevelValue(4), Digits); // LowMid
         if(entry - tp < MidBreak_MinTpPips * pipSize)
            tp = NormalizeDouble(GetDailyLevelValue(5), Digits); // Low
         double risk = sl - entry;
         double reward = entry - tp;
         if(reward >= MidBreak_MinTpPips * pipSize && reward >= risk * MidBreak_MinRR)
           {
            if(Bid - entry >= MinStopDistance())
              {
               int ticket = OrderSend(Symbol(), OP_SELLSTOP, NormalizeLots(MidBreak_Lot), entry, SlippagePoints, sl, tp, "Mid Breakout SELL", MidBreak_Magic, 0, clrRed);
               if(ticket > 0)
                 {
                  Print("Mid Breakout: SELL STOP placed. Ticket: ", ticket, " @ ", DoubleToString(entry, Digits));
                  midPendingTicket = ticket;
                  midPendingPlacedBar = iTime(Symbol(), MidBreak_Timeframe, 0);
                  midLastSellDay = today;
                  midSignalDir = -1;
                 }
              }
            else
              {
               static datetime lastSellStopSkip = 0;
               if(TimeCurrent() != lastSellStopSkip)
                 {
                  Print("Mid Breakout SELL STOP skipped: entry too close to price");
                  lastSellStopSkip = TimeCurrent();
                 }
              }
           }
         else
           {
            static datetime lastSellPendSkip = 0;
            if(TimeCurrent() != lastSellPendSkip)
              {
               Print("Mid Breakout SELL STOP skipped: Bad Risk/Reward (Risk: ", DoubleToString(risk/pipSize, 1), " pips, Reward: ", DoubleToString(reward/pipSize, 1), " pips)");
               lastSellPendSkip = TimeCurrent();
              }
           }
        }
      else if(Bid <= midSignalLow - buffer)
        {
      double sl = NormalizeDouble(midSignalHigh, Digits);
      
      // Limit SL to MaxSlPips
      if((sl - Bid) / pipSize > MidBreak_MaxSlPips)
         sl = NormalizeDouble(Bid + (MidBreak_MaxSlPips * pipSize), Digits);
         
      double tp = NormalizeDouble(GetDailyLevelValue(4), Digits); // LowMid
      
      // Провери дали TP е премногу блиску. Ако е помало од MinTpPips, гаѓај го следното ниво (Low)
      if(Bid - tp < MidBreak_MinTpPips * pipSize)
         tp = NormalizeDouble(GetDailyLevelValue(5), Digits); // Low
         
      double risk = sl - Bid;
      double reward = Bid - tp;
      
      // Risk/Reward & Min TP check
      if(reward >= MidBreak_MinTpPips * pipSize && reward >= risk * MidBreak_MinRR)
        {
         int ticket = OrderSend(Symbol(), OP_SELL, NormalizeLots(MidBreak_Lot), Bid, SlippagePoints, sl, tp, "Mid Breakout SELL", MidBreak_Magic, 0, clrRed);
         if(ticket > 0) 
           {
            Print("Mid Breakout: SELL Executed. Ticket: ", ticket);
            midLastSellDay = today;
            midSignalDir = -1; // Reset signal after successful entry
           }
        }
      else
        {
         // Print safety limit log once per signal to avoid spam
         static datetime lastSellSkip = 0;
         if(TimeCurrent() != lastSellSkip)
           {
            Print("Mid Breakout SELL skipped: Bad Risk/Reward (Risk: ", DoubleToString(risk/pipSize, 1), " pips, Reward: ", DoubleToString(reward/pipSize, 1), " pips)");
            lastSellSkip = TimeCurrent();
           }
        }
        }
     }
  }

// Brise istareli MidBreak pending orders (ne se potpira na midPendingTicket -
// prezhiveuva i restart na terminalot bidejki bara po OrdersTotal).
void ExpireMidBreakoutPending()
  {
   if(!Enable_MidBreakout || !MidBreak_UsePendingStop) return;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != MidBreak_Magic) continue;
      if(OrderType() != OP_BUYSTOP && OrderType() != OP_SELLSTOP) continue;
      if(iBarShift(Symbol(), MidBreak_Timeframe, OrderOpenTime()) >= MidBreak_PendingExpiryBars)
        {
         int ticket = OrderTicket();
         if(OrderDelete(ticket))
            Print("Mid Breakout: pending #", ticket, " expired after ", MidBreak_PendingExpiryBars, " bars");
         if(midPendingTicket == ticket) midPendingTicket = 0;
        }
     }
  }

void ManageMidBreakout()
  {
   if(!Enable_MidBreakout || !MidBreak_UseBreakEven) return;
   
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MidBreak_Magic)
           {
            double openPrice = OrderOpenPrice();
            double tp = OrderTakeProfit();
            double sl = OrderStopLoss();
            
            if(tp <= 0) continue; // No TP set

            // BE trigger: ATR-baziran ili fiksni pips
            double beTrigger = MidBreak_UseAtrBE
                               ? MidBreak_BE_ATR * iATR(Symbol(), MidBreak_Timeframe, MidBreak_AtrPeriod, 1)
                               : MidBreak_BE_TriggerPips * pipSize;

            if(OrderType() == OP_BUY)
              {
               if(Bid >= openPrice + beTrigger)
                 {
                  if(sl < openPrice) // If SL is still below entry
                    {
                     if(OrderModify(OrderTicket(), openPrice, openPrice, tp, 0, clrBlue))
                       {
                        Print("Mid Breakout: BUY StopLoss moved to Break-Even");
                        sl = openPrice;
                       }
                    }
                 }
               // Swing trail: posle BE, SL pod najnizok low od poslednite N zatvoreni sveki
               if(MidBreak_UseSwingTrail && sl >= openPrice && sl > 0)
                 {
                  static datetime lastBuyTrailBar = 0;
                  datetime trailBar = iTime(Symbol(), MidBreak_Timeframe, 0);
                  if(trailBar != lastBuyTrailBar)
                    {
                     lastBuyTrailBar = trailBar;
                     int li = iLowest(Symbol(), MidBreak_Timeframe, MODE_LOW, MidBreak_TrailSwingBars, 1);
                     if(li >= 0)
                       {
                        double swing = NormalizeDouble(iLow(Symbol(), MidBreak_Timeframe, li), Digits);
                        if(swing > sl + Point && Bid - swing >= MinStopDistance())
                          {
                           if(OrderModify(OrderTicket(), openPrice, swing, tp, 0, clrBlue))
                              Print("Mid Breakout: BUY SL trailed to swing low ", DoubleToString(swing, Digits));
                          }
                       }
                    }
                 }
              }
            else if(OrderType() == OP_SELL)
              {
               if(Ask <= openPrice - beTrigger)
                 {
                  if(sl > openPrice || sl == 0) // If SL is still above entry
                    {
                     if(OrderModify(OrderTicket(), openPrice, openPrice, tp, 0, clrRed))
                       {
                        Print("Mid Breakout: SELL StopLoss moved to Break-Even");
                        sl = openPrice;
                       }
                    }
                 }
               // Swing trail: posle BE, SL nad najvisok high od poslednite N zatvoreni sveki
               if(MidBreak_UseSwingTrail && sl > 0 && sl <= openPrice)
                 {
                  static datetime lastSellTrailBar = 0;
                  datetime trailBar = iTime(Symbol(), MidBreak_Timeframe, 0);
                  if(trailBar != lastSellTrailBar)
                    {
                     lastSellTrailBar = trailBar;
                     int hi = iHighest(Symbol(), MidBreak_Timeframe, MODE_HIGH, MidBreak_TrailSwingBars, 1);
                     if(hi >= 0)
                       {
                        double swing = NormalizeDouble(iHigh(Symbol(), MidBreak_Timeframe, hi), Digits);
                        if(swing < sl - Point && swing - Ask >= MinStopDistance())
                          {
                           if(OrderModify(OrderTicket(), openPrice, swing, tp, 0, clrRed))
                              Print("Mid Breakout: SELL SL trailed to swing high ", DoubleToString(swing, Digits));
                          }
                       }
                    }
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| RESCUE MODULE FUNCTIONS                                          |
//+------------------------------------------------------------------+
int CountRescueOrders(int magic)
  {
   int count = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
            count++;
        }
     }
   return count;
  }

double RescueProfit(int magic)
  {
   double profit = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
            profit += OrderProfit() + OrderSwap() + OrderCommission();
        }
     }
   return profit;
  }

void CloseRescueOrders(int magic)
  {
   RefreshRates();
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
           {
            double price = (OrderType() == OP_BUY) ? Bid : Ask;
            if(!OrderClose(OrderTicket(), OrderLots(), price, SlippagePoints, clrMagenta))
               Print("Failed to close rescue order ", OrderTicket(), " Error: ", GetLastError());
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| ACCOUNT AUTHORIZATION MODULE                                     |
//+------------------------------------------------------------------+
bool CheckAccountAuthorization()
  {
   if(AllowedAccounts == "") return true; // Ако е празно, дозволи ги сите сметки
   
   string accounts[];
   ushort sep = StringGetCharacter(",", 0);
   int k = StringSplit(AllowedAccounts, sep, accounts);
   
   string currentAccStr = IntegerToString(AccountNumber());
   
   for(int i=0; i<k; i++)
     {
      string acc = accounts[i];
      StringTrimLeft(acc);
      StringTrimRight(acc);
      if(acc == currentAccStr) return true;
     }
     
   return false;
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!CheckAccountAuthorization())
     {
      Print("EA BLOCKED: Account ", AccountNumber(), " is not authorized!");
      Alert("EA BLOCKED: Account ", AccountNumber(), " is not authorized!");
      return(INIT_FAILED);
     }

   pipSize = PipSize();

   if(MagicNumber1 <= 0 || MagicNumber2 <= 0)
     {
      Print("Error: MagicNumber1 and MagicNumber2 must be positive numbers.");
      return(INIT_FAILED);
     }

   if(MagicNumber1 == MagicNumber2)
     {
      Print("Error: MagicNumber1 and MagicNumber2 must be different.");
      return(INIT_FAILED);
     }

   magicNumber  = MagicNumber1;
   magicNumber2 = MagicNumber2;

   RecoverExistingOrders();
   LoadStatsResetTime();

   Print(Symbol(), ": digits ", Digits,
         ", point ", DoubleToString(Point, 5),
         ", 1 pip ", DoubleToString(pipSize, 5),
         ", tp ", DoubleToString(TpPip * pipSize, 5),
         ", fixed gap ", DoubleToString(GapSizePip * pipSize, 5),
         ", gap ", DoubleToString(GapDistance(), 5),
         ", stop level ", DoubleToString(MinStopDistance(), 5),
         ", magic1 ", magicNumber, ", magic2 ", magicNumber2);

   if(GapDistance() <= MinStopDistance())
      Print("Warning: GapDistance() is smaller than the minimum stop distance of the broker, pending orders will be pushed away.");

   if(MaxOrdersPerSegment > 0 || MaxLotsPerSegment > 0 || MaxBasketLossPerSegment > 0 || MinFirstOrderCloseProfit > 0)
      Print("Safety active: MinFirstOrderCloseProfit=", DoubleToString(MinFirstOrderCloseProfit, 2),
            ", MaxOrdersPerSegment=", MaxOrdersPerSegment,
            ", MaxLotsPerSegment=", DoubleToString(MaxLotsPerSegment, 2),
            ", MaxBasketLossPerSegment=", DoubleToString(MaxBasketLossPerSegment, 2));

   RefreshVisuals(true);
   EventSetTimer(1);
   
   return(INIT_SUCCEEDED);
  }
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   RemoveDashboard();
   RemoveEMAs();
   RemoveDailyLevels();
  }
  
//+------------------------------------------------------------------+
//| Timer function, keeps the dashboard fresh without ticks          |
//+------------------------------------------------------------------+
void OnTimer()
  {
   RefreshVisuals();
  }

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id != CHARTEVENT_OBJECT_CLICK) return;

   if(sparam == dashPrefix + "closeall")
     {
      ObjectSetInteger(0, dashPrefix + "closeall", OBJPROP_STATE, false);
      Print("CLOSE ALL button pressed: closing all EA orders.");
      CloseOrders();
      DeleteAllPendingStopOrders();
      CloseRescueOrders(Rescue_Magic1);
      CloseOrders2();
      DeleteAllPendingStopOrders2();
      CloseRescueOrders(Rescue_Magic2);
      RefreshVisuals(true);
      return;
     }

   if(sparam != dashPrefix + "reset") return;

   ResetHistoryStats();
   RefreshVisuals(true);
  }
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
bool WeekendCloseNow()
  {
   if(!EnableWeekendProtection || !CloseBasketOnFriday) return false;

   datetime now = TimeCurrent();
   return (TimeDayOfWeek(now) == 5 && TimeHour(now) >= FridayCloseHour);
  }

void WeekendCloseCheck()
  {
   if(!WeekendCloseNow()) return;

   if(segment1 && (CountMarketOrders() > 0 || CountRescueOrders(Rescue_Magic1) > 0) && (TotalProfit() + RescueProfit(Rescue_Magic1)) >= -MaxWeekendCloseLoss)
     {
      PrintSafetyOncePerMinute("Weekend close: closing segment 1 basket before the weekend, profit "
                               + DoubleToString(TotalProfit() + RescueProfit(Rescue_Magic1), 2), 1, false);
      CloseOrders();
      DeleteAllPendingStopOrders();
      CloseRescueOrders(Rescue_Magic1);
     }

   if(segment2 && (CountMarketOrders2() > 0 || CountRescueOrders(Rescue_Magic2) > 0) && (TotalProfit2() + RescueProfit(Rescue_Magic2)) >= -MaxWeekendCloseLoss)
     {
      PrintSafetyOncePerMinute("Weekend close: closing segment 2 basket before the weekend, profit "
                               + DoubleToString(TotalProfit2() + RescueProfit(Rescue_Magic2), 2), 2, false);
      CloseOrders2();
      DeleteAllPendingStopOrders2();
      CloseRescueOrders(Rescue_Magic2);
     }
  }

void OnTick()
  {
         if(pipSize <= 0) pipSize = PipSize();
         double pip= pipSize;
         
         WeekendCloseCheck();
         
         // Повици за Mid Breakout Стратегијата
         CheckMidBreakoutSignal();
         ProcessMidBreakout();
         ExpireMidBreakoutPending();
         ManageMidBreakout();
         
         if(segment1 == true)
         {
            int marketOrders1 = CountMarketOrders();
            double totalLots1 = TotalLots();
            double totalProfit1 = TotalProfit();
            
            int rescueCount1 = 0;
            double rescueProf1 = 0;
            if(Enable_Rescue)
              {
               rescueCount1 = CountRescueOrders(Rescue_Magic1);
               rescueProf1 = RescueProfit(Rescue_Magic1);
              }

            if(EmergencyLossTriggered(1, marketOrders1 + rescueCount1, totalProfit1 + rescueProf1))
            {
               CloseOrders();
               DeleteAllPendingStopOrders();
               if(Enable_Rescue) CloseRescueOrders(Rescue_Magic1);
            }
            else
            {
            
            // --- RESCUE LOGIC SEGMENT 1 ---
            if(Enable_Rescue)
              {
               if(rescueCount1 == 0 && marketOrders1 >= 2 && totalProfit1 <= -Rescue_Activation_Loss)
                 {
                  int rDir = MarketDirection(-1);
                  if(rDir == OP_BUY || rDir == OP_SELL)
                    {
                     SendMarketOrder(rDir, Rescue_LotSize, Rescue_Magic1, clrMagenta);
                     Print("Rescue Module: Order opened for Segment 1");
                    }
                 }
                 
               if(rescueCount1 > 0 && (totalProfit1 + rescueProf1) >= Rescue_TargetProfit)
                 {
                  if(RefreshIntervalPassed(lastRescueCloseAttempt1Ms, 1000, false))
                    {
                     Print("Rescue Module: Target reached for Segment 1. Closing all.");
                     CloseOrders();
                     DeleteAllPendingStopOrders();
                     CloseRescueOrders(Rescue_Magic1);
                    }
                 }
              }
            // ------------------------------
            
            //First trade
            if(Count() == 0 && !NewsBlocksFreshSeries() && CanOpenFirstEntry() && CanPlaceNextSegmentOrder(1, marketOrders1, totalLots1, NormalizeLots(LotSize)))
            {            
               int firstSide = FirstOrderSide(FirstTrade, false);
               if(!FirstEntryConfirmed(firstSide))
                  firstSide = -1;
               
               if(firstSide == OP_BUY)
               {
                  SendMarketOrder(OP_BUY, LotSize, magicNumber, Blue);
               }
               else if(firstSide == OP_SELL)
               {
                  SendMarketOrder(OP_SELL, LotSize, magicNumber, Green);
               }
            }
            
            double lotSizePending;
            
            //sending pending orders
            if(CountPendingOrders() == 0)
            {
               marketOrders1 = CountMarketOrders();
               totalLots1 = TotalLots();
               double lastOrderOpenPrice = LastOrderOpenPrice();
               double entryPrice;
               
               if(LastOrderType() == 0) // buy, send sellstop order
               {
                  entryPrice = lastOrderOpenPrice - GapDistance();
                  lotSizePending = NextChainLot(LastOrderLotSize());
                  
                  if(CanPlaceNextSegmentOrder(1, marketOrders1, totalLots1, lotSizePending))
                     SendStopOrder(OP_SELLSTOP,lotSizePending,entryPrice,magicNumber,Green);
               }
               else if(LastOrderType() == 1) // Sell, send BuyStop order
               {
                  entryPrice = lastOrderOpenPrice + GapDistance();
                  lotSizePending = NextChainLot(LastOrderLotSize());
                  
                  if(CanPlaceNextSegmentOrder(1, marketOrders1, totalLots1, lotSizePending))
                     SendStopOrder(OP_BUYSTOP,lotSizePending,entryPrice,magicNumber,Green);
               }
            }
            //closing if only one order
            if(CountMarketOrders()== 1 && CountPendingOrders() == 1)
            {
               double firstDistance;
               //selecting orders
               for(int i=0; i<OrdersTotal();i++)
               {
                  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
                  {
                     if(OrderSymbol()==Symbol() && OrderMagicNumber()==magicNumber)
                     {
                        if(OrderType()==0)//buy
                        {
                           firstDistance= (Bid- OrderOpenPrice())/pip;
                           
                           if(firstDistance >= TpPip)
                           {
                              if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),SlippagePoints,Black))
                              {
                                 CloseOrders();
                                 DeleteAllPendingStopOrders();
                              }
                              else
                                 Print("Failed to close order ", OrderTicket(), ". Error: ", GetLastError());
                           }
                        }
                        else if(OrderType()==1)//sell
                        {
                           firstDistance= (OrderOpenPrice() - Ask)/pip;
                           
                           if(firstDistance >= TpPip)
                           {
                              if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),SlippagePoints,Black))
                              {
                                 CloseOrders();
                                 DeleteAllPendingStopOrders();
                              }
                              else
                                 Print("Failed to close order ", OrderTicket(), ". Error: ", GetLastError());
                           }
                        }
                     }
                  }
               }
            }
            //closing first order if it is in hedging
            while (CountMarketOrders() > 2)
            {
               int firstOrderTicket; //for closing when in profit
               double firstOrderProfit = FirstOrderProfit(firstOrderTicket);
               
               if(firstOrderTicket <= 0 || firstOrderProfit <= MinFirstOrderCloseProfit)
                  break;
               
               if(CloseOrderByTicket(firstOrderTicket) == false)
                  break;
               
            }
            //Alert("TotalProfit(): ", TotalProfit());
            //closing all orders
            if(CountMarketOrders() > 1 && (!Enable_Rescue || CountRescueOrders(Rescue_Magic1) == 0))
            {
               if(TotalProfit() > BasketTarget(TotalLots()))
               {
                  CloseOrders();
                  DeleteAllPendingStopOrders();
               }
            }
            }
         }
         //segment 2----------------------------------------------------------------------------------
         if(segment2 == true)
         {
            int marketOrders2 = CountMarketOrders2();
            double totalLots2 = TotalLots2();
            double totalProfit2 = TotalProfit2();
            
            int rescueCount2 = 0;
            double rescueProf2 = 0;
            if(Enable_Rescue)
              {
               rescueCount2 = CountRescueOrders(Rescue_Magic2);
               rescueProf2 = RescueProfit(Rescue_Magic2);
              }

            if(EmergencyLossTriggered(2, marketOrders2 + rescueCount2, totalProfit2 + rescueProf2))
            {
               CloseOrders2();
               DeleteAllPendingStopOrders2();
               if(Enable_Rescue) CloseRescueOrders(Rescue_Magic2);
            }
            else
            {
            
            // --- RESCUE LOGIC SEGMENT 2 ---
            if(Enable_Rescue)
              {
               if(rescueCount2 == 0 && marketOrders2 >= 2 && totalProfit2 <= -Rescue_Activation_Loss)
                 {
                  int rDir = MarketDirection(-1);
                  if(rDir == OP_BUY || rDir == OP_SELL)
                    {
                     SendMarketOrder(rDir, Rescue_LotSize, Rescue_Magic2, clrMagenta);
                     Print("Rescue Module: Order opened for Segment 2");
                    }
                 }
                 
               if(rescueCount2 > 0 && (totalProfit2 + rescueProf2) >= Rescue_TargetProfit)
                 {
                  if(RefreshIntervalPassed(lastRescueCloseAttempt2Ms, 1000, false))
                    {
                     Print("Rescue Module: Target reached for Segment 2. Closing all.");
                     CloseOrders2();
                     DeleteAllPendingStopOrders2();
                     CloseRescueOrders(Rescue_Magic2);
                    }
                 }
              }
            // ------------------------------
            
            //First trade
            if(Count2() == 0 && !NewsBlocksFreshSeries() && CanOpenFirstEntry() && CanPlaceNextSegmentOrder(2, marketOrders2, totalLots2, NormalizeLots(LotSize)))
            {            
               int firstSide2 = FirstOrderSide(FirstTrade2, Segment2Inverse);
               if(!FirstEntryConfirmed(firstSide2))
                  firstSide2 = -1;
               
               if(firstSide2 == OP_BUY)
               {
                  SendMarketOrder(OP_BUY, LotSize, magicNumber2, clrSkyBlue);
               }
               else if(firstSide2 == OP_SELL)
               {
                  SendMarketOrder(OP_SELL, LotSize, magicNumber2, clrGreenYellow);
               }
            }
            double lotSizePending;
         
            //sending pending orders
            if(CountPendingOrders2() == 0)
            {
               marketOrders2 = CountMarketOrders2();
               totalLots2 = TotalLots2();
               double lastOrderOpenPrice = LastOrderOpenPrice2();
               double entryPrice;
               
               if(LastOrderType2() == 0) // buy, send sellstop order
               {
                  entryPrice = lastOrderOpenPrice - GapDistance();
                  lotSizePending = NextChainLot(LastOrderLotSize2());
                  
                  if(CanPlaceNextSegmentOrder(2, marketOrders2, totalLots2, lotSizePending))
                     SendStopOrder(OP_SELLSTOP,lotSizePending,entryPrice,magicNumber2,clrGreenYellow);
               }
               else if(LastOrderType2() == 1) // Sell, send BuyStop order
               {
                  entryPrice = lastOrderOpenPrice + GapDistance();
                  lotSizePending = NextChainLot(LastOrderLotSize2());
                  
                  if(CanPlaceNextSegmentOrder(2, marketOrders2, totalLots2, lotSizePending))
                     SendStopOrder(OP_BUYSTOP,lotSizePending,entryPrice,magicNumber2,clrSkyBlue);
               }
            }
            //closing if only one order
            if(CountMarketOrders2()== 1 && CountPendingOrders2() == 1)
            {
               double firstDistance;
               //selecting orders
               for(int i=0; i<OrdersTotal();i++)
               {
                  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
                  {
                     if(OrderSymbol()==Symbol() && OrderMagicNumber()==magicNumber2)
                     {
                        if(OrderType()==0)//buy
                        {
                           firstDistance= (Bid- OrderOpenPrice())/pip;
                           
                           if(firstDistance >= TpPip)
                           {
                              if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),SlippagePoints,Black))
                              {
                                 CloseOrders2();
                                 DeleteAllPendingStopOrders2();
                              }
                              else
                                 Print("Failed to close order ", OrderTicket(), ". Error: ", GetLastError());
                           }
                        }
                        else if(OrderType()==1)//sell
                        {
                           firstDistance= (OrderOpenPrice() - Ask)/pip;
                           
                           if(firstDistance >= TpPip)
                           {
                              if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),SlippagePoints,Black))
                              {
                                 CloseOrders2();
                                 DeleteAllPendingStopOrders2();
                              }
                              else
                                 Print("Failed to close order ", OrderTicket(), ". Error: ", GetLastError());
                           }
                        }
                     }
                  }
               }
            }
            //closing first order if it is in hedging
            while (CountMarketOrders2() > 2)
            {
               int firstOrderTicket; //for closing when in profit
               double firstOrderProfit2 = FirstOrderProfit2(firstOrderTicket);
               
               if(firstOrderTicket <= 0 || firstOrderProfit2 <= MinFirstOrderCloseProfit)
                  break;
               
               if(CloseOrderByTicket2(firstOrderTicket) == false)
                  break;
               
            }
            //closing all orders
            if(CountMarketOrders2() > 1 && (!Enable_Rescue || CountRescueOrders(Rescue_Magic2) == 0))
            {
               if(TotalProfit2() > BasketTarget(TotalLots2()))
               {
                  CloseOrders2();
                  DeleteAllPendingStopOrders2();
               }
            }
            }
         }
         
         RefreshVisuals();
         
  }

int Count() // all orders including pending
  {
   int result=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      int MyOrderSelect=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(MyOrderSelect && OrderSymbol()==Symbol() && OrderMagicNumber()==magicNumber) result++;
     }
   return (result);
  }

int CountMarketOrders()
{
    int totalMarketOrders = 0;

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if ((OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderSymbol()==Symbol() && OrderMagicNumber()==magicNumber)
            {
                totalMarketOrders++;
            }
        }
        else
        {
            Print("Error selecting order ", i);
        }
    }

    return totalMarketOrders;
}

int CountPendingOrders()
{
   int total = 0;
   int count = OrdersTotal();
   
   for(int i = 0; i < count; i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
      {
         if(OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP)
         {
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magicNumber)
            {
               total++;
            }
            
         }
      }
   }
   
   return total;
}

int LastOrderType()
{
    // Variable to store the last open time
    datetime lastOpenTime = 0;
    int lastOrderType = -1; // Default value if no matching order is found

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        // Select order by position
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            // Check if the order is for the current symbol and matches the magic number
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
            {
                // Check if it's a BUY or SELL order (exclude pending orders)
                if (OrderType() == OP_BUY || OrderType() == OP_SELL)
                {
                    datetime curOpenTime = OrderOpenTime();

                    // If this order has a later open time, update the variables
                    if (curOpenTime > lastOpenTime)
                    {
                        lastOpenTime = curOpenTime;
                        lastOrderType = OrderType();
                    }
                }
            }
        }
    }

    return lastOrderType;
}

double LastOrderOpenPrice()
{
    // Variable to store the last open time
    datetime lastOpenTime = 0;
    int lastOrderType = -1; // Default value if no matching order is found
    double orderOpenPrice = 0;

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        // Select order by position
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            // Check if the order is for the current symbol and matches the magic number
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
            {
                // Check if it's a BUY or SELL order (exclude pending orders)
                if (OrderType() == OP_BUY || OrderType() == OP_SELL)
                {
                    datetime curOpenTime = OrderOpenTime();

                    // If this order has a later open time, update the variables
                    if (curOpenTime > lastOpenTime)
                    {
                        lastOpenTime = curOpenTime;
                        lastOrderType = OrderType();
                        orderOpenPrice = OrderOpenPrice();
                    }
                }
            }
        }
    }

    return orderOpenPrice;
}

double LastOrderLotSize()
{
    // Variable to store the last open time
    datetime lastOpenTime = 0;
    int lastOrderType = -1; // Default value if no matching order is found
    double orderOpenPrice = 0;
    double lotSize = 0;

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        // Select order by position
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            // Check if the order is for the current symbol and matches the magic number
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
            {
                // Check if it's a BUY or SELL order (exclude pending orders)
                if (OrderType() == OP_BUY || OrderType() == OP_SELL)
                {
                    datetime curOpenTime = OrderOpenTime();

                    // If this order has a later open time, update the variables
                    if (curOpenTime > lastOpenTime)
                    {
                        lastOpenTime = curOpenTime;
                        lastOrderType = OrderType();
                        orderOpenPrice = OrderOpenPrice();
                        lotSize = OrderLots();
                    }
                }
            }
        }
    }

    return lotSize;
}

void CloseOrders()
{
   // Update the exchange rates before closing the orders.
   RefreshRates();
   // Log in the terminal the total of orders, current and past.
   //Print(OrdersTotal());
      
   // Start a loop to scan all the orders.
   // The loop starts from the last order, proceeding backwards; Otherwise it would skip some orders.
   for (int i = (OrdersTotal() - 1); i >= 0; i--)
   {
      // If the order cannot be selected, throw and log an error.
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
          {
         Print("OrderSelect failed in CloseOrders at position ", i, ". Error: ", GetLastError());
         continue;
      } 

      // Create the required variables.
      // Result variable - to check if the operation is successful or not.
      bool res = false;
      
      // Allowed Slippage - the difference between current price and close price.
      int Slippage = SlippagePoints;
      
      // Bid and Ask prices for the instrument of the order.
      double BidPrice = MarketInfo(OrderSymbol(), MODE_BID);
      double AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);

      // Closing the order using the correct price depending on the type of order.
      if (OrderType() == OP_BUY && OrderMagicNumber()==magicNumber && OrderSymbol()==Symbol())
          {
         res = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
      }
      else if (OrderType() == OP_SELL && OrderMagicNumber()==magicNumber && OrderSymbol()==Symbol())
          {
         res = OrderClose(OrderTicket(), OrderLots(), AskPrice, Slippage);
      }
      
      // If there was an error, log it.
      if (res == false)
         Print("Failed to close order ", OrderTicket(), ". Error: ", GetLastError());
   }
}

bool DeleteAllPendingStopOrders()
{
   bool result = false;
   
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
      {
         if((OrderType() == OP_BUYSTOP ||OrderType() == OP_SELLSTOP ) && OrderSymbol()==Symbol() && OrderMagicNumber()==magicNumber)
         {
            if(OrderDelete(OrderTicket(), 10))
            {
               result = true;
            }
         }
      }
   }
   
   return result;
}

double TotalProfit()
{
   double totalprofit = 0.0;
         for(int i=0;i<OrdersTotal();i++)
         {
         if(OrderSelect(i,0,0))
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magicNumber)
            {
               totalprofit+=OrderProfit() + OrderSwap() + OrderCommission(); 
            }
         } 
      return totalprofit;
}

double TotalLots()
{
   double totallots = 0.0;
         for(int i=0;i<OrdersTotal();i++)
         {
         if(OrderSelect(i,0,0))
            if((OrderType() == OP_BUY || OrderType() == OP_SELL) &&
               OrderSymbol()==Symbol() && OrderMagicNumber()==magicNumber)
            {
               totallots+=OrderLots();
            }
         }
      return totallots;
}

double FirstOrderProfit(int &firstOrderTicket)
{
    datetime earliestOpenTime = 0;
    bool foundOrder = false;
    firstOrderTicket = -1;          // Default to -1 if no order is found
    double firstOrderProfit = 0.0;  // Default profit

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        // Select the order by position
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            // Check if the order matches the symbol and magic number
            if ((OrderType() == OP_BUY || OrderType() == OP_SELL) &&
                OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
            {
                datetime curOpenTime = OrderOpenTime();

                // Check for the earliest open time
                if (!foundOrder || curOpenTime < earliestOpenTime)
                {
                    earliestOpenTime = curOpenTime;
                    foundOrder = true;
                    firstOrderTicket = OrderTicket();     // Save the ticket
                    firstOrderProfit = OrderProfit() + OrderSwap() + OrderCommission();     // Save the profit
                }
            }
        }
    }

    return firstOrderProfit; // Return the profit of the first order
}

bool CloseOrderByTicket(int ticket)
{
    // Select the order using the ticket number
    if (OrderSelect(ticket, SELECT_BY_TICKET))
    {
        // Ensure the order is not already closed
        if (OrderType() == OP_BUY || OrderType() == OP_SELL)
        {
            double lots = OrderLots();       // Number of lots to close
            double price = (OrderType() == OP_BUY) ? Bid : Ask; // Use Bid for BUY, Ask for SELL
            int slippage = SlippagePoints;  // Maximum slippage in points

            // Attempt to close the order
            if (OrderClose(ticket, lots, price, slippage, clrRed))
            {
                Print("Order ", ticket, " closed successfully.");
                return true;
            }
            else
            {
                Print("Failed to close order ", ticket, ". Error: ", GetLastError());
            }
        }
        else
        {
            Print("Order ", ticket, " is not an active trade.");
        }
    }
    else
    {
        Print("OrderSelect failed for ticket ", ticket, ". Error: ", GetLastError());
    }

    return false;
}

//--------------------------for segment 2

int Count2() // all orders including pending
  {
   int result=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      int MyOrderSelect=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(MyOrderSelect && OrderSymbol()==Symbol() && OrderMagicNumber()==magicNumber2) result++;
     }
   return (result);
  }

int CountMarketOrders2()
{
    int totalMarketOrders = 0;

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if ((OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderSymbol()==Symbol() && OrderMagicNumber()==magicNumber2)
            {
                totalMarketOrders++;
            }
        }
        else
        {
            Print("Error selecting order ", i);
        }
    }

    return totalMarketOrders;
}

int CountPendingOrders2()
{
   int total = 0;
   int count = OrdersTotal();
   
   for(int i = 0; i < count; i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
      {
         if(OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP)
         {
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magicNumber2)
            {
               total++;
            }
            
         }
      }
   }
   
   return total;
}

int LastOrderType2()
{
    // Variable to store the last open time
    datetime lastOpenTime = 0;
    int lastOrderType = -1; // Default value if no matching order is found

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        // Select order by position
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            // Check if the order is for the current symbol and matches the magic number
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber2)
            {
                // Check if it's a BUY or SELL order (exclude pending orders)
                if (OrderType() == OP_BUY || OrderType() == OP_SELL)
                {
                    datetime curOpenTime = OrderOpenTime();

                    // If this order has a later open time, update the variables
                    if (curOpenTime > lastOpenTime)
                    {
                        lastOpenTime = curOpenTime;
                        lastOrderType = OrderType();
                    }
                }
            }
        }
    }

    return lastOrderType;
}

double LastOrderOpenPrice2()
{
    // Variable to store the last open time
    datetime lastOpenTime = 0;
    int lastOrderType = -1; // Default value if no matching order is found
    double orderOpenPrice = 0;

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        // Select order by position
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            // Check if the order is for the current symbol and matches the magic number
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber2)
            {
                // Check if it's a BUY or SELL order (exclude pending orders)
                if (OrderType() == OP_BUY || OrderType() == OP_SELL)
                {
                    datetime curOpenTime = OrderOpenTime();

                    // If this order has a later open time, update the variables
                    if (curOpenTime > lastOpenTime)
                    {
                        lastOpenTime = curOpenTime;
                        lastOrderType = OrderType();
                        orderOpenPrice = OrderOpenPrice();
                    }
                }
            }
        }
    }

    return orderOpenPrice;
}

double LastOrderLotSize2()
{
    // Variable to store the last open time
    datetime lastOpenTime = 0;
    int lastOrderType = -1; // Default value if no matching order is found
    double orderOpenPrice = 0;
    double lotSize = 0;

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        // Select order by position
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            // Check if the order is for the current symbol and matches the magic number
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber2)
            {
                // Check if it's a BUY or SELL order (exclude pending orders)
                if (OrderType() == OP_BUY || OrderType() == OP_SELL)
                {
                    datetime curOpenTime = OrderOpenTime();

                    // If this order has a later open time, update the variables
                    if (curOpenTime > lastOpenTime)
                    {
                        lastOpenTime = curOpenTime;
                        lastOrderType = OrderType();
                        orderOpenPrice = OrderOpenPrice();
                        lotSize = OrderLots();
                    }
                }
            }
        }
    }

    return lotSize;
}

void CloseOrders2()
{
   // Update the exchange rates before closing the orders.
   RefreshRates();
   // Log in the terminal the total of orders, current and past.
   //Print(OrdersTotal());
      
   // Start a loop to scan all the orders.
   // The loop starts from the last order, proceeding backwards; Otherwise it would skip some orders.
   for (int i = (OrdersTotal() - 1); i >= 0; i--)
   {
      // If the order cannot be selected, throw and log an error.
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
          {
         Print("OrderSelect failed in CloseOrders2 at position ", i, ". Error: ", GetLastError());
         continue;
      } 

      // Create the required variables.
      // Result variable - to check if the operation is successful or not.
      bool res = false;
      
      // Allowed Slippage - the difference between current price and close price.
      int Slippage = SlippagePoints;
      
      // Bid and Ask prices for the instrument of the order.
      double BidPrice = MarketInfo(OrderSymbol(), MODE_BID);
      double AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);

      // Closing the order using the correct price depending on the type of order.
      if (OrderType() == OP_BUY && OrderMagicNumber()==magicNumber2 && OrderSymbol()==Symbol())
          {
         res = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
      }
      else if (OrderType() == OP_SELL && OrderMagicNumber()==magicNumber2 && OrderSymbol()==Symbol())
          {
         res = OrderClose(OrderTicket(), OrderLots(), AskPrice, Slippage);
      }
      
      // If there was an error, log it.
      if (res == false)
         Print("Failed to close order ", OrderTicket(), ". Error: ", GetLastError());
   }
}

bool DeleteAllPendingStopOrders2()
{
   bool result = false;
   
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
      {
         if((OrderType() == OP_BUYSTOP ||OrderType() == OP_SELLSTOP ) && OrderSymbol()==Symbol() && OrderMagicNumber()==magicNumber2)
         {
            if(OrderDelete(OrderTicket(), 10))
            {
               result = true;
            }
         }
      }
   }
   
   return result;
}

double TotalProfit2()
{
   double totalprofit = 0.0;
         for(int i=0;i<OrdersTotal();i++)
         {
         if(OrderSelect(i,0,0))
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==magicNumber2)
            {
               totalprofit+=OrderProfit() + OrderSwap() + OrderCommission(); 
            }
         } 
      return totalprofit;
}

double TotalLots2()
{
   double totallots = 0.0;
         for(int i=0;i<OrdersTotal();i++)
         {
         if(OrderSelect(i,0,0))
            if((OrderType() == OP_BUY || OrderType() == OP_SELL) &&
               OrderSymbol()==Symbol() && OrderMagicNumber()==magicNumber2)
            {
               totallots+=OrderLots();
            }
         }
      return totallots;
}

double BasketTarget(double totalLots)
{
   if(!ScaleTargetByLots) return CloseAllOrdersAmountAt;

   double target = totalLots * TargetPerLot;
   double floor = (MinCloseTarget > 0) ? MinCloseTarget : CloseAllOrdersAmountAt;

   return MathMax(target, floor);
}

double FirstOrderProfit2(int &firstOrderTicket)
{
    datetime earliestOpenTime = 0;
    bool foundOrder = false;
    firstOrderTicket = -1;          // Default to -1 if no order is found
    double firstOrderProfit = 0.0;  // Default profit

    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        // Select the order by position
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            // Check if the order matches the symbol and magic number
            if ((OrderType() == OP_BUY || OrderType() == OP_SELL) &&
                OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber2)
            {
                datetime curOpenTime = OrderOpenTime();

                // Check for the earliest open time
                if (!foundOrder || curOpenTime < earliestOpenTime)
                {
                    earliestOpenTime = curOpenTime;
                    foundOrder = true;
                    firstOrderTicket = OrderTicket();     // Save the ticket
                    firstOrderProfit = OrderProfit() + OrderSwap() + OrderCommission();     // Save the profit
                }
            }
        }
    }

    return firstOrderProfit; // Return the profit of the first order
}

bool CloseOrderByTicket2(int ticket)
{
    // Select the order using the ticket number
    if (OrderSelect(ticket, SELECT_BY_TICKET))
    {
        // Ensure the order is not already closed
        if (OrderType() == OP_BUY || OrderType() == OP_SELL)
        {
            double lots = OrderLots();       // Number of lots to close
            double price = (OrderType() == OP_BUY) ? Bid : Ask; // Use Bid for BUY, Ask for SELL
            int slippage = SlippagePoints;  // Maximum slippage in points

            // Attempt to close the order
            if (OrderClose(ticket, lots, price, slippage, clrRed))
            {
                Print("Order ", ticket, " closed successfully.");
                return true;
            }
            else
            {
                Print("Failed to close order ", ticket, ". Error: ", GetLastError());
            }
        }
        else
        {
            Print("Order ", ticket, " is not an active trade.");
        }
    }
    else
    {
        Print("OrderSelect failed for ticket ", ticket, ". Error: ", GetLastError());
    }

    return false;
}
//+═══════════════════════════════════════════════════════════════════════════════════+
//|  END OF EA GoldGuard_Hedge                                                        |
//+═══════════════════════════════════════════════════════════════════════════════════+
 