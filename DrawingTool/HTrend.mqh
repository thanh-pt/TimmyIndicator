#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string            HTrend_ = SEPARATE_LINE_BIG;
input int               HTrend_Width  = 0;
input ENUM_LINE_STYLE   HTrend_Style  = 2;
input string            HTrend_sp     = SEPARATE_LINE;
//-----------------------------------------------------------
input string            HTrend_1_NAME   = "bos➚";
input color             HTrend_1_Color  = clrYellowGreen;
input ENUM_ANCHOR_POINT HTrend_1_Anchor = ANCHOR_LOWER;
input string            HTrend_1_sp     = SEPARATE_LINE;
//-----------------------------------------------------------
input string            HTrend_2_NAME   = "SH";
input color             HTrend_2_Color  = clrYellowGreen;
input ENUM_ANCHOR_POINT HTrend_2_Anchor = ANCHOR_LOWER;
input string            HTrend_2_sp     = SEPARATE_LINE;
//-----------------------------------------------------------
input string            HTrend_3_NAME   = "Strong SH";
input color             HTrend_3_Color  = clrYellowGreen;
input ENUM_ANCHOR_POINT HTrend_3_Anchor = ANCHOR_LOWER;
input string            HTrend_3_sp     = SEPARATE_LINE;
//-----------------------------------------------------------
input string            HTrend_4_NAME   = "bos➘";
input color             HTrend_4_Color  = clrOrangeRed;
input ENUM_ANCHOR_POINT HTrend_4_Anchor = ANCHOR_UPPER;
input string            HTrend_4_sp     = SEPARATE_LINE;
//-----------------------------------------------------------
input string            HTrend_5_NAME   = "SL";
input color             HTrend_5_Color  = clrOrangeRed;
input ENUM_ANCHOR_POINT HTrend_5_Anchor = ANCHOR_UPPER;
input string            HTrend_5_sp     = SEPARATE_LINE;
//-----------------------------------------------------------
input string            HTrend_6_NAME   = "Strong SL";
input color             HTrend_6_Color  = clrOrangeRed;
input ENUM_ANCHOR_POINT HTrend_6_Anchor = ANCHOR_UPPER;

class HTrend : public BaseItem
{
// Internal Value
private:
    color               mColorType[MAX_TYPE];
    ENUM_ANCHOR_POINT   mAnchrType[MAX_TYPE];

// Component name
private:
    string cMainTrend;
    string cText    ;

// Value define for Item
private:
    double price;
    double priceText;
    datetime time1;
    datetime time2;
    datetime timeText;

public:
    HTrend(const string name, CommonData* commonData, MouseInfo* mouseInfo);

// Internal Event
public:
    virtual void prepareActive();
    virtual void createItem();
    virtual void updateDefaultProperty();
    virtual void updateTypeProperty();
    virtual void activateItem(const string& itemId);
    virtual void updateItemAfterChangeType();
    virtual void refreshData();

// Chart Event
public:
    virtual void onMouseMove();
    virtual void onMouseClick();
    virtual void onItemDrag(const string &itemId, const string &objId);
    virtual void onItemClick(const string &itemId, const string &objId);
    virtual void onItemChange(const string &itemId, const string &objId);
    virtual void onItemDeleted(const string &itemId, const string &objId);
};

HTrend::HTrend(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [0] = HTrend_1_NAME  ;
    mColorType[0] = HTrend_1_Color ;
    mAnchrType[0] = HTrend_1_Anchor;
    //-----------------------------
    mNameType [1] = HTrend_2_NAME  ;
    mColorType[1] = HTrend_2_Color ;
    mAnchrType[1] = HTrend_2_Anchor;
    //-----------------------------
    mNameType [2] = HTrend_3_NAME  ;
    mColorType[2] = HTrend_3_Color ;
    mAnchrType[2] = HTrend_3_Anchor;
    //-----------------------------
    mNameType [3] = HTrend_4_NAME  ;
    mColorType[3] = HTrend_4_Color ;
    mAnchrType[3] = HTrend_4_Anchor;
    //-----------------------------
    mNameType [4] = HTrend_5_NAME  ;
    mColorType[4] = HTrend_5_Color ;
    mAnchrType[4] = HTrend_5_Anchor;
    //-----------------------------
    mNameType [5] = HTrend_6_NAME  ;
    mColorType[5] = HTrend_6_Color ;
    mAnchrType[5] = HTrend_6_Anchor;
    //-----------------------------
    mIndexType = 0;
    mTypeNum   = 6;
}

// Internal Event
void HTrend::prepareActive(){}

void HTrend::createItem()
{
    ObjectCreate(cText    , OBJ_TEXT , 0, 0, 0);
    ObjectCreate(cMainTrend, OBJ_TREND, 0, 0, 0);

    updateTypeProperty();

    updateDefaultProperty();

    // Value define update
    time1 = pCommonData.mMouseTime;
    price = pCommonData.mMousePrice;
    priceText = price;
}
void HTrend::updateDefaultProperty()
{
    ObjectSet(cMainTrend, OBJPROP_RAY, false);
    ObjectSetString(ChartID(), cText      ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cMainTrend ,OBJPROP_TOOLTIP,"\n");
}
void HTrend::updateTypeProperty()
{
    ObjectSet(cMainTrend, OBJPROP_WIDTH, HTrend_Width);
    ObjectSet(cMainTrend, OBJPROP_STYLE, HTrend_Style);
    //------------------------------------------------------------
    ObjectSet(cMainTrend, OBJPROP_COLOR, mColorType[mIndexType]);
    ObjectSet(cText,      OBJPROP_COLOR, mColorType[mIndexType]);
    ObjectSetText(cText,  mNameType[mIndexType]);
    ObjectSetInteger(ChartID(), cText, OBJPROP_ANCHOR, mAnchrType[mIndexType]);
}
void HTrend::activateItem(const string& itemId)
{
    cMainTrend = itemId + "_cMainTrend";
    cText     = itemId + "_cText";
}
void HTrend::updateItemAfterChangeType()
{
    if (mFirstPoint == true)
    {
        updateTypeProperty();
    }
}
void HTrend::refreshData()
{
    ObjectSet(cMainTrend, OBJPROP_TIME1,  time1);
    ObjectSet(cMainTrend, OBJPROP_TIME2,  time2);
    ObjectSet(cMainTrend, OBJPROP_PRICE1, price);
    ObjectSet(cMainTrend, OBJPROP_PRICE2, price);
    ObjectSet(cText     , OBJPROP_PRICE1, price);

    do
    {
        if (priceText == price)
        {
            ObjectSet(cText, OBJPROP_TIME1, getCenterTime(time1, time2));
            break;
        }

        if (priceText > price)
        {
            ObjectSetInteger(0, cText, OBJPROP_ANCHOR, ANCHOR_LOWER);
        }
        else
        {
            ObjectSetInteger(0, cText, OBJPROP_ANCHOR, ANCHOR_UPPER);
        }
        ObjectSet(cText, OBJPROP_TIME1, timeText);
    }
    while (false);
    string textString = ObjectGetString(ChartID(), cText, OBJPROP_TEXT);
    if (StringFind(textString, "<") == -1 && textString != "")
    {
        textString += "<" + getTFString() + ">";
        ObjectSetText(cText    , textString);
    }
}

// Chart Event
void HTrend::onMouseMove()
{
    if (mFirstPoint == false)
    {
        return;
    }
    time2 = pCommonData.mMouseTime;
    refreshData();
}
void HTrend::onMouseClick()
{
    if (mFirstPoint == false)
    {
        createItem();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}
void HTrend::onItemDrag(const string &itemId, const string &objId)
{
    time1 = (datetime)ObjectGet(cMainTrend, OBJPROP_TIME1);
    time2 = (datetime)ObjectGet(cMainTrend, OBJPROP_TIME2);
    price = ObjectGet(cMainTrend, OBJPROP_PRICE1);
    priceText = price;

    if (objId == cText)
    {
        priceText = ObjectGet(cText, OBJPROP_PRICE1);
        timeText = (datetime)ObjectGet(cText, OBJPROP_TIME1);
    }

    refreshData();
}
void HTrend::onItemClick(const string &itemId, const string &objId)
{
    if (objId == cText)
    {
        ObjectSet(cMainTrend, OBJPROP_SELECTED, ObjectGet(cText, OBJPROP_SELECTED));
    }
}
void HTrend::onItemChange(const string &itemId, const string &objId)
{
    color c = (color)ObjectGet(objId, OBJPROP_COLOR);
    ObjectSet(cMainTrend, OBJPROP_COLOR, c);
    ObjectSet(cText     , OBJPROP_COLOR, c);
    if (objId == cMainTrend)
    {
        string lineDescription = ObjectDescription(cMainTrend);
        if (lineDescription != "")
        {
            ObjectSetText(cText    , lineDescription);
            ObjectSetText(cMainTrend, "");
        }
    }
}
void HTrend::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cMainTrend);
    ObjectDelete(cText    );
}