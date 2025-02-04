//+------------------------------------------------------------------+
//|                           BollingerBandsEA.mq4 |
//|                        Copyright 2023, YourName|versão 1.1
//+------------------------------------------------------------------+

#property version "1.0"
#property strict

//--- input parameters
input double LotSize = 0.1; // Lote
input int StopLoss = 50;    // Stop Loss em pontos
input int TakeProfit = 100; // Take Profit em pontos
input int BollingerPeriod = 20; // Periodo das Bandas de Bollinger
input double BollingerDeviation = 2.0; // Desvio padrão das Bandas de Bollinger

//--- variáveis globais para estatísticas
int totalBuyOrders = 0;
int totalSellOrders = 0;
double totalProfit = 0.0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- inicialização concluída
   Print("EA inicializado.");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //--- nada a fazer aqui
   Print("EA desinicializado.");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //--- arrays para armazenar os valores das Bandas de Bollinger
   double upperBand, middleBand, lowerBand;

   //--- obter os valores das Bandas de Bollinger
   upperBand = iBands(NULL, 0, BollingerPeriod, 0, BollingerDeviation, PRICE_CLOSE, MODE_UPPER, 0);
   middleBand = iBands(NULL, 0, BollingerPeriod, 0, BollingerDeviation, PRICE_CLOSE, MODE_MAIN, 0);
   lowerBand = iBands(NULL, 0, BollingerPeriod, 0, BollingerDeviation, PRICE_CLOSE, MODE_LOWER, 0);

   //--- verificar valores das Bandas de Bollinger
   Print("Upper Band: ", upperBand, " Middle Band: ", middleBand, " Lower Band: ", lowerBand);

   //--- obter o preço de fechamento atual
   double closePrice = iClose(NULL, 0, 0);
   Print("Close Price: ", closePrice);

   //--- verificar se já existem ordens abertas
   int totalOrders = OrdersTotal();
   Print("Total de ordens abertas: ", totalOrders);

   //--- lógica de compra
   if(closePrice <= lowerBand && totalOrders == 0)
     {
      Print("Condição de compra atendida");
      //--- calcular níveis de stop loss e take profit
      double sl = closePrice - StopLoss * Point;
      double tp = closePrice + TakeProfit * Point;

      //--- abrir uma ordem de compra
      int ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, 3, sl, tp, "Buy Order", 0, 0, Green);
      if(ticket < 0)
        {
         int error = GetLastError();
         Print("Erro ao abrir ordem de compra: ", error);
         if(error == 129) // ERR_INVALID_PRICE
           {
            Print("Erro de preço inválido. Ask: ", Ask, " Slippage: 3");
           }
         else if(error == 134) // ERR_NO_MONEY
           {
            Print("Erro de falta de dinheiro.");
           }
         else if(error == 132) // ERR_MARKET_CLOSED
           {
            Print("Erro de mercado fechado.");
           }
         else
           {
            Print("Erro desconhecido: ", error);
           }
        }
      else
        {
         Print("Ordem de compra aberta com sucesso: Ticket ", ticket);
         totalBuyOrders++;
        }
     }
   else
     {
      Print("Condição de compra não atendida ou já existem ordens abertas.");
     }

   //--- lógica de venda
   if(closePrice >= upperBand && totalOrders == 0)
     {
      Print("Condição de venda atendida");
      //--- calcular níveis de stop loss e take profit
      double sl = closePrice + StopLoss * Point;
      double tp = closePrice - TakeProfit * Point;

      //--- abrir uma ordem de venda
      int ticket = OrderSend(Symbol(), OP_SELL, LotSize, Bid, 3, sl, tp, "Sell Order", 0, 0, Red);
      if(ticket < 0)
        {
         int error = GetLastError();
         Print("Erro ao abrir ordem de venda: ", error);
         if(error == 129) // ERR_INVALID_PRICE
           {
            Print("Erro de preço inválido. Bid: ", Bid, " Slippage: 3");
           }
         else if(error == 134) // ERR_NO_MONEY
           {
            Print("Erro de falta de dinheiro.");
           }
         else if(error == 132) // ERR_MARKET_CLOSED
           {
            Print("Erro de mercado fechado.");
           }
         else
           {
            Print("Erro desconhecido: ", error);
           }
        }
      else
        {
         Print("Ordem de venda aberta com sucesso: Ticket ", ticket);
         totalSellOrders++;
        }
     }
   else
     {
      Print("Condição de venda não atendida ou já existem ordens abertas.");
     }

   //--- atualizar estatísticas
   totalProfit = AccountProfit();

   //--- desenhar as Bandas de Bollinger no gráfico
   ObjectCreate(0, "UpperBand", OBJ_TREND, 0, Time[0], upperBand, Time[Bars-1], iBands(NULL, 0, BollingerPeriod, 0, BollingerDeviation, PRICE_CLOSE, MODE_UPPER, Bars-1));
   ObjectCreate(0, "MiddleBand", OBJ_TREND, 0, Time[0], middleBand, Time[Bars-1], iBands(NULL, 0, BollingerPeriod, 0, BollingerDeviation, PRICE_CLOSE, MODE_MAIN, Bars-1));
   ObjectCreate(0, "LowerBand", OBJ_TREND, 0, Time[0], lowerBand, Time[Bars-1], iBands(NULL, 0, BollingerPeriod, 0, BollingerDeviation, PRICE_CLOSE, MODE_LOWER, Bars-1));

   ObjectSetInteger(0, "UpperBand", OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, "MiddleBand", OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, "LowerBand", OBJPROP_COLOR, clrGreen);

   //--- desenhar estatísticas no gráfico
   string stats = "Total Buy Orders: " + IntegerToString(totalBuyOrders) + "\n" +
                  "Total Sell Orders: " + IntegerToString(totalSellOrders) + "\n" +
                  "Total Profit: " + DoubleToString(totalProfit, 2);
   Comment(stats);
  }
//+------------------------------------------------------------------+
