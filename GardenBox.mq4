#property strict

#include "Controller.mqh"
#include "CommonData.mqh"
#include "InfoItem/CrossHair.mqh"
#include "InfoItem/MouseInfo.mqh"

void FinishedJobFunc();

CommonData gCommonData;
CrossHair  gCrossHair(&gCommonData);
MouseInfo  gMouseInfo(&gCommonData);
Controller gController(&gCommonData, &gMouseInfo);

int OnInit()
{
    gController.setFinishedJobCB(FinishedJobFunc);
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
    {
        int option = StrToInteger(sparam);
        gCommonData.updateMousePosition(lparam, dparam, option);
        gCrossHair.onMouseMove();
        gMouseInfo.onMouseMove();
    }
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
