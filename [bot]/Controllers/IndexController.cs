using Microsoft.AspNetCore.Mvc;

public class IndexController : ControllerBase
{
    [HttpGet("/")]
    public IActionResult Index()
    {
        return Ok("Hello World!");
    }
}