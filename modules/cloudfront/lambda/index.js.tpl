const USERNAME = "${"${basic_user}"}"
const PASSWORD = "${"${basic_password}"}"


exports.handler = async (event) => {
  const request = event.Records[0].cf.request
  const headers = request.headers
  const authString = "Basic " + Buffer.from(USERNAME + ":" + PASSWORD).toString("base64")
  console.log('auth string: ' + authString)
  console.log("auth header: " + headers.authorization)
  console.log('auth header value: ' + headers.authorization[0])
  
  if (!headers.authorization || headers.authorization[0].value !== authString) {
    return {
      status: "401",
      statusDescription: "Unauthorized",
      body: "Unauthorized",
      headers: { "www-authenticate": [{ key: "WWW-Authenticate", value: "Basic realm=\"Restricted Area\"" }] }
    }
  }
  return request
}
