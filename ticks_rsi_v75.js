require('dotenv').config();
const WebSocket = require('ws');
const { RSI } = require('technicalindicators');

const appId = process.env.DERIV_APP_ID;
const token = process.env.DERIV_API_TOKEN;
const serverUrl = process.env.DERIV_SERVER || `wss://ws.derivws.com/websockets/v3?app_id=${appId}`;

const symbol = 'R_75';        // Volatility 75 Index on Deriv
const rsiPeriod = 14;
const prices = [];            // closing prices for RSI

const ws = new WebSocket(serverUrl);

ws.on('open', () => {
  console.log('Connected to Deriv WebSocket');

  // 1) Authorize with your token (this will bind to whichever account was active when the token was created)
  ws.send(JSON.stringify({
    authorize: token
  }));
});

ws.on('message', (msg) => {
  const data = JSON.parse(msg);

  if (data.msg_type === 'authorize') {
    console.log(`Authorized as: ${data.authorize.loginid} (is_virtual=${data.authorize.is_virtual})`);
    // This tells us whether we're on DEMO (virtual) or REAL.
    // 2) Subscribe to ticks for VIX 75
    ws.send(JSON.stringify({
      ticks: symbol,
      subscribe: 1
    }));
  }

  if (data.msg_type === 'tick') {
    const { quote, epoch, symbol } = data.tick;

    // Use last price as "close" for 1-tick bars
    const price = Number(quote);
    prices.push(price);
    if (prices.length > rsiPeriod + 5) {
      prices.shift(); // keep array small
    }

    let rsiValue = null;
    if (prices.length >= rsiPeriod) {
      rsiValue = RSI.calculate({ period: rsiPeriod, values: prices }).slice(-1)[0];
    }

    const time = new Date(epoch * 1000).toISOString();
    console.log(`${time}  ${symbol}  price=${price}  RSI(${rsiPeriod})=${rsiValue?.toFixed(2) || 'n/a'}`);
  }

  if (data.error) {
    console.error('Deriv error:', data.error);
  }
});

ws.on('close', () => {
  console.log('WebSocket closed');
});

ws.on('error', (err) => {
  console.error('WebSocket error:', err);
});
