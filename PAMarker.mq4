#property strict

input bool AlertActive = false;
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

string gListAlert= "";
string gAlertArr[];
int    gAlertTotal  = 0;
bool   gAlertReach  = false;
double gAlertPrice  = 0;
string gAlertRemain = "";

void initAlarm()
{
    string alertLine = "";
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        alertLine = ObjectName(i);
        if (StringFind(alertLine, "cAlert") == -1) continue;
        // Add Alert to the list
        if (gListAlert != "") gListAlert += ",";
        gListAlert += alertLine;
    }
}

void checkAlert()
{
    gAlertTotal  = StringSplit(gListAlert,',',gAlertArr);
    gAlertRemain = "";
    for (int i = 0; i < gAlertTotal; i++)
    {
        // Check valid Alert
        if (ObjectFind(gAlertArr[i]) < 0) continue;
        if (StringFind(gAlertArr[i], "cAlert") == -1) continue;

        // Get Alert information
        gAlertReach = false;
        gAlertPrice = ObjectGet(gAlertArr[i], OBJPROP_PRICE1);

        // Check Alert Price
        if (ObjectGetString(ChartID(), gAlertArr[i], OBJPROP_TOOLTIP) == "H")
        {
            gAlertReach = (gAlertPrice <= Bid);
        }
        else
        {
            gAlertReach = (gAlertPrice >= Bid);
            if (gAlertReach)
                PrintFormat("gAlertArr OBJPROP_TOOLTIP Low. Text = [" + ObjectGetString(ChartID(), gAlertArr[i], OBJPROP_TOOLTIP) + "]");
        }

        // Send notification or save remain Alert
        if (gAlertReach == true)
        {
            SendNotification(
                "["+ DoubleToString(gAlertPrice, 5) + "] "
                   + ObjectGetString(ChartID(), gAlertArr[i], OBJPROP_TEXT));
            ObjectDelete(gAlertArr[i]);
        }
        else
        {
            gAlertRemain += gAlertArr[i] + ",";
        }
    }
    gListAlert = gAlertRemain;
}

int OnInit()
{
    ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, true);
    ChartSetInteger(ChartID(), CHART_EVENT_OBJECT_DELETE, true);
    
    gController.setFinishedJobCB(FinishedJobFunc);

    initAlarm();
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
    if (AlertActive) checkAlert();
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