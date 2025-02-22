#include "../Home/CommonData.mqh"
#include "../Home/UtilityHeader.mqh"

class AskBid
{
private:
    string mObjAskLine;
    string mObjBidLine;
    string mObjCDBkgnd;
    string mObjCDTimer;

private:
    string  mStrTimer;
    int     mPosX, mPosY;
    int     mClock;
public:
    AskBid(){
        mStrTimer       = "";
        mObjAskLine     = "*1AskLine";
        mObjBidLine     = "*2BidLine";
        mObjCDBkgnd     = "*1CountDownBG";
        mObjCDTimer     = "*2CountDownTm";
        init();
    }
    void init(){
        ObjectCreate(mObjCDBkgnd, OBJ_LABEL, 0, 0, 0);
        ObjectSet(mObjCDBkgnd, OBJPROP_SELECTABLE, false);
        ObjectSetText(mObjCDBkgnd, "", 9, "Consolas");
        ObjectSet(mObjCDBkgnd, OBJPROP_COLOR, clrLightGray);
        ObjectSet(mObjCDBkgnd, OBJPROP_XDISTANCE, 1);
        ObjectSet(mObjCDBkgnd, OBJPROP_YDISTANCE, 0);
        ObjectSet(mObjCDBkgnd, OBJPROP_CORNER , CORNER_RIGHT_UPPER);
        ObjectSet(mObjCDBkgnd, OBJPROP_ANCHOR , ANCHOR_RIGHT);
        ObjectSetString(0 , mObjCDBkgnd, OBJPROP_TOOLTIP, "\n");
        //--------------------------------------------
        ObjectCreate(mObjCDTimer, OBJ_LABEL, 0, 0, 0);
        ObjectSetText(mObjCDTimer, "", 8, "Consolas");
        ObjectSet(mObjCDTimer, OBJPROP_SELECTABLE, false);
        ObjectSet(mObjCDTimer, OBJPROP_COLOR, clrBlack);
        ObjectSet(mObjCDTimer, OBJPROP_XDISTANCE, 1);
        ObjectSet(mObjCDTimer, OBJPROP_YDISTANCE, 0);
        ObjectSet(mObjCDTimer, OBJPROP_CORNER , CORNER_RIGHT_UPPER);
        ObjectSet(mObjCDTimer, OBJPROP_ANCHOR , ANCHOR_RIGHT);
        ObjectSetString(0 , mObjCDTimer, OBJPROP_TOOLTIP, "\n");
    //---
        ObjectCreate(mObjAskLine, OBJ_TREND, 0, 0, 0);
        ObjectCreate(mObjBidLine, OBJ_TREND, 0, 0, 0);
        ObjectSet(mObjBidLine, OBJPROP_BACK, true);
        ObjectSet(mObjBidLine, OBJPROP_SELECTABLE, false);
        ObjectSet(mObjBidLine, OBJPROP_RAY, true);
        ObjectSet(mObjBidLine, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet(mObjBidLine, OBJPROP_WIDTH, 0);
        ObjectSet(mObjBidLine, OBJPROP_COLOR, clrLightGray);
        ObjectSetString(0, mObjBidLine, OBJPROP_TOOLTIP, "\n");
        
        ObjectSet(mObjAskLine, OBJPROP_BACK, true);
        ObjectSet(mObjAskLine, OBJPROP_SELECTABLE, false);
        ObjectSet(mObjAskLine, OBJPROP_RAY, true);
        ObjectSet(mObjAskLine, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet(mObjAskLine, OBJPROP_WIDTH, 0);
        ObjectSet(mObjAskLine, OBJPROP_COLOR, clrRed);
        ObjectSetString(0, mObjAskLine, OBJPROP_TOOLTIP, "\n");
    //---
        ChartSetInteger(0, CHART_SHOW_ASK_LINE, false);
        ChartSetInteger(0, CHART_SHOW_BID_LINE, false);
    }
    void onTick(){
        mClock = (int)(Time[0] + Period()*60 - CurTime());
        loadTimer();
    }
    // Not implement yet:
    void onTimer(){
        mClock++;
        loadTimer();
    }
    void onChartChange(){
        updateLocation();
    }
    void loadTimer(){
        int min, sec;
        sec = mClock%60;
        min =(mClock - mClock%60) / 60;
        if (ChartPeriod() <= PERIOD_H1){
            ObjectSetText(mObjCDBkgnd, "█████");
            mStrTimer = IntegerToString(min,2,'0') + ":" + IntegerToString(sec,2,'0');
        }
        else if (ChartPeriod() <= PERIOD_H4){
            ObjectSetText(mObjCDBkgnd, "█████");
            int hour = 0;
            if (min >= 60) {
                hour = min/60;
                min = min - hour*60;
            }
            mStrTimer = IntegerToString(hour) +"h:"+IntegerToString(min,2,'0');
        }
        ObjectSetText(mObjCDTimer, mStrTimer);
    }
    
    void updateLocation(){
        ChartTimePriceToXY(0, 0, Time[0], Bid, mPosX, mPosY);
        ObjectSet(mObjCDBkgnd, OBJPROP_YDISTANCE, mPosY);
        ObjectSet(mObjCDTimer, OBJPROP_YDISTANCE, mPosY);
        
        ObjectSet(mObjBidLine, OBJPROP_PRICE1, Bid);
        ObjectSet(mObjBidLine, OBJPROP_PRICE2, Bid);
        ObjectSet(mObjBidLine, OBJPROP_TIME1, Time[0]);
        ObjectSet(mObjBidLine, OBJPROP_TIME2, Time[0] + Period()*300);
        
        ObjectSet(mObjAskLine, OBJPROP_PRICE1, Ask);
        ObjectSet(mObjAskLine, OBJPROP_PRICE2, Ask);
        ObjectSet(mObjAskLine, OBJPROP_TIME1, Time[0]);
        ObjectSet(mObjAskLine, OBJPROP_TIME2, Time[0] + Period()*300);
    }
};