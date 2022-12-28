#include "../CommonData.mqh"
#include "../InfoItem/MouseInfo.mqh"

typedef void(*FinishedJob)();

#define MAX_TYPE 10

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

public:
    virtual void onMouseMove(){}
    virtual void onMouseClick(){}
    virtual void onItemDrag(const string &itemId, const string &objId){};
    virtual void onItemClick(const string &itemId, const string &objId){};
    virtual void onItemChange(const string &itemId, const string &objId){PrintFormat("onItemChange");};
    virtual void onItemDeleted(const string &itemId, const string &objId){};

protected:
    virtual void prepareActive(){};
    virtual void createItem()=0;

public:
    void startActivate(FinishedJob cb);
    virtual void activateItem(const string& itemId)=0;
    virtual void refreshData()=0;
    void changeActiveType(){};
};

void BaseItem::startActivate(FinishedJob cb)
{
    mFinishedJobCb = cb;
    prepareActive();
    string itemId = mItemName + "_" +IntegerToString(ChartPeriod()) + "#" + IntegerToString(TimeLocal());
    activateItem(itemId);
    PrintFormat("NewItem: %s", itemId);
    
}
