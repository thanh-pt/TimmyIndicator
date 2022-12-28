#include "../Base/BaseItem.mqh"
#include "../Controller.mqh"
#include "../CommonData.mqh"

class Line : public BaseItem
{
    bool mFirstPoint;
    public:
    Line(const string name, CommonData* commonData);
    virtual void onMouseMove();
    virtual void onMouseClick();
    virtual void activateObject(const string& objId);
    virtual void refreshData();
    virtual void createObject();
    virtual void actionBeforeActivate();
};

Line::Line(const string name, CommonData* commonData)
{
    mItemName = name;
    pCommonData = commonData;
}

void Line::onMouseClick()
{
    PrintFormat("Line::onMouseClick");
    if (mFirstPoint == false)
    {
        createObject();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}

void Line::onMouseMove()
{
    // PrintFormat("Line::onMouseMove");
}

void Line::activateObject(const string& objId)
{
    PrintFormat("Line::activateObject");
}

void Line::refreshData()
{
    PrintFormat("Line::refreshData");
}

void Line::createObject()
{
    PrintFormat("Line::createObject");
}

void Line::actionBeforeActivate()
{
    mFirstPoint = false;
}