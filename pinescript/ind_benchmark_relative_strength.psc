//@version=4
strategy("Benchmark Relative Strength", overlay=false)

benchmark_ticker = input(defval='NSE:NIFTY',    type=input.string, options=['NSE:NIFTY'], title='Benchmark')
source           = input(defval=close,          type=input.source, title='Source')
time_frame       = input(defval='1D',           type=input.resolution, title='Time Frame')

benchmark        = security(benchmark_ticker, time_frame, source)
source_tf        = security(syminfo.tickerid, time_frame, source)
rel_str_sig      = source_tf/benchmark

plot(rel_str_sig, color=color.blue, title='Relative Strength wrt BenchMark')
