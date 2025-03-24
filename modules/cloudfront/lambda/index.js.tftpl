const USERNAME = ${basic_user}
const PASSWORD = ${basic_password}

exports.handler = async (event) => {
  try {
    const request = event.Records[0].cf.request;
    const headers = request.headers;
    const authString = "Basic " + Buffer.from(USERNAME + ":" + PASSWORD).toString("base64");
    
    console.log("auth string: " + authString);
    console.log("auth header full: " + JSON.stringify(headers.authorization || "none"));
    
    const authValue = headers.authorization && headers.authorization[0] ? headers.authorization[0].value : null;
    console.log("auth header value: " + (authValue || "none"));
    
    if (!authValue || authValue !== authString) {
      return {
        status: "401",
        statusDescription: "Unauthorized",
        body: "Unauthorized",
        headers: {
          "www-authenticate": [{ key: "WWW-Authenticate", value: 'Basic realm="Restricted Area"' }]
        }
      };
    }
    return request;
  } catch (error) {
    console.error("Lambda error:", error);
    return {
      status: "500",
      statusDescription: "Internal Server Error",
      body: "Something went wrong"
    };
  }
};