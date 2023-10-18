//+------------------------------------------------------------------+
//|                                           PAMarker_OpenOrder.mq4 |
//|                                           Timmy - Trader Ham Học |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property copyright "Timmy - Trader Ham Học"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict

// Note: This script have to move to Scripts folder
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
    // Check new order
    double newOrder = GlobalVariableGet("GV_NewOrder");
    if (newOrder < -0.01) 
    {
        Print("No New Order!");
        return;
    }

    // Check correct symbol
    double symbolCode = GlobalVariableGet("GV_SymbolCode");
    string strSymbol = Symbol();
    double currentSymbolCode = 0;
    for (int i = 0; i < StringLen(strSymbol); i++)
    {
        currentSymbolCode += strSymbol[i] * (i+1);
    }
    if (fabs(currentSymbolCode - symbolCode) > 0.01) 
    {
        Print("Cặp giao dịch không khớp!");
        return;
    }
    
    // Get data
    double priceEN = GlobalVariableGet("GV_priceEN");
    double priceSL = GlobalVariableGet("GV_priceSL");
    double priceTP = GlobalVariableGet("GV_priceTP");
    double lotSize = GlobalVariableGet("GV_lotSize");
    int digit = (int)SymbolInfoInteger(strSymbol, SYMBOL_DIGITS);
    priceEN = NormalizeDouble(priceEN, digit);
    priceSL = NormalizeDouble(priceSL, digit);
    priceTP = NormalizeDouble(priceTP, digit);
    lotSize = NormalizeDouble(lotSize, 2);

    int Cmd = OP_SELLLIMIT;
    if (priceTP > priceEN) Cmd = OP_BUYLIMIT;

    int OrderNumber;
    int Slippage = 200;
    OrderNumber=OrderSend(Symbol(),Cmd,lotSize,priceEN,Slippage,priceSL,priceTP);
    if(OrderNumber>0){
        Print("Order ",OrderNumber," open");
    }
    else{
        Print("Order failed with error - ",GetLastError());
        Alert("Order failed with error - "+IntegerToString(GetLastError()));
    }
    GlobalVariableSet("GV_NewOrder", -1.0);
}
