#include "Base/BaseItem.mqh"
#include "InfoItem/MouseInfo.mqh"
#include "DrawingTool/Trend.mqh"
#include "DrawingTool/HTrend.mqh"
#include "DrawingTool/ZigZag.mqh"
#include "DrawingTool/Rectangle.mqh"
#include "DrawingTool/CallOut.mqh"
#include "DrawingTool/LongShort.mqh"
#include "DrawingTool/Fibonacci.mqh"

#define CHECK_NOT_ACTIVE_RETURN if(mActive == IDX_NONE){return;}
#define CHECK_ACTIVE_RETURN if(mActive != IDX_NONE){return;}

#define IDX_NONE        -1
#define IDX_TREND       0
#define IDX_HTREND      1
#define IDX_ZIGZAG      2
#define IDX_RECTANGLE   3
#define IDX_FIBONACI    4
#define IDX_CALLOUT     5
#define IDX_LONGSHORT   6

#define ITEM_TREND      "Trend"
#define ITEM_HTREND     "HTrend"
#define ITEM_ZIGZAG     "ZigZag"
#define ITEM_RECTANGLE  "Rectangle"
#define ITEM_FIBONACI   "Fibonacci"
#define ITEM_CALLOUT    "CallOut"
#define ITEM_LONGSHORT  "LongShort"

class Controller
{
private:
    BaseItem*    mListItem[10];
    int         mActive;
    FinishedJob mFinishedJobCb;
    MouseInfo*  pMouseInfo;
    bool        mbStartErase;

private:
    int findItemIdByKey(const int key);
    int findItemIdByName(const string& name);

public:
    Controller(CommonData* commonData, MouseInfo* mouseInfo);
    ~Controller();

public:
    void handleKeyEvent(const long &key);
    void handleIdEventOnly(const int id);
    void handleSparamEvent(const int id, const string& sparam);
    void setFinishedJobCB(FinishedJob cb);
    void finishedJob();
};

void Controller::Controller(CommonData* commonData, MouseInfo* mouseInfo)
{
    pMouseInfo = mouseInfo;
    mActive = IDX_NONE;
    mListItem[IDX_TREND    ]    = new Trend     ( ITEM_TREND     , commonData, mouseInfo);
    mListItem[IDX_HTREND   ]    = new HTrend    ( ITEM_HTREND    , commonData, mouseInfo);
    mListItem[IDX_ZIGZAG   ]    = new ZigZag    ( ITEM_ZIGZAG    , commonData, mouseInfo);
    mListItem[IDX_RECTANGLE]    = new Rectangle ( ITEM_RECTANGLE , commonData, mouseInfo);
    mListItem[IDX_FIBONACI ]    = new Fibonacci ( ITEM_FIBONACI  , commonData, mouseInfo);
    mListItem[IDX_CALLOUT  ]    = new CallOut   ( ITEM_CALLOUT   , commonData, mouseInfo);
    mListItem[IDX_LONGSHORT]    = new LongShort ( ITEM_LONGSHORT , commonData, mouseInfo);
}

Controller::~Controller()
{
    delete mListItem[IDX_TREND    ];
    delete mListItem[IDX_HTREND   ];
    delete mListItem[IDX_ZIGZAG   ];
    delete mListItem[IDX_RECTANGLE];
    delete mListItem[IDX_FIBONACI ];
    delete mListItem[IDX_CALLOUT  ];
    delete mListItem[IDX_LONGSHORT];
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
    mActive = IDX_NONE;
}

int Controller::findItemIdByKey(const int key)
{
    if (key == 'T') return IDX_TREND    ;
    if (key == 'H') return IDX_HTREND   ;
    if (key == 'Z') return IDX_ZIGZAG   ;
    if (key == 'R') return IDX_RECTANGLE;
    if (key == 'F') return IDX_FIBONACI ;
    if (key == 'C') return IDX_CALLOUT  ;
    if (key == 'S') return IDX_LONGSHORT;
    return IDX_NONE;
}

int Controller::findItemIdByName(const string& name)
{
    if (name == ITEM_TREND    ) return IDX_TREND    ;
    if (name == ITEM_HTREND   ) return IDX_HTREND   ;
    if (name == ITEM_ZIGZAG   ) return IDX_ZIGZAG   ;
    if (name == ITEM_RECTANGLE) return IDX_RECTANGLE;
    if (name == ITEM_FIBONACI ) return IDX_FIBONACI ;
    if (name == ITEM_CALLOUT  ) return IDX_CALLOUT  ;
    if (name == ITEM_LONGSHORT) return IDX_LONGSHORT;
    return IDX_NONE;
}

void Controller::handleKeyEvent(const long &key)
{
    if (DEBUG) PrintFormat("handleKeyEvent %c %d", key, key);

    // S1: handle functional Key
    switch ((int)key)
    {
    case 27:
        finishedJob();
        unSelectAll();
        break;
    case '1':
        if (mbStartErase) EraseAll();
        break;
    case '2':
        if (mbStartErase) EraseThisTF();
        break;
    case '3':
        if (mbStartErase) EraseLowerTF();
        break;
    default:
        break;
    }
    if (key == 'E' && mActive == IDX_NONE)
    {
        mbStartErase = true;
        pMouseInfo.setText("Erase: 1-All | 2-ThisTF | 3-LowerTF");
    }
    else
    {
        mbStartErase = false;
        pMouseInfo.setText("");
    }

    // S2: Active drawing tool
    int activeTarget = findItemIdByKey((int)key);
    if (activeTarget == IDX_NONE)
    {
        return;
    }
    if (activeTarget == mActive)
    {
        mListItem[mActive].changeActiveType();
        return;
    }
    CHECK_ACTIVE_RETURN
    mActive = activeTarget;
    
    mListItem[mActive].startActivate(mFinishedJobCb);
}

void Controller::handleIdEventOnly(const int id)
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

void Controller::handleSparamEvent(const int id, const string& sparam)
{
    CHECK_ACTIVE_RETURN

    string sparamItems[];
    int k=StringSplit(sparam,'_',sparamItems);
    if (k != 3)
    {
        return;
    }
    int receiverItem = findItemIdByName(sparamItems[0]);
    if (receiverItem == IDX_NONE)
    {
        return;
    }

    string itemId = sparamItems[0] + "_" + sparamItems[1];
    mListItem[receiverItem].touchItem(itemId);
    switch (id)
    {
    case CHARTEVENT_OBJECT_DELETE:
        mListItem[receiverItem].onItemDeleted(itemId, sparam);
        break;
    case CHARTEVENT_OBJECT_DRAG:
        mListItem[receiverItem].onItemDrag(itemId, sparam);
        break;
    case CHARTEVENT_OBJECT_CHANGE:
        mListItem[receiverItem].onItemChange(itemId, sparam);
        break;
    case CHARTEVENT_OBJECT_CLICK:
        mListItem[receiverItem].onItemClick(itemId, sparam);
        break;
    }
}