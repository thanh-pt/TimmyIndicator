#include "../CommonData.mqh"
#include "../InfoItem/MouseInfo.mqh"

typedef void(*FinishedJob)();

#define MAX_TYPE 10

#define UPDATE_TYPE if((++mIndexType) >= mTypeNum){mIndexType = 0;}

class BaseItem
{
protected:
    string      mItemName;
    CommonData* pCommonData;
    MouseInfo*  pMouseInfo;
    FinishedJob mFinishedJobCb;
protected:
    bool        mFirstPoint;
    int         mIndexType;
    int         mTypeNum;
    string      mNameType[MAX_TYPE];

protected:
    string createMouseInfo();

// Internal Event:
protected:
    virtual void prepareActive(){};
    virtual void createItem()=0;
    virtual void updateDefaultProperty(){};
    virtual void updateTypeProperty(){};
    virtual void activateItem(const string& itemId)=0;
    virtual void updateItemAfterChangeType(){};
    virtual void refreshData()=0;
    virtual void finishedJobDone(){};

// Chart Event:
public:
    virtual void onMouseMove(){}
    virtual void onMouseClick(){}
    virtual void onItemDrag(const string &itemId, const string &objId){};
    virtual void onItemClick(const string &itemId, const string &objId){};
    virtual void onItemChange(const string &itemId, const string &objId){};
    virtual void onItemDeleted(const string &itemId, const string &objId){};

public:
    void startActivate(FinishedJob cb);
    void finishedDeactivate();
    void changeActiveType();
    void touchItem(const string& itemId);
};

void BaseItem::startActivate(FinishedJob cb)
{
    ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
    if (mTypeNum == 0)
    {
        pMouseInfo.setText(mItemName);
    }
    else
    {
        pMouseInfo.setText(createMouseInfo());
    }
    mFirstPoint = false;
    mFinishedJobCb = cb;
    prepareActive();
    string itemId = mItemName + "_" +IntegerToString(ChartPeriod()) + "#" + IntegerToString(TimeLocal());
    activateItem(itemId);
    // PrintFormat("NewItem: %s", itemId);
}

void BaseItem::finishedDeactivate()
{
    ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
    finishedJobDone();
}

void BaseItem::touchItem(const string& itemId)
{
    activateItem(itemId);
}

void BaseItem::changeActiveType()
{
    if (mTypeNum <= 0)
    {
        return;
    }

    /* disable hold shift feature
    if (pCommonData.mShiftHold)
    {
        if((--mIndexType) < 0)
        {
            mIndexType = mTypeNum-1;
        }
    }
    else
    */
    {
        if((++mIndexType) >= mTypeNum)
        {
            mIndexType = 0;
        }
    }
    
    pMouseInfo.setText(createMouseInfo());
    updateItemAfterChangeType();
}

string BaseItem::createMouseInfo()
{
    string mouseInfo = "";
    for (int i = 0; i < mTypeNum; i++)
    {
        if (mouseInfo != "")
        {
            mouseInfo += " - ";
        }
        if (i == mIndexType)
        {
            mouseInfo += "(" + mNameType[i] + ")";
            continue;
        }
        mouseInfo += mNameType[i];
    }
    return mouseInfo;
}
