#property strict

#include "Controller.mqh"
#include "CommonData.mqh"

void FinishedJobFunc();

CommonData gCommonData;
Controller gController(&gCommonData);

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
    case CHARTEVENT_CLICK:
        gController.handleIdEventOnly(id);
        break;

    // event need sparam
    case CHARTEVENT_OBJECT_CLICK:
    case CHARTEVENT_OBJECT_DELETE:
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
