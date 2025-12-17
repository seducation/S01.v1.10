const { AccessToken } = require('livekit-server-sdk');

module.exports = async (req, res) => {
  const { roomName, userId } = JSON.parse(req.payload);

  // You can get these from your LiveKit project dashboard
  const apiKey = req.variables['LIVEKIT_API_KEY'];
  const apiSecret = req.variables['LIVEKIT_API_SECRET'];

  if (!apiKey || !apiSecret) {
    res.json({ error: 'LiveKit API key or secret not configured.' }, 400);
    return;
  }

  const at = new AccessToken(apiKey, apiSecret, {
    identity: userId,
  });

  at.addGrant({ roomJoin: true, room: roomName });

  res.json({ token: at.toJwt() });
};
