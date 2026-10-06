const http = require("http");
const https = require("https");
const fs = require("fs");

const PORT = Number(process.env.OBSIDIAN_MCP_ADAPTER_PORT || 27125);
const TARGET_HOST = "127.0.0.1";
const TARGET_PORT = Number(process.env.OBSIDIAN_REST_API_PORT || 27124);
const TARGET_PATH = "/mcp/";
const API_KEY = process.env.OBSIDIAN_API_KEY;

if (!API_KEY) {
  console.error("FATAL: OBSIDIAN_API_KEY is missing.");
  process.exit(2);
}

const caPath = process.env.OBSIDIAN_CA_BUNDLE;
if (!caPath || !fs.existsSync(caPath)) {
  console.error("FATAL: OBSIDIAN_CA_BUNDLE is missing or does not exist.");
  process.exit(2);
}

const server = http.createServer((req, res) => {
  if (req.url === "/.well-known/oauth-protected-resource/mcp" ||
      req.url === "/.well-known/oauth-protected-resource") {
    res.writeHead(404, {"Content-Type": "text/plain"});
    res.end("Not Found");
    return;
  }

  if (!req.url.startsWith("/mcp")) {
    res.writeHead(404, {"Content-Type": "text/plain"});
    res.end("Not Found");
    return;
  }

  const headers = {...req.headers};
  headers.host = `${TARGET_HOST}:${TARGET_PORT}`;
  headers.authorization = `Bearer ${API_KEY}`;

  const options = {
    hostname: TARGET_HOST,
    port: TARGET_PORT,
    path: TARGET_PATH,
    method: req.method,
    headers,
    ca: fs.readFileSync(caPath),
    rejectUnauthorized: true
  };

  const upstream = https.request(options, upstreamRes => {
    res.writeHead(upstreamRes.statusCode, upstreamRes.headers);
    upstreamRes.pipe(res);
  });

  upstream.on("error", err => {
    console.error(`upstream error: ${err.message}`);
    if (!res.headersSent) res.writeHead(502);
    res.end("Bad Gateway");
  });

  req.pipe(upstream);
});

server.listen(PORT, "127.0.0.1", () => {
  console.log(`adapter listening on 127.0.0.1:${PORT}`);
});
