#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

enum EV_ALIGN
{
    TOP     = 0,
    MIDDLE  = 1,
    BOTTOM  = 2,
};
enum EH_ALIGN
{
    LEFT    = 0,
    CENTER  = 1,
    RIGHT   = 2,
};

ENUM_ANCHOR_POINT gMatrixAnchorPoint[3][3] = {
    ANCHOR_LEFT_LOWER  , ANCHOR_LOWER  , ANCHOR_RIGHT_LOWER ,
    ANCHOR_LEFT        , ANCHOR_CENTER , ANCHOR_RIGHT       ,
    ANCHOR_LEFT_UPPER  , ANCHOR_UPPER  , ANCHOR_RIGHT_UPPER 
};

input string            HTrend_         = SEPARATE_LINE_BIG;
input int               HTrend_Width    = 0;
input string            HTrend_sp       = SEPARATE_LINE;
//-----------------------------------------------------------
input string            HTrend_1_NAME   = "bos up";
input string            HTrend_1_TEXT   = "bos";
input EV_ALIGN          HTrend_1_VAlign = EV_ALIGN::TOP;
input EH_ALIGN          HTrend_1_HAlign = EH_ALIGN::LEFT;
input ENUM_LINE_STYLE   HTrend_1_Style  = STYLE_DOT;
input color             HTrend_1_Color  = clrDarkGray;
input string            HTrend_1_sp     = SEPARATE_LINE;
//-----------------------------------------------------------
input string            HTrend_2_NAME   = "bos down";
input string            HTrend_2_TEXT   = "bos";
input EV_ALIGN          HTrend_2_VAlign = EV_ALIGN::BOTTOM;
input EH_ALIGN          HTrend_2_HAlign = EH_ALIGN::LEFT;
input ENUM_LINE_STYLE   HTrend_2_Style  = STYLE_DOT;
input color             HTrend_2_Color  = clrDarkGray;
input string            HTrend_2_sp     = SEPARATE_LINE;
//-----------------------------------------------------------
input string            HTrend_3_NAME   = "high";
input string            HTrend_3_TEXT   = "high";
input EV_ALIGN          HTrend_3_VAlign = EV_ALIGN::TOP;
input EH_ALIGN          HTrend_3_HAlign = EH_ALIGN::RIGHT;
input ENUM_LINE_STYLE   HTrend_3_Style  = STYLE_SOLID;
input color             HTrend_3_Color  = clrSilver;
input string            HTrend_3_sp     = SEPARATE_LINE;
//-----------------------------------------------------------
input string            HTrend_4_NAME   = "low";
input string            HTrend_4_TEXT   = "low";
input EV_ALIGN          HTrend_4_VAlign = EV_ALIGN::BOTTOM;
input EH_ALIGN          HTrend_4_HAlign = EH_ALIGN::RIGHT;
input ENUM_LINE_STYLE   HTrend_4_Style  = STYLE_SOLID;
input color             HTrend_4_Color  = clrSilver;
input string            HTrend_4_sp     = SEPARATE_LINE;
//-----------------------------------------------------------
input string            HTrend_5_NAME   = "sweep";
input string            HTrend_5_TEXT   = "sweep";
input EV_ALIGN          HTrend_5_VAlign = EV_ALIGN::MIDDLE;
input EH_ALIGN          HTrend_5_HAlign = EH_ALIGN::RIGHT;
input ENUM_LINE_STYLE   HTrend_5_Style  = STYLE_DOT;
input color             HTrend_5_Color  = clrRed;
input string            HTrend_5_sp     = SEPARATE_LINE;

class HTrend : public BaseItem
{
// Internal Value
private:
    string              mPropText  [MAX_TYPE];
    EV_ALIGN            mPropVAlign[MAX_TYPE];
    EH_ALIGN            mPropHAlign[MAX_TYPE];
    ENUM_LINE_STYLE     mPropStyle [MAX_TYPE];
    color               mPropColor [MAX_TYPE];
// Component name
private:
    string cMainTrend;
    string cText    ;

// Value define for Item
private:
    double price;
    datetime time1;
    datetime time2;

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
    mNameType  [0] = HTrend_1_NAME  ;
    mPropText  [0] = HTrend_1_TEXT  ;
    mPropVAlign[0] = HTrend_1_VAlign;
    mPropHAlign[0] = HTrend_1_HAlign;
    mPropStyle [0] = HTrend_1_Style ;
    mPropColor [0] = HTrend_1_Color ;
    //-----------------------------
    mNameType  [1] = HTrend_2_NAME  ;
    mPropText  [1] = HTrend_2_TEXT  ;
    mPropVAlign[1] = HTrend_2_VAlign;
    mPropHAlign[1] = HTrend_2_HAlign;
    mPropStyle [1] = HTrend_2_Style ;
    mPropColor [1] = HTrend_2_Color ;
    //-----------------------------
    mNameType  [2] = HTrend_3_NAME  ;
    mPropText  [2] = HTrend_3_TEXT  ;
    mPropVAlign[2] = HTrend_3_VAlign;
    mPropHAlign[2] = HTrend_3_HAlign;
    mPropStyle [2] = HTrend_3_Style ;
    mPropColor [2] = HTrend_3_Color ;
    //-----------------------------
    mNameType  [3] = HTrend_4_NAME  ;
    mPropText  [3] = HTrend_4_TEXT  ;
    mPropVAlign[3] = HTrend_4_VAlign;
    mPropHAlign[3] = HTrend_4_HAlign;
    mPropStyle [3] = HTrend_4_Style ;
    mPropColor [3] = HTrend_4_Color ;
    //-----------------------------
    mNameType  [4] = HTrend_5_NAME  ;
    mPropText  [4] = HTrend_5_TEXT  ;
    mPropVAlign[4] = HTrend_5_VAlign;
    mPropHAlign[4] = HTrend_5_HAlign;
    mPropStyle [4] = HTrend_5_Style ;
    mPropColor [4] = HTrend_5_Color ;
    //-----------------------------
    mIndexType = 0;
    mTypeNum   = 5;
}

// Internal Event
void HTrend::prepareActive(){}

void HTrend::createItem()
{
    ObjectCreate(cText     , OBJ_TEXT , 0, 0, 0);
    ObjectCreate(cMainTrend, OBJ_TREND, 0, 0, 0);

    updateTypeProperty();

    updateDefaultProperty();

    // Value define update
    time1 = pCommonData.mMouseTime;
    price = pCommonData.mMousePrice;
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
    ObjectSet(cMainTrend, OBJPROP_STYLE, mPropStyle[mIndexType]);
    //------------------------------------------------------------
    ObjectSet(cMainTrend, OBJPROP_COLOR, mPropColor[mIndexType]);
    ObjectSet(cText,      OBJPROP_COLOR, mPropColor[mIndexType]);
    ObjectSetText(cText,  mPropText[mIndexType]);
    ObjectSetInteger(ChartID(), cText, OBJPROP_ANCHOR, gMatrixAnchorPoint[mPropVAlign[mIndexType]][mPropHAlign[mIndexType]]);
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
    setItemPos(cMainTrend, time1, time2, price, price);
    datetime textTime;
    int propAnchor = (int)ObjectGetInteger(ChartID(), cText, OBJPROP_ANCHOR);
    switch (propAnchor)
    {
        case ANCHOR_RIGHT_LOWER:
        case ANCHOR_RIGHT      :
        case ANCHOR_RIGHT_UPPER:
            textTime = time2-ChartPeriod()*60;
            break;
        case ANCHOR_LEFT_LOWER :
        case ANCHOR_LEFT       :
        case ANCHOR_LEFT_UPPER :
            textTime = time1+ChartPeriod()*60;
            break;
        default:
            textTime = getCenterTime(time1, time2);
    }
    setItemPos(cText      , textTime, price);
    string textString = ObjectGetString(ChartID(), cText, OBJPROP_TEXT);
    if (StringFind(textString, "𓈖") == -1 && textString != "")
    {
        textString += "𓈖" + getTFString();
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

    if (pCommonData.mCtrlHold)
    {
        price = pCommonData.mMousePrice;
    }
    
    if (time1 > time2)
    {
        datetime temp = time1;
        time1 = time2;
        time2 = temp;
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