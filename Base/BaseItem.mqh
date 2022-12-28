#include "../CommonData.mqh"

typedef void(*FinishedJob)();

class BaseItem
{
protected:
    string mItemName;
    CommonData *pCommonData;
    FinishedJob mFinishedJobCb;
public:
    virtual void onMouseMove(){}
    virtual void onMouseClick(){}
    virtual void onObjectDeleted(const string &objId){};
    virtual void onObjectDrag(const string &objId){};
    virtual void onObjectClick(const string &objId){};
    virtual void onObjectChange(const string &objId){};

protected:
    virtual void actionBeforeActivate(){};
    virtual void createObject()=0;

public:
    void startActivate(FinishedJob cb);
    virtual void activateObject(const string& objId)=0;
    virtual void refreshData()=0;
};

void BaseItem::startActivate(FinishedJob cb)
{
    mFinishedJobCb = cb;
    string objId = mItemName + "_" +IntegerToString(ChartPeriod()) + "#" + IntegerToString(TimeLocal());
    activateObject(objId);
    PrintFormat("NewItem: %s", objId);
    
    actionBeforeActivate();
}
