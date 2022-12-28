#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string          Line_ = "Line Config";
input color           Line_Color = clrWhite;
input int             Line_Width = 1;
input ENUM_LINE_STYLE Line_Style = 0;

class Line : public BaseItem
{
private:
    string cMainLine;
    string cText    ;

private:
    datetime time1;
    datetime time2;
    datetime time3;
    double price1;
    double price2;
    double price3;

public:
    Line(const string name, CommonData* commonData, MouseInfo* mouseInfo);
    virtual void onMouseMove();
    virtual void onMouseClick();
    virtual void activateItem(const string& itemId);
    virtual void refreshData();
    virtual void createItem();
    virtual void prepareActive();
public:
    virtual void onItemDrag(const string &itemId, const string &objId);
    virtual void onItemChange(const string &itemId, const string &objId);
};

Line::Line(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;
}

void Line::onMouseClick()
{
    if (mFirstPoint == false)
    {
        createItem();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}

void Line::onMouseMove()
{
    if (mFirstPoint == false)
    {
        return;
    }
    if (pCommonData.mShiftHold)
    {
        price2 = price1;
    }
    else
    {
        price2 = pCommonData.mMousePrice;
    }
    time2  = pCommonData.mMouseTime;
    refreshData();
}

void Line::prepareActive()
{
    mFirstPoint = false;
    pMouseInfo.setText(mItemName);
}

void Line::activateItem(const string& itemId)
{
    cMainLine = itemId + "_mainLine";
    cText     = itemId + "_text";
}

void Line::refreshData()
{
    getCenterPos(time1, time2, price1, price2, time3, price3);
    ObjectSet(cMainLine, OBJPROP_TIME1,  time1);
    ObjectSet(cMainLine, OBJPROP_PRICE1, price1);

    ObjectSet(cMainLine, OBJPROP_TIME2,  time2);
    ObjectSet(cMainLine, OBJPROP_PRICE2, price2);

    ObjectSet(cText, OBJPROP_TIME1,  time3);
    ObjectSet(cText, OBJPROP_PRICE1, price3);
}

void Line::createItem()
{
    ObjectCreate(cMainLine, OBJ_TREND, 0, 0, 0);
    ObjectCreate(cText    , OBJ_TEXT , 0, 0, 0);

    ObjectSet(cMainLine, OBJPROP_RAY, false);
    ObjectSet(cMainLine, OBJPROP_COLOR, Line_Color);
    ObjectSet(cMainLine, OBJPROP_WIDTH, Line_Width);
    ObjectSet(cMainLine, OBJPROP_STYLE, Line_Style);

    ObjectSet(cText,     OBJPROP_COLOR, Line_Color);
    ObjectSetText(cText, "");
    ObjectSetString(ChartID(), cMainLine ,OBJPROP_TOOLTIP,"\n");
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}


void Line::onItemDrag(const string &itemId, const string &objId)
{
    time1 = (datetime)ObjectGet(cMainLine, OBJPROP_TIME1);
    time2 = (datetime)ObjectGet(cMainLine, OBJPROP_TIME2);
    price1 = ObjectGet(cMainLine, OBJPROP_PRICE1);
    price2 = ObjectGet(cMainLine, OBJPROP_PRICE2);

    refreshData();
}

void Line::onItemChange(const string &itemId, const string &objId)
{
    if (objId == cMainLine)
    {
        ObjectSet(cText, OBJPROP_COLOR, ObjectGet(cMainLine, OBJPROP_COLOR));
        
        string lineDescription = ObjectDescription(cMainLine);
        if (lineDescription != "")
        {
            ObjectSetText(cText    , lineDescription);
            ObjectSetText(cMainLine, "");
        }
    }
}