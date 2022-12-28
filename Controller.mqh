#include "Base/BaseItem.mqh"
#include "DrawingTool/Line.mqh"
#include "DrawingTool/HLine.mqh"

#define NOT_ACTIVE -1
#define NOT_ACTIVE_RETURN if(mActive == NOT_ACTIVE){return;}

#define LINE_IDX 0
#define HLINE_IDX 1

class Controller
{
private:
    BaseItem* mListItem[10];
    int mActive;
    FinishedJob mFinishedJobCb;

private:
    void activeItemByKey(const int key);
    void activeItemByName(const string& name);

public:
    Controller(CommonData* commonData);

public:
    void handleKeyEvent(const long &key);
    void handleIdEventOnly(const int id);
    void handleSparamEvent(const int id, const string& sparam);
    void setFinishedJobCB(FinishedJob cb);
    void finishedJob();
};

void Controller::Controller(CommonData* commonData)
{
    mActive = NOT_ACTIVE;
    mListItem[LINE_IDX] = new Line("Line", commonData);
    // mListItem[HLINE_IDX] = new HLine();
}


void Controller::setFinishedJobCB(FinishedJob cb)
{
    mFinishedJobCb = cb;
}

void Controller::finishedJob()
{
    mActive = NOT_ACTIVE;
}

void Controller::activeItemByKey(const int key)
{}

void Controller::activeItemByName(const string& name)
{}

void Controller::handleKeyEvent(const long &key)
{
    PrintFormat("handleKeyEvent %c", key);
    switch ((int)key)
    {
    case 'L':
        mActive = LINE_IDX;
        break;
    // case 'A':
    //     mActive = HLINE_IDX;
    //     break;
    case 27:
        mActive = NOT_ACTIVE; 
        break;
    }
    NOT_ACTIVE_RETURN
    
    mListItem[mActive].startActivate(mFinishedJobCb);
}

void Controller::handleIdEventOnly(const int id)
{
    NOT_ACTIVE_RETURN

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
    NOT_ACTIVE_RETURN

    string sparamItems[];
    int k=StringSplit(sparam,'_',sparamItems);
    if (k != 3)
    {
        return;
    }
    activeItemByName(sparamItems[0]);
    string objId = sparamItems[0] + "_" + sparamItems[1];
    mListItem[mActive].activateObject(objId);
    switch (id)
    {
    case CHARTEVENT_OBJECT_DELETE:
        mListItem[mActive].onObjectDeleted(objId);
        break;
    case CHARTEVENT_OBJECT_DRAG:
        mListItem[mActive].onObjectDrag(objId);
        break;
    case CHARTEVENT_OBJECT_CHANGE:
        mListItem[mActive].onObjectChange(objId);
        break;
    case CHARTEVENT_OBJECT_CLICK:
        mListItem[mActive].onObjectClick(objId);
        break;
    }
    mListItem[mActive].refreshData();
}