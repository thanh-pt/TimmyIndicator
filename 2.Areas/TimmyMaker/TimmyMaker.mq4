//+------------------------------------------------------------------+
//|                                                   TimmyMaker.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window
// #define Lver

#include "Home/Controller.mqh"
#include "Home/CommonData.mqh"
#include "InfoItem/CrossHair.mqh"
#include "InfoItem/ContextMenu.mqh"
#include "InfoItem/MouseInfo.mqh"

void FinishedJobFunc();
void detectMouseDraging(const string &sparam);

CommonData  gCommonData;
MouseInfo   gMouseInfo(&gCommonData);
Controller  gController(&gCommonData, &gMouseInfo);
CrossHair   gCrossHair(&gCommonData);
ContextMenu gContextMenu();

int OnInit()
{
//---
    ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
    ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, true);

    ChartSetInteger(0, CHART_AUTOSCROLL, false);
    ChartSetInteger(0, CHART_SHOW_GRID, false);
    ChartSetInteger(0, CHART_SHIFT, true);
    
    // Init global variable
    gController.setFinishedJobCB(FinishedJobFunc);
//---
    return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
    gContextMenu.clearContextMenu();
    gContextMenu.clearStaticCtxMenu();
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
//---

//--- return value of prev_calculated for next call
    gController.handleOntick();
    return(rates_total);
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    switch (id)
    {
    case CHARTEVENT_KEYDOWN:
        gController.handleEvent(lparam);
    break;

    case CHARTEVENT_MOUSE_MOVE:
        gCommonData.updateMousePosition(lparam, dparam, sparam);
        gCrossHair.onMouseMove();
        gMouseInfo.onMouseMove();
        detectMouseDraging(sparam);
    case CHARTEVENT_CLICK:
        gController.handleEvent(id);
        break;

    // event need sparam
    case CHARTEVENT_OBJECT_CLICK:
        gContextMenu.onItemClick(sparam);
    case CHARTEVENT_OBJECT_DELETE:
        // Disable this 2 feature to reduce work load
        // gCrossHair.onObjectDeleted(sparam);
        // gMouseInfo.onObjectDeleted(sparam);
    case CHARTEVENT_OBJECT_DRAG:
    case CHARTEVENT_OBJECT_CHANGE:
        gController.handleEvent(id, sparam);
    break;
    case CHARTEVENT_CHART_CHANGE:
        gContextMenu.clearContextMenu();
    break;
    default:
        // PrintFormat("%d", id);
    break;
    }
}
//+------------------------------------------------------------------+
void FinishedJobFunc()
{
    gController.finishedJob();
}

// Tạo biến globle cho đỡ tốn công tạo xoá biến
string gTargetItem;
bool gIsPress;
int gPreviousOption;
void detectMouseDraging(const string &sparam)
{
    if (gContextMenu.mIsOpen == true) return;
    int option = StrToInteger(sparam);
    // Press event
    if ((option & 0x01) != 0 && (gPreviousOption & 0x01) == 0)
    {
        gIsPress = true;
        gTargetItem = getItemUnderMouse(gCommonData.mMouseX, gCommonData.mMouseY);
    }
    else
        // Release event
        if ((option & 0x01) == 0 && (gPreviousOption & 0x01) != 0)
        {
            gIsPress = false;
            gTargetItem = "";
        }
    // Press and draging
    if (gIsPress && (option & 0x01) != 0)
    {
        gController.handleEvent(CHARTEVENT_OBJECT_DRAG, gTargetItem);
    }

    gPreviousOption = option;
}