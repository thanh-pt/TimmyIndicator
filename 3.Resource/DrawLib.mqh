/*
Workflow:
Draw các thứ thoải mái
Cuối cycle -> hide unsused item
*/


#ifndef APP_TAG
#define APP_TAG "DrawLib"
#endif


#define LINETAG "Line"
#define RECTTAG "Rect"

int gDlLineIdx = 0;
void drawLine(datetime time1, datetime time2, double price1, double price2, color cl){
    drawLine(time1, time2, price1, price2, cl, STYLE_DOT);
}

void drawLine(datetime time1, datetime time2, double price1, double price2, color clr, int style){
    string objName = APP_TAG + LINETAG + IntegerToString(gDlLineIdx++);
    ObjectCreate(objName, OBJ_TREND, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_HIDDEN, true);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objName, OBJPROP_RAY, false);
    // Style
    ObjectSet(objName, OBJPROP_BACK, true);
    ObjectSet(objName, OBJPROP_COLOR, clr);
    ObjectSet(objName, OBJPROP_STYLE, style);
    ObjectSet(objName, OBJPROP_WIDTH, 3);
    // Basic
    ObjectSet(objName, OBJPROP_TIME1, time1);
    ObjectSet(objName, OBJPROP_TIME2, time2);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
    ObjectSet(objName, OBJPROP_PRICE2, price2);
}

int gDlRectIdx = 0;
void drawRect(datetime time1, datetime time2, double price1, double price2, color cl){
    string objName = APP_TAG + RECTTAG + IntegerToString(gDlRectIdx++);
    ObjectCreate(objName, OBJ_RECTANGLE, 0, 0, 0);
    // Default
    ObjectSet(objName, OBJPROP_HIDDEN, true);
    ObjectSet(objName, OBJPROP_SELECTABLE, false);
    ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
    // Style
    ObjectSet(objName, OBJPROP_BACK, true);
    ObjectSet(objName, OBJPROP_COLOR, cl);
    ObjectSet(objName, OBJPROP_STYLE, STYLE_DOT);
    // Basic
    ObjectSet(objName, OBJPROP_TIME1, time1);
    ObjectSet(objName, OBJPROP_TIME2, time2);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
    ObjectSet(objName, OBJPROP_PRICE2, price2);
}

void hideItem(int &index, string tag){
    string objName = APP_TAG + tag + IntegerToString(index);
    while(ObjectFind(objName) >= 0){
        ObjectSet(objName, OBJPROP_TIME1, 0);
        ObjectSet(objName, OBJPROP_TIME2, 0);
        objName = APP_TAG + tag + IntegerToString(index++);
    }
    index = 0;
}

void drawLibEnd()
{
    hideItem(gDlLineIdx, LINETAG);
    hideItem(gDlRectIdx, RECTTAG);
}