//+------------------------------------------------------------------+
//|                                                 ForexSession.mq4 |
//|                                 Thanh Pham - Price Action Trader |
//|            https://www.youtube.com/@thanhpham-PriceActionTrader/ |
//+------------------------------------------------------------------+
#property copyright "Thanh Pham - Price Action Trader"
#property link      "https://www.youtube.com/@thanhpham-PriceActionTrader/"
#property version   "1.00"
#property strict

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 4
//--- input parameters
#define FX_SESSION_TAG "%FX_SESSION"

enum E_SS_TYPE
{
  YesterdayToToday = 0,
  OnlyToday        = 1,
  TodayToTomorrow  = 2,
};

input color Sydney_Color = clrDarkTurquoise;
input color Tokyo__Color = clrPeru;
input color London_Color = clrLightGreen;
input color NewYorkColor = clrRed;

input color HourLineColor = C'35,47,61';

input E_SS_TYPE Sydney_Type = YesterdayToToday;
input int       Sydney_Opened = 23;
input int       Sydney_Closed = 8;
input E_SS_TYPE Tokyo__Type = OnlyToday;
input int       Tokyo__Opened = 1;
input int       Tokyo__Closed = 10;
input E_SS_TYPE London_Type = OnlyToday;
input int       London_Opened = 10;
input int       London_Closed = 19;
input E_SS_TYPE NewYorkType = OnlyToday;
input int       NewYorkOpened = 15;
input int       NewYorkClosed = 24;

const string Sydney_Tag = FX_SESSION_TAG + "_Sydney_";
const string Tokyo__Tag = FX_SESSION_TAG + "_Tokyo__";
const string London_Tag = FX_SESSION_TAG + "_London_";
const string NewYorkTag = FX_SESSION_TAG + "_NewYork";

// Session name
string objSydney_ = "";
string objTokyo__ = "";
string objLondon_ = "";
string objNewYork = "";
// temp
int YY = 0;
int MN = 0;
int DD = 0;
string objHourLine;
string objCurrentTime = FX_SESSION_TAG + "_objCurrentTime";
// global value
string gStrBeginOfToDay = "";
datetime gToday;
int gWindowID = 0;


void createSessionItem(string sessionName, int pos1, int pos2, color c, int opendHour, int closeHour, E_SS_TYPE sessionType)
{
  if (sessionName == "")
  {
    return;
  }
  ObjectCreate(sessionName, OBJ_RECTANGLE, gWindowID, 0, 0);
  ObjectSet(sessionName, OBJPROP_BACK, 1);
  ObjectSet(sessionName, OBJPROP_SELECTABLE, 0);
  ObjectSet(sessionName, OBJPROP_COLOR, c);
  ObjectSet(sessionName, OBJPROP_PRICE1, pos1);
  ObjectSet(sessionName, OBJPROP_PRICE2, pos2);
  ObjectSet(sessionName, OBJPROP_TIME1, gToday + opendHour*3600 - (sessionType==YesterdayToToday?86400:0));
  ObjectSet(sessionName, OBJPROP_TIME2, gToday + closeHour*3600 - (sessionType==TodayToTomorrow ?86400:0));
}

void createHourLine(string lineName, int hour)
{
  ObjectCreate(lineName, OBJ_TREND, gWindowID, 0, 0);
  ObjectSetString(ChartID(), lineName ,OBJPROP_TOOLTIP,"\n");
  ObjectSet(lineName, OBJPROP_BACK      , 1);
  ObjectSet(lineName, OBJPROP_RAY       , 0);
  ObjectSet(lineName, OBJPROP_SELECTABLE, 0);
  ObjectSet(lineName, OBJPROP_WIDTH     , 0);
  ObjectSet(lineName, OBJPROP_STYLE     , 2);
  ObjectSet(lineName, OBJPROP_PRICE1    , 0);
  ObjectSet(lineName, OBJPROP_PRICE2    , 4);
  ObjectSet(lineName, OBJPROP_COLOR     , HourLineColor);
  ObjectSet(lineName, OBJPROP_TIME1     , gToday+hour*3600);
  ObjectSet(lineName, OBJPROP_TIME2     , gToday+hour*3600);
}

void updateCurrentLine()
{
  if (ObjectFind(objCurrentTime) < 0)
  {
    ObjectCreate(objCurrentTime, OBJ_TREND, gWindowID, 0, 0);
    ObjectSet(objCurrentTime, OBJPROP_RAY, 0);
    ObjectSet(objCurrentTime, OBJPROP_SELECTABLE, 0);
    ObjectSet(objCurrentTime, OBJPROP_WIDTH, 0);
    ObjectSet(objCurrentTime, OBJPROP_STYLE, 0);
    ObjectSet(objCurrentTime, OBJPROP_COLOR, clrWhite);
    ObjectSet(objCurrentTime, OBJPROP_PRICE1, 0);
    ObjectSet(objCurrentTime, OBJPROP_PRICE2, 4);
    ObjectSetString(ChartID(), objCurrentTime ,OBJPROP_TOOLTIP,"\n");
  }
  ObjectSet(objCurrentTime, OBJPROP_TIME1, Time[0]);
  ObjectSet(objCurrentTime, OBJPROP_TIME2, Time[0]);
}

void reload()
{
  if (ObjectFind(objSydney_) < 0) createSessionItem(objSydney_, 3, 4, Sydney_Color, Sydney_Opened, Sydney_Closed, Sydney_Type);
  if (ObjectFind(objTokyo__) < 0) createSessionItem(objTokyo__, 2, 3, Tokyo__Color, Tokyo__Opened, Tokyo__Closed, Tokyo__Type);
  if (ObjectFind(objLondon_) < 0) createSessionItem(objLondon_, 1, 2, London_Color, London_Opened, London_Closed, London_Type);
  if (ObjectFind(objNewYork) < 0) createSessionItem(objNewYork, 0, 1, NewYorkColor, NewYorkOpened, NewYorkClosed, NewYorkType);
  for (int i = 0; i < 24; i++)
  {
    objHourLine = FX_SESSION_TAG+"_HourLine"+gStrBeginOfToDay+"#"+IntegerToString(i);
    if (ObjectFind(objHourLine) < 0) createHourLine(objHourLine, i);
  }
}

int OnInit()
{
   gWindowID = WindowFind("ForexSession");
   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
  updateCurrentLine();
  if (DD == TimeDay(Time[0]))
  {
    return 0;
  }
  // Detemine today
  YY=TimeYear(  Time[0]);
  MN=TimeMonth( Time[0]);
  DD=TimeDay(   Time[0]);
  gStrBeginOfToDay = IntegerToString(YY)+"."+IntegerToString(MN)+"."+IntegerToString(DD)+" 00:00";
  gToday = StrToTime(gStrBeginOfToDay);
  // Update session object name
  objSydney_ = Sydney_Tag + gStrBeginOfToDay;
  objTokyo__ = Tokyo__Tag + gStrBeginOfToDay;
  objLondon_ = London_Tag + gStrBeginOfToDay;
  objNewYork = NewYorkTag + gStrBeginOfToDay;
  reload();
  return(rates_total);
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
  if (id == CHARTEVENT_OBJECT_DELETE)
  {
    if (StringFind(sparam, FX_SESSION_TAG) != -1) reload();
  }
}
