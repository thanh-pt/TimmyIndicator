#include "Base/BaseItem.mqh"
#include "DrawingTool/Trend.mqh"
#include "DrawingTool/HTrend.mqh"
#include "InfoItem/MouseInfo.mqh"

#define CHECK_NOT_ACTIVE_RETURN if(mActive == IDX_NONE){return;}
#define CHECK_ACTIVE_RETURN if(mActive != IDX_NONE){return;}

#define IDX_NONE    -1
#define IDX_TREND   0
#define IDX_HTREND  1

#define ITEM_TREND   "Trend"
#define ITEM_HTREND  "HTrend"

class Controller
{
private:
    BaseItem* mListItem[10];
    int mActive;
    FinishedJob mFinishedJobCb;
    MouseInfo* pMouseInfo;

private:
    int findItemIdByKey(const int key);
    int findItemIdByName(const string& name);

public:
    Controller(CommonData* commonData, MouseInfo* mouseInfo);

public:
    void handleKeyEvent(const long &key);
    void handleIdEventOnly(const int id);
    void handleSparamEvent(const int id, const string& sparam);
    void setFinishedJobCB(FinishedJob cb);
    void finishedJob();
};

void Controller::Controller(CommonData* commonData, MouseInfo* mouseInfo)
{
    pMouseInfo = mouseInfo;
    mActive = IDX_NONE;
    mListItem[IDX_TREND] = new Trend(ITEM_TREND, commonData, mouseInfo);
    mListItem[IDX_HTREND] = new HTrend(ITEM_HTREND, commonData, mouseInfo);
}


void Controller::setFinishedJobCB(FinishedJob cb)
{
    mFinishedJobCb = cb;
}

void Controller::finishedJob()
{
    pMouseInfo.setText("");
    mActive = IDX_NONE;
}

int Controller::findItemIdByKey(const int key)
{
    if (key == 'T')
    {
        return IDX_TREND;
    }
    if (key == 'H')
    {
        return IDX_HTREND;
    }
    return IDX_NONE;
}

int Controller::findItemIdByName(const string& name)
{
    if (name == ITEM_TREND)
    {
        return IDX_TREND;
    }
    if (name == ITEM_HTREND)
    {
        return IDX_HTREND;
    }
    return IDX_NONE;
}

void Controller::handleKeyEvent(const long &key)
{
    if (DEBUG) PrintFormat("handleKeyEvent %c %d", key, key);

    // S1: handle functional Key
    switch ((int)key)
    {
    case 27:
        finishedJob();
        unSelectAll();
        break;
    }

    // S2: Active drawing tool
    int activeTarget = findItemIdByKey((int)key);
    if (activeTarget == IDX_NONE)
    {
        return;
    }
    if (activeTarget == mActive)
    {
        // TODO: change charactise
        mListItem[mActive].changeActiveType();
        return;
    }
    CHECK_ACTIVE_RETURN
    mActive = activeTarget;
    
    mListItem[mActive].startActivate(mFinishedJobCb);
}

void Controller::handleIdEventOnly(const int id)
{
    CHECK_NOT_ACTIVE_RETURN

    switch (id)
    {
    case CHARTEVENT_CLICK:
        mListItem[mActive].onMouseClick();
        break;

    case CHARTEVENT_MOUSE_MOVE:
        mListItem[mActive].onMouseMove();
        break;
    }
}

void Controller::handleSparamEvent(const int id, const string& sparam)
{
    CHECK_ACTIVE_RETURN

    string sparamItems[];
    int k=StringSplit(sparam,'_',sparamItems);
    if (k != 3)
    {
        return;
    }
    int receiverItem = findItemIdByName(sparamItems[0]);
    if (receiverItem == IDX_NONE)
    {
        return;
    }

    string itemId = sparamItems[0] + "_" + sparamItems[1];
    mListItem[receiverItem].touchItem(itemId);
    switch (id)
    {
    case CHARTEVENT_OBJECT_DELETE:
        mListItem[receiverItem].onItemDeleted(itemId, sparam);
        break;
    case CHARTEVENT_OBJECT_DRAG:
        mListItem[receiverItem].onItemDrag(itemId, sparam);
        break;
    case CHARTEVENT_OBJECT_CHANGE:
        mListItem[receiverItem].onItemChange(itemId, sparam);
        break;
    case CHARTEVENT_OBJECT_CLICK:
        mListItem[receiverItem].onItemClick(itemId, sparam);
        break;
    }
}