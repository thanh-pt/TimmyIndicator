#include "Base/BaseItem.mqh"
#include "DrawingTool/Line.mqh"
#include "DrawingTool/HLine.mqh"
#include "InfoItem/MouseInfo.mqh"

#define NOT_ACTIVE -1
#define CHECK_NOT_ACTIVE_RETURN if(mActive == NOT_ACTIVE){return;}
#define CHECK_ACTIVE_RETURN if(mActive != NOT_ACTIVE){return;}

#define LINE_IDX 0
#define HLINE_IDX 1

#define ITEM_LINE   "Line"
#define ITEM_HLINE  "HLine"

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
    mActive = NOT_ACTIVE;
    mListItem[LINE_IDX] = new Line(ITEM_LINE, commonData, mouseInfo);
    mListItem[HLINE_IDX] = new HLine(ITEM_HLINE, commonData, mouseInfo);
}


void Controller::setFinishedJobCB(FinishedJob cb)
{
    mFinishedJobCb = cb;
}

void Controller::finishedJob()
{
    pMouseInfo.setText("");
    mActive = NOT_ACTIVE;
}

int Controller::findItemIdByKey(const int key)
{
    if (key == 'L')
    {
        return LINE_IDX;
    }
    if (key == 'H')
    {
        return HLINE_IDX;
    }
    return NOT_ACTIVE;
}

int Controller::findItemIdByName(const string& name)
{
    if (name == ITEM_LINE)
    {
        return LINE_IDX;
    }
    if (name == ITEM_HLINE)
    {
        return HLINE_IDX;
    }
    return NOT_ACTIVE;
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
    if (activeTarget == NOT_ACTIVE)
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
    if (receiverItem == NOT_ACTIVE)
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