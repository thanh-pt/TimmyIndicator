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

// Internal Event:
protected:
    virtual void prepareActive(){};
    virtual void createItem()=0;
    virtual void updateDefaultProperty(){};
    virtual void updateTypeProperty(){};
    virtual void activateItem(const string& itemId)=0;
    virtual void updateItemAfterChangeType(){};
    virtual void refreshData()=0;

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
    void changeActiveType();
    void touchItem(const string& itemId);
};

void BaseItem::startActivate(FinishedJob cb)
{
    mFinishedJobCb = cb;
    prepareActive();
    string itemId = mItemName + "_" +IntegerToString(ChartPeriod()) + "#" + IntegerToString(TimeLocal());
    activateItem(itemId);
    if (DEBUG) PrintFormat("NewItem: %s", itemId);
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
    
    if((++mIndexType) >= mTypeNum)
    {
        mIndexType = 0;
    }
    
    pMouseInfo.setText(mNameType[mIndexType]);
    updateItemAfterChangeType();
}
