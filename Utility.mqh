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
    getCenterPos(time1, time2, Close[0], Close[0], centerTime, price);
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
        ObjectDelete(ObjectName(i));
    }
}

void EraseLowerTF()
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string sparamItems[];
        int k1=StringSplit(ObjectName(i),'_',sparamItems);
        if (k1 == 3)
        {
            string strInfoItem[];
            int k2 = StringSplit(sparamItems[1],'#',strInfoItem);
            if (k2 == 2 && StrToInteger(strInfoItem[0]) >= ChartPeriod())
            {
                continue;
            }
        }
        ObjectDelete(ObjectName(i));
    }
}

void EraseThisTF()
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string sparamItems[];
        int k1=StringSplit(ObjectName(i),'_',sparamItems);
        if (k1 == 3)
        {
            string strInfoItem[];
            int k2 = StringSplit(sparamItems[1],'#',strInfoItem);
            if (k2 == 2 && StrToInteger(strInfoItem[0]) == ChartPeriod())
            {
                ObjectDelete(ObjectName(i));
            }
        }
    }
}