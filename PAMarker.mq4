#property strict

#include "InfoItem/CrossHair.mqh"
#include "InfoItem/MouseInfo.mqh"
#include "Controller.mqh"
#include "CommonData.mqh"

void FinishedJobFunc();
void detectMouseDraging(const string &sparam);

CommonData gCommonData;
CrossHair  gCrossHair(&gCommonData);
MouseInfo  gMouseInfo(&gCommonData);
Controller gController(&gCommonData, &gMouseInfo);

bool DEBUG = false;

int timerInterval = 30;

void OnTimer()
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string alertLine = ObjectName(i);
        if (ObjectType(alertLine) == OBJ_HLINE) {
            bool notified = false;
            double alertPrice = ObjectGet(alertLine, OBJPROP_PRICE1);
            if (ObjectGetString(ChartID(), alertLine, OBJPROP_TEXT) == "Upper Ring")
            {
                if (alertPrice <= High[0])
                {
                    notified = true;
                    SendNotification("Chart Reached " + DoubleToString(alertPrice, 5) + " Upper Alert!!!");
                }
            }
            else
            {
                if (alertPrice >= Low[0])
                {
                    notified = true;
                    SendNotification("Chart Reached " + DoubleToString(alertPrice, 5) + " Lower Alert!!!");
                }
            }
            if (notified == true)
            {
                ObjectDelete(alertLine);
            }
        }
    }
}

int OnInit()
{
    ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, true);
    ChartSetInteger(ChartID(), CHART_EVENT_OBJECT_DELETE, true);
    
    gController.setFinishedJobCB(FinishedJobFunc);

    EventSetTimer(timerInterval);
    return (INIT_SUCCEEDED);
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
    return (rates_total);
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    switch (id)
    {
    case CHARTEVENT_KEYDOWN:
        gController.handleKeyEvent(lparam);
    break;

    case CHARTEVENT_MOUSE_MOVE:
        gCommonData.updateMousePosition(lparam, dparam, sparam);
        gCrossHair.onMouseMove();
        gMouseInfo.onMouseMove();
        detectMouseDraging(sparam);
    case CHARTEVENT_CLICK:
        gController.handleIdEventOnly(id);
        break;

    // event need sparam
    case CHARTEVENT_OBJECT_CLICK:
    case CHARTEVENT_OBJECT_DELETE:
        gCrossHair.onObjectDeleted(sparam);
        gMouseInfo.onObjectDeleted(sparam);
    case CHARTEVENT_OBJECT_DRAG:
    case CHARTEVENT_OBJECT_CHANGE:
        gController.handleSparamEvent(id, sparam);
    break;
    }
}

void FinishedJobFunc()
{
    gController.finishedJob();
}

string gTargetItem;
bool gIsPress;
int gPreviousOption;
void detectMouseDraging(const string &sparam)
{
    int option = StrToInteger(sparam);
    // Press event
    if ((option & 0x01) != 0 && (gPreviousOption & 0x01) == 0)
    {
        gIsPress = true;
        gTargetItem = findItemUnderMouse(gCommonData.mMouseX, gCommonData.mMouseY);
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
        gController.handleSparamEvent(CHARTEVENT_OBJECT_DRAG, gTargetItem);
    }

    gPreviousOption = option;
}