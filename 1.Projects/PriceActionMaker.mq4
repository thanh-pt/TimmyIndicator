#property version   "1.00"
#property copyright "Timmy"
#property link "https://www.mql5.com/en/users/thanh01"
#property icon "T-black.ico"
#property description "Price Action Maker allows you to:\r\n- Mark up and Navigation on the Charts\r\n- Execute Trades\r\n- Sent Notification"

// #define EA
#define LSTYLE ENUM_LINE_STYLE


/// INFO ITEM ///
class InfoItems {
    private:
    string m_objHorizontalLine;
    string m_objVerticalLine;
    string m_objMouseInfo;
    string m_objOptionInfo;
    string m_objDTimeInfo;
    string m_objAsk;
    string m_objBid;

    bool   mCrossHairOn;
    string mStrTimer;
    string mStrDTimeInfo;

    public:
        InfoItems() {
            mCrossHairOn = true;

            m_objMouseInfo = "InfoItems_MouseInfo_" + Commons::TagStatic;
            m_objOptionInfo = "InfoItems_OptionInfo_" + Commons::TagStatic;
            m_objDTimeInfo = "InfoItems_DTimeInfo_" + Commons::TagStatic;
            m_objHorizontalLine = "InfoItems_HorizontalLine_" + Commons::TagStatic;
            m_objVerticalLine = "InfoItems_VerticalLine_" + Commons::TagStatic;
            m_objAsk = "InfoItems_objAsk_" + Commons::TagStatic;
            m_objBid = "InfoItems_objBid_" + Commons::TagStatic;

            ChartSetInteger(0, CHART_SHOW_ASK_LINE, false);
            ChartSetInteger(0, CHART_SHOW_BID_LINE, false);
            ChartSetInteger(0, CHART_SHOW_LAST_LINE, false);
            Create();
        }
    void Create() {
        // Tạo Fibonacci Retracement
        ObjectCreate(0, m_objHorizontalLine, OBJ_FIBO, 0, 0, Commons::MousePrice, 0, Commons::MousePrice);
        ObjectSetInteger(0, m_objHorizontalLine, OBJPROP_COLOR, clrNONE);
        ObjectSetInteger(0, m_objHorizontalLine, OBJPROP_RAY_RIGHT, true);
        ObjectSetInteger(0, m_objHorizontalLine, OBJPROP_BACK, true);
        ObjectSetInteger(0, m_objHorizontalLine, OBJPROP_LEVELS, 1);
        ObjectSetInteger(0, m_objHorizontalLine, OBJPROP_LEVELSTYLE, 0, STYLE_DOT);
        ObjectSetInteger(0, m_objHorizontalLine, OBJPROP_LEVELWIDTH, 0, 1);
        ObjectSetInteger(0, m_objHorizontalLine, OBJPROP_LEVELCOLOR, 0, clrMidnightBlue);
        ObjectSetDouble(0, m_objHorizontalLine, OBJPROP_LEVELVALUE, 0, 1);
        ObjectSetString(0, m_objHorizontalLine, OBJPROP_LEVELTEXT, 0, DoubleToString(Commons::MousePrice, _Digits));
        ObjectMove(0, m_objHorizontalLine, 1, 0, Commons::MousePrice);

        // Tạo Fibonacci Time Zone
        ObjectCreate(0, m_objVerticalLine, OBJ_FIBOTIMES, 0, Commons::MouseTime, 0);
        ObjectSetInteger(0, m_objVerticalLine, OBJPROP_COLOR, clrNONE);
        ObjectSetInteger(0, m_objVerticalLine, OBJPROP_BACK, true);
        ObjectSetInteger(0, m_objVerticalLine, OBJPROP_LEVELS, 1);
        ObjectSetInteger(0, m_objVerticalLine, OBJPROP_LEVELSTYLE, 0, STYLE_DOT);
        ObjectSetInteger(0, m_objVerticalLine, OBJPROP_LEVELWIDTH, 0, 1);
        ObjectSetInteger(0, m_objVerticalLine, OBJPROP_LEVELCOLOR, 0, clrMidnightBlue);
        ObjectSetDouble(0, m_objVerticalLine, OBJPROP_LEVELVALUE, 0, 0);
        ObjectSetString(0, m_objVerticalLine, OBJPROP_LEVELTEXT, 0, "");
        ObjectMove(0, m_objVerticalLine, 1, Commons::MouseTime, 0);

        // Create Mouse Info
        ObjectCreate(0, m_objMouseInfo, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_objMouseInfo, OBJPROP_COLOR, clrMidnightBlue);
        ObjectSetInteger(0, m_objMouseInfo, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        ObjectSetInteger(0, m_objMouseInfo, OBJPROP_FONTSIZE, 10);
        ObjectSetString(0, m_objMouseInfo, OBJPROP_FONT, "Consolas");
        ObjectSetString(0, m_objMouseInfo, OBJPROP_TEXT, Commons::StringEmpty);
        // Create Option Info
        ObjectCreate(0, m_objOptionInfo, OBJ_LABEL, 0, 0, 0, 0, 0);
        ObjectSetInteger(0, m_objOptionInfo, OBJPROP_COLOR, clrMidnightBlue);
        ObjectSetInteger(0, m_objOptionInfo, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
        ObjectSetInteger(0, m_objOptionInfo, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
        ObjectSetInteger(0, m_objOptionInfo, OBJPROP_FONTSIZE, 10);
        ObjectSetString(0, m_objOptionInfo, OBJPROP_FONT, "Consolas");
        ObjectSetString(0, m_objOptionInfo, OBJPROP_TEXT, Commons::StringEmpty);
        ObjectSetInteger(0, m_objOptionInfo, OBJPROP_XDISTANCE, 0);
        ObjectSetInteger(0, m_objOptionInfo, OBJPROP_YDISTANCE, 0);
        // Create DateTime Info
        ObjectCreate(0, m_objDTimeInfo, OBJ_LABEL, 0, 0, 0, 0, 0);
        ObjectSetInteger(0, m_objDTimeInfo, OBJPROP_COLOR, clrMidnightBlue);
        ObjectSetInteger(0, m_objDTimeInfo, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        ObjectSetInteger(0, m_objDTimeInfo, OBJPROP_CORNER, CORNER_LEFT_LOWER);
        ObjectSetInteger(0, m_objDTimeInfo, OBJPROP_FONTSIZE, 10);
        ObjectSetInteger(0, m_objDTimeInfo, OBJPROP_YDISTANCE, 0);
        ObjectSetString(0, m_objDTimeInfo, OBJPROP_FONT, "Consolas");
        ObjectSetString(0, m_objDTimeInfo, OBJPROP_TEXT, 0, "12:23 · T2");
        
        // Create Ask
        ObjectCreate(0, m_objAsk, OBJ_FIBO, 0, iTime(_Symbol, _Period, 0), Commons::Ask, iTime(_Symbol, _Period, 0), Commons::Ask);
        ObjectSetInteger(0, m_objAsk, OBJPROP_COLOR, clrNONE);
        ObjectSetInteger(0, m_objAsk, OBJPROP_RAY_RIGHT, true);
        ObjectSetInteger(0, m_objAsk, OBJPROP_BACK, true);
        ObjectSetInteger(0, m_objAsk, OBJPROP_LEVELS, 1);
        ObjectSetInteger(0, m_objAsk, OBJPROP_LEVELSTYLE, 0, STYLE_SOLID);
        ObjectSetDouble(0, m_objAsk, OBJPROP_LEVELVALUE, 0, 0);
        ObjectSetInteger(0, m_objAsk, OBJPROP_LEVELWIDTH, 0, 1);
        ObjectSetInteger(0, m_objAsk, OBJPROP_LEVELCOLOR, 0, clrRed);
        ObjectSetString(0, m_objAsk, OBJPROP_LEVELTEXT, 0, "");
        ObjectCreate(0, m_objBid, OBJ_FIBO, 0, iTime(_Symbol, _Period, 0), Commons::Bid, iTime(_Symbol, _Period, 0), Commons::Bid);
        ObjectSetInteger(0, m_objBid, OBJPROP_COLOR, clrNONE);
        ObjectSetInteger(0, m_objBid, OBJPROP_RAY_RIGHT, true);
        ObjectSetInteger(0, m_objBid, OBJPROP_BACK, true);
        ObjectSetInteger(0, m_objBid, OBJPROP_LEVELS, 1);
        ObjectSetInteger(0, m_objBid, OBJPROP_LEVELSTYLE, 0, STYLE_SOLID);
        ObjectSetDouble(0, m_objBid, OBJPROP_LEVELVALUE, 0, 0);
        ObjectSetInteger(0, m_objBid, OBJPROP_LEVELWIDTH, 0, 1);
        ObjectSetInteger(0, m_objBid, OBJPROP_LEVELCOLOR, 0, clrMidnightBlue);
        ObjectSetString(0, m_objBid, OBJPROP_LEVELTEXT, 0, "");
    }
    void Update() {
        if (mCrossHairOn == true || Commons::CtrlHeld) {
            // Location
            ObjectMove(0, m_objHorizontalLine, 0, 0, Commons::MousePrice);
            ObjectMove(0, m_objVerticalLine, 0, Commons::MouseTime, 0);
            ObjectSetInteger(0, m_objDTimeInfo, OBJPROP_XDISTANCE, Commons::MouseX + 5);
            // Info
            mStrDTimeInfo = TimeToString(Commons::MouseTimeLocal, TIME_MINUTES) + " · T" + IntegerToString((Commons::MouseTimeLocal/86400+4) % 7 + 1);
            ObjectSetString(0, m_objDTimeInfo, OBJPROP_TEXT, 0, mStrDTimeInfo);
            ObjectSetString(0, m_objHorizontalLine, OBJPROP_LEVELTEXT, 0, DoubleToString(Commons::MousePrice, _Digits));
        }
        else {
            ObjectMove(0, m_objHorizontalLine, 0, 0, 0);
            ObjectMove(0, m_objHorizontalLine, 1, 0, 0);
            ObjectMove(0, m_objVerticalLine, 0, 0, 0);
            ObjectMove(0, m_objVerticalLine, 1, 0, 0);
            ObjectSetInteger(0, m_objDTimeInfo, OBJPROP_XDISTANCE, -100);
        }
        ObjectSetInteger(0, m_objMouseInfo, OBJPROP_XDISTANCE, Commons::MouseX + 20);
        ObjectSetInteger(0, m_objMouseInfo, OBJPROP_YDISTANCE, Commons::MouseY);
        ChartRedraw();
    }
    void toggleCrossHair(){
        mCrossHairOn = !mCrossHairOn;
        Update();
    }
    void showMouseInfo(string text) {
        if (text == "") text = Commons::StringEmpty;
        ObjectSetString(0, m_objMouseInfo, OBJPROP_TEXT, text);
        ChartRedraw();
    }
    void showOptionInfo(string text) {
        if (text == "") text = Commons::StringEmpty;
        ObjectSetString(0, m_objOptionInfo, OBJPROP_TEXT, text);
        ChartRedraw();
    }
    void onTick() {
        datetime time0 = iTime(_Symbol, _Period, 0);
        ObjectMove(0, m_objAsk, 0, time0, Commons::Ask);
        ObjectMove(0, m_objAsk, 1, time0, Commons::Ask);
        ObjectMove(0, m_objBid, 0, time0, Commons::Bid);
        ObjectMove(0, m_objBid, 1, time0, Commons::Bid);
        int min, sec;
        min = (int)(time0 + PeriodSeconds(_Period) - TimeCurrent());
        sec = min%60;
        min =(min - min%60) / 60;
        mStrTimer = "";
        if (ChartPeriod() <= PERIOD_H1){
            mStrTimer = IntegerToString(min,2,'0') + ":" + IntegerToString(sec,2,'0');
        }
        else if (ChartPeriod() < PERIOD_D1){
            int hour = 0;
            if (min >= 60) {
                hour = min/60;
                min = min - hour*60;
            }
            mStrTimer = IntegerToString(hour) +"h:"+IntegerToString(min,2,'0');
        }
        ObjectSetString(0, m_objBid, OBJPROP_LEVELTEXT, 0, mStrTimer);
    }
};

/// COMMON ITEM ///
class Commons {
    public:
    static double Ask;
    static double Bid;
    static int MouseX;
    static int MouseY;
    static double MousePrice;
    static datetime MouseTime;
    static datetime MouseTimeLocal;
    static int SubWindow;
    static bool CtrlHeld;
    static bool ShiftHeld;
    static string TagStatic;

    static string StringEmpty;
    static string StringUnderLine;

    static void UpdateAskBid(){
        Bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
        Ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
    }

    static void UpdateMousePosition(const long & lparam,
                                    const double & dparam,
                                    const string & sparam) {
        int option = (int) StringToInteger(sparam);
        MouseX = (int) lparam;
        MouseY = (int) dparam;
        ChartXYToTimePrice(0, MouseX, MouseY, SubWindow, MouseTime, MousePrice);
        int barIndex = iBarShift(_Symbol, 0, MouseTime, true);
        if (barIndex != -1) {
            MouseTime = iTime(_Symbol, PERIOD_CURRENT, barIndex);
            ChartTimePriceToXY(0, SubWindow, MouseTime, MousePrice, MouseX, MouseY);
        }
        MouseTimeLocal = MouseTime + 18000; // Fixed Time zone!

        // update fixed position
        long chartWidth = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
        ChartSetDouble(0, CHART_FIXED_POSITION, (double) MouseX / chartWidth * 100);

        // Cập nhật trạng thái phím Ctrl và Shift
        CtrlHeld = (option & 8) != 0;
        ShiftHeld = (option & 4) != 0;

        // Nếu Ctrl được giữ, lấy giá Open, High, Low, Close của cây nến
        if (CtrlHeld && barIndex != -1) {
            double open = iOpen(_Symbol, PERIOD_CURRENT, barIndex);
            double high = iHigh(_Symbol, PERIOD_CURRENT, barIndex);
            double low = iLow(_Symbol, PERIOD_CURRENT, barIndex);
            double close = iClose(_Symbol, PERIOD_CURRENT, barIndex);
            if (MousePrice >= high)
                MousePrice = high;
            else if (MousePrice <= low)
                MousePrice = low;
            else if (MathAbs(MousePrice - open) < MathAbs(MousePrice - close)) {
                MousePrice = open;
            }
            else {
                MousePrice = close;
            }
        }
    }
    static void UnselectAll() {
        int objTotal = ObjectsTotal(0, -1);
        string objName = "";
        for (int i = 0; i < objTotal; i++) {
            objName = ObjectName(0, i);
            ObjectSetInteger(0, objName, OBJPROP_SELECTED, false);
        }
        ChartRedraw();
    }
    static string GetStringUnderLine(int num) {
        return StringSubstr(StringUnderLine, 0, num);
    }
};

// Init Commons
double Commons::Ask = 0;
double Commons::Bid = 0;
int Commons::MouseX = 0;
int Commons::MouseY = 0;
int Commons::SubWindow = 0;
bool Commons::CtrlHeld = false;
bool Commons::ShiftHeld = false;
double Commons::MousePrice = 0;
datetime Commons::MouseTime = 0;
datetime Commons::MouseTimeLocal = 0;
string Commons::TagStatic = "Static";
string Commons::StringEmpty = "‎";
string Commons::StringUnderLine = "_______________________________________________________________";

class QuickHotkey {
   private:
    bool    mbEraseOn;
    int     mUpperTF;
    int     mLowerTF;

    char    mErase_Hotkey           ;
    char    mDelete_Hotkey          ;
    char    mTimeFrameMoving_Hotkey ;
    char    mToggleTradeLever_Hotkey;
    char    mToggleScalePanel_Hotkey;
    char    mToggleCrossHair_Hotkey ;
   public:
   QuickHotkey(){
        mbEraseOn = false;
    }
    void onInit() {
        mErase_Hotkey           = (char) InpErase_Hotkey[0];
        mDelete_Hotkey          = (char) InpDelete_Hotkey[0];
        mTimeFrameMoving_Hotkey = (char) InpTimeFrameMoving_Hotkey[0];
        mToggleTradeLever_Hotkey= (char) InpToggleTradeLever_Hotkey[0];
        mToggleScalePanel_Hotkey= (char) InpToggleScalePanel_Hotkey[0];
        mToggleCrossHair_Hotkey = (char) InpToggleCrossHair_Hotkey[0];

        string tflist[];
        int tfnum;
        tfnum = StringSplit(InpTimeFrameList, ',', tflist);
        if (tfnum >= 2) {
            int tf;
            mLowerTF = stringToPeriod(tflist[0]);
            mUpperTF = stringToPeriod(tflist[tfnum-1]);
            for (int i = 0; i < tfnum; i++) {
                tf = stringToPeriod(tflist[i]);
                if (tf == _Period) {
                    if (i > 0) mLowerTF = stringToPeriod(tflist[i-1]);
                    if (i < tfnum-1) mUpperTF = stringToPeriod(tflist[i+1]);
                    break;
                }
            }
        }
        else {
            mUpperTF = _Period;
            mLowerTF = _Period;
        }
    }
    int stringToPeriod(string strPeriod) {
        int tf = 0;
        if (StringFind(strPeriod, "H1") != -1){
            return PERIOD_H1;
        }
        else if (StringFind(strPeriod, "H4") != -1){
            return PERIOD_H4;
        }
        else if (StringFind(strPeriod, "D1") != -1){
            return PERIOD_D1;
        }
        else if (StringFind(strPeriod, "W1") != -1){
            return PERIOD_W1;
        }
        else if (StringFind(strPeriod, "MN1") != -1){
            return PERIOD_MN1;
        }
        else if (StringFind(strPeriod, "H") != -1){
            tf = 1 << 14;
            StringReplace(strPeriod, "H", "");
        }
        tf += (int)StringToInteger(strPeriod);
        return tf;
    }
    void handleKey(int key) {
        int i, objTotal;
        string objName;
        double chartMin;
        double chartMax;
        double scaleRange;
        if (mbEraseOn) {
            if (key == '1') {
                objTotal = ObjectsTotal(0, -1);
                objName = "";
                for (i = objTotal; i >= 0; i--) {
                    objName = ObjectName(0, i);
                    if (StringFind(objName, Commons::TagStatic) != -1) continue;
                    ObjectDelete(0, objName);
                }
                ChartRedraw();
            }
            else if (key == '2') {
                objTotal = ObjectsTotal(0, -1);
                objName = "";
                int curTf = _Period;
                for (i = objTotal; i >= 0; i--) {
                    objName = ObjectName(0, i);
                    if (StringFind(objName, Commons::TagStatic) != -1) continue;
                    if (curTf <= getObjTf(objName)) continue;
                    ObjectDelete(0, objName);
                }
                ChartRedraw();
            }
        }
        if (key == mErase_Hotkey) {
            mbEraseOn = true;
            infoItems.showMouseInfo("1.Erase all  2.Erease LTF");
            return;
        }
        else mbEraseOn = false;
        
        if (key == mToggleScalePanel_Hotkey) {// Show Hide Scroll bar
            bool bShow = ChartGetInteger(0, CHART_SHOW_PRICE_SCALE);
            ChartSetInteger(0, CHART_SHOW_PRICE_SCALE, !bShow);
            ChartSetInteger(0, CHART_SHOW_DATE_SCALE, !bShow);
        }
        else if (key == mToggleTradeLever_Hotkey) {
            bool bTradeLevels = (bool)ChartGetInteger(0, CHART_SHOW_TRADE_LEVELS);
            ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS, !bTradeLevels);
        }
        else if (key == mToggleCrossHair_Hotkey) {
            infoItems.toggleCrossHair();
        }
        else if (key == mTimeFrameMoving_Hotkey) {
            if (TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT) == -128) { // key press
                if (mUpperTF != _Period) ChartSetSymbolPeriod(0, _Symbol, (ENUM_TIMEFRAMES)mUpperTF);
            }
            else {
                if (mLowerTF != _Period) ChartSetSymbolPeriod(0, _Symbol, (ENUM_TIMEFRAMES)mLowerTF);
            }
        }
        else if (key == mDelete_Hotkey) {
            objTotal = ObjectsTotal(0, -1);
            objName = "";
            for (i = objTotal; i >= 0; i--) {
                objName = ObjectName(0, i);
                if ((bool)ObjectGetInteger(0, objName, OBJPROP_SELECTED) == false) continue;
                ObjectDelete(0, objName);
            }
            ChartRedraw();
        }
        else if (key == 188) { //','
            ChartSetInteger(0, CHART_SCALEFIX, 0, 1);
            chartMin     = ChartGetDouble(0,CHART_FIXED_MIN);
            chartMax     = ChartGetDouble(0,CHART_FIXED_MAX);
            scaleRange   = (chartMax - chartMin) / 15;
            chartMax = chartMax - scaleRange;
            chartMin = chartMin + scaleRange;
            ChartSetDouble(0,CHART_FIXED_MAX,chartMax);
            ChartSetDouble(0,CHART_FIXED_MIN,chartMin);
        }
        else if (key == 190) { //'.'
            ChartSetInteger(0, CHART_SCALEFIX, 0, 1);
            chartMin     = ChartGetDouble(0,CHART_FIXED_MIN);
            chartMax     = ChartGetDouble(0,CHART_FIXED_MAX);
            scaleRange   = (chartMax - chartMin) / 15;
            chartMax = chartMax + scaleRange;
            chartMin = chartMin - scaleRange;
            ChartSetDouble(0,CHART_FIXED_MAX,chartMax);
            ChartSetDouble(0,CHART_FIXED_MIN,chartMin);
        }
        else if (key == 191) { // '/'
            int firstBar = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
            if (firstBar == -1) return;
            int barCount = (int)ChartGetInteger(0, CHART_VISIBLE_BARS);
            double highest = iHigh(_Symbol, _Period, firstBar);
            double high = iHigh(_Symbol, _Period, firstBar);
            double lowest = iLow(_Symbol, _Period, firstBar);
            double low = iLow(_Symbol, _Period, firstBar);
            for (i = firstBar; i > firstBar-barCount && i >= 0; i--){
                high = iHigh(_Symbol, _Period, i);
                low = iLow(_Symbol, _Period, i);
                if (high > highest) highest = high;
                if (low < lowest) lowest = low;
            }
            ChartSetDouble(0,CHART_FIXED_MAX,highest);
            ChartSetDouble(0,CHART_FIXED_MIN,lowest);
        }
        else {
            // Print("Key: ", key);
        }

        if (mbEraseOn == false) {
            infoItems.showMouseInfo("");
        }
    }
    private:
        // TODO: need another option!
        int getObjTf(string sparam) {
            // TimeKey + TF + TAG +  objName + Others
            // |______ObjId______|    |__CHILD Info__|
            string sparamItems[];
            int keynum = StringSplit(sparam, '_', sparamItems);
            if (keynum < 4) {
                return 0;
            }
            return (int)StringToInteger(sparamItems[1]);
        }
};

#define TYPELIMIT 10
/// IDrawingTool ///
class IDrawingTool {
    public:
        string Tag;
        char Hotkey;
        bool Creating;
        bool Editing;

    protected:
        string mObjId;
        int mPointIdx;
        int mPointLimit;
        int mType;
        int mTypeLimit;
        string mTypeNames[TYPELIMIT];
        // Variable List
        double price0;
        double price1;
        datetime time0;
        datetime time1;

    private:
        string m_objType;
        string mSparamItems[];
        int mKeyNum;

    // Internal Child Function
    protected:
        virtual void intTools(){};
        virtual void prepareObj() {};
        virtual bool createObj() {return false;};
        virtual void cancelObj() {};
        virtual void updateTypeObj() {};
        virtual void activeObj(bool state) {};
        virtual void refreshObj() {};
        virtual bool deleteObj(string sparam) {return true;};
        virtual void changeObj(string sparam) {};
        virtual void prepareData(string sparam) {};
        virtual void userAction(int key) {};

    // IDrawingTool public Function
    public:
        IDrawingTool() {
            Creating = false;
            mPointIdx = 0;
            mPointLimit = 0;
            mType = 0;
            mTypeLimit = 0;
        }
        void createNew() {
            Commons::UnselectAll();
            ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
            mObjId = IntegerToString(TimeLocal()) + "_" + IntegerToString(_Period) + "_" + Tag;
            m_objType = mObjId + "_objType";
            prepareObj();
            Creating = true;
            mPointIdx = 0;
        };
        void updateType() {
            mType++;
            if (mType >= mTypeLimit) {
                mType = 0;
                if (mTypeLimit == 0) return;
            }
            updateTypeObj();
            ChartRedraw();
        }
        void updateType(int type) {
            if (type >= mTypeLimit) {
                if (Editing) userAction(type);
                return;
            }
            mType = type;
            ObjectSetString(0, m_objType, OBJPROP_TEXT, IntegerToString(mType));
            updateTypeObj();
            ChartRedraw();
        }
        void cancelDraw() {
            if (Editing == true) Editing = false;
            cancelObj();
            if (Creating == true) {
                ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
                Creating = false;
            }
            ChartRedraw();
        }
        virtual string mouseInfo() {
            if (mTypeLimit == 0) return Tag;
            string strMouseInfo = "";
            for (int i = 0; i < mTypeLimit; i++) {
                if (mType == i) strMouseInfo += "(" + IntegerToString(i+1) + "." + mTypeNames[i] + ") ";
                else strMouseInfo += IntegerToString(i+1) + "." + mTypeNames[i] + " ";
            }
            return strMouseInfo;
        }
        virtual string optionInfo() {
            if (mTypeLimit == 0) return "";
            return mouseInfo();
        }

    // IDrawingTool protected Function
    protected:
        string getObjId(string sparam) {
            // TimeKey + TF + TAG +  objName + Others
            // |______ObjId______|    |__CHILD Info__|
            mKeyNum = StringSplit(sparam, '_', mSparamItems);
            if (mKeyNum < 4) {
                return "";
            }
            return mSparamItems[0] + "_" + mSparamItems[1] + "_" + mSparamItems[2];
        }
    // onEvent Handler
    public:
        void onInit() {intTools();}
        void onMouseClick() {
            if (Creating == false) return;
            if (mPointLimit == 0) {
                // For custom use purpose
                createObj();
                // out
                ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
                gpCurDrawingTool = NULL;
                Creating = false;
                return;
            }
            if (mPointLimit == 1) {
                time0 = Commons::MouseTime;
                price0 = Commons::MousePrice;
                time1 = Commons::MouseTime;
                price1 = Commons::MousePrice;
                if (createObj()) {
                    ObjectCreate(0, m_objType, OBJ_TEXT, 0, 0, 0);
                    ObjectSetString(0, m_objType, OBJPROP_TEXT, IntegerToString(mType));
                    ChartRedraw();
                }

                // out
                ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
                gpCurDrawingTool = NULL;
                Creating = false;
                return;
            }
            if (mPointIdx >= mPointLimit-1) {
                // out
                ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
                gpCurDrawingTool = NULL;
                Creating = false;
                return;
            }


            time0 = Commons::MouseTime;
            price0 = Commons::MousePrice;
            time1 = Commons::MouseTime;
            price1 = Commons::MousePrice;
            if (createObj() && mPointIdx == 0) {
                ObjectCreate(0, m_objType, OBJ_TEXT, 0, 0, 0);
                ObjectSetString(0, m_objType, OBJPROP_TEXT, IntegerToString(mType));
            }
            ChartRedraw();
            mPointIdx++;
        }
        void onMouseMove() {
            if (Creating == false) return;
            if (mPointIdx > 0) {
                time1 = Commons::MouseTime;
                price1 = Commons::MousePrice;
                if (Commons::ShiftHeld) price1 = price0;
                refreshObj();
                ChartRedraw();
            }
        }
        void onObjectTouch(string sparam) {
            bool selectable = ObjectGetInteger(0, sparam, OBJPROP_SELECTABLE);
            if (selectable == false) return;
            mObjId = getObjId(sparam);
            if (mObjId == "") {
                return;
            }
            m_objType = mObjId + "_objType";
            mType = (int) StringToInteger(ObjectGetString(0, m_objType, OBJPROP_TEXT));
            prepareObj();
            Editing = ObjectGetInteger(0, sparam, OBJPROP_SELECTED);
            if (Editing == true) Commons::UnselectAll();
            activeObj(Editing);
            prepareData(sparam);
            refreshObj();
            ChartRedraw();
        }
        void onObjectDelete(string sparam) {
            mObjId = getObjId(sparam);
            if (mObjId == "") {
                gpCurDrawingTool = NULL;
                return;
            }
            prepareObj();
            if (deleteObj(sparam) == true) {
                m_objType = mObjId + "_objType";
                ObjectDelete(0, m_objType);
            }
            ChartRedraw();
        }
        void onObjectChange(string sparam) {
            mObjId = getObjId(sparam);
            if (mObjId == "") {
                // gpCurDrawingTool = NULL;
                return;
            }
            m_objType = mObjId + "_objType";
            mType = (int) StringToInteger(ObjectGetString(0, m_objType, OBJPROP_TEXT));
            prepareObj();
            changeObj(sparam);
        }
        virtual void onTick() {}
};

/// Drawing TOOLS ///
//#include <Trade\Trade.mqh>
input string InpTrade = ""; // ===  T R A D E  ===
input string InpTrade_Hotkey = "W";
input double InpTradeCost = 100.0;  // Cost ($)
input double InpTradeComm = 7.0;    // Commission ($)
input double InpTradeSpread = 0.0;  // Spread (point)
input double InpTradeSlOpt = 2.0;   // SL Space
input double InpTradeTpOpt = 2.0;   // TP RRR

class Trade: public IDrawingTool {
    public:
    Trade(): IDrawingTool() {
        Tag = "Trade";
        Hotkey = 'W';
        mTypeLimit = 2;
        mPointLimit = 1;
        mTypeNames[0] = "Long";
        mTypeNames[1] = "Short";
    }
    private:
    void intTools() override {
        Hotkey = (char)InpTrade_Hotkey[0];
        mContractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
    }
    // Internal Child Function
    protected:
    string m_objLineTp;
    string m_objLineEn;
    string m_objLineSl;
    string m_objBgTp;
    string m_objBgSl;
    string m_objInfoTp;
    string m_objInfoEn;
    string m_objInfoSl;
    string m_objBack;


    double price2;
    datetime time2;
    double mContractSize;
    //CTrade mCTrade;

    void prepareObj() override {
        m_objBack   = mObjId + "_Back";
        m_objInfoTp = mObjId + "_InfoTp";
        m_objInfoEn = mObjId + "_InfoEn";
        m_objInfoSl = mObjId + "_InfoSl";
        m_objLineTp = mObjId + "_LineTp";
        m_objLineEn = mObjId + "_LineEn";
        m_objLineSl = mObjId + "_LineSl";
        m_objBgTp   = mObjId + "_BgTp";
        m_objBgSl   = mObjId + "_BgSl";
    };
    virtual bool createObj() override {
        // Create
        ObjectCreate(0, m_objInfoTp, OBJ_TEXT, 0, time0, price0);
        ObjectCreate(0, m_objInfoEn, OBJ_TEXT, 0, time0, price0);
        ObjectCreate(0, m_objInfoSl, OBJ_TEXT, 0, time0, price0);
        ObjectCreate(0, m_objBgTp, OBJ_RECTANGLE, 0, time0, price0, time1, price1);
        ObjectCreate(0, m_objBgSl, OBJ_RECTANGLE, 0, time0, price0, time1, price1);
        ObjectCreate(0, m_objLineTp, OBJ_TREND, 0, time0, price0, time1, price1);
        ObjectCreate(0, m_objLineEn, OBJ_TREND, 0, time0, price0, time1, price1);
        ObjectCreate(0, m_objLineSl, OBJ_TREND, 0, time0, price0, time1, price1);
        ObjectCreate(0, m_objBack, OBJ_RECTANGLE, 0, time0, price0, time1, price1);
        
        // Text Info
        ObjectSetInteger(0, m_objInfoEn, OBJPROP_ANCHOR, ANCHOR_LOWER);
        ObjectSetInteger(0, m_objInfoTp, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, m_objInfoEn, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, m_objInfoSl, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, m_objInfoTp, OBJPROP_COLOR, clrMidnightBlue);
        ObjectSetInteger(0, m_objInfoEn, OBJPROP_COLOR, clrMidnightBlue);
        ObjectSetInteger(0, m_objInfoSl, OBJPROP_COLOR, clrMidnightBlue);
        ObjectSetInteger(0, m_objInfoTp, OBJPROP_FONTSIZE, 8);
        ObjectSetInteger(0, m_objInfoEn, OBJPROP_FONTSIZE, 8);
        ObjectSetInteger(0, m_objInfoSl, OBJPROP_FONTSIZE, 8);
        ObjectSetString(0, m_objInfoTp, OBJPROP_FONT, "Consolas");
        ObjectSetString(0, m_objInfoEn, OBJPROP_FONT, "Consolas");
        ObjectSetString(0, m_objInfoSl, OBJPROP_FONT, "Consolas");

        // Background
        ObjectSetInteger(0, m_objBgTp, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, m_objBgSl, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, m_objBgTp, OBJPROP_FILL, true);
        ObjectSetInteger(0, m_objBgSl, OBJPROP_FILL, true);
        ObjectSetInteger(0, m_objBgTp, OBJPROP_COLOR, AliceBlue);
        ObjectSetInteger(0, m_objBgSl, OBJPROP_COLOR, MistyRose);

        // TP/SL/EN Line
        ObjectSetInteger(0, m_objLineTp, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, m_objLineSl, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, m_objLineEn, OBJPROP_SELECTABLE, true);

        ObjectSetInteger(0, m_objLineTp, OBJPROP_RAY, false);
        ObjectSetInteger(0, m_objLineEn, OBJPROP_RAY, false);
        ObjectSetInteger(0, m_objLineSl, OBJPROP_RAY, false);

        ObjectSetInteger(0, m_objLineTp, OBJPROP_WIDTH, 1);
        ObjectSetInteger(0, m_objLineEn, OBJPROP_WIDTH, 2);
        ObjectSetInteger(0, m_objLineSl, OBJPROP_WIDTH, 1);

        ObjectSetInteger(0, m_objLineTp, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(0, m_objLineEn, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(0, m_objLineSl, OBJPROP_STYLE, STYLE_SOLID);

        ObjectSetInteger(0, m_objLineTp, OBJPROP_COLOR, clrDarkGreen);
        ObjectSetInteger(0, m_objLineEn, OBJPROP_COLOR, clrGoldenrod);
        ObjectSetInteger(0, m_objLineSl, OBJPROP_COLOR, clrCrimson);

        //Back
        ObjectSetInteger(0, m_objBack, OBJPROP_SELECTABLE, true);
        ObjectSetInteger(0, m_objBack, OBJPROP_COLOR, clrNONE);
        ObjectSetInteger(0, m_objBack, OBJPROP_WIDTH, 2);

        time1  = time0 + 5 * PeriodSeconds(_Period);
        
        double chartMin = ChartGetDouble(0,CHART_FIXED_MIN);
        double chartMax = ChartGetDouble(0,CHART_FIXED_MAX);

        if (mType == 0) {
            // price2 = chartMax;
            // price0 = chartMin;
            price0 = (2 * price1 + chartMin) / 3;
        } 
        else {
            // price2 = chartMin;
            // price0 = chartMax;
            price0 = (2 * price1 + chartMax) / 3;
        }
        price2 = 3*price1 - 2*price0;

        // price0 = price1 + (mType == 0 ? -1 : 1) * (0.0015); // SL
        // price2 = price1 + (mType == 0 ? 1 : -1) * (0.0015); // TP
        refreshObj();
        return true;
    };
    void cancelObj() override {
        refreshObj();
    }
    virtual bool deleteObj(string sparam) override {
        ObjectDelete(0, m_objInfoTp);
        ObjectDelete(0, m_objInfoEn);
        ObjectDelete(0, m_objInfoSl);
        ObjectDelete(0, m_objLineTp);
        ObjectDelete(0, m_objLineEn);
        ObjectDelete(0, m_objLineSl);
        ObjectDelete(0, m_objBgTp  );
        ObjectDelete(0, m_objBgSl  );
        ObjectDelete(0, m_objBack  );
        return true;
    };
    virtual void updateTypeObj() override {
        if (Editing) userAction(mType);
    };
    virtual void activeObj(bool state) override {
        ObjectSetInteger(0, m_objLineEn, OBJPROP_SELECTED, state);
        ObjectSetInteger(0, m_objBack, OBJPROP_SELECTED, state);
    };
    virtual void refreshObj() override {
        ObjectMove(0, m_objBack, 0, time0, price0);
        ObjectMove(0, m_objBack, 1, time1, price2);
        ObjectMove(0, m_objLineTp, 0, time0, price2);
        ObjectMove(0, m_objLineTp, 1, time1, price2);
        ObjectMove(0, m_objLineEn, 0, time0, price1);
        ObjectMove(0, m_objLineEn, 1, time1, price1);
        ObjectMove(0, m_objLineSl, 0, time0, price0);
        ObjectMove(0, m_objLineSl, 1, time1, price0);
        ObjectMove(0, m_objBgTp, 0, time0, price1);
        ObjectMove(0, m_objBgTp, 1, time1, price2);
        ObjectMove(0, m_objBgSl, 0, time0, price0);
        ObjectMove(0, m_objBgSl, 1, time1, price1);

        time2 = (time0+time1)/2;
        
        ObjectMove(0, m_objInfoTp, 0, time2, price2);
        ObjectMove(0, m_objInfoEn, 0, time2, price1);
        ObjectMove(0, m_objInfoSl, 0, time2, price0);
        if (price1 > price0) {
            ObjectSetInteger(0, m_objInfoTp, OBJPROP_ANCHOR, ANCHOR_LOWER);
            ObjectSetInteger(0, m_objInfoSl, OBJPROP_ANCHOR, ANCHOR_UPPER);
        }
        else {
            ObjectSetInteger(0, m_objInfoTp, OBJPROP_ANCHOR, ANCHOR_UPPER);
            ObjectSetInteger(0, m_objInfoSl, OBJPROP_ANCHOR, ANCHOR_LOWER);
        }

        int slPoint = (int)(MathAbs(price1-price0) * mContractSize);
        int tpPoint = (int)(MathAbs(price1-price2) * mContractSize);
        double lotSize = MathFloor(InpTradeCost / (slPoint + InpTradeComm) * 100) /100;

        string strTpInfo = DoubleToString((price2-price1)/(price1-price0), 1) + "r";
        string strEnInfo = ObjectGetString(0, m_objLineEn, OBJPROP_TEXT);
        string strSlInfo = Commons::StringEmpty;
        if (Editing) {
            strTpInfo += "/" + IntegerToString(tpPoint) + "pt/" + DoubleToString(lotSize * (tpPoint-InpTradeComm), 2) + "$";
            if (strEnInfo != "") strEnInfo += " ";
            strEnInfo += DoubleToString(lotSize, 2) + "lot";
            strSlInfo = IntegerToString(slPoint) + "pt/" + DoubleToString(lotSize * (slPoint + InpTradeComm), 2) + "$";
        }
        else {
            if (strEnInfo == "") strEnInfo = Commons::StringEmpty;
        }
        
        ObjectSetString(0, m_objInfoTp, OBJPROP_TEXT, strTpInfo);
        ObjectSetString(0, m_objInfoEn, OBJPROP_TEXT, strEnInfo);
        ObjectSetString(0, m_objInfoSl, OBJPROP_TEXT, strSlInfo);
    };
    virtual void changeObj(string sparam) override {
        if (sparam == m_objLineEn) {
            refreshObj();
        }
    };
    virtual void prepareData(string sparam) override {
        bool moveP0, moveP1, moveP2;
        if (sparam == m_objLineEn) {
            price0 = ObjectGetDouble(0, m_objBack, OBJPROP_PRICE, 0);
            price2 = ObjectGetDouble(0, m_objBack, OBJPROP_PRICE, 1);
            time0 = (datetime) ObjectGetInteger(0, m_objLineEn, OBJPROP_TIME, 0);
            time1 = (datetime) ObjectGetInteger(0, m_objLineEn, OBJPROP_TIME, 1);
            double oldPriceEn = ObjectGetDouble(0, m_objBgSl, OBJPROP_PRICE, 1);
            moveP0 = (oldPriceEn != ObjectGetDouble(0, m_objLineEn, OBJPROP_PRICE, 0));
            moveP1 = (oldPriceEn != ObjectGetDouble(0, m_objLineEn, OBJPROP_PRICE, 1));
            if (moveP0 && moveP1) {
                if (Commons::CtrlHeld) price1 = Commons::MousePrice;
                else price1 = ObjectGetDouble(0, m_objLineEn, OBJPROP_PRICE, 0);
                price0 += (price1 - oldPriceEn);
                price2 += (price1 - oldPriceEn);
            }
            else if (Commons::CtrlHeld) {
                time0 = (datetime) ObjectGetInteger(0, m_objBack, OBJPROP_TIME, 0);
                time1 = (datetime) ObjectGetInteger(0, m_objBack, OBJPROP_TIME, 1);
                price1 = Commons::MousePrice;
            }
            else if (Commons::ShiftHeld && moveP0) {
                price1 = oldPriceEn;
            }
            else {
                if (time1 > time0) {
                    price1 = ObjectGetDouble(0, m_objLineEn, OBJPROP_PRICE, 0);
                }
                else {
                    price1 = ObjectGetDouble(0, m_objLineEn, OBJPROP_PRICE, 1);
                }
            }
        }
        else if (sparam == m_objBack) {
            price0 = ObjectGetDouble(0, m_objBack, OBJPROP_PRICE, 0);
            price2 = ObjectGetDouble(0, m_objBack, OBJPROP_PRICE, 1);
            time0 = (datetime) ObjectGetInteger(0, m_objLineEn, OBJPROP_TIME, 0);
            time1 = (datetime) ObjectGetInteger(0, m_objLineEn, OBJPROP_TIME, 1);
            price1 = ObjectGetDouble(0, m_objLineEn, OBJPROP_PRICE, 0);
            moveP0 = (price0 != ObjectGetDouble(0, m_objLineSl, OBJPROP_PRICE, 0));
            moveP2 = (price2 != ObjectGetDouble(0, m_objLineTp, OBJPROP_PRICE, 0));
            if (moveP0 && moveP2) {
                price1 += (price0 - ObjectGetDouble(0, m_objLineSl, OBJPROP_PRICE, 0));
                time0 = (datetime) ObjectGetInteger(0, m_objBack, OBJPROP_TIME, 0);
                time1 = (datetime) ObjectGetInteger(0, m_objBack, OBJPROP_TIME, 1);
            }
            else if (Commons::CtrlHeld) {
                if (moveP0) price0 = Commons::MousePrice;
                else if (moveP2) price2 = Commons::MousePrice;
            }
        }
    };
    virtual string optionInfo() override {
        return "1.Fill SL  2.Fill TP  3.Go Live  4.SL to Entry  5.TP to Entry";
    }
    virtual void userAction(int key) override {
        switch (key) {
            case 0:
                if (price1 > price0) { //BUY
                    price0 -= InpTradeSlOpt/mContractSize;
                }
                else {
                    price0 += (InpTradeSlOpt + InpTradeSpread)/mContractSize;
                }
            break;
            case 1:
                price2 = (price1 + ((price1 > price0) ? 1 : -1 )*InpTradeComm/mContractSize) * (InpTradeTpOpt + 1) - InpTradeTpOpt * price0;
            break;
            case 2: // Go Live 
            {
                double point        = floor(fabs(price1-price0) * mContractSize);
                double tradeSize    = NormalizeDouble(floor(InpTradeCost / (point+InpTradeComm) * 100)/100, 2);
                if (price1 > price0) {
                    //mCTrade.BuyLimit(tradeSize, price1, _Symbol, price0, price2);
                }
                else {
                    //mCTrade.SellLimit(tradeSize, price1, _Symbol, price0, price2);
                }
            }
            break;
            case 3:
            break;
            case 4:
            break;
        }
        refreshObj();
    };
};

input string InpRect = ""; // ===  R E C T A N G L E  ===
input string InpRect_Hotkey = "R";
input string InpRect1 = ""; // Rectangle 1:
input string InpRect1_Name = "Sz1";
input color  InpRect1_Color = MistyRose;
input string InpRect2 = ""; // Rectangle 2:
input string InpRect2_Name = "Sz2";
input color  InpRect2_Color = LightPink;
input string InpRect3 = ""; // Rectangle 3:
input string InpRect3_Name = "Dz1";
input color  InpRect3_Color = AliceBlue;
input string InpRect4 = ""; // Rectangle 4:
input string InpRect4_Name = "Dz2";
input color  InpRect4_Color = PowderBlue;
class Rectangle: public IDrawingTool {
    public:
    Rectangle(): IDrawingTool() {
        Tag = "Rectangle";
        mPointLimit = 2;
        mTypeLimit = 4;
    }
    private:
    color  mTypeColor[TYPELIMIT];
    void intTools() override {
        Hotkey = (char)InpRect_Hotkey[0];
        mTypeNames[0] = InpRect1_Name ;
        mTypeColor[0] = InpRect1_Color;
        mTypeNames[1] = InpRect2_Name ;
        mTypeColor[1] = InpRect2_Color;
        mTypeNames[2] = InpRect3_Name ;
        mTypeColor[2] = InpRect3_Color;
        mTypeNames[3] = InpRect4_Name ;
        mTypeColor[3] = InpRect4_Color;
    }

    private:
    string m_objRect;
    string m_objLine;
    string m_objBack;
    string m_objText;
    void prepareObj() override {
        m_objRect = mObjId + "_Rect";
        m_objLine = mObjId + "_Line";
        m_objBack = mObjId + "_Back";
        m_objText = mObjId + "_Text";
    };
    bool createObj() override {
        ObjectCreate(0, m_objBack, OBJ_RECTANGLE, 0, time0, price0, time1, price1);
        ObjectSetInteger(0, m_objBack, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, m_objBack, OBJPROP_COLOR, clrNONE);
        ObjectCreate(0, m_objText, OBJ_TEXT, 0, 0, 0);
        ObjectSetInteger(0, m_objText, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, m_objText, OBJPROP_COLOR, clrMidnightBlue);
        ObjectSetInteger(0, m_objText, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
        ObjectSetInteger(0, m_objText, OBJPROP_FONTSIZE, 10);
        ObjectSetString(0, m_objText, OBJPROP_FONT, "Consolas");
        ObjectSetString(0, m_objText, OBJPROP_TEXT, Commons::StringEmpty);

        ObjectCreate(0, m_objRect, OBJ_RECTANGLE, 0, time0, price0, time1, price1);
        ObjectSetInteger(0, m_objRect, OBJPROP_SELECTABLE, true);
        ObjectSetInteger(0, m_objRect, OBJPROP_BACK, true);
        ObjectSetInteger(0, m_objRect, OBJPROP_WIDTH, 2);
        ObjectSetInteger(0, m_objRect, OBJPROP_FILL, true);
        ObjectSetInteger(0, m_objRect, OBJPROP_STYLE, STYLE_DOT);

        ObjectCreate(0, m_objLine, OBJ_TREND, 0, time0, price0, time1, price1);
        ObjectSetInteger(0, m_objLine, OBJPROP_COLOR, clrNONE);
        ObjectSetInteger(0, m_objLine, OBJPROP_SELECTABLE, true);
        ObjectSetInteger(0, m_objLine, OBJPROP_STYLE, STYLE_DOT);
        updateTypeObj();
        return true;
    }
    void cancelObj() override {
        if (Creating) ObjectDelete(0, m_objRect);
    }
    void updateTypeObj() override {
        ObjectSetInteger(0, m_objRect, OBJPROP_COLOR, mTypeColor[mType]);
    }
    virtual string optionInfo() override {
        return mouseInfo() + "5.Expand 6.Line50%";
    }
    void userAction(int key) override {
        int i;
        if (key == 4) {
            datetime timeNewer;
            bool update0 = true;
            if (time0 > time1) {
                timeNewer = time0;
                update0 = true;
            }
            else {
                timeNewer = time1;
                update0 = false;
            }
            int barIdx = iBarShift(_Symbol, _Period, timeNewer) - 5;
            if (mType > 1) { // DM
                double priceH = MathMax(price0, price1);
                for (i = barIdx; i >= 0; i--) {
                    if (iLow(_Symbol, _Period, i) <= priceH) {
                        if (update0) time0 = iTime(_Symbol, _Period, i);
                        else time1 = iTime(_Symbol, _Period, i);
                        refreshObj();
                        return;
                    }
                }
            }
            else {
                double priceL = MathMin(price0, price1);
                for (i = barIdx; i >= 0; i--) {
                    if (iHigh(_Symbol, _Period, i) >= priceL) {
                        if (update0) time0 = iTime(_Symbol, _Period, i);
                        else time1 = iTime(_Symbol, _Period, i);
                        refreshObj();
                        return;
                    }
                }
            }
            if (update0) time0 = iTime(_Symbol, _Period, 0);
            else time1 = iTime(_Symbol, _Period, 0);
            refreshObj();
        }
        else if (key == 5) {
            if ((color)ObjectGetInteger(0, m_objLine, OBJPROP_COLOR) == clrNONE) {
                ObjectSetInteger(0, m_objLine, OBJPROP_COLOR, clrGray);
            }
            else {
                ObjectSetInteger(0, m_objLine, OBJPROP_COLOR, clrNONE);
            }
        }
    }
    bool deleteObj(string sparam) override {
        ObjectDelete(0, m_objRect);
        ObjectDelete(0, m_objLine);
        ObjectDelete(0, m_objBack);
        ObjectDelete(0, m_objText);
        return true;
    }
    void activeObj(bool state) override {
        ObjectSetInteger(0, m_objRect, OBJPROP_SELECTED, state);
        ObjectSetInteger(0, m_objLine, OBJPROP_SELECTED, state);
    }
    void prepareData(string sparam) override {
        price0 = ObjectGetDouble(0, m_objRect, OBJPROP_PRICE, 0);
        price1 = ObjectGetDouble(0, m_objRect, OBJPROP_PRICE, 1);
        time0 = (datetime) ObjectGetInteger(0, sparam, OBJPROP_TIME, 0);
        time1 = (datetime) ObjectGetInteger(0, sparam, OBJPROP_TIME, 1);
        if (sparam == m_objRect) {
            if (Commons::CtrlHeld) {
                if (price0 != ObjectGetDouble(0, m_objBack, OBJPROP_PRICE, 0))
                    price0 = Commons::MousePrice;
                else if (price1 != ObjectGetDouble(0, m_objBack, OBJPROP_PRICE, 1))
                    price1 = Commons::MousePrice;
            }
            else if (time0 == time1) {
                time0 = (datetime) ObjectGetInteger(0, m_objBack, OBJPROP_TIME, 0);
            }
        }
    };
    void changeObj(string sparam) override {
        if (sparam == m_objRect || sparam == m_objLine) {
            string content = ObjectGetString(0, sparam, OBJPROP_TEXT);
            if (content == "") content = Commons::StringEmpty;
            ObjectSetString(0, m_objText, OBJPROP_TEXT, content);
        }
    };
    void refreshObj() override {
        ObjectMove(0, m_objRect, 0, time0, price0);
        ObjectMove(0, m_objRect, 1, time1, price1);
        ObjectMove(0, m_objBack, 0, time0, price0);
        ObjectMove(0, m_objBack, 1, time1, price1);
        ObjectMove(0, m_objLine, 0, time0, (price0 + price1) / 2);
        ObjectMove(0, m_objLine, 1, time1, (price0 + price1) / 2);
        
        if (time0 > time1) {
            ObjectMove(0, m_objText, 0, time0 - 2*PeriodSeconds(_Period), (price0 + price1) / 2);
        }
        else {
            ObjectMove(0, m_objText, 0, time1 - 2*PeriodSeconds(_Period), (price0 + price1) / 2);
        }
    }
};

input string InpTrend = ""; // ===  T R E N D  ===
input string InpTrend_Hotkey = "T";
input string InpTrend1 = ""; // Trend 1:
input string InpTrend1_Name = "Flow";
input string InpTrend1_Text = "";
input color  InpTrend1_Color = clrMidnightBlue;
input LSTYLE InpTrend1_Style = STYLE_SOLID;
input int    InpTrend1_Width = 1;
//--------------------------------
input string InpTrend2 = ""; // Trend 2:
input string InpTrend2_Name = "x";
input string InpTrend2_Text = "x";
input color  InpTrend2_Color = clrMidnightBlue;
input LSTYLE InpTrend2_Style = STYLE_DOT;
input int    InpTrend2_Width = 1;
//--------------------------------
input string InpTrend3 = ""; // Trend 3:
input string InpTrend3_Name = "BOS";
input string InpTrend3_Text = "BOS";
input color  InpTrend3_Color = clrMidnightBlue;
input LSTYLE InpTrend3_Style = STYLE_SOLID;
input int    InpTrend3_Width = 2;
//--------------------------------
input string InpTrend4 = ""; // Trend 4:
input string InpTrend4_Name = "sub";
input string InpTrend4_Text = "sub";
input color  InpTrend4_Color = clrMidnightBlue;
input LSTYLE InpTrend4_Style = STYLE_SOLID;
input int    InpTrend4_Width = 1;
//--------------------------------
input string InpTrend5 = ""; // Trend 5:
input string InpTrend5_Name = "$$$";
input string InpTrend5_Text = "$$$";
input color  InpTrend5_Color = clrDarkGreen;
input LSTYLE InpTrend5_Style = STYLE_DOT;
input int    InpTrend5_Width = 1;
//--------------------------------
class Trend: public IDrawingTool {
    public:
    Trend(): IDrawingTool() {
        Tag = "Trend";
        mPointLimit = 2;
        mTypeLimit = 5;
    }
    private:
        string mTypeText [TYPELIMIT];
        color  mTypeColor[TYPELIMIT];
        LSTYLE mTypeStyle[TYPELIMIT];
        int    mTypeWidth[TYPELIMIT];
    void intTools() override {
        Hotkey = (char)InpTrend_Hotkey[0];
        mTypeNames[0] = InpTrend1_Name ;
        mTypeText [0] = InpTrend1_Text ;
        mTypeColor[0] = InpTrend1_Color;
        mTypeStyle[0] = InpTrend1_Style;
        mTypeWidth[0] = InpTrend1_Width;
        //------------------------------
        mTypeNames[1] = InpTrend2_Name ;
        mTypeText [1] = InpTrend2_Text ;
        mTypeColor[1] = InpTrend2_Color;
        mTypeStyle[1] = InpTrend2_Style;
        mTypeWidth[1] = InpTrend2_Width;
        //------------------------------
        mTypeNames[2] = InpTrend3_Name ;
        mTypeText [2] = InpTrend3_Text ;
        mTypeColor[2] = InpTrend3_Color;
        mTypeStyle[2] = InpTrend3_Style;
        mTypeWidth[2] = InpTrend3_Width;
        //------------------------------
        mTypeNames[3] = InpTrend4_Name ;
        mTypeText [3] = InpTrend4_Text ;
        mTypeColor[3] = InpTrend4_Color;
        mTypeStyle[3] = InpTrend4_Style;
        mTypeWidth[3] = InpTrend4_Width;
        //------------------------------
        mTypeNames[4] = InpTrend5_Name ;
        mTypeText [4] = InpTrend5_Text ;
        mTypeColor[4] = InpTrend5_Color;
        mTypeStyle[4] = InpTrend5_Style;
        mTypeWidth[4] = InpTrend5_Width;
        //------------------------------
    }
    // Internal Child Function
    protected:
    string m_objLine;
    string m_objBack;
    string m_objText;

    datetime time2;
    double   price2;
    void prepareObj() override {
        m_objLine = mObjId + "_Line";
        m_objBack = mObjId + "_Back";
        m_objText = mObjId + "_Text";
    };
    virtual bool createObj() override {
        ObjectCreate(0, m_objBack, OBJ_TREND, 0, time0, price0, time1, price1);
        ObjectSetInteger(0, m_objBack, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, m_objBack, OBJPROP_COLOR, clrNONE);
        ObjectCreate(0, m_objText, OBJ_TEXT, 0, 0, 0);
        ObjectSetInteger(0, m_objText, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, m_objText, OBJPROP_ANCHOR, ANCHOR_LEFT);
        ObjectSetInteger(0, m_objText, OBJPROP_FONTSIZE, 8);
        ObjectSetString(0, m_objText, OBJPROP_FONT, "Consolas");

        ObjectCreate(0, m_objLine, OBJ_TREND, 0, time0, price0, time1, price1);
        ObjectSetInteger(0, m_objLine, OBJPROP_SELECTABLE, true);
        ObjectSetInteger(0, m_objLine, OBJPROP_RAY, false);
        updateTypeObj();
        return true;
    };
    virtual bool deleteObj(string sparam) override {
        ObjectDelete(0, m_objLine);
        ObjectDelete(0, m_objBack);
        ObjectDelete(0, m_objText);
        return true;
    };
    virtual void cancelObj() override {
        if (Creating) ObjectDelete(0, m_objLine);
    };
    virtual void updateTypeObj() override {
        if (mTypeText[mType] != "") ObjectSetString(0, m_objText, OBJPROP_TEXT, mTypeText[mType]);
        else ObjectSetString(0, m_objText, OBJPROP_TEXT, Commons::StringEmpty);
        ObjectSetInteger(0, m_objLine, OBJPROP_COLOR, mTypeColor[mType]);
        ObjectSetInteger(0, m_objLine, OBJPROP_STYLE, mTypeStyle[mType]);
        ObjectSetInteger(0, m_objLine, OBJPROP_WIDTH, mTypeWidth[mType]);
        ObjectSetInteger(0, m_objText, OBJPROP_COLOR, mTypeColor[mType]);
    };
    virtual void activeObj(bool state) override {
        ObjectSetInteger(0, m_objLine, OBJPROP_SELECTED, state);
    };
    virtual void refreshObj() override {
        ObjectMove(0, m_objBack, 0, time0, price0);
        ObjectMove(0, m_objBack, 1, time1, price1);
        ObjectMove(0, m_objLine, 0, time0, price0);
        ObjectMove(0, m_objLine, 1, time1, price1);

        time2 = (time0 + time1) / 2;
        price2 = (price0 + price1) / 2;
        ObjectMove(0, m_objText, 0, time2, price2);

        int beginBar;
        double priceCd;
        if (time1 > time0) {
            beginBar = iBarShift(_Symbol, _Period, time0);
            priceCd = iOpen(_Symbol, _Period, beginBar);
            if (price1 >= price0) ObjectSetInteger(0, m_objText, OBJPROP_ANCHOR, priceCd > price0 ? ANCHOR_LEFT_UPPER : ANCHOR_RIGHT_LOWER);
            else ObjectSetInteger(0, m_objText, OBJPROP_ANCHOR, priceCd > price0 ? ANCHOR_RIGHT_UPPER : ANCHOR_LEFT_LOWER);
        }
        else {
            beginBar = iBarShift(_Symbol, _Period, time1);
            priceCd = iOpen(_Symbol, _Period, beginBar);
            if (price1 <= price0) ObjectSetInteger(0, m_objText, OBJPROP_ANCHOR, priceCd > price0 ? ANCHOR_LEFT_UPPER : ANCHOR_RIGHT_LOWER);
            else ObjectSetInteger(0, m_objText, OBJPROP_ANCHOR, priceCd > price0 ? ANCHOR_RIGHT_UPPER : ANCHOR_LEFT_LOWER);
        }
    };
    virtual void changeObj(string sparam) override {
        if (sparam == m_objLine) {
            string content = ObjectGetString(0, sparam, OBJPROP_TEXT);
            if (content == "") content = Commons::StringEmpty;
            ObjectSetString(0, m_objText, OBJPROP_TEXT, content);
            refreshObj();
        }
    };
    virtual void prepareData(string sparam) override {
        price0 = ObjectGetDouble(0, m_objLine, OBJPROP_PRICE, 0);
        price1 = ObjectGetDouble(0, m_objLine, OBJPROP_PRICE, 1);
        time0 = (datetime) ObjectGetInteger(0, m_objLine, OBJPROP_TIME, 0);
        time1 = (datetime) ObjectGetInteger(0, m_objLine, OBJPROP_TIME, 1);
        if (Commons::ShiftHeld) {
            if (price0 != ObjectGetDouble(0, m_objBack, OBJPROP_PRICE, 0)) {
                price0 = price1;
            }
            else {
                price1 = price0;
            }
        }
        else if (Commons::CtrlHeld) {
            if (price0 != ObjectGetDouble(0, m_objBack, OBJPROP_PRICE, 0)) {
                price0 = Commons::MousePrice;
            }
            else {
                price1 = Commons::MousePrice;
            }
        }
    };
    // virtual void userAction(int key) override {};
};

input string InpZigzag = ""; // ===  Z I G Z A G  ===
input string InpZigzag_Hotkey = "Z";
input color  InpZigzag_Color = clrMidnightBlue;
input LSTYLE InpZigzag_Style = STYLE_SOLID;
input int    InpZigzag_Width = 1;
class Zigzag: public IDrawingTool {
    public:
    Zigzag(): IDrawingTool() {
        Tag = "Zigzag";
        mTypeLimit = 0;
        mPointLimit = 100;
    }
    private:
        string mTypeText [TYPELIMIT];
        color  mTypeColor[TYPELIMIT];
        LSTYLE mTypeStyle[TYPELIMIT];
        int    mTypeWidth[TYPELIMIT];
    void intTools() override {
        Hotkey = (char)InpZigzag_Hotkey[0];
    }
    // Internal Child Function
    protected:
    string m_objTempl;
    string m_objLine;

    string mSparamItems[];
    void prepareObj() override {
        m_objTempl = mObjId + "_Line";
    };
    virtual bool createObj() override {
        m_objLine = m_objTempl + "_" + IntegerToString(mPointIdx);
        ObjectCreate(0, m_objLine, OBJ_TREND, 0, time0, price0, time1, price1);
        ObjectSetInteger(0, m_objLine, OBJPROP_SELECTABLE, true);
        ObjectSetInteger(0, m_objLine, OBJPROP_RAY, false);
        updateTypeObj();
        return true;
    };
    bool deleteObj(string sparam) override {
        if (sparam == m_objLine) return false;
        for (int i = 0; i < mPointLimit; i++) {
            m_objLine = m_objTempl + "_" + IntegerToString(i);
            ObjectDelete(0, m_objLine);
        }
        return true;
    };
    virtual void cancelObj() override {
        if (Creating) ObjectDelete(0, m_objLine);
    };
    virtual void updateTypeObj() override {
        ObjectSetInteger(0, m_objLine, OBJPROP_COLOR, InpZigzag_Color);
        ObjectSetInteger(0, m_objLine, OBJPROP_STYLE, InpZigzag_Style);
        ObjectSetInteger(0, m_objLine, OBJPROP_WIDTH, InpZigzag_Width);
    };
    virtual void activeObj(bool state) override {
        for (int i = 0; i < mPointLimit; i++) {
            m_objLine = m_objTempl + "_" + IntegerToString(i);
            ObjectSetInteger(0, m_objLine, OBJPROP_SELECTED, state);
        }
    };
    virtual void refreshObj() override {
        ObjectMove(0, m_objLine, 1, time1, price1);
        if (Creating == true) return;
        ObjectMove(0, m_objLine, 0, time0, price0);
        m_objLine = m_objTempl + "_" + IntegerToString(mPointIdx-1);
        ObjectMove(0, m_objLine, 1, time0, price0);
        
        m_objLine = m_objTempl + "_" + IntegerToString(mPointIdx+1);
        ObjectMove(0, m_objLine, 0, time1, price1);
    };
    virtual void changeObj(string sparam) override {
        color clr = (color)ObjectGetInteger(0, sparam, OBJPROP_COLOR);
        int   sty = (int)ObjectGetInteger(0, sparam, OBJPROP_STYLE);
        int   wid = (int)ObjectGetInteger(0, sparam, OBJPROP_WIDTH);
        int   bak = (int)ObjectGetInteger(0, sparam, OBJPROP_BACK);
        for (int i = 0; i < mPointLimit; i++) {
            m_objLine = m_objTempl + "_" + IntegerToString(i);
            ObjectSetInteger(0, m_objLine, OBJPROP_COLOR, clr);
            ObjectSetInteger(0, m_objLine, OBJPROP_STYLE, sty);
            ObjectSetInteger(0, m_objLine, OBJPROP_WIDTH, wid);
            ObjectSetInteger(0, m_objLine, OBJPROP_BACK , bak);
        }
    };
    virtual void prepareData(string sparam) override {
        StringSplit(sparam, '_', mSparamItems);
        mPointIdx = (int)StringToInteger(mSparamItems[4]);
        price0 = ObjectGetDouble(0, sparam, OBJPROP_PRICE, 0);
        price1 = ObjectGetDouble(0, sparam, OBJPROP_PRICE, 1);
        time0 = (datetime) ObjectGetInteger(0, sparam, OBJPROP_TIME, 0);
        time1 = (datetime) ObjectGetInteger(0, sparam, OBJPROP_TIME, 1);
        if (Commons::ShiftHeld) {
            if (mPointIdx == 0) {
                m_objLine = m_objTempl + "_" + IntegerToString(mPointIdx+1);
                if (price1 != ObjectGetDouble(0, m_objLine, OBJPROP_PRICE, 0)) {
                    price1 = price0;
                }
                else {
                    price0 = price1;
                }
            }
            else {
                m_objLine = m_objTempl + "_" + IntegerToString(mPointIdx-1);
                if (price0 != ObjectGetDouble(0, m_objLine, OBJPROP_PRICE, 1)) {
                    price0 = price1;
                }
                else {
                    price1 = price0;
                }
            }
        }
        else if (Commons::CtrlHeld) {
            if (mPointIdx == 0) {
                m_objLine = m_objTempl + "_" + IntegerToString(mPointIdx+1);
                if (price1 != ObjectGetDouble(0, m_objLine, OBJPROP_PRICE, 0)) {
                    price1 = Commons::MousePrice;
                }
                else {
                    price0 = Commons::MousePrice;
                }
            }
            else {
                m_objLine = m_objTempl + "_" + IntegerToString(mPointIdx-1);
                if (price0 != ObjectGetDouble(0, m_objLine, OBJPROP_PRICE, 1)) {
                    price0 = Commons::MousePrice;
                }
                else {
                    price1 = Commons::MousePrice;
                }
            }
        }
        m_objLine = sparam;
    };
    // virtual void userAction(int key) override {};
};

input string InpCallout = ""; // ===  C A L L O U T  ===
input string InpCallout_Hotkey = "C";
input color  InpCallout_Color = clrMidnightBlue;
class Callout: public IDrawingTool {
    public:
    Callout(): IDrawingTool() {
        Tag = "Callout";
        mTypeLimit = 0;
        mPointLimit = 2;
    }
    private:
    void intTools() override {
        Hotkey = (char)InpCallout_Hotkey[0];
    }
    // Internal Child Function
    protected:
    string m_objLine;
    string m_objBack;
    string m_objText;
    string m_objTxBG;
    void prepareObj() override {
        m_objLine = mObjId + "_Line";
        m_objBack = mObjId + "_Back";
        m_objText = mObjId + "_Text";
        m_objTxBG = mObjId + "_TxBG";
    };
    virtual bool createObj() override {
        ObjectCreate(0, m_objBack, OBJ_TREND, 0, time0, price0, time1, price1);
        ObjectSetInteger(0, m_objBack, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, m_objBack, OBJPROP_COLOR, clrNONE);
        ObjectSetInteger(0, m_objBack, OBJPROP_RAY, false);

        ObjectCreate(0, m_objTxBG, OBJ_TEXT, 0, 0, 0);
        ObjectSetInteger(0, m_objTxBG, OBJPROP_SELECTABLE, false);
        ObjectSetString(0, m_objTxBG, OBJPROP_FONT, "Consolas");

        ObjectCreate(0, m_objText, OBJ_TEXT, 0, 0, 0);
        ObjectSetInteger(0, m_objText, OBJPROP_SELECTABLE, true);
        ObjectSetString(0, m_objText, OBJPROP_FONT, "Consolas");

        ObjectCreate(0, m_objLine, OBJ_TREND, 0, time0, price0, time1, price1);
        ObjectSetInteger(0, m_objLine, OBJPROP_RAY, false);
        ObjectSetInteger(0, m_objLine, OBJPROP_SELECTABLE, true);
        updateTypeObj();
        return true;
    };
    virtual bool deleteObj(string sparam) override {
        ObjectDelete(0, m_objLine);
        ObjectDelete(0, m_objBack);
        ObjectDelete(0, m_objText);
        ObjectDelete(0, m_objTxBG);
        return true;
    };
    virtual void cancelObj() override {
        if (Creating) ObjectDelete(0, m_objLine);
    };
    // virtual string optionInfo() override {
    //     return ""; // add leg???
    // }
    virtual void updateTypeObj() override {
        ObjectSetInteger(0, m_objText, OBJPROP_COLOR, InpCallout_Color);
        ObjectSetInteger(0, m_objTxBG, OBJPROP_COLOR, InpCallout_Color);
        ObjectSetInteger(0, m_objLine, OBJPROP_COLOR, InpCallout_Color);
    };
    virtual void activeObj(bool state) override {
        ObjectSetInteger(0, m_objLine, OBJPROP_SELECTED, state);
        ObjectSetInteger(0, m_objText, OBJPROP_SELECTED, state);
    };
    virtual void refreshObj() override {
        ObjectMove(0, m_objBack, 0, time0, price0);
        ObjectMove(0, m_objBack, 1, time1, price1);
        ObjectMove(0, m_objLine, 0, time0, price0);
        ObjectMove(0, m_objLine, 1, time1, price1);
        ObjectMove(0, m_objText, 0, time1, price1);
        ObjectMove(0, m_objTxBG, 0, time1, price1);

        string calloutContent = ObjectGetString(0, m_objText, OBJPROP_TEXT);
        if (calloutContent == "Text" || calloutContent == "") {
            calloutContent = DoubleToString(price0, _Digits);
        }

        if (time1 > time0) {
            ObjectSetInteger(0, m_objText, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
            ObjectSetInteger(0, m_objTxBG, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        }
        else {
            ObjectSetInteger(0, m_objText, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
            ObjectSetInteger(0, m_objTxBG, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
        }
        //
        ObjectSetString(0, m_objText, OBJPROP_TEXT, calloutContent);
        ObjectSetString(0, m_objTxBG, OBJPROP_TEXT, Commons::GetStringUnderLine(StringLen(calloutContent)));
        
    };
    virtual void changeObj(string sparam) override {
        if (sparam == m_objText) {
            refreshObj();
        }
    };
    virtual void prepareData(string sparam) override {
        price0 = ObjectGetDouble(0, m_objLine, OBJPROP_PRICE, 0);
        price1 = ObjectGetDouble(0, m_objLine, OBJPROP_PRICE, 1);
        time0 = (datetime) ObjectGetInteger(0, m_objLine, OBJPROP_TIME, 0);
        time1 = (datetime) ObjectGetInteger(0, m_objLine, OBJPROP_TIME, 1);
        if (sparam == m_objText) {
            price1 = ObjectGetDouble(0, m_objText, OBJPROP_PRICE, 0);
            time1 = (datetime) ObjectGetInteger(0, m_objText, OBJPROP_TIME, 0);
        }
        else if (Commons::ShiftHeld) {
            if (price0 != ObjectGetDouble(0, m_objBack, OBJPROP_PRICE, 0)) {
                price0 = price1;
            }
            else {
                price1 = price0;
            }
        }
        else if (Commons::CtrlHeld) {
            if (price0 != ObjectGetDouble(0, m_objBack, OBJPROP_PRICE, 0)) {
                price0 = Commons::MousePrice;
            }
            else {
                price1 = Commons::MousePrice;
            }
        }
    };
    // virtual void userAction(int key) override {};
};

#define ALERT_H "↑"
#define ALERT_L "↓"
#define INVALID_H 2147483647
#define INVALID_L -1

input string InpAlert = ""; // ===  A L E R T  ===
input string InpAlert_Hotkey = "A";
class DAlert: public IDrawingTool {
    public:
    DAlert(): IDrawingTool() {
        Tag = "Alert";
        mTypeLimit = 2;
        mTypeNames[0] = "Alert";
        mTypeNames[1] = "Test!";
        mPointLimit = 1;
        /// Get near High, near Low and valid AlertList
        Commons::UpdateAskBid();
        mStrAlerts = "";
        mLowest_HAPrice = INVALID_H;
        mHighest_LAPrice  = INVALID_L;
        string tagAlertItem = Tag + "_FibL";
        int objTotal = ObjectsTotal(0, -1);
        string objName = "";
        // ver2 - Simple
        for (int i = objTotal; i >= 0; i--) {
            objName = ObjectName(0, i);
            // Alert Filter
            if (StringFind(objName, tagAlertItem) == -1) continue;
            mStrAlerts += objName + ",";
        }
        findClosestAlert("");
    }
    private:
    void intTools() override {
        Hotkey = (char)InpAlert_Hotkey[0];
    }
    // Internal Child Function
    protected:
    string m_objFibL;
    string m_objBack;
    string m_objText;
    string m_objTxBG;

    string mStrAlerts;
    string mArrAlerts[];
    int    mAlertNumber;
    string mLowest_HAObj;
    string mHighest_LAObj;
    double mLowest_HAPrice;
    double mHighest_LAPrice;

    void prepareObj() override {
        m_objFibL = mObjId + "_FibL";
    };
    virtual bool createObj() override {
        if (mType == 0) {
            ObjectCreate(0, m_objFibL, OBJ_FIBO, 0, time0, price0, time1, price0);
            ObjectSetInteger(0, m_objFibL, OBJPROP_SELECTABLE, true);
            ObjectSetInteger(0, m_objFibL, OBJPROP_COLOR, clrNONE);
            ObjectSetInteger(0, m_objFibL, OBJPROP_RAY, false);
            ObjectSetInteger(0, m_objFibL, OBJPROP_RAY_RIGHT, true);
            ObjectSetInteger(0, m_objFibL, OBJPROP_WIDTH, 2);
            //
            ObjectSetInteger(0, m_objFibL, OBJPROP_LEVELS, 1);
            ObjectSetInteger(0, m_objFibL, OBJPROP_LEVELSTYLE, 0, STYLE_DOT);
            ObjectSetDouble(0, m_objFibL, OBJPROP_LEVELVALUE, 0, 0);
            ObjectSetInteger(0, m_objFibL, OBJPROP_LEVELWIDTH, 0, 1);
            ObjectSetInteger(0, m_objFibL, OBJPROP_LEVELCOLOR, 0, clrGray);
            updateTypeObj();
            mStrAlerts += m_objFibL + ",";
            refreshObj();
            return true;
        }
        else if (mType == 1) {
            sendNotification("↗﹉↘﹍" + DoubleToString(Commons::MousePrice, _Digits) + "\nThông báo OK!");
            return false;
        }
        return false;
    };
    virtual bool deleteObj(string sparam) override {
        if (StringFind(sparam, "_FibL") != -1) {
            StringReplace(mStrAlerts, sparam+",", "");
        }
        if (sparam == mLowest_HAObj) {
            findClosestAlert(ALERT_H);
        }
        else if (sparam == mHighest_LAObj) {
            findClosestAlert(ALERT_L);
        }
        return true;
    };
    // virtual void cancelObj() override {
    // };
    // virtual string optionInfo() override {
    // }
    // virtual void updateTypeObj() override {
    // };
    virtual void activeObj(bool state) override {
        ObjectSetInteger(0, m_objFibL, OBJPROP_SELECTED, state);
    };
    virtual void refreshObj() override {
        time1 = time0 + 5 * PeriodSeconds(_Period);
        ObjectMove(0, m_objFibL, 0, time0, price0);
        ObjectMove(0, m_objFibL, 1, time1, price0);

        ObjectSetString(0, m_objFibL, OBJPROP_LEVELTEXT, 0, "►"+DoubleToString(price0, _Digits));
        if (price0 > Commons::Bid) {
            ObjectSetString(0, m_objFibL, OBJPROP_TEXT, ALERT_H);
            findClosestAlert(ALERT_H);
        }
        else {
            ObjectSetString(0, m_objFibL, OBJPROP_TEXT, ALERT_L);
            findClosestAlert(ALERT_L);
        }
    };
    virtual void changeObj(string sparam) override {
        // TODO add text
    };
    virtual void prepareData(string sparam) override {
        time0 = (datetime) ObjectGetInteger(0, m_objFibL, OBJPROP_TIME, 0);
        if (Commons::CtrlHeld) price0 = Commons::MousePrice;
        else price0 = ObjectGetDouble(0, m_objFibL, OBJPROP_PRICE, 0);
    };
    // virtual void userAction(int key) override {};
    void sendNotification(string msg){
        SendNotification(msg);
    }
    void findClosestAlert(string type) {
        double curPrice;
        string mAlertTxt;
        int i;
        if (type == ALERT_H) {
            mAlertNumber = StringSplit(mStrAlerts, ',', mArrAlerts);
            mLowest_HAPrice = INVALID_H;
            for (i = 0; i < mAlertNumber; i++) {
                mAlertTxt = ObjectGetString(0, mArrAlerts[i], OBJPROP_TEXT);
                curPrice = ObjectGetDouble(0, mArrAlerts[i], OBJPROP_PRICE, 0);
                if (StringFind(mAlertTxt, ALERT_H) != -1) {
                    if (curPrice < mLowest_HAPrice) {
                        mLowest_HAPrice = curPrice;
                        mLowest_HAObj = mArrAlerts[i];
                    }
                }
            }
        }
        else if (type == ALERT_L) {
            mAlertNumber = StringSplit(mStrAlerts, ',', mArrAlerts);
            mHighest_LAPrice = INVALID_L;
            for (i = 0; i < mAlertNumber; i++) {
                mAlertTxt = ObjectGetString(0, mArrAlerts[i], OBJPROP_TEXT);
                curPrice = ObjectGetDouble(0, mArrAlerts[i], OBJPROP_PRICE, 0);
                if (StringFind(mAlertTxt, ALERT_L) != -1) {
                    if (curPrice > mHighest_LAPrice) {
                        mHighest_LAPrice = curPrice;
                        mHighest_LAObj = mArrAlerts[i];
                    }
                }
            }
        }
        else {
            mAlertNumber = StringSplit(mStrAlerts, ',', mArrAlerts);
            mLowest_HAPrice = INVALID_H;
            mHighest_LAPrice = INVALID_L;
            for (i = 0; i < mAlertNumber; i++) {
                mAlertTxt = ObjectGetString(0, mArrAlerts[i], OBJPROP_TEXT);
                curPrice = ObjectGetDouble(0, mArrAlerts[i], OBJPROP_PRICE, 0);
                if (StringFind(mAlertTxt, ALERT_H) != -1) {
                    if (curPrice < mLowest_HAPrice) {
                        mLowest_HAPrice = curPrice;
                        mLowest_HAObj = mArrAlerts[i];
                    }
                }
                else if (StringFind(mAlertTxt, ALERT_L) != -1) {
                    if (curPrice > mHighest_LAPrice) {
                        mHighest_LAPrice = curPrice;
                        mHighest_LAObj = mArrAlerts[i];
                    }
                }
            }
        }
    }
    public:
        string curHiLo;
        string preHiLo;
        virtual void onTick() override {
            //// Debug Alert
            // curHiLo = "H: " + DoubleToString(mLowest_HAPrice, _Digits) + " - L:" + DoubleToString(mHighest_LAPrice, _Digits);
            // if (curHiLo != preHiLo) {
            //     Print("curHiLo ", curHiLo);
            //     preHiLo = curHiLo;
            // }
            if (mLowest_HAPrice != INVALID_H) {
                if (Commons::Bid > mLowest_HAPrice) {
                    sendNotification(ALERT_H + DoubleToString(mLowest_HAPrice, _Digits));
                    ObjectDelete(0, mLowest_HAObj);
                    ChartRedraw();
                }
                else if (Commons::Bid == mLowest_HAPrice) {
                    sendNotification(ALERT_H + "﹉" + DoubleToString(mLowest_HAPrice, _Digits));
                }
            }
            if (mHighest_LAPrice != INVALID_L) {
                if (Commons::Bid < mHighest_LAPrice) {
                    sendNotification(ALERT_L + DoubleToString(mHighest_LAPrice, _Digits));
                    ObjectDelete(0, mHighest_LAObj);
                    ChartRedraw();
                }
                else if (Commons::Bid == mHighest_LAPrice) {
                    sendNotification(ALERT_L + "﹍" + DoubleToString(mHighest_LAPrice, _Digits));
                }
            }
        }
};

input string InpOther = ""; // ===  O T H E R   S T U F F S  ===
input string InpErase_Hotkey = "E";
input string InpDelete_Hotkey = "B";
input string InpToggleTradeLever_Hotkey = "I";
input string InpToggleScalePanel_Hotkey = "O";
input string InpToggleCrossHair_Hotkey = "F";
input string InpTimeFrameMoving_Hotkey = "Q";
input string InpTimeFrameList = "5,H1,H4,D1"; // TFList: Ex: 1,5,15,H1,H4,D1,W1,MN1

/// DRAWING OBJECT AND FIND TOOL LOGIC
Rectangle   rectangle;
Trend       trend;
Trade       trade;
Zigzag      zigzag;
Callout     callout;
DAlert      alert;
bool findToolByKey(int key) {
    if (key == rectangle.Hotkey) gpCurDrawingTool = & rectangle;
    else if (key == trend.Hotkey) gpCurDrawingTool = & trend;
    else if (key == zigzag.Hotkey) gpCurDrawingTool = & zigzag;
    else if (key == callout.Hotkey) gpCurDrawingTool = & callout;
    else if (key == trade.Hotkey) gpCurDrawingTool = & trade;
    else if (key == alert.Hotkey) gpCurDrawingTool = & alert;
    // else if (key == xxx.Hotkey) gpCurDrawingTool = &xxx
    else {
        return false;
    }
    return true;
}

bool findToolByTag(string sparam) {
    if (StringFind(sparam, rectangle.Tag) != -1) gpCurDrawingTool = & rectangle;
    else if (StringFind(sparam, trend.Tag) != -1) gpCurDrawingTool = & trend;
    else if (StringFind(sparam, zigzag.Tag) != -1) gpCurDrawingTool = & zigzag;
    else if (StringFind(sparam, callout.Tag) != -1) gpCurDrawingTool = & callout;
    else if (StringFind(sparam, trade.Tag) != -1) gpCurDrawingTool = & trade;
    else if (StringFind(sparam, alert.Tag) != -1) gpCurDrawingTool = & alert;
    // else if (StringFind(sparam, xxx.Tag) != -1) gpCurDrawingTool = &xxx;
    else {
        return false;
    }
    return true;
}
#ifndef EA
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    Commons::UpdateAskBid();
    alert.onTick();
    // trade.onTick();
    infoItems.onTick();
    return(rates_total);
}
#else
void OnTick(){
    Commons::UpdateAskBid();
    alert.onTick();
    // trade.onTick();
    infoItems.onTick();
}
#endif
/// INIT and DEINIT ///
void OnInit() {
    ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
    ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, 1);
    ChartSetInteger(0, CHART_SHIFT, 1);
    ChartSetInteger(0, CHART_AUTOSCROLL, 0);
    ChartSetInteger(0, CHART_SCALEFIX, 1);

    qHotkey.onInit();
    
    // Drawing Tools
    rectangle.onInit();
    trend.onInit();
    trade.onInit();
    zigzag.onInit();
    callout.onInit();
    alert.onInit();
}
void OnDeinit(const int reason) {
}
/// CORE LOGIC ///
InfoItems   infoItems;
QuickHotkey qHotkey;
IDrawingTool * gpCurDrawingTool = NULL;

void OnChartEvent(const int id,
                  const long & lparam,
                  const double & dparam,
                  const string & sparam) {
    /// MOUSE EVENT
    if (id == CHARTEVENT_MOUSE_MOVE) {
        Commons::UpdateMousePosition(lparam, dparam, sparam);
        infoItems.Update();

        if (gpCurDrawingTool != NULL)
            gpCurDrawingTool.onMouseMove();
    }
    else if (id == CHARTEVENT_CLICK) {
        if (gpCurDrawingTool != NULL) gpCurDrawingTool.onMouseClick();
        if (gpCurDrawingTool == NULL) infoItems.showMouseInfo("");
    }
    /// KEYBOARD EVENT
    else if (id == CHARTEVENT_KEYDOWN) {
        int key = (int) lparam;
        if (gpCurDrawingTool == NULL) {
            // Create New!
            if (findToolByKey(key) == true) {
                gpCurDrawingTool.createNew();
                infoItems.showMouseInfo(gpCurDrawingTool.mouseInfo());
            }
            else qHotkey.handleKey(key);
        }
        else if (gpCurDrawingTool.Creating == true) {
            if (key == gpCurDrawingTool.Hotkey) {
                gpCurDrawingTool.updateType();
                infoItems.showMouseInfo(gpCurDrawingTool.mouseInfo());
                infoItems.showOptionInfo("");
            }
            else if (key >= '1' && key <= '9') {
                gpCurDrawingTool.updateType(key - '1');
                infoItems.showMouseInfo(gpCurDrawingTool.mouseInfo());
            }
            else if (key == 27) { // ESC
                gpCurDrawingTool.cancelDraw();
                gpCurDrawingTool = NULL;
                infoItems.showMouseInfo("");
            }
        }
        else {
            // Create New!
            if (findToolByKey(key) == true) {
                gpCurDrawingTool.createNew();
                infoItems.showMouseInfo(gpCurDrawingTool.mouseInfo());
                infoItems.showOptionInfo("");
            }
            else if (gpCurDrawingTool.Editing == true) {
                if (key >= '1' && key <= '9') {
                    gpCurDrawingTool.updateType(key - '1');
                    infoItems.showOptionInfo(gpCurDrawingTool.optionInfo());
                    ChartRedraw();
                }
                else if (key == 27) { // ESC
                    gpCurDrawingTool.cancelDraw();
                    Commons::UnselectAll();
                    infoItems.showOptionInfo("");
                    gpCurDrawingTool = NULL;
                }
                qHotkey.handleKey(key);
            }
        }
    }
    /// OBJECT EVENTS
    else if (id == CHARTEVENT_OBJECT_CLICK || id == CHARTEVENT_OBJECT_DRAG) {
        // Known issue:
        // A tool activated, then we touch to the inactive -> activated still active and we lost Option!
        if (gpCurDrawingTool != NULL && gpCurDrawingTool.Creating == true) return;
        if (findToolByTag(sparam) == true) {
            gpCurDrawingTool.onObjectTouch(sparam);
            if (gpCurDrawingTool.Editing)
                infoItems.showOptionInfo(gpCurDrawingTool.optionInfo());
            else {
                infoItems.showOptionInfo("");
                gpCurDrawingTool = NULL;
            }
        }
    }
    else if (id == CHARTEVENT_OBJECT_CHANGE) {
        if (findToolByTag(sparam) == true) gpCurDrawingTool.onObjectChange(sparam);
    }
    else if (id == CHARTEVENT_OBJECT_DELETE) {
        if (gpCurDrawingTool != NULL && gpCurDrawingTool.Creating == true) return;
        if (findToolByTag(sparam) == true) gpCurDrawingTool.onObjectDelete(sparam);
        infoItems.showOptionInfo("");
        gpCurDrawingTool = NULL;
    }
}
