//@version=3 
study(title="FTR", shorttitle="FTR") 
ftr_lag      = input(9) 
ftr_ema_len  = input(14) 
  
ftr(lag, ftr_len) => 
    tr_t  = max(max((high - low), (high - close[lag])), (low - close[lag])) 
    ftr_t = ema(tr_t, ftr_len) 
 
plot(ftr(ftr_lag, ftr_ema_len), color=red, linewidth=2) 
