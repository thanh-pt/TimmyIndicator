string gTFString = "";
string getTFString()
{
    if (gTFString != "") return gTFString;
    int period = ChartPeriod();
    gTFString = "mn";

    if (period < PERIOD_H1) {
        gTFString = IntegerToString(period);
    }
    else if (period < PERIOD_D1) {
        gTFString = "h";
        gTFString += IntegerToString(period/PERIOD_H1);
    }
    else if (period < PERIOD_W1) {
        gTFString = "d";
        gTFString += IntegerToString(period/PERIOD_D1);
    }
    else if (period < PERIOD_MN1) {
        gTFString = "w";
        gTFString += IntegerToString(period/PERIOD_W1);
    }
    return gTFString;
}

input string _strTfLine = "5,15,H4,D1"; // TF Line (1,5,15,30,H1,H4,D1,W1,MN)

int getHigerTF()
{
    int arrTfLine[9];
    int tfNum = 0;
    arrTfLine[0] = 0;
    string tfItems[9];
    int k = StringSplit(_strTfLine,',',tfItems);
    for (int i = 0; i < k; i++) {
        if (tfItems[i] == "1")  {arrTfLine[tfNum++] = PERIOD_M1 ; continue;}
        if (tfItems[i] == "5")  {arrTfLine[tfNum++] = PERIOD_M5 ; continue;}
        if (tfItems[i] == "15") {arrTfLine[tfNum++] = PERIOD_M15; continue;}
        if (tfItems[i] == "30") {arrTfLine[tfNum++] = PERIOD_M30; continue;}
        if (tfItems[i] == "H1") {arrTfLine[tfNum++] = PERIOD_H1 ; continue;}
        if (tfItems[i] == "H4") {arrTfLine[tfNum++] = PERIOD_H4 ; continue;}
        if (tfItems[i] == "D1") {arrTfLine[tfNum++] = PERIOD_D1 ; continue;}
        if (tfItems[i] == "W1") {arrTfLine[tfNum++] = PERIOD_W1 ; continue;}
        if (tfItems[i] == "MN") {arrTfLine[tfNum++] = PERIOD_MN1; continue;}
    }

    int currentTf = ChartPeriod();
    for (int i = 0; i < tfNum-1; i++){
        if (currentTf == arrTfLine[i]) return arrTfLine[i+1];
    }
    return arrTfLine[tfNum-1];
}

int getLowerTF()
{
    int arrTfLine[9];
    int tfNum = 0;
    arrTfLine[0] = 0;
    string tfItems[9];
    int k = StringSplit(_strTfLine,',',tfItems);
    for (int i = 0; i < k; i++) {
        if (tfItems[i] == "1")  {arrTfLine[tfNum++] = PERIOD_M1 ; continue;}
        if (tfItems[i] == "5")  {arrTfLine[tfNum++] = PERIOD_M5 ; continue;}
        if (tfItems[i] == "15") {arrTfLine[tfNum++] = PERIOD_M15; continue;}
        if (tfItems[i] == "30") {arrTfLine[tfNum++] = PERIOD_M30; continue;}
        if (tfItems[i] == "H1") {arrTfLine[tfNum++] = PERIOD_H1 ; continue;}
        if (tfItems[i] == "H4") {arrTfLine[tfNum++] = PERIOD_H4 ; continue;}
        if (tfItems[i] == "D1") {arrTfLine[tfNum++] = PERIOD_D1 ; continue;}
        if (tfItems[i] == "W1") {arrTfLine[tfNum++] = PERIOD_W1 ; continue;}
        if (tfItems[i] == "MN") {arrTfLine[tfNum++] = PERIOD_MN1; continue;}
    }

    int currentTf = ChartPeriod();
    for (int i = 1; i < tfNum; i++){
        if (currentTf == arrTfLine[i]) return arrTfLine[i-1];
    }
    return arrTfLine[0];
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

string gObjSelectedList[3][20];
int    gObjSelectedIdx0;
int    gObjSelectedIdx1;
int    gObjSelectedIdx2;
string getItemUnderMouse(int posX, int posY)
{
    gObjSelectedIdx0 = 0;
    gObjSelectedIdx1 = 0;
    gObjSelectedIdx2 = 0;
    int objType, i;
    string objName;
    for(i=ObjectsTotal() - 1 ;  i >= 0 ;  i--) {
        objName = ObjectName(i);
        if (ObjectGet(objName, OBJPROP_SELECTED) == false) continue;
        if (ObjectGet(objName, OBJPROP_SELECTABLE) == false) continue;
        if (StringFind(objName, TAG_CTRL) == -1) continue;

        objType = ObjectType(objName);
        if (objType == OBJ_LABEL) {
            gObjSelectedList[0][gObjSelectedIdx0++] = objName;
        }
        else if (objType == OBJ_ARROW || objType == OBJ_TEXT) {
            gObjSelectedList[1][gObjSelectedIdx1++] = objName;
        }
        else if (objType == OBJ_TREND || objType == OBJ_RECTANGLE){
            gObjSelectedList[2][gObjSelectedIdx2++] = objName;
        }
    }
    int x1, x2, y1, y2, offset;
    // Label
    offset = 20;
    for (i = 0; i < gObjSelectedIdx0; i++) {
        x1 = (int)ObjectGet(gObjSelectedList[0][i], OBJPROP_XDISTANCE);
        y1 = (int)ObjectGet(gObjSelectedList[0][i], OBJPROP_YDISTANCE);

        if (posX < (x1 - offset) || posX > (x1 + offset)) continue;
        if (posY >= (y1 - offset) && posY < (y1 + offset)) return gObjSelectedList[0][i];
    }
    // Arrow or Text
    offset = 10;
    for (i = 0; i < gObjSelectedIdx1; i++) {
        ChartTimePriceToXY(0, 0, (datetime)ObjectGet(gObjSelectedList[1][i], OBJPROP_TIME1), ObjectGet(gObjSelectedList[1][i], OBJPROP_PRICE1), x1, y1);

        if (posX < (x1 - offset) || posX > (x1 + offset))  continue;
        if (posY >= (y1 - offset) && posY < (y1 + offset)) return gObjSelectedList[1][i];
    }
    // Rectangle or Trend
    for (i = 0; i < gObjSelectedIdx2; i++){
        ChartTimePriceToXY(0, 0, (datetime)ObjectGet(gObjSelectedList[2][i], OBJPROP_TIME1), ObjectGet(gObjSelectedList[2][i], OBJPROP_PRICE1), x1, y1);
        ChartTimePriceToXY(0, 0, (datetime)ObjectGet(gObjSelectedList[2][i], OBJPROP_TIME2), ObjectGet(gObjSelectedList[2][i], OBJPROP_PRICE2), x2, y2);

        if (x1 > x2) {
            int temp = x1;
            x1 = x2;
            x2 = temp;
        }
        if (posX < (x1 - offset) || posX > (x2 + offset)) continue;
        if (y1 > y2) {
            int temp = y1;
            y1 = y2;
            y2 = temp;
        }
        if (posY >= (y1 - offset) && posY < (y2 + offset)) return objName;
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
