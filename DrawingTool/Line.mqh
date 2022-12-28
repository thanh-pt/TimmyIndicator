#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string          Line_ = "Line Config";
input color           Line1_Color = clrWhite;
input int             Line1_Width = 1;
input ENUM_LINE_STYLE Line1_Style = 0;
input color           Line2_Color = clrRed;
input int             Line2_Width = 1;
input ENUM_LINE_STYLE Line2_Style = 2;

class Line : public BaseItem
{
private:
    color mColorType[MAX_TYPE];
    int   mWidthType[MAX_TYPE];
    int   mStyleType[MAX_TYPE];

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

    virtual void activateItem(const string& itemId);
    virtual void refreshData();
    virtual void createItem();
    virtual void updateDefaultProperty();
    virtual void updateTypeProperty();
    virtual void prepareActive();
    virtual void updateItemAfterChangeType();
public:
    virtual void onMouseMove();
    virtual void onMouseClick();
    virtual void onItemDrag(const string &itemId, const string &objId);
    virtual void onItemChange(const string &itemId, const string &objId);
};

Line::Line(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    mNameType [0] = "Line1";
    mColorType[0] = Line1_Color;
    mWidthType[0] = Line1_Width;
    mStyleType[0] = Line1_Style;

    mNameType [1] = "Line2";
    mColorType[1] = Line2_Color;
    mWidthType[1] = Line2_Width;
    mStyleType[1] = Line2_Style;

    mIndexType = 0;
    mTypeNum = 2;
}

void Line::prepareActive()
{
    mFirstPoint = false;
    pMouseInfo.setText(mNameType[mIndexType]);
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

    updateTypeProperty();
    updateDefaultProperty();
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void Line::updateDefaultProperty()
{
    ObjectSet(cMainLine, OBJPROP_RAY, false);
    ObjectSetText(cText, "");
    ObjectSetString(ChartID(), cMainLine ,OBJPROP_TOOLTIP,"\n");
}
void Line::updateTypeProperty()
{
    ObjectSet(cMainLine, OBJPROP_COLOR, mColorType[mIndexType]);
    ObjectSet(cMainLine, OBJPROP_WIDTH, mWidthType[mIndexType]);
    ObjectSet(cMainLine, OBJPROP_STYLE, mStyleType[mIndexType]);
    ObjectSet(cText,     OBJPROP_COLOR, mColorType[mIndexType]);
}
void Line::updateItemAfterChangeType()
{
    if (mFirstPoint == true)
    {
        updateTypeProperty();
    }
}

//Chart Event
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