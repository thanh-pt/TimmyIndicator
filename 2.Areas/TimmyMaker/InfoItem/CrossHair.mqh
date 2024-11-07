#include "../Home/CommonData.mqh"
#include "../Home/UtilityHeader.mqh"
input string CrossHair_;                        // ●  C R O S S   H A I R  ●
input bool   CrossHair_DisplayDateInfo  = true; // Date Info
input eTz    CrossHair_ServerTz         = eTz0; // Server Timezone


int gLocalTz = 7;

class CrossHair
{
private:
    CommonData* pCommonData;
    string mStrTimeInfo;
    int mOffsetTime;
// COMPONENTS
private:
    string mVCrossHair;
    string mHCrossHair;
    string miHPriceBg;
    string mWeekInfo;
    string mDateInfo;
    string miDtBkgnd;
public:
    CrossHair(CommonData* commonData)
    {
        gLocalTz = (int)(TimeLocal() - TimeGMT())/3600;
        pCommonData = commonData;
        if (CrossHair_ServerTz == eTzAuto) {
            mOffsetTime = (int)(TimeLocal() - TimeCurrent())/3600;
        }
        else {
            mOffsetTime = gLocalTz - CrossHair_ServerTz;
        }
        // Init component
        mVCrossHair = "." + TAG_STATIC + TAG_CTRL + "mVCrossHair";
        mHCrossHair = "." + TAG_STATIC + TAG_CTRL + "mHCrossHair";
        mWeekInfo   = "." + TAG_STATIC + TAG_CTRL + "mWeekInfo";
        mDateInfo   = "." + TAG_STATIC + TAG_CTRL + "mDateInfo";

        miHPriceBg  = "." + TAG_STATIC + TAG_INFO + "miHPriceBg";
        miDtBkgnd   = "." + TAG_STATIC + TAG_INFO + "miDtBkgnd";

        initDrawing();
    }
    void initDrawing()
    {
        ObjectDelete(mVCrossHair);
        ObjectDelete(mHCrossHair);
        ObjectDelete(mWeekInfo);
        ObjectDelete(mDateInfo);
        // --- Info background ---
        ObjectCreate(miDtBkgnd, OBJ_LABEL, 0, 0, 0);
        setTextContent(miDtBkgnd, "█████", 20, FONT_BLOCK);
        ObjectSet(miDtBkgnd, OBJPROP_SELECTABLE, false);
        ObjectSet(miDtBkgnd, OBJPROP_COLOR, clrWhite);
        ObjectSet(miDtBkgnd, OBJPROP_YDISTANCE, CrossHair_DisplayDateInfo ? 25 : 15);
        ObjectSet(miDtBkgnd, OBJPROP_CORNER , CORNER_LEFT_LOWER);
        ObjectSet(miDtBkgnd, OBJPROP_ANCHOR , ANCHOR_LEFT_UPPER);
        ObjectSetString( 0, miDtBkgnd, OBJPROP_TOOLTIP,"\n");
        // --- HPrice background ---
        ObjectCreate(miHPriceBg, OBJ_LABEL, 0, 0, 0);
        setTextContent(miHPriceBg, "██████", 9, FONT_BLOCK);
        ObjectSet(miHPriceBg, OBJPROP_SELECTABLE, false);
        ObjectSet(miHPriceBg, OBJPROP_COLOR, clrWhite);
        ObjectSet(miHPriceBg, OBJPROP_XDISTANCE, 0);
        ObjectSet(miHPriceBg, OBJPROP_CORNER , CORNER_RIGHT_UPPER);
        ObjectSet(miHPriceBg, OBJPROP_ANCHOR , ANCHOR_RIGHT_LOWER);
        ObjectSetString( 0, miHPriceBg, OBJPROP_TOOLTIP,"\n");

        ObjectCreate(mVCrossHair, OBJ_RECTANGLE, 0, 0, 0);
        setObjectStyle(mVCrossHair, gClrPointer, STYLE_DOT, 0);
        ObjectSet(mVCrossHair, OBJPROP_SELECTABLE, false);
        ObjectSet(mVCrossHair, OBJPROP_TIME2, 0);

        ObjectCreate(mHCrossHair, OBJ_FIBO, 0, 0, 0);
        ObjectSet(mHCrossHair, OBJPROP_RAY  , true);
        ObjectSet(mHCrossHair, OBJPROP_SELECTABLE, false);
        ObjectSet(mHCrossHair,OBJPROP_LEVELS, 1);
        ObjectSetDouble (0, mHCrossHair,OBJPROP_LEVELVALUE,0, 0);
        ObjectSetInteger(0, mHCrossHair,OBJPROP_LEVELCOLOR,0, gClrPointer);
        ObjectSetInteger(0, mHCrossHair,OBJPROP_LEVELSTYLE,0, STYLE_DOT);
        ObjectSetInteger(0, mHCrossHair,OBJPROP_LEVELWIDTH,0, 1);

        // mWeekInfo
        ObjectCreate(mWeekInfo, OBJ_LABEL, 0, 0, 0);
        setTextContent(mWeekInfo, "", 10, FONT_BLOCK);
        ObjectSet(mWeekInfo, OBJPROP_SELECTABLE, false);
        ObjectSet(mWeekInfo, OBJPROP_COLOR, gClrPointer);
        ObjectSet(mWeekInfo, OBJPROP_YDISTANCE, CrossHair_DisplayDateInfo ? 25 : 15);
        ObjectSet(mWeekInfo, OBJPROP_CORNER , CORNER_LEFT_LOWER);
        ObjectSet(mWeekInfo, OBJPROP_ANCHOR , ANCHOR_LEFT_UPPER);
        ObjectSetString( 0, mWeekInfo, OBJPROP_TOOLTIP,"\n");

        // mDateInfo
        ObjectCreate(mDateInfo, OBJ_LABEL, 0, 0, 0);
        setTextContent(mDateInfo, "", 10, FONT_BLOCK);
        ObjectSet(mDateInfo, OBJPROP_SELECTABLE, false);
        ObjectSet(mDateInfo, OBJPROP_COLOR, gClrPointer);
        ObjectSet(mDateInfo, OBJPROP_YDISTANCE, CrossHair_DisplayDateInfo ? 15 : 0);
        ObjectSet(mDateInfo, OBJPROP_CORNER , CORNER_LEFT_LOWER);
        ObjectSet(mDateInfo, OBJPROP_ANCHOR , ANCHOR_LEFT_UPPER);
        ObjectSetString( 0, mDateInfo, OBJPROP_TOOLTIP,"\n");

    }
    void onMouseMove()
    {
        if (pCommonData.mOutBoundary) {
            ObjectSet(mHCrossHair, OBJPROP_PRICE1, 0);
            ObjectSet(mHCrossHair, OBJPROP_PRICE2, 0);
            ObjectSet(miHPriceBg , OBJPROP_YDISTANCE, 0);
            ObjectSet(mVCrossHair, OBJPROP_TIME1,  0);
            ObjectSet(miDtBkgnd, OBJPROP_XDISTANCE,0);
            ObjectSet(mWeekInfo, OBJPROP_XDISTANCE,0);
            ObjectSet(mDateInfo, OBJPROP_XDISTANCE,0);
            return;
        }
        // Horizontal: Đường kẻ ngang
        ObjectSet(mHCrossHair, OBJPROP_TIME1, pCommonData.mBeginTime);
        ObjectSet(mHCrossHair, OBJPROP_TIME2, pCommonData.mBeginTime);
        ObjectSet(mHCrossHair, OBJPROP_PRICE1, pCommonData.mMousePrice); // -> Price
        ObjectSet(mHCrossHair, OBJPROP_PRICE2, pCommonData.mMousePrice); // -> Price
        ObjectSetString(0, mHCrossHair,OBJPROP_LEVELTEXT ,0, DoubleToString(pCommonData.mMousePrice, Digits));
        ObjectSet(miHPriceBg , OBJPROP_YDISTANCE, pCommonData.mMouseY);
        // Vertical: Đường kẻ dọc
        ObjectSet(mVCrossHair, OBJPROP_PRICE1, ChartGetDouble(0,CHART_FIXED_MIN)-10);
        ObjectSet(mVCrossHair, OBJPROP_PRICE2, ChartGetDouble(0,CHART_FIXED_MAX)+10);
        ObjectSet(mVCrossHair, OBJPROP_TIME1,  pCommonData.mMouseTime);   //-> time
        
        // mWeekInfo and mDateInfo
        ObjectSet(miDtBkgnd, OBJPROP_XDISTANCE, pCommonData.mMouseX + 10);
        ObjectSet(mWeekInfo, OBJPROP_XDISTANCE, pCommonData.mMouseX + 10);
        ObjectSet(mDateInfo, OBJPROP_XDISTANCE, pCommonData.mMouseX + 10);
        setTextContent(mDateInfo, TimeToStr(pCommonData.mMouseTime, TIME_DATE));
        if (ChartPeriod() <= PERIOD_H4) {
            mStrTimeInfo = TimeToStr(pCommonData.mMouseTime + mOffsetTime*3600, TIME_MINUTES);
            mStrTimeInfo += " · " + getDayOfWeekStr(pCommonData.mMouseTime);
        }
        else if (ChartPeriod() <= PERIOD_D1) {
            mStrTimeInfo = getDayOfWeekStr(pCommonData.mMouseTime);
            mStrTimeInfo += "  ·  " + "W"+IntegerToString(getWeekOfYear(pCommonData.mMouseTime),2,'0');
        }
        else {
            mStrTimeInfo = "W"+IntegerToString(TimeDayOfYear(pCommonData.mMouseTime)/7,2,'0');
            mStrTimeInfo += " · " +IntegerToString(TimeYear(pCommonData.mMouseTime));
        }
        setTextContent(mWeekInfo, mStrTimeInfo);
    }
    void onObjectDeleted(const string& objectName)
    {
        if (objectName == miDtBkgnd || objectName == miHPriceBg) {
            initDrawing();
        }
    }
};