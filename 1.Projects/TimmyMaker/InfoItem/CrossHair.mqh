#include "../Home/CommonData.mqh"
#include "../Home/UtilityHeader.mqh"
input string CrossHair_; // ●  C R O S S   H A I R  ●
      int    CrossHair_LocalTimeZone   = 7;
input bool   CrossHair_DisplayDateInfo = true; // Date Info

class CrossHair
{
private:
    CommonData* pCommonData;
    string mVCrossHair;
    string mHCrossHair;
    string mInfoBkgn;
    string mWeekInfo;
    string mDateInfo;
    uint mTimeOffset;
    bool mIsHided;
    bool mHideState;
public:
    CrossHair(CommonData* commonData)
    {
        mVCrossHair = "." + TAG_STATIC + "VCrossHair";
        mHCrossHair = "." + TAG_STATIC + "HCrossHair";
        mInfoBkgn   = "." + TAG_STATIC + "iInfoBkgn";
        mWeekInfo   = "." + TAG_STATIC + "zWeekInfo";
        mDateInfo   = "." + TAG_STATIC + "zDateInfo";
        pCommonData = commonData;

        if (ChartPeriod() == PERIOD_MN1) mTimeOffset = ChartPeriod()*60*100;
        else mTimeOffset = 120000*ChartPeriod();

        initDrawing();
        mIsHided = false;
    }
    void initDrawing()
    {
        ObjectCreate(mVCrossHair, OBJ_RECTANGLE, 0, 0, 0);
        setObjectStyle(mVCrossHair, gClrPointer, STYLE_DOT, 0);
        ObjectSet(mVCrossHair, OBJPROP_SELECTABLE, false);
        ObjectSet(mVCrossHair, OBJPROP_TIME2, 0);

        ObjectCreate(mHCrossHair, OBJ_FIBO, 0, 0, 0);
        ObjectSet(mHCrossHair, OBJPROP_RAY  , true);
        ObjectSet(mHCrossHair, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, mHCrossHair,OBJPROP_LEVELS, 1);
        ObjectSetDouble (0, mHCrossHair,OBJPROP_LEVELVALUE,0, 0);
        ObjectSetInteger(0, mHCrossHair,OBJPROP_LEVELCOLOR,0, gClrPointer);
        ObjectSetInteger(0, mHCrossHair,OBJPROP_LEVELSTYLE,0, STYLE_DOT);
        ObjectSetInteger(0, mHCrossHair,OBJPROP_LEVELWIDTH,0, 1);

        // --- Info background ---
        ObjectCreate(mInfoBkgn, OBJ_LABEL, 0, 0, 0);
        setTextContent(mInfoBkgn, "█████", 20, FONT_BLOCK);
        ObjectSet(mInfoBkgn, OBJPROP_SELECTABLE, false);
        ObjectSet(mInfoBkgn, OBJPROP_COLOR, clrWhite);
        ObjectSet(mInfoBkgn, OBJPROP_YDISTANCE, CrossHair_DisplayDateInfo ? 25 : 15);
        ObjectSetInteger(0, mInfoBkgn, OBJPROP_CORNER , CORNER_LEFT_LOWER);
        ObjectSetString( 0, mInfoBkgn, OBJPROP_TOOLTIP,"\n");
        // mWeekInfo
        ObjectCreate(mWeekInfo, OBJ_LABEL, 0, 0, 0);
        setTextContent(mWeekInfo, "", 10, FONT_BLOCK);
        ObjectSet(mWeekInfo, OBJPROP_SELECTABLE, false);
        ObjectSet(mWeekInfo, OBJPROP_COLOR, gClrPointer);
        ObjectSet(mWeekInfo, OBJPROP_YDISTANCE, CrossHair_DisplayDateInfo ? 25 : 15);
        ObjectSetInteger(0, mWeekInfo, OBJPROP_CORNER , CORNER_LEFT_LOWER);
        ObjectSetString( 0, mWeekInfo, OBJPROP_TOOLTIP,"\n");

        // mDateInfo
        ObjectCreate(mDateInfo, OBJ_LABEL, 0, 0, 0);
        setTextContent(mDateInfo, "", 10, FONT_BLOCK);
        ObjectSet(mDateInfo, OBJPROP_SELECTABLE, false);
        ObjectSet(mDateInfo, OBJPROP_COLOR, gClrPointer);
        ObjectSet(mDateInfo, OBJPROP_YDISTANCE, CrossHair_DisplayDateInfo ? 15 : 0);
        ObjectSetInteger(0, mDateInfo, OBJPROP_CORNER , CORNER_LEFT_LOWER);
        ObjectSetString( 0, mDateInfo, OBJPROP_TOOLTIP,"\n");

    }
    void onMouseMove()
    {
        mHideState = (pCommonData.mMouseX > ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0) || pCommonData.mMouseY > ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0));
        
        if (mIsHided == true) {
            if (mHideState == true) return;
            mIsHided = false;
            ObjectSet(mInfoBkgn, OBJPROP_COLOR, clrWhite);
            setMultiProp(OBJPROP_COLOR, gClrPointer, mDateInfo + mWeekInfo
                                                + mVCrossHair + mHCrossHair);
        }
        else {
            if (mHideState == true) {
                mIsHided = true;
                setMultiProp(OBJPROP_COLOR, clrNONE, mDateInfo + mWeekInfo
                                            + mVCrossHair + mHCrossHair + mInfoBkgn);
                return;
            }
        }
        ObjectSet(mHCrossHair, OBJPROP_TIME1, pCommonData.mBeginTime);
        ObjectSet(mHCrossHair, OBJPROP_TIME2, pCommonData.mBeginTime);
        ObjectSet(mHCrossHair, OBJPROP_PRICE1, pCommonData.mMousePrice); // -> Price
        ObjectSet(mHCrossHair, OBJPROP_PRICE2, pCommonData.mMousePrice); // -> Price
        
        ObjectSetString(0, mHCrossHair,OBJPROP_LEVELTEXT ,0, DoubleToString(pCommonData.mMousePrice, Digits));

        ObjectSet(mVCrossHair, OBJPROP_PRICE1, ChartGetDouble(ChartID(),CHART_FIXED_MIN)-10);
        ObjectSet(mVCrossHair, OBJPROP_PRICE2, ChartGetDouble(ChartID(),CHART_FIXED_MAX)+10);

        ObjectSet(mVCrossHair, OBJPROP_TIME1,  pCommonData.mMouseTime);   //-> time
        
        // mWeekInfo and mDateInfo
        ObjectSet(mInfoBkgn, OBJPROP_XDISTANCE, pCommonData.mMouseX + 10);
        ObjectSet(mWeekInfo, OBJPROP_XDISTANCE, pCommonData.mMouseX + 10);
        ObjectSet(mDateInfo, OBJPROP_XDISTANCE, pCommonData.mMouseX + 10);
        setTextContent(mDateInfo, TimeToStr(pCommonData.mMouseTime, TIME_DATE));
        if (ChartPeriod() <= PERIOD_H4)
        {
            setTextContent(mWeekInfo,
                            TimeToStr(pCommonData.mMouseTime + CrossHair_LocalTimeZone*3600, TIME_MINUTES)
                            + " · " + getDayOfWeekStr(pCommonData.mMouseTime));
        }
        else if (ChartPeriod() <= PERIOD_D1) setTextContent(mWeekInfo, getDayOfWeekStr(pCommonData.mMouseTime) + "  ·  " + "W"+IntegerToString(getWeekOfYear(pCommonData.mMouseTime),2,'0'));
        else setTextContent(mWeekInfo, "W"+IntegerToString(TimeDayOfYear(pCommonData.mMouseTime)/7,2,'0') + " · " +IntegerToString(TimeYear(pCommonData.mMouseTime)));

    }
    void onObjectDeleted(const string& objectName)
    {
        if (objectName == mVCrossHair || objectName == mHCrossHair)
        {
            initDrawing();
        }
    }
};