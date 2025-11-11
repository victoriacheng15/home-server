FROM jupyter/datascience-notebook:python-3.11

USER root

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install TA-Lib
RUN wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz \
    && tar -xzf ta-lib-0.4.0-src.tar.gz \
    && cd ta-lib/ \
    && ./configure --prefix=/usr \
    && make \
    && make install \
    && cd .. \
    && rm -rf ta-lib-0.4.0-src.tar.gz ta-lib/

USER $NB_UID

# Install trading packages
RUN pip install --no-cache-dir \
    backtrader \
    yfinance \
    ccxt \
    alpaca-trade-api \
    vectorbt \
    quantlib \
    plotly \
    dash