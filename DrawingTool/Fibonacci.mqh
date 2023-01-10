#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

input string          Fibonacci_  = SEPARATE_LINE_BIG;
//--------------------------------------------
input color           FibTrendColor = clrGray;
input int             FibTrendWidth = 1;
input ENUM_LINE_STYLE FibTrendStyle = 2;
input string          Fib_sp_trend  = SEPARATE_LINE;
//--------------------------------------------
input int             FibLevelWidth = 1;
input ENUM_LINE_STYLE FibLevelStyle = 0;
input string          Fib_sp_level  = SEPARATE_LINE;
//--------------------------------------------
input bool            Fib_0_Show  = true;
input double          Fib_0_Ratio = 0;
input color           Fib_0_Color = clrGray;
input string          Fib_0_sp    = SEPARATE_LINE;
//--------------------------------------------
input bool            Fib_1_Show  = true;
input double          Fib_1_Ratio = 1;
input color           Fib_1_Color = clrGray;
input string          Fib_1_sp    = SEPARATE_LINE;
//--------------------------------------------
input bool            Fib_2_Show  = true;
input double          Fib_2_Ratio = 0.5;
input color           Fib_2_Color = clrYellow;
input string          Fib_2_sp    = SEPARATE_LINE;
//--------------------------------------------
input bool            Fib_3_Show  = true;
input double          Fib_3_Ratio = 0.618;
input color           Fib_3_Color = clrYellow;
input string          Fib_3_sp    = SEPARATE_LINE;
//--------------------------------------------
input bool            Fib_4_Show  = true;
input double          Fib_4_Ratio = -0.27;
input color           Fib_4_Color = clrGold;
input string          Fib_4_sp    = SEPARATE_LINE;
//--------------------------------------------
input bool            Fib_5_Show  = true;
input double          Fib_5_Ratio = -0.62;
input color           Fib_5_Color = clrRed;

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
    datetime time0;
    datetime time1;
    double price0;
    double price1;

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
void Fibonacci::prepareActive(){}
void Fibonacci::createItem()
{
    if (Fib_0_Show) ObjectCreate(cFib0, OBJ_TREND, 0, 0, 0);
    if (Fib_1_Show) ObjectCreate(cFib1, OBJ_TREND, 0, 0, 0);
    if (Fib_2_Show) ObjectCreate(cFib2, OBJ_TREND, 0, 0, 0);
    if (Fib_3_Show) ObjectCreate(cFib3, OBJ_TREND, 0, 0, 0);
    if (Fib_4_Show) ObjectCreate(cFib4, OBJ_TREND, 0, 0, 0);
    if (Fib_5_Show) ObjectCreate(cFib5, OBJ_TREND, 0, 0, 0);
    //------------------------------------------
    if (Fib_0_Show) ObjectCreate(cText0, OBJ_TEXT, 0, 0, 0);
    if (Fib_1_Show) ObjectCreate(cText1, OBJ_TEXT, 0, 0, 0);
    if (Fib_2_Show) ObjectCreate(cText2, OBJ_TEXT, 0, 0, 0);
    if (Fib_3_Show) ObjectCreate(cText3, OBJ_TEXT, 0, 0, 0);
    if (Fib_4_Show) ObjectCreate(cText4, OBJ_TEXT, 0, 0, 0);
    if (Fib_5_Show) ObjectCreate(cText5, OBJ_TEXT, 0, 0, 0);
    ObjectCreate(cMainLine, OBJ_TREND, 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();

    time0  = pCommonData.mMouseTime;
    price0 = pCommonData.mMousePrice;
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
    //------------------------------------------
    ObjectSetInteger(ChartID(), cText0  , OBJPROP_ANCHOR, ANCHOR_RIGHT);
    ObjectSetInteger(ChartID(), cText1  , OBJPROP_ANCHOR, ANCHOR_RIGHT);
    ObjectSetInteger(ChartID(), cText2  , OBJPROP_ANCHOR, ANCHOR_RIGHT);
    ObjectSetInteger(ChartID(), cText3  , OBJPROP_ANCHOR, ANCHOR_RIGHT);
    ObjectSetInteger(ChartID(), cText4  , OBJPROP_ANCHOR, ANCHOR_RIGHT);
    ObjectSetInteger(ChartID(), cText5  , OBJPROP_ANCHOR, ANCHOR_RIGHT);
    //------------------------------------------
    ObjectSet(cText0, OBJPROP_SELECTABLE, 0);
    ObjectSet(cText1, OBJPROP_SELECTABLE, 0);
    ObjectSet(cText2, OBJPROP_SELECTABLE, 0);
    ObjectSet(cText3, OBJPROP_SELECTABLE, 0);
    ObjectSet(cText4, OBJPROP_SELECTABLE, 0);
    ObjectSet(cText5, OBJPROP_SELECTABLE, 0);
    //------------------------------------------
    ObjectSet(cFib0 , OBJPROP_SELECTABLE, 0);
    ObjectSet(cFib1 , OBJPROP_SELECTABLE, 0);
    ObjectSet(cFib2 , OBJPROP_SELECTABLE, 0);
    ObjectSet(cFib3 , OBJPROP_SELECTABLE, 0);
    ObjectSet(cFib4 , OBJPROP_SELECTABLE, 0);
    ObjectSet(cFib5 , OBJPROP_SELECTABLE, 0);
}
void Fibonacci::updateTypeProperty()
{
    ObjectSetText(cText0, DoubleToString(Fib_0_Ratio, 2) + "  ", 7, NULL, Fib_0_Color);
    ObjectSetText(cText1, DoubleToString(Fib_1_Ratio, 2) + "  ", 7, NULL, Fib_1_Color);
    ObjectSetText(cText2, DoubleToString(Fib_2_Ratio, 2) + "  ", 7, NULL, Fib_2_Color);
    ObjectSetText(cText3, DoubleToString(Fib_3_Ratio, 2) + "  ", 7, NULL, Fib_3_Color);
    ObjectSetText(cText4, DoubleToString(Fib_4_Ratio, 2) + "  ", 7, NULL, Fib_4_Color);
    ObjectSetText(cText5, DoubleToString(Fib_5_Ratio, 2) + "  ", 7, NULL, Fib_5_Color);
    //------------------------------------------
    ObjectSet(cMainLine, OBJPROP_COLOR, FibTrendColor);
    ObjectSet(cMainLine, OBJPROP_WIDTH, FibTrendWidth);
    ObjectSet(cMainLine, OBJPROP_STYLE, FibTrendStyle);
    //------------------------------------------
    ObjectSet(cFib0, OBJPROP_COLOR, Fib_0_Color);
    ObjectSet(cFib1, OBJPROP_COLOR, Fib_1_Color);
    ObjectSet(cFib2, OBJPROP_COLOR, Fib_2_Color);
    ObjectSet(cFib3, OBJPROP_COLOR, Fib_3_Color);
    ObjectSet(cFib4, OBJPROP_COLOR, Fib_4_Color);
    ObjectSet(cFib5, OBJPROP_COLOR, Fib_5_Color);
    //------------------------------------------
    ObjectSet(cFib0, OBJPROP_WIDTH, FibLevelWidth);
    ObjectSet(cFib1, OBJPROP_WIDTH, FibLevelWidth);
    ObjectSet(cFib2, OBJPROP_WIDTH, FibLevelWidth);
    ObjectSet(cFib3, OBJPROP_WIDTH, FibLevelWidth);
    ObjectSet(cFib4, OBJPROP_WIDTH, FibLevelWidth);
    ObjectSet(cFib5, OBJPROP_WIDTH, FibLevelWidth);
    //------------------------------------------
    ObjectSet(cFib0, OBJPROP_STYLE, FibLevelStyle);
    ObjectSet(cFib1, OBJPROP_STYLE, FibLevelStyle);
    ObjectSet(cFib2, OBJPROP_STYLE, FibLevelStyle);
    ObjectSet(cFib3, OBJPROP_STYLE, FibLevelStyle);
    ObjectSet(cFib4, OBJPROP_STYLE, FibLevelStyle);
    ObjectSet(cFib5, OBJPROP_STYLE, FibLevelStyle);
}
void Fibonacci::activateItem(const string& itemId)
{
    cMainLine = itemId + "_" + "cMainLine";
    cFib0     = itemId + "_" + "cFib0";
    cFib1     = itemId + "_" + "cFib1";
    cFib2     = itemId + "_" + "cFib2";
    cFib3     = itemId + "_" + "cFib3";
    cFib4     = itemId + "_" + "cFib4";
    cFib5     = itemId + "_" + "cFib5";
    cText0    = itemId + "_" + "cText0";
    cText1    = itemId + "_" + "cText1";
    cText2    = itemId + "_" + "cText2";
    cText3    = itemId + "_" + "cText3";
    cText4    = itemId + "_" + "cText4";
    cText5    = itemId + "_" + "cText5";
}
void Fibonacci::updateItemAfterChangeType(){}
void Fibonacci::refreshData()
{
    double price2 = price1-Fib_2_Ratio*(price1-price0);
    double price3 = price1-Fib_3_Ratio*(price1-price0);
    double price4 = price1-Fib_4_Ratio*(price1-price0);
    double price5 = price1-Fib_5_Ratio*(price1-price0);
    //-------------------------------------------------
    
    setItemPos(cMainLine, time0, time1, price0, price1);
    setItemPos(cFib0    , time0, time1, price0, price0);
    setItemPos(cFib1    , time0, time1, price1, price1);
    setItemPos(cFib2    , time0, time1, price2, price2);
    setItemPos(cFib3    , time0, time1, price3, price3);
    setItemPos(cFib4    , time0, time1, price4, price4);
    setItemPos(cFib5    , time0, time1, price5, price5);
    //-------------------------------------------------
    setItemPos(cText0   , time0, price0);
    setItemPos(cText1   , time0, price1);
    setItemPos(cText2   , time0, price2);
    setItemPos(cText3   , time0, price3);
    setItemPos(cText4   , time0, price4);
    setItemPos(cText5   , time0, price5);
}
void Fibonacci::finishedJobDone(){}

// Chart Event
void Fibonacci::onMouseMove()
{
    if (mFirstPoint == false)
    {
        return;
    }
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
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
    time0   = (datetime)ObjectGet(cMainLine, OBJPROP_TIME1);
    time1   = (datetime)ObjectGet(cMainLine, OBJPROP_TIME2);
    price0  =           ObjectGet(cMainLine, OBJPROP_PRICE1);
    price1  =           ObjectGet(cMainLine, OBJPROP_PRICE2);

    if (pCommonData.mCtrlHold)
    {
        double oldPrice0 = ObjectGet(cText0, OBJPROP_PRICE1);
        double oldPrice1 = ObjectGet(cText1, OBJPROP_PRICE1);
        if (price0 == oldPrice0 && price1 != oldPrice1)
        {
            price1 = pCommonData.mMousePrice;
        }
        else if (price0 != oldPrice0 && price1 == oldPrice1)
        {
            price0 = pCommonData.mMousePrice;
        }
    }

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