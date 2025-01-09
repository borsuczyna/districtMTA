using Microsoft.AspNetCore.Mvc;

[Route("api/compile")]
[ApiController]
public class CompileController : ControllerBase
{
    private static string secretKey = "b321hj4123hj5hj235jk13bhj53b1ui3h2178fh78shd8c12h";

    [HttpPost("js")]
    public async Task<string> CompileJavascript()
    {
        try
        {
            if (!Request.Headers.ContainsKey("Authorization"))
                return "Authorization header is missing";

            if (Request.Headers["Authorization"] != secretKey)
                return "Invalid secret key";

            var body = await new StreamReader(Request.Body).ReadToEndAsync();
            var obfuscatedCode = JavaScriptObfuscator.Obfuscate(body);

            return obfuscatedCode;
        }
        catch (Exception e)
        {
            return e.Message;
        }
    }

    [HttpPost("html")]
    public async Task<string> CompileHtml()
    {
        try
        {
            if (!Request.Headers.ContainsKey("Authorization"))
                return "Authorization header is missing";

            if (Request.Headers["Authorization"] != secretKey)
                return "Invalid secret key";

            var body = await new StreamReader(Request.Body).ReadToEndAsync();
            var obfuscator = new HtmlObfuscator();
            var obfuscatedHtml = obfuscator.Obfuscate(body);

            return obfuscatedHtml;
        }
        catch (Exception e)
        {
            return e.Message;
        }
    }

    [HttpPost("css")]
    public async Task<string> CompileCss()
    {
        try
        {
            if (!Request.Headers.ContainsKey("Authorization"))
                return "Authorization header is missing";

            if (Request.Headers["Authorization"] != secretKey)
                return "Invalid secret key";

            var body = await new StreamReader(Request.Body).ReadToEndAsync();
            var minifiedCss = CSSMinifier.Minify(body);

            return minifiedCss;
        }
        catch (Exception e)
        {
            return e.Message;
        }
    }
}