#include "../CommonData.mqh"
#include "../Utility.mqh"

input color CrossHair_Color = clrDarkSlateGray;

class CrossHair
{
private:
    CommonData* pCommonData;
    string mVCrossHair;
    string mHCrossHair;
    string mWeekInfo;
    string mDateInfo;
    uint mTimeOffset;
    bool mIsHide;
    bool mHideState;
public:
    CrossHair(CommonData* commonData)
    {
        mVCrossHair = STATIC_TAG + "VCrossHair";
        mHCrossHair = STATIC_TAG + "HCrossHair";
        mWeekInfo   = STATIC_TAG + "mWeekInfo";
        mDateInfo   = STATIC_TAG + "mDateInfo";
        pCommonData = commonData;

        if (ChartPeriod() == PERIOD_MN1) mTimeOffset = ChartPeriod()*60*100;
        else mTimeOffset = 120000*ChartPeriod();

        initDrawing();
        mIsHide = false;
    }
    void initDrawing()
    {
        ObjectCreate(mVCrossHair, OBJ_RECTANGLE, 0, 0, 0);
        ObjectCreate(mHCrossHair, OBJ_RECTANGLE, 0, 0, 0);
        SetObjectStyle(mVCrossHair, CrossHair_Color, STYLE_DOT, 0);
        SetObjectStyle(mHCrossHair, CrossHair_Color, STYLE_DOT, 0);
        ObjectSet(mVCrossHair, OBJPROP_SELECTABLE, false);
        ObjectSet(mHCrossHair, OBJPROP_SELECTABLE, false);

        ObjectSet(mVCrossHair, OBJPROP_TIME2, 0);
        
        ObjectSet(mHCrossHair, OBJPROP_TIME2, 0);
        ObjectSet(mHCrossHair, OBJPROP_PRICE2, 0);

        // mWeekInfo
        ObjectCreate(mWeekInfo, OBJ_LABEL, 0, 0, 0);
        ObjectSetText(mWeekInfo, "", 10, "Consolas");
        ObjectSet(mWeekInfo, OBJPROP_SELECTABLE, false);
        ObjectSet(mWeekInfo, OBJPROP_COLOR, CrossHair_Color);
        ObjectSet(mWeekInfo, OBJPROP_YDISTANCE, 30);
        ObjectSetInteger(0, mWeekInfo, OBJPROP_CORNER , CORNER_LEFT_LOWER);
        ObjectSetString( 0, mWeekInfo, OBJPROP_TOOLTIP,"\n");

        // mDateInfo
        ObjectCreate(mDateInfo, OBJ_LABEL, 0, 0, 0);
        ObjectSetText(mDateInfo, "", 10, "Consolas");
        ObjectSet(mDateInfo, OBJPROP_SELECTABLE, false);
        ObjectSet(mDateInfo, OBJPROP_COLOR, CrossHair_Color);
        ObjectSet(mDateInfo, OBJPROP_YDISTANCE, 20);
        ObjectSetInteger(0, mDateInfo, OBJPROP_CORNER , CORNER_LEFT_LOWER);
        ObjectSetString( 0, mDateInfo, OBJPROP_TOOLTIP,"\n");
    }
    void onMouseMove()
    {
        mHideState = (pCommonData.mMouseX > ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0) || pCommonData.mMouseY > ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0));
        
        if (mIsHide == true)
        {
            if (mHideState == true)
            {
                return;
            }
            mIsHide = false;
            ObjectSet(mDateInfo,   OBJPROP_COLOR, CrossHair_Color);
            ObjectSet(mWeekInfo,   OBJPROP_COLOR, CrossHair_Color);
            ObjectSet(mVCrossHair, OBJPROP_COLOR, CrossHair_Color);
            ObjectSet(mHCrossHair, OBJPROP_COLOR, CrossHair_Color);
        }
        else
        {
            if (mHideState == true)
            {
                mIsHide = true;
                ObjectSet(mDateInfo,   OBJPROP_COLOR, clrNONE);
                ObjectSet(mWeekInfo,   OBJPROP_COLOR, clrNONE);
                ObjectSet(mVCrossHair, OBJPROP_COLOR, clrNONE);
                ObjectSet(mHCrossHair, OBJPROP_COLOR, clrNONE);
                return;
            }
        }
        

        ObjectSet(mHCrossHair, OBJPROP_TIME1, pCommonData.mMouseTime + mTimeOffset);
        ObjectSet(mHCrossHair, OBJPROP_TIME2, pCommonData.mMouseTime - mTimeOffset);

        ObjectSet(mVCrossHair, OBJPROP_PRICE1, ChartGetDouble(ChartID(),CHART_FIXED_MIN)-10);
        ObjectSet(mVCrossHair, OBJPROP_PRICE2, ChartGetDouble(ChartID(),CHART_FIXED_MAX)+10);

        ObjectSet(mHCrossHair, OBJPROP_PRICE1, pCommonData.mMousePrice);
        ObjectSet(mVCrossHair, OBJPROP_TIME1, pCommonData.mMouseTime);

        
        // mWeekInfo and mDateInfo
        ObjectSet(mWeekInfo, OBJPROP_XDISTANCE, pCommonData.mMouseX + 10);
        ObjectSet(mDateInfo, OBJPROP_XDISTANCE, pCommonData.mMouseX + 10);
        ObjectSetText(mDateInfo, TimeToStr(pCommonData.mMouseTime, TIME_DATE));
        if (ChartPeriod() <= PERIOD_H4) ObjectSetText(mWeekInfo, TimeToStr(pCommonData.mMouseTime, TIME_MINUTES) + " · " + strDayOfWeek(pCommonData.mMouseTime));
        else if (ChartPeriod() <= PERIOD_D1) ObjectSetText(mWeekInfo, strDayOfWeek(pCommonData.mMouseTime) + "  ·  " + "W"+IntegerToString(TimeDayOfYear(pCommonData.mMouseTime)/7,2,'0'));
        else ObjectSetText(mWeekInfo, "W"+IntegerToString(TimeDayOfYear(pCommonData.mMouseTime)/7,2,'0') + " · " +IntegerToString(TimeYear(pCommonData.mMouseTime)));
    }
    void onObjectDeleted(const string& objectName)
    {
        if (objectName == mVCrossHair || objectName == mHCrossHair)
        {
            initDrawing();
        }
    }
};