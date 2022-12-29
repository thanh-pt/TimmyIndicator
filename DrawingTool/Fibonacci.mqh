#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string          Fibonacci_  = "Fibonacci Config";
//--------------------------------------------
input color           FibCenterColor = clrWhite;
input int             FibCenterWidth = 1;
input ENUM_LINE_STYLE FibCenterStyle = 2;
//--------------------------------------------
input string          Fib_0_Name  = "0";
input double          Fib_0_Value = 0;
input bool            Fib_0_Show  = true;
input color           Fib_0_Color = clrWhite;
input int             Fib_0_Width = 1;
input ENUM_LINE_STYLE Fib_0_Style = 0;
//--------------------------------------------
input string          Fib_1_Name  = "1";
input double          Fib_1_Value = 1;
input bool            Fib_1_Show  = true;
input color           Fib_1_Color = clrWhite;
input int             Fib_1_Width = 1;
input ENUM_LINE_STYLE Fib_1_Style = 0;
//--------------------------------------------
input string          Fib_2_Name  = "0.5";
input double          Fib_2_Value = 0.5;
input bool            Fib_2_Show  = true;
input color           Fib_2_Color = clrWhite;
input int             Fib_2_Width = 1;
input ENUM_LINE_STYLE Fib_2_Style = 0;
//--------------------------------------------
input string          Fib_3_Name  = "0.618";
input double          Fib_3_Value = 0.618;
input bool            Fib_3_Show  = true;
input color           Fib_3_Color = clrWhite;
input int             Fib_3_Width = 1;
input ENUM_LINE_STYLE Fib_3_Style = 0;
//--------------------------------------------
input string          Fib_4_Name  = "-0.27";
input double          Fib_4_Value = -0.27;
input bool            Fib_4_Show  = true;
input color           Fib_4_Color = clrWhite;
input int             Fib_4_Width = 1;
input ENUM_LINE_STYLE Fib_4_Style = 0;
//--------------------------------------------
input string          Fib_5_Name  = "-0.62";
input double          Fib_5_Value = -0.62;
input bool            Fib_5_Show  = true;
input color           Fib_5_Color = clrWhite;
input int             Fib_5_Width = 1;
input ENUM_LINE_STYLE Fib_5_Style = 0;

class Fibonacci : public BaseItem
{
// Internal Value
private:

// Component name
private:
    string cMainLine;
    string cFib0    ;
    string cFib1    ;
    string cFib2    ;
    string cFib3    ;
    string cFib4    ;
    string cFib5    ;
    string cText0   ;
    string cText1   ;
    string cText2   ;
    string cText3   ;
    string cText4   ;
    string cText5   ;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    double price1;
    double price2;

public:
    Fibonacci(const string name, CommonData* commonData, MouseInfo* mouseInfo);

// Internal Event
public:
    virtual void prepareActive();
    virtual void createItem();
    virtual void updateDefaultProperty();
    virtual void updateTypeProperty();
    virtual void activateItem(const string& itemId);
    virtual void updateItemAfterChangeType();
    virtual void refreshData();
    virtual void finishedJobDone();

// Chart Event
public:
    virtual void onMouseMove();
    virtual void onMouseClick();
    virtual void onItemDrag(const string &itemId, const string &objId);
    virtual void onItemClick(const string &itemId, const string &objId);
    virtual void onItemChange(const string &itemId, const string &objId);
    virtual void onItemDeleted(const string &itemId, const string &objId);
};

Fibonacci::Fibonacci(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [0] = "Fibonacci";
    mIndexType = 0;
    mTypeNum = 0;
}

// Internal Event
void Fibonacci::prepareActive()
{
    mFirstPoint = false;
    pMouseInfo.setText(mItemName);
}
void Fibonacci::createItem()
{
    if (cFib0) ObjectCreate(cFib0, OBJ_TREND, 0, 0, 0);
    if (cFib1) ObjectCreate(cFib1, OBJ_TREND, 0, 0, 0);
    if (cFib2) ObjectCreate(cFib2, OBJ_TREND, 0, 0, 0);
    if (cFib3) ObjectCreate(cFib3, OBJ_TREND, 0, 0, 0);
    if (cFib4) ObjectCreate(cFib4, OBJ_TREND, 0, 0, 0);
    if (cFib5) ObjectCreate(cFib5, OBJ_TREND, 0, 0, 0);
    //------------------------------------------
    if (cFib0) ObjectCreate(cText0, OBJ_TEXT, 0, 0, 0);
    if (cFib1) ObjectCreate(cText1, OBJ_TEXT, 0, 0, 0);
    if (cFib2) ObjectCreate(cText2, OBJ_TEXT, 0, 0, 0);
    if (cFib3) ObjectCreate(cText3, OBJ_TEXT, 0, 0, 0);
    if (cFib4) ObjectCreate(cText4, OBJ_TEXT, 0, 0, 0);
    if (cFib5) ObjectCreate(cText5, OBJ_TEXT, 0, 0, 0);
    ObjectCreate(cMainLine, OBJ_TREND, 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();

    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void Fibonacci::updateDefaultProperty()
{
    ObjectSet(cMainLine, OBJPROP_RAY, false);
    ObjectSet(cFib0    , OBJPROP_RAY, false);
    ObjectSet(cFib1    , OBJPROP_RAY, false);
    ObjectSet(cFib2    , OBJPROP_RAY, false);
    ObjectSet(cFib3    , OBJPROP_RAY, false);
    ObjectSet(cFib4    , OBJPROP_RAY, false);
    ObjectSet(cFib5    , OBJPROP_RAY, false);
    //------------------------------------------
    ObjectSetString(ChartID(), cMainLine,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cFib0    ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cFib1    ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cFib2    ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cFib3    ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cFib4    ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cFib5    ,OBJPROP_TOOLTIP,"\n");
    //------------------------------------------
    ObjectSetString(ChartID(), cText0   ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cText1   ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cText2   ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cText3   ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cText4   ,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(ChartID(), cText5   ,OBJPROP_TOOLTIP,"\n");
    // TODO: update text anchor
}
void Fibonacci::updateTypeProperty()
{
    ObjectSetText(cText0, Fib_0_Name);
    ObjectSetText(cText1, Fib_1_Name);
    ObjectSetText(cText2, Fib_2_Name);
    ObjectSetText(cText3, Fib_3_Name);
    ObjectSetText(cText4, Fib_4_Name);
    ObjectSetText(cText5, Fib_5_Name);
    //------------------------------------------
    ObjectSet(cText0, OBJPROP_COLOR, Fib_0_Color);
    ObjectSet(cText1, OBJPROP_COLOR, Fib_1_Color);
    ObjectSet(cText2, OBJPROP_COLOR, Fib_2_Color);
    ObjectSet(cText3, OBJPROP_COLOR, Fib_3_Color);
    ObjectSet(cText4, OBJPROP_COLOR, Fib_4_Color);
    ObjectSet(cText5, OBJPROP_COLOR, Fib_5_Color);
    //------------------------------------------
    ObjectSet(cMainLine, OBJPROP_COLOR, FibCenterColor);
    ObjectSet(cMainLine, OBJPROP_WIDTH, FibCenterWidth);
    ObjectSet(cMainLine, OBJPROP_STYLE, FibCenterStyle);
    //------------------------------------------
    ObjectSet(cFib0, OBJPROP_COLOR, Fib_0_Color);
    ObjectSet(cFib0, OBJPROP_WIDTH, Fib_0_Width);
    ObjectSet(cFib0, OBJPROP_STYLE, Fib_0_Style);
    //------------------------------------------
    ObjectSet(cFib1, OBJPROP_COLOR, Fib_1_Color);
    ObjectSet(cFib1, OBJPROP_WIDTH, Fib_1_Width);
    ObjectSet(cFib1, OBJPROP_STYLE, Fib_1_Style);
    //------------------------------------------
    ObjectSet(cFib2, OBJPROP_COLOR, Fib_2_Color);
    ObjectSet(cFib2, OBJPROP_WIDTH, Fib_2_Width);
    ObjectSet(cFib2, OBJPROP_STYLE, Fib_2_Style);
    //------------------------------------------
    ObjectSet(cFib3, OBJPROP_COLOR, Fib_3_Color);
    ObjectSet(cFib3, OBJPROP_WIDTH, Fib_3_Width);
    ObjectSet(cFib3, OBJPROP_STYLE, Fib_3_Style);
    //------------------------------------------
    ObjectSet(cFib4, OBJPROP_COLOR, Fib_4_Color);
    ObjectSet(cFib4, OBJPROP_WIDTH, Fib_4_Width);
    ObjectSet(cFib4, OBJPROP_STYLE, Fib_4_Style);
    //------------------------------------------
    ObjectSet(cFib5, OBJPROP_COLOR, Fib_5_Color);
    ObjectSet(cFib5, OBJPROP_WIDTH, Fib_5_Width);
    ObjectSet(cFib5, OBJPROP_STYLE, Fib_5_Style);
    //------------------------------------------
}
void Fibonacci::activateItem(const string& itemId)
{
    string cMainLine = itemId + "_" + "cMainLine";
    string cFib0     = itemId + "_" + "cFib0";
    string cFib1     = itemId + "_" + "cFib1";
    string cFib2     = itemId + "_" + "cFib2";
    string cFib3     = itemId + "_" + "cFib3";
    string cFib4     = itemId + "_" + "cFib4";
    string cFib5     = itemId + "_" + "cFib5";
    string cText0    = itemId + "_" + "cText0";
    string cText1    = itemId + "_" + "cText1";
    string cText2    = itemId + "_" + "cText2";
    string cText3    = itemId + "_" + "cText3";
    string cText4    = itemId + "_" + "cText4";
    string cText5    = itemId + "_" + "cText5";
}
void Fibonacci::updateItemAfterChangeType(){}
void Fibonacci::refreshData()
{
    double priceFib2;
    double priceFib3;
    double priceFib4;
    double priceFib5;
}
void Fibonacci::finishedJobDone(){}

// Chart Event
void Fibonacci::onMouseMove()
{
    if (mFirstPoint == false)
    {
        return;
    }
    time2  = pCommonData.mMouseTime;
    price2 = pCommonData.mMousePrice;
    refreshData();
}
void Fibonacci::onMouseClick()
{
    if (mFirstPoint == false)
    {
        createItem();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}
void Fibonacci::onItemDrag(const string &itemId, const string &objId)
{
    time1   = (datetime)ObjectGet(cMainLine, OBJPROP_TIME1);
    time2   = (datetime)ObjectGet(cMainLine, OBJPROP_TIME2);
    price1  =           ObjectGet(cMainLine, OBJPROP_PRICE1);
    price2  =           ObjectGet(cMainLine, OBJPROP_PRICE2);

    refreshData();
}
void Fibonacci::onItemClick(const string &itemId, const string &objId){}
void Fibonacci::onItemChange(const string &itemId, const string &objId){}
void Fibonacci::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cMainLine);
    ObjectDelete(cFib0    );
    ObjectDelete(cFib1    );
    ObjectDelete(cFib2    );
    ObjectDelete(cFib3    );
    ObjectDelete(cFib4    );
    ObjectDelete(cFib5    );
    ObjectDelete(cText0   );
    ObjectDelete(cText1   );
    ObjectDelete(cText2   );
    ObjectDelete(cText3   );
    ObjectDelete(cText4   );
    ObjectDelete(cText5   );
}