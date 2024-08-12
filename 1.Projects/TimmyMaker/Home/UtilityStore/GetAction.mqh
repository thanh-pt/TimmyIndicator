string getTFString()
{
    int period = ChartPeriod();

    string result = "";
    if (period < PERIOD_H1)
    {
        result = IntegerToString(period);
        return result;
    }
    if (period < PERIOD_D1)
    {
        result = "h";
        result += IntegerToString(period/PERIOD_H1);
        return result;
    }
    if (period < PERIOD_W1)
    {
        result = "d";
        return result;
    }
    if (period < PERIOD_MN1)
    {
        result = "w";
        return result;
    }
    result = "mn";
    return result;
}

int getHigerTF()
{
    int currentTf = ChartPeriod();
    int retTF = PERIOD_H4;
    switch (currentTf)
    {
        case PERIOD_D1:  retTF = PERIOD_D1; break;
        case PERIOD_H4:  retTF = PERIOD_D1; break;
        case PERIOD_M15: retTF = PERIOD_H4; break;
        case PERIOD_M5:  retTF = PERIOD_M15; break;
        case PERIOD_M1:  retTF = PERIOD_M5; break;
    }
    return retTF;
}

int getLowerTF()
{
    int currentTf = ChartPeriod();
    int retTF = PERIOD_M5;
    switch (currentTf)
    {
        case PERIOD_D1:  retTF = PERIOD_H4; break;
        case PERIOD_H4:  retTF = PERIOD_M15; break;
        case PERIOD_M15: retTF = PERIOD_M5; break;
        // case PERIOD_M5:  retTF = PERIOD_M1; break;
        // case PERIOD_M1:  retTF = PERIOD_M1; break;
    }
    return retTF;
}

void getCenterPos(const datetime& time1, const datetime& time2, double price1, double price2, datetime& outTime, double& outPrice)
{
    int x1,y1,x2,y2;
    int window = 0;
    ChartTimePriceToXY(0, window, time1, price1, x1, y1);
    ChartTimePriceToXY(0, window, time2, price2, x2, y2);
    x1 = (x1+x2)/2;
    y1 = (y1+y2)/2;
    ChartXYToTimePrice(0, x1, y1, window, outTime, outPrice);
    outPrice = (price1+price2)/2;
}

datetime getCenterTime(const datetime& time1, const datetime& time2)
{
    datetime centerTime;
    double price;
    double priceInp = ChartGetDouble(0,CHART_FIXED_MAX);
    getCenterPos(time1, time2, priceInp, priceInp, centerTime, price);
    return centerTime;
}

int getDistanceBar(int bar)
{
    return bar * Period() * 60;
}

string getItemUnderMouse(int posX, int posY)
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (ObjectGet(objName, OBJPROP_SELECTED) == false) continue;
        if (ObjectGet(objName, OBJPROP_SELECTABLE) == false) continue;
        if (StringFind(objName, TAG_CTRL) == -1) continue;

        int objType = ObjectType(objName);

        if (objType == OBJ_TREND || objType == OBJ_RECTANGLE)
        {
            int x1, y1, x2, y2;
            ChartTimePriceToXY(0, 0, (datetime)ObjectGet(objName, OBJPROP_TIME1), ObjectGet(objName, OBJPROP_PRICE1), x1, y1);
            ChartTimePriceToXY(0, 0, (datetime)ObjectGet(objName, OBJPROP_TIME2), ObjectGet(objName, OBJPROP_PRICE2), x2, y2);

            int offset = 10;
            if (x1 > x2)
            {
                int temp = x1;
                x1 = x2;
                x2 = temp;
            }
            if (posX < (x1 - offset) || posX > (x2 + offset))
            {
                continue;
            }
            if (y1 > y2)
            {
                int temp = y1;
                y1 = y2;
                y2 = temp;
            }
            if (posY >= (y1 - offset) && posY < (y2 + offset))
            {
                return objName;
            }
            continue;
        }
        if (objType == OBJ_ARROW || objType == OBJ_TEXT)
        {
            int x1, y1;
            ChartTimePriceToXY(0, 0, (datetime)ObjectGet(objName, OBJPROP_TIME1), ObjectGet(objName, OBJPROP_PRICE1), x1, y1);

            int offset = 10;
            if (posX < (x1 - offset) || posX > (x1 + offset))
            {
                continue;
            }
            if (posY >= (y1 - offset) && posY < (y1 + offset))
            {
                return objName;
            }
            continue;
        }
        if (objType == OBJ_LABEL)
        {
            int x1 = (int)ObjectGet(objName, OBJPROP_XDISTANCE);
            int y1 = (int)ObjectGet(objName, OBJPROP_YDISTANCE);

            int offset = 20;
            if (posX < (x1 - offset) || posX > (x1 + offset))
            {
                continue;
            }
            if (posY >= (y1 - offset) && posY < (y1 + offset))
            {
                return objName;
            }
            continue;
        }
    }
    return "";
}

// This function using for overlaping feature
int getObjectTimeId(string objId)
{
    int startP = StringFind(objId, "#");
    if (startP < 0) return hashString(objId);
    int endP = StringFind(objId, "_", startP);
    if (endP < 0) return hashString(objId);
    string timeIdStr = StringSubstr(objId, startP+1, endP-startP-1);
    return StrToInteger(timeIdStr);
}

string getRandStr(){
    return gStrRand[rand()%(ArraySize(gStrRand))];
}

string getSpaceBL(int size){
    if (size == 0) return "";
    return StringSubstr(BL_SPACE, 0, size);
}
string getFullBL(int size){
    return StringSubstr(BL_FULL, 0, size);
}
string getHalfUpBL(int size){
    if (size % 2 != 0) size++;
    return StringSubstr(BL_HALF_UP, 0, size/2);
}
string getHalfDwBL(int size){
    if (size % 2 != 0) size++;
    return StringSubstr(BL_HALF_DN, 0, size/2);
}

int getWeekOfYear(datetime date)
{
    return (TimeDayOfYear(date)+TimeDayOfWeek(StrToTime(IntegerToString(TimeYear(date))+".01.01"))-2)/7;
}

string getDayOfWeekStr(datetime date)
{
    int dayOfWeek = TimeDayOfWeek(date);
    string retDayOfW = "";
    switch (dayOfWeek)
    {
        case 0: retDayOfW = "CN"; break;
        case 1: retDayOfW = "T2"; break;
        case 2: retDayOfW = "T3"; break;
        case 3: retDayOfW = "T4"; break;
        case 4: retDayOfW = "T5"; break;
        case 5: retDayOfW = "T6"; break;
        case 6: retDayOfW = "T7"; break;
        // case 0: retDayOfW = "Su"; break;
        // case 1: retDayOfW = "Mo"; break;
        // case 2: retDayOfW = "Tu"; break;
        // case 3: retDayOfW = "We"; break;
        // case 4: retDayOfW = "Th"; break;
        // case 5: retDayOfW = "Fr"; break;
        // case 6: retDayOfW = "Sa"; break;
    }
    return retDayOfW;
}

string getSubStr(string str, int start, int len)
{
    string result = "";
    result = StringSubstr(str, start, len);
    if (result == "") return StringSubstr(str, 0, len);
    
    return result;
}
