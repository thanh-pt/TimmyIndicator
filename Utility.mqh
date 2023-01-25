#define SEPARATE_LINE       "------------------------------------------------------------------------------------------------------------------------"
#define SEPARATE_LINE_BIG   "████████████████████████████████████"
#define STATIC_TAG          "%"

void getCenterPos(const datetime& time1, const datetime& time2, double price1, double price2, datetime& outTime, double& outPrice)
{
    int x1,y1,x2,y2;
    int window = 0;
    ChartTimePriceToXY(ChartID(), window, time1, price1, x1, y1);
    ChartTimePriceToXY(ChartID(), window, time2, price2, x2, y2);
    x1 = (x1+x2)/2;
    y1 = (y1+y2)/2;
    ChartXYToTimePrice(ChartID(), x1, y1, window, outTime, outPrice);
}

datetime getCenterTime(const datetime& time1, const datetime& time2)
{
    datetime centerTime;
    double price;
    double priceInp = ChartGetDouble(ChartID(),CHART_FIXED_MAX);
    getCenterPos(time1, time2, priceInp, priceInp, centerTime, price);
    return centerTime;
}

void unSelectAll()
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        ObjectSet(ObjectName(i), OBJPROP_SELECTED, 0);
    }
}

string findItemUnderMouse(int posX, int posY)
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (ObjectGet(objName, OBJPROP_SELECTED) == false) continue;
        if (ObjectGet(objName, OBJPROP_SELECTABLE) == false) continue;

        int objType = ObjectType(objName);

        if (objType == OBJ_TREND)
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
        if (objType == OBJ_RECTANGLE)
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

void EraseAll()
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (StringFind(objName, "LongShort") != -1) continue;
        if (StringFind(objName, STATIC_TAG) != -1) continue;
        ObjectDelete(objName);
    }
}

void EraseLowerTF()
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (StringFind(objName, STATIC_TAG) != -1) continue;
        string sparamItems[];
        int k1=StringSplit(objName,'_',sparamItems);
        if (k1 == 3)
        {
            string strInfoItem[];
            int k2 = StringSplit(sparamItems[1],'#',strInfoItem);
            if (k2 == 2 && StrToInteger(strInfoItem[0]) >= ChartPeriod())
            {
                continue;
            }
        }
        ObjectDelete(objName);
    }
}

void EraseThisTF()
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (StringFind(objName, "LongShort") != -1) continue;
        if (StringFind(objName, STATIC_TAG) != -1) continue;

        string sparamItems[];
        int k1=StringSplit(objName,'_',sparamItems);
        if (k1 == 3)
        {
            string strInfoItem[];
            int k2 = StringSplit(sparamItems[1],'#',strInfoItem);
            if (k2 == 2 && StrToInteger(strInfoItem[0]) == ChartPeriod())
            {
                ObjectDelete(objName);
            }
        }
    }
}

void SetChartScaleFix(bool bFix)
{
    ChartSetInteger(ChartID(), CHART_SCALEFIX, 0, bFix);
}

string getTFString()
{
    string result = "";
    int period = ChartPeriod();
    if (period < PERIOD_H1)
    {
        result = "m";
        result += IntegerToString(period);
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

void setItemPos(const string& objName, const datetime& time1, const datetime& time2, const double price1, const double price2)
{
    ObjectSet(objName, OBJPROP_TIME1 , time1);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
    ObjectSet(objName, OBJPROP_TIME2 , time2);
    ObjectSet(objName, OBJPROP_PRICE2, price2);
}

void setItemPos(const string& objName, const datetime& time1, const double price1)
{
    ObjectSet(objName, OBJPROP_TIME1 , time1);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
}

void setTextPos(const string& objName, const datetime& time1, const double price1)
{
    ObjectSet(objName, OBJPROP_TIME1,  time1);

    string textContent = ObjectDescription(objName);
    if (textContent == "" || textContent == "Text")
    {
        ObjectSet(objName, OBJPROP_PRICE1, 0);
    }
    else
    {
        ObjectSet(objName, OBJPROP_PRICE1, price1);
    }
}

void multiObjectSet(int property, int value, string listObj)
{
    string sparamItems[];
    int k=StringSplit(listObj,'.',sparamItems);
    for (int i = 0; i < k; i++)
    {
        if (sparamItems[i] == "") continue;
        ObjectSet("."+sparamItems[i], property, value);
    }
}

void multiObjectSetString(int property, string value, string listObj)
{
    string sparamItems[];
    int k=StringSplit(listObj,'.',sparamItems);
    for (int i = 0; i < k; i++)
    {
        if (sparamItems[i] == "") continue;
        ObjectSetString(ChartID(), "."+sparamItems[i], property, value);
    }
}

void multiObjectSetInteger(int property, int value, string listObj)
{
    string sparamItems[];
    int k=StringSplit(listObj,'.',sparamItems);
    for (int i = 0; i < k; i++)
    {
        if (sparamItems[i] == "") continue;
        ObjectSetInteger(ChartID(), "."+sparamItems[i], property, value);
    }
}

void commonObjectSet(string obj, bool back, color c, int style, int width)
{
    ObjectSet(obj, OBJPROP_COLOR, c);
    ObjectSet(obj, OBJPROP_BACK , back);
    ObjectSet(obj, OBJPROP_STYLE, style);
    ObjectSet(obj, OBJPROP_WIDTH, width);
    ObjectSet(obj, OBJPROP_RAY,   false);
}