exports.handler = async (event) => {
  const request = event.Records[0].cf.request;
  const headers = request.headers;
  const username = "admin";
  const password = "mysecretpassword";
  const authString = `Basic ${Buffer.from(`${username}:${password}`).toString("base64")}`;
  if (!headers.authorization || headers.authorization[0].value !== authString) {
    return {
      status: "401",
      statusDescription: "Unauthorized",
      body: "Unauthorized",
      headers: { "www-authenticate": [{ key: "WWW-Authenticate", value: "Basic realm=\"Restricted Area\"" }] }
    };
  }
  return request;
};
