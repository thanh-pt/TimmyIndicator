#include "../Base/BaseItem.mqh"
#include "../Tools/Trade.mqh"
#include "../Tools/Alert.mqh"
#include "../Tools/Trend.mqh"
#include "../Tools/Rectangle.mqh"
#include "../Tools/ZigZag.mqh"
#include "../Tools/CallOut.mqh"
#include "../Tools/Fibonacci.mqh"
#include "../Tools/Points.mqh"
#include "../Tools/Label.mqh"
#include "../InfoItem/MouseInfo.mqh"

#define CHECK_NOT_ACTIVE_RETURN if(mActive == eNONE){return;}
#define CHECK_ACTIVE_RETURN if(mActive != eNONE){return;}

enum eToolIdx{
    eTREND    ,
    eZIGZAG   ,
    eRECTANGLE,
    eFIBONACI ,
    eCALLOUT  ,
    eTRADE    ,
    eALERT    ,
    ePOINT    ,
    eLABEL    ,
    eNONE     ,
};

class Controller
{
private:
    BaseItem*   mListItem[10];
    int         mActive;
    FinishedJob mFinishedJobCb;
    MouseInfo*  pMouseInfo;
    bool        mbActiveErase;

private:
    int findItemIdByKey(const int key);
    int findItemIdByName(const string& name);

public:
    Controller(CommonData* commonData, MouseInfo* mouseInfo);
    ~Controller();

public:
    void handleEvent(const long &key);
    void handleEvent(const int id);
    void handleEvent(const int id, const string& sparam);
    void handleOntick();
    void setFinishedJobCB(FinishedJob cb);
    void finishedJob();
};

void Controller::Controller(CommonData* commonData, MouseInfo* mouseInfo)
{
    pMouseInfo = mouseInfo;
    mActive = eNONE;
    mListItem[eTREND    ]   = new Trend     (commonData, mouseInfo);
    mListItem[eZIGZAG   ]   = new ZigZag    (commonData, mouseInfo);
    mListItem[eRECTANGLE]   = new Rectangle (commonData, mouseInfo);
    mListItem[eFIBONACI ]   = new Fibonacci (commonData, mouseInfo);
    mListItem[eCALLOUT  ]   = new CallOut   (commonData, mouseInfo);
    mListItem[eTRADE    ]   = new Trade     (commonData, mouseInfo);
    mListItem[eALERT    ]   = new Alert     (commonData, mouseInfo);
    mListItem[ePOINT    ]   = new Point     (commonData, mouseInfo);
    mListItem[eLABEL    ]   = new LabelText (commonData, mouseInfo);
}

Controller::~Controller()
{
    delete mListItem[eTREND     ];
    delete mListItem[eZIGZAG    ];
    delete mListItem[eRECTANGLE ];
    delete mListItem[eFIBONACI  ];
    delete mListItem[eCALLOUT   ];
    delete mListItem[eTRADE     ];
    delete mListItem[eALERT     ];
    delete mListItem[ePOINT     ];
    delete mListItem[eLABEL     ];
}

void Controller::setFinishedJobCB(FinishedJob cb)
{
    mFinishedJobCb = cb;
}

void Controller::finishedJob()
{
    CHECK_NOT_ACTIVE_RETURN
    pMouseInfo.setText("");
    mListItem[mActive].finishedDeactivate();
    mActive = eNONE;
}

int Controller::findItemIdByKey(const int key)
{
    if (key == 'T') return eTREND     ;
    if (key == 'Z') return eZIGZAG    ;
    if (key == 'R') return eRECTANGLE ;
    if (key == 'F') return eFIBONACI  ;
    if (key == 'C') return eCALLOUT   ;
    if (key == 'G') return eLABEL     ;
    if (key == 'S') return ePOINT     ;
#ifndef Lver
    if (key == 'X') return eALERT     ;
    if (key == 'W') return eTRADE     ;
#endif
    return eNONE;
}

int Controller::findItemIdByName(const string& name)
{
    if (name == Trend::Tag     ) return eTREND     ;
    if (name == ZigZag::Tag    ) return eZIGZAG    ;
    if (name == Rectangle::Tag ) return eRECTANGLE ;
    if (name == Fibonacci::Tag ) return eFIBONACI  ;
    if (name == CallOut::Tag   ) return eCALLOUT   ;
    if (name == Trade::Tag     ) return eTRADE     ;
    if (name == Alert::Tag     ) return eALERT     ;
    if (name == Point::Tag     ) return ePOINT     ;
    if (name == LabelText::Tag ) return eLABEL     ;
    return eNONE;
}

void Controller::handleEvent(const long &key)
{
    // PrintFormat("handleEvent %c %d", key, key);
    // S1: handle functional Key
    bool bFunctionKey = true;
    switch ((int)key)
    {
    case 27: // Esc
        finishedJob();
        setUnselectAll();
        break;
    // Number Line
    case '1':
        if (mbActiveErase) EraseAll();
        break;
    case '2':
        if (mbActiveErase) EraseThisTF();
        break;
    case '3':
        if (mbActiveErase) EraseLowerTF();
        break;
    case '4':
        if (mbActiveErase) EraseBgOverlap();
        break;
    // QWERT Line
    case 'Y':
        ((Trade*)mListItem[eTRADE]).showHistory(true);
        break;
    case 'U':
        ((Trade*)mListItem[eTRADE]).showHistory(false);
        break;
    case 'H':
        setChartFree(true);
        break;
    case 'J':
        setChartFree(false);
        break;
    case 'V':
        syncTimmyItem();
        break;
    case 'B':
        deleteTimmyItem();
        break;
    case 'Q':
        ChartSetSymbolPeriod(0, ChartSymbol(), getLowerTF());
        setChartFree(false);
        break;
    case 'P': // Using AHK to combine 'Shift+Q'='P'
        ChartSetSymbolPeriod(0, ChartSymbol(), getHigerTF());
        setChartFree(false);
        break;
    case 188: // ','
        setScaleChart(false);
        break;
    case 190: // '.'
        setScaleChart(true);
        break;
    case 'L':
        ((Trade*)mListItem[eTRADE]).restoreBacktestingTrade();
        break;
    default:
        bFunctionKey = false;
        break;
    }
    if (mActive == eNONE) {
        if (key == 'E') {
            mbActiveErase = true;
            pMouseInfo.setText("Erase: 1-All | 2-ThisTF | 3-LowerTF | 4-BgOvl");
        }
        else {
            mbActiveErase = false;
            pMouseInfo.setText("");
        }
        if (key >= '1' && key <= '9') {
            if (gContextMenu.mStaticCtxOn == true){
                gContextMenu.onNumKeyPress((int)key-'1');
            }
        }
    }
    else {
        // there is some tool is active
        if (key >= '1' && key <= '9')
        {
            mListItem[mActive].changeActiveType((int)key-'1');
        }
        else if (key == '0')
        {
            mListItem[mActive].changeActiveType(9);
        }
    }
    if (bFunctionKey == true) return;

    // S2: Active drawing tool
    int activeTarget = findItemIdByKey((int)key);
    if (activeTarget == eNONE)
    {
        return;
    }
    if (activeTarget == mActive)
    {
        mListItem[mActive].changeActiveType();
        return;
    }
    CHECK_ACTIVE_RETURN
    setUnselectAll();
    mActive = activeTarget;
    mListItem[mActive].startActivate(mFinishedJobCb);
}

void Controller::handleEvent(const int id)
{
    CHECK_NOT_ACTIVE_RETURN

    switch (id)
    {
    case CHARTEVENT_CLICK:
        mListItem[mActive].onMouseClick();
        break;

    case CHARTEVENT_MOUSE_MOVE:
        mListItem[mActive].onMouseMove();
        break;
    }
}

void Controller::handleEvent(const int id, const string& sparam)
{
    CHECK_ACTIVE_RETURN

    string sparamItems[];
    int k=StringSplit(sparam,'_',sparamItems);
    if (k != 3)
    {
        return;
    }
    int receiverItem = findItemIdByName(sparamItems[0]);
    if (receiverItem == eNONE)
    {
        return;
    }

    string itemId = sparamItems[0] + "_" + sparamItems[1];
    // Feature: Trong một thời điểm chỉ có 1 tool được active
    if (id == CHARTEVENT_OBJECT_CLICK && (int)ObjectGet(sparam, OBJPROP_SELECTED) == 1 && StringFind(sparam, TAG_CTRL) != -1){
        setUnselectAllExcept(itemId);
    }

    mListItem[receiverItem].touchItem(itemId);
    switch (id)
    {
    case CHARTEVENT_OBJECT_DELETE:
        if (StringFind(sparam, TAG_CTRM) == -1) return;
        mListItem[receiverItem].onItemDeleted(itemId, sparam);
        break;
    case CHARTEVENT_OBJECT_DRAG:
        if (StringFind(sparam, TAG_CTRL) == -1) return;
        mListItem[receiverItem].onItemDrag(itemId, sparam);
        break;
    case CHARTEVENT_OBJECT_CHANGE:
        if (StringFind(sparam, TAG_CTRL) == -1) return;
        mListItem[receiverItem].onItemChange(itemId, sparam);
        break;
    case CHARTEVENT_OBJECT_CLICK:
        if (StringFind(sparam, TAG_CTRL) == -1) return;
        mListItem[receiverItem].onItemClick(itemId, sparam);
        break;
    case CHARTEVENT_SELECT_CONTEXTMENU:
        mListItem[receiverItem].onUserRequest(itemId, sparam);
        break;
    }
}

void Controller::handleOntick()
{
    ((Alert*)mListItem[eALERT]).checkAlert();
    ((Trade*)mListItem[eTRADE]).scanLiveTrade();
}